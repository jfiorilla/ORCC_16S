## 9.8.2026 - md5 check
Used [Brooke's script](https://github.com/brookewicz/CBC_metagenomics/blob/db0de23907d5382e904fa32af875cc5fb6519d64/all_sctld/sampleinfo/md5check.txt) to check files were downloaded without corruption (success!)
- Her code has a double `#!/bin/bash` that threw an error

>Command: `sbatch`  
>Script: [md5check](bash-scripts/md5check.sh)  
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
>Script: [fastqc](bash-scripts/fastqc.sh)    
>Output: [sampleids.txt](sampleids.txt) (missing slurm)

### MultiQC
>Command: `multiqc .`  
>Output: [multiqc_raw](QC-outputs/multiqc-reports/multiqc_raw.html)

## 9.17.2026 - start processing sequences
After talking with SGW, plan is to follow [DADA2](https://benjjneb.github.io/dada2/) pipeline which recommends trimmomatic or cutadapt tools, but I thought I'd also try trim galore since I already have a tested script for that from my metagenomics QC workflow  
### Trim galore
Combined both Nikea's [metagenomic workflow](https://github.com/nikeaulrich/Metagenomics_workflow/blob/fcfd850453887a23301e5d07c220aab7c9972994/0_QC.ipynb) and Julia's [RNAseq workflow](https://github.com/jgmcdonough/CE24_RNA-seq/blob/d5c6e46913b5a4067e697677178ea129e5e5aa8f/processing/processing_seqs.ipynb) 
- Also produces a samplesid.txt file, but realize now that I could have just set the `SAMPLE_NAMES_FILE` variable to the existing file created during [raw FastQC](#FastQC) steps

>Command: `sbatch`   
>Script: [trim-galore](bash-scripts/trim-galore.sh)  
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
Pieced together [trim-galore](bash-scripts/trim-galore.sh) script, some of Caroline's [16S workflow](https://github.com/cdesouza02/BEL_16S_ITS2/blob/51f1b7652672009b21ec146c69977494d83159f5/scripts/2_cutadapt_trim), and some of SGW's [16S workflow](https://github.com/sagw/DE_micro/blob/fe607fcbdcdb33eff0e052d0e7483907e0471a56/QC_Run1.ipynb)

>Command: `sbatch`  
>Script: [cut-adapt](bash-scripts/cut-adapt.sh)  
>Output: [slurm-cutadapt-64671732](QC-outputs/slurm-cutadapt-64671732.out)

### FastQC
>Command: `sbatch`  
>Script: [fastqc](bash-scripts/fastqc.sh)  
>Output: [slurm-fastqc-cutadapt-64675148](QC-outputs/slurm-fastqc-cutadapt-64675148.out)