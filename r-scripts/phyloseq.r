# Load packages
library(phyloseq)
library(Biostrings)
library(tidyverse)

# Read ASV table
seqtab.nochim <- readRDS("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim_2.rds")

# Read taxonomy table
taxaDecipher <- readRDS("/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/decipher_taxa_sp.rds")

# Read tidied metadata
samples <- read.csv("/project/pi_sarah_gignouxwolfsohn_uml_edu/jade/ORCC_16S/metadata/metadata_samples.csv", row.names=NULL)

head(seqtab.nochim)
head(taxaDecipher)
head(samples)

# Construct phyloseq object
psObject <- phyloseq(otu_table(seqtab.nochim, taxa_are_rows = FALSE),
                     sample_data(samples),
                     tax_table(taxaDecipher))
psObject

saveRDS(psObject, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/psObject.rds")

# Save ASV sequences but rename with short names for downstream analysis
dna <- Biostrings::DNAStringSet(taxa_names(ps))
names(dna) <- taxa_names(ps)
ps <- merge_phyloseq(ps, dna)
taxa_names(ps) <- paste0("ASV", seq(ntaxa(ps)))
ps

saveRDS(ps, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ps.rds")