import QtQuick 2.4
import QtMultimedia 5.6
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0

import "utils.js" as Utils

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "usonic.arubislander"

    width: units.gu(50)
    height: units.gu(75)

    SubsonicClient {
        id: client
        settings: Settings {
            onSettingsUpdated: {
                client.serverUrl = server + "/rest"
                client.username = username
                client.password = password
            }
        }
    }

    Playlist {
        id: playlist
        onCurrentIndexChanged: playlistview.currentIndex = playlist.currentIndex
        onItemCountChanged: {
            if (player.playbackState == Audio.StoppedState) {
                //playlist.currentIndex = playlist.itemCount - 1
                player.play()
            }
        }
    }

    Audio {
        id: player
        autoPlay : true
        playlist: playlist
    }

    ListModel {
        id: playlistModel
    }

    ActionList {
        id: backActionList
        actions: [
            Action {
                visible: pageStack.depth > 1 ? true : false
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: {
                    if (pageStack.depth > 1)
                        pageStack.pop()
                }
            }
        ]
    }

    PageStack {
        id: pageStack
        Component.onCompleted: pageStack.push(mainPage)
        Page {

            id: mainPage
            visible: false

            header: PageHeader {
                id: pageHeader
                title: i18n.tr("uSonic")
                trailingActionBar {
                    actions: [
                        Action {
                            id: searchNavigateAction
                            iconName: "search"
                            text: i18n.tr("Search")
                            onTriggered: pageStack.push(Qt.resolvedUrl("SearchPage.qml"),
                                                        {
                                                            backActions:backActionList,
                                                            client: client,
                                                            playlist: playlist,
                                                            playlistModel: playlistModel
                                                        })
                        },
                        Action {
                            id: clearPlaylistAction
                            iconName: "clear"
                            text: i18n.tr("Clear")
                            onTriggered: {
                                console.log("Clearing playlist")
                                playlist.clear()
                                playlistModel.clear()
                            }
                        },
                        Action {
                            id: settingsNavigateAction
                            iconName: "settings"
                            text: i18n.tr("Settings")
                            onTriggered: {
                                console.log("Activating settings screen")
                                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
                                               {
                                                   pageStack: pageStack,
                                                   backActionList: backActionList,
                                                   settings: client.settings
                                               })
                            }
                        }
                    ]
                    numberOfSlots: 2
                }
            }

            ListItemActions {
                id: playlistLeadingItemActions
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            console.log(value)
                            var index = value
                            playlist.removeItem(index)
                            playlistModel.remove(index)
                        }
                    }]
            }

            UbuntuListView {
                id: playlistview
                anchors.top: pageHeader.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                model: playlistModel
                delegate: ListItem {
                    id: playlistItem
                    leadingActions: playlistLeadingItemActions
                    ListItemLayout {
                        id: playlistlayout
                        title.text: model.title
                        subtitle.text: model.artist + " - " + model.album
                        Shape {
                            height: units.gu(5)
                            width : height
                            SlotsLayout.position: SlotsLayout.Leading
                            children: [Image {
                                    //id: imgListItem
                                    anchors.fill: parent
                                    source: model.coverArt
                                }]
                        }
                    }
                    onClicked: {
                        console.log(index);
                        if (playlist.currentIndex != index)
                            playlist.currentIndex = index

                        if (player.playbackState != Audio.PlayingState)
                            player.play()
                    }
                    //color: dragMode ? "lightblue" : "lightgray"
                    onPressAndHold: ListView.view.ViewItems.dragMode =
                                    !ListView.view.ViewItems.dragMode
                }
                ViewItems.onDragUpdated: {
                    if (event.status == ListItemDrag.Started) {
                        return;
                    } else if (event.status == ListItemDrag.Dropped) {
                        playlistModel.move(event.from, event.to, 1)
                        playlist.moveItem(event.from, event.to)
                    } else {
                        event.accept = false;
                    }
                }
            }
        }

    }
}

