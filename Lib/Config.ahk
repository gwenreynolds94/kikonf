; Config.Config.ahk

#Requires AutoHotkey v2.0

#Include FS.ahk

class Config {
    /**
     * @prop {FS.Path} fpath
     */
    fpath := false
    /**
     * @prop {Map} deftree
     */
    deftree := false
    /**
     * @prop {Config.Editor} guieditor
     */
    guieditor := false
    __New(_fpath, _deftree?) {
        this.fpath := FS.Path(_fpath)
        FS.ValidateFile(this.fpath)
        if IsSet(_deftree)
            this.IniValidate(_deftree)
        this.guieditor := Config.Editor(this)
    }
    IniSections() {
        sections := []
        Loop Read this.fpath.str {
            rdln := A_LoopReadLine
            if rdln ~= "^\[\S+\]$"
                sections.Push RegExReplace(rdln, "\]|\[")
        }
        return sections
    }
    IniTree() {
        sectheaders := this.IniSections()
        parsedtree := Map()
        for _header in sectheaders
            parsedtree[_header] := this.IniSection(_header)
        return parsedtree
    }
    IniSection(_section) {
        if !this.HasSection(_section)
            return false
        sectmeat := IniRead(this.fpath.str, _section)
        parsedkeys := Map()
        Loop Parse, sectmeat, "`n", "`r" {
            RegExMatch(A_LoopField, "S)^(?<keyname>[^=]+)=(?<keyval>.*)$", &subpats)
            parsedkeys[subpats.keyname] := subpats.keyval
        }
        return parsedkeys
    }
    IniValidate(_deftree?) {
        deftree := _deftree ?? this.deftree
        if !deftree
            return false
        curtree := this.IniTree()
        for _defsectname, _defsectmeat in deftree {
            if !curtree.has(_defsectname)
                curtree[_defsectname] := Map()
            for _defkeyname, _defkeyvalue in _defsectmeat
                if !curtree[_defsectname].Has(_defkeyname)
                    IniWrite(_defkeyvalue, this.fpath.str, _defsectname, _defkeyname)
        }
        this.deftree := deftree
        return this.IniTree()
    }
    Ini[_section, _key] {
        get => IniRead(this.fpath.str, _section, _key)
        set => IniWrite(Value, this.fpath.str, _section, _key)
    }
    HasSection(_section) {
        sects:=this.IniSections()
        if !sects.Length
            return false
        for _sect in sects
            if _sect = _section
                return true
        return false
    }
    OpenEditor() => this.guieditor.Show()
    class Editor extends Gui {
        /**
         * @prop {Config} cfg
         */
        cfg := false
        cfgtree := Map()
        /**
         * @prop {Gui.Tab} tabctl
         */
        tabctl := false
        tabctltree := Map()
        /**
         * @param {Config} _cfgobj
         */
        __New(_cfgobj) {
            this.cfg := _cfgobj
            super.__New(,, this)
            this.tabctl := this.AddTab3("+Theme -Background")
            ; this.InitTabCtl()
        }
        InitTabCtl() {
            this.cfgtree := this.cfg.IniTree()
            for _newsectname, _newsectmeat in this.cfgtree {
                if !this.tabctltree.Has(_newsectname)
                    this.tabctltree[_newsectname] := Map(),
                    this.tabctl.Add(_newsectname)
                this.tabctl.UseTab(_newsectname, true)
                for _keyname, _keyval in _newsectmeat
                    if !this.tabctltree[_newsectname].Has(_keyname)
                        this.tabctltree[_newsectname][_keyname] := this.AddEdit()
            }
        }
        Update() {
            
        }
    }
}

