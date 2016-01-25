#ifndef RAWFSREPOSITORYTEST_H
#define RAWFSREPOSITORYTEST_H

#include "IUnitTestCase.h"
#include "Query.h"

class RawFsRepositoryTest : public IUnitTestCase
{
    Q_OBJECT
public slots:
    void initTestCase();
    
    void testContains();
    
private:
    Qompoter::Query query_;
};

DECLARE_TEST("qompoter.unit", RawFsRepositoryTest)

#endif // RAWFSREPOSITORYTEST_H
