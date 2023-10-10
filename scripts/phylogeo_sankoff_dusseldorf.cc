#include "tree.h"
#include "state.h"


array<string, StateInOut::size> StateInOut::names = {"UK", "nonUK"}; 

int main(int argc, char* argv[]) {
	string tree = "data/ft_SH.tree";
	//tree = "data/ft-sample_SH.tree";
	string output = "results/all-c.trees";
	string annotation = "data/dates_and_locations.tsv";
	//annotation = "data/dates_and_locations-sample.tsv";

	tree = "data/gisaid-20210324.tree";
	output = "results/gisaid-20210324-dusseldorf-all.trees";

	//tree = "data/gisaid-20210324/timetree.nexus";
	//output = "results/gisaid-20210324-all-timed.trees";
	annotation = "data/metadata-gisaid-20210325.tsv";

	Node<State_Dusseldorf> phylo = load_tree<State_Dusseldorf>(tree) ;
	map<string, Metadata> id_to_name = load_map(annotation);
	//0:GERMANY, 1:NON_GERMANY
	cost_type cost = {0,1,1,0};

	cerr << "metadata loaded" << endl;

	int count_dusseldorf = 0, count_nondusseldorf = 1;
	map<string, State_Dusseldorf> isolate_matrix;
	for (auto const &i: id_to_name) {
		vector<string> loc = split(i.second.location + "/" + i.second.location_add, '/');
		if (loc.size() >= 4 && trim(loc[1]) == "Germany" && trim(loc[2]) == "North Rhine-Westphalia" && startsWith(trim(loc[3]), "Dusseldorf")) {
			isolate_matrix[i.first] = State_Dusseldorf::State_Dusseldorf_Type::DUSSELDORF;
			count_dusseldorf++;
		} else {
			isolate_matrix[i.first] = State_Dusseldorf::State_Dusseldorf_Type::NON_DUSSELDORF;
			count_nondusseldorf++;
		}
	}

	cerr << "Dusseldorf cnt=" << count_dusseldorf << " non-cnt=" << count_nondusseldorf << endl;

	//cerr << "isolate_matrix:" << isolate_matrix << endl;
	//cerr << "cost" << cost << endl;

	phylo.set_tip_location(isolate_matrix);

	//phylo.annotation= "location=Germany";

	phylo.sankoff(cost);
	phylo.sankoff2(-1, cost);
	//phylo.print(cerr);

	int removed_count = 0;
	//ofstream fo(splitted_tree_prefix + "1" + ".trees");
	phylo.remove_invalid_children(id_to_name, removed_count);


	ofstream fo(output);
	phylo.print(fo) << ";" << endl;

	cerr << "output saved on " << output<< " " << endl;
	return 0;
}
