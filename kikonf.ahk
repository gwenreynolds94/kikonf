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
#Include <Ducky>
#Include <Vieb>
#Include <Creds>
#Include <ResMod>

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
Hotkey "sc029 & f", (*)=>Run("`"C:\Program Files\Ablaze Floorp\floorp.exe`"")
Hotkey "sc029 & a", (*)=>Run("hh.exe `"C:\Program Files\AutoHotkey\v2\AutoHotkey.chm`"")
Hotkey "sc029 & e", (*)=>Run("rundll32.exe sysdm.cpl,EditEnvironmentVariables")
Hotkey "sc029 & d", (*)=>Run("rundll32.exe shell32.dll,Control_RunDLL access.cpl,,3")
Hotkey "sc029 & g", _G.cbToggle("gamemode")
Hotkey "<#<!g", _G.cbToggle("gamemode")
Hotkey "sc029 & s", Ducky.SearchFromClipboard
; Hotkey "sc029 & o", (*)=>Run('"C:\Program Files\Opera GX\launcher.exe"')
; --side-profile-name=32343339325F363132343930333239 --side-profile-minimal
; --with-feature:side-profiles --no-default-browser-check --disable-usage-statistics-question')
Hotkey "sc029 & o", (*)=>Run("niebo.cmd base")
Hotkey "sc029 & 1", WinVis.PrevStepActive
Hotkey "sc029 & 2", WinVis.NextStepActive
Hotkey "sc029 & v", Vieb.SaveBufferListFromFirstVieb
Hotkey "sc029 & m", (*)=>Run("`"C:\Program Files\VideoLAN\VLC\vlc.exe`"")
Hotkey "sc029 & c", (*)=>Run("wt")
Hotkey "sc029 & n", (*)=>(WinExist("ahk_exe vlc.exe") and WinClose("ahk_exe vlc.exe"),WinWaitClose(),Run("`"C:\Program Files\VideoLAN\VLC\vlc.exe`""))
Hotkey "sc029 & q", _G.cbToggle("quikclip")
Hotkey "sc029 & l", (*)=>Run("logseq.exe")
Hotkey "<!<#c", _G.cbToggle("quikclip")
Hotkey "#z", ResMod.cbToggleActiveDisplayZoom(1280, 720)
Hotkey "#u", ResMod.cbUpdateRefreshRate(,165)

; hotkey ">!AppsKey", dothingasd.Bind()
dothingasd(*){
  loop 10
    slpdur := 500
  , Send("{Down}")
  , Sleep(slpdur)
  , Send("{Down}")
  , Sleep(slpdur)
  , Send("{Enter}")
  , Sleep(slpdur)
  , Send("{Tab}")
  , Sleep(slpdur)
  , Send("{Tab}")
}

HotIf (*)=>(FileExist(_G.nieb_start))
Hotkey "!#p", (*)=>Run("cmd.exe /c " _G.nieb_start " pp")
HotIf
HotIfWinActive "ahk_exe floorp.exe"
Hotkey "Insert", (*)=>ToggleAutoWheel()
HotIfWinActive

Hotkey "<^<#f", FreyrCopy.cbToggle

Hotkey "<^<#x", QuikClik.cbToggle


class AutoTrap {
    static enabled := false
         , cbToggle := ObjBindMethod(AutoTrap, "Toggle")
    static Enable(*) {
    }
    static Disable(*) {
    }
    static Toggle(*) {
    }
}

/*
Hotkey "<^<#a", AutoChop.cbToggle
class AutoChop {
    static enabled := false
         , inactive_ms := 75
         , last_clicked := 0
         , cbToggle := ObjBindMethod(AutoChop, "Toggle")
         , cbCheckGreen := ObjBindMethod(AutoChop, "CheckGreen")
         , cbStartCheckGreen := ObjBindMethod(AutoChop, "StartCheckGreen")
         , cbStopCheckGreen := ObjBindMethod(AutoChop, "StopCheckGreen")
    static CheckGreen(*) =>
        ((Abs((CoordMode("mouse", "screen"), MouseGetPos(&_mx, &_my), GDIPixelSearch(_mx, _my)).g - 236)) < 3) and (Click(), AutoChop.last_clicked := A_TickCount)
    ; static CheckGreen(*) {
        ; mcolor_green := Number("0x" SubStr(PixelGetColor(_mx,_my), 6, 2))
        ; mcolor_blue := Number("0x" SubStr(mcolor, 4, 2))
        ; if mcolor_blue < 190 and mcolor_blue > 120 and mcolor_green > 211
        ;    Tooltip mcolor_green "." mcolor_blue
        ; if Abs(Number("0x" SubStr((MouseGetPos(&_mx, &_my), PixelGetColor(_mx,_my)), 6, 2)) - 227) < 3
            ; Click
    ; }
    static StartCheckGreen(*) {
        SetTimer(AutoChop.cbCheckGreen, 1)
    }
    static StopCheckGreen(*) {
        SetTimer(AutoChop.cbCheckGreen, 0)
    }
    static Enable(*) {
        if !!(AutoChop.enabled)
            return
        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"
        ; SetTimer(AutoChop.cbCheckGreen, 1)
        Tooltip "AutoChop: true"
        SetTimer((*)=>ToolTip(), -2000)
        AutoChop.enabled := true
        Loop {
            if !(AutoChop.enabled)
                break
            this_tick := A_TickCount
            if (this_tick - AutoChop.last_clicked) > AutoChop.inactive_ms
                AutoChop.CheckGreen
        }
    }
    static Disable(*) {
        Tooltip "AutoChop: false"
        SetTimer((*)=>ToolTip(), -2000)
        if !(AutoChop.enabled)
            return
        ; SetTimer(AutoChop.cbCheckGreen, 0)
        AutoChop.enabled := false
    }
    static Toggle(*) {
        if !(AutoChop.enabled)
            AutoChop.Enable()
        else AutoChop.Disable()
    }
}
*/

class QuikClik {
    static running := false
         , click_interval := 10
         , cbSendClick := ObjBindMethod(QuikClik, "SendClick")
         , cbToggle := ObjBindMethod(QuikClik, "Toggle")
         , click_count := 0
    static SendClick(*) {
        Click
        QuikClik.click_count++
        ToolTip QuikClik.click_count
    }
    static Enable(*) {
        if !!(QuikClik.running)
            return
        SetTimer QuikClik.cbSendClick, QuikClik.click_interval
        QuikClik.running := true
    }
    static Disable(*) {
        if !(QuikClik.running)
            return
        SetTimer QuikClik.cbSendClick, 0
        QuikClik.running := false
        QuikClik.click_count := 0
        ToolTip
    }
    static Toggle(*) {
        if !(QuikClik.running)
            QuikClik.Enable()
        else QuikClik.Disable()
    }
}

class FreyrCopy {
    static cbClipChange := ObjBindMethod(FreyrCopy, "OnClipChange")
         , cbToggle := ObjBindMethod(FreyrCopy, "Toggle")
    static OnClipChange(_datatype, *) {
        if _datatype = 1 and (clipb:=A_Clipboard) ~= "^https://music\.apple\.com/.+" {
            Tooltip clipb
            SetTimer ((*)=>Tooltip()), -1250
            if WinExist("ahk_exe WindowsTerminal.exe") {
                WinActivate()
                WinWaitActive()
                BlockInput true
                Send "cd $HOME\Music\freyr"
                Sleep 20
                Send "{Enter}"
                Sleep 500
                Send "freyr "
                Sleep 20
                Send "{Ctrl Down}v{Ctrl Up}"
                Sleep 20
                Send "{Enter}"
                BlockInput false
            }
        }
    }
    static Enable(*) {
        if !!(_G.freyr_copy)
            return
        OnClipboardChange FreyrCopy.cbClipChange
        Tooltip "FreyrCopy:True"
        SetTimer ((*)=>Tooltip()), -1250
        _G.freyr_copy := true
    }
    static Disable(*) {
        if !(_G.freyr_copy)
            return
        OnClipboardChange FreyrCopy.cbClipChange, 0
        Tooltip "FreyrCopy:False"
        SetTimer ((*)=>Tooltip()), -1250
        _G.freyr_copy := false
    }
    static Toggle(*) {
        if !!(_G.freyr_copy)
            FreyrCopy.Disable()
        else FreyrCopy.Enable()
    }
}

ToggleAutoWheel(_wheeldir:="Down", *) {
    static _autowheel_enabled := false
         , _previous_wheeldir := false
         , _autowheel := (_dir, *)=>(WinActive("ahk_exe floorp.exe") and Send("{Wheel" _dir "}"))
         , _cb_autowheel := false
         , _autowheel_interval := 2000
         , _autowheel_interval_min := 500
         , _autowheel_interval_delta := 250
         , _autowheel_tooltip_off := (*)=>ToolTip()
         , _autowheel_tooltip_msg := (_msg, *)=>(Tooltip("AutoWheel: " _msg), SetTimer(_autowheel_tooltip_off, -1250))
         , _autowheel_hotif := (*)=>WinActive("ahk_exe floorp.exe")
    _wheeldir := (_wheeldir ~= "i)up?") ? "Up" : "Down"
    _autowheel_enabled := (_wheeldir != _previous_wheeldir) ? true : !_autowheel_enabled
    _previous_wheeldir := _wheeldir
    if !!_cb_autowheel {
        SetTimer _cb_autowheel, 0
    }
    if !_autowheel_enabled {
        HotIf _autowheel_hotif
        Hotkey "WheelDown", "Off"
        Hotkey "WheelUp", "Off"
        Hotkey "RButton", "Off"
        Hotkey "MButton", "Off"
        HotIf
        _autowheel_tooltip_msg 0
        return
    }
    _cb_autowheel := _autowheel.Bind(_wheeldir)
    HotIf _autowheel_hotif
    Hotkey( "WheelDown", (*)=>(
            _autowheel_interval := Max(_autowheel_interval_min, _autowheel_interval - _autowheel_interval_delta)
          , SetTimer(_cb_autowheel, _autowheel_interval)
          , _autowheel_tooltip_msg(_autowheel_interval)
        ), "I1 On" )
    Hotkey( "WheelUp", (*)=>(
            _autowheel_interval := _autowheel_interval + _autowheel_interval_delta
          , SetTimer(_cb_autowheel, _autowheel_interval)
          , _autowheel_tooltip_msg(_autowheel_interval)
        ), "I1 On" )
    Hotkey( "RButton", (*)=>(
            _cb_autowheel()
          , SetTimer(_cb_autowheel, _autowheel_interval)
          , _autowheel_tooltip_msg(_autowheel_interval)
        ), "On" )
    Hotkey("MButton", (*)=>(
            _autowheel(_wheeldir = "Up" ? "Down" : "Up")
          , SetTimer(_cb_autowheel, _autowheel_interval)
          , _autowheel_tooltip_msg(_autowheel_interval)
        ), "On" )
    HotIf
    SetTimer(_cb_autowheel, _autowheel_interval)
    _autowheel_tooltip_msg _autowheel_interval
}

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

