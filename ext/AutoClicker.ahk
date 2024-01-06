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
        send_interval := 1.0
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
            timer_interval := Abs(this.send_interval * 1000) + this.sequence_duration
            SetTimer(this, timer_interval * -1)
            this.active := true
        }
        Deactivate(*) {
            SetTimer(this, 0)
            this.active := false
        }
        Toggle(*) => !this.active ? this.Activate() : this.Deactivate()
        cbToggle := ObjBindMethod(this, "Toggle")
        EnableHotkey(*) => Hotkey(this.toggle_hotkey, this.cbToggle, "On")
        DisableHotkey(*) => Hotkey(this.toggle_hotkey, "Off")
        TSV {
            Get {
                tsv_text := "name`t" this.name "`n"
                if this.target_win
                    tsv_text .= "target`t" this.target_win "`n"
                if this.toggle_hotkey
                    tsv_text .= "hotkey`t" this.toggle_hotkey "`n"
                for _item in this {
                    if _item is AutoClicker.SendSequence.ClickEntry
                        tsv_text .= "click`t" _item.x "`t" _item.y "`t" _item.button "`n"
                    else if _item is AutoClicker.SendSequence.KeyEntry
                        tsv_text .= "key`t" _item.key "`n"
                }
                return tsv_text
            }
        }
    }
    class ConfigFiles {
        static config_dir := A_AppData "\AHKAutoClicker"
             , default_sequence_name_prefix := "Sequence."
             , invalid_path_chars := "\/*?:<>|`""
        static config_path => this.config_dir "\AutoClicker.ini"
        static sequences_dir => this.config_dir "\saved"
        static __New() {
            if not DirExist(this.config_dir)
                DirCreate this.config_dir
            if not FileExist(this.config_path)
                FileAppend("", this.config_path, "UTF-8")
            if not DirExist(this.sequences_dir)
                DirCreate(this.sequences_dir)
        }
        static DefaultNewSequenceName {
            Get {
                sequence_number := 0
                loop files this.sequences_dir "\*.tsv"
                    sequence_number += ( A_LoopFileName =
                        (this.default_sequence_name_prefix sequence_number ".tsv") )
                return (this.default_sequence_name_prefix sequence_number)
            }
        }
        static SequenceNameExists[_sequence_name] => FileExist(this.sequences_dir "\" _sequence_name ".tsv")
        static LoadSequence(_filepath, *) {
            if !FileExist(_filepath)
                return
            SplitPath(_filepath,,,, &sequence_name)
            sequence := AutoClicker.SendSequence()
            sequence.save_file_name := sequence_name
            loop read, _filepath {
                split_line := StrSplit(A_LoopReadLine, "`t")
                switch split_line[1] {
                    case "click":
                        sequence.AddClick(split_line[2], split_line[3], split_line[4])
                    case "key":
                        sequence.AddKey(split_line[2])
                    case "name":
                        sequence.name := split_line[2]
                    case "target":
                        sequence.target_win := split_line[2]
                    case "hotkey":
                        sequence.toggle_hotkey := split_line[2]
                }
            }
            return sequence
        }
        static LoadSavedSequences(*) {
            loaded_sequences := []
            loop files this.sequences_dir "\*.tsv"
                loaded_sequences.Push AutoClicker.ConfigFiles.LoadSequence(A_LoopFileFullPath)
            return loaded_sequences
        }
        static SaveSequence(_sequence, *) {
            filepath := this.sequences_dir "\" _sequence.save_file_name ".tsv"
            if FileExist(filepath)
                FileDelete filepath
            FileAppend _sequence.TSV, filepath, "UTF-8"
        }
    }
    class ConfigUI {
        static ui := Gui("+AlwaysOnTop", "AutoClicker Config", this)
             , ctrl_opts := {
                 sequence_tree    : "r20 w300 x10 y10"
               , new_sequence_btn : "yp+0"
               , new_click_btn    : ""
               , new_key_btn      : ""
               , open_conf_dir_btn: ""
               , sequence_interval: "Number"
               , send_delay       : "Number"
               , hotkey_input     : ""
               , reset_hotkey_btn : ""
               , set_hotkey_btn   : ""
               , x_pos            : "Number Limit4"
               , y_pos            : "Number Limit4"
               , mouse_button     : ""
               , send_key_text    : ""
               , target_win_group : "Section w160 h80"
               , target_win_edit  : "xs+10 ys+20 w140"
               , target_win_select: "xs+10 ys+50 w140"
             }
             , sequence_tree     := this.ui.AddTreeView(this.ctrl_opts.sequence_tree)
             , new_sequence_btn  := this.ui.AddButton(this.ctrl_opts.new_sequence_btn, "New Sequence")
             , new_click_btn     := this.ui.AddButton(this.ctrl_opts.new_click_btn, "New Click")
             , new_key_btn       := this.ui.AddButton(this.ctrl_opts.new_key_btn, "New Key")
             , open_conf_dir_btn := this.ui.AddButton(this.ctrl_opts.open_conf_dir_btn, "Open Config Folder")
             , dynamic_ctrls := {
                 sequence: {
                     sequence_interval: this.ui.AddEdit(this.ctrl_opts.sequence_interval " Hidden")
                   , target_win_group : this.ui.AddGroupBox(this.ctrl_opts.target_win_group, "Target Window")
                   , target_win_edit  : this.ui.AddEdit(this.ctrl_opts.target_win_edit)
                   , target_win_select: this.ui.AddButton(this.ctrl_opts.target_win_select, "Select Visible Window")
                   , send_delay       : this.ui.AddEdit(this.ctrl_opts.send_delay " Hidden")
                   , hotkey_input     : this.ui.AddHotkey(this.ctrl_opts.hotkey_input " Hidden")
                   , reset_hotkey_btn : this.ui.AddButton(this.ctrl_opts.reset_hotkey_btn " Hidden", "Reset")
                   , set_hotkey_btn   : this.ui.AddButton(this.ctrl_opts.set_hotkey_btn " Hidden", "Set")
                 }
               , click_entry: {
                   x_pos : this.ui.AddEdit(this.ctrl_opts.x_pos " Hidden")
                 , y_pos : this.ui.AddEdit(this.ctrl_opts.y_pos " Hidden")
                 , mouse_button: this.ui.AddDropDownList(this.ctrl_opts.mouse_button " Hidden",
                     ["Left", "Right", "Middle", "X1", "X2", "WheelUp", "WheelDown", "WheelLeft", "WheelRight"]
                 )
               }
               , key_entry: {
                   send_key_text: this.ui.AddEdit(this.ctrl_opts.send_key_text " Hidden")
               }
             }
           ; , width := 600
           ; , height := 400
           ; , size := "w" this.width " h" this.height
        static __New() {
            this.ui.OnEvent "Close", "Close"
            this.ui.OnEvent "Escape", "Close"
            this.sequence_tree.OnEvent "ItemSelect", "ItemSelect_SequenceTree"
            this.open_conf_dir_btn.OnEvent "Click", "OpenConfigDir"
        }
        static OpenConfigDir(*) => Run(AutoClicker.ConfigFiles.config_dir)
        static Close(*) {
            this.ui.Hide
        }
        static Show(*) {
            this.ui.Show("AutoSize Center")
        }
        static Toggle(*) => (WinExist(this.ui) ? this.Close() : this.Show())
        static ItemSelect_SequenceTree(_ctrl, _item_id, *) {
            parent_id := this.sequence_tree.GetParent(_item_id)

        }
        static RefreshSequenceTree(*) {
            this.sequence_tree.Delete()
            for _name, _sequence in AutoClicker.sequences {
                _sequence_id := this.sequence_tree.Add(_name)
                for _entry in _sequence {
                    this.sequence_tree.Add( (_entry is AutoClicker.SendSequence.ClickEntry) ?
                                            "click: " _entry.button " x" _entry.x " y" _entry.y :
                                            "key: " _entry.key
                                          , _sequence_id )
                }
            }
        }
        static NewSendSequence(*) {
            new_sequence := AutoClicker.SendSequence(,AutoClicker.ConfigFiles.DefaultNewSequenceName)
            new_sequence.save_file_name := new_sequence.name
            AutoClicker.sequences.Set(new_sequence.name, new_sequence)
            AutoClicker.ConfigFiles.SaveSequence new_sequence
            this.RefreshSequenceTree()
            return new_sequence
        }
        static NewKeyEntry(*) {
        }
        static NewClickEntry(*) {
        }
    }
    static settings_gui := Gui("+AlwaysOnTop", "AutoClicker Settings", this)
    static sequences := Map()
    static __New() {
        for _sequence in AutoClicker.ConfigFiles.LoadSavedSequences()
            this.sequences.Set(_sequence.name, _sequence)
        AutoClicker.ConfigUI.RefreshSequenceTree
    }
    static TooltipMsg(_msg, _duration:=1000, *) {
        static cbToolTipOff := (*)=>ToolTip()
        ToolTip _msg
        SetTimer cbToolTipOff, Abs(_duration) * -1
    }
}

AutoClicker.ConfigUI.Show

