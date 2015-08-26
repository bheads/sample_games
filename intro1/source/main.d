module main;

/++
    App init logic for windows and beyond
 +/
version(Windows) {
    import core.runtime : Runtime;
    import std.string : toStringz;
    import core.sys.windows.windows;
    

    enum dllRootPath = `..\dlls\`;
    extern(Windows) export BOOL SetDllDirectoryA(LPCSTR) nothrow @nogc @trusted;
    

    extern(Windows)
    int WinMain(HINSTANCE hInstance, HINSTANCE pPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
        int result;
        try {
            Runtime.initialize();
            scope(exit) Runtime.terminate();
            
            version(Win32) SetDllDirectoryA((dllRootPath ~ `x32`).ptr);
            version(Win64) SetDllDirectoryA((dllRootPath ~ `x64`).ptr);

            result = run(Runtime.args); // todo: get the args
        } catch(Exception e) {
            import std.stdio;
            writeln("Error: ", e.toString);
            MessageBoxA(null, e.toString().toStringz, "Error", MB_OK | MB_ICONEXCLAMATION);
            result = -1;
        }    

        return result;
    }

} else {
    /**
     * Non-windows happy fun time
     */
    int main(string[] args) {
        int result;
        assert(false, "Test on linux!");


        try {
            result = run(args);
        } catch(Throwable e) {
            import std.stdio;

            writeln("Error: ", e.toString);
            result = -1;
        }
        return result;
    }
}



int run(string[] args) {
    throw new Exception("A");
    //return 0;
}