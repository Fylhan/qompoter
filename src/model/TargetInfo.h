#ifndef TARGETINFO_H
#define TARGETINFO_H

#include <QString>
#include <QVariantMap>

namespace Qompoter {
class TargetInfo
{
public:
    TargetInfo();
    TargetInfo(const QVariantMap &data);
    
    /**
    * Target library compiled with this compiler. E.g. gcc, vs2010
    */
    const QString &getCompiler() const;
    void setCompiler(const QString &compiler);
    
    /**
    * Target library compiled, or source code written for this OS. E.g. windows, linux
    */
    const QString &getOs() const;
    void setOs(const QString &os);
    
    /**
    * Target library compiled for this architecture. E.g. 32, 64
    */
    const QString &getArch() const;
    void setArch(const QString &arch);
    
    /**
    * Ouput a Qmake or Cmake makefile. E.g. qmake, cmake
    */
    const QString &getMakefile() const;
    void setMakefile(const QString &makefile);
    
private:
    QString compiler_;
    QString os_;
    QString arch_;
    QString makefile_;
};
}

#endif // TARGETINFO_H
