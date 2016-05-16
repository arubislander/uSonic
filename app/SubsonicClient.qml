import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import "utils.js" as Utils

Item {
    id : client
    property string serverUrl
    property string username
    property string password
    property string appcode : "ssqmlapp"
    property string api_version : "1.13"
    property int saltSize: 6

    property string token;
    property string salt;
    property string response;

    onPasswordChanged: {
            if (password !== "") {
            salt = Utils.random_salt(saltSize);
            token = token = Utils.get_token(password, salt);
            password = "";
        }
    }

    signal ready()

    function ping() {
        var url = Utils.get_ping_url(appcode,
                                     api_version,
                                     serverUrl,
                                     username,
                                     token,
                                     salt);
        console.debug("url", url)
        Utils.webclient_get(url, function(_response) {
            response = _response
            ready();
        });
    }

    function getLicense() {
        var url = Utils.get_license_url(appcode,
                                        api_version,
                                        serverUrl,
                                        username,
                                        token,
                                        salt);
        Utils.webclient_get(url, function(_response) {
            response = _response;
            ready();
        });
    }

    function getIndex(musicFolder) {
        var url = Utils.get_index_url(appcode,
                                         api_version,
                                         serverUrl,
                                         username,
                                         token,
                                         salt,
                                         musicFolder);
        Utils.webclient_get(url, function(_response) {
            response = _response;
            ready();
        });
    }

    function search(query) {
        var url = Utils.get_search_url(appcode,
                                         api_version,
                                         serverUrl,
                                         username,
                                         token,
                                         salt,
                                         query);
        Utils.webclient_get(url, function(_response) {
            searchResponse.xml = _response;
            searchResponse.reload();
            ready();
        });
    }

    function test(query) {
        response = Utils.get_search_url(appcode,
                                         api_version,
                                         serverUrl,
                                         username,
                                         token,
                                         salt,
                                         query);
        console.log(response);
        ready();
    }

}

