
Class __Number extends Number {
    static __New() {
        this.Prototype.__Class := "Number"
        for _prop in ObjOwnProps(this.Prototype)
            Number.Prototype.%_prop% := this.Prototype.%_prop%
    }

    Abs() {
        return Abs(this)
    }

    Neg() {
        return ((-1) * Abs(this))
    }

    Clamp(_min:=0,_max:=1) {
        if _max < this
            return _max
        if _min > this
            return _min
        return this
    }

    Min(_values*) => Min(this, _values*)
    Max(_values*) => Max(this, _values*)
    Mod(_divisor) => Mod(this, _divisor)
    Round(_N:=0) => Round(this, _N)

    WinExists(_win_text?, _exclude_title?, _exclude_text?, *) => WinExist(
                        this, _win_text?, _exclude_title?, _exclude_text?)

    Nearest(_numbers*) {
        closest_number := _numbers.length ? _numbers[1] : Number(this)
        for _nbr in _numbers {
            if (_nbr - this).abs() < (closest_number - this).abs()
                closest_number := _nbr
        }
        return closest_number
    }
}

