#ifndef TESTRUNNER_H
#define TESTRUNNER_H

#include <QCoreApplication>
#include <QTest>
#include <QSharedPointer>
#include <QMutex>
#include <algorithm>
#include <list>
#include <iostream>

class IsNameEqualTo
{
public:
    IsNameEqualTo(char* name): name_(name){}
    bool operator()(QSharedPointer< QObject >& elem) const  { return elem->objectName() == name_; }
private:
    char* name_;
};

class AutoTestRunner
{
public:
    AutoTestRunner();
    ~AutoTestRunner();

    static AutoTestRunner& Instance()
    {
        static AutoTestRunner instance;
        return instance;
    }

    template <typename T>
    char addTest(char* name)
    {
        if ( std::find_if(tests_.begin(), tests_.end(), IsNameEqualTo(name)) == tests_.end() ) {
            QSharedPointer<QObject> test(new T());
            test->setObjectName(name);
            tests_.push_back(test);
        }
        return char(1);
    }

    void run(int argc, char *argv[]);

private:
    QString testNameResized(QString testName);

private:
    int overallResult;
    int count_passedTest;
    int count_failedTest;
    std::list< QSharedPointer<QObject> > tests_;
};

// Use this macro after your test declaration
#define DECLARE_TEST(className)\
    static char test_##className = AutoTestRunner::Instance().addTest<className>(#className);

// Use this macro to execute all tests
#define RUN_ALL_TESTS(argc, argv)\
    AutoTestRunner::Instance().run(argc, argv);

#define TEST_MAIN \
    int main(int argc, char *argv[]) \
    { \
        QCoreApplication a(argc, argv); \
        RUN_ALL_TESTS(argc, argv); \
        return a.exec(); \
    }

#endif // TESTRUNNER_H

//#ifndef AUTOTESTRUNNER_H
//#define AUTOTESTRUNNER_H

//#include <QTest>
//#include <QList>
//#include <QDebug>
//#include <QString>
//#include <QSharedPointer>

//namespace AutoTestRunner
//{
//int overallResult;
//int count_passedTest;
//int count_failedTest;
//typedef QList<QObject*> TestList;

//inline TestList& testList()
//{
//    static TestList list;
//    return list;
//}

//inline bool findObject(QObject* object)
//{
//    TestList& list = testList();
//    if (list.contains(object))
//    {
//        return true;
//    }
//    foreach (QObject* test, list)
//    {
//        if (test->objectName() == object->objectName())
//        {
//            return true;
//        }
//    }
//    return false;
//}

//inline void addTest(QObject* object)
//{
//    TestList& list = testList();
//    if (!findObject(object))
//    {
//        list.append(object);
//    }
//}

//inline int run(int argc, char *argv[])
//{
//    int ret = 0;
//    overallResult = 0;
//    count_passedTest = 0;
//    count_failedTest = 0;

//    foreach (QObject* test, testList())
//    {
//        QString logFolderPath = "log";
//        QString testCaseName = "TestCaseName";
//        QStringList outputLogfileCmd;
//        outputLogfileCmd<<" "<<"-o"<<""+logFolderPath+"/"+testCaseName+"_result.log";
//        int testCaseResult = QTest::qExec(test, outputLogfileCmd); //argc, argv);
//        qDebug()<<QString(0 == testCaseResult ? "PASS" : "FAIL")<<"  : "<<testCaseName;
//        if (0 == testCaseResult) {
//            count_passedTest++;
//        }
//        else {
//            count_failedTest++;
//        }
//        overallResult |= testCaseResult;
//        ret += testCaseResult;
//    }

//    // Launch
//    // Log overall result
//    qDebug()<<"Totals: "<<count_passedTest<<" passed, "<<count_failedTest<<" failed";
//    qDebug()<<"Global result: "<<QString((0 == overallResult) ? "PASSED" : "FAILURE");
//    // Quit
//    QApplication::instance()->quit();
//}
//}

//template <class T>
//class Test
//{
//public:
//    QSharedPointer<T> child;

//    Test(const QString& name) : child(new T)
//    {
//        child->setObjectName(name);
//        AutoTestRunner::addTest(child.data());
//    }
//};

//#define DECLARE_TEST(className) static Test<className> t(#className);

////#define TEST_MAIN \
////    int main(int argc, char *argv[]) \
////{ \
////    QCoreApplication a(argc, argv); \
////    return AutoTestRunner::run(argc, argv); \
////    return a.exec(); \
////    }

//#endif // AUTOTESTRUNNER_H
