; BuiltinsExt.StaticVariadic.ahk

#Requires AutoHotkey v2+

#Include ../
#Include Debug.ahk

class VariadicBase {
    class Method extends Func {
        __New() {
            Func()
        }
        /**
         * @param {Func} thisMethod
         * @param {Array} staticParams*
         */
        Call(thisMethod, staticParams*) {
            loop (staticParams.Length - (thisMethod.MaxParams - 1))
                staticParams.Pop()
            thisMethod.Call(this, staticParams*)
        }
    }
}

