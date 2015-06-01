#include "QompoterTest.h"

#include <QDebug>

#include "Qompoter.h"
#include "QuerySettings.h"

using namespace Qompoter;

QompoterTest::QompoterTest()
{
    QCoreApplication::setOrganizationName   ("qompoter");
    QCoreApplication::setApplicationName    ("Qompoter");
}

void QompoterTest::init()
{
}

void QompoterTest::cleanup()
{
    
}

void QompoterTest::testInstall()
{
    // Persistant Settings
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, QCoreApplication::organizationName(), QCoreApplication::applicationName());
    
    // Process
    Query query;
    QuerySettings querySettings(settings, query);
    querySettings.loadSettings();
    query.setAction("install");
    query.setVerbose(true);
    Qompoter::Qompoter qompoter(query);
    bool loaded = qompoter.loadQompoterFile();
    QVERIFY2(loaded, "Normally, there is no qompoter file");
    bool installed = qompoter.install();
    QVERIFY2(installed, "Normally, you can't install without  qompoter file");
}

