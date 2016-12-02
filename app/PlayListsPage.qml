import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

Page {
    id: playlistsPage
    objectName: "playlists"
    property AppResources appResources

    visible: false
    header: PageHeader {
        id: playlistsPageHeader
        title: i18n.tr("PlayLists")

        leadingActionBar.actions: appResources.menu.actions
    }

    Component.onCompleted: {
        listview.model.source = appResources.getPlaylistsUrl();
    }

    /*
        <subsonic-response xmlns="http://subsonic.org/restapi" status="ok" version="1.11.0">
            <playlists>
                <playlist id="15"
                name="Some random songs"
                comment="Just something I tossed together"
                owner="admin"
                public="false" songCount="6"
                duration="1391"
                created="2012-04-17T19:53:44"
                coverArt="pl-15">
                    <allowedUser>sindre</allowedUser>
                    <allowedUser>john</allowedUser>
                </playlist>
                <playlist id="16" name="More random songs" comment="No comment" owner="admin" public="true" songCount="5" duration="1018" created="2012-04-17T19:55:49" coverArt="pl-16"/>
            </playlists>
        </subsonic-response>
    */

    XmlListModel {
        id: itemsView
        namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
        query: "//playlist/entry"
        XmlRole { name: "songId"; query: "@id/string()" }
        XmlRole { name: "title"; query: "@title/string()" }
        XmlRole { name: "album"; query: "@album/string()" }
        XmlRole { name: "artist"; query: "@artist/string()" }
        XmlRole { name: "coverArt"; query: "@coverArt/string()" }

        onStatusChanged: {
            if (itemsView.status == XmlListModel.Ready) {
                appResources.playlistModel.clear();
                appResources.playlist.clear();

                for (var i=0; i < itemsView.count; i++) {
                    var item = itemsView.get(i);

                    var url = appResources.getStreamUrl(item.songId)
                    var coverart = appResources.getCoverArtUrl(item.coverArt,
                                                               appResources.shapeSize);

                    appResources.playlistModel.append({
                         "songId": item.songId,
                         "playlistIndex": appResources.playlist.itemCount,
                         "title":item.title,
                         "album":item.album,
                         "artist":item.artist,
                         "coverArt":coverart})

                    appResources.playlist.addItem(url)
                }
            }
        }
    }

    ListItemActions {
        id: playlistLeadingItemActions
        actions: [
            Action {
                iconName: "delete"
                onTriggered: {
                    console.log(value)
                    var item = listview.model.get(value);
                    appResources.removePlaylist(item.playlistId);
                    listview.model.reload();
                }
            }]
    }

    UbuntuListView {
        id: listview
        anchors.top: playlistsPageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        model: XmlListModel {
            namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
            query: "//playlists/playlist"
            XmlRole { name: "playlistId"; query: "@id/string()" }
            XmlRole { name: "name"; query: "@name/string()" }
            XmlRole { name: "comment"; query: "@comment/string()" }
            XmlRole { name: "songCount"; query: "@songCount/string()" }
            XmlRole { name: "coverArt"; query: "@coverArt/string()" }
        }

        // let refresh control know when the refresh gets completed
        pullToRefresh {
            enabled: true
            refreshing: model.status === XmlListModel.Loading
            onRefresh: {
                model.reload();
            }
        }

        delegate: ListItem {

            height: layout.height +
                    (divider.visible ? divider.height : 0)

            leadingActions: playlistLeadingItemActions

            ListItemLayout {
                id: layout
                title.text: model.name
                subtitle.text: model.comment
                summary.text: songCount + (songCount === "1" ? " song" : " songs")
                Shape {
                    height: appResources.shapeSize
                    width : height
                    SlotsLayout.position: SlotsLayout.Leading
                    children:
                        [Image {
                            id: imgListItem
                            anchors.fill: parent
                            source: appResources.getCoverArtUrl(
                                        model.coverArt,
                                        imgListItem.height)
                        }]
                }
            }

            onClicked: {
                appResources.currentPlaylist   = model.name;
                appResources.currentPlaylistId = model.playlistId;
                appResources.dirty = false;

                itemsView.source = appResources.getPlaylistUrl(model.playlistId);
            }
        }
    }
}

