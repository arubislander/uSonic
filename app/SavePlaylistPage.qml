import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: settingsPage
    visible: false
    header : PageHeader {
        id: pageHeader
        title: i18n.tr("Save Playlist")
    }

    property AppResources appResources

    Column {

        spacing: units.gu(2)
        anchors {
            margins: units.gu(2)

            top: pageHeader.bottom
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        width: parent.width - units.gu(4)

        Label{
            text: i18n.tr("Name:")
        }

        TextField {
            id: txtPlaylistName
            width: parent.width
            text: appResources.currentPlaylist
            placeholderText: "enter playlist name"
            action: saveAction
        }

        Row {
            id: buttonsRow
            spacing: parent.width - (btnCancel.width + btnSave.width)

            Button {
                id:btnCancel
                color: UbuntuColors.red
                action: cancelAction
            }

            Button {
                id:btnSave
                color: UbuntuColors.green
                action: saveAction
            }
        }
    }

    ActionList {
        actions: [
            Action {
                id: saveAction
                name: "saveAction"
                text: "Save"
                enabled : txtPlaylistName.text.trim() != ""
                onTriggered: {
                    if (appResources.currentPlaylistId)
                        appResources.removePlaylist(appResources.currentPlaylistId);

                    var songIds = [];
                    for (var i=0; i< appResources.playlistModel.count; i++) {
                        songIds.push(appResources.playlistModel.get(i).songId);
                    }

                    appResources.createPlaylist(txtPlaylistName.text,
                                                songIds, function(response){
                                                    console.log(appResources.currentPlaylistId);
                                                    if (response.status === "ok") {
                                                        if (response.version >= "1.14.0")
                                                            appResources.currentPlaylistId = response.playlist.id;
                                                        appResources.currentPlaylist = txtPlaylistName.text;
                                                        appResources.dirty = false;

                                                        pageStack.pop();
                                                    }
                    });
                }
            },
            Action {
                id: cancelAction
                name: "cancelAction"
                text: "Cancel"
                onTriggered: {
                    pageStack.pop();
                }
            }
        ]
    }
}

