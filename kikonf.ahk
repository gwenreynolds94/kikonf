; kikonf.ahk

#Requires AutoHotkey v2+
#Warn All, StdOut
#SingleInstance Force

#Include <Globals>
#Include <Debug>
#Include <FS>
#Include <WinVis>
#Include <VolScroll>
#Include <QuikTool>
#Include <HotList>
#Include <Config>
#Include <Crosshair>
#Include <Builtins\All>

kfg := Config(A_AppData "\kikonf\.ahkonf", Map(
    "PCNames", Map(
        "DeskMain", "DESKTOP-HQ7DNU5",
        "LapMain" , "DESKTOP-JJTV8BS",
    ),
    "PCAddr", Map(
        "DeskMain", "192.168.1.4",
        "LapMain" , "192.168.1.3",
    ),
))

Class AllKi {
    Static _enabled := false
    Static __New() {

    }
    Static Enabled {
        Get => this._enabled
        Set => !!Value ? this.Enable() : this.Disable()
    }
    Static Enable(*) {
        if !!this.Enabled
            return
        this._enabled := true
    }
    Static Disable(*) {
        if !this.Enabled
            return
        this._enabled := false
    }
}

PinkHair := Crosshair("6f", "dd9fbf")
Hotkey "#c", PinkHair.bmtoggle
Hotkey "<^#c", PinkHair.bmdecsize
Hotkey "<!#c", PinkHair.bmincsize
Hotkey ">!#c", PinkHair.bmdectrans
Hotkey ">^#c", PinkHair.bminctrans

Hotkey "$sc029", (*)=>Send("{sc029}")
Hotkey "+sc029", (*)=>Send("{~}")
Hotkey "sc029 & F4", (*)=>ExitApp()
Hotkey "sc029 & F5", (*)=>Reload()
Hotkey "sc029 & h", (*)=>KeyHistory()
Hotkey "sc029 & w", (*)=>Run("wezterm-gui.exe")
Hotkey "sc029 & f", (*)=>Run("firefox.exe")
Hotkey "sc029 & a", (*)=>Run("*RunAs hh.exe `"C:\Program Files\AutoHotkey\v2\AutoHotkey.chm`"")
Hotkey "sc029 & g", _G.cbToggle("gamemode")
; Hotkey "sc029 & o", (*)=>Run('"C:\Program Files\Opera GX\launcher.exe"') 
; --side-profile-name=32343339325F363132343930333239 --side-profile-minimal 
; --with-feature:side-profiles --no-default-browser-check --disable-usage-statistics-question')
Hotkey "sc029 & o", (*)=>Run(_G.browser)
Hotkey "sc029 & v", (*)=>MsgBox(A_AhkVersion)
Hotkey "sc029 & 1", WinVis.PrevStepActive
Hotkey "sc029 & 2", WinVis.NextStepActive
/**
HotIfStartCorner := HotList(true, ((*)=>(MouseGetPos(&_x,&_y), ((_x+_y) < 12) )))
HotIf HotIfStartCorner
Hotkey "WheelDown", WinVis.PrevStepActive
Hotkey "WheelUp", WinVis.NextStepActive
HotIf
*/
HotIfWez := HotList(true, "wezterm-gui.exe")
HotIf HotIfWez
Hotkey "LAlt & Space", (*)=>(Send("{F13}")), "On"
HotIf

Hotkey "<+#a", (*)=>WinSetAlwaysOnTop(-1, winexist("A"))

VolScroll.Enable()

