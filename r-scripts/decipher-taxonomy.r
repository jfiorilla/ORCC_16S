# Load packages
library(dada2)
library(DECIPHER)

# Load csv
seqtab.nochim <- read.csv("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.csv", 
                          row.names = 1, check.names = FALSE)
seqtab.nochim <- as.matrix(seqtab.nochim)
storage.mode(seqtab.nochim) <- "numeric"

#  -- AI, turn CSV into format required by dada2
# -- Save as an RDS object next time rather than a csv and use lines below

# Load RDS from ASV-table.r
# seqtab.nochim <- readRDS("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.rds")

# Create a DNAStringSet from the ASVs
dna <- DNAStringSet(getSequences(seqtab.nochim)) 

# Load training set
load("/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/SILVA_SSU_r138.2_v2.RData") 

# Use all processors
ids <- IdTaxa(dna, trainingSet, strand="top", processors=NULL, verbose=FALSE) 

# Ranks of interest
ranks <- c("domain", "phylum", "class", "order", "family", "genus", "species") 

# Convert the output object of class "Taxa" to a matrix analogous to the output from assignTaxonomy
taxid <- t(sapply(ids, function(x) {
        m <- match(ranks, x$rank)
        taxa <- x$taxon[m]
        taxa[startsWith(taxa, "unclassified_")] <- NA
        taxa
}))
colnames(taxid) <- ranks; rownames(taxid) <- getSequences(seqtab.nochim)

# Check taxa table
taxa.print <- taxid # Removing sequence rownames for display only
rownames(taxa.print) <- NULL
head(taxa.print)

# Save taxa table
saveRDS(taxid, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/decipher_taxa_sp.rds")
print("Saved species RDS")

# Bonus, save csv version
write.csv(taxid, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/decipher_taxa_sp.csv", quote = FALSE)
print("Saved species csv")