import QtQuick 2.0
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0
import "utils.js" as Utils


Page {
    id: searchPage
    property ActionList backActions
    property SubsonicClient client
    property Playlist playlist
    property ListModel playlistModel

    visible: false
    header: PageHeader {
        id: searchPageHeader
        contents: TextField {
            id: searchText
            anchors {
                centerIn: parent
            }
            width: parent.width
            verticalAlignment: Text.AlignBottom
            action: searchAction
        }

        leadingActionBar.actions: backActions.actions

        trailingActionBar {
            actions: [
                Action {
                    id: searchAction
                    iconName: "search"
                    text: i18n.tr("Search")
                    onTriggered: {
                        console.log("Searching on", client.serverUrl, "...");
                        var url = Utils.get_search_url(client.appcode,
                                                       client.api_version,
                                                       client.serverUrl,
                                                       client.username,
                                                       client.token,
                                                       client.salt,
                                                       searchText.text);
                        console.log(url);
                        listview.model.source = url;
                    }
                }
            ]
            numberOfSlots: 1
        }
    }

    UbuntuListView {
        id: listview
        anchors.top: searchPageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        model: XmlListModel {
            query: "//searchResult2/song"
            namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
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
            ListItemLayout {
                id: layout
                title.text: model.title
                subtitle.text: model.artist + " - " + model.album
                Shape {
                    height: units.gu(5)
                    width : height
                    SlotsLayout.position: SlotsLayout.Leading
                    children: [Image {
                            id: imgListItem
                            anchors.fill: parent
                            source: Utils.get_coverart_url(client.appcode,
                                                           client.api_version,
                                                           client.serverUrl,
                                                           client.username,
                                                           client.token,
                                                           client.salt,
                                                           model.coverArt,
                                                           imgListItem.height)
                        }]
                }
            }
            onClicked: {
                var url = Utils.get_stream_Url(client.appcode,
                                               client.api_version,
                                               client.serverUrl,
                                               client.username,
                                               client.token,
                                               client.salt,
                                               model.songId)

                var coverart = Utils.get_coverart_url(client.appcode,
                                                      client.api_version,
                                                      client.serverUrl,
                                                      client.username,
                                                      client.token,
                                                      client.salt,
                                                      model.coverArt,
                                                      imgListItem.height)
                console.log(url);
                playlistModel.append({"playlistIndex": playlist.itemCount,
                                     "title":model.title,
                                     "album":model.album,
                                     "artist":model.artist,
                                     "coverArt":coverart})
                playlist.addItem(url)
            }
        }
    }
}

