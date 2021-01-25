import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

ViewBase {
    id: settingsView
    title: i18n.tr("Settings")



    function clientReady() {
        console.debug("result", appResources.client.response)
    }

    function clientResponseChanged() {
        var response = appResources.client.response;
        if (response.status === "failed") {
            txtArea.text = response.error.message;
        } else {
            txtArea.text = response.status;
        }
    }

    Component.onCompleted: {
        appResources.client.ready.connect(clientReady)
        appResources.client.responseChanged.connect(clientResponseChanged)
    }

    Component.onDestruction: {
        console.debug("destroying the settings view")
        appResources.client.responseChanged.disconnect(clientResponseChanged)
        appResources.client.ready.disconnect(clientReady)

        appResources.client.revertSettings()
    }
    

 Column {

        spacing: units.gu(2)
        anchors {
            margins: units.gu(2)

            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        width: parent.width - units.gu(4)

        UbuntuShape {
            width: (parent.height > parent.width ? parent.width : parent.height) / 3
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: Image {
                source: Qt.resolvedUrl("../../assets/uSonic.png")
            }
        }

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
                action: cancelAction
            }

            Button {
                id: btnPing
                //strokeColor: UbuntuColors.warmGrey
                action: pingAction
            }

            Button {
                id: btnSave
                color: theme.palette.normal.positive
                action: saveAction
            }
        }

        Rectangle {
            width: parent.width
            height: units.gu(5)
            color: theme.palette.normal.base
            radius: units.gu(1)
            TextArea {
                id: txtArea
                anchors.fill: parent
                readOnly: true
                //text: appResources.client.response ? appResources.client.response : ""
            }
        }
    }

    ActionList {
        actions: [
            Action {
                id: pingAction
                name: "pingAction"
                text: i18n.tr("Test")
                onTriggered: {
                    appResources.client.password = txtPassword.text
                    appResources.client.ping()
                }
            },
            Action {
                id: saveAction
                name: "saveAction"
                text: i18n.tr("Apply")
                onTriggered: {
                    appResources.client.applySettings(txtServer.text,
                                             txtUsername.text,
                                             txtPassword.text)
                }
            },
            Action {
                id: cancelAction
                name: "cancelAction"
                text: i18n.tr("Revert")
                onTriggered: {
                    appResources.client.revertSettings()
                    txtServer.text = appResources.client.settings.account.contents.server
                    txtUsername.text = appResources.client.settings.account.contents.username
                    txtPassword.text = appResources.client.settings.account.contents.password
                }
            }
        ]
    }
}