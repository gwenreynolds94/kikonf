; WAPIWrapr.ahk

#Requires AutoHotkey v2+
#Include Debug.ahk
#SingleInstance Force

class WAPI {
    static __New() {
        _ToVariadic_(_this, _thisMethod, _staticArgs*) {
            _extraArgs := (_staticArgs.Length - (_thisMethod.MaxParams - 1))
            loop _extraArgs
                _staticArgs.Pop()
            return (*) => (_thisMethod(_this, _staticArgs*))
        }
        for _func in this.OwnProps()
            if (_func ~= "^(?!(__|Prototype$)).*") and (this.%_func% is Func)
                this.%_func%.DefineProp("ToVariadic", { Call: _ToVariadic_.Bind(this) })
    }
    static IsZoomed(_wintitle:="A") {
        hWnd := (_wintitle and WinExist(_wintitle)) or WinExist("A")
        isZoomed := DllCall("User32\IsZoomed", "Ptr", hWnd, "Int")
        return isZoomed
    }
}


hotkey "^6", WAPI.IsZoomed.ToVariadic("A")
^7::ExitApp()


