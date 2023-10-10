#!/usr/bin/env Rscript

library("ape")
#library("readr")
#library("MASS")

args = commandArgs(trailingOnly=TRUE)
phylo_file = args[1]
augur_json_file = args[2]
output_json_file = args[3]
date_file = args[4]

#phylo_file <- "/home/sreimering/repos/VirusTracker/reconstructions/cov2020_reconstructed.phy"
#augur_json_file <- "/home/sreimering/repos/VirusTracker/auspice/ncov2_fasttree_original.json"
#output_json_file <- "/home/sreimering/repos/VirusTracker/auspice/ncov2_dates.json"
#date_file <- "/home/sreimering/repos/VirusTracker/augur_adjustment/cov2020_dates.tsv"

get_div <- function(phylo, node){
  # takes a tree and a node label and outputs the summed branch length from the root to that node
  all_label <- c(phylo$tip.label, phylo$node.label)
  node_number <- which(all_label == node)
  
  # initialize as 0
  div <- 0
  
  stop <- 0
  id <- node_number
  
  # traverse from the current node to the root and sum up all edge lengths
  while(stop == 0){
    # look for incoming edges
    position <- which(phylo$edge[,2] == id)
    
    # if no incoming edge: current node is the root (leave the while loop)
    if (length(position) == 0) {
      stop <- 1;
    } else{
      # if not root: get length of the edge
      # HADI: this is the true one, following line is for debug 
      div <- div + phylo$edge.length[position]
      # div <- div + 1
    }
    # if there is an incoming edge: get id of next node
    id <- phylo$edge[position, 1];
  }
  return(div)
}


# read data

phylo <- read.tree(phylo_file)
json <- readLines(augur_json_file)

dates <- read.csv2(date_file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

# open file to print output to
sink(output_json_file)

# find line where the tree starts
tree_start <- which(grepl("\"tree\": {", json, fixed = TRUE))

# paste everything before the tree without any adjustments
for (i in 1:(tree_start-1)){
  cat(paste(json[i], "\n", sep = ""))
}

# in the tree: add div info for each node
skip <- FALSE

for (i in tree_start:length(json)){
  if (skip == TRUE){
    #if (grepl("\"node_attrs\": \\{\\}", json[i])) {
    #cat(paste("\"node_attrs\": {", "\n", sep = ""))
    #cat(paste("\"div\": ", div, ",\n", sep = ""))
    #cat(paste("\"num_date\": {\n", "\"value\": ", date, "\n},\n", sep = ""))
    #cat(paste("}", "\n", sep = ""))
    #} else {
    cat(paste(json[i], "\n", sep = ""))
    cat(paste("\"div\": ", div, ",\n", sep = ""))
    cat(paste("\"num_date\": {\n", "\"value\": ", date, "\n},\n", sep = ""))
    #}
    skip <- FALSE
    next
  }
  
  # search for lines with a node name
  if (grepl("\"name\": \".*\",", json[i])){
    # extract node name
    name <- gsub("[[:space:]]*\"name\": \"(.*)\",", "\\1", json[i])
    # calculate div (summed branch lengths)
    div <- get_div(phylo, name)
    date <- dates$dates[which(dates$label == name)]
    #cat(div)
    skip <- TRUE
  }
  
  cat(paste(json[i], "\n", sep = ""))
}

sink()
