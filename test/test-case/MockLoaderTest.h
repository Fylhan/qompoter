#ifndef MOCKLOADERTEST_H
#define MOCKLOADERTEST_H

#include "IUnitTestCase.h"
#include "Query.h"

class MockLoaderTest : public IUnitTestCase
{
    Q_OBJECT
public slots:
    void initTestCase();
    
    void testContains();
    
private:
    Qompoter::Query query_;
};

DECLARE_TEST("qompoter.unit", MockLoaderTest)

#endif // MOCKLOADERTEST_H
