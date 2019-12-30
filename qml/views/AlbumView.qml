import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

ViewBase {
    id: albumView
    title: appResources.currentAlbum

    Component.onCompleted: {
        leadingActions = [ backAction ]
        listview.model.source = appResources.getAlbumUrl(appResources.currentAlbumId);
    }

    Action {
        id: backAction
        iconName: "back"
        text: i18n.tr("Back")
        onTriggered: {
            loader.setSource(Qt.resolvedUrl("AlbumsView.qml"))
        }
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
        
        anchors.fill: parent
        
        model: XmlListModel {
            namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
            query: "//album/song"
            XmlRole { name: "path"; query: "@path/string()"}
            XmlRole { name: "songId"; query: "@id/string()" }
            XmlRole { name: "title"; query: "@title/string()" }
            XmlRole { name: "album"; query: "@album/string()" }
            XmlRole { name: "artist"; query: "@artist/string()" }
            XmlRole { name: "coverArt"; query: "@coverArt/string()" }
            XmlRole { name: "track"; query: "@track/string()"}
        }

        delegate: ListItem {
            height: layout.height +
                    (divider.visible?divider.height:0)
            ListItemLayout {
                id: layout
                title.text: (model.track == "") ? model.title : "#" + model.track + " " + model.title;
                subtitle.text: model.artist
                summary.text: model.album
                UbuntuShape {
                    height: appResources.shapeSize
                    width : height
                    radius: "medium"
                    aspect:  UbuntuShape.Inset
                    SlotsLayout.position: SlotsLayout.Leading
                    source : Image {
                            id: imgListItem
                            anchors.fill: parent
                            source: appResources.getCoverArtUrl(model.coverArt,
                                                           imgListItem.height)
                        }
                }
            }
            onClicked: appResources.addToPlaylist(model, imgListItem.height)
        }
    }
}