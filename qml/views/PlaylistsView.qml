import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

import "../delegates"

ViewBase{
    id: playlistsView

    title: i18n.tr("Playlists")

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

    GridView {
        id: listview
        visible: true
        property int minCellWidth : units.gu(20)
        cellWidth: parent.width < minCellWidth ? minCellWidth : parent.width / (Math.round(parent.width / minCellWidth))
        cellHeight: cellWidth

        anchors.fill: parent
        model: XmlListModel {
            namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
            query: "//playlists/playlist"
            XmlRole { name: "playlistId"; query: "@id/string()" }
            XmlRole { name: "name"; query: "@name/string()" }
            XmlRole { name: "comment"; query: "@comment/string()" }
            XmlRole { name: "songCount"; query: "@songCount/string()" }
            XmlRole { name: "coverArt"; query: "@coverArt/string()" }
            XmlRole { name: "track"; query: "@track/string()"}
        }

        // let refresh control know when the refresh gets completed
        // pullToRefresh {
        //     enabled: true
        //     refreshing: model.status === XmlListModel.Loading
        //     onRefresh: {
        //         model.reload();
        //     }
        // }

        delegate: ListItem {

            width: listview.cellWidth; height: listview.cellHeight

            leadingActions: playlistLeadingItemActions

            Card {
                
                imageSource: appResources.getCoverArtUrl(model.coverArt,
                                            Math.round(parent.height))
                title: model.name
                subtitle: model.comment
                info: model.songCount + " " +
                    (model.songCount === "1"? i18n.tr("track") : i18n.tr("tracks"))

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
}