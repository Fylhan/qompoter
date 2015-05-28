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
    query_.setRepositories(settings_.value(QStringLiteral("repositories")).toString().split("|"));
    settings_.endGroup();
}
