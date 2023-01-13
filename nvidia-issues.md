### Fixes for NVIDIA drivers
While inconvenient, this is the only solution i found. i'm actively looking for a  better one. As mentioned in 2.0, the proprietary NVIDIA driver has issues being unbound on gpu passthrough systems and often end up crashing libvirt. to go around this, heres the solution i found. **If you want to test this out without hooks first, open up a tty shell and login as root.** if you dont use a tty shell, add the commands to a shell script in your vm's startup directory. in the tty, first kill the display manager with `systemctl stop display-manager`. next look for your gpu's PCI bus id. do this with `lspci -nnk | grep "NVIDIA"` you should get back something like this:

```
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU106 [GeForce RTX 2060 12GB] [10de:1f03] (rev a1)
01:00.1 Audio device [0403]: NVIDIA Corporation TU106 High Definition Audio Controller [10de:10f9] (rev a1)
```

paste the id of your video card into this command: `echo -n "01:00.0" > /sys/bus/pci/drivers/nvidia/unbind`. next, continue as usual unbinding all the modules that are typically in use. once done, start the display manager again with `systemctl start display manager`, log in, and start the VM. should work now. i recommend adding this line to your vm startup script. this is a short cheap fix, but ill make a better explanation when i have some more time. 

#### (script)

```
!#bin/bash

## load config


## kill dm
systemctl stop display-manager

## unbind nvidia driver
echo -n "01:00.0" > /sys/bus/pci/drivers/nvidia/unbind

## remove modules
rmmod nvidia
rmmod nvidia_modeset
rmmod nvidia_drm
rmmod nvidia_uvm
rmmod i2c_nvidia_gpu

## unbind device with virsh
virsh nodedev-detach $VIRSH_GPU_VIDEO
