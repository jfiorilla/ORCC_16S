# Load package
library(dada2)

# Load RDS from ASV-table.r
seqtab.nochim <- readRDS("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim_2.rds")

# Compare taxa to the Zymo mock community positive control
unqs.mock <- seqtab.nochim["Positive_control_NA",]
unqs.mock <- sort(unqs.mock[unqs.mock>0], decreasing=TRUE) # Drop ASVs absent in the Mock
cat("DADA2 inferred", length(unqs.mock), "sample sequences present in the Mock community.\n")

# -- AI, combine reference fasta files
ref_dir <- "/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/ZymoBIOMICS.STD.refseq.v2/Genomes"
fasta_files <- list.files(
  ref_dir,
  pattern = "\\.(fasta|fa|fna|fas)$",
  full.names = TRUE,
  recursive = TRUE,
  ignore.case = TRUE
)
mock.ref <- unlist(lapply(fasta_files, getSequences), use.names = FALSE)

# Count ASVs that exactly match at least one reference sequence
match.ref <- sapply(names(unqs.mock), function(x) {
  any(x == mock.ref)
})
cat("Of those,", sum(match.ref), "were exact matches to the expected reference sequences.\n")