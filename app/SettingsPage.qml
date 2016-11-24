import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: settingsPage
    visible: false
    header : PageHeader {
        id: settingsPageHeader
        title: i18n.tr("uSonic Settings")
        leadingActionBar.actions:backActionList.actions
    }

    property PageStack pageStack
    property Settings settings
    property ActionList backActionList

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
            text: i18n.tr("Server:")
        }
        TextField {
            id: txtServer
            width: parent.width
            text: settings.account.contents.server
        }
        Label{
            text: i18n.tr("Username:")
        }
        TextField {
            id: txtUsername
            text: settings.account.contents.username
        }
        Label{
            text: i18n.tr("Password:")
        }
        TextField {
            id: txtPassword
            text: settings.account.contents.password
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
                strokeColor: UbuntuColors.warmGrey
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
        onResponseChanged: {
            var response = testClient.response;
            if (response.status === "failed") {
                txtArea.text = response.error.message;
            } else {
                txtArea.text = response.status;
            }
        }
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
                    settings.account.contents = {
                        "server" : txtServer.text,
                        "username" : txtUsername.text,
                        "password" : txtPassword.text
                    }
                    settings.settingsUpdated(txtServer.text,
                                             txtUsername.text,
                                             txtPassword.text)
                    pageStack.pop();
                }
            },
            Action {
                id: cancelAction
                name: "cancelAction"
                text: "Cancel"
                onTriggered: {
                    txtServer.text = settings.account.contents.server
                    txtUsername.text = settings.account.contents.username
                    txtPassword.text = settings.account.contents.password

                    pageStack.pop();
                }
            }
        ]
    }
}

