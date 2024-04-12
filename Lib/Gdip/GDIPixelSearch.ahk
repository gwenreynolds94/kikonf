; Gdip.GDIPixelSearch.ahk

#Requires AutoHotkey v2+
#SingleInstance Force
#DllLoad Winmm
#DllLoad kernel32

#Include gdijk.ahk

TimePeriod := 1


class GDIPixelSearch {
    static Call(_px, _py, *) {
        static sBitmap, argb, hex_argb, hex_r, hex_g, hex_b, r, g, b
        Gdip_Startup()
        sBitmap := Gdip_BitmapFromScreen(1)
        argb := Gdip_GetPixel(sBitmap, _px, _py)
        hex_argb := Format("{:x}", argb)
        hex_r := SubStr(hex_argb, 3, 2)
        hex_g := SubStr(hex_argb, 5, 2)
        hex_b := SubStr(hex_argb, 7, 2)
        r := Number("0x" hex_r)
        g := Number("0x" hex_g)
        b := Number("0x" hex_b)
        return {r: r, g: g, b: b}
    }
}
asd := A_TickCount
mx := 0
my := 0
    DllCall "timeBeginPeriod", "UInt", TimePeriod
loop 60 {
    MouseGetPos(&_mx, &_my)
    col := GDIPixelSearch(_mx, _my)
    tooltip col.r "." col.g "." col.b
}
    DllCall "timeEndPeriod", "UInt", TimePeriod
Tooltip (A_TickCount - asd)
    Sleep 5000

    ExitApp()
