#include "EmptyTest.h"

EmptyTest::EmptyTest()
{
}
void EmptyTest::initTestCase()
{
}
void EmptyTest::cleanupTestCase()
{
}


void EmptyTest::testEmpty()
{
    qDebug()<<"Here we log";
    QVERIFY2(true, "Should be true");
}
