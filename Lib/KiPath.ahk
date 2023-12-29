; KiPath.ahk

#Requires AutoHotkey v2+

class KeyCache {
    static _all_ := Map()
         , _previd_entry_ := 0
         , _previd_table_ := 0
    static __Item[_key_string] {
        get => this._all_[_key_string]
        set => this._all_[_key_string] := Value
    }
    static Has(_key_string, *) => this._all_.Has(_key_string)
}

class KeyEntry {
    id := 0
    key_string := ""
    ontrigger_actions := []
    parent_table := false
    enabled := false
    __New(_key_string, _parent_table:=false, _actions*) {
        this.key_string := _key_string
        this.parent_table := _parent_table
        this.AppendTriggerActions(_actions*)
        this.id := KeyCache._previd_entry_++
    }
    Enable(*) {
        this.enabled := true
    }
    AppendTriggerActions(_actions*) {
    }
    PrependTriggerActions(_actions*) {
    }
}

class KeyTable extends Map {
    id := 0
    timeout := false
    oneshot := false

    _enabled_ := false
    actions := []
    bm := {
        Enable: ObjBindMethod(this, "Enable"),
        Disable: ObjBindMethod(this, "Disable"),
    }
    HasActivationActions => !!this.actions.Length
    HasHotkeys => !!this.Count
    __New(_timeout:=false, _oneshot:=false) {
        this.timeout := _timeout
        this.oneshot := _oneshot
        this.id := KeyCache._previd_table_++
    }
    Activate(*) {
        if this.HasActivationActions {
            for _action in this.actions {
                if _action is Func
                    _action()
                else if _action is Primitive
                    Send _action
            }
        }
        if this.HasHotkeys
            this.Enable
    }
    Enable(*) {
        if !!this._enabled_
            return
    }
    Disable(*) {
        if !this._enabled_
            return
    }
    Path(_keypath, _action, *) {

    }
    AppendActions(_key_string, _actions*) {
        if !this.Has(_key_string)
            this[_key_string] := KeyEntry(_key_string, this)
        this[_key_string].ontrigger_actions.Push(_actions*)
    }
    PrependActions(_key_string, _actions*) {
        if !this.Has(_key_string)
            this[_key_string] := KeyEntry(_key_string, this)
        this[_key_string].ontrigger_actions.InsertAt(1, _actions*)
    }
}

