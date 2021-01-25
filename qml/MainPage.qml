import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

Page {
    id: mainPage
    property AppResources appResources

    property Action lastAction
    property Action selectedAction
    property Action tmp : selectedAction

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
                    property bool selected : false;
                    objectName: "settings"
                    // text: i18n.tr("Settings")
                    iconName: "settings"
                    onTriggered: selectedAction = this
                },
                Action {
                    id: filler
                    enabled: false
                },
                Action {
                    id: now_playing
                    property bool selected : false;
                    objectName: "now_playing"
                    // text: i18n.tr("Now playing")
                    iconName: "multimedia-player-symbolic"
                    onTriggered: selectedAction = this
                },
                Action {
                    id: playlists
                    property bool selected : false;
                    objectName: "playlists"
                    // text: i18n.tr("Artists")
                    iconName: "media-playlist"
                    onTriggered: selectedAction = this
                },
                Action {
                    id: artists
                    property bool selected : false;
                    objectName: "artists"
                    // text: i18n.tr("Artists")
                    iconName: "contact"
                    visible: false
                },
                Action {
                    id: albums
                    property bool selected : false;
                    objectName: "albums"
                    // text: i18n.tr("Albums")
                    iconName: "media-optical-symbolic"
                    onTriggered: selectedAction = this
                },
                Action {
                    id: songs
                    property bool selected : false;
                    objectName: "songs"
                    // text: i18n.tr("Songs")
                    iconName: "stock_music"
                    onTriggered: selectedAction = this
                }
            ] 
            numberOfSlots: 6
            delegate: Button {
                action: modelData
                height: footer.height
                width: modelData.enabled ? footer.width/6 - units.gu(0.5) : footer.width/5 - units.gu(1)
                //textColor: modelData.selected ? theme.palette.foreground.selected : theme.palette.foreground.base
                color: modelData.selected ? theme.palette.normal.selection: theme.palette.normal.background //UbuntuColors.lightGrey : UbuntuColors.porcelain
                //strokeColor: UbuntuColors.porcelain
            }
        }
    }

    onSelectedActionChanged: {
        lastAction = tmp;
        tmp = selectedAction;
        if (lastAction != null)
            lastAction.selected= false;
        selectedAction.selected = true;
        switch (selectedAction.objectName) {
            case "settings": 
                loader.setSource(Qt.resolvedUrl("views/SettingsView.qml"));
                break;
            case "now_playing":
                loader.setSource(Qt.resolvedUrl("views/CurrentPlaylistView.qml"));
                break;
            case "playlists":
                loader.setSource(Qt.resolvedUrl("views/PlaylistsView.qml"));
                break;
            case "albums":
                loader.setSource(Qt.resolvedUrl("views/AlbumsView.qml"));
                break;
            case "songs":
                loader.setSource(Qt.resolvedUrl("views/SongsView.qml"));
                break;            
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