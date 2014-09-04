#include "ConfigFileManager.h"

#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>

QVariantMap ConfigFileManager::parseFile(QString filepath, bool createFileFromCleanedContent)
{
    // -- Get configuration file data (JSON formated)
    QFile file(filepath);
    // - Open the file (read only)
    if (!file.open(QIODevice::ReadOnly)) {
        qCritical()<<"File \""+filepath+"\" not found. Empty map returned.";
        return QVariantMap();
    }
    // - Modify file content
    // Read content
    QTextStream in(&file);
    QString fileData = in.readAll();
    // Close file
    file.close();
    // Remove inline comms
    QRegExp pattern = QRegExp("(^|\\[|\\{|,|\\n|\\s)//.*($|\\n)");
    pattern.setMinimal(true); //ungreedy
    fileData.replace(pattern, "\\1\n");
    fileData.replace(pattern, "\\1\n");//2 times, I am not sure why...
    // Remove bloc comms
    pattern = QRegExp("/\\*.*\\*/");
    pattern.setMinimal(true); //ungreedy
    fileData.replace(pattern, "");
    // Add first and last brace
    if (!fileData.startsWith("{")) {
        fileData = "{\n"+fileData;
    }
    if (!fileData.endsWith("}")) {
        fileData += "\n}";
    }
    // Remove commas before } or ]
    pattern = QRegExp(",(\\s*[}\\]])");
    pattern.setMinimal(true); //non-greedy
    fileData.replace(pattern, "\\1");

    if (createFileFromCleanedContent) {
        QFile computedFileData("computed_"+filepath);
        computedFileData.open(QIODevice::WriteOnly);
        computedFileData.write(fileData.toUtf8());
        computedFileData.close();
    }
    // -- Parse JSON data
    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(fileData.toUtf8(), &error);
    if (error.error != 0 || jsonDoc.isNull() || jsonDoc.isEmpty() || !jsonDoc.isObject()) {
        QString errorStr = "empty content";
        if (0 != error.error) {
            error.errorString();
        }
        qCritical()<<"Error during JSON parsing: "<<errorStr<<". Empty map returned.";
        return QVariantMap();
    }
    return jsonDoc.object().toVariantMap();
}
