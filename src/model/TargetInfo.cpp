#include "TargetInfo.h"

using namespace Qompoter;

TargetInfo::TargetInfo() :
    makefile_("qmake")
{}

TargetInfo::TargetInfo(const QVariantMap &data) :
    makefile_("qmake")
{
    compiler_ = data.value("compiler", compiler_).toString();
    os_ = data.value("os", os_).toString();
    arch_ = data.value("arch", arch_).toString();
    makefile_ = data.value("makefile", makefile_).toString();
}

const QString &Qompoter::TargetInfo::getCompiler() const
{
    return compiler_;
}
void Qompoter::TargetInfo::setCompiler(const QString &compiler)
{
    compiler_ = compiler;
}

const QString &Qompoter::TargetInfo::getOs() const
{
    return os_;
}
void Qompoter::TargetInfo::setOs(const QString &os)
{
    os_ = os;
}

const QString &Qompoter::TargetInfo::getArch() const
{
    return arch_;
}
void Qompoter::TargetInfo::setArch(const QString &arch)
{
    arch_ = arch;
}

const QString &Qompoter::TargetInfo::getMakefile() const
{
    return makefile_;
}
void Qompoter::TargetInfo::setMakefile(const QString &makefile)
{
    makefile_ = makefile;
}
