.PHONY: clean all

SWITCH = -g

ROOTCFLAGS   := $(shell root-config --cflags)
ROOTLIBS     := $(shell root-config --glibs) -lSpectrum
INCLUDES      = -Iinclude
CPP           = g++
CFLAGS	      = -pedantic -Wall -Wno-long-long -D_FILE_OFFSET_BITS=64 -MMD -O3 \
                   $(ROOTCFLAGS) $(INCLUDES) $(SWITCH)
LIBS  =  $(ROOTLIBS) -Lbin -lAnalysis -Wl,-rpath,\$ORIGIN

EXECUTABLES = $(addprefix bin/,$(basename $(wildcard *.cc)))
O_FILES = $(addsuffix .o,$(addprefix build/,$(basename $(notdir $(wildcard src/*.cc)))))
DICT_O_FILES = build/Dictionary.o

all: $(EXECUTABLES) bin/libAnalysis.so

bin/%: %.cc | bin/libAnalysis.so bin
	@echo "Compiling $@"
	@$(CPP) $(CFLAGS) $(LIBS) $< $(filter %.o,$^) -o $@

bin:
	@echo "Making bin directory"
	@mkdir $@

build:
	@echo "Making build directory"
	@mkdir $@

bin/libAnalysis.so:  $(O_FILES) $(DICT_O_FILES) | bin
	@echo "Making $@"
	@$(CPP) $(CFLAGS) -fPIC -shared -Wl,-soname,$@ -o $@ $^ -lc

-include $(wildcard build/*.d)

build/%.o: src/%.cc include/%.hh | build
	@echo "Compiling $@"
	@$(CPP) -fPIC $(CFLAGS) -c $< -o $@

build/Dictionary.o: build/Dictionary.cc build/Dictionary.h | build
	@echo "Compiling $@"
	@$(CPP) -fPIC $(CFLAGS) -c $< -o $@

build/Dictionary.cc: $(wildcard include/*.hh) include/LinkDef.h | build
	@echo "Building $@"
	@rootcint -f $@ -c $(SWITCH) $(INCLUDES) $(ROOTCFLAGS) $(notdir $^)
build/Dictionary.h: build/Dictionary.cc
	@echo "Confirming $@"

clean:
	@echo "Cleaning up"
	@rm -rf build
	@rm -rf bin