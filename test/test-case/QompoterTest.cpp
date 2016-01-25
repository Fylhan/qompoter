#include "QompoterTest.h"

#include <QDebug>

#include "Qompoter.h"
#include "QuerySettings.h"

QompoterTest::QompoterTest() :
    query_(),
    qompoter_(query_)
{
}

void QompoterTest::initTestCase()
{
    QCoreApplication::setOrganizationName("qompoter");
    QCoreApplication::setApplicationName("Qompoter");
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, QCoreApplication::organizationName(), QCoreApplication::applicationName());
    Qompoter::QuerySettings querySettings(settings, query_);
    querySettings.loadSettings();
    query_.setAction(QStringLiteral("install"));
    query_.setVerbose(true);
    qompoter_.setQuery(query_);
}

void QompoterTest::testQuery()
{
    QCOMPARE(qompoter_.getQuery().isVerbose(), true);
    QCOMPARE(qompoter_.getQuery().isGlobal(), false);
    QCOMPARE(qompoter_.getQuery().isDev(), true);
    QCOMPARE(qompoter_.getQuery().getQompoterFile(), QStringLiteral("qompoter.json"));
    QCOMPARE(qompoter_.getQuery().getQompoterFilePath(), QStringLiteral("qompoter.json"));
    QCOMPARE(qompoter_.getQuery().getVendorDir(), QStringLiteral("vendor/"));
    QCOMPARE(qompoter_.getQuery().getMaxRecurency(), 10);
    QCOMPARE(qompoter_.getQuery().getAction(), QStringLiteral("install"));
}

void QompoterTest::testLoadQompoterFile()
{
    bool loaded = false;
    Qompoter::Config config = qompoter_.loadQompoterFile(query_.getQompoterFilePath(), &loaded);
    QVERIFY2(loaded, "Qompoter file should be correctly loaded");
    QCOMPARE(config.getPackageName(), QStringLiteral("fylhan/qompoter-test"));
    QCOMPARE(config.getProjectName(), QStringLiteral("qompoter-test"));
    QCOMPARE(config.getVendorName(), QStringLiteral("fylhan"));
}

void QompoterTest::testInstall1Qompoter()
{
    bool installed = false;
    QHash<QString, Qompoter::PackageInfo> packages = qompoter_.install1Qompoter(query_.getQompoterFilePath(), true, &installed);
    QCOMPARE(qompoter_.getConfig().getPackageName(), QStringLiteral("fylhan/qompoter-test"));
    QCOMPARE(qompoter_.getConfig().getProjectName(), QStringLiteral("qompoter-test"));
    QCOMPARE(qompoter_.getConfig().getVendorName(), QStringLiteral("fylhan"));
    QCOMPARE(qompoter_.getConfig().getPackages().size(), 5);
    QCOMPARE(packages.size(), 5);
    QVERIFY2(packages.contains(QStringLiteral("trialog/solilog")), "Should contain package solilog");
    QVERIFY2(packages.contains(QStringLiteral("trialog/gpslib")), "Should contain package gpslib");
    QVERIFY2(packages.contains(QStringLiteral("trialog/tcanp")), "Should contain package tcanp");
    QVERIFY2(packages.contains(QStringLiteral("trialog/autotester")), "Should contain package autotester");
    QVERIFY2(packages.contains(QStringLiteral("ixxat/eci")), "Should contain package eci");
    QVERIFY2(installed, "First level packages should be installed correctly");
}

void QompoterTest::testInstall()
{
    bool installed = qompoter_.install();
    QVERIFY2(installed, "Normally, you can't install without  qompoter file");
}

