import QtQuick 2.4
import U1db 1.0 as U1db

Item {

    property var account: accountDocument
    property var recentSearch: recentSearchDocument

    signal settingsUpdated( string server, string username, string password )

    U1db.Database {
        id: settingsDB
        path: "SettingsDB.u1db"
    }

    U1db.Document {
        id: accountDocument
        database: settingsDB
        docId: "accounts_v1"
        create: true
        defaults: {
            "server" : "http://demo.subsonic.org",
            "username" : "guest",
            "password" : "guest",
        }
    }

    U1db.Document {
        id: recentSearchDocument
        database: settingsDB
        docId: "recentSearch_v1"
        create: true
        defaults: {
            "recent_searches" : []
        }
    }

    Component.onCompleted: {
        console.debug(account.contents.server)
        settingsUpdated(  account.contents.server
                        , account.contents.username
                        , account.contents.password )
    }
}



