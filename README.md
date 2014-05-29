minimal_root
============
This project is intended as a minimal working example of writing custom objects to a ROOT tree.

* All executables and the .so are output to basename/bin.
* All dependency-tracking is handled by the Makefile.
* To add additional classes, add the appropriate src/\*.cc and include/\*.hh files.
  If this class is a TObject to be written to a ROOT file, add the appropriate line to include/LinkDef.h.
  The Makefile will handle the additional compilation steps.
* To add additional executables, add a new \*.cc file in the base folder.
  The Makefile will handle the additional compilation steps.
