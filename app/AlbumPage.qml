import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

Page {
    id: recentAlbumsPage
    property AppResources appResources


    visible: false
    header: PageHeader {
        id: recentAlbumsPageHeader
        title: appResources.currentAlbum

        //leadingActionBar.actions: appResources.backActions.actions
    }

    Component.onCompleted: {
        listview.model.source = appResources.getAlbumUrl(appResources.currentAlbumId);
    }

    /*

<subsonic-response xmlns="http://subsonic.org/restapi" status="ok" version="1.8.0">
    <albumList2>
        <album id="1768"
               name="Duets"
               coverArt="al-1768"
               songCount="2"
               created="2002-11-09T15:44:40"
               duration="514"
               artist="Nik Kershaw"
               artistId="829"/>
    </albumList2>
</subsonic-response>
    */

    UbuntuListView {
        id: listview
        anchors.top: recentAlbumsPageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        model: XmlListModel {
            namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
            query: "//album/song"
            XmlRole { name: "songId"; query: "@id/string()" }
            XmlRole { name: "title"; query: "@title/string()" }
            XmlRole { name: "album"; query: "@album/string()" }
            XmlRole { name: "artist"; query: "@artist/string()" }
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
                    (divider.visible?divider.height:0)
            ListItemLayout {
                id: layout
                title.text: model.title
                subtitle.text: model.artist
                summary.text: model.album
                Shape {
                    height: appResources.shapeSize
                    width : height
                    SlotsLayout.position: SlotsLayout.Leading
                    Image {
                            id: imgListItem
                            anchors.fill: parent
                            source: appResources.getCoverArtUrl(model.coverArt,
                                                           imgListItem.height)
                        }
                }
            }
            onClicked: {
                var url = appResources.getStreamUrl(model.songId)
                var coverart = appResources.getCoverArtUrl(model.coverArt,
                                                           imgListItem.height)

                appResources.playlistModel.append({
                     "songId" : model.songId,
                     "playlistIndex": appResources.playlist.itemCount,
                     "title":model.title,
                     "album":model.album,
                     "artist":model.artist,
                     "coverArt":coverart})

                appResources.playlist.addItem(url)
                appResources.dirty = true;
            }
        }
    }
}

