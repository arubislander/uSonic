import QtQuick 2.4
import QtMultimedia 5.6
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "utils.js" as Utils
import "usonic.js" as UsonicJS


Object {
    id: res

    property string currentAlbumId
    property string currentAlbum
    property string currentSongId
    property string currentSong
    property string currentPlaylistId
    property string currentPlaylist
    property bool dirty : false

    readonly property int shapeSize : units.gu(7);
    readonly property int iconSize: units.gu(2);

    readonly property ActionList menu : ActionList { actions : [
            Action{
                id: currentPlaylistNavigateAction
                text: i18n.tr("Current Playlist")
                enabled: pageStack.currentPage.objectName != "currentPlaylist"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("CurrentPlaylistPage.qml"),
                                   {appResources: res}
                                   );
                }
            },
            Action{
                id: playlistNavigateAction
                text: i18n.tr("Playlists")
                enabled: pageStack.currentPage.objectName != "playlists"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("PlayListsPage.qml"),
                                   {appResources: res}
                                   );
                }
            },
            Action{
                id: favouriteAlbumNavigateAction
                visible: false
                text: i18n.tr("Favourite Albums")
                enabled: pageStack.currentPage.objectName != "favouriteAlbums"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("AlbumsPage.qml"),
                                   {
                                     objectName: "favouriteAlbums",
                                     appResources: res,
                                     title: "Favourite Albums",
                                     type: "starred"
                                   });
                }
            },
            Action{
                id: newestAlbumNavigateAction
                //visible: false
                text: i18n.tr("Newest Albums")
                enabled: pageStack.currentPage.objectName != "newestAlbums"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("AlbumsPage.qml"),
                                   {
                                     objectName: "newestAlbums",
                                     appResources: res,
                                     title: "Newest Albums",
                                     type: "newest"
                                   });
                }
            },
            Action{
                id: randomAlbumNavigateAction
                text: i18n.tr("Random Albums")
                enabled: pageStack.currentPage.objectName != "randomAlbums"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("AlbumsPage.qml"),
                                   {
                                     objectName: "randomAlbums",
                                     appResources: res,
                                     title: "Random Albums",
                                     type: "random"
                                   });
                }
            },
            Action{
                id: recentAlbumNavigateAction
                text: i18n.tr("Recent Albums")
                enabled: pageStack.currentPage.objectName != "recentAlbums"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("AlbumsPage.qml"),
                                   {
                                     objectName: "recentAlbums",
                                     appResources: res,
                                     title: "Recent Albums",
                                     type: "recent"
                                   });
                }
            }
        ]}
    readonly property SubsonicClient client : SubsonicClient {
        id: client
        settings: Settings {
            onSettingsUpdated: {
                client.serverUrl = server + "/rest"
                client.username = username
                client.password = password
            }
        }

    }
    readonly property ListModel playlistModel : ListModel { }
    readonly property Audio player :Audio {
        id: player
        autoPlay : true
        playlist: playlist
    }
    readonly property Playlist playlist : Playlist {
        property ListView playlistView : null
        id: playlist
        onCurrentIndexChanged: {
            if (playlist.playlistView != null) {
                playlist.playlistView.currentIndex = playlist.currentIndex
            }
        }
        onItemCountChanged: {
            if (player.playbackState == Audio.StoppedState) {
                //playlist.currentIndex = playlist.itemCount - 1
                player.play()
            }
        }
    }
    readonly property XmlListModel itemsView : XmlListModel {
        id: itemsView
        namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
        //query: "//playlist/entry"
        XmlRole { name: "songId"; query: "@id/string()" }
        XmlRole { name: "title"; query: "@title/string()" }
        XmlRole { name: "album"; query: "@album/string()" }
        XmlRole { name: "artist"; query: "@artist/string()" }
        XmlRole { name: "coverArt"; query: "@coverArt/string()" }

        onStatusChanged: {
            if (itemsView.status == XmlListModel.Ready) {
                res.playlistModel.clear();
                res.playlist.clear();

                for (var i=0; i < itemsView.count; i++) {
                    var item = itemsView.get(i);
                    res.addToPlaylist(item)
                }
            }
        }
    }

    function clearPlaylist() {
        console.log("Clearing playlist")
        UsonicJS.clearQueue();
        res.playlist.clear();
        res.playlistModel.clear();
        res.dirty = false;
        res.currentPlaylist = "";
        res.currentPlaylistId = "";
    }
    function addToPlaylist (model) {
      var url = res.getStreamUrl(model.songId);
      var coverart = res.getCoverArtUrl(model.coverArt, res.shapeSize);
      UsonicJS.addToQueue(model.songId);
    
      res.playlistModel.append({
           "songId" : model.songId,
           "playlistIndex": res.playlist.itemCount,
           "title":model.title,
           "album":model.album,
           "artist":model.artist,
           "coverArt":coverart});

      res.playlist.addItem(url);
      res.dirty = true;
    }
    function getRandomSongsUrl(pageSize) {
        console.log("assembing random songs url");
        var url = Utils.get_random_songs_url(client.appcode,
            client.api_version,
            client.serverUrl,
            client.username,
            client.token,
            client.salt,
            pageSize);
        console.log(url);
        return url;
    }

    function getSearchUrl(type, pageNum, pageSize, query) {
        console.log("assembling search url for query:", query);
        var url;
        switch(type) {
            case "album":
                url = Utils.get_search_album_url(client.appcode,
                                            client.api_version,
                                            client.serverUrl,
                                            client.username,
                                            client.token,
                                            client.salt,
                                            pageNum * pageSize,
                                            pageSize,
                                            query);
                break;
            case "artist":
                url = Utils.get_search_artist_url(client.appcode,
                                            client.api_version,
                                            client.serverUrl,
                                            client.username,
                                            client.token,
                                            client.salt,
                                            pageNum * pageSize,
                                            pageSize,
                                            query);
                break;
            case "song":
                url = Utils.get_search_song_url(client.appcode,
                                            client.api_version,
                                            client.serverUrl,
                                            client.username,
                                            client.token,
                                            client.salt,
                                            pageNum * pageSize,
                                            pageSize,
                                            query);
                break;
        }
        console.log(url);
        return url;
    }

    function getCoverArtUrl(coverArtId, height) {
        //console.log("assembling cover art url for:", coverArtId);
        if (coverArtId === "" || coverArtId === null || coverArtId === undefined)
            return "../../assets/coverArt.png";

        var item = UsonicJS.getCoverArt(coverArtId);
        console.debug ("retrieved coverart: " + item + ", for " + coverArtId );

        if (item ) {
            console.debug("* Found in cache!");
            return item.path;
        }
        var url = Utils.get_coverart_url(
                   client.appcode,
                   client.api_version,
                   client.serverUrl,
                   client.username,
                   client.token,
                   client.salt,
                   coverArtId,
                   height);

        //downloader.downloadQueue.push({
        // downloader.download({
        //     "type": "CoverArt",
        //     "id": coverArtId,
        //     "url": url,
        //     "title": coverArtId
        // }, false);

        //console.log(url);
        return url;
    }
    function getStreamUrl(songId) {
        console.log("assembling stream url for: ", songId);
        var url = Utils.get_stream_Url(
                   client.appcode,
                   client.api_version,
                   client.serverUrl,
                   client.username,
                   client.token,
                   client.salt,
                   songId);
        console.log(url);
        return url;
    }
    function getPlaylistsUrl() {
        console.log("assembling playlists url");
        var url = Utils.get_playlists_url(
                    client.appcode,
                    client.api_version,
                    client.serverUrl,
                    client.username,
                    client.token,
                    client.salt);
        console.log(url);
        return url;
    }
    function getPlaylistUrl(playlistId) {
        console.log("assembling playlist url");
        var url = Utils.get_playlist_url(
                    client.appcode,
                    client.api_version,
                    client.serverUrl,
                    client.username,
                    client.token,
                    client.salt,
                    playlistId);
        console.log(url);
        return url;
    }
    function getAlbumListUrl(type, pageNum, pageSize) {
        console.log("assembling " + type + " albums url");
        var url = Utils.get_albumList_url(
                    client.appcode,
                    client.api_version,
                    client.serverUrl,
                    client.username,
                    client.token,
                    client.salt,
                    type, pageNum*pageSize, pageSize);
        console.log(url);
        return url;
    }
    function getAlbumUrl(albumId) {
        console.log("assembling album url");
        var url = Utils.get_album_url(
                    client.appcode,
                    client.api_version,
                    client.serverUrl,
                    client.username,
                    client.token,
                    client.salt,
                    albumId);
        console.log(url);
        return url;
    }

    function createPlaylist(name, songIds, callback) {
        console.log("creating playlist");
        var url = Utils.create_playlist_url(
                    client.appcode,
                    client.api_version,
                    client.serverUrl,
                    client.username,
                    client.token,
                    client.salt,
                    name,
                    songIds);
        console.log(url);
        Utils.webclient_get(url, callback)
    }
    
    function removePlaylist(playlistId, callback) {
        console.log("removing playlist");
        var url = Utils.delete_playlist_url(
                    client.appcode,
                    client.api_version,
                    client.serverUrl,
                    client.username,
                    client.token,
                    client.salt,
                    playlistId);
        console.log(url);
        Utils.webclient_get(url, callback)
    }

    Downloader {
        id: downloader
    }


}
