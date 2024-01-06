; Builtins.Array.ahk

#Requires AutoHotkey v2+

class __Array extends Array {
    Static __New() {
        this.Prototype.__Class := "Array"
        for _prop in ObjOwnProps(this.Prototype)
            if SubStr(_prop, 1, 2) != "__"
                Array.Prototype.%_prop% := this.Prototype.%_prop%
    }
    /**
      * @param {(_item, _index?)=>Any} _func
      * @param {Object} [_include_return_type=false]
      * @param {Object} [_exclude_return_type=false]
      */
    ForEach(_func, _include_return_type:=false, _exclude_return_type:=false) {
        foreach_results := []
        for _item in this {
            func_result := false
            if _func.MinParams = 1
                func_result := _func(_item)
            else if _func.MinParams = 2
                func_result := _func(_item, A_Index)
            if (!!_exclude_return_type and !(func_result is _exclude_return_type)) or
               (!!_include_return_type and !!(func_result is _include_return_type))
                foreach_results.Push func_result
        }
        return foreach_results
    }
    /**
      * @param {(_item, _index?)=>Number} _func
      */
    Where(_func) {
        where_results := []
        for _item in this {
            if _func.MinParams = 1 and !!_func(_item) or
               _func.MinParams = 2 and !!_func(_item, A_Index)
                where_results.Push _item
        }
        return where_results
    }
}

