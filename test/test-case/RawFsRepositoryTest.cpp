#include "RawFsRepositoryTest.h"

#include "QuerySettings.h"
#include "RequireInfo.h"
#include "RawFsRepository.h"

using namespace Qompoter;

void RawFsRepositoryTest::initTestCase()
{
    QCoreApplication::setOrganizationName("qompoter");
    QCoreApplication::setApplicationName("Qompoter");
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, QCoreApplication::organizationName(), QCoreApplication::applicationName());
    Qompoter::QuerySettings querySettings(settings, query_);
    querySettings.loadSettings();
    query_.setAction(QStringLiteral("install"));
    query_.setVerbose(true);
}

void RawFsRepositoryTest::testContains()
{
    RawFsRepository repo(query_, QStringLiteral("/media/data/Projet/qompoter"));
    RequireInfo requireInfo(QStringLiteral("trialog/gpslib"), QStringLiteral("v1.1.1"));
    QVERIFY2(repo.contains(requireInfo), "Raw FS repo should contain gpslib");
    QCOMPARE(repo.package(requireInfo).getRepository().getType(), QStringLiteral("fs"));
    QCOMPARE(repo.package(requireInfo).getRepository().getUrl(), QStringLiteral("/media/data/Projet/qompoter/trialog/gpslib/v1.1.1"));
    
    requireInfo = RequireInfo(QStringLiteral("trialog/solilog"), QStringLiteral("v1.0"));
    QVERIFY2(repo.contains(requireInfo), "Raw FS repo should contain solilog");
    QCOMPARE(repo.package(requireInfo).getRepository().getType(), QStringLiteral("git"));
    QCOMPARE(repo.package(requireInfo).getRepository().getUrl(), QStringLiteral("/media/data/Projet/qompoter/trialog/gpslib.git"));
}
