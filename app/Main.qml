import QtQuick 2.4
import QtMultimedia 5.6
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
//import Ubuntu.Thumbnailer 0.1

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

    Settings {
        id: settings
    }

    SubsonicClient {
        id: client
        serverUrl: settings.accountDocument.contents.server + "/rest"
        username: settings.accountDocument.contents.username
        password: settings.accountDocument.contents.password
    }


    Audio {
        id: player
        autoPlay : true
        playlist: Playlist {
            id: playlist
        }
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

    ListModel {
        id: playlistModel
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
                            onTriggered: pageStack.push(searchPage)
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
                                pageStack.push(settingsPage)
                            }
                        }
                    ]
                    numberOfSlots: 2
                }
            }

            UbuntuListView {
                id: playlistview
                anchors.top: pageHeader.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                model: playlistModel
                delegate: ListItem {
                    id: playlistItem
                    ListItemLayout {
                        id: playlistlayout
                        title.text: model.title
                        subtitle.text: model.artist + " - " + model.album
                        Shape {
                            height: units.gu(5)
                            width : height
                            SlotsLayout.position: SlotsLayout.Leading
                            children: [Image {
                                    id: imgListItem
                                    anchors.fill: parent
                                    source: model.coverArt
                                }]
                        }
                    }
                    onClicked: {
                        console.log(index);
                        if (playlist.currentIndex !== index)
                            playlist.currentIndex = index

                        if (player.playbackState != Audio.PlayingState)
                            player.play()
                    }
                }
            }
        }

        Page {
            id: searchPage
            visible: false
            header: PageHeader {
                id: searchPageHeader
                contents: TextField {
                    id: searchText
                    anchors {
                        centerIn: parent
                    }
                    width: parent.width
                    verticalAlignment: Text.AlignBottom
                    action: searchAction
                }

                leadingActionBar.actions: backActionList.actions

                trailingActionBar {
                    actions: [
                        Action {
                            id: searchAction
                            iconName: "search"
                            text: i18n.tr("Search")
                            onTriggered: {
                                console.log("Searching on", client.serverUrl, "...");
                                var url = Utils.get_search_url(client.appcode,
                                                               client.api_version,
                                                               client.serverUrl,
                                                               client.username,
                                                               client.token,
                                                               client.salt,
                                                               searchText.text);
                                console.log(url);
                                listview.model.source = url;
                            }
                        }
                    ]
                    numberOfSlots: 1
                }
            }

            UbuntuListView {
                id: listview
                anchors.top: searchPageHeader.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                model: XmlListModel {
                    query: "//searchResult2/song"
                    namespaceDeclarations: "declare default element namespace 'http://subsonic.org/restapi';"
                    XmlRole { name: "songId"; query: "@id/string()" }
                    XmlRole { name: "title"; query: "@title/string()" }
                    XmlRole { name: "album"; query: "@album/string()" }
                    XmlRole { name: "artist"; query: "@artist/string()" }
                    XmlRole { name: "coverArt"; query: "@coverArt/string()" }
                }
                // let refresh control know when the refresh gets completed
                pullToRefresh {
                    enabled: true
                    refreshing: model.status === XmlListModel.Loading
                    onRefresh: {
                        model.reload();
                    }
                }
                delegate: ListItem {
                    ListItemLayout {
                        id: layout
                        title.text: model.title
                        subtitle.text: model.artist + " - " + model.album
                        Shape {
                            height: units.gu(5)
                            width : height
                            SlotsLayout.position: SlotsLayout.Leading
                            children: [Image {
                                    id: imgListItem
                                    anchors.fill: parent
                                    source: Utils.get_coverart_url(client.appcode,
                                                                   client.api_version,
                                                                   client.serverUrl,
                                                                   client.username,
                                                                   client.token,
                                                                   client.salt,
                                                                   model.coverArt,
                                                                   imgListItem.height)
                                }]
                        }
                    }
                    onClicked: {
                        var url = Utils.get_stream_Url(client.appcode,
                                                       client.api_version,
                                                       client.serverUrl,
                                                       client.username,
                                                       client.token,
                                                       client.salt,
                                                       model.songId)

                        var coverart = Utils.get_coverart_url(client.appcode,
                                                              client.api_version,
                                                              client.serverUrl,
                                                              client.username,
                                                              client.token,
                                                              client.salt,
                                                              model.coverArt,
                                                              imgListItem.height)
                        console.log(url);
                        playlistModel.append({"title":model.title,
                                             "album":model.album,
                                             "artist":model.artist,
                                             "coverArt":coverart})
                        playlist.addItem(url)
                        if (player.playbackState != Audio.PlayingState) {
                            playlist.currentIndex = playlist.itemCount - 1
                            player.play()
                        }
                    }
                }
            }
        }

        Page {
            id: settingsPage
            visible: false
            header : PageHeader {
                id: settingsPageHeader
                title: i18n.tr("uSonic Settings")
                leadingActionBar.actions:backActionList.actions
            }


            Column {

                spacing: units.gu(2)
                anchors {
                    margins: units.gu(2)

                    top: settingsPageHeader.bottom
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width - units.gu(4)

                Label{
                    text: "Server:"
                }
                TextField {
                    id: txtServer
                    width: parent.width
                    text: settings.accountDocument.contents.server
                }
                Label{
                    text: "Username :"
                }
                TextField {
                    id: txtUsername
                    text: settings.accountDocument.contents.username
                }
                Label{
                    text: "Password :"
                }
                TextField {
                    id: txtPassword
                    text: settings.accountDocument.contents.password
                    echoMode: TextInput.Password
                }

                Row {
                    id: buttonsRow
                    spacing: units.gu(3)
                    Button {
                        strokeColor: UbuntuColors.warmGrey
                        action: pingAction
                    }
                    Button {
                        color: UbuntuColors.red
                        action: saveAction
                    }
                    Button {
                        color: UbuntuColors.green
                        action: cancelAction
                    }
                }

                TextArea {
                    id: txtArea
                    width: parent.width
                    text: testClient.response
                }
            }

            SubsonicClient{
                id: testClient
                serverUrl: txtServer.text + "/rest"
                username: txtUsername.text
                password: txtPassword.text
                onReady: {
                    console.debug("result", testClient.response)
                }
                onResponseChanged: txtArea.text = testClient.response
            }

            ActionList {
                actions: [
                    Action {
                        id: pingAction
                        name: "pingAction"
                        text: "Test"
                        onTriggered: {
                            testClient.password = txtPassword.text
                            testClient.ping()
                        }
                    },
                    Action {
                        id: saveAction
                        name: "saveAction"
                        text: "Save"
                        onTriggered: {
                            settings.accountDocument.contents = {
                                "server" : txtServer.text,
                                "username" : txtUsername.text,
                                "password" : txtPassword.text
                            }
                            pageStack.pop();
                        }
                    },
                    Action {
                        id: cancelAction
                        name: "cancelAction"
                        text: "Cancel"
                        onTriggered: {
                            txtServer.text = settings.accountDocument.contents.server
                            txtUsername.text = settings.accountDocument.contents.username
                            txtPassword.text = settings.accountDocument.contents.password

                            pageStack.pop();
                        }
                    }
                ]
            }
        }
    }
}

