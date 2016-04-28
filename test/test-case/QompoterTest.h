#ifndef QOMPOTERTEST_H
#define QOMPOTERTEST_H

#include "IUnitTestCase.h"

#include "Qompoter.h"

class QompoterTest : public IUnitTestCase
{
    Q_OBJECT
public:
    QompoterTest();

private Q_SLOTS:
    void initTestCase();
    
    void testQuery();
    void testLoadQompoterFile();
    void testInstall1Qompoter();
    void testInstall();
    
private:
    Qompoter::Query query_;
    Qompoter::Qompoter qompoter_;
};

DECLARE_TEST("qompoter.unit", QompoterTest)

#endif // QOMPOTERTEST_H
