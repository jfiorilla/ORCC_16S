## 9.8.2026 - md5 check
Used [Brooke's script](https://github.com/brookewicz/CBC_metagenomics/blob/db0de23907d5382e904fa32af875cc5fb6519d64/all_sctld/sampleinfo/md5check.txt) to check files were downloaded without corruption (success)
- Her code has a double `#!/bin/bash` that threw an error

>Code: `sbatch`  
>Script: [[md5check.sh]]  
>Output: [[slurm-checksum-64092117.out|slurm]], [[md5_checksums.txt]]  

## 9.16.2026 - QC on raw files
Conda environment (used for metagenomic QC workflow)
#### FastQC
Moved fastq.gz files into a separate directory using a for loop:
```
for filename in *.fastq.gz
	do echo $filename
	mv $filename fastq
done
```
