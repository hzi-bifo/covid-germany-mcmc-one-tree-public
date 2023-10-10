ALL: phylogeo_sankoff_general split_tree_general contract_short_branch check_timed_tree phylogeo_sankoff_general_dna mutation-samples
#ALL: phylogeo_sankoff split-tree phylogeo_sankoff_dusseldorf split-tree-dusseldorf phylogeo_sankoff_general

#split-tree: split-tree.cc tree.h state.h
#	g++ split-tree.cc -o split-tree -O2 -std=c++11 -Wall

#split-tree-dusseldorf: split-tree-dusseldorf.cc tree.h state.h
#	g++ split-tree-dusseldorf.cc -o split-tree-dusseldorf -O2 -std=c++11 -Wall

#phylogeo_sankoff: phylogeo_sankoff.cc tree.h state.h
#	g++ phylogeo_sankoff.cc -o phylogeo_sankoff -O2 -std=c++11 -Wall

#phylogeo_sankoff_dusseldorf: phylogeo_sankoff_dusseldorf.cc tree.h state.h
#	g++ phylogeo_sankoff_dusseldorf.cc -o phylogeo_sankoff_dusseldorf -O2 -std=c++11 -Wall

phylogeo_sankoff_general: phylogeo_sankoff_general.cc tree.h state.h
	g++ phylogeo_sankoff_general.cc -o $@ -O2 -std=c++11 -Wall -lboost_program_options

split_tree_general: split_tree_general.cc tree.h state.h
	g++ split_tree_general.cc -o $@ -O2 -std=c++11 -Wall -lboost_program_options

contract_short_branch: contract_short_branch.cc tree.h state.h
	g++ contract_short_branch.cc -o $@ -O2 -std=c++11 -Wall -lboost_program_options

check_timed_tree: check_timed_tree.cc tree.h metadata.h
	g++ check_timed_tree.cc -o $@ -O2 -std=c++11 -Wall -lboost_program_options

phylogeo_sankoff_general_dna: phylogeo_sankoff_general_dna.cc tree.h state.h
	g++ phylogeo_sankoff_general_dna.cc -o $@ -O2 -std=c++11 -Wall -lboost_program_options -lboost_iostreams -I$(CONDA_PREFIX)/include -Wl,-rpath-link=$(CONDA_PREFIX)/lib -L$(CONDA_PREFIX)/lib

mutation-samples: mutation-samples.cc
	g++ mutation-samples.cc -o mutation-samples -O2 -std=c++11 -Wall -lboost_program_options
