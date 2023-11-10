; AllWin.ahk

#Requires AutoHotkey v2+

class AllWin {
    static cache := Map()
    static blacklists := Map(
                "class" , [
                    "Progman", "Shell_(Secondary)?TrayWnd", "SysShadow", "EdgeUiInputWndClass",
                    "Internet Explorer_Hidden", "ApplicationManager_ImmersiveShellWindow",
                    "CEF-OSC-WIDGET", "RainmeterMeterWindow", "tooltips_class32", 
                    "Windows\.UI\.Core\.CoreWindow", "ApplicationFrameWindow", 
                    "MozillaDropShadowWindowClass"
                ],
                "processname" , ["PowerToys.MouseWithoutBordersHelper.exe"],
                "title" , [ "^Program\sManager", "^Window\sSpy\sfor\sAHKv2" ],
            )
        ,  whitelists := Map(
                "class", [],
                "processname", ["firefox.exe", "wezterm-gui.exe"],
                "title", []
            )
    static __Item[_wintitle, _all:=false] {
        Get {
            wHwnd := WinExist(_wintitle)
            if not this.cache.Get(wHwnd, false)
                this.cache.Set(wHwnd, WinWrapr(_wintitle))
            return this.cache[wHwnd]
        }
    }
    static __Enum(_varcount:=1) {
        __Enum__(_vcnt:=1) {

        }
        return __Enum__.Bind(_varcount)
    }
    static __FilterCheck__(_wintitle) {
        for _listgroup in [[this.whitelists,1],[this.blacklists,0]]
            for _type, _list in _listgroup[1] {
                _f_wintitle_alt := %("winget" _type)%(_wintitle)
                for _title in _list
                    if _f_wintitle_alt ~= _title
                        return _listgroup[2]
            } 
        return true
    }
    static Filter(_wintitles*) {
        filtered_list := []
        for _wt in _wintitles
            if !this.__FilterCheck__(_wt)
                filtered_list.Push _wt
        return filtered_list
    }
}

class WinWrapr {
    Hwnd := 0x00000
    __New(_wintitle:="A") {
        this.Hwnd := WinExist(_wintitle)
    }
    Active => WinActive(this)
    Exists => WinExist(this)
    Move(_x?, _y?, _w?, _h?) {
        WinMove(_x?, _y?, _w?, _h?, this.Hwnd)
    }
}


class Coord {

    class Rect {
        x := 0
        y := 0
        w := 0
        h := 0
        _coordrefs_ := {
            x: "_x",
            y: "_y",
            w: "_w",
            h: "_h",
        }
        __New(_x?, _y?, _w?, _h?) {
            this.Set(_x?, _y?, _w?, _h?)
        }
        Set(_x?, _y?, _w?, _h?) {
            this.x := _x ?? this.x
            this.y := _y ?? this.y
            this.w := _w ?? this.w
            this.h := _h ?? this.h
        }
        Mod(_x?, _y?, _w?, _h?) {
            for _pname, _vname in this._coordrefs_ {
                if (Isset(%_vname%) and 
                        IsNumber(crdval := %_vname%))
                    this.%_pname% := this.%_pname% + Number(crdval)
            }
        }
        Calc(_x?, _y?, _w?, _h?) {
            for _pname, _vname in this._coordrefs_ {
                if (Isset(%_vname%) and 
                        ((crdval := %_vname%) is Func) and 
                        (crdval.MaxParams + crdval.IsVariadic))
                    this.%_pname% := crdval.Call({key: _pname, val: this.%_pname%})
            }
        }
    }

    class Pos extends Coord.Rect {
        _coordrefs_ := {
            x: "_x",
            y: "_y",
        }
        __New(_x?, _y?) {
            this.DeleteProp "w"
            this.DeleteProp "h"
            this.Set(_x?, _y?)
        }
        Set(_x?, _y?) => super.Set(_x?, _y?)
        Mod(_x?, _y?) => super.Mod(_x?, _y?)
        Calc(_x?, _y?) => super.Calc(_x?, _y?)
    }

    class Size extends Coord.Rect {
        _coordrefs_ := {
            w: "_w",
            h: "_h",
        }
        __New(_w?, _h?) {
            this.DeleteProp "x"
            this.DeleteProp "y"
            this.Set(_w?, _h?)
        }
        Set(_w?, _h?) => super.Set(_w?, _h?)
        Mod(_w?, _h?) => super.Mod(_w?, _h?)
        Calc(_w?, _h?) => super.Calc(_w?, _h?)
    }

}
