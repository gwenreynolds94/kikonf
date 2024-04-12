; HexDec.ahk

#Requires AutoHotkey v2.0

#Include Debug.ahk

class HexDec {
        static hexmap := Map( "0", 0, "1", 1, "2",  2, "3",  3, "4",  4,
                              "5", 5, "6", 6, "7",  7, "8",  8, "9",  9,
                                              "a", 10, "b", 11, "c", 12,
                                              "d", 13, "e", 14, "f", 15)
             , decmap := Map()
        static __New() {
            for _hex, _dec in this.hexmap
                this.decmap.Set(_dec, _hex)
            debug this.hexmap
            debug this.decmap
        }
        ; newdecval := hexmap[SubStr(this.transparency,1,1)] + 1
        ; newhexval := decmap[newdecval]
}

class Dec2Hex {

}

class Hex2Dec {

}

