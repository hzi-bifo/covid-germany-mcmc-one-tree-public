#include "tree.h"
#include "state.h"

array<string, StateInOut::size> StateInOut::names = {"UK", "nonUK"}; 

int main(int argc, char* argv[]) {
	//string tree = "data/ft_SH.tree";
	//tree = "data/ft-sample_SH.tree";
	//string output = "results/all-c.trees";
	//string annotation = "data/dates_and_locations.tsv";
	//annotation = "data/dates_and_locations-sample.tsv";

	//string tree = "data/gisaid-20210324.tree";
	string tree = argv[1];
	//string output = "results/gisaid-20210324-all.trees";
	string output = argv[2];

	//tree = "data/gisaid-20210324/timetree.nexus";
	//output = "results/gisaid-20210324-all-timed.trees";
	string annotation = "data/metadata-gisaid-20210325.tsv";

	Node<STATE_GERMANY> phylo = load_tree<STATE_GERMANY>(tree) ;
	map<string, Metadata> id_to_name = load_map(annotation);
	//0:GERMANY, 1:NON_GERMANY
	cost_type cost = {0,1,1,0};

	map<string, STATE_GERMANY> isolate_matrix;
	for (auto const &i: id_to_name)
		isolate_matrix[i.first] = startsWith(trim(split(i.second.location, '/')[1]), "Germany") ? STATE_GERMANY::STATE_GERMANY_TYPE::GERMANY : STATE_GERMANY::STATE_GERMANY_TYPE::NON_GERMANY;

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
