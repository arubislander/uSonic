import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

import "../delegates"

ViewBase {
    id: albumsView
    title: "Albums"

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
        
        readonly property int pageSize : 15
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

    GridView {
        id: listview
        visible: true
        property int minCellWidth : units.gu(20)
        cellWidth: parent.width < minCellWidth ? minCellWidth : parent.width / (Math.round(parent.width / minCellWidth))
        cellHeight: cellWidth

        anchors.fill: parent
        
        model: viewState.sharedListModel
        onAtYEndChanged : {
            if (atYEnd) {
                nextBatch();
            }
        }
        delegate: ListItem {
            id: albumDelegate
            width: listview.cellWidth; height: listview.cellHeight

            Card {
                imageSource: appResources.getCoverArtUrl(model.coverArt,
                                            Math.round(parent.height))
                title: model.name
                subtitle: model.artist
                info: songCount + " " +
                    (songCount === "1"? i18n.tr("track") : i18n.tr("tracks"))

                onClicked: {
                    appResources.currentAlbum = model.name;
                    appResources.currentAlbumId = model.albumId;
                    loader.setSource(Qt.resolvedUrl("AlbumView.qml"))
                }
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