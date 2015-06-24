#ifndef QOMPOTER_GITWRAPPER_H
#define QOMPOTER_GITWRAPPER_H

#include <QProcess>

namespace Qompoter {
class Query;
}

namespace Qompoter {
/**
 * Basic wrapper for Git command line
 */
class GitWrapper
{
public:
    GitWrapper(const Query &settings);

/**
 * @defgroup Git Git Commands
 * The Git group contains all available Git commands
 * @{
 */
public:
    /**
     * @brief Call "git clone source"
     * @param source Source repository
     * @param dest Destionation folder
     * @param branch Target branch/tag/commit in the source repository
     * @return Success of the operation
     */
    bool clone(const QString &source, const QString &dest="", const QString &branch="");
    /**
     * @brief Call "git fetch [branch]"
     * @param branch Branch/tag/commit to fetch
     * @return Success of the operation
     */
    bool fetch(const QString &branch="");
    /**
     * @brief Call "git checkout branch"
     * @param branch Branch/tag/commit to checkout
     * @param force Force the checkout: erase local changes
     * @param createBranch Create the branch and checkout to it
     * @return Success of the operation
     */
    bool checkout(const QString &branch, bool force=false, bool createBranch=false);
    /**
     * @brief Call "git reset branch"
     * @param branch Branch/tag/commit to reset to
     * @param hard Hard reset (--hard)
     * @return Success of the operation
     */
    bool reset(const QString &branch, bool hard=false);
    /**
     * @brief Call "git log -nb args" and retrieve result
     * @param nb Number of log to retrieve
     * @param args Additional parameters
     * @return All retrieved log, empty in case of error
     */
    QString log(const int &nb=10, const QStringList &args=QStringList());
    /**
     * @brief Call "git log -1 --pretty=format:"%H"" and retrieve result
     * @return Hash of the last commit, empty in case of error
     */
    QString lastHash();
    /**
     * @brief Call "git command args"
     * @param command Git command
     * @param args Arguments of the command
     * @return Success of the operation
     */
    bool command(const QString &command, QStringList args);
    /**
     * @brief Call "git command args" and retrieve results
     * @param command Git command
     * @param args Arguments of the command
     * @param outString Result of the command is available in this variable
     * @return Success of the operation
     */
    bool request(const QString &command, QStringList args, QString &outString);
/** @} */

/**
 * @defgroup Management Git Wrapper Management
 * The Management group 
 * @{
 */
public:
    /**
     * @brief Apply the Git command line in the specified folder
     * @param folder Folder where to apply the command
     */
    void cd(const QString &folder);
    /**
     * @brief stdout result of the last command
     * @return stdout as string
     */
    const QString &outString() const;
    /**
     * @brief stderr result of the last command
     * @return stderr as string
     */
    const QString &errorString() const;

private:
    QProcess gitProcess_;
    QString git_;
    bool verbose_;
    QString outString_;
    QString errorString_;
/** @} */
};
}

#endif // QOMPOTER_GITWRAPPER_H
