#include "TFile.h"
#include "TTree.h"

#include "DataStructure.hh"


int main(){
  TFile* tfile = new TFile("test_out.root","RECREATE");
  TTree* ttree = new TTree("t","Description of the tree");

  DataStructure* data = new DataStructure;
  ttree->Branch("data",&data);

  for(int i=0; i<100; i++){
    ttree->Fill();
  }

  ttree->Write();
  tfile->Close();
}
