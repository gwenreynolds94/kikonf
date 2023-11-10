; WinVis.ahk

#Requires AutoHotkey v2+

class WinVis {
    static opacity_steps := OrderedDigits(75, 125, 150, 180, 210, 230, 245, 255)
         , NextStepActive := ObjBindMethod(WinVis, "NextStep", "A")
         , PrevStepActive := ObjBindMethod(WinVis, "PrevStep", "A")
    static NextStep(_wintitle:="A", *) {
        wHwnd := winexist(_wintitle)
        if !wHwnd
            return
        current_opacity := WinGetTransparent(wHwnd)
        if current_opacity is String
            current_opacity := 255
        nearest_index := this.NearestStepIndex(current_opacity)
        nearest_opacity := this.opacity_steps[nearest_index]
        use_next_index := !!(nearest_opacity <= current_opacity)
        new_index := nearest_index + Integer(use_next_index)
        new_index := (new_index > this.opacity_steps.Length) ? 1 : new_index
        new_opacity := this.opacity_steps[new_index]
        WinSetTransparent(new_opacity, wHwnd)
    }
    static PrevStep(_wintitle:="A", *) {
        wHwnd := winexist(_wintitle)
        if !wHwnd
            return
        current_opacity := WinGetTransparent(wHwnd)
        if current_opacity is String
            current_opacity := 255
        nearest_index := this.NearestStepIndex(current_opacity)
        nearest_opacity := this.opacity_steps[nearest_index]
        use_prev_index := !!(nearest_opacity >= current_opacity)
        new_index := nearest_index - Integer(use_prev_index)
        new_index := (new_index < 1) ? this.opacity_steps.Length : new_index
        new_opacity := this.opacity_steps[new_index]
        WinSetTransparent(new_opacity, wHwnd)
    }
    static NearestStepIndex(_opacity) {
        shortest_distance := 256
        nearest_index := 0
        for _opacity_index, _opacity_step in this.opacity_steps
            if (step_distance := Abs(_opacity - _opacity_step)) < shortest_distance
                shortest_distance := step_distance, nearest_index := _opacity_index
        return nearest_index
    }
}

class OrderedDigits extends Array {
    __New(_digits*) {
        this.Push(_digits*)
    }
    Push(_digits*) {
        super.Push(_digits*)
        this.__Sort()
    }
    RemoveDigit(_digit) {
        digit_index := false
        for _index, _value in this
            digit_index := (_value = _digit) and _index
        if !!digit_index
            this.RemoveAt(digit_index)
    }
    __Sort(*) {
        if !this.Length
            return
        joined_digits := String(this[1])
        loop (this.Length - 1)
            joined_digits .= "`n" . this[A_Index+1]
        sorted_joined_digits := Sort(joined_digits, "N U D`n")
        sorted_digits := StrSplit(sorted_joined_digits, "`n")
        this.RemoveAt(1, this.Length)
        for _index, _digit in sorted_digits
            super.Push(Number(_digit))
    }
}

