# Load package
library(dada2)

# Set threads to number parametized in slurm
threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

# Assign taxonomy using dada2 and PhytoREF database
chlor_tax <- assignTaxonomy("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/chloroplast_ASVs.fasta", "/work/pi_sarah_gignouxwolfsohn_uml_edu/jade/pr2_version_5.1.1_SSU_dada2.fasta.gz", multithread = TRUE, minBoot = 50)

saveRDS(chlor_tax, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa_chlor.rds")

