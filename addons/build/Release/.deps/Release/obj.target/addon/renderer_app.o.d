cmd_Release/obj.target/addon/renderer_app.o := c++ '-DNODE_GYP_MODULE_NAME=addon' '-DUSING_UV_SHARED=1' '-DUSING_V8_SHARED=1' '-DV8_DEPRECATION_WARNINGS=1' '-DV8_DEPRECATION_WARNINGS' '-DV8_IMMINENT_DEPRECATION_WARNINGS' '-D_GLIBCXX_USE_CXX11_ABI=1' '-D_DARWIN_USE_64_BIT_INODE=1' '-D_LARGEFILE_SOURCE' '-D_FILE_OFFSET_BITS=64' '-DV8_COMPRESS_POINTERS' '-DV8_COMPRESS_POINTERS_IN_ISOLATE_CAGE' '-DV8_31BIT_SMIS_ON_64BIT_ARCH' '-DV8_REVERSE_JSARGS' '-DOPENSSL_NO_PINSHARED' '-DOPENSSL_THREADS' '-DOPENSSL_NO_ASM' '-DNAPI_DISABLE_CPP_EXCEPTIONS' '-DBUILDING_NODE_EXTENSION' -I/Users/user/.electron-gyp/17.1.0/include/node -I/Users/user/.electron-gyp/17.1.0/src -I/Users/user/.electron-gyp/17.1.0/deps/openssl/config -I/Users/user/.electron-gyp/17.1.0/deps/openssl/openssl/include -I/Users/user/.electron-gyp/17.1.0/deps/uv/include -I/Users/user/.electron-gyp/17.1.0/deps/zlib -I/Users/user/.electron-gyp/17.1.0/deps/v8/include -I/usr/local/include -I../node_modules/nan -I/Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api  -O3 -gdwarf-2 -mmacosx-version-min=10.15 -arch x86_64 -Wall -Wendif-labels -W -Wno-unused-parameter -std=gnu++14 -stdlib=libc++ -ObjC++ -std=c++14 -stdlib=libc++ -v -arch x86_64 -arch arm64  -MMD -MF ./Release/.deps/Release/obj.target/addon/renderer_app.o.d.raw -c -o Release/obj.target/addon/renderer_app.o ../renderer_app.mm
Release/obj.target/addon/renderer_app.o: ../renderer_app.mm \
  ../renderer_app.h ../remote_layer_api.h
../renderer_app.mm:
../renderer_app.h:
../remote_layer_api.h: