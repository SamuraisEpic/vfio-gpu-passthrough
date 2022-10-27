# vfio-pci Passthrough Guide

### Greeting
 Thanks for checking out this guide. If you use Linux and have have 2 GPUs (integrated graphics count too!), and plan to make for example a Gaming VM with windows on it to pass a card to, this guide will help you get started.

### Disclaimer
Though in this guide i'll be using Libvirt hooks, like the greeting mentions, this guide is best if you have 2 GPUs instead of just one. Even your CPU's integrated graphics processor (hereby referred to as the "iGP") will do just fine.

### Intro
So, why all of this? Well, that's for you to decide. For me it was moving my workflow off of windows for the sake of privacy, stability, and reliability, while still retaining the ability to play certain games. And you might be asking "Why not use Wine, or play natively?" and the answer is that sometimes, its easier to run the vm then jumping through hoops applying patches and using Wine, or the fact that certain anticheats only support windows and not even Proton. With that out of the way, before i get started on the guide, Let's layout some details.

1: This guide focuses on Manjaro, and certain things will only apply to Arch and Manjaro. I'll try to leave Debian commands as well, but i won't be supporting distros like RHEL, Fedora, and Gentoo. Certain steps will also only apply to Arch, and I'll point those out when i get to them

2: Since this is both my first guide, and a beginner-friendly tutorial, i'll leave out more advanced topics like CPU Pinning and Disk Tuning from [Bryan Steiner's guide](https://github.com/bryansteiner/gpu-passthrough-tutorial#----cpu-pinning)

3: This guide is based off of some other guides linked at the bottom, but it also has my own hardware in mind so your results may vary. You can take a look at my own hardware as a pointer to see if it might work, but this is a very loose reference and should work in most cases regardless.

Thing | Value
:-----: | :--------:
CPU | AMD Ryzen 5 5600G
GPU | ASUS NVIDIA Geforce RTX 2060 12GB
RAM | 16GB G.SKILL Aegis DDR4 3000 with XMP
Motherboard | ASUS Prime B550 Plus
BIOS Version | 2803
Software | Manjaro Linux 21.3.7
Kernel | 5.17.13-1-VFIO-MANJARO
QEMU Version | QEMU emulator version 7.1.0
Libvirt Version | 8.8.0

So, without further ado, lets get started!

## Guide

### 1. Prerequisites

#### 1.0: BIOS Settings

**\*\*Note: All of these options and all the pictures provided are from ASUS PRIME AM4 motherboards. Since i don't have experience with other boards, you'll have to hunt for those options yourself, or consult your board manufacturer since they may not be called the same thing shown here. On Intel boards IOMMU is typically called `VT-d`, and Virtualisation is typically called `VT-x`. And for AMD users, Virtualisation could be called `AMD-V`, and IOMMU could be called `AMD-Vi`. These are sadly the only pointers i can give for other boards.**

##### **\*\*Note for 1.3: This setting might not apply at all to your board, or only one of the two options may apply**

##### 1.0.1: Virtualisation
The first thing you'll want to enable in the BIOS is Virtualisation. For my board, or generally any ASUS PRIME AM4 board, this can be found under the `Advanced` tab in `CPU Configuration`
![CPU Options](https://github.com/SamuraisEpic/vfio-gpu-passthrough/blob/main/images/BIOS%20Images/CPU-options.png?raw=true)
Within here, you're gonna wanna look for `SVM Mode` or `SVM`, and make sure it's set to *enabled*![SVM Mode](https://github.com/SamuraisEpic/vfio-gpu-passthrough/blob/main/images/BIOS%20Images/SVM.png?raw=true)

##### 1.0.2: Hardware Enabling IOMMU on the board
Now, before you can do anything in [1.1](https://github.com/SamuraisEpic/vfio-gpu-passthrough#11-enabling-iommu), you have to do this. ***This option is crucial to the rest of the guide since it all depends on IOMMU*** With that out of the way, this is how to enable IOMMU on ASUS PRIME AM4 boards. Under the `Advanced` tab again, look for `AMD CBS`, or something similar it should be near the bottom, so scroll down if necessary. ![AMD CBS](https://github.com/SamuraisEpic/vfio-gpu-passthrough/blob/main/images/BIOS%20Images/CBS-options.png?raw=true) Within this menu, look for `IOMMU`, and make sure it's set to `Enabled`. ***This is important. make sure this is enabled, because the rest of the guide depends on this being on*** ![IOMMU on](https://github.com/SamuraisEpic/vfio-gpu-passthrough/blob/main/images/BIOS%20Images/IOMMU.png?raw=true).

##### 1.0.3: Enabling the iGP and Making it the Primary Video Output ([see warning](https://github.com/SamuraisEpic/vfio-gpu-passthrough#note-for-13-this-setting-might-not-apply-at-all-to-your-board-or-only-one-of-the-two-options-may-apply))
So in order to enable these things yo wanna go back to the advanced tab, and go to `NB Configuration` ![NB configuration](https://github.com/SamuraisEpic/vfio-gpu-passthrough/blob/main/images/BIOS%20Images/NB-config.png?raw=true)
Within this menu, make sure `IGFX Multi-Monitor` is set to `Enabled`, and `Primary Video Device` is set to `IGFX Video`, like in the image below. ![iGP options](https://github.com/SamuraisEpic/vfio-gpu-passthrough/blob/main/images/BIOS%20Images/make-iGP-primary.png?raw=true)

With that done, the BIOS settings should all be good, and you should be ready to move on to 1.1!


#### 1.1: Enabling IOMMU within Linux
This step is mostly the same in every guide. I'll be using Grub, so i'll provide the instructions for Grub, but also for Systemd Boot. The general parameter you're gonna wanna add is `intel_iommu=on` for an Intel CPU, or `amd_iommu=on` for AMD, as well as `iommu=pt` for both manufacturers, and this will apply to both Grub, and Systemd. **\*\*note: I've read in certain guides that assuming IOMMU is enabled in BIOS, The Linux Kernel will automatically enable it on AMD systems. I'm not 100% sure of this so I've added the correct parameter to my own setup just in case. i advise you do the same.**

##### 1.1.1: Enabling IOMMU for Grub
In order to enable IOMMU,  you need to edit the Grub settings file. To do that, you can use any text editor you want, but I'll be using `nano`. To open the file you can use root directly, but i'll be using `sudo`. In my case i'll type in `sudo nano /etc/default/grub`. once that's done, you should get a screen like this: ![my grub settings file](https://github.com/SamuraisEpic/vfio-gpu-passthrough/blob/main/images/grub-config-original.png?raw=true)

Now, where it says `GRUB_CMDLINE_LINUX_DEFAULT="quiet udev.log_priority=3"`(this line might look different depending on your distro), you're going to remove `quiet` (to make debugging your boot a little easier + it looks cooler), and add the command for your CPU's IOMMU, as well as `iommu=pt`. So in my case, since I have an AMD CPU, mine would look like this: `GRUB_CMDLINE_LINUX_DEFAULT="udev.log_priority=3 iommu=pt amd_iommu=on"`. Then, just save and quit. For `nano`, that's Ctrl+O, Enter, and Ctrl+X. So all well and good. Now, to apply these changes, we'll have to regenerate the Grub configuration file. This is super easy, and is universal across any distro that uses Grub. just type `sudo grub-mkconfig -o /boot/grub/grub.cfg` into a terminal, and you're good to go.

##### 1.1.2: Enabling IOMMU for Systemd Boot
For Systemd Boot you can use a tool that comes preinstalled with Pop!\_OS called kernelstub. You can also install it on other distros. Unfortunately, it doesn't seem like any Manjaro repositories or even the AUR has `kernelstub`, but Debian based distros should be able to install it using `sudo apt install kernelstub`. So, in order to allow the Kernel to access IOMMU on Systemd Boot distros, all you have to do is put in the following commands: `sudo kernelstub --add-options "intel_iommu=on" && sudo kernelstub --add-options "iommu=pt"` for Intel CPUs, or `sudo kernelstub --add-options "amd_iommu=on" && sudo kernelstub --add-options "iommu=pt"` for AMD CPUs.

With that, we're done enabling IOMMU! Time for the next step.

#### 1.2: Making Sure IOMMU is Enabled Properly
If you did all those steps correctly, then you should be able to move on to this step, to ensure your IOMMU groups have been configured properly.

##### 1.2.1: Checking if IOMMU is Enabled at All

In order to verify it worked, the first thing you're going to do it put in this command: `sudo dmesg | grep VT-d` for Intel, and `sudo dmesg | grep AMD-Vi` for AMD. If you were successful, you should see something similar to this for AMD CPUs
```
[    0.292288] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
[    0.292888] pci 0000:00:00.2: AMD-Vi: Found IOMMU cap 0x40
[    0.603347] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
[    0.613744] AMD-Vi: AMD IOMMUv2 loaded and initialized
```

##### 1.2.2: Checking if IOMMU Groups are Valid
So what you wanna do here, is run the script provided in the repo, or you can make the script yourself. If you wanna make the script yourself, i recommend placing it in a seperate `vfio` directory within your Home directory. Assuming you've done that, paste this glob of code into it, and then run it.

```
#!/bin/bash
for d in /sys/kernel/iommu_groups/*/devices/*; do
  n=${d#*/iommu_groups/*}; n=${n%%/*}
  printf 'IOMMU Group %s ' "$n"
  lspci -nns "${d##*/}"
done
```

once run, it should give an output similar to this (ids and names may look different or your system)
```

```

Now, the biggest thing to look for here, is that your GPU's Audio and Video (and any other GPU component) is in the same group, and isolated, since you can only pass a full group. If there are other things in there, or if your second GPU is also in there, you'll have to perfrom the ACS Override Patch.

#### 1.3 (optional): ACS Override Patch
If your IOMMU groups aren't valid, then you'll have to perform the ACS Override Patch. There's 2 ways to do it, and you can do whichever one you choose. You can choose to a, Patch the Kernel yourself, which Bryan Steiner also covers, or b) install a different Kernel, notably the Zen Kernel or the linux-vfio Kernel, which have the ACS Override Patch built in, and you just need to specify `pcie_acs_override=downstream` in the boot parameters to ensure the Kernel loads it

##### 1.3.1: Installing a different kernel
This process is very straightforward. All you have to do is type `sudo pacman -S linux-vfio` for the VFIO Kernel or Arch systems, or `sudo apt install linux-vfio` for Debian based systems. Likewise, for the Zen Kernel, just replace `linux-vfio`, with `linux-zen`. After intalling one of the Kernels that has it built in, you then need to specify the ACS Override Patch in the boot process. For grub, just edit `/etc/default/grub` and add the parameter `pcie_acs_override=downstream` to `GRUB_CMDLINE_LINUX_DEFAULT` so, with all the modifications we've made it should look like this (for AMD - Intel has a dfferent IOMMU param [intel_iommu=on]) 
![grub settings with ACS Override Patch](image not here yet)

##### 1.3.2: Patching your Kernel Yourself
Now since I'm not especially well versed in this area, i've linked [Bryan Steiner's guide](https://github.com/bryansteiner/gpu-passthrough-tutorial/#----acs-override-patch-optional), which *does* go over this process. This should get you almost all the way through, minus passing it as a param if you use Grub. For that look at [1.3.1](github.com/SamuraisEpic/vfio-gpu-passthrough#1.3.1:-installing-a-different-kernel) For systemd boot on Debian based systems, Bryan Steiner's guide covers that part with `kernelstub`.
