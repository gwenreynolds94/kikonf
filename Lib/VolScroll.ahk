; VolScroll.ahk

#Requires AutoHotkey v2+

#Include HotList.ahk

Class VolScroll {
    static _enabled := false
        /**
         * @prop {Gui} gui
         */
         , gui := false
        /**
         * @prop {Gui.Progress} progress
         */
         , progress := false
         , x := 0
         , y := 0
         , w := 50
         , unmutedColor := "c3f6f6f"
         , mutedColor := "c3f4a4a"
         , transparency := 230
         , multiplier := 2
         , timeout := 1000
         , bmhide := ObjBindMethod(this, "hide")
         , bmonwheeldown := ObjBindMethod(this, "OnWheelDown")
         , bmonwheelup := ObjBindMethod(this, "OnWheelUp")
         , bmonmbutton := ObjBindMethod(this, "OnMButton")
         , bmonxbutton1 := ObjBindMethod(this, "OnXButton1")
         , hotifexpr := HotList(false,
             (*)=>(
                 !_G.gamemode && (
                     CoordMode("Mouse"),
                     MouseGetPos(&_mx,&_my,&_mhwnd),
                     ( WinGetClass(_mhwnd) ~= "Shell_(Secondary)?TrayWnd"    ) ||
                     ( (_mx <= 50) && (_my >= (A_ScreenHeight - 50))         ) ||
                     ( (_mx <= 10) && (WinActive("ahk_exe wezterm-gui.exe")) )
                 )
             ),
             (*)=>(
                 !!_G.gamemode && (
                     CoordMode("Mouse"),
                     MouseGetPos(,,&_mhwnd),
                     ( WinGetClass(_mhwnd) = "Shell_SecondaryTrayWnd" )
                 )
             )
         )
         , hidden := true
         , muted := false
    static __New() {
        this.gui := Gui("-Caption +Owner +AlwaysOnTop", "kikonf.VolScroll")
        this.gui.MarginX := 0, this.gui.MarginY := 0
        MonitorGet(MonitorGetPrimary(), &_monleft, &_montop, &_monright, &_monbottom)
        this.x := (_monright - _monleft) - (this.w / 2)
        this.progress := this.gui.AddProgress(
            "Smooth range0-100 BackgroundAAAAAA" .
            " w" this.w .
            " h" A_ScreenHeight " vertical" .
            " " (!!SoundGetMute() ? this.mutedColor : this.unmutedColor) ,
            Round(SoundGetVolume()))
        this.gui.Show("NA Hide")
        WinSetTransColor("AAAAAA " this.transparency, this.gui)
        this.gui.Hide()
    }
    Static Show(*) {
        if !!this.hidden
            this.gui.show("NA x" this.x " y" this.y)
        this.hidden := false
        SetTimer this.bmhide, Abs(this.timeout) * (-1)
    }
    Static Hide(*) {
        this.gui.Hide()
        this.hidden := true
    }
    static CurrentVolume => Round(SoundGetVolume())
    static OnWheelUp(*) {
        muted := !!SoundGetMute()
        if !muted {
            Send "{Volume_Up " this.multiplier "}"
            this.progress.Opt(this.unmutedColor)
            this.progress.value := this.CurrentVolume
        } else {
            this.progress.Opt(this.mutedColor)
            newvol := Integer(SoundGetVolume() + (2 * this.multiplier))
            newvol := (newvol > 100) ? 100 : newvol
            this.progress.Value := newvol
            SoundSetVolume(newvol)
        }
        this.Show()
    }
    static OnWheelDown(*) {
        muted := !!SoundGetMute()
        if !muted {
            Send "{Volume_Down " this.multiplier "}"
            this.progress.Opt(this.unmutedColor)
            this.progress.value := this.CurrentVolume
        } else {
            this.progress.Opt(this.mutedColor)
            newvol := Integer(SoundGetVolume() - (2 * this.multiplier))
            newvol := (newvol < 0) ? 0 : newvol
            this.progress.Value := newvol
            SoundSetVolume(newvol)
        }
        this.Show()
    }
    static OnMButton(*) {
        muted := !!SoundGetMute()
        SoundSetMute(-1)
        this.progress.Opt( muted ? this.unmutedColor : this.mutedColor )
        WinActivate("ahk_class Shell_TrayWnd")
        this.Show()
    }
    static OnXButton1(*) {
        WinActivate("ahk_class Shell_TrayWnd")
    }
    static Enable(*) {
        if !!this._enabled
            return
        HotIf VolScroll.hotifexpr
        HotKey "WheelUp", this.bmonwheelup
        HotKey "WheelDown", this.bmonwheeldown
        HotKey "MButton", this.bmonmbutton
        HotKey "XButton1", this.bmonxbutton1
        HotIf
        this._enabled := true
    }
    static Disable(*) {
        if !this._enabled
            return
        HotIf VolScroll.hotifexpr
        HotKey "WheelUp", "Off"
        HotKey "WheelDown", "Off"
        HotKey "MButton", "Off"
        HotKey "XButton1", "Off"
        HotIf
        this._enabled := false
    }
}

