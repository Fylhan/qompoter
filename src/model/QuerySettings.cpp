#include "QuerySettings.h"

#include <QSettings>

#include "Query.h"

using namespace Qompoter;

const QString GitsRepo = QStringLiteral("gits-repo");
const QString FsRepo = QStringLiteral("fs-repo");
const QString HttpRepo = QStringLiteral("http-repo");
const QString NoGithub = QStringLiteral("no-github");

QuerySettings::QuerySettings(QSettings &settings, Query &query) :
    settings_(settings),
    query_(query)
{
}

void QuerySettings::loadSettings()
{
    settings_.beginGroup(QStringLiteral("Query"));
    if (!settings_.contains(GitsRepo))
        settings_.setValue(GitsRepo, "/media/Project/PlateformeVehiculeElectrique/4_workspace/qompoter|/media/data/Projet/qompoter|https://github.com");
    if (!settings_.contains(FsRepo))
        settings_.setValue(FsRepo, "/media/Project/PlateformeVehiculeElectrique/4_workspace/qompoter|/media/data/Projet/qompoter");
    if (!settings_.contains(QStringLiteral("maxRecurency")))
        settings_.setValue(QStringLiteral("maxRecurency"), 10);
    //query_.setRepositories(settings_.value(HttpRepo).toString().split("|"), "http");
    query_.addRepositories(settings_.value(GitsRepo).toString().split("|"), "gits");
    query_.addRepositories(settings_.value(FsRepo).toString().split("|"), "fs");
    if (!settings_.contains(NoGithub) || !settings_.value(NoGithub).toBool()) {
        query_.addRepository("https://github.com", "git");
    }
    query_.setMaxRecurency(settings_.value(QStringLiteral("maxRecurency")).toInt());
    settings_.endGroup();
}
