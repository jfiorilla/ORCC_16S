## 9.8.2026 - md5 check
Used [Brooke's script](https://github.com/brookewicz/CBC_metagenomics/blob/db0de23907d5382e904fa32af875cc5fb6519d64/all_sctld/sampleinfo/md5check.txt) to check files were downloaded without corruption (success!)
- Her code has a double `#!/bin/bash` that threw an error
>Output: [slurm-checksum-64092117](QC-outputs/slurm/slurm-checksum-64092117.out), [md5_checksums.txt](QC-outputs/md5_checksums.txt)  

## 9.16.2026 - QC on raw files
### Conda
Conda environment `seqproc-env` that has fastqc, multiqc, and trim galore packages
- Created in my metagenomic workflow
```
module load conda/latest
conda activate seqproc-env
```

### FastQC
Moved fastq.gz files into a separate directory using a for loop:
```
for filename in *.fastq.gz
	do echo $filename
	mv $filename fastq ## moves file to existing directory "fastq"
done
```
- Wrote script within terminal using [`nano`](https://linuxize.com/post/how-to-use-nano-text-editor/) text editor
>Output: [sampleids.txt](QC-outputs/sampleids.txt) 

### MultiQC
>Output: [raw html report](QC-outputs/multiqc-reports/raw.html)

## 9.17.2026 - try trim galore on 16S sequences
After talking with SGW, plan is to follow [DADA2](https://benjjneb.github.io/dada2/) pipeline which recommends trimmomatic or cutadapt tools, but I thought I'd also try trim galore since I already have a tested script for that from my metagenomics QC workflow.
### Trim galore
Combined both Nikea's [metagenomic workflow](https://github.com/nikeaulrich/Metagenomics_workflow/blob/fcfd850453887a23301e5d07c220aab7c9972994/0_QC.ipynb) and Julia's [RNAseq workflow](https://github.com/jgmcdonough/CE24_RNA-seq/blob/d5c6e46913b5a4067e697677178ea129e5e5aa8f/processing/processing_seqs.ipynb) 
- Trims adapters from the 3' tail
- Also produces a samplesid.txt file, but realize now that I could have just set the `SAMPLE_NAMES_FILE` variable to the existing [sampleids](QC-outputs/sampleids.txt) created 9.16 from raw FastQC
>Output: [slurm-trimgalore-64527440](QC-outputs/slurm/slurm-trimgalore-64527440.out)

#### MultiQC
>Output: [trimgalore html report](QC-outputs/multiqc-reports/trimgalore.html)

Adapter content looks clean, some reads were also trimmed short...may want to investigate? 

## 9.21.2026 - first stab at using cutadapt
### Conda
Created new conda environment `cutadapt-env` that just has the cutadapt package
```
module load conda/latest
conda create --name cutadapt-env
conda activate cutadapt-env
conda install -c bionconda cutadapt
```

### Cutadapt
Pieced together trim-galore script, some of Caroline's [16S workflow](https://github.com/cdesouza02/BEL_16S_ITS2/blob/51f1b7652672009b21ec146c69977494d83159f5/scripts/2_cutadapt_trim), and some of SGW's [16S workflow](https://github.com/sagw/DE_micro/blob/fe607fcbdcdb33eff0e052d0e7483907e0471a56/QC_Run1.ipynb)
- Trimming from 5' end using `-g` and `-G` flags to specify 515F and 608R primer sequences
>Output: [slurm-cutadapt-64671732](QC-outputs/slurm/slurm-cutadapt-64671732.out)

### FastQC
>Output: [slurm-fastqc-cutadapt-64675148](QC-outputs/slurm/slurm-fastqc-cutadapt-64675148.out)

### MultiQC
>Output: [cutadapt html report](QC-outputs/multiqc-reports/cutadapt.html)  

Comparing the trim galore and cutadapt multiqc, they appear to have trimmed differently, which was expected since as far as I'm aware, trim galore will only cut the Illumina adapters (see slurm) and won't recognize the 16S primers. 
- **Cutadapt** 
	- Some samples were not trimmed at all, still 301bp in length
	- Adapter content plot looks, at first glance, comparable to the raw fastq multiqc report
- **Trim galore**
	- All samples except undetermined sequences were trimmed to ~290bp, Illumina adapters are ~63bp
	- Adapter content plots look much cleaner
Using `head` and a difference checker, definitely apparent that trim galore did not touch the 16S primers while cutadapt did cut the primers, at least for 2024_Both01_Both01_O1_gill_S28_R1. The only other difference is that trim galore is missing/cutadapt retained a consistent CTGTCTC at the end of each line (3' end). Comparing to the raw fastq, this CTGTCTC is also present, so it seems like trim galore purposefully cuts this sequence. 
- This 7bp sequence is part of the [Illumina/Nextera adapter](https://support-docs.illumina.com/SHARE/AdapterSequences/Content/Nextera_Illumina-Sequences.htm) *CTGTCTC*TTATACACATCT
- Amplicon of interest is only 291bp so the fact that we have reads that are 301bp long means that some of the adapter on the 3' end will be included in the sequences—that sequence needs to be trimmed and/or a read length filter needs to be applied 

Looking at individual fastq reports, cutadapt also has lower base quality around 60-100bp whereas trim galore looks much cleaner up through 290bp, but not sure why.
## 9.26.2026 - adjusting cutadapt and trim galore
### Cutadapt
Adjusted script to include `--nextseq-trim=20` to account for NextSeq poly-G tails when quality trimming and `--overlap 2` which overrides the default of needing three matching base pairs to identify adapters (from SGW's [code](https://github.com/sagw/DE_micro/blob/fe607fcbdcdb33eff0e052d0e7483907e0471a56/QC_Run1.ipynb)) . 
>Output: [slurm-cutadapt-64904065](QC-outputs/slurm/slurm-cutadapt-64904065.out)  
>Directory: cutadapt_quality

#### FastQC
>Output: [slurm-fastqc-cutadapt-65023371](QC-outputs/slurm/slurm-fastqc-cutadapt-65023371.out)  

#### MultiQC
>Output: [cutadapt_quality html report](QC-outputs/multiqc-reports/cutadapt_quality.html)

Sequence length got messed up based on one of the two flags I added, some are trimmed to <100bp! GC content was better though (I think?)...the overlap flag might have made things weird?

### Trim galore
Looking at the trim galore slurm I realized that the adapters auto-detected were nextera not illumina so going to try to force that by adding the flag `--illumina` and will also add `--nextseq 20` to account for the NextSeq poly-G tails when quality trimming.
- May be redundant to do trim galore then cutadapt if cutadapt can manage both 5' and 3' trimming at once, but still intrested to see these results/if forcing the illumina adapters makes any difference
>Output: [slurm-trimgalore-64906360](QC-outputs/slurm/slurm-trimgalore-64906360.out)  
>Directory: trimgalore_illumina

#### MultiQC (9.29)
>Output: [trimgalore_illumina html report](QC-outputs/multiqc-reports/trimgalore_illumina.html)  

Not many samples had Illumina adapter; SGW was probably right, that when the sequencer demultiplexes they also end up trimming the 5' adapter. Going to move away from trim galore for 16S now since I'm more confident what I need can be accomplished through cutadapt alone. 
- Seems like trim galore gets rid of a variety of adapters, whereas cutadapt you have to specify what you want to keep or remove which makes sense since tirm galore is just a wrapper for cutadapt

## 9.29.26 - add nextera adapter sequences to cutadapt
### Cutadapt 
A new modification to [cut-adapt](bash-scripts/cut-adapt) to include the [nextera transposase adapters](https://support-docs.illumina.com/SHARE/AdapterSequences/Content/Nextera_Illumina-Sequences.htm) that trim galore automatically identified (added the flags `--a CTGTCTCTTATA` and `--A CTGTCTCTTATA`). Kept the poly-G aware quality trimming and overlap.
>Output: [slurm-cutadapt-65026069](QC-outputs/slurm/slurm-cutadapt-65026069.out) 
>Directory: cutadapt_quality_adapters

#### FastQC (cutadapt 9.29)
>Output: [slurm-fastqc-cutadapt-65049526](QC-outputs/slurm/slurm-fastqc-cutadapt-65049526.out)

#### MultiQC (cutadapt 9.29)
>Output: [cutadapt_quality_adapters html report](QC-outputs/multiqc-reports/cutadapt_quality_adapters.html)

Remaining adapter contamination, but it's weird because there is adapter found at 50bp so if I trim those (which cutadapt didn't do anyway, maybe because not at 3' tail) I will have very short reads...

## 10.1.26 try fastp to remove adapters
### Fastp
>Output: [slurm-fastp-65117744](QC-outputs/slurm/slurm-fastp-65117744.out)
>Directory: fastp

#### FastQC
>Output: [slurm-fastqc-fastp-65174707](QC-outputs/slurm/slurm-fastqc-fastp-65174707.out)

#### MultiQC
>Output: 

## 10.2.26 two step trim galore/fastp then cutadapt
### Cutadapt (with trim galore)
Use cutadapt without quality or adapter flags (only 5' primer sequences) on the fastq files that were first processed by trim galore.
>Output: [slurm-cutadapt-65150120](QC-outputs/slurm/slurm-cutadapt-65150120.out)  
>Directory: trimgalore-cutadapt

#### FastQC
>Output: [slurm-fastqc-cutadapt-65159048](QC-outputs/slurm/slurm-fastqc-cutadapt-65159048.out)

#### MultiQC
>Output: [trimgalore-cutadapt](QC-outputs/multiqc-reports/trimgalore-cutadapt.html)

No significant adapter content, but sequence length is still a bit all over the place. The trim galore fasq files used from 9.17 also had some short (~20bp) reads. Are these ones that I should just filter out before proceeding with the DADA2 pipeline? 

### Cutadapt (with fastp)
Use cutadapt without quality or adapter flags (only 5' primer sequences) on the fastq files that were first processed by fastp.
>Output: [slurm-cutadapt-65175878](QC-outputs/slurm/slurm-cutadapt-65175878.out)
>Directory: fastp-cutadapt

#### FastQC


#### MultiQC