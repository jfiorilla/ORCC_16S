library(dada2)
n_cores <- 18

path <- "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/fastp-cutadapt" 

# Forward and reverse fastq filenames
fnFs <- sort(list.files(path, pattern="_R1_trim.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="_R2_trim.fastq", full.names = TRUE))
# Extract sample names
sample.names <- sub("_S[0-9]+_R[12]_trim\\.fastq$", "", basename(fnFs))

# Place filtered files in filtered/ subdirectory
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))
names(filtFs) <- sample.names
names(filtRs) <- sample.names

# Filter and truncation
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, trimLeft=20, truncLen=c(250,250),
              maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
              compress=TRUE, multithread=TRUE)
head(out)

# Learn non-random error rates made during sequencing in R1 and R2
errF = learnErrors(filtFs, nbases=1e8, multithread=TRUE)
errR <- learnErrors(filtRs, nbases=1e8, multithread=TRUE)

dadaFs <- dada(filtFs, err=errF, multithread=TRUE)
dadaRs <- dada(filtRs, err=errR, multithread=TRUE)

# Merge paired reads
mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)

# Make sequence table
seqtab <- makeSequenceTable(mergers)
dim(seqtab)

write.csv(seqtab, file="/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV.csv")

# Remove chimeras
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
dim(seqtab.nochim)
sum(seqtab.nochim)/sum(seqtab)

write.csv(seqtab.nochim, file="/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.csv")

# Track number of reads
getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
head(track)

write.csv(track, file="/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/read_tracker.csv")

# Taxonomy
taxa = assignTaxonomy(seqtab.nochim, "/project/pi_sarah_gignouxwolfsohn_uml_edu/BEL_16S_ITS2_seqs/silva_nr99_v138.2_toGenus_trainset.fa.gz", multithread=TRUE)
dim(taxa)

write.csv(taxa, file="/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/taxa.csv")