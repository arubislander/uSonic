#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "filemanager.h"

void UsonicPlugin::registerTypes(const char *uri) {
    //@uri FileManager
    qmlRegisterSingletonType<FileManager>(uri, 1, 0, "FileManager", [](QQmlEngine*, QJSEngine*) -> QObject* { return new FileManager; });
}
