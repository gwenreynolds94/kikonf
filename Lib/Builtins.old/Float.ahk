; Builtins.Float.ahk

Class __Float extends Float {
    static __New() {
        this.Prototype.__Class := "Float"
        for _prop in ObjOwnProps(this.Prototype)
            Float.Prototype.%_prop% := this.Prototype.%_prop%
    }

    /**
     *
     * @param {number} [_N=0] Round to `_N` digits after decimal point
     * @returns {number|string}
     */
    Round(_N:=0) {
        return Round(this, _N)
    }
}
