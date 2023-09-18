PROJECT_NAME=module-engine

CXX:=ccache

MSO= -DSO='"$(shell uname)"' -DUNAME='$(shell uname)' -D$(shell uname)
MPN= -DPROJECT_NAME='"$(PROJECT_NAME)"'

MACROS:= $(MSO) $(MPN)
INCLUDE_DIRS:= ./include
LIB_DIRS:= ./Libs
STATIC_LIBS:= $(foreach L,$(foreach D,$(LIB_DIRS), $(call FIND_FILES,$(D),.a)), $(L))
DYNAMIC_LIBS:= $(foreach L,$(foreach D,$(LIB_DIRS), $(call FIND_FILES,$(D),.so)), $(L))
FLAGS:=-Wall -pedantic
# INCLUDE DIRS
FLAGS+= $(foreach D,$(INCLUDE_DIRS), -I$(D))

ifdef STD_11
	FLAGS+= -std=c++11
	MACROS+= -DSTD='"c++11"' -DCXX_VERSION='11' -DCXX11=1
else
	ifdef STD_17
		FLAGS+= -std=c++17
		MACROS+= -DSTD='"c++17"' -DCXX_VERSION='17' -DCXX17=1
	else
		ifdef STD_20
			FLAGS+= -std=c++20
			MACROS+= -DSTD='"c++20"' -DCXX_VERSION='20' -DCXX20=1
		else
			FLAGS+= -std=c++23
			MACROS+= -DSTD='"c++23"' -DCXX_VERSION='23' -DCXX23=1
		endif
	endif
endif

ifdef RELEASE
	FLAGS+= -O3
	MACROS+= -DMODE_STR='"RELEASE"' -DRELEASE=1 -DMODE='RELEASE' -DOPTIMIZED
else
	FLAGS+= -g -ggdb
	MACROS+= -DMODE_STR='"DEBUG"' -DDEBUG=1 -DMODE='DEBUG' -DVERBOSE
endif

ifdef RAW_CXX
	CXX:=
endif

ifdef CXX_CLANG
	CXX+= clang++
	MACROS+= -DCOMPILER='clang++' -DCOMPILER_STR='"clang++"' -DCLANGXX
else
	CXX+= g++
	MACROS+= -DCOMPILER='g++' -DCOMPILER_STR='"g++"' -DGXX
endif

ifndef NASAN
	FLAGS+= -fsanitize=address,undefined
	MACROS+= -DSANITIZER='address,undefined' -DSANITIZER_STR='"address,undefined"' -DSANITIZE
endif

LDFLAGS:= $(STATIC_LIBS) $(DYNAMIC_LIBS)

ifndef LD_DYN=1
	LDFLAGS+= -static-libgcc -static-libstdc++
	MACROS+= -DSTATIC_LIBS=1 -DSTATIC
endif

SRCDIR=src
OBJDIR=obj

FLAGS+= -I$(SRCDIR)

MACROS+= -DSOURCE_DIRECTORY='$(SRCDIR)' -DSOURCE_DIRECTORY_STR='"$(SRCDIR)"'
MACROS+= -DOBJECT_DIRECTORY='$(OBJDIR)' -DOBJECT_DIRECTORY_STR='"$(OBJDIR)"'

SRCDIRS= $(call FIND_SUBDIRS,$(SRCDIR))
OBJDIRS= $(patsubst $(SRCDIR)%,$(OBJDIR)%,$(SRCDIRS))

MACROS+= -DALL_SRC_DIRS='$(SRCDIRS)' -DALL_SRC_DIRS_STR='"$(SRCDIRS)"'
MACROS+= -DALL_OBJ_DIRS='$(OBJDIRS)' -DALL_OBJ_DIRS_STR='"$(OBJDIRS)"'

SRCFILES:=$(call FIND_FILES,$(SRCDIR),cpp)
OBJFILES:=$(patsubst $(SRCDIR)%,$(OBJDIR)%,$(SRCFILES:.cpp=.o))

MACROS+= -DALL_SRC_FILES='$(SRCFILES)' -DALL_SRC_FILES_STR='"$(SRCFILES)"'
MACROS+= -DALL_OBJ_FILES='$(OBJFILES)' -DALL_OBJ_FILES_STR='"$(OBJFILES)"'
MACROS+= -DALL_FILES='$(SRCFILES) $(OBJFILES)' -DALL_FILES_STR='"$(SRCFILES) $(OBJFILES)"'

BUILD_DIR=build
APP:=$(BUILD_DIR)/$(PROJECT_NAME)

MACROS+= -DBUILD_DIR='$(BUILD_DIR)' -DBUILD_DIR_STR='"$(BUILD_DIR)"'
MACROS+= -DAPP_NAME='$(APP)' -DAPP_NAME_STR='"$(APP)"'

FLAGS+= $(MACROS)
