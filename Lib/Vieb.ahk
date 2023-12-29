; Vieb.ahk

#Requires AutoHotkey v2+

#SingleInstance Force

class Vieb {
    static CopyBufferListFromFirstVieb := ObjBindMethod(Vieb, "__CopyBufferListFromVieb", "")
        ,  SaveBufferListFromFirstVieb := ObjBindMethod(Vieb, "__SaveBufferListFromVieb", "")
        ,  savedBuffersDir := "C:\Users\" A_UserName "\.vieb\.savedbuffers"
    static __New() {
        if (!DirExist(Vieb.savedBuffersDir))
            DirCreate(Vieb.savedBuffersDir)
    }
    static __CopyBufferListFromVieb(_wintitle, *) {
        initialWindow := WinExist("A")
        firstFoundExe := "Vieb.exe"
        firstFound := WinExist(_wintitle or "ahk_exe Vieb.exe") or
                      WinExist("Vieb ahk_exe" (firstFoundExe:="electron.exe"))
        if not firstFound
            return
        WinActivate
        ControlSend "{Escape 2}{Shift Down}{;}{Shift Up}buffers{Enter}"
        if (not WinWait("Notification ahk_exe" firstFoundExe,, 5))
            return
        WinActivate
        WinWaitActive
        ControlSend "{Ctrl Down}ac{Ctrl Up}q"
        WinActivate(initialWindow)
        return A_Clipboard
    }
    static __SaveBufferListFromVieb(_wintitle, *) {
        preClipboard := A_Clipboard
        buffersText := Vieb.__CopyBufferListFromVieb(_wintitle)
        if not buffersText
            return
        bufferLinksText := ""
        for bufText in StrSplit(buffersText, "`n")
            if (bufLink := StrSplit(bufText, ":", A_Space, 2)[2])
                bufferLinksText .= bufLink "`n"
        A_Clipboard := preClipboard
        newFileName := FormatTime(,"yyMMdd.HHmm.ss") ".txt"
        FileAppend bufferLinksText, Vieb.savedBuffersDir "\" newFileName, "`n UTF-8"
    }
}
