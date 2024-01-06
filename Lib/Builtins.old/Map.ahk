
Class __Map extends Map {

    static previd := 0
        ,  cache := []

    Static __New() {
        this.Prototype.__Class := "Map"
        for _prop in ObjOwnProps(this.Prototype)
            if not _prop.StartsWith("__")
                Map.Prototype.%_prop% := this.Prototype.%_prop%
    }
    ___cacheid___ := 0

    __new(_params*) {
        super.__new(_params*)
        this.___cacheid___ := ++__Map.previd
    }

    Extend(_map2, _mode:="keep", _new_map:=false, *) {
        newmap := _new_map and map() or this
        if _new_map
            for _k1, _v1 in this
                newmap[_k1] := _v1
        for _key, _value in _map2
            if (!newmap.has(_key) or _mode="force")
                newmap[_key] := _value
        return newmap
    }

    ForEach(_func) {
        parsedarray := []
        for _k, _v in this
            parsedarray.push _func(_k, _v, A_index, this)
        return parsedarray
    }

    Where(_func) {
        parsedmap := Map()
        for _k, _v in this
            if _func(_k, _v, A_Index, this)
                parsedmap[_k] := _v
        return parsedmap
    }

    WhereSplit(_func) {
        parsedmap := Map()
        for _k, _v in this
            parsedmap[!!_func(_k, _v, A_Index, this)][_k] := _v
        return parsedmap
    }

    Keys(*)=>this.ForEach((_k, *)=>(_k))
    Values(*)=>this.ForEach((_, _v, *)=>(_v))

}

