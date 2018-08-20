import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

ViewBase{
    id: playlistsView

    Component.onCompleted: {
        listview.model.source = appResources.getPlaylistsUrl();
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
        anchors.fill: parent
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
                summary.text: songCount + " " +
                    (songCount === "1" ? i18n.tr("track") : i18n.tr("tracks"))
                UbuntuShape {
                    height: appResources.shapeSize
                    width : height
                    radius: "medium"
                    aspect:  UbuntuShape.Inset
                    SlotsLayout.position: SlotsLayout.Leading
                    source: Image {
                            id: imgListItem
                            anchors.fill: parent
                            source: appResources.getCoverArtUrl(
                                        model.coverArt,
                                        imgListItem.height)
                        }
                }
            }

            onClicked: {
                appResources.currentPlaylist   = model.name;
                appResources.currentPlaylistId = model.playlistId;
                appResources.dirty = false;
                appResources.itemsView.query = "//playlist/entry"
                appResources.itemsView.source =
                        appResources.getPlaylistUrl(model.playlistId);

                loader.setSource(Qt.resolvedUrl("CurrentPlaylistView.qml"))
            }
        }
    }
}