# LAST_ZWOASICamera

LAST hardware driver for ZWO cameras. Tested with ASI_linux_mac_SDK_V1.14.1227, downloaded from
[ZWO site](https://astronomy-imaging-camera.com/software-drivers) , on Ubuntu 19.

## Installation of the SDK:

All is needed from the SDK package is:

1. the shared library file for the relevant platform (e.g. `ASI_linux_mac_SDK_V1.14.1227/lib/x64/libASICamera2.so.1.14.1227` for x64).

2. a (patched copy) of the header file, i.e. `ASI_linux_mac_SDK_V1.14.1227/include/ASICamera2.h`

In principle they can be copied anywhere the command `loadlibrary` in the instantiator method of the class can find them. The present writeup assumes they are copied into `+inst/@ZWOASICamera/lib`.

A symbolic link `libASICamera2.so` to the actual library file has also to be created in that directory. E.g.,
```
ln -s libASICamera2.so.1.14.1227 libASICamera2.so 
```
