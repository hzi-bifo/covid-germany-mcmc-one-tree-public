args = commandArgs(trailingOnly=TRUE)

DATE_METADATA <- args[1]
DATE_TREE <- args[2]
STATE <- args[3]

metadata <- read.table(paste0("data/gisaid-",DATE_METADATA,"-metadata.tsv"), sep="\t", head=TRUE, na.strings=c("NA", ""), fill=TRUE, stringsAsFactors=FALSE, quote="|")
dates <- read.table(paste0("data/gisaid-",DATE_TREE,"-", STATE, "-cont/dates_corrected.tsv"), sep="\t", head=TRUE, na.strings=c("NA", ""), fill=TRUE, stringsAsFactors=FALSE, quote="|")
metadata_new <- merge(metadata, dates, by.x="Accession.ID", by.y="sample", all.x=TRUE)
metadata_new$date_corrected[is.na(metadata_new$date_corrected)] = metadata_new$Collection.date[is.na(metadata_new$date_corrected)]
write.table(metadata_new, paste0("data/gisaid-",DATE_TREE,"-", STATE, "-cont/metadata-gisaid-",DATE_METADATA,".tsv"), sep="\t", quote=FALSE)

