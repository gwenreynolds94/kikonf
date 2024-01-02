; ResMod.ahk

#Requires AutoHotkey v2+

class ResMod {
    static ActiveDeviceNumber {
        Get {
            monCount := MonitorGetCount()
            CoordMode "Mouse", "Screen"
            MouseGetPos(&mouseX, &mouseY)
            Loop monCount {
                MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
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
    static cbSetActiveDisplaySettings(_width:=false, _height:=false, _color_depth:=false, _refresh_rate:=false) =>
        ObjBindMethod(ResMod, "SetActiveDisplaySettings", _width, _height, _color_depth, _refresh_rate)
    static cbToggleActiveDisplayZoom(_zoom_width, _zoom_height) => ObjBindMethod(ResMod, "ToggleActiveDisplayZoom", _zoom_width, _zoom_height)
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
    }
}
ResMod.ToggleDisplayZoom(1, 1280, 720)
