; Globals.ahk

#Requires AutoHotkey v2+

#Include QuikTool.ahk

Class _G {
    static gamemode := false
         , browser := _G.GetDefaultBrowserCommand()

    static GetDefaultBrowserCommand(*) {
        ProgID := RegRead( "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\" .
                              "Explorer\FileExts\.html\UserChoice", "ProgID" )
        ShellOpenCMD := RegRead( "HKCR\" ProgID "\shell\open\command" )
        ShellOpenCMD := StrReplace(ShellOpenCMD, " -osint -url `"%1`"")
        return ShellOpenCMD
    }

    static Toggle(_variable, _showtooltip, *) {
        if !this.HasProp(_variable)
            return
        this.%_variable% := !this.%_variable%
        if _showtooltip
            QuikTool(_variable ": " ( !this.%_variable% ? "false" : "true" ))
    }

    static Cycle(_variable, _values, _showtooltip, *) {
        if !this.HasProp(_variable)
            return
        currentvalue := this.%_variable%, currentindex := 0
        loop (_values.Length)
            if currentvalue = _values[A_Index]
                currentindex := A_Index
        nextvalue := _values[(Mod(currentindex+1, _values.Length)+1)]
        this.%_variable% := nextvalue
        if _showtooltip
            QuikTool(_variable ": " ( !this.%_variable% ? "false" : "true" ))
    }

    static cbToggle(_variable, _showtooltip:=true) => ObjBindMethod(_G, "Toggle", _variable, _showtooltip)
    static cbCycle(_variable, _values, _showtooltip:=true) => ObjBindMethod(_G, "Toggle", _variable, _values, _showtooltip)
}

