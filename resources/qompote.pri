# $$setLibPath()
# Generate a lib path name depending of the OS and the arch
# Export and return LIBPATH
defineReplace(setLibPath){
    # Detection of YoctoLinux SDK
    YOCTO = $$(TARGET_PREFIX)
    !isEmpty(YOCTO) {
      LIBPATH = $${YOCTO}lib
    }
    else {
      LIBPATH = lib
      # Windows / Linux
      win32|win32-cross-mingw {
        LIBPATH = $${LIBPATH}_windows
      }
      else:unix {
        LIBPATH = $${LIBPATH}_linux
      }
      # Precise architecture for Linux host
      linux-g++-32 {
        LIBPATH = $${LIBPATH}_32
      }
      else:linux-g++-64 {
        LIBPATH = $${LIBPATH}_64
      }
      else:linux-arm-gnueabi-g++ {
        LIBPATH = $${LIBPATH}_arm-gnueabi
      }
      # Or use architecture of the host when not provided
      else {
        contains(QMAKE_HOST.arch, x86_64) {
          LIBPATH = $${LIBPATH}_64
        }
        else {
          LIBPATH = $${LIBPATH}_32
        }
      }
    }

    export(LIBPATH)
    return($${LIBPATH})
}

# $$setLibName(lib name[, lib version])
# Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided
# Export VERSION, export and return LIBNAME
defineReplace(setLibName){
    unset(LIBNAME)
    LIBNAME = $$1
    VERSION = $$2
    CONFIG(debug,debug|release){
      LIBNAME = $${LIBNAME}d
    }

    export(VERSION)
    export(LIBNAME)
    return($${LIBNAME})
}

# $$getLibName(lib name)
# Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided
# Return lib name
defineReplace(getLibName){
    ExtLibName = $$1
    QtVersion = $$2
    equals(QtVersion, "Qt"){
      ExtLibName = $${ExtLibName}-Qt$$QT_VERSION
    }
    CONFIG(debug,debug|release){
      ExtLibName = $${ExtLibName}d
    }

    return($${ExtLibName})
}

# $$getCompleteLibName(lib name)
# Will add a "d" at the end of lib name in case of debug  echo compilation, and "-version" if provided
# Return lib name
defineReplace(getCompleteLibName){
    ExtLibName = $$1
    QtVersion = $$2
    LIBSUFIX = a
    contains(CONFIG,"dll"){
      win32|win32-cross-mingw {
        LIBSUFIX = dll
      }
      else:unix {
        LIBSUFIX = so
      }
    }
    contains(CONFIG,"shared"){
      win32|win32-cross-mingw {
        LIBSUFIX = dll
      }
      else:unix {
        LIBSUFIX = so
      }
    }
    contains(CONFIG,"static"){
      LIBSUFIX = a
    }
    return(lib$$getLibName($$ExtLibName,$$QtVersion).$$LIBSUFIX)
}

# $$setBuildDir()
# Generate a build dir depending of OS and arch
# Export MOC_DIR, OBJECTS_DIR, UI_DIR, TARGET, LIBS
defineReplace(setBuildDir){
    CONFIG(debug,debug|release){
      MOC_DIR = debug
      OBJECTS_DIR = debug
      UI_DIR      = debug
    }
    else {
      MOC_DIR = release
      OBJECTS_DIR = release
      UI_DIR      = release
    }

    # Detection of YoctoLinux SDK
    YOCTO = $$(TARGET_PREFIX)
    !isEmpty(YOCTO) {
      MOC_DIR     = $${MOC_DIR}/$${YOCTO}build
      OBJECTS_DIR = $${OBJECTS_DIR}/$${YOCTO}build
      UI_DIR      = $${UI_DIR}/$${YOCTO}build
    }
    # Windows
    else:win32|win32-cross-mingw{
      MOC_DIR     = $${MOC_DIR}/build_windows
      OBJECTS_DIR = $${OBJECTS_DIR}/build_windows
      UI_DIR      = $${UI_DIR}/build_windows
    }
    # Linux for different architecture
    else:linux-g++-32{
      MOC_DIR     = $${MOC_DIR}/build_linux_32
      OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_32
      UI_DIR      = $${UI_DIR}/build_linux_32
    	LIBS       += -L/usr/lib/gcc/i586-linux-gnu/4.9
    }
    else:linux-g++-64{
      MOC_DIR     = $${MOC_DIR}/build_linux_64
      OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_64
      UI_DIR      = $${UI_DIR}/build_linux_64
      LIBS       += -L/usr/lib/gcc/x86_64-linux-gnu/4.9
    }
    else:linux-arm-gnueabi-g++{
      MOC_DIR     = $${MOC_DIR}/build_linux_arm-gnueabi
      OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_arm-gnueabi
      UI_DIR      = $${UI_DIR}/build_linux_arm-gnueabi
      LIBS       += -L/usr/lib/gcc/arm-linux-gnueabi/4.9
    }
    # Linux use the architecture of the host
    else:unix{
      contains(QMAKE_HOST.arch, x86_64){
          MOC_DIR     = $${MOC_DIR}/build_linux_64
          OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_64
          UI_DIR      = $${UI_DIR}/build_linux_64
      }
      else{
          MOC_DIR     = $${MOC_DIR}/build_linux_32
          OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_32
          UI_DIR      = $${UI_DIR}/build_linux_32
      }
    }

    DESTDIR = $$OUT_PWD/$$OBJECTS_DIR

    export(DESTDIR)
    export(MOC_DIR)
    export(OBJECTS_DIR)
    export(UI_DIR)
    export(LIBS)
    return($TARGET)
}

