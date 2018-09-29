import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

Page {
    id: mainPage
    property AppResources appResources

    visible: false
    header: PageHeader {
        id: mainPageHeader
        title: "uSonic" + (loader.item.title ? " - " + loader.item.title : "")
        leadingActionBar {
            numberOfSlots: -1
        }
        trailingActionBar {
            numberOfSlots: -1
        }
    }

    Loader {
        id: loader

        anchors {
            top: mainPageHeader.bottom
            bottom: footer.top
            left: parent.left
            right: parent.right
        }
        source: Qt.resolvedUrl("views/WelcomeView.qml")
        onStatusChanged: {
            switch(status) {
                case Loader.Ready:
                    mainPageHeader.leadingActionBar.actions = item.leadingActions.reverse()
                    mainPageHeader.leadingActionBar.numberOfSlots = item.leadingActions.length
                    mainPageHeader.trailingActionBar.actions = item.trailingActions.reverse()
                    mainPageHeader.trailingActionBar.numberOfSlots = item.trailingActions.length
                    if (viewState.sharedListModel) { viewState.sharedListModel.clear() }
                    break;
            }
        }
    }
    
    // footer
    PageHeader {
        id: footer
        objectName: "footer"
        anchors.bottom: parent.bottom
        leadingActionBar { 
            actions : [
                Action {
                    id: settings
                    objectName: "settings"
                    // text: i18n.tr("Settings")
                    iconName: "settings"
                },
                Action {
                    id: now_playing
                    objectName: "now_playing"
                    // text: i18n.tr("Now playing")
                    iconName: "multimedia-player-symbolic"
                    onTriggered: loader.setSource(Qt.resolvedUrl("views/CurrentPlaylistView.qml"))
                },
                Action {
                    id: playlists
                    objectName: "playlists"
                    // text: i18n.tr("Artists")
                    iconName: "media-playlist"
                    onTriggered: loader.setSource(Qt.resolvedUrl("views/PlaylistsView.qml"))
                },
                Action {
                    id: artists
                    objectName: "artists"
                    // text: i18n.tr("Artists")
                    iconName: "contact"
                },
                Action {
                    id: albums
                    objectName: "albums"
                    // text: i18n.tr("Albums")
                    iconName: "media-optical-symbolic"
                    onTriggered: loader.setSource(Qt.resolvedUrl("views/AlbumsView.qml"))
                },
                Action {
                    id: songs
                    objectName: "songs"
                    // text: i18n.tr("Songs")
                    iconName: "stock_music"
                    onTriggered: loader.setSource(Qt.resolvedUrl("views/SongsView.qml"))
                }
            ] 
            numberOfSlots: 6
            delegate: Button {
                action: modelData
                height: footer.height
                width: footer.width/6 - units.gu(0.5)
                strokeColor: UbuntuColors.porcelain
            }
        }
    }

    ActivityIndicator {
        id: activiy
        anchors.centerIn: parent
        running: loader.status == Loader.Loading
    }

    Item {
        id: viewState
        property int viewDepth: 0 // how deep we are inside the view. Used to determine if Back action should be visisble in header
        property bool searching: false
        property string searchText: ""
        property var sharedListModel: searching ? lm1 : lm2 // two list models: One for plain list, the other for search

        ListModel {id: lm1}
        ListModel {id: lm2}
        onSearchingChanged: {
            searchText = "";
            sharedListModel.clear()
        }
    }
    
}