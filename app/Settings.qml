import QtQuick 2.4
import U1db 1.0 as U1db

Item {

    property var accountDocument: accountSettings
    property var recentSearchDocument: recentSearchSettings

    U1db.Database {
        id: settingsDB
        path: "SettingsDB.u1db"
    }

    U1db.Document {
        id: accountSettings
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
        id: recentSearchSettings
        database: settingsDB
        docId: "recentSearch_v1"
        create: true
        defaults: {
            "recent_searches" : []
        }
    }
}



