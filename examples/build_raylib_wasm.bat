set EMCC_PATH=F:\Dev\_frameworks\emsdk
SET EMSDK_CMD=1
call %EMCC_PATH%\emsdk_env
call emcc example_raylib_wasm.c zig-out/lib/libeditor_raylib_wasm.a -Lraylib/wasm -lraylib -s USE_GLFW=3 -s ASYNCIFY -o zig-out/www/example_raylib.html --preload-file monofonto.otf
echo compile success