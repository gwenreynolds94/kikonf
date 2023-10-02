; Debug.Debug.ahk

#Requires AutoHotkey v2.0

#Include Ext/jsongo.v2.ahk
(jsongo)

class Debug {
    static Call(_object) => Debug.View(jsongo.Stringify(_object,,4))
    static Msg(_object) => MsgBox(jsongo.Stringify(_object,,4))
    class View {
        static title := "ahk_exe dbgview64.exe"
        static isopen => WinExist(this.title)
        static Call(_message:="") {
            if !this.isopen
                Run("C:\Users\" A_UserName "\Portables\sysinternals\DebugView\dbgview64.exe")
            WinWait(this.title)
            WinActivate(this.title)
            OutputDebug _message
        }
    }
}

