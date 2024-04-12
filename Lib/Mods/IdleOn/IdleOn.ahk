
; Mods.IdleOn.ahk

#Requires AutoHotkey v2+
#SingleInstance Force

class IdleOn {
    static HWND := 0x00000
         , Exe := "LegendsOfIdleon.exe"
    static __New() {

    }
    static SyncWindow(*) {
        if WinExist(this)
            return true
        this.HWND := WinExist("ahk_exe" this.Exe)
    }
    class Minigame {

    }
}

