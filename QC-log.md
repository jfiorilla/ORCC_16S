## 9.8.2026 - md5 check
Used [Brooke's script](https://github.com/brookewicz/CBC_metagenomics/blob/db0de23907d5382e904fa32af875cc5fb6519d64/all_sctld/sampleinfo/md5check.txt) to check files were downloaded without corruption (success!)
- Her code has a double `#!/bin/bash` that threw an error

>Command: `sbatch`  
>Script: [md5check](bash-scripts/md5check)  
>Output: [slurm-checksum-64092117](QC-outputs/slurm-checksum-64092117.out), [md5_checksums](QC-outputs/md5_checksums.txt)  

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

>Command: `sbatch`  
>Script: [fastqc](bash-scripts/fastqc)    
>Output: [sampleids.txt](sampleids.txt) (missing slurm)

### MultiQC
>Command: `multiqc .`  
>Output: [multiqc_raw](QC-outputs/multiqc-reports/multiqc_raw.html)

## 9.17.2026 - try trim galore on 16S sequences
After talking with SGW, plan is to follow [DADA2](https://benjjneb.github.io/dada2/) pipeline which recommends trimmomatic or cutadapt tools, but I thought I'd also try trim galore since I already have a tested script for that from my metagenomics QC workflow.
### Trim galore
Combined both Nikea's [metagenomic workflow](https://github.com/nikeaulrich/Metagenomics_workflow/blob/fcfd850453887a23301e5d07c220aab7c9972994/0_QC.ipynb) and Julia's [RNAseq workflow](https://github.com/jgmcdonough/CE24_RNA-seq/blob/d5c6e46913b5a4067e697677178ea129e5e5aa8f/processing/processing_seqs.ipynb) 
- Also produces a samplesid.txt file, but realize now that I could have just set the `SAMPLE_NAMES_FILE` variable to the existing file created during [raw FastQC](#FastQC) steps

>Command: `sbatch`   
>Script: [trim-galore](bash-scripts/trim-galore)  
>Output: [slurm-trimgalore-64527440](QC-outputs/slurm-trimgalore-64527440.out)

### MultiQC
>Command: `multiqc .`  
>Output: [multiqc_trimgalore](QC-outputs/multiqc-reports/multiqc_trimgalore.html)

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
Pieced together [trim-galore](bash-scripts/trim-galore) script, some of Caroline's [16S workflow](https://github.com/cdesouza02/BEL_16S_ITS2/blob/51f1b7652672009b21ec146c69977494d83159f5/scripts/2_cutadapt_trim), and some of SGW's [16S workflow](https://github.com/sagw/DE_micro/blob/fe607fcbdcdb33eff0e052d0e7483907e0471a56/QC_Run1.ipynb)

>Command: `sbatch`  
>Script: [cut-adapt](bash-scripts/cut-adapt)  
>Output: [slurm-cutadapt-64671732](QC-outputs/slurm-cutadapt-64671732.out)

### FastQC
>Command: `sbatch`  
>Script: [fastqc](bash-scripts/fastqc)  
>Output: [slurm-fastqc-cutadapt-64675148](QC-outputs/slurm-fastqc-cutadapt-64675148.out)

### MultiQC
Had to switch conda environments
```
conda deactivate
conda activate seqproc-env
```

>Comand: `multiqc .`  
>Output: [multiqc_cutadapt](QC-outputs/multiqc-reports/multiqc_cutadapt.html)  

Comparing the trim galore and cutadapt multiqc, they appear to have trimmed differently, which was expected since as far as I'm aware, trim galore will only cut the identified Illumina adapters (see slurm) and won't recognize the 16S primers automatically. 
- **Cutadapt** 
	- Some samples were not trimmed at all, still 301bp in length
	- Adapter content plot looks, at first glance, comparable to the raw fastq multiqc report
- **Trim galore**
	- All samples except undetermined sequences were trimmed to ~290bp, Illumina adapters are ~63bp
	- Adapter content plots look much cleaner
Using `head` and a difference checker, definitely apparent that trim galore did not touch the 16S primers while cutadapt did cut the primers at least for 2024_Both01_Both01_O1_gill_S28_R1. The only other difference is that trim-galore is missing/cutadapt retained a consistent CTGTCTC at the end of each line (3' end). Comparing to the raw fastq, this CTGTCTC is also present, so it seems like trim galore purposefully cuts this sequence. 
- This 7bp sequence is part of the [Illumina/Nextera adapter](https://support-docs.illumina.com/SHARE/AdapterSequences/Content/Nextera_Illumina-Sequences.htm) *CTGTCTC*TTATACACATCT

Looking at individual fastq reports, cutadapt has lower base quality around 60-100bp whereas trim galore looks much cleaner up through 290bp. 
## 9.26.2026 - adjusting cutadapt and trim galore
Directory metadata after today
- trim-galore: used trim-galore with auto-detect adapters
- trim-galore-illumina: used trim-galore forcing illumina adapters and nextseq flag
- trimmed-cutadapt: used cut-adapt
- trimmed-cutadapt-quality: used cut-adapt with a nextseq flag and reduced adapter overlap requirement

Notes on these different trimming tools:
- We give cutadapt 5' primer sequences to trim (forward and reverse reads)
- Trim galore cuts adapters from the 3' end of reads
	- Don't think I can force trim galore to also cut primers
### Cutadapt
Adjusted [cut-adapt](bash-scripts/cut-adapt) to include `--nextseq-trim=20` to account for NextSeq poly-G tails when quality trimming and `--overlap 2` which overrides the default of needing three matching base pairs to identify adapters (idea from SGW's [code](https://github.com/sagw/DE_micro/blob/fe607fcbdcdb33eff0e052d0e7483907e0471a56/QC_Run1.ipynb)) .
- Can also tack on the 3' end trimming since there may be some overlap between forward and reverse since area of interest is only 291bp and the sequence reads are 301bp

>Command: `sbatch`  
>Script: [cut-adapt](bash-scripts/cut-adapt)  
>Output: [slurm-cutadapt-64904065](QC-outputs/slurm-cutadapt-64904065.out)

### Trim galore
Looking at the trim galore [slurm output](QC-outputs/slurm-trimgalore-64527440.out) I realized that the adapters auto-detected were nextera not illumina so going to try to force that by adding the flag `--illumina` and will also add `--nextseq 20` to account for the NextSeq poly-G tails when quality trimming.
- May be redundant to do trim galore then cutadapt if cutadapt can manage both 5' and 3' trimming at once, but still intrested to see these results/if forcing the illumina adapters makes any difference

>Command: `sbatch`   
>Script: [trim-galore](bash-scripts/trim-galore)  
>Output: [slurm-trimgalore-64906360](QC-outputs/slurm-trimgalore-64906360.out)

## 9.29.26 - add nextera adapter sequences to cutadapt
### MultiQC (trim galore)
>Command: `multiqc .`  
>Output: [multiqc_trimgalore_illumina](QC-outputs/multiqc-reports/multiqc_trimgalore_illumina.html)

Not many samples had Illumina adapter; SGW was probably right, that when the sequencer demultiplexes they also end up trimming most of the adapters—want to check the metagenomics fastqc after trim galore since it is part of Nikea's workflow, wonder if it also recognized the Nextera adapters rather than the Illumina. Looks like the Nextera adapters are part of the "tagmentation" process that attaches to the PCR primers? Going to move away from trim galore for 16S now since I'm more confident what I need can be accomplished through cutadapt alone. 
- Looking more closely at one metagenomic sample, Illumina adapters were identified and trimmed such that all adapter sequences were removed (FastQC)
- Seems like trim galore and trimmomatic get rid of a variety of adapters, whereas cutadapt you have to specify what you want to keep or remove (which makes sense since tirm galore is just a wrapper for cutadapt)

### FastQC (cutadapt)
>Command: `sbatch`  
>Script: [fastqc](bash-scripts/fastqc)  
>Output: 

### MultiQC (cutadapt)
>Command: `multiqc .`  
>Output:

### Cutadapt 
A new modification to [cut-adapt](bash-scripts/cut-adapt) to include the [nextera transposase adapters](https://support-docs.illumina.com/SHARE/AdapterSequences/Content/Nextera_Illumina-Sequences.htm) that trim galore automatically identified (added the flags `--a CTGTCTCTTATA` and `--A CTGTCTCTTATA`). Kept the poly-G aware quality trimming and overlap from [9.26.2026 - adjusting cutadapt and trim galore](#9.26.2026%20-%20adjusting%20cutadapt%20and%20trim%20galore).


