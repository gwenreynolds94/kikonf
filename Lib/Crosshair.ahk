; Crosshair.ahk

#Requires AutoHotkey v2.0

#Include Gdip\gdijk.ahk

class Crosshair extends Gui {
    gbm := 0x0
    hdc := 0x0
    hbm := 0x0
    gfx := 0x0
    size := 12
    color := "ffccff"
    transparency := "aa"
    bradius := 3
    shown := false
    bmtoggle := ObjBindMethod(this, "Toggle")
    bmincsize := ObjBindMethod(this, "IncreaseSize")
    bmdecsize := ObjBindMethod(this, "DecreaseSize")
    bminctrans := ObjBindMethod(this, "IncreaseTransparency")
    bmdectrans := ObjBindMethod(this, "DecreaseTransparency")

    __New(_transparency := "aa", _color := "ffcfff", _size := 12, _bradius := 3) {
        super.__New("-Caption +AlwaysOnTop +ToolWindow +LastFound +OwnDialogs +E0x80000")
        this.MarginX := 0
        this.MarginY := 0
        this.color := _color
        this.transparency := _transparency
        this.size := _size
        this.bradius := _bradius
    }

    w => this.size
    h => this.size
    x => (A_ScreenWidth / 2) - (this.w / 2)
    y => (A_ScreenHeight / 2) - (this.h / 2)

    openctx(*) {
        this.gbm := CreateDIBSection(this.w, this.h)
        this.hdc := CreateCompatibleDC()
        this.hbm := SelectObject(this.hdc, this.gbm)
        this.gfx := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode this.gfx, 2
    }

    closectx(*) {
        SelectObject this.hdc, this.hbm
        DeleteObject this.hbm
        DeleteDC this.hdc
        Gdip_DeleteGraphics this.gfx
    }

    updatelayeredwindow(*)=>
        UpdateLayeredWindow(this.hwnd, this.hdc, this.x, this.y, this.w, this.h)

    CoordString => "x" this.x " y" this.y " w" this.w " h" this.h

    DrawCircle() {
        this.openctx()
        gbrush := Gdip_BrushCreateSolid(integer("0x" this.transparency this.color))
        Gdip_FillEllipse(this.gfx, gbrush, 1, 1, this.w - 2, this.h - 2)
        Gdip_DeleteBrush gbrush
        this.updatelayeredwindow()
        this.closectx()
    }

    Clear() => Gdip_GraphicsClear(this.gfx)

    Show() {
        static bgdrawn := false
        if !bgdrawn
            this.DrawCircle(),
            bgdrawn := true
        super.Show(this.CoordString " NA")
        this.shown := true
    }

    Hide() {
        super.Hide()
        this.shown := false
    }

    Toggle(*) {
        if not this.shown
            this.show()
        else this.hide()
    }

    IncreaseSize(*) {
        this.size += 2
        if this.shown
            this.DrawCircle()
    }

    DecreaseSize(*) {
        this.size -= 2
        if this.shown
            this.DrawCircle()
    }

    IncreaseTransparency(*) {
        static hexmap := Map( "0", 0, "1", 1, "2", 2, "3", 3, "4", 4,
                              "5", 5, "6", 6, "7", 7, "8", 8, "9", 9,
                                           "a", 10, "b", 11, "c", 12,
                                           "d", 13, "e", 14, "f", 15)
             , decmap := Map( 0, "0", 1, "1", 2, "2", 3, "3", 4, "4",
                              5, "5", 6, "6", 7, "7", 8, "8", 9, "9",
                                           10, "a", 11, "b", 12, "c",
                                           13, "d", 14, "e", 15, "f")
        newdecval := hexmap[SubStr(this.transparency,1,1)] + 1
        newdecval := (newdecval < 16) ? newdecval : 15
        newhexval := decmap[newdecval]
        this.transparency := newhexval newhexval
        if this.shown
            this.DrawCircle()
    }

    DecreaseTransparency(*) {
        static hexmap := Map( "0", 0, "1", 1, "2", 2, "3", 3, "4", 4,
                              "5", 5, "6", 6, "7", 7, "8", 8, "9", 9,
                                           "a", 10, "b", 11, "c", 12,
                                           "d", 13, "e", 14, "f", 15)
             , decmap := Map( 0, "0", 1, "1", 2, "2", 3, "3", 4, "4",
                              5, "5", 6, "6", 7, "7", 8, "8", 9, "9",
                                           10, "a", 11, "b", 12, "c",
                                           13, "d", 14, "e", 15, "f")
        newdecval := hexmap[SubStr(this.transparency,1,1)] - 1
        newdecval := (newdecval >= 0) ? newdecval : 0
        newhexval := decmap[newdecval]
        this.transparency := newhexval newhexval
        if this.shown
            this.DrawCircle()
    }
}

