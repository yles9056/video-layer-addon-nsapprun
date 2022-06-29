cmd_Release/obj.target/addon/addon.o := c++ -o Release/obj.target/addon/addon.o ../addon.cpp '-DNODE_GYP_MODULE_NAME=addon' '-DUSING_UV_SHARED=1' '-DUSING_V8_SHARED=1' '-DV8_DEPRECATION_WARNINGS=1' '-DV8_DEPRECATION_WARNINGS' '-DV8_IMMINENT_DEPRECATION_WARNINGS' '-D_GLIBCXX_USE_CXX11_ABI=1' '-D_DARWIN_USE_64_BIT_INODE=1' '-D_LARGEFILE_SOURCE' '-D_FILE_OFFSET_BITS=64' '-DV8_COMPRESS_POINTERS' '-DV8_COMPRESS_POINTERS_IN_ISOLATE_CAGE' '-DV8_31BIT_SMIS_ON_64BIT_ARCH' '-DV8_REVERSE_JSARGS' '-DOPENSSL_NO_PINSHARED' '-DOPENSSL_THREADS' '-DOPENSSL_NO_ASM' '-DNAPI_DISABLE_CPP_EXCEPTIONS' '-DBUILDING_NODE_EXTENSION' -I/Users/user/.electron-gyp/17.1.0/include/node -I/Users/user/.electron-gyp/17.1.0/src -I/Users/user/.electron-gyp/17.1.0/deps/openssl/config -I/Users/user/.electron-gyp/17.1.0/deps/openssl/openssl/include -I/Users/user/.electron-gyp/17.1.0/deps/uv/include -I/Users/user/.electron-gyp/17.1.0/deps/zlib -I/Users/user/.electron-gyp/17.1.0/deps/v8/include -I/usr/local/include -I../node_modules/nan -I/Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api  -O3 -gdwarf-2 -mmacosx-version-min=10.15 -arch x86_64 -Wall -Wendif-labels -W -Wno-unused-parameter -std=gnu++14 -stdlib=libc++ -ObjC++ -std=c++14 -stdlib=libc++ -v -arch x86_64 -arch arm64 -MMD -MF ./Release/.deps/Release/obj.target/addon/addon.o.d.raw   -c
Release/obj.target/addon/addon.o: ../addon.cpp \
  /Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api/napi.h \
  /Users/user/.electron-gyp/17.1.0/include/node/node_api.h \
  /Users/user/.electron-gyp/17.1.0/include/node/js_native_api.h \
  /Users/user/.electron-gyp/17.1.0/include/node/js_native_api_types.h \
  /Users/user/.electron-gyp/17.1.0/include/node/node_api_types.h \
  /Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api/napi-inl.h \
  /Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api/napi-inl.deprecated.h \
  /Users/user/.electron-gyp/17.1.0/include/node/node.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8.h \
  /Users/user/.electron-gyp/17.1.0/include/node/cppgc/common.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8config.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-array-buffer.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-local-handle.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-internal.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-version.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-object.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-maybe.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-persistent-handle.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-weak-callback-info.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-primitive.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-data.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-value.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-traced-handle.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-container.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-context.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-snapshot.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-date.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-debug.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-exception.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-extension.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-external.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-function.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-function-callback.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-message.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-template.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-memory-span.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-initialization.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-isolate.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-callbacks.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-embedder-heap.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-microtask.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-statistics.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-promise.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-unwinder.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-embedder-state-scope.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-platform.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-json.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-locker.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-microtask-queue.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-primitive-object.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-proxy.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-regexp.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-script.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-typed-array.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-value-serializer.h \
  /Users/user/.electron-gyp/17.1.0/include/node/v8-wasm.h \
  /Users/user/.electron-gyp/17.1.0/include/node/node_version.h \
  ../renderer_app.h ../remote_layer_api.h
../addon.cpp:
/Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api/napi.h:
/Users/user/.electron-gyp/17.1.0/include/node/node_api.h:
/Users/user/.electron-gyp/17.1.0/include/node/js_native_api.h:
/Users/user/.electron-gyp/17.1.0/include/node/js_native_api_types.h:
/Users/user/.electron-gyp/17.1.0/include/node/node_api_types.h:
/Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api/napi-inl.h:
/Users/user/Desktop/video-layer-addon/addons/node_modules/node-addon-api/napi-inl.deprecated.h:
/Users/user/.electron-gyp/17.1.0/include/node/node.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8.h:
/Users/user/.electron-gyp/17.1.0/include/node/cppgc/common.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8config.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-array-buffer.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-local-handle.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-internal.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-version.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-object.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-maybe.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-persistent-handle.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-weak-callback-info.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-primitive.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-data.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-value.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-traced-handle.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-container.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-context.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-snapshot.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-date.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-debug.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-exception.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-extension.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-external.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-function.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-function-callback.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-message.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-template.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-memory-span.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-initialization.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-isolate.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-callbacks.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-embedder-heap.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-microtask.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-statistics.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-promise.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-unwinder.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-embedder-state-scope.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-platform.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-json.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-locker.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-microtask-queue.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-primitive-object.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-proxy.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-regexp.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-script.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-typed-array.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-value-serializer.h:
/Users/user/.electron-gyp/17.1.0/include/node/v8-wasm.h:
/Users/user/.electron-gyp/17.1.0/include/node/node_version.h:
../renderer_app.h:
../remote_layer_api.h:
