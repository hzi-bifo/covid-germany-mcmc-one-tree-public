ALL: phylogeo_sankoff_general_dna mutation-samples

phylogeo_sankoff_general_dna: phylogeo_sankoff_general_dna.cc tree.h state.h
	g++ phylogeo_sankoff_general_dna.cc -o $@ -O2 -std=c++11 -Wall -lboost_program_options -lboost_iostreams -I$(CONDA_PREFIX)/include -Wl,-rpath-link=$(CONDA_PREFIX)/lib -L$(CONDA_PREFIX)/lib

mutation-samples: mutation-samples.cc
	g++ mutation-samples.cc -o mutation-samples -O2 -std=c++11 -Wall -lboost_program_options
