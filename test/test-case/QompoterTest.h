#ifndef QOMPOTERTEST_H
#define QOMPOTERTEST_H

#include "IUnitTestCase.h"

class QompoterTest : public IUnitTestCase
{
    Q_OBJECT
public:
    QompoterTest();
    
private Q_SLOTS:
    void init();
    void cleanup();
    
    void testInstall();
};

DECLARE_TEST("qompoter.unit", QompoterTest)

#endif // QOMPOTERTEST_H
