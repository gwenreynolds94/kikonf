; KiPath.ahk

#Requires AutoHotkey v2+

class KiKache {
    static _instance_ := Map()
         , _previd_ := 0
    static __Item[_kistr] {
        get => this._instance_[_kistr]
        set => this._instance_[_kistr] := Value
    }
}

class KiEntry {
    kistr := ""
    onTrigger := []
    parentTable := false
    __New(_kistr, _parentTable:=false, _actions*) {
        this.kistr := _kistr
        this.parentTable := _parentTable
        if !!_actions.Length
            this.onTrigger.Push(_actions*)
    }
}

class KiPath {
    static Kache := Map()
}

class KiTable extends Map {
    static _previd_ := 0
    id := 0
    timeout := false
    oneshot := false
    _enabled_ := false
    __New(_timeout:=false, _oneshot:=false) {
        this.timeout := _timeout
        this.oneshot := _oneshot
        KiTable._previd_++
        this.id := KiTable._previd_
    }
    Enable(*) {
        if !!this._enabled_
            return
        
    }
    Disable(*) {
        if !this._enabled_
            return
    }
    AddActions(_kistr, _actions*) {
        if !this.Has(_kistr)
            this[_kistr] := KiEntry(_kistr, this)
        this[_kistr].onTrigger.Push(_actions*)
    }
}

