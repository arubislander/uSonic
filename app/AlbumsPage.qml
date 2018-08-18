import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

Page {
    id: albumsPage
    //objectName: "albums"
    property AppResources appResources
    property string title
    property string type

    visible: false
    header: PageHeader {
        id: newestAlbumsPageHeader
        title: albumsPage.title

        leadingActionBar.actions: appResources.menu.actions
    }

    Component.onCompleted: {
        //albumListBuffer.pageSize = listview.height/units.gu(5)+1
        console.log("pageSize: ", albumListBuffer.pageSize)
        albumListBuffer.nextBatch()
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

    XmlListModel {
        id: albumListBuffer
        
        property int pageSize : albumsPage.height/units.gu(8)+1
        property int currentPage : -1;
        property bool isLastPage : false;

        signal nextBatch()

        namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
        query: "//albumList2/album"
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

        onNextBatch: {
            if (!isLastPage) {
                source=""
                currentPage++
                source = appResources.getAlbumListUrl(albumsPage.type, currentPage, pageSize);
                console.debug("currentPage: ", currentPage)
            }
        }
    }

    UbuntuListView {
        id: listview
        anchors.top: newestAlbumsPageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        model: ListModel {}
        // let refresh control know when the refresh gets completed
        // pullToRefresh {
        //     enabled: true
        //     refreshing: model.status === XmlListModel.Loading
        //     onRefresh: {
        //         model.reload();
        //     }
        // }
        onAtYEndChanged : {
            if (atYEnd) {
                albumListBuffer.nextBatch();
            }
        }
        // onAtYBeginningChanged: {
        //     if (atYBeginning && pageNum > 0) {
        //         pageNum--
        //         console.debug("PageNum: ", pageNum)
        //         albumListBuffer.source = appResources.getAlbumListUrl(albumsPage.type, pageNum, pageSize);
        //     }
        // }
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
                pageStack.push(Qt.resolvedUrl("AlbumPage.qml"),
                               {appResources: appResources});
            }
        }
    }
    Rectangle {
        id: waitComponent
        //color: ""
        anchors.centerIn: parent
        height: units.gu(5)
        width: units.gu(15)
        border.color: "black" 
        border.width: 1
        radius: units.gu(1)
        antialiasing: true
        visible: albumListBuffer.status !== XmlListModel.Ready
        Label {
            anchors.centerIn: parent
            text: "Please wait ..."
        }
    }
}
