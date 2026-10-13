library(dada2)
n_cores <- 18

# Load csv from dada2.r script
seqtab.nochim <- read.csv("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.csv")

# Assign taxa to species
taxa.species <- assignSpecies(seqtab.nochim, "/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/silva_nr99_v138.2_toSpecies_trainset.fa.gz", allowMultiple=TRUE)

# Save taxa table
saveRDS(taxa.species, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_assignSpecies.rds")
write.csv(taxa.species, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_assignSpecies.csv", quote = FALSE)

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

