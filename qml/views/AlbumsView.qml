import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

ViewBase {
    id: albumsView

    Component.onCompleted: {
        leadingActions = [cancelSearch]
        trailingActions = [searchNavigateAction, searchAction]
        mainPageHeader.contents = Qt.binding(function(){return viewState.searching ? searchTextField : null})
    }

    Action{
        id: searchNavigateAction
        iconName: "search"
        visible: !viewState.searching
        text: i18n.tr("Search")
        onTriggered: {
            viewState.searching = true;
        }
    }

    Action {
        id: cancelSearch
        visible: viewState.searching
        iconName: "close"
        text: i18n.tr("Cancel")
        onTriggered: {
            viewState.searching = false;
            resetBatch()
        }
    }

    Action {
        id: searchAction
        visible: viewState.searching
        iconName: "find"
        text: i18n.tr("Find")
        onTriggered: {
            listview.model.clear()
            resetBatch()
        }
    }

    TextField {
        id: searchTextField
        visible: viewState.searching
        anchors.centerIn: parent
        width: parent.width
        placeholderText: i18n.tr("search for album name")
        action: searchAction

        onTextChanged: {
            viewState.searchText = text
        }

        Component.onCompleted: {
            text = viewState.searchText
        }
    }

    XmlListModel {
        id: albumListBuffer
        
        readonly property int pageSize : 10
        property int currentPage : 0;
        property bool isLastPage : false;

        namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
        query: "//album"
        XmlRole { name: "albumId"; query: "@id/string()" }
        XmlRole { name: "name"; query: "@name/string()" }
        XmlRole { name: "artist"; query: "@artist/string()" }
        XmlRole { name: "songCount"; query: "@songCount/string()" }
        XmlRole { name: "coverArt"; query: "@coverArt/string()" }

        onStatusChanged: {
            if (source == "") return
            isLastPage = count < pageSize
            if (status == XmlListModel.Ready && count > 0) {
                for (var i=0; i<count; i++) {
                    listview.model.append(get(i))
                }
            }
        }
    }

    UbuntuListView {
        id: listview
        anchors.fill: parent
        model: viewState.sharedListModel
        onAtYEndChanged : {
            if (atYEnd) {
                nextBatch();
            }
        }
        delegate: ListItem {
            height: layout.height +
                    (divider.visible?divider.height:0)
            
            trailingActions: ListItemActions {
              id: songListItemActions
              actions: [
                Action {
                  id: addToPlaylist
                  iconName: "add-to-playlist"
                  text: i18n.tr("Play album")
                  onTriggered: {
                    appResources.clearPlaylist()
                    appResources.itemsView.query = "//album/song"
                    appResources.itemsView.source =
                            appResources.getAlbumUrl(model.albumId);
                  }
                }
              ]
            }

            ListItemLayout {
                id: layout
                title.text: model.name
                subtitle.text: model.artist
                summary.text: songCount + " " +
                    (songCount === "1"? i18n.tr("track") : i18n.tr("tracks"))
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
                loader.setSource(Qt.resolvedUrl("AlbumView.qml"))
            }
        }
    }

    // functions
    function resetBatch() {
        albumListBuffer.isLastPage = false;
        albumListBuffer.currentPage = 0;
        nextBatch();
    } // resetBatch

    function nextBatch() {
        if (!albumListBuffer.isLastPage) {
            albumListBuffer.source=""
            if (viewState.searching) {
                albumListBuffer.source = appResources.getSearchUrl("album", 
                            albumListBuffer.currentPage, 
                            albumListBuffer.pageSize, 
                            searchTextField.text + "*");
            } else {
                albumListBuffer.source = appResources.getAlbumListUrl("newest", albumListBuffer.currentPage, albumListBuffer.pageSize);
            }
            console.debug("currentPage: ", albumListBuffer.currentPage, "pageSize: ", albumListBuffer.pageSize)
            ++albumListBuffer.currentPage
        }
    } // nextBatch

}