; iCtrl.ahk

#Requires AutoHotkey v2.0

#Include Debug.ahk

class iCtrl {
    class ITEnum {
        static __Item[_field] {
            Get {
                for _fieldname, _fieldval in this.OwnProps() {
                    if SubStr(_fieldname, 1, 2) == "__"
                        continue
                    if _fieldval = _field
                        return _fieldname
                    if _fieldname ~= ("i)" _field)
                        return _fieldval
                }
            }
        }
    }
    class ITPlaylistSearchField extends iCtrl.ITEnum {
        static All       := 0
             , Visible   := 1
             , Artists   := 2
             , Albums    := 3
             , Composers := 4
             , SongNames := 5
    }
    class ITPlaylistRepeatMode extends iCtrl.ITEnum {
        static Off := 0
             , One := 1
             , All := 2
    }
    class IDCachedPlaylist {
        playlistID := false
        _ITObject := false
        __New(_ITObject_or_playlistID, _persist:=false) {
            if IsNumber(_ITObject_or_playlistID) 
                this.playlistID := _ITObject_or_playlistID
            else this.playlistID := _ITObject_or_playlistID.playlistID
            if _persist
                this._ITObject := this.ITObject
        }
        PlayFirstTrack(*) => this.ITObject.PlayFirstTrack()
        ITObject => this._ITObject or iCtrl.app.GetITObjectById(iCtrl.app.LibrarySource.sourceID, this.playlistID, 0, 0)
    }
    static app := false
    static isConnected => !!this.app && !!this.app.Windows
    static Connect(*) {
        if !this.isConnected
            this.app := ComObject("iTunes.Application.1")
        return WinWait("ahk_exe iTunes.exe",, 10)
    }
    static Disconnect(*) => (this.app := "")
    static Play(*) => this.isConnected && this.app.Play()
    static Stop(*) => this.isConnected && this.app.Stop()
    static Pause(*) => this.isConnected && this.app.Pause()
    static PlayPause(*) => this.isConnected && this.app.PlayPause()
    static NextTrack(*) => this.isConnected && this.app.NextTrack()
    static PreviousTrack(*) => this.isConnected && this.app.PreviousTrack()
    static Rewind(*) => this.isConnected && this.app.Rewind()
    static FastForward(*) => this.isConnected && this.app.FastForward()
    static Shuffle {
        Get => this.isConnected
            && this.app.CanSetShuffle(this.app.CurrentPlaylist)
            && !!this.app.CurrentPlaylist.Shuffle
        Set => this.isConnected
            && this.app.CanSetShuffle(this.app.CurrentPlaylist)
            && this.app.CurrentPlaylist.Shuffle := !!Value
    }
    static RepeatMode {
        Get => this.isConnected
            && this.app.CanSetSongRepeat(this.app.CurrentPlaylist)
            && this.app.CurrentPlaylist.SongRepeat
        Set => this.isConnected
            && this.app.CanSetSongRepeat(this.app.CurrentPlaylist)
            && this.app.CurrentPlaylist.SongRepeat := Value
    }
    static LibraryPlaylist => this.isConnected && this.app.LibraryPlaylist
    static CurrentPlaylist => this.isConnected && this.app.CurrentPlaylist
    static CurrentTrack => this.isConnected && this.app.CurrentTrack
    static GetAllPlaylists(*) => this.isConnected && this.app.LibrarySource.Playlists
    static FindPlaylist(_name_regex) {
        if !this.isConnected
            return false
        playlists := this.GetAllPlaylists()
        for _pl in playlists
            if _pl.Name ~= _name_regex
                return _pl
    }
    static Search(_searchstring, _fieldtype:="songnames") {
        if !this.isConnected
            return false
        searchfieldtype := iCtrl.ITPlaylistSearchField.SongNames
        for _searchfieldname, _searchfieldval in ObjOwnProps(iCtrl.ITPlaylistSearchField)
            if _searchfieldname != "__Init" and !!InStr(_searchfieldname, _fieldtype)
                searchfieldtype := _searchfieldval
        return this.app.LibraryPlaylist.Search(_searchstring, searchfieldtype)
    }
    static SearchBySongName(_songname) {
        if !this.isConnected
            return false
        return this.Search("songnames")
    }
    static SearchByArtist(_artist) {
        if !this.isConnected
            return false
        return this.Search("artist")
    }
    static SearchByAlbum(_album) {
        if !this.isConnected
            return false
        return this.Search("album")
    }
    static Quit(*) {
        if !this.isConnected
            return false
        this.app.Quit()
    }
}


