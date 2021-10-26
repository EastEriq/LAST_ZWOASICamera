# LAST_ZWOASICamera

LAST hardware driver for ZWO cameras.

Tested with ASI_linux_mac_SDK_V1.14.1227 and ASI_linux_mac_SDK_V1.20.2, downloaded from
[ZWO site](https://astronomy-imaging-camera.com/software-drivers), on Ubuntu 18,
19 and 20, and an **ASI6200MM** and one **ASI174MM mini** camera.

# Installation and troubleshooting

Upon simple connection of the camera, even without installing software, `dmesg -wH` should show
something like
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

that alone may be not enough for the camera to work. Rule files in `/etc/udev/rules.d` are necessary for the camera to be connected. The procedure is described
in the file `README.txt` in the `/lib/` directory of the sdk package.

Installing
[ASIStudio](https://astronomy-imaging-camera.com/software/ASIStudio_V1.0.1.run) does it.
ASIStudio is convenient also as independent camera-control interface, just big (134MB, bundles several libraries for good). (**BEWARE** - the static libraries
included can conflict with the system ones. Take care to install ASIStudio
in a directory of its own; not in one which causes its subdirectory `lib/`
to be in `LD_CONFIG_PATH`. I.e., **do not install it** in `/usr/local`, to
prevent the static libraries to end up in `/usr/local/lib`. It happened to me,
and dbus is the first to fail - preventing the computer from booting.

The rule files which result from the installation of ASIStudio are `asi.rules`,
`eaf.rules`, `efw.rules`. Only
the first is the one relevant to the camera, the others are for other ZWO hardware. `asi.rules` spells:
```
ACTION=="add", ATTR{idVendor}=="03c3", RUN+="/bin/sh -c '/bin/echo 200 >/sys/mod
ule/usbcore/parameters/usbfs_memory_mb'"
# All ASI Cameras and filter wheels
SUBSYSTEMS=="usb", ATTR{idVendor}=="03c3", MODE="0666"
```

Note that if the rule is not in place, the matlab binding finds the camera, but is not able
to open it (`ASIOpenCamera()` returns `ASI_ERROR_CAMERA_CLOSED`), and that `ASIGetCameraProperty()` would return `IsUSB3Host: ASI_FALSE`.

# Specific experiences on the ASI6200MM

+ The cooler and the fan stop when `disconnect()` is called, i.e. when the class
  object is deleted. They also stop when the USB cable is pulled off.
+ However, most of the ASI functions don't return errors if the cable has been pulled,
  they just return the previous values. This is deceiving. And can hang
  `takeExposureSeq()`, even when the cable is attached back in.
  The safe action is `disconnect()`/`connect()`, but the loss of connection may
  pass undetected.
+ I've found from the forum an indirect way to determine if a previously connected
  camera is still there, which I've implemented in the hidden property `isConnected`
  (pending to be tested with multiple ZWO cameras). This could perused by a periodical
  watchdog.
+ A disconnection of the power supply turns off fan and cooler, but leaves the camera
  alive and connected, as long as the USB cable is in.
+ After changing `bitDepth` or `binning` (both involve calls to set ROI functions),
  the first image(s) taken may be empty, or it may take a longer time to retrieve
  images, or to set the camera in video mode.
+ `CamStatus` is "unknown" when the camera is operated in video mode and after it.
  For this reason `takeExposure` is allowed to start also when status is "unknown".
