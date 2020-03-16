# LAST_ZWOASICamera

LAST hardware driver for ZWO cameras. Tested with ASI_linux_mac_SDK_V1.14.1227, downloaded from
[ZWO site](https://astronomy-imaging-camera.com/software-drivers) , on Ubuntu 19.

# Installation and troubleshooting

Upon simple connection of the camera, even without installing software, `dmesg` should show something like

```
[  +9.144051] usb 1-2: new high-speed USB device number 15 using xhci_hcd
[  +0.149413] usb 1-2: New USB device found, idVendor=04b4, idProduct=6572
[  +0.000002] usb 1-2: New USB device strings: Mfr=0, Product=1, SerialNumber=0
[  +0.000001] usb 1-2: Product: USB2.0 Hub
[  +0.000782] hub 1-2:1.0: USB hub found
[  +0.000321] hub 1-2:1.0: 4 ports detected
[  +1.965565] usb 2-2: new SuperSpeed USB device number 7 using xhci_hcd
[  +0.024923] usb 2-2: New USB device found, idVendor=03c3, idProduct=620b
[  +0.000002] usb 2-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[  +0.000002] usb 2-2: Product: ASI6200MM Pro
[  +0.000001] usb 2-2: Manufacturer: ZWO
```

(the ASI6200MM has both an USB3 camera connection and an USB2 hub).


## Installation of the SDK:

All is needed from the SDK package is:

1. the shared library file for the relevant platform (e.g. `ASI_linux_mac_SDK_V1.14.1227/lib/x64/libASICamera2.so.1.14.1227` for x64).

2. a (patched copy) of the header file, i.e. `ASI_linux_mac_SDK_V1.14.1227/include/ASICamera2.h`

In principle they can be copied anywhere the command `loadlibrary` in the instantiator method of the class can find them. The present writeup assumes they are copied into `+inst/@ZWOASICamera/lib`.

+ A symbolic link `libASICamera2.so` to the actual library file has also to be created in that directory. E.g.,
```
ln -s libASICamera2.so.1.14.1227 libASICamera2.so
```

### however,

that alone may be not enough for the camera to work. Rule files in `/etc/udev/rules.d` are probably necessary for the camera to be connected. Installing
(ASIStudio)[https://astronomy-imaging-camera.com/software/ASIStudio_V1.0.1.run] does it.
ASIStudio is convenient also as independent camera-control interface, just big (134MB, bundles several libraries for good).

The rule files which result are `asi.rules`, `eaf.rules`, `efw.rules`. I guess that only
the first is the one relevant to the camera, the others are for other ZWO hardware. `asi.rules` spells:
```
ACTION=="add", ATTR{idVendor}=="03c3", RUN+="/bin/sh -c '/bin/echo 200 >/sys/mod
ule/usbcore/parameters/usbfs_memory_mb'"
# All ASI Cameras and filter wheels
SUBSYSTEMS=="usb", ATTR{idVendor}=="03c3", MODE="0666" 
```

Note that if the rule is not in place, the matlab binding finds the camera, but is not able
to open it (`ASIOpenCamera()` returns `ASI_ERROR_CAMERA_CLOSED`), and that `ASIGetCameraProperty()` would return `IsUSB3Host: ASI_FALSE`.