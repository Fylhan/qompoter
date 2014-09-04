#include "AutoTestRunner.h"

#include <QTextCodec>
#include <QDir>
#include <QDebug>


AutoTestRunner::AutoTestRunner() : overallResult(0), count_passedTest(0), count_failedTest(0)
{
}
AutoTestRunner::~AutoTestRunner()
{
}


void AutoTestRunner::run(int argc, char *argv[])
{
    for(std::list< QSharedPointer<QObject> >::iterator it=tests_.begin(); it != tests_.end(); it++) {
        QSharedPointer<QObject> test = (*it);
        QString testCaseName = test.data()->objectName();
        int testCaseResult = QTest::qExec(test.data(), argc, argv);
        if (0 == testCaseResult) {
            qDebug()<<testNameResized(testCaseName)<<": PASSED";
            count_passedTest++;
        }
        else {
            qDebug()<<testNameResized(testCaseName)<<": FAILURE";
            count_failedTest++;
        }
        overallResult |= testCaseResult;
    }

    // Log overall result
    qDebug()<<"Totals: "<<count_passedTest<<" passed, "<<count_failedTest<<" failed";
    qDebug()<<"Global result: "<<QString((0 == overallResult) ? "PASSED" : "FAILURE");
    // Quit
    QCoreApplication::instance()->exit();
}

QString AutoTestRunner::testNameResized(QString testName)
{
    int totalLength = 35;
    int toBeResized = totalLength-testName.length();
    QString resized = testName;
    for (int i=0; i<toBeResized; i++) {
        resized.append(" ");
    }
    return resized;
}
