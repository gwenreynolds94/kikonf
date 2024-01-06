; Creds.ahk

#Requires AutoHotkey v2+

class Creds {
    static active := "Default"
         , User := { name: "", password: "" }
    static __New(*) {
        if not (FileExist("C:\Users\" A_UserName "\.cache\.creds\user\username") and
                FileExist("C:\Users\" A_UserName "\.cache\.creds\user\password"))
            return
        wshell := ComObject("WScript.Shell")
        pwsh := wshell.Exec("pwsh.exe -nol -nop -w hidden")
        pwsh.StdIn.WriteLine(
                "$ahkusername = ConvertFrom-SecureString -AsPlainText -SecureString "
              . "(gc C:\Users\" A_UserName "\.cache\.creds\user\username | ConvertTo-SecureString -Key (1..16))"
              . "`n"
              . "$ahkpassword = ConvertFrom-SecureString -AsPlainText -SecureString "
              . "(gc C:\Users\" A_UserName "\.cache\.creds\user\password | ConvertTo-SecureString -Key (1..16))"
              . "`n"
              . "echo `"$(`"username:`" + $ahkusername + `"``npassword:`" + $ahkpassword)`""
              . "`n"
              . "exit"
        )
        pwsh_stdout := pwsh.StdOut.ReadAll()
        Creds.User.name := (RegExMatch(pwsh_stdout, "(?<=(?<!\S)username:)(.+)", &_uname), _uname[1])
        Creds.User.password := (RegExMatch(pwsh_stdout, "(?<=(?<!\S)password:)(.+)", &_upass), _upass[1])
    }
    static HasUserCreds => (!!Creds.User.name and !!Creds.User.password)
    static RunAsUser(*) => Creds.HasUserCreds and (Creds.active := "User", RunAs(Creds.User.name, Creds.User.password))
    static RunAsDefault(*) => (Creds.active := "Default", RunAs())
    static ToggleRunAs(*) => ( (Creds.active = "Default") ? Creds.RunAsUser() : Creds.RunAsDefault()
                             , ToolTip("RunAs: " Creds.active)
                             , SetTimer((*)=>Tooltip(), -1500) )
    static RegisterUser(*) {
        username_input := InputBox(,"Enter Username", "w300 h80")
        if username_input.Result != "OK" or !username_input.Value
            return
        password_input := InputBox(,"Enter Password", "w300 h80 Password")
        if password_input.Result != "OK" or !password_input.Value
            return
        if not DirExist("C:\Users\" A_UserName "\.cache\.creds\user")
            DirCreate("C:\Users\" A_UserName "\.cache\.creds\user")
        wshell := ComObject("WScript.Shell")
        pwsh := wshell.Exec("pwsh.exe -nol -nop -w hidden")
        pwsh.StdIn.WriteLine( "ConvertTo-SecureString '" username_input.Value "' -AsPlainText "
                            . "| ConvertFrom-SecureString -Key (1..16) "
                            . "| Set-Content -Force -Path C:\Users\" A_UserName "\.cache\.creds\user\username"
                            . "`n"
                            . "ConvertTo-SecureString '" password_input.Value "' -AsPlainText "
                            . "| ConvertFrom-SecureString -Key (1..16) "
                            . "| Set-Content -Force -Path C:\Users\" A_UserName "\.cache\.creds\user\password"
                            . "`n"
                            . "exit"
        )
        Creds.User.name := username_input.Value
        Creds.User.password := password_input.Value
    }
}
