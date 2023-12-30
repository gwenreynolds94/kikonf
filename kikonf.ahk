; kikonf.ahk

#Requires AutoHotkey v2+
#Warn All, StdOut
#SingleInstance Force

TraySetIcon(A_ScriptDir "\deart.ico")

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
#Include <Ducky>
#Include <Vieb>
#Include <Creds>

kfg := Config(A_AppData "\kikonf\.ahkonf", Map(
    "PCNames", Map(
        "DeskMain", "DESKTOP-HQ7DNU5",
        "LapMain" , "DESKTOP-JJTV8BS",
    ),
    "PCAddr", Map(
        "DeskMain", "192.168.1.2",
        "LapMain" , "192.168.1.3",
    ),
))

Class AllKi {
    Static _enabled := false
    Static __New() {

    }
    Static Enabled {
        get => this._enabled
        set => !!Value ? this.Enable() : this.Disable()
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

Creds.RunAsUser()
Hotkey "sc029 & r", (*)=>Creds.ToggleRunAs()
Hotkey "#^+r", (*)=>Creds.RegisterUser()

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
Hotkey "sc029 & e", (*)=>Run("rundll32.exe sysdm.cpl,EditEnvironmentVariables")
Hotkey "sc029 & d", (*)=>Run("rundll32.exe shell32.dll,Control_RunDLL access.cpl,,3")
Hotkey "sc029 & g", _G.cbToggle("gamemode")
Hotkey "<#<!g", _G.cbToggle("gamemode")
Hotkey "sc029 & s", Ducky.SearchFromClipboard
; Hotkey "sc029 & o", (*)=>Run('"C:\Program Files\Opera GX\launcher.exe"')
; --side-profile-name=32343339325F363132343930333239 --side-profile-minimal
; --with-feature:side-profiles --no-default-browser-check --disable-usage-statistics-question')
Hotkey "sc029 & o", (*)=>Run(_G.browser)
Hotkey "sc029 & 1", WinVis.PrevStepActive
Hotkey "sc029 & 2", WinVis.NextStepActive
Hotkey "sc029 & v", Vieb.SaveBufferListFromFirstVieb
Hotkey "sc029 & q", _G.cbToggle("quikclip")
Hotkey "<!<#c", _G.cbToggle("quikclip")

RegisterDblClick(_key, _dblclick_action, _timeout_action, _timeout:=200, _hotif:=false, *) {
    static registered := Map()
    if registered.Has(_key) and registered[_key].hotif = _hotif
        throw ValueError( "There is already a dblclick hotkey "
                        . "registered for the key {" _key "} "
                        . "using the given hotif" )
    registered[_key] := { key: _key
                        , timeout: _timeout
                        , hotif: _hotif
                        , dblclick_action: _dblclick_action
                        , timeout_action: _timeout_action
                        , trigger_count: 0
                        , timeout_check: OnKeyTimeout.Bind(&registered, _key)
    }
    OnKeyTimeout(&_registered, _key, *) {
        reginfo := _registered[_key]
        SetTimer(reginfo.timeout_check, 0)
        if reginfo.trigger_count = 1
            reginfo.timeout_action()
        reginfo.trigger_count := 0
    }
    OnKeyPress(&_registered, _key, *) {
        reginfo := _registered[_key]
        is_dblclick := (++reginfo.trigger_count > 1)
        if is_dblclick {
            reginfo.trigger_count := 0
            SetTimer(reginfo.timeout_check, 0)
            reginfo.dblclick_action()
            return
        }
        KeyWait(_key)
        SetTimer( reginfo.timeout_check
                , Abs(reginfo.timeout) * -1 )
    }
    if _hotif
        HotIf _hotif
    Hotkey _key, OnKeyPress.bind(&registered, _key)
    if _hotif
        HotIf
}

RegisterDblClick( "XButton1"
                , (*)=>Send("{Ctrl Down}c{Ctrl Up}")
                , (*)=>Send("{Click X1}")
               ,, _G.hotifs["quikclip_active"] )
RegisterDblClick( "XButton2"
                , (*)=>Send("{Ctrl Down}x{Ctrl Up}")
                , (*)=>Send("{Click X2}")
               ,, _G.hotifs["quikclip_active"] )
HotIf _G.hotifs["quikclip_active"]
Hotkey "XButton1 & MButton", (*)=>Send("{Ctrl Down}v{Ctrl Up}")
HotIf

/**
HotIfStartCorner := HotList(true, ((*)=>(MouseGetPos(&_x,&_y), ((_x+_y) < 12) )))
HotIf HotIfStartCorner
Hotkey "WheelDown", WinVis.PrevStepActive
Hotkey "WheelUp", WinVis.NextStepActive
HotIf
*/
HotIf _G.hotifs["wezterm_winactive"]
Hotkey "LAlt & Space", (*)=>(Send("{F13}")), "On"
HotIf

Hotkey "<+#a", (*)=>WinSetAlwaysOnTop(-1, winexist("A"))

VolScroll.Enable()

