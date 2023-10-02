; HotList.ahk

#Requires AutoHotkey v2.0

class HotList extends Map {
    _unnamed_count_ := 0
    Strict := true
    Call := ObjBindMethod(this, "_Call_")
    __New(_strict:=true, _hotitems*) {
        this.Strict := _strict
        for _item in _hotitems
            this.Push(_item)
    }
    Push(_items*) {
        for _index, _item in _items {
            while this.has(this._unnamed_count_)
                this._unnamed_count_++
            this[this._unnamed_count_] := _item
        }
    }
    _StrictCheck() {
        for _index, _item in this
            if !this._CheckItem(_item)
                return false
        return true
    }
    _AnyCheck() {
        for _index, _item in this
            if !!this._CheckItem(_item)
                return true
        return false
    }
    _CheckItem(_item) {
        if HasMethod(_item, "Call") and (!_item.Call.MinParams or !!_item.Call.IsVariadic)
            return !!_item()
        if _item is Primitive {
            if IsNumber(_item)
                return !!WinActive("ahk_id " _item)
            if _item ~= "^ahk_(class|id|pid|exe|group)"
                return !!WinActive(_item)
            if _item ~= "\.exe$"
                return !!WinActive("ahk_exe " _item)
        }
        return false
    }
    _Call_(*) {
        if this.Strict
            return this._StrictCheck()
        return this._AnyCheck()
    }
}

