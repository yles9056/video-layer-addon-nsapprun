{
    "targets": [
        {
            "target_name": "VideoLayerLibV2",
            "cflags!": ["-fno-exceptions"],
            "cflags_cc!": ["-fno-exceptions"],
            "sources": ["Client.m", "async.mm", "addon.cpp", "addon_osx.mm"],
            "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
            "defines": ["NAPI_DISABLE_CPP_EXCEPTIONS"],
            "xcode_settings": {
                "OTHER_CPLUSPLUSFLAGS" : ['-ObjC++',"-std=c++14","-stdlib=libc++", "-v"],
                "OTHER_LDFLAGS": ["-stdlib=libc++"],
                "MACOSX_DEPLOYMENT_TARGET": "12.1",
                "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
                "GCC_ENABLE_CPP_RTTI": "YES"
            }
        }
    ]
}
