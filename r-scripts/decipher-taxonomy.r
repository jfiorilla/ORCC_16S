library(DECIPHER)
library(dada2)
n_cores <- 18

# Load csv from dada2.r script
seqtab.nochim <- read.csv("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.csv")

dna <- DNAStringSet(getSequences(seqtab.nochim)) # Create a DNAStringSet from the ASVs
load("/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/SILVA_SSU_r138.2_v2.RData") # CHANGE TO THE PATH OF YOUR TRAINING SET
ids <- IdTaxa(dna, trainingSet, strand="top", processors=NULL, verbose=FALSE) # use all processors
ranks <- c("domain", "phylum", "class", "order", "family", "genus", "species") # ranks of interest
# Convert the output object of class "Taxa" to a matrix analogous to the output from assignTaxonomy
taxid <- t(sapply(ids, function(x) {
        m <- match(ranks, x$rank)
        taxa <- x$taxon[m]
        taxa[startsWith(taxa, "unclassified_")] <- NA
        taxa
}))
colnames(taxid) <- ranks; rownames(taxid) <- getSequences(seqtab.nochim)

taxa <- taxid

# Check taxa table
taxa.print <- taxa # Removing sequence rownames for display only
rownames(taxa.print) <- NULL
head(taxa.print)

# Save taxa table
saveRDS(taxa, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_decipher.rds")
write.csv(taxa, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_decipher.csv", quote = FALSE)

# Compare taxa to the mock Zymo mock community positive control
unqs.mock <- seqtab.nochim["Positive_control_NA",]
unqs.mock <- sort(unqs.mock[unqs.mock>0], decreasing=TRUE) # Drop ASVs absent in the Mock
cat("DADA2 inferred", length(unqs.mock), "sample sequences present in the Mock community.\n")

#### AI
# Path to the folder containing expected reference FASTA files (provided by Zymo)
ref_dir <- "/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/ZymoBIOMICS.STD.refseq.v2/Genomes"
# List all FASTA files in the folder (including subfolders)
fasta_files <- list.files(
  ref_dir,
  pattern = "\\.(fasta|fa|fna|fas)$",
  full.names = TRUE,
  recursive = TRUE,
  ignore.case = TRUE
)
# Read and combine all reference sequences
mock.ref <- unlist(lapply(fasta_files, getSequences), use.names = FALSE)
# Count ASVs that exactly match at least one reference sequence
match.ref <- sapply(names(unqs.mock), function(x) {
  any(x == mock.ref)
})

cat("Of those,", sum(match.ref),
    "were exact matches to the expected reference sequences.\n")
####

