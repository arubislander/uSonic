import QtQuick 2.4
import Ubuntu.Components 0.1
import Ubuntu.OnlineAccounts.Plugin 1.0

Flickable {
    id: root

    signal finished

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: account.accountId != 0 ? existingAccountComponent : newAccountComponent

        Connections {
            target: loader.item
            onFinished: root.finished()
        }
    }

    Component {
        id: newAccountComponent
        NewAccount {}
    }

    Component {
        id: existingAccountComponent
        EditAccount{}
    }
}

