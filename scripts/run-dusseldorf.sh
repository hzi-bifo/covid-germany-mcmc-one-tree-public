scripts/phylogeo_sankoff_general --metadata data/metadata-gisaid-20210325.tsv --in  data/gisaid-20210324/timetree.nexus --out "results/gisaid-20210324-dusseldorf-timed.trees" --location_label Dusseldorf nonDusseldorf --merge --cond 2 "==" Germany 4 ">=" Dusseldorf

mkdir results/trees-gisaid-20210324-dusseldorf/
rm    results/trees-gisaid-20210324-dusseldorf/*
./scripts/split_tree_general --metadata data/metadata-gisaid-20210325.tsv --in "results/gisaid-20210324-dusseldorf-timed.trees" --out "results/trees-gisaid-20210324-dusseldorf/gisaid-20210324-" -l Dusseldorf nonDusseldorf

### 20210422
## data/mmsa_2021-04-18.tar.xz
DEPRICATED, run ../run-state.sh with appropriate arguments, specified in ../run.sh
exit(0)
./scripts/phylogeo_sankoff_general --in data/gisaid-20210417.tree --out "results/gisaid-20210417-all.tree" --metadata data/gisaid-20210421-metadata.tsv --location_label Germany nonGermany --cond 2 "==" Germany
treetime --tree results/gisaid-20210417-all.tree --dates data/gisaid-20210421-metadata.tsv --outdir data/gisaid-20210417/ --name-column "Accession ID" --date-column "Collection date"  --sequence-length 29811 --keep-root --clock-rate 7.5e-4

./scripts/phylogeo_sankoff_general --in data/gisaid-20210417/timetree.nexus --out "results/gisaid-20210417-dusseldorf-timed.trees"  --metadata data/gisaid-20210421-metadata.tsv --location_label --location_label Dusseldorf nonDusseldorf --merge --cond 2 "==" Germany 4 ">=" Dusseldorf

mkdir results/trees-gisaid-20210417-dusseldorf/
rm    results/trees-gisaid-20210417-dusseldorf/*
./scripts/split_tree_general --metadata data/gisaid-20210421-metadata.tsv --in results/gisaid-20210417-dusseldorf-timed.trees --out "results/trees-gisaid-20210417-dusseldorf/gisaid-20210417-" -l Dusseldorf nonDusseldorf

