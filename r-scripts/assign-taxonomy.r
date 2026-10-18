# Load package
library(dada2)

# Set threads to number parametized in slurm
threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

# Load csv
seqtab.nochim <- read.csv("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.csv",
                          row.names = 1, check.names = FALSE)
seqtab.nochim <- as.matrix(seqtab.nochim)
storage.mode(seqtab.nochim) <- "numeric"
# -- AI, turn CSV into format required by dada2
# -- Save as an RDS object next time rather than a csv and use lines below

# Load RDS from ASV-table.r
# seqtab.nochim <- readRDS("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.rds")

# Save ASV_nochim as RDS for future use
saveRDS(seqtab.nochim, /scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASVs_nochim.rds)
print("Saved ASV_nochim RDS")

# Assign taxa to genus
taxa <- assignTaxonomy(seqtab.nochim, "/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/silva_nr99_v138.2_toGenus_trainset.fa.gz", 
                       multithread=threads)
saveRDS(taxa, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_genus.rds")
print("Saved genus RDS")

# Check table
taxa.print <- taxa # Removing sequence rownames for display only
rownames(taxa.print) <- NULL
head(taxa.print)

# Add species information to genus table where possible
taxa <- addSpecies(taxa, "/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/silva_v138.2_assignSpecies.fa.gz")
saveRDS(taxa, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_species.rds")
print("Saved species RDS")

# Bonus, save csv version
write.csv(taxa, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_species.csv", quote = FALSE)
print("Saved species csv")