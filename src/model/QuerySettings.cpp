#include "QuerySettings.h"

#include <QSettings>

#include "Query.h"

using namespace Qompoter;

QuerySettings::QuerySettings(QSettings &settings, Query &query) :
    settings_(settings),
    query_(query)
{
}

void QuerySettings::loadSettings()
{
    settings_.beginGroup(QStringLiteral("Query"));
    if (!settings_.contains(QStringLiteral("repositories")))
        settings_.setValue(QStringLiteral("repositories"), "/media/Project/PlateformeVehiculeElectrique/4_workspace/qompoter|/media/data/Projet/qompoter");
    if (!settings_.contains(QStringLiteral("maxRecurency")))
        settings_.setValue(QStringLiteral("maxRecurency"), 10);
    query_.setRepositories(settings_.value(QStringLiteral("repositories")).toString().split("|"), "http");
    query_.setRepositories(settings_.value(QStringLiteral("repositories")).toString().split("|"), "git");
    query_.setRepositories(settings_.value(QStringLiteral("repositories")).toString().split("|"), "fs");
    query_.setMaxRecurency(settings_.value(QStringLiteral("maxRecurency")).toInt());
    settings_.endGroup();
}
