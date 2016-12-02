import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: settingsPage
    objectName: "settings"
    visible: false
    header : PageHeader {
        id: settingsPageHeader
        title: i18n.tr("uSonic Settings")
        leadingActionBar.actions: appResources.menu.actions
    }

    property AppResources appResources

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
            text: appResources.client.settings.account.contents.server
        }

        Label{
            text: i18n.tr("Username:")
        }

        TextField {
            id: txtUsername
            text: appResources.client.settings.account.contents.username
        }

        Label{
            text: i18n.tr("Password:")
        }

        TextField {
            id: txtPassword
            text: appResources.client.settings.account.contents.password
            echoMode: TextInput.Password
        }

        Row {
            id: buttonsRow
            spacing: (parent.width - (btnCancel.width + btnPing.width + btnSave.width))/2

            Button {
                id: btnCancel
                color: UbuntuColors.green
                action: cancelAction
            }

            Button {
                id: btnPing
                strokeColor: UbuntuColors.warmGrey
                action: pingAction
            }

            Button {
                id: btnSave
                strokeColor: UbuntuColors.warmGrey
                action: saveAction
            }
        }

        TextArea {
            id: txtArea
            width: parent.width
            text: testClient.response ? testClient.response : ""
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
                    appResources.client.settings.account.contents = {
                        "server" : txtServer.text,
                        "username" : txtUsername.text,
                        "password" : txtPassword.text
                    }
                    appResources.client.settings.settingsUpdated(txtServer.text,
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
                    txtServer.text = appResources.client.settings.account.contents.server
                    txtUsername.text = appResources.client.settings.account.contents.username
                    txtPassword.text = appResources.client.settings.account.contents.password

                    pageStack.pop();
                }
            }
        ]
    }
}

