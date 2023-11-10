; HotList.ahk

#Requires AutoHotkey v2+

class HotList extends Map {
    static PreBound := true
    _unnamed_count_ := 0
    _prebound_hotifs_ := Map()
    Strict := true
    Call := ObjBindMethod(this, "_Call_")
    __New(_strict:=true, _hotitems*) {
        this.Strict := _strict
        this.Push(_hotitems*)
    }
    Push(_items*) {
        for _index, _item in _items {
            while this.has(this._unnamed_count_)
                this._unnamed_count_++
            this[this._unnamed_count_] := _item
            bhres := this._GetBoundCheck(_item)
            this._prebound_hotifs_[this._unnamed_count_] := (
                (!!bhres) ? bhres : ObjBindMethod(this, "_CheckItem", _item) )
        }
    }
    _StrictCheck() {
        _PreBoundStrictCheck() {
            for _,_bh in this._prebound_hotifs_
                if !_bh()
                    return false
            return true
        }
        if HotList.PreBound
            return _PreBoundStrictCheck()
        for _index, _item in this
            if !this._CheckItem(_item)
                return false
        return true
    }
    _AnyCheck() {
        _PreBoundAnyCheck() {
            for _,_bh in this._prebound_hotifs_
                if !!_bh()
                    return true
            return false
        }
        if HotList.PreBound
            return _PreBoundAnyCheck()
        for _index, _item in this
            if !!this._CheckItem(_item)
                return true
        return false
    }
    ; check to see if property set to an object bound method will work here
    ; (_item is Func) or HasMethod(_item, "Call")
    _GetBoundCheck(_i)=>(HasMethod(_i,"Call") ? (_i.Call.MaxParams or _i.Call.IsVariadic) ? (_i) :
        ( (*)=>(_i()) ) : ( _i is Primitive ) ? ( ((_w,*)=>(WinActive(_w))).Bind( ((IsNumber(_i) ||
        ((_p:=InStr(_i,"ahk_")) && InStr("grclhwexpid",SubStr(_i,_p,2)))) ? (_i) : (_i~=".exe$") ?
        ("ahk_exe" _i) : (_i)))) : (_i is VarRef) ? (((&_v,*)=>(!_v)).Bind(&_i)) : false)

    _CheckItem(_i)=>((HasMethod(_i,"Call") and !_i.Call.MinParams) ? (_i()) : (_i is Primitive) ?
        (WinActive((IsNumber(_i) || (_p:=InStr(_i,"ahk_")) && InStr("grclhwexpid",SubStr(_i,_p,2))) ?
        (_i) : (_i~=".exe$") ? ("ahk_exe" _i) : (_i))) : (_i is VarRef) ? ((&_v,*)=>(!_v)).Bind(&_i) : false)

    _Call_(*) {
        if this.Strict
            return this._StrictCheck()
        return this._AnyCheck()
    }
}


/**
    _GetBoundCheck(_item) {
        static wtlstr := "groclahwnexepid "
        ; check to see if property set to an object bound method will work here
        if _item is Func or HasMethod(_item, "Call") {
            if not (_item.Call.MaxParams or _item.Call.IsVariadic)
                return ( (*)=>(!!_item()) )
            return (_item)
        }
        if _item is Primitive {
            if IsNumber(_item)
                return ( (*)=>(!!WinActive("ahk_id " _item)) )
            if (wtlpos:=InStr(_item, "ahk_")) and InStr(wtlstr, SubStr(_item, wtlpos, 3))
                return ( (*)=>(!!WinActive(_item)) )
            if SubStr(_item, -4) = ".exe"
                return ( (*)=>(!!WinActive("ahk_exe " _item)) )
            return ( (*)=>(!!WinActive(_item)) )
        }
        if _item is VarRef
            return ((&_v, *)=>(!_v)).Bind(&_item)
        return false
    }
    _CheckItem(_item) {
        static wtlstr := "groclahwnexepid "
        ; check to see if property set to an object bound method will work here
        if _item is Func or HasMethod(_item, "Call")
            if not (!_item.Call.MinParams)
                return !!_item()
        if _item is Primitive {
            if IsNumber(_item)
                return !!WinActive("ahk_id " _item)
            if (wtlpos:=InStr(_item, "ahk_")) and InStr(wtlstr, SubStr(_item, wtlpos, 3))
                return !!WinActive(_item)
            if SubStr(_item, -4) = ".exe"
                return !!WinActive("ahk_exe " _item)
            return !!WinActive(_item)
        }
        return false
    }
*/
