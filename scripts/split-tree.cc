#include "tree.h"
#include "state.h"

template<typename STATE>
struct mul_to {
	float to;
	mul_to(float _to=1) : to(_to) {}
	
	void operator()(Node<STATE>& n) {
		n.branch_length *= to;
	}
};

array<string, StateInOut::size> StateInOut::names = {"UK", "nonUK"}; 

int main(int argc, char* argv[]) {
	//string tree = "results/all-c.trees";
	//tree = "results/all-sample2.phy";
	//string annotation = "data/dates_and_locations.tsv";
	//string splitted_tree_prefix = "results/trees/all-c-";
	//annotation = "data/dates_and_locations-sample.tsv";


	//tree = "results/gisaid-20210324-all-timed.trees";
	string tree = argv[1];
	//splitted_tree_prefix = "results/trees-gisaid-20210324-test/gisaid-20210324-";
	string splitted_tree_prefix = argv[2];
	string annotation = "data/metadata-gisaid-20210325.tsv";
	StateInOut::names = {argv[3], argv[4]};

	Node<STATE_GERMANY> phylo = load_tree<STATE_GERMANY>(tree);


	map<string, Metadata> metadata = load_map(annotation);
	cerr << "metadata loaded" << endl;

//	mul_to mul_to_5(1.0/5.0);
//	phylo.apply(mul_to_5);

	int int_index = 0;
	phylo.name_internal_nodes(int_index);

	//phylo.split_and_print(splitted_tree_prefix, index);
	NodePrinter<STATE_GERMANY> np(splitted_tree_prefix, 0, STATE_GERMANY(STATE_GERMANY::STATE_GERMANY_TYPE::GERMANY));
	np.find_and_print_lineage(phylo);

	int removed_count = 0;
	

	cerr << "Saved " << np.index << " trees with prefix " << splitted_tree_prefix << " removed nodes: " << removed_count << endl;
	return 0;
}

