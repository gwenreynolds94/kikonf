
Class __String extends String {

    static __matchmode__ := "regex"

    Static __New() {
        this.Prototype.__Class := "String"
        for _prop in ObjOwnProps(this.Prototype)
            String.Prototype.%_prop% := this.Prototype.%_prop%
    }

    WinExists(_win_text?, _exclude_title?, _exclude_text?, *) => WinExist(
                        this, _win_text?, _exclude_title?, _exclude_text?)

    Length() {
        Return StrLen(this)
    }

    Sub(_starting_pos, _length?){
        Return SubStr(this, _starting_pos, _length ?? unset)
    }

    Split(_delimeters?, _omitchars?, _maxparts?) {
        Return StrSplit(this, _delimeters?, _omitchars?, _maxparts?)
    }

    StartsWith(_chars) {
        Return this.Sub(1, _chars.Length()) == _chars
    }

    EndsWith(_chars) {
        Return this.Sub((-1) * _chars.Length(), _chars.Length()) ~= _chars
    }

    Lower() {
        return StrLower(this)
    }

    Upper() {
        return StrUpper(this)
    }

    Replace(_re_needle, _replacement:='', &_cnt:=(-1), _starting_pos?) {
        repl_args := [
            this,
            _re_needle,
            _replacement
        ]
        if _cnt >= 0
            repl_args.Push(&_cnt)
        if (_starting_pos ?? False)
            repl_args.Push(_starting_pos)
        return RegExReplace(repl_args*)
    }

    Repeat(_count) {
        retstr := ""
        loop _count
            retstr .= this
        return retstr
    }

}

