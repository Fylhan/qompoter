#ifndef EMPTYTEST_H
#define EMPTYTEST_H

#include "IUnitTestCase.h"


class EmptyTest : public IUnitTestCase
{
    Q_OBJECT
public:
    EmptyTest();

private Q_SLOTS:
    void initTestCase();
    void cleanupTestCase();

    void testEmpty();
};

DECLARE_TEST(EmptyTest)

#endif // EMPTYTEST_H
