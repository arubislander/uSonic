.pragma library
.import "md5.js" as MD5

var mt = null;

// http://stackoverflow.com/questions/35577243/access-and-read-html-php-page-by-https-request-by-qml-js-behind-htaccess-apache2

function webclient_get(url, callback) {
    var http = new XMLHttpRequest();
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            console.log("Headers -->");
            console.log(http.getAllResponseHeaders());
            console.log("Last modified -->");
            console.log(http.getResponseHeader(("Last-Modified")));
        } else if (http.readyState === XMLHttpRequest.DONE) {
            console.log(http.responseText);
            if (callback) {
                callback(JSON.parse(http.responseText)["subsonic-response"]);
            }
        }
    }
    http.open("GET", url+"&f=json");
    http.send();
}

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

function random_salt(length) {
    var min = Math.pow(2,32);
    var max = Math.pow(2,33)-1;
    console.log("length:", length,"min:", min, "max:", max);
    return MD5.rhex(randomInt(min,max)).substr(0,length);
}

function get_token(password, salt) {
    var token = MD5.calcMD5(password+salt);
    return token;
}

function get_coverart_url(appcode, target_api_version, basepath,
                          username, token, salt, coverart_id,size) {
    var url = basepath + "/getCoverArt.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
            + "&id=" + coverart_id
            + "&size=" + size;
    console.debug("url:", url)
    return url;
}

function get_ping_url(appcode, target_api_version, basepath,
                      username, token, salt) {
    var url = basepath + "/ping.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version;
    return url;
}

function get_stream_Url(appcode, target_api_version, basepath,
                      username ,token, salt, songId) {
    var url = basepath + "/stream.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
            + "&id=" + songId;
    return url;
}

function get_license_url(appcode, target_api_version, basepath,
                         username ,token, salt) {
    var url = basepath + "/getLicense.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version;
    return url;
}

function get_index_url(appcode, target_api_version, basepath,
                       username ,token, salt, musicFolder) {
    var url = basepath + "/getIndexes.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
            + "&musicFolder=" + musicFolder;
    return url;
}

function get_search_url(appcode, target_api_version, basepath,
                        username, token, salt, query) {
    var url = basepath + "/search2.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
            + "&query=" + query;
    return url;
}

function get_playlists_url(appcode, target_api_version, basepath,
                           username, token, salt) {
    var url = basepath + "/getPlaylists.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
    return url;
}

function get_playlist_url(appcode, target_api_version, basepath,
                          username, token, salt, playlistId) {
    var url = basepath + "/getPlaylist.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
            + "&id=" + playlistId
    return url;
}

//createPlaylist.view
function create_playlist_url(appcode, target_api_version, basepath,
                             username, token, salt, name, songIds) {
   var url = basepath + "/createPlaylist.view?c=" + appcode
           + "&u=" + username
           + "&t=" + token
           + "&s=" + salt
           + "&v=" + target_api_version
           + "&name=" + name
           + "&songId=" + songIds.join("&songId=")
   return url;
}

function delete_playlist_url(appcode, target_api_version, basepath,
                             username, token, salt, playlistId) {
   var url = basepath + "/deletePlaylist.view?c=" + appcode
           + "&u=" + username
           + "&t=" + token
           + "&s=" + salt
           + "&v=" + target_api_version
           + "&id=" + playlistId;
   return url;
}


function get_albumList_url(appcode, target_api_version, basepath,
                         username, token, salt, type) {
    var url = basepath + "/getAlbumList2.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
            + "&type=" + type
    return url;
}

function get_album_url(appcode, target_api_version, basepath,
                       username, token, salt, albumId) {
    var url = basepath + "/getAlbum.view?c=" + appcode
            + "&u=" + username
            + "&t=" + token
            + "&s=" + salt
            + "&v=" + target_api_version
            + "&id=" + albumId
    return url;
}
