cmd_Release/UVCCamCtrl.node := c++ -bundle -stdlib=libc++ -arch x86_64 -arch arm64 -undefined dynamic_lookup -Wl,-search_paths_first -mmacosx-version-min=10.11 -arch x86_64 -L./Release -stdlib=libc++  -o Release/UVCCamCtrl.node Release/obj.target/UVCCamCtrl/uvcCamCtrl_mac.o Release/obj.target/UVCCamCtrl/uvcCamCtrl.o Release/obj.target/UVCCamCtrl/iSerialNum.o Release/obj.target/UVCCamCtrl/avCtrl_mac.o 
