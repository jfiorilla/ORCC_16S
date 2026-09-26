## 9.8.2026 - md5 check
Used [Brooke's script](https://github.com/brookewicz/CBC_metagenomics/blob/db0de23907d5382e904fa32af875cc5fb6519d64/all_sctld/sampleinfo/md5check.txt) to check files were downloaded without corruption (success)
- Her code has a double `#!/bin/bash` that threw an error

>Command: `sbatch`  
>Script: [md5check](bash-scripts/md5check.sh)  
>Output: [slurm-checksum-64092117](QC-outputs/slurm-checksum-64092117.out), [md5_checksums](QC-outputs/md5_checksums.txt)  

## 9.16.2026 - QC on raw files
Conda environment (used for metagenomic QC workflow)
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

## 9.17.2026 - Trim Galore
After talking with SGW, plan is to follow [DADA2](https://benjjneb.github.io/dada2/) pipeline which recommends trimmomatic or cutadapt tools, but I thought I'd also try trim galore since I already have a tested script for that from my metagenomics QC workflow

>Command: `sbatch`   
>Script: [trim-galore](bash-scripts/trim-galore.sh)  
>Output: [slurm-trimgalore-64527440](QC-outputs/slurm-trimgalore-64527440.out)

