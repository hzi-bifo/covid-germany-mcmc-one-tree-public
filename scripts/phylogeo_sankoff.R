#!/usr/bin/env Rscript
# This script takes a phylogenetic tree, locations for the tips as well as a cost matrix with distances between all possible locations.
# The Sankoff algorithm is used to perform a parsimonious ancestral state reconstruction to infer locations for internal nodes.

### define functions

# implementation of the sankoff algorithm
# method: MP: for maximum parsimony, ML: for maximum likelihood (top-buttom fix not to max-likelihood)
#   MLG: for each vertex find the location that maximize likelihood of other parts of the tree
reconstruct_sankoff <- function(treeObject, cost, isolate_matrix, method = c('MP', 'ML', 'MLG'), tip_weight = NULL,
    valid_states = NULL){
  method <- match.arg(method);
  
  # reformat isolate matrix to make id to row names
  isolate_matrix <- data.frame(unstack(isolate_matrix, form=location~label))

  phylo <- as.phylo(treeObject)
  
  n_tips <- Ntip(phylo)
  n_nodes <- phylo$Nnode
  #n_nodes <- Nnode(phylo)
  n <- n_tips + n_nodes
  
  # values represent minimal cost in subtree starting at a specific node, given that it is assigned a specific state
  # rows: nodes, columns: states
  values <- matrix(data = NA, nrow = n, ncol = nrow(cost))
  colnames(values) <- colnames(cost)
  
  
  # for all other nodes: postorder traversal
  phylo <- reorder(phylo,"postorder")
  # internal nodes to traverse
  int_nodes <- unique(phylo$edge[,1])

  all_weight <- rep(1, n)
  if (!is.null(tip_weight)) {
    tip_length <- rep(0, n)
    tip_length[phylo$edge[,2]] <- phylo$edge.length[]
    all_weight[1:n_tips] <- tip_weight[phylo$tip.label[1:n_tips],] / exp(tip_length[1:n_tips])
    # calculate values for all internal nodes
    for (current_node in int_nodes) {
      # list of child nodes for current internal node
      child_nodes <- phylo$edge[phylo$edge[,1]==current_node,2]
      if (current_node %in% phylo$edge[,2])
        all_weight[current_node] = sum(all_weight[child_nodes]) / exp(tip_length[current_node])
    }
  }

  # reverse traversal to assign states
  states <- character(length = n)
  states[1:n_tips] <- isolate_matrix[phylo$tip.label[1:n_tips],1]
  #write(states, stderr())
  #write(all_weight, stderr())
  
    # initialize values for leaf nodes (0 for observed state, otherwise infinity)
    for (i in 1:n_tips) {
      values[i,] <- Inf
      if (isolate_matrix[phylo$tip.label[i],] %in% colnames(values))
        values[i, isolate_matrix[phylo$tip.label[i],]] <- 0
      else {
        values[i,] <- 0
        write(paste("tip bad state:", phylo$tip.label[i], isolate_matrix[phylo$tip.label[i],], i), stderr())
      }
    }
    # calculate values for all internal nodes
    for (current_node in int_nodes) {
      # list of child nodes for current internal node
      child_nodes <- phylo$edge[phylo$edge[,1]==current_node,2]
      
      # get minimal costs for each possible state
      for (loc in colnames(values)) {
	if (is.null(valid_states) || loc %in% valid_states) {
          sum_childs <- 0
          # sum over all child nodes
          for (child in child_nodes){
            sum_childs <- sum_childs + min(cost[loc,] + values[child,]) * all_weight[child]
          }
          values[current_node, loc] <- sum_childs
	} else {
          values[current_node, loc] <- Inf
	}
      }
      #write(paste("val:", current_node), stderr())
      #write(values[current_node,], stderr())
    }

    int_nodes <- rev(int_nodes)
    # state at root node is the one with the minimum cost
    root_options <- names(which(values[int_nodes[1],] == min(values[int_nodes[1],])))
    states[int_nodes[1]] <- root_options[1] # if more than one option, take first one
    
    # determine all other states
    for (current_node in int_nodes[2:length(int_nodes)]) {
      # get parent node
      parent <- states[phylo$edge[which(phylo$edge[,2] == current_node),][1]]
      # add minimum cost at current node with the cost of traveling from parent to child
      #write(paste("parent ", parent, sep=":"), stderr())
      current_costs <- cost[parent,] + values[current_node,]
      # possible states
      options <- names(which(current_costs == min(current_costs)))
      
      if (length(options) == 1){
        # state is the one that minimizes these values
        states[current_node] <- options
      } else {
        if (parent %in% options){
          # delayed transformation: take same location as the parent to delay changes
          states[current_node] <- parent
        } else {
          # if there is still more than one possibility: take first one
          states[current_node] <- options[1]
        }
      }
    }
    #print(values)
    #print(phylo$edge)
  
  # add internal node IDs
  node_label <- paste("intNode", int_nodes, sep="")
  names(node_label) <- int_nodes
  treeObject@phylo$node.label <- node_label

  # create annotation
  node_annotation <- data.frame(label=c(phylo$tip.label[1:n_tips], node_label), location=states)

  treeObject@data <- tibble("location" = states, node = c(1:n_tips, int_nodes))

  
  return(list(tree=treeObject, annotation=node_annotation))
}

