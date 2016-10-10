#include <QtQml>
#include <QtQml/QQmlContext>
#include <QSslConfiguration>
#include <QSslSocket>
#include "backend.h"
#include "mytype.h"


void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Usonic"));

    qmlRegisterType<MyType>(uri, 1, 0, "MyType");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setPeerVerifyMode(QSslSocket::VerifyNone);
    QSslConfiguration::setDefaultConfiguration(config);

    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
