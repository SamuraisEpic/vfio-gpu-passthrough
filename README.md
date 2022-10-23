# vfio-pci Passthrough Guide

#### Greeting
 Thanks for checking out this guide. If you use Linux and have have 2 GPUs (integrated graphics count too!), and plan to make for example a Gaming VM with windows on it to pass a card to, this guide will help you get started.

#### Disclaimer
Though in this guide i'll be using Libvirt hooks, like the greeting mentions, this guide is best if you have 2 GPUs instead of just one. Even your CPU's integrated graphics processor (hereby referred to as the "iGP") will do just fine.

#### Intro
So, why all of this? Well, that's for you to decide. For me it was moving my workflow off of windows for the sake of privacy, stability, and reliability, while still retaining the ability to play certain games. And you might be asking "Why not use Wine, or play natively?" and the answer is that sometimes, its easier to run the vm then jumping through hoops applying patches and using Wine, or how certain anticheats only support windows and not even Proton. With that out of the way, before i get started on the guide, Let's layout some details.

1: This guide focuses on Manjaro, and certain things will only apply to Arch and Manjaro. I'll try to leave Debian commands as well, but i won't be supportting distros like RHEL, Fedora, and Gentoo. Certain steps will also only apply to Arch, and I'll point those out when i get to them

2: Since this is both my first guide, and a beginner-friendly tutorial, i'll leave out more advanced topics like CPU Pinning and Disk Tuning

3: This guide is based off of some other guides linked at the bottom, but it also has my own hardware in mind so your results may vary. You can take a look at my own hardware as a pointer to see if it might work, but this is a very loose reference and should work in most cases regardless.

Thing | Value
:-----: | :--------:
CPU | AMD Ryzen 5 5600G
GPU | ASUS NVIDIA Geforce RTX 2060 12GB
RAM | 16GB G.SKILL Aegis DDR4 3000 with XMP
Motherboard | ASUS Prime B550 Plus
BIOS Version |2403
Software | Manjaro Linux 21.3.7
Kernel | 5.17.13-1-VFIO-MANJARO
QEMU Version | QEMU emulator version 7.1.0
Libvirt Version | 8.8.0

So, without further ado, lets get started!

## Guide

#### 1. Prerequisites

##### 1.1: Enabling IOMMU
This step is mostly the same in every guide. I'll be using Grub, so i'll provide the instructions for Grub, but also for Systemd Boot. The general parameter you're gonna wanna add is `intel_iommu=on` for an Intel CPU, or `amd_iommu=on` for AMD, as well as `iommu=pt` for both manufacturers, and this will apply to both Grub, and Systemd. **\*\*note: I've read in certain guides that assuming IOMMU is enabled in BIOS, The Linux Kernel will automatically enable it on AMD systems. I'm not 100% sure of this so I've added the correct parameter to my own setup just in case. i advise you do the same.**

##### 1.1.1: Enabling IOMMU for Grub
