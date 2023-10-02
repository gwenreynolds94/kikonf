; FS.FS.ahk

#Requires AutoHotkey v2.0

class FS {
    static ValidateFile(_fpath, _rootcap?, _initcontent?) {
        fpath := FS.Path(_fpath)
        if fpath.IsFile()
            return true
        if fpath.IsDir()
            return false
        if !this.ValidateDir(fpath.Parent, _rootcap?)
            return false
        FileAppend _initcontent ?? "", fpath.str, "UTF-8"
    }
    static ValidateDir(_fdir, _rootcap?) {
        fdir := FS.Path(_fdir)
        if fdir.IsDir()
            return true
        rootcap := FS.Path(_rootcap ?? "C:\Users\" A_UserName)
        if !!rootcap and !fdir.HasParent(rootcap)
            return false
        fparts := fdir.GetParts()
        tpath := fparts[1]
        loop fparts.Length - 1 {
            fpindex := A_Index + 1
            tpath .= "\" fparts[fpindex]
            if !FileExist(tpath) and !DirExist(tpath)
                DirCreate(tpath)
        }
        return fdir.IsDir()
    }
    class Path {
        str := ""
        __New(_path, _normalize:=true) {
            this.str := (_path is FS.Path) ? _path.str : _path
            if _normalize
                this.Normalize()
        }
        Exists() => !!FileExist(this.str)
        GetParts() => FS.Path.GetParts(this)
        HasParent(_path) => FS.Path.HasParent(this, _path)
        HasChild(_path) => FS.Path.HasChild(this, _path)
        Parent => (SplitPath(this.str,,&_parent), _parent)
        IsDir() => !!DirExist(this.str)
        IsFile() => this.Exists() and !this.IsDir()
        Normalized => FS.Path.Normalize(this.str)
        Normalize() => (this.str := this.Normalized)
        static GetParts(_path) {
            _path := (_path is FS.Path) ? _path.str : _path
            Return StrSplit(_path, ["\", "/"])
        }
        static HasParent(_child, _parent) {
            childparts := FS.Path.GetParts(_child)
            parentparts := FS.Path.GetParts(_parent)
            Loop parentparts.Length
                if parentparts[A_Index] != childparts[A_Index]
                    return false
            return true
        }
        static HasChild(_parent, _child) {
            return FS.Path.HasParent(_child, _parent)
        }
        static Normalize(_path) {
            tchars := DllCall("GetFullPathName", "str", _path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
            pathnamebuf := Buffer(tchars * 2)
            DllCall "GetFullPathName", "str", _path, "uint", tchars, "ptr", pathnamebuf, "ptr", 0
            Return StrGet(pathnamebuf)
        }
    }
    ; static NormalizePath() {}
}

