import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: card
    anchors.fill: parent
    property alias imageSource: coverArt.source
    property alias title: primaryLabel.text
    property alias subtitle: secondaryLabel.text
    property alias info: tertiaryLabel.text
    
    signal clicked(var mouse)
    signal pressAndHold(var mouse)

    UbuntuShape {
        id: shape
        anchors.margins: units.gu(.5)
        anchors.fill : parent
        source: Image {
            id: coverArt
        }

        MouseArea {
            id: cardMouseArea
            anchors.fill: parent
            onClicked: card.clicked(mouse)
            onPressAndHold: card.pressAndHold(mouse)
        }

        Rectangle {
            id: textCanvas
            anchors {
                top: parent.verticalCenter
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            radius: units.gu(0.5)
            color: "black"
            opacity: 0.7
            Column {
                anchors.fill: parent
                anchors.margins: units.gu(0.25)

                Label {
                    id: primaryLabel
                    width: parent.width
                    height: Math.round(parent.height / 2)
                    anchors {
                        leftMargin: units.gu(1)
                        rightMargin: units.gu(1)
                    }
                    color: "#FFF"
                    elide: Text.ElideRight
                    textSize: Label.Small
                    opacity: 1.0
                    maximumLineCount: 2
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Label {
                    id: secondaryLabel
                    width: parent.width
                    height: Math.round(parent.height / 4)
                    anchors {
                        leftMargin: units.gu(1)
                        rightMargin: units.gu(1)
                    }
                    color: "#FFF"
                    elide: Text.ElideRight
                    textSize: Label.Small
                    // Allow wrapping of 2 lines unless primary has been wrapped
                    maximumLineCount: primaryLabel.lineCount > 1 ? 1 : 2
                    opacity: 0.8
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
        
                Label {
                    id: tertiaryLabel
                    width: parent.width
                    height: Math.round(parent.height / 4)
                    anchors {
                        leftMargin: units.gu(1)
                        rightMargin: units.gu(1)
                    }
                    color: "#FFF"
                    elide: Text.ElideRight
                    textSize: Label.Small
                    // Allow wrapping of 2 lines unless primary has been wrapped
                    maximumLineCount: primaryLabel.lineCount > 1 ? 1 : 2
                    opacity: 0.8
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }
        }
    }

}