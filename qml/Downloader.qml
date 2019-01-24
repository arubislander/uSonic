import QtQuick 2.4
import QtQuick.LocalStorage 2.0
import Ubuntu.DownloadManager 1.2

import FileManager 1.0
import "usonic.js" as UsonicJS

Item {
    id: downloader
    property var downloadQueue: []

    onDownloadQueueChanged: {
        //timer.start();
    }

    Timer {
        id: timer
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            console.debug("Download Timer triggered");

            while (downloadQueue.length > 0) {
                var msg = downloadQueue.shift();
                if (msg === undefined) {
                    console.debug("* no downloads queued: exiting" )
                    return;
                }
                console.debug("* setting up to download",msg.url);
                download(msg, false);
            }
        }
     }

    Component {
        id: singleDownloadComponent
        SingleDownload {
            id: singleDownloadObject
            property string id
            property string title
            property string type
            metadata: Metadata {
                showInIndicator: true
                title: singleDownloadObject.title
                custom: {"id": singleDownloadObject.id, "type" : singleDownloadObject.type}
            }
        }
    }

    function download(msg, disableMobileDownload) {
        if(downloadManager.isDownloadInQueue(msg.id)) {
            console.log("[LOG]: Download with ID of :"+msg.id+ " is already in the download queue.")
            return false;
        }

        var singleDownload = singleDownloadComponent.createObject(
            downloader, {
                "id": msg.id, 
                "title": msg.title, 
                "type": msg.type, 
                allowMobileDownload : !disableMobileDownload });
        singleDownload.download(msg.url);
    }

    DownloadManager {
        id: downloadManager

        property string downloadingId: downloads.length > 0 ? downloads[0].metadata.custom.id : "NULL"
        property int progress: downloads.length > 0 ? downloads[0].progress : 0

        cleanDownloads: true

        function isDownloadInQueue ( id ) {
            for( var i=0; i < downloads.length; i++) {
                if( downloads[i].metadata.custom.id && id === downloads[i].metadata.custom.id) {
                    return true ;
                }
            }
            return false;
        }

        onDownloadFinished: {
             console.debug("* download finished");
             var msg = download.metadata.custom;
             console.debug("* retrieved: ", msg.id);

             var basePath;
             switch(msg.type) {
                 case "CoverArt":
                    console.debug("* saving coverart");
                    basePath = FileManager.coverArtDirectory;
                    break;
                case "Song":
                    basePath = FileManager.songsDirectory;
                    break;
             }
             console.debug("* finished downloading: " + msg.id + " at " + path )
             var newPath = FileManager.saveDownload(msg.id + ".png", basePath, path);
             UsonicJS.addToCoverArt( {"id" : msg.id, "path": newPath} );
        }

        onErrorFound: {
            console.log("[ERROR]: " + download.errorMessage)
        }
    }
}