{
    "targets": [
        {
            "target_name": "videoLayerLibV2",
            
            "sources": ["addon.cpp", "addon_osx.mm"],
            "include_dirs": [
                "/usr/local/include",
                "<!(node -e \"require('nan')\")",
                "<!@(node -p \"require('node-addon-api').include\")"
                ],
            'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ],
            "cflags!": ["-fno-exceptions"],
            "cflags_cc!": ["-fno-rtti", "-fno-exceptions"],
            "xcode_settings": {
                "OTHER_CPLUSPLUSFLAGS" : ['-ObjC++',"-std=c++14","-stdlib=libc++", "-v",  "-arch x86_64", "-arch arm64"],
                "OTHER_LDFLAGS": ["-stdlib=libc++", "-arch x86_64", "-arch arm64"],
                "MACOSX_DEPLOYMENT_TARGET": "10.15",
                "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
                "GCC_ENABLE_CPP_RTTI": "YES"
            }
        }
    ]
}
