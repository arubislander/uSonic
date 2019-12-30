import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

ViewBase {
    id: currentPlayListView
    title: appResources.currentPlaylist

    Component.onCompleted: {
        leadingActions = []
        trailingActions = [saveAction, clearPlaylistAction]
    }

    // Actions
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
    }

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

    UbuntuListView {
        id: playlistview
        anchors.fill: parent
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
                //title.text: model.title
                title.text: (model.track == "") ? model.title : "#" + model.track + " " + model.title;
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
            title: i18n.tr("Overwrite playlist: ") + appResources.currentPlaylist
            text: i18n.tr("Are you sure that you want to overrite?")
            Button {
                text: i18n.tr("Overwrite")
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
                text: i18n.tr("Cancel")
                color: UbuntuColors.green
                onClicked: PopupUtils.close(overwriteDialogue)
            }
        }
    }

    Component {
        id: confirmClearDialog
        Dialog {
            id: clearDialogue
            title: i18n.tr("Clear playlist")
            text: i18n.tr("There are unsaved changes, clear anyway?")
            Button {
                text: i18n.tr("Yes")
                color: UbuntuColors.green
                onClicked: {
                    clearPlaylist();
                    PopupUtils.close(clearDialogue)
                }
            }
            Button {
                text: i18n.tr("No")
                color: UbuntuColors.red
                onClicked: PopupUtils.close(clearDialogue)
            }
        }
    }

    Component {
        id: saveDialog
        Dialog {
            id: saveDialogue
            title: i18n.tr("Save playlist")
            TextField {
                id: txtPlaylistName
                width: parent.width
                placeholderText: i18n.tr("enter playlist name")
                //action: dialogSaveAction
                //onTextChanged: appResources.currentPlaylist = txtPlaylistName.text.trim()
            }
            Button {
                text: i18n.tr("Save")
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
                        }
                    );
                    PopupUtils.close(saveDialogue);
                }
            }
            Button {
                text: i18n.tr("Cancel")
                color: UbuntuColors.red
                onClicked: PopupUtils.close(saveDialogue)
            }
        }
    }

    function clearPlaylist() {
        appResources.clearPlaylist()
    }
}