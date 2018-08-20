import QtQuick 2.0
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0


Page {
    id: searchPage
    objectName: "search"
    property AppResources appResources

    visible: false
    header: PageHeader {
        id: searchPageHeader
        title: i18n.tr("Search")
        contents: TextField {
                id: searchText
                anchors.centerIn: parent
                width: parent.width
                placeholderText: i18n.tr("search for song or artist")
                action: searchAction
        }

        //leadingActionBar.actions: appResources.menu.actions

        trailingActionBar {
            actions: [

                Action {
                    id: searchAction
                    iconName: "search"
                    text: i18n.tr("Search")
                    onTriggered: {
                        listview.model.source = appResources.getSearchUrl(searchText.text);
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
                    children: [Image {
                            id: imgListItem
                            anchors.fill: parent
                            source: appResources.getCoverArtUrl(model.coverArt,
                                                           imgListItem.height)
                        }]
                }
            }
            onClicked: appResources.addToPlaylist(model)
        }
    }
}
