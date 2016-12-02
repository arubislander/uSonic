import QtQuick 2.4
import QtMultimedia 5.6
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import "utils.js" as Utils


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
                id: recentAlbumNavigateAction
                visible: false
                text: i18n.tr("Newest Albums")
                enabled: pageStack.currentPage.objectName != "newestAlbums"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("RecentAlbumsPage.qml"),
                                   {appResources: res}
                                   );
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

    function getSearchUrl(query) {
        console.log("assembling search url for query:", query);
        var url = Utils.get_search_url(client.appcode,
                                       client.api_version,
                                       client.serverUrl,
                                       client.username,
                                       client.token,
                                       client.salt,
                                       query);
        console.log(url);
        return url;
    }

    function getCoverArtUrl(coverArtId, height) {
        console.log("assembling cover art url for:", coverArtId);
        var url = Utils.get_coverart_url(
                   client.appcode,
                   client.api_version,
                   client.serverUrl,
                   client.username,
                   client.token,
                   client.salt,
                   coverArtId,
                   height);
        console.log(url);
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

    function getAlbumListUrl(type) {
        console.log("assembling recent albums url");
        var url = Utils.get_albumList_url(
                    client.appcode,
                    client.api_version,
                    client.serverUrl,
                    client.username,
                    client.token,
                    client.salt,
                    type);
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
}
