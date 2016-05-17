.pragma library
.import "md5.js" as MD5

var mt = null;

function webclient_get(url, callback) {
    var http = new XMLHttpRequest();
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            console.log("Headers -->");
            console.log(http.getAllResponseHeaders());
            console.log("Last modified -->");
            console.log(http.getResponseHeader(("Last-Modified")));
        } else if (http.readyState == XMLHttpRequest.DONE) {
            console.log(http.responseText);
            callback(http.responseText)
        }
    }
    http.open("GET", url);
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
