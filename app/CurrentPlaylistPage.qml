import QtQuick 2.4
import QtMultimedia 5.6
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.XmlListModel 2.0

Page {
    id: currentPlaylistPage
    visible: false
    objectName: "currentPlaylist"
    property AppResources appResources

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Current Playlist")
        leadingActionBar.actions: appResources.menu.actions
        trailingActionBar {
            actions: [

                Action {
                    id: settingsNavigateAction
                    iconName: "settings"
                    text: i18n.tr("Settings")
                    enabled: pageStack.currentPage.objectName != "settings"
                    onTriggered: {
                        //pageStack.clear();
                        pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
                                       {appResources: appResources})
                    }
                },
                Action {
                    id: clearPlaylistAction
                    iconName: "clear"
                    enabled: appResources.playlistModel.count > 0
                    text: i18n.tr("Clear")
                    onTriggered: {
                        if (appResources.dirty) {
                            // show dialog warning user that playlist has not
                            // been saved.
                            PopupUtils.open(confirmClearDialog)
                        } else {
                            clearPlaylist();
                        }
                    }
                },
                Action {
                    id: saveAction
                    iconName: "save"
                    enabled: appResources.dirty
                    text: i18n.tr("Save ...")
                    onTriggered: {
                        if (!appResources.currentPlaylistId)
                            PopupUtils.open(saveDialog);
                        else if (appResources.dirty) {
                            PopupUtils.open(confirmOverwriteDialog);
                        }
                    }
                },
                Action{
                    id: searchNavigateAction
                    iconName: "search"
                    text: i18n.tr("Search")
                    onTriggered: {
                        pageStack.push(Qt.resolvedUrl("SearchPage.qml"),
                                                {appResources: appResources})
                    }
                }
            ]
            numberOfSlots: 4
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
                    appResources.playlist.removeItem(index)
                    appResources.playlistModel.remove(index)
                    appResources.dirty = true;
                }
            }]
    }

    Action {
        id: dialogSaveAction
        name: "saveAction"
        text: "Save"
        onTriggered: {
        }
    }


    UbuntuListView {
        id: playlistview
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        model: appResources.playlistModel

        Component.onCompleted: {
            appResources.playlist.playlistView = playlistview;
        }

        delegate: ListItem {
            id: playlistItem
            leadingActions: playlistLeadingItemActions
            height: layout.height +
                    (divider.visible?divider.height:0)
            ListItemLayout {
                id: layout
                title.text: model.title
                subtitle.text: model.album
                summary.text: model.artist
                UbuntuShape {
                    height: appResources.shapeSize
                    width : height
                    radius: "medium"
                    aspect:  UbuntuShape.Inset
                    SlotsLayout.position: SlotsLayout.Leading
                    source: Image {
                            anchors.fill: parent
                            source: model.coverArt
                        }
                }
            }
            onClicked: {
                console.log(index);
                if (appResources.playlist.currentIndex != index)
                    appResources.playlist.currentIndex = index

                if (appResources.player.playbackState != Audio.PlayingState)
                    appResources.player.play()
            }
            //color: dragMode ? "lightblue" : "lightgray"
            onPressAndHold: ListView.view.ViewItems.dragMode =
                            !ListView.view.ViewItems.dragMode
        }
        ViewItems.onDragUpdated: {
            if (event.status == ListItemDrag.Started) {
                return;
            } else if (event.status == ListItemDrag.Dropped) {
                appResources.playlistModel.move(event.from, event.to, 1)
                appResources.playlist.moveItem(event.from, event.to)
            } else {
                event.accept = false;
            }
        }
    }

    Component {
            id: confirmOverwriteDialog
            Dialog {
                id: overwriteDialogue
                title: "Overwrite playlist: " + appResources.currentPlaylist
                text: "Are you sure that you want to overrite?"
                Button {
                    text: "Overwrite"
                    color: UbuntuColors.red
                    onClicked: {
                        if (appResources.currentPlaylistId)
                            appResources.removePlaylist(appResources.currentPlaylistId);

                        var songIds = [];
                        for (var i=0; i< appResources.playlistModel.count; i++) {
                            songIds.push(appResources.playlistModel.get(i).songId);
                        }

                        appResources.createPlaylist(appResources.currentPlaylist,
                                                    songIds, null);
                        appResources.dirty = false;

                        PopupUtils.close(overwriteDialogue)

                    }
                }
                Button {
                    text: "Cancel"
                    color: UbuntuColors.green
                    onClicked: PopupUtils.close(overwriteDialogue)
                }
            }
       }

    Component {
            id: confirmClearDialog
            Dialog {
                id: clearDialogue
                title: "Clear playlist"
                text: "There are unsaved changes, clear anyway?"
                Button {
                    text: "Yes"
                    color: UbuntuColors.green
                    onClicked: {
                        clearPlaylist();
                        PopupUtils.close(clearDialogue)
                    }
                }
                Button {
                    text: "No"
                    color: UbuntuColors.red
                    onClicked: PopupUtils.close(clearDialogue)
                }
            }
       }

    Component {
            id: saveDialog
            Dialog {
                id: saveDialogue
                title: "Save playlist"
                TextField {
                    id: txtPlaylistName
                    width: parent.width
                    placeholderText: "enter playlist name"
                    //action: dialogSaveAction
                    //onTextChanged: appResources.currentPlaylist = txtPlaylistName.text.trim()
                }
                Button {
                    text: "Save"
                    color: UbuntuColors.green
                    enabled: txtPlaylistName.text != ""
                    onClicked: {
                        if (appResources.currentPlaylistId)
                            appResources.removePlaylist(appResources.currentPlaylistId);

                        var songIds = [];
                        for (var i=0; i< appResources.playlistModel.count; i++) {
                            songIds.push(appResources.playlistModel.get(i).songId);
                        }

                        appResources.createPlaylist(txtPlaylistName.text,
                                                    songIds, function(response){
                                                        if (response.status === "ok") {
                                                            if (response.version >= "1.14.0")
                                                                appResources.currentPlaylistId = response.playlist.id;
                                                            appResources.dirty = false;
                                                            appResources.currentPlaylist = txtPlaylistName.text;
                                                        }
                        });
                        PopupUtils.close(saveDialogue);
                    }
                }
                Button {
                    text: "Cancel"
                    color: UbuntuColors.red
                    onClicked: PopupUtils.close(saveDialogue)
                }
            }
       }

    function clearPlaylist() {
        console.log("Clearing playlist")
        appResources.playlist.clear()
        appResources.playlistModel.clear()
        appResources.dirty = false;
        appResources.currentPlaylist = "";
        appResources.currentPlaylistId = "";
    }
}
