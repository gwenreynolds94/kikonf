; SortedList.ahk

#Requires AutoHotkey v2+

class SortedList extends Array {
    __Item[_index] {
        Get => super[_index]
        Set {
            
        }
    }
    __Sort(*) {
        if !this.Length
            return
    }
}

