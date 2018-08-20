import QtQuick 2.4
import QtMultimedia 5.6
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0

// import Usonic 1.0

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

    AppResources {
        id: resources
    }

    PageStack {
        id: pageStack
    }

    Component.onCompleted: pageStack.push(
        Qt.resolvedUrl("MainPage.qml"),
            {
                objectName: "mainPage",
                appResources: resources,
                title: "uSonic",
            })
}
