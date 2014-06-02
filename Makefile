.PHONY: clean all
.SECONDARY:

LIBRARY_NAME = Analysis
SWITCH = -g

ROOTCFLAGS   := $(shell root-config --cflags)
ROOTLIBS     := $(shell root-config --glibs) -lSpectrum
INCLUDES      = -Iinclude
CPP           = g++
CFLAGS	      = -pedantic -Wall -Wno-long-long -D_FILE_OFFSET_BITS=64 -MMD -O3 \
                   $(ROOTCFLAGS) $(INCLUDES) $(SWITCH)
LIBS  =  $(ROOTLIBS) -Lbin -l$(LIBRARY_NAME) -Wl,-rpath,\$$ORIGIN

EXECUTABLES = $(patsubst %.cc,bin/%,$(wildcard *.cc))
O_FILES = $(patsubst src/%.cc,build/%.o,$(wildcard src/*.cc))
DICT_O_FILES = build/Dictionary.o

all: $(EXECUTABLES) bin/lib$(LIBRARY_NAME).so

bin/%: build/%.o | bin/lib$(LIBRARY_NAME).so bin
	@echo "Compiling $@"
	@$(CPP) $(CFLAGS) $(LIBS) $< -o $@

bin:
	@echo "Making bin directory"
	@mkdir $@

build:
	@echo "Making build directory"
	@mkdir $@

bin/lib$(LIBRARY_NAME).so:  $(O_FILES) $(DICT_O_FILES) | bin
	@echo "Making $@"
	@$(CPP) $(CFLAGS) -fPIC -shared -o $@ $^

-include $(wildcard build/*.d)

define OBJ_COMMANDS
@echo "Compiling $@"
@$(CPP) -fPIC $(CFLAGS) -c $< -o $@
endef

build/%.o: %.cc | build
	$(OBJ_COMMANDS)
build/%.o: src/%.cc include/%.hh | build
	$(OBJ_COMMANDS)
build/Dictionary.o: build/Dictionary.cc build/Dictionary.h | build
	$(OBJ_COMMANDS)

build/Dictionary.cc: $(wildcard include/*.hh) include/LinkDef.h | build
	@echo "Building $@"
	@rootcint -f $@ -c $(SWITCH) $(INCLUDES) $(ROOTCFLAGS) $(notdir $^)
build/Dictionary.h: build/Dictionary.cc
	@echo "Confirming $@"
	@touch $@

clean:
	@echo "Cleaning up"
	@rm -rf build
	@rm -rf bin