#ifndef CONFIGFILEMANAGER_H
#define CONFIGFILEMANAGER_H

#include <QVariantMap>

class QString;

/**
 * Gestionnaire de fichiers de configurations.
 * Pour un fichier de configuration, le formatage suit le protocole JSON : http://www.json.org/
 * C'est-à-dire une liste de "clef: valeur,", où "valeur" peut être :
 * une valeur simple (ex: "ma valeur"),
 * une liste de valeur ([valeur1, valeur2]),
 * ou à nouveau une liste de "clef: valeur,".
 *
 * Ce formatage est relativement souple par rapport au JSON strict :
 * Les commentaires en ligne ("// Commentaire") et en bloc ("/ * Commentaire sur plusieurs lignes * /") sont supportés.
 * Les virgules des derniers éléments d'une liste sont optionnelles,
 * Les accolades en début et en fin de fichier sont optionnelles.
*/
class ConfigFileManager
{
public:
    /**
      * Parse a config file
      * @param filepath Path (folder/name.extension) of the file to parse
      * @param createFileFromCleanedContent The content of the file is cleaned to avoid unwanted JSON issue
      */
    static QVariantMap parseFile(QString filepath);
    static QVariantMap parseContent(QString fileData);
};

#endif // CONFIGFILEMANAGER_H
