module ahki.main;

private import std.exception : enforce;
import std.stdio;
import ahki.loop;

/++
    App init logic for windows and better
 +/
version(Windows) {
    import core.runtime : Runtime;
    import std.string : toStringz;
    import std.format : format;
    import core.sys.windows.windows;
    
    extern(Windows) export BOOL SetDllDirectoryA(LPCSTR) nothrow @nogc @trusted;   

    extern(Windows)
    int WinMain(HINSTANCE hInstance, HINSTANCE pPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
        int result;
        try {
            Runtime.initialize();

            version(Win32) enum dllPath = `..\dlls\x32`;
            version(Win64) enum dllPath = `..\dlls\x64`;
            // Add the path to the dll folder to the windows DLL search path
            enforce(SetDllDirectoryA(dllPath.ptr) != 0, format("Failed to set the DLL search path: %d", GetLastError()));
            
            result = start(Runtime.args);
        } catch(Throwable e) {
            auto msg = format("Uncaught exception %s", e.toString);
            debug writeln(msg);
            MessageBoxA(null, msg.toStringz, "Error", MB_OK | MB_ICONEXCLAMATION);
            result = -1;
        } finally {
            // make sure we always shutdown
            Runtime.terminate();
        }   

        return result;
    }

} else {
    /**
     * Non-windows happy fun time
     */
    int main(string[] args) {
        int result;

        try {
            result = start(args);
        } catch(Throwable e) {
            writeln(format("Uncaught exception %s", e.toString));
            result = -1;
        }
        return result;
    }
}
