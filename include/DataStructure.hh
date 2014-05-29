#ifndef DATA_STRUCTURE_HH
#define DATA_STRUCTURE_HH

#include "TObject.h"

class DataStructure : public TObject{
public:
  DataStructure();
  double x,y;
public:
  ClassDef(DataStructure,1);
};

#endif
