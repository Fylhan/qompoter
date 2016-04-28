#include "MockLoaderTest.h"

#include "MockLoader.h"
#include "QuerySettings.h"

using namespace Qompoter;

void MockLoaderTest::initTestCase()
{
    QSettings settings;
    Qompoter::QuerySettings querySettings(settings, query_);
    querySettings.loadSettings();
    query_.setAction(QStringLiteral("install"));
    query_.setVerbose(true);
}

void MockLoaderTest::testContains()
{
    MockLoader loader(query_);
}