# function to write tree and annotation
save_tree <- function(result, filename){
  source("script/write-beast.R")

  write.beast.newick(result$tree, paste(filename,".phy", sep=""))
  # write.tree replaces spaces in sequence names by underscores - do the same with annotation file
  result$annotation$label <- gsub(" ", "_", result$annotation$label)
  write.table(result$annotation, paste(filename, ".annotation.txt", sep=""), quote=FALSE, row.names=FALSE, sep="\t")
}


### load required packages

suppressPackageStartupMessages(library("optparse"))

### define input data

# parsing arguments
arguments <- parse_args(
  OptionParser(
    option_list = list( 
      make_option("--method", default="MP", 
          help = "Method [default \"%default\"] MP for maximum parsimony, ML for maximum likelihood")
      ,
      make_option("--airports", dest = "airports_file", default=NULL, 
                  help = "File showing valid airports")
      ,
      make_option("--sampleweight", default=NULL, 
                  help = "Weight for samples. Default: NA, for equal weights.")
      ,
      make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
        help="Print extra output [default]"
      ),
      make_option(c("-d", "--fix-diameter"), action="store_true", default=FALSE,
                  dest = "fix_diameter", help="Fix diameter of the cost matrix [default]"
      )
    )
  ), positional_arguments = 0)

args = arguments$args #commandArgs(trailingOnly=TRUE)
#tree <- args[1]
#tip_locations <- args[2]
#dist_matrix <- args[3]
#output <- args[4]
#method <- arguments$opt$method
#sample_weight_file <- arguments$opt$sampleweight
#output <- args[2]
tree <- 'data/ft_SH.tree'
#tree <- 'data/ft-sample_SH.tree'
output <- 'result/all'
annotation <- 'data/dates_and_locations.tsv'
#annotation <- 'data/dates_and_locations-sample.tsv'
method <- "MP"

### read data

library(ape)
library(tidytree)
#library("ape")      # package for phylogenetic trees
#phylo <- read.tree(tree)
library(treeio)
#phylo <- read.newick(tree)
phylo <- read.nhx(tree)


annotations <- read.table(annotation, sep="\t", head=TRUE, na.strings=c("NA", ""), fill=TRUE, stringsAsFactors=FALSE, quote="|")
id.name = sapply(annotations$Virus.name, function(v) { paste(strsplit(v, "/")[[1]][2:4], collapse="/")  } )
names(id.name) = annotations$Accession.ID
tip_weight <- NULL
valid_airports <- NULL

isolate_matrix = data.frame("label" = annotations$Accession.ID, "location" = factor(rep("nonGermany", length(id.name)), levels=c("Germany", "nonGermany")) )
isolate_matrix[unlist(lapply(as.character(annotations$Virus.name), function(v) {strsplit(v, "/")[[1]][2]} )) == "Germany", "location"] = "Germany"

cost <- matrix(c(0, 1, 1, 0), nrow=2, ncol=2, dimnames = list(c("Germany", "nonGermany"), c("Germany", "nonGermany")))

#
#isolate_matrix <- read.table(tip_locations, header = T, sep="\t", stringsAsFactors=FALSE, na.strings = "")
#cost <- as.matrix(read.csv(dist_matrix, header = TRUE, row.names = 1, check.names=FALSE, na.strings = ""))
#if (arguments$opt$fix_diameter) {
#  diag(cost) <- apply(cost, 1, sum)
#}
#colnames(cost)[which(is.na(colnames(cost)))] <- "NA"
#if (!is.null(sample_weight_file)) {
#  tip_weight <- read.table(sample_weight_file, header = TRUE, sep="\t", stringsAsFactors=FALSE, na.strings = NA, row.names = 1)
#} else {
#  tip_weight <- NULL
#}
#valid_airports <- NULL
#if (!is.null(arguments$opt$airports_file)) {
#  airports <- read.table(arguments$opt$airports_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE, na.strings = NA, row.names = 2)
#  valid_airports <- c(row.names(airports), isolate_matrix$location)
#  cost <- cost[(rownames(cost) %in% valid_airports), (colnames(cost) %in% valid_airports)]
#}

# check if all locations in isolate_matrix are in cost matrix
#if (!all(unique(isolate_matrix$location) %in% rownames(cost))){
#  stop("One or more locations in the tips are not in the distance matrix. Check your input.")
#}

### ancestral reconstruction of locations
phylo_reconstructed <- reconstruct_sankoff(phylo, cost, isolate_matrix, method = method, tip_weight = tip_weight, valid_states = valid_airports)

### save new tree and reconstructed locations
save_tree(phylo_reconstructed, output)
#save_tree(phylo, paste(output, "-o.phy", sep=""))
