import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

ViewBase {
    id: songView
    
    title: i18n.tr("Songs")

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
        placeholderText: i18n.tr("search for song or artist name")
        action: searchAction

        onTextChanged: {
            viewState.searchText = text
        }

        Component.onCompleted: {
            text = viewState.searchText
        }
    }

    XmlListModel {
        id: listBuffer
        
        readonly property int pageSize : 10
        property int currentPage : 0;
        property bool isLastPage : false;

        namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
        query: "//song"
        XmlRole { name: "songId"; query: "@id/string()" }
        XmlRole { name: "title"; query: "@title/string()" }
        XmlRole { name: "album"; query: "@album/string()" }
        XmlRole { name: "artist"; query: "@artist/string()" }
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

    // functions
    function resetBatch() {
        listBuffer.isLastPage = false;
        listBuffer.currentPage = 0;
        nextBatch();
    } // resetBatch

    function nextBatch() {
        if (!listBuffer.isLastPage) {
            listBuffer.source=""
            if (viewState.searching) {
                listBuffer.source = appResources.getSearchUrl("song", 
                            listBuffer.currentPage, 
                            listBuffer.pageSize, 
                            searchTextField.text + "*");
            } else {
                listBuffer.source = appResources.getRandomSongsUrl(listBuffer.pageSize);
            }
            console.debug("currentPage: ", listBuffer.currentPage, "pageSize: ", listBuffer.pageSize)
            ++listBuffer.currentPage
        }
    } // nextBatch

}