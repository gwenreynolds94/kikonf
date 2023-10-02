; kikonf.ahk

#Requires AutoHotkey v2
#Warn All, StdOut
#SingleInstance Force

#Include <Debug>
#Include <FS>
#Include <QuikTool>
#Include <HotList>
#Include <Config>
#Include <Crosshair>
#Include <Builtins\All>

kfg := Config(A_AppData "\kikonf\.ahkonf", Map(
    "PCNames", Map(
        "DeskMain", "DESKTOP-HQ7DNU5",
        "LapMain" , "DESKTOP-JJTV8BS",
    ),
    "PCAddr", Map(
        "DeskMain", "192.168.1.4",
        "LapMain" , "192.168.1.3",
    ),
))

PinkHair := Crosshair("6f", "ffafcf")
Hotkey "#c", PinkHair.bmtoggle
Hotkey "<^#c", PinkHair.bmdecsize
Hotkey "<!#c", PinkHair.bmincsize
Hotkey ">!#c", PinkHair.bmdectrans
Hotkey ">^#c", PinkHair.bminctrans

Hotkey "#F4", (*)=>ExitApp()
Hotkey "#F5", (*)=>Reload()

VolScrollHotList := HotList(true, "wezterm-gui.exe", (*)=>(MouseGetPos(&_mx,&_my),_mx <= 5 && _my >= (A_ScreenHeight - 100)))

Hotif VolScrollHotList
Hotkey "WheelUp", (*)=>(Send("{Volume_Up}"), QuikTool(Integer(SoundGetVolume())))
Hotkey "WheelDown", (*)=>(Send("{Volume_Down}"), QuikTool(Integer(SoundGetVolume())))
Hotif

