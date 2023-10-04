; kikonf.ahk

#Requires AutoHotkey v2
#Warn All, StdOut
#SingleInstance Force

#Include <Debug>
#Include <FS>
#Include <VolScroll>
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

Hotkey "$sc029", (*)=>Send("{sc029}")
Hotkey "+sc029", (*)=>Send("{~}")
Hotkey "sc029 & F4", (*)=>ExitApp()
Hotkey "sc029 & F5", (*)=>Reload()
Hotkey "sc029 & h", (*)=>KeyHistory()

Hotkey "<+#a", (*)=>WinSetAlwaysOnTop(-1, winexist("A"))

VolScroll.Enable()
Hotkey "sc029 & WheelUp", VolScroll.bmonwheelup
Hotkey "sc029 & WheelDown", VolScroll.bmonwheeldown

