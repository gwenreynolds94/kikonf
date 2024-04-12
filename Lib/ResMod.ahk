; ResMod.ahk

#Requires AutoHotkey v2+

class ResMod {
    static ActiveDeviceNumber {
        Get {
            static monLeft, monTop, monRight, monBottom, mouseX, mouseY
            monCount := MonitorGetCount()
            CoordMode "Mouse", "Screen"
            MouseGetPos &mouseX, &mouseY
            Loop monCount {
                MonitorGet A_Index, &monLeft, &monTop, &monRight, &monBottom 
                if mouseX >= monLeft and mouseX < monRight and
                   mouseY >= monTop and mouseY < monBottom
                    return A_Index - 1
            }
        }
    }
    static DisplaySettings[_DevNum:=0] {
        Get {
            DisplayDevice := ResMod.DisplayDeviceBuffer(_DevNum)
            DisplaySettings := ResMod.DisplaySettingsBuffer()
            DllCall "EnumDisplaySettingsA", "Ptr", DisplayDevice.DeviceNameBuffer, "UInt", -1, "Ptr", DisplaySettings
            return DisplaySettings
        }
    }
    static ActiveDisplaySettings => this.DisplaySettings[this.ActiveDeviceNumber]
    static SetDisplaySettings(_DevNum, _width:=false, _height:=false, _color_depth:=false, _refresh_rate:=false, *) {
        DeviceNameBuf := ResMod.DisplayDeviceBuffer(_DevNum).DeviceNameBuffer
        DisplaySettings := this.DisplaySettings[_DevNum]
        if _width
            DisplaySettings.Width := _width
        if _height
            DisplaySettings.Height := _height
        if _color_depth
            DisplaySettings.ColorDepth := _color_depth
        if _refresh_rate
            DisplaySettings.RefreshRate := _refresh_rate
        DllCall "ChangeDisplaySettingsExA", "Ptr", DeviceNameBuf, "Ptr", DisplaySettings, "UInt", 0, "UInt", 0, "UInt", 0
    }
    static SetActiveDisplaySettings(_width:=false, _height:=false, _color_depth:=false, _refresh_rate:=false, *) =>
        this.SetDisplaySettings(this.ActiveDeviceNumber, _width, _height, _color_depth, _refresh_rate)
    static ToggleDisplayZoom(_DevNum, _zoom_width, _zoom_height, *) {
        DeviceNameBuf := ResMod.DisplayDeviceBuffer(_DevNum).DeviceNameBuffer
        DisplaySettings := this.DisplaySettings[_DevNum]
        CurrentWidth := DisplaySettings.Width
        DisplaySettings.Width := (CurrentWidth = 1920) ? _zoom_width : 1920
        DisplaySettings.Height := (CurrentWidth = 1920) ? _zoom_height : 1080
        DllCall "ChangeDisplaySettingsExA", "Ptr", DeviceNameBuf, "Ptr", DisplaySettings, "UInt", 0, "UInt", 0, "UInt", 0
    }
    static ToggleActiveDisplayZoom(_zoom_width, _zoom_height, *) =>
        this.ToggleDisplayZoom(this.ActiveDeviceNumber, _zoom_width, _zoom_height)
    static UpdateRefreshRate(_DevNum:=(-1), _refresh_rate:=120, *) {
        if _DevNum >= 0 {
            this.SetDisplaySettings(_DevNum,,,, _refresh_rate)
            return
        }
        Loop MonitorGetCount()
            this.SetDisplaySettings(A_Index - 1,,,, _refresh_rate)
    }
    static cbUpdateRefreshRate(_DevNum:=(-1), _refresh_rate:=120) =>
        ObjBindMethod(ResMod, "UpdateRefreshRate", _DevNum, _refresh_rate)
    static cbSetActiveDisplaySettings(_width:=false, _height:=false, _color_depth:=false, _refresh_rate:=false) =>
        ObjBindMethod(ResMod, "SetActiveDisplaySettings", _width, _height, _color_depth, _refresh_rate)
    static cbToggleActiveDisplayZoom(_zoom_width, _zoom_height) =>
        ObjBindMethod(ResMod, "ToggleActiveDisplayZoom", _zoom_width, _zoom_height)
    class RegistryDisplaySettings extends Array {
        StringifiedList := ""
        StringifiedCompactList := ""
        __New(_DevNum:=0, _min_refresh_rate:=60) {
            super.__New()
            DisplayDevice := ResMod.DisplayDeviceBuffer(_DevNum)
            DisplaySettings := ResMod.DisplaySettingsBuffer()
            While DllCall("EnumDisplaySettingsA", "Ptr", DisplayDevice.DeviceNameBuffer, "UInt", A_Index - 1, "Ptr", DisplaySettings) {
                StringifiedDisplaySettings := DisplaySettings.Stringified
                DisplayRefreshRate := DisplaySettings.RefreshRate
                if InStr(this.StringifiedList, StringifiedDisplaySettings) or
                        (DisplayRefreshRate < _min_refresh_rate)
                    continue
                this.Push DisplaySettings.ObjLiteral
                this.StringifiedList .= StringifiedDisplaySettings "`n"
                SplitStringified := StrSplit(StringifiedDisplaySettings, "@",, 2)
                if not InStr(this.StringifiedCompactList, SplitStringified[1]) {
                    this.StringifiedCompactList .= StringifiedDisplaySettings "`n"
                    continue
                }
                this.StringifiedCompactList := RegExReplace( this.StringifiedCompactList
                                                           , "(" SplitStringified[1] "[@\d]+)"
                                                           , "$1@" DisplayRefreshRate )
            }
            this.StringifiedCompactList := Sort(this.StringifiedCompactList, "N")
        }
    }
    class DisplayDeviceBuffer extends Buffer {
        __New(_DevNum:=0) {
            super.__New(424, 0)
            NumPut "UInt", 424, this
            DllCall "EnumDisplayDevicesA", "UInt", 0, "UInt", _DevNum, "Ptr", this, "UInt", 1
        }
        DeviceName {
            Get {
                DeviceNameStr := ""
                Loop 32
                    DeviceNameStr .= Chr(NumGet(this, 3 + A_Index, "Char"))
                return DeviceNameStr
            }
        }
        DeviceNameBuffer {
            Get {
                DevNameBuf := Buffer(32, 0)
                StrPut this.DeviceName, DevNameBuf, "CP0"
                return DevNameBuf
            }
        }
    }
    class DisplaySettingsBuffer extends Buffer {
        __New() {
            super.__New(156, 0)
            NumPut "UInt", 156, this, 36
        }
        Width {
            Get => NumGet(this, 108, "UInt")
            Set => NumPut("UInt", Value, this, 108)
        }
        Height {
            Get => NumGet(this, 112, "UInt")
            Set => NumPut("UInt", Value, this, 112)
        }
        ColorDepth {
            Get => NumGet(this, 104, "UInt")
            Set => NumPut("UInt", Value, this, 112)
        }
        RefreshRate {
            Get => NumGet(this, 120, "UInt")
            Set => NumPut("UInt", Value, this, 120)
        }
        ObjLiteral => { Width: this.Width
                      , Height: this.Height
                      , ColorDepth: this.ColorDepth
                      , RefreshRate: this.RefreshRate }
        Stringified => this.Width "x" this.Height "@" this.RefreshRate
    }
}

