# LAST_ZWO_ASICamera

LAST hardware driver for ZWO cameras. Tested with ASI_linux_mac_SDK_V1.14.1227, downloaded from
https://astronomy-imaging-camera.com/software-drivers , on Ubuntu 19.

## Installation of the SDK:

All is needed are the two files `ASI_linux_mac_SDK_V1.14.1227/include/ASICamera2.h` and
the shared library for the relevant platform (e.g. `ASI_linux_mac_SDK_V1.14.1227/lib/x64/libASICamera2.so.1.14.1227`
for x64). They can be copied anywhere the command `loadlibrary` in the instantiator method of the class can find them.
A symbolic link `libASICamera2.so -> libASICamera2.so.1.14.1227` has to be created. The present writeup assumes they are copied into `@ZWO_ASICamera @ZWO_ASICamera/lib`.
