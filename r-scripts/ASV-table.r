# Load package
library(dada2)

# Set threads to number parametized in slurm
threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

# Set path to trimmed fastq files
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
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(250,250),
              maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
              compress=TRUE, multithread=threads, verbose=TRUE)
head(out)

# Learn non-random error rates made during sequencing in R1 and R2
errF <- learnErrors(filtFs, multithread=threads)
errR <- learnErrors(filtRs, multithread=threads)
dadaFs <- dada(filtFs, err=errF, multithread=threads)
dadaRs <- dada(filtRs, err=errR, multithread=threads)

# Merge paired reads
mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)

# Make sequence table
seqtab <- makeSequenceTable(mergers)

# Inspect distribution of sequence lengths
dim(seqtab)
table(nchar(getSequences(seqtab)))
saveRDS(seqtab, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASVs.rds")
print("Saved ASV RDS")

# Remove chimeras
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=threads, verbose=TRUE)
dim(seqtab.nochim)
cat("Percent lost after removing chimeras:", sum(seqtab.nochim)/sum(seqtab))
saveRDS(seqtab.nochim, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/ASV_nochim.rds")
print("Saved ASV_nochim RDS")

# Track number of reads
getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
head(track)
write.csv(track, "/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/dada2/read_tracker.csv")