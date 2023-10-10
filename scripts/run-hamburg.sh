scripts/phylogeo_sankoff_general --metadata data/metadata-gisaid-20210325.tsv --in  data/gisaid-20210324/timetree.nexus --out "results/gisaid-20210324-hamburg-timed.trees" --location_label Hamburg nonHamburg --merge --cond 2 "==" Germany 3 ">=" Hamburg

mkdir results/trees-gisaid-20210324-hamburg/
rm    results/trees-gisaid-20210324-hamburg/*
./scripts/split_tree_general --metadata data/metadata-gisaid-20210325.tsv --in "results/gisaid-20210324-hamburg-timed.trees" --out "results/trees-gisaid-20210324-hamburg/gisaid-20210324-" -l Hamburg nonHamburg
