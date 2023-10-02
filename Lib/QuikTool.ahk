; QuikTool.ahk

#Requires AutoHotkey v2.0

Class QuikTool {
    static bmHideToolTip := ObjBindMethod(QuikTool, "HideToolTip")
    static ShowToolTip(_msg, _dur:=500, *) =>
        (Tooltip(_msg), SetTimer(QuikTool.bmHideToolTip, Abs(_dur) * (-1)))
    static HideToolTip(*) => ToolTip()
    static Call(_msg, _dur:=500) => QuikTool.ShowToolTip(_msg, _dur)
}

