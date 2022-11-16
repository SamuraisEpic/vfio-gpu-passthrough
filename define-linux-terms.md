terms to define

AUR (and by extension helpers) - AUR, also known as the Arch User Repository is a great place to get packagees on Arch if they're not in official repositories, or if they only contain loose source files. The downside to using the AUR traditionally, is that you have to clone and compile package sources locally. AUR helpers solve that problem by doing all that for you. They'll clone and compile packages, and leave the source afterward should you need to do it again, or if compilation fails for whatever reason.

Libvirt Hooks - Libvirt (see libvirt.org) is a virtualisation api that's very flexible and allows for KVM and other domain types. it primarily uses XML, rather than pure commandline switched like QEMU. Libvirt hooks are a system that allows for dynamic execution of a script or program at when a vm is started. more info in README.md

Wine - Wine  Is Not an Emulator. Wine allows you to run certain windows programs under Linux by translating windows calls to Linux ones. Wine is also used in Proton, which is Valve's extension of it, and in things like DXVK, which translates DirectX 9, 10, and 11 calls to Vulkan ones, and VKD3D, which translates DX12 calls to Vulkan ones.

CPU Pinning - CPU Pinning allows for core and thread isolation to ensure that cores/threads aree allocated solely to a VM and are commonly used with Libvirt Hooks in guides like these to increase guest CPU performance by decreasing latency.

Disk Tuning - Disk Tuning allows for more disk performance in the VM if used together with CPU Pinning by allowing cpu threads to be specifically dedicated to I/O operations.

/bin - /bin can be considered the PATH directory. any program or symlink placed in /bin allows that program to be executed from anywhere.

framebuffer - the framebuffer is where GPU frames sit before being bushed to the monitor. programs like looking glass can take advantage of this by pushinhg the framebuffer to RAM and allowing the host access to it.

parallel downloading - parallel downloading just means downloading mustiple things at the same time.

grub - grub is the default bootloader for most distros. typically the boot process for Linux look something like this: BIOS/UEFI -> grub -> Linux

nano - nano is a terminal based text editor. an alternative is vim

isolated groups - this just means that you have only one GPU (video AND audio interface) in an IOMMU groups

ACS Override Patch - if your groups are not isolated, you have to patch the kernel to manually isolate them.

virtIO bus - the virtIO bus is a virtual bus that allows
for better network, disk, and (if you require) display performance.
