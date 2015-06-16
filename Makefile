.PHONY: clean all
.SECONDARY:

# EDIT THIS SECTION
LIBRARY_NAME = Analysis

INCLUDES  = include
CPP       = g++
CFLAGS    = -pedantic -Wall -Wno-long-long -D_FILE_OFFSET_BITS=64 -O3
LINKFLAGS =

# EVERYTHING PAST HERE SHOULD WORK AUTOMATICALLY

INCLUDES  := $(addprefix -I,$(INCLUDES))
CFLAGS    += $(shell root-config --cflags)
CFLAGS    += -MMD $(INCLUDES)
LINKFLAGS += $(shell root-config --glibs) -lSpectrum
LINKFLAGS += -Lbin -l$(LIBRARY_NAME) -Wl,-rpath,\$$ORIGIN

EXE_O_FILES = $(patsubst %.cc,build/%.o,$(wildcard *.cc))
EXECUTABLES = $(patsubst build/%.o,bin/%,$(EXE_O_FILES))

SOURCES = $(shell find -name "*.cc")
ALL_O_FILES = $(patsubst ./%.cc,build/%.o,$(SOURCES))
LIB_O_FILES = $(filter-out $(EXE_O_FILES),$(ALL_O_FILES)) build/Dictionary.o

all: $(EXECUTABLES) $(EXTRAS)

bin/%: build/%.o | bin/lib$(LIBRARY_NAME).so bin
	@echo "Compiling $@"
	@$(CPP) $< -o $@ $(LINKFLAGS)

bin:
	@echo "Making $@ directory"
	@mkdir -p $@

bin/lib$(LIBRARY_NAME).so:  $(LIB_O_FILES) | bin
	@echo "Making $@"
	@$(CPP) -fPIC -shared -o $@ $^

build/%.o: %.cc
	@echo "Compiling $@"
	@mkdir -p $(dir $@)
	@$(CPP) -fPIC -c $< -o $@ $(CFLAGS)

build/Dictionary.o: build/Dictionary.cc
	@echo "Compiling $@"
	@mkdir -p $(dir $@)
	@$(CPP) -fPIC -c $< -o $@ $(CFLAGS)

build/Dictionary.cc: $(wildcard include/*.hh) include/LinkDef.h
	@echo "Building $@"
	@mkdir -p build
	@rootcint -f $@ -c $(INCLUDES) $(ROOTCFLAGS) $(notdir $^)

-include $(shell find build -name '*.d' 2> /dev/null)

clean:
	@echo "Cleaning up"
	@rm -rf build
	@rm -rf bin