; Ducky.ahk

#Requires AutoHotkey v2+

#Include Globals.ahk

Class Ducky {
    static _encodings_ := Map(
        /**
        " ", "+",
        "%", "%25",
        "+", "%2B",
        ",", "%2C",
        "/", "%2F",
        "\", "%5C",
        "#", "%23",
        "$", "%24",
        "&", "%26",
        "<", "%3c",
        ">", "%3e",
        "{", "%7b",
        "}", "%7d",
        "|", "%7c",
        "^", "%5e",
        "~", "%7e",
        "[", "%5b",
        "]", "%5d",
        "'", "%27",
        "`"", "%22",
        "``", "%60",
        */
    ), SearchFromClipboard := ObjBindMethod(Ducky, "__SearchFromClipboard")

    static Encode(_url) {
        for char, code in this._encodings_
            _url := StrReplace(_url, char, code)
        return _url
    }

    static GetSearchURL(_search) {
        return "https://www.duckduckgo.com/?q=" StrReplace(_search, "`"", "\`"")
    }

    static __SearchFromClipboard(*) {
        Run(_G.browser " `"" this.GetSearchURL(A_Clipboard) "`"")
    }
}

