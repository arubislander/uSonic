import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtQuick.XmlListModel 2.0

ViewBase {
    id: welcomeView
    Column {
        anchors.centerIn: parent
        width: parent.width - units.gu(10)
        height: parent.height - units.gu(10)
        spacing: units.gu(2)
        Image {
            width: (parent.height > parent.width ? parent.width : parent.height) / 3
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: Qt.resolvedUrl("../../assets/uSonic.png")
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            textSize: Label.Large
            text: i18n.tr("Welcome to uSonic")
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: i18n.tr("uSonic is the first native client to the Subsonic music server.")
        }
    }
}