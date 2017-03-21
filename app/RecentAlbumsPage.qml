import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

Page {
    id: recentAlbumsPage
    objectName: "newestAlbums"
    property AppResources appResources

    visible: false
    header: PageHeader {
        id: newestAlbumsPageHeader
        title: i18n.tr("Newest Albums")

        leadingActionBar.actions: appResources.menu.actions
    }

    Component.onCompleted: {
        listview.model.source = appResources.getAlbumListUrl("newest");
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
        anchors.top: newestAlbumsPageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        model: XmlListModel {
            namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
            query: "//albumList2/album"
            XmlRole { name: "albumId"; query: "@id/string()" }
            XmlRole { name: "name"; query: "@name/string()" }
            XmlRole { name: "artist"; query: "@artist/string()" }
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
                    (divider.visible?divider.height:0)
            ListItemLayout {
                id: layout
                title.text: model.name
                subtitle.text: model.artist
                summary.text: songCount + (songCount === "1"? " track" : " tracks")
                UbuntuShape {
                    height: appResources.shapeSize
                    width : height
                    radius: "medium"
                    aspect:  UbuntuShape.Inset
                    SlotsLayout.position: SlotsLayout.Leading
                    source: Image {
                            id: imgListItem
                            anchors.fill: parent
                            source: appResources.getCoverArtUrl(model.coverArt,
                                                           imgListItem.height)
                    }
                }
                Icon {
                    height: appResources.iconSize
                    width: height
                    name: "next"
                    SlotsLayout.position: SlotsLayout.Trailing
                }
            }
            onClicked: {
                appResources.currentAlbum = model.name;
                appResources.currentAlbumId = model.albumId;
                pageStack.push(Qt.resolvedUrl("AlbumPage.qml"),
                               {appResources: appResources});
            }
        }
    }
}

