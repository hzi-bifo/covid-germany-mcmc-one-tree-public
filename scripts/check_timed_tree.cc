#include "tree.h"
#include "state.h"
#include <boost/program_options.hpp>
#include "metadata.h"

namespace po = boost::program_options;

typedef int Data;
array<string, StateInOut::size> StateInOut::names = {"UK", "nonUK"};
typedef Node<StateInOut, Data> INode;

struct SampleDate {
	string sample;
	string date;
	double year;
	SampleDate(string _sample="", string _date="", double _year=0) : sample(_sample), date(_date), year(_year) {}
};
ostream& operator<<(ostream& os, const SampleDate& d) {
	return os << "[" << d.sample << ":" << d.date << "," << d.year << "]";
}
istream& operator>>(istream& is, SampleDate& d) {
	return is >> d.sample >> d.date >> d.year;
}

template<typename STATE>
struct Checker {
	const map<string, Metadata>& metadata;
	const map<string, SampleDate>& dates;
	int removed_count;
	bool is_root_fixed;
	double root_year;
	map<string, string> date_corrected;
	Checker(const map<string, Metadata>& _metadata = map<string, Metadata>(),
		const map<string, SampleDate>& _dates = map<string, SampleDate>()) : metadata(_metadata), dates(_dates), removed_count(0), 
		is_root_fixed(false), root_year(0), date_corrected() {}

	int info_incompatible_tree_metadata_cnt = 0,
		info_incompatible_tree_dates_cnt = 0,
		info_incompatible_tree_non_bad_dates_cnt = 0;


	void check(const Node<STATE>& n, double h = 0) {
		auto d = dates.find(n.label);
		if (!is_root_fixed) {
			if (d != dates.end()) {
				is_root_fixed = true;
				root_year = d->second.year + h;
			}
		}
		if (is_root_fixed) {
			double y = metadata.find(n.label) != metadata.end() ? date_to_year(metadata.find(n.label)->second.date) : -1;
			if ((y != -1 && abs(root_year + h - y) > 1e-2) || (d != dates.end() && d->second.date != "--" && abs(root_year + h - d->second.year) > 1e-2)) {
				//cerr << "W: incompatible date " << n.label << " h(tree):" << root_year + h << " h:" << h << " ";
				if (y != -1) {
				//	cerr << " " << metadata.find(n.label)->second.date << " date:" << y << " ";
					info_incompatible_tree_metadata_cnt++;
				}
				if (d != dates.end()) {
				//	cerr << d->second;
					info_incompatible_tree_dates_cnt++;
					if (d->second.date != "--")
						info_incompatible_tree_non_bad_dates_cnt++;
				}
				//cerr << endl;
			}
			date_corrected[n.label] = year_to_date(root_year + h);
		}
		for (auto &c: n.children) {
			check(c, h + c.branch_length);
		}
	}
};


int main(int argc, char* argv[]) {

	// Declare the supported options.
	po::options_description desc("Allowed options");
	desc.add_options()
	    ("help", "Run sankoff")
	    ("metadata", po::value<string>(), "metadata file")
	    ("dates", po::value<string>(), "metadata file")
	    ("in", po::value<string>(), "input tree")
	    ("location_label", po::value<vector<string>>()->multitoken(), "location labels, e.g. Germany nonGermany")
	;

	po::variables_map vm;
	po::store(po::parse_command_line(argc, argv, desc), vm);

	try {
		po::notify(vm);
	} catch (std::exception& e) {
		std::cerr << "Error: " << e.what() << "\n";
		return 1;
	}

	map<string, SampleDate> dates;
	ifstream fi(vm["dates"].as<string>());
	for (string line; getline(fi, line); ) {
		istringstream is(line.c_str());
		if (line[0] != '#') {
			SampleDate d;
			is >> d;
			dates[d.sample] = d;
			//cerr << d << endl;
		}
	}

	map<string, Metadata> metadata = load_map(vm["metadata"].as<string>());

	StateInOut::names = {vm["location_label"].as<vector<string>>()[0], vm["location_label"].as<vector<string>>()[1]};

	string tree_file_name = vm["in"].as<string>();
	Node<StateInOut,Data> phylo = load_tree<INode>(tree_file_name) ;

	Checker<StateInOut> checker(metadata, dates);
	checker.check(phylo);

	cout << "sample" << "\t" << "date_corrected" << endl;
	for (auto & it : checker.date_corrected) {
		cout << it.first << "\t" << it.second << endl;
	}

	cerr << "W: metadata!=" << checker.info_incompatible_tree_metadata_cnt 
		<< " dates!=" << checker.info_incompatible_tree_dates_cnt 
		<< " dates[!'==']!=" << checker.info_incompatible_tree_non_bad_dates_cnt  <<endl;

	return 0;
}
