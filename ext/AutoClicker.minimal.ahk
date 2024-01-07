; AutoClicker.ahk

#Requires AutoHotkey v2+
#SingleInstance Force

/**
  TODO Add support for custom updown intervals
  TODO Add tooltip to edit box for sequence name containing the invalid path chars
  */

class AutoClicker {
    class SendSequence extends Array {
        class ClickEntry {
            x := 0
          , y := 0
          , button := "Left"
          , target_win := false
            __New(_x, _y, _button:="Left", _target_win:=false) {
                this.x := _x
                this.y := _y
                this.button := _button
                this.target_win := _target_win
            }
            Execute(*) {
                if !!this.target_win
                    ControlClick( "x" this.x " y" this.y ; position or control
                                , this.target_win        ; window title
                                , unset                  ; window text
                                , this.button            ; button: L R M X1 X2 W[U|P|L|R]
                                , 1                      ; click count
                                , "NA" )                 ; options: NA(NoActivate) D(Down) U(Up)
                else CoordMode("Mouse", "Screen")
                   , Click( this.button ; button: L R M X1 X2 W[U|P|L|R]
                          , this.x      ; x coordinate
                          , this.y      ; y coordinate
                          , 1           ; click count
                          , unset       ; state: U[p] D[own]
                          , unset )     ; relative to cursor: Rel[ative]
            }
            Call := ObjBindMethod(this, "Execute")
        }
        class KeyEntry {
            key := ""
          , target_win := false
            __New(_key, _target_win:=false) {
                this.key := _key
                this.target_win := _target_win
            }
            Execute(*) {
                if !!this.target_win
                    ControlSend( this.key        ; key string
                               , unset           ; control
                               , this.target_win ; window title
                               , unset )         ; window text
                else Send(this.key)
            }
            Call := ObjBindMethod(this, "Execute")
        }
        /**
         * @return {AutoClicker.SendSequence}
         */
        static Call(_target_win:=false, _name:="", *) {
            new_instance := super.Call()
            new_instance.target_win := _target_win
            new_instance.name := _name
            return new_instance
        }
        send_interval := 0.5
        sequence_interval := 3.0
        target_win := false
        active := false
        name := ""
        save_file_name := ""
        toggle_hotkey := ""
        sequence_duration => Abs((this.Length - 1) * this.send_interval * 1000)
        AddClick(_x, _y, _button:="Left", *) {
            this.Push AutoClicker.SendSequence.ClickEntry(_x, _y, _button, this.target_win)
        }
        AddKey(_key, *) {
            this.Push AutoClicker.SendSequence.KeyEntry(_key, this.target_win)
        }
        Execute(*) {
            if !this.Length
                return
            this[1]()
            loop (this.Length - 1)
                SetTimer this[A_Index+1], Abs(this.send_interval * 1000) * A_Index * -1
        }
        Call := ObjBindMethod(this, "Execute")
        Activate(*) {
            timer_interval := Abs(this.sequence_interval * 1000) + this.sequence_duration
            SetTimer(this, timer_interval)
            AutoClicker.TooltipMsg "AutoClicker: ON"
            this.active := true
        }
        Deactivate(*) {
            SetTimer(this, 0)
            AutoClicker.TooltipMsg "AutoClicker: OFF"
            this.active := false
        }
        Toggle(*) => !this.active ? this.Activate() : this.Deactivate()
        cbToggle := ObjBindMethod(this, "Toggle")
        EnableHotkey(*) => Hotkey(this.toggle_hotkey, this.cbToggle, "On")
        DisableHotkey(*) => Hotkey(this.toggle_hotkey, "Off")
    }
    static TooltipMsg(_msg, _duration:=1000, *) {
        static cbToolTipOff := (*)=>ToolTip()
        ToolTip _msg
        SetTimer cbToolTipOff, Abs(_duration) * -1
    }
}

; replace <floorp.exe> with the executable name of the target window
send_sequence := AutoClicker.SendSequence("ahk_exe floorp.exe")
; seconds between individual click/key presses
send_sequence.send_interval := 0.25
; seconds between whole sequence executions
send_sequence.sequence_interval := 4.0
send_sequence.AddClick(1080, 900)
send_sequence.AddClick(1550, 950)
send_sequence.AddKey("w")
; Shift+Win+e toggles the autoclicker
send_sequence.toggle_hotkey := "+#e"
send_sequence.EnableHotkey()
