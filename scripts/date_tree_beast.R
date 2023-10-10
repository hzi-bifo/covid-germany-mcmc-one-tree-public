#!/usr/bin/env Rscript

# date tree

library("ape")
args = commandArgs(trailingOnly=TRUE)
phylo_file = args[1]
metadata_file = args[2]
output_dates = args[3]

#phylo_file <- "/home/sreimering/repos/VirusTracker/augur_adjustment/cov2020_reconstructed.phy"
#metadata_file <- "/home/sreimering/repos/VirusTracker/augur_adjustment/cov2020_processed_adjusted.tsv"
#output_dates <- "/home/sreimering/repos/VirusTracker/augur_adjustment/cov2020_dates.tsv"

phylo <- read.tree(phylo_file)
metadata <- read.csv2(metadata_file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
if (!("strain" %in% colnames(metadata)) && "Virus.name" %in% colnames(metadata)) {
	metadata$strain = metadata$Virus.name
}
if (!("date" %in% colnames(metadata)) && "Collection.date" %in% colnames(metadata)) {
	metadata$date = metadata$Collection.date
}
#print(colnames(metadata))
#exit()

n_tips <- length(phylo$tip.label)
node_dates <- vector(mode = "character", length = n_tips)

# get all dates (same order as tip labels)
for (i in 1:n_tips){
  if (length(which(metadata$strain == phylo$tip.label[i])) == 0) {
    if (length(which(metadata$strain == paste('hCoV-19/', phylo$tip.label[i], sep=''))) == 0) {
      print(c(phylo$tip.label[i], paste('hCoV-19/', phylo$tip.label[i], sep=''), i))
    }
  }
}
for (i in 1:n_tips){
  if (length(which(metadata$strain == phylo$tip.label[i])) != 1) {
    if (length(which(metadata$strain == paste('hCoV-19/', phylo$tip.label[i], sep=''))) != 1) {
      if (length(which(metadata$strain == paste('hCoV-19/', phylo$tip.label[i], sep=''))) == 0) {
      print(c(phylo$tip.label[i], paste('hCoV-19/', phylo$tip.label[i], sep='')))
      #print(metadata$strain)
      #halt()
      } else {
        node_dates[i] <- metadata$date[which(metadata$strain == paste('hCoV-19/', phylo$tip.label[i], sep=''))[1]]
      }
    } else {
      #print(c(phylo$tip.label[i], paste('hCoV-19/', phylo$tip.label[i], sep='')))
      node_dates[i] <- metadata$date[which(metadata$strain == paste('hCoV-19/', phylo$tip.label[i], sep=''))]
    }
  } else {
    node_dates[i] <- metadata$date[which(metadata$strain == phylo$tip.label[i])]
  }
}

# transform dates into numeric values
node_dates_num <- vector(mode = "numeric", length = n_tips)

for (i in 1:length(node_dates)){
  date <- strsplit(node_dates[i], "-", fixed = TRUE)
  year <- as.numeric(date[[1]][1])
  # transform month and day into year
  month <- (as.numeric(date[[1]][2])-1)/12
  day <- (as.numeric(date[[1]][3])-1)/365
  
  # if no month or day given, set to 0
  if (is.na(month)){
    month <- 0
  }
  
  if (is.na(day)){
    day <- 0
  }
  
  year_num <- year + month + day
  node_dates_num[i] <- year_num
}

# print(node_dates_num)
# estimate dates for internal nodes
mu <- estimate.mu(phylo, node_dates_num)
print(paste('Estimated mu', mu))
#mu <- 360.321345135183 * 5
#mu <- mu * 5
print(paste('Estimated mu 2=MAKE IT CORRECT', mu))
#g <- glm(node.depth.edgelength(phylo)[1:length(node_dates_num)] ~ node_dates_num)
#print(g)
dates <- estimate.dates(phylo, node_dates_num, mu = abs(mu), nsteps = 1000)
print('Estimated dates')

print('Estimating done')
date_data <- data.frame(c(phylo$tip.label, phylo$node.label), dates)
names(date_data) <- c("label", "dates")

write.table(date_data, output_dates, row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE)
