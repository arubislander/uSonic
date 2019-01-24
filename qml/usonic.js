function init() {
    var db = LocalStorage.openDatabaseSync("uSonic", "1.0", "Database of synced Subsonic info", 1000000);

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS CoverArt(id STRING NOT NULL, path STRING NOT NULL, PRIMARY KEY(id))');
        tx.executeSql('CREATE TABLE IF NOT EXISTS Artist(id INTEGER NOT NULL, name TEXT, coverArtId TEXT albumCount INTEGER, PRIMARY KEY(id), FOREIGN KEY(coverArtId) REFERENCES CoverArt(id))');
        tx.executeSql('CREATE TABLE IF NOT EXISTS Album(id INTEGER NOT NULL, name TEXT, coverArtId TEXT, songCount INTEGER, created TIMESTAMP, duration INTEGER, artist TEXT,artistId INTEGER, PRIMARY KEY(id), FOREIGN KEY(coverArtId) REFERENCES CoverArt(id))');
        tx.executeSql('CREATE TABLE IF NOT EXISTS Song(id INTEGER NOT NULL, parent INTEGER, title TEXT isDir BOOLEAN, album TEXT, artist TEXT, track INTEGER, year TEXT, genre TEXT, coverArtId TEXT, size INTEGER, contentType TEXT, suffix TEXT, duration INTEGER, bitRate INTEGER, path TEXT, lastUpdate TIMESTAMP, PRIMARY KEY(id), FOREIGN KEY(coverArtId) REFERENCES CoverArt(id))');
        tx.executeSql('CREATE TABLE IF NOT EXISTS Queue(ordinal INTEGER NOT NULL, songId INTEGER NOT NULL, FOREIGN KEY(songId) REFERENCES Song(id))');
    });

    return db;
}

function addToQueue(songId) {
    var db = init();
    try {
        db.transaction(function (tx) {
            // find next sequence number:
            var rs = tx.executeSql('SELECT COUNT(*) count FROM Queue');
            var sq = rs.rows.item(0).count + 1;
            tx.executeSql('INSERT INTO Queue(?,?)', [sq, songId]);
            return sq; 
        });
    } catch(e) {
        console.debug(e);
        return -1;
    }
}

function clearQueue() {
    var db = init();
    db.transaction(function (tx) {
        tx.executeSql('DELETE FROM Queue'); 
    });
}

function addToCoverArt(coverArt, tx) {
    console.debug ("== entering addToCoverArt ==");
    if (tx === undefined) {
        console.debug("=  setting up transaction");
        var db = init();
        db.transaction(function (tx) {
            addToCoverArt(coverArt, tx);
        });
    } else {
        console.debug("=  executing upsert for id: "+coverArt.id + ", path: " + coverArt.path);
        var rs = tx.executeSql('SELECT COUNT(id) count FROM CoverArt WHERE id = ?', [coverArt.id]);
        var statement;
        if (rs.rows.item[0].count == 0) {
            statement = 'INSERT INTO CoverArt(path, id) VALUES(?,?)';
        } else {
            statement = 'UPDATE CoverArt SET path = ? WHERE id = ?';
        }
        tx.executeSql(statement,[coverArt.path, coverArt.id]);
    }
    console.debug ("== exiting addToCoverArt ==");
}

function getCoverArt(id, tx) {
    if (tx === undefined) {
        var db = init();
        db.transaction(function(tx){
            return getCoverArt(id, tx);
        });
    } else {
        console.debug("retrieving converart for id: " + id)
        var rs = tx.executeSql('SELECT path FROM CoverArt WHERE id = ?',[id]);
        if (rs.rows.length == 0) {
            console.debug("no coverArt found")
            return null;
        }
        console.debug("CoverArt found!")
        return { 'id' : id, 'path' : rs.rows.item(0).path };
   }
}

function addToSong(song) {
    var db = init();
    try {
        db.transaction(function(tx) {
            var statemnt;
            var rs = tx.executeSql('SELECT COUNT(id) FROM Song WHERE id = ?', [song.songId]);
            if (rs.rows.length == 0) {
                statment = 'INSERT INTO Song(parent, title, isDir, album, artist, track, year, coverArtId, genre, size, contentType, suffix, duration, bitRate, path, lastUpdate, id)' + 
                'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
            } else {
                statemnt = 'UPDATE Song SET parent = ?, title = ?, isDir = ?, album = ?, artist = ?, track = ?, year = ?, coverArtId = ?, genre = ?, size = ?, contentType = ?, suffix = ?, duration = ?, bitRate = ?, path = ?, lastUpdate = ?' +
                ' WHERE id=?';
            }
            tx.executeSql(statement,[model.parent, model.title, model.isDir, model.album, model.artist, model.track, model.year, model.coverArtId, model.genre, model.size, model.contentType, model.suffix, model.duration, model.bitRate, model.path, new Date(), model.songId]);
        });
    } catch (ex) {
        console.debug(e);
    }
}
