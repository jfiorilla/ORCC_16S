## 10.6.2026 setting up unity with R + Bionconductor
### Conda
Create environment `dada2-env` in terminal, much easier than doing it in R! 
```
conda create -n dada2-env python=3.14 
conda activate dada2-env
conda install -c conda-forge -c bioconda --strict-channel-priority r-base r-biocmanager bioconductor-dada2
conda install -c conda-forge r-tidyverse 
# install jupyter and add r kernel
pip install jupyter 
conda install -c conda-forge r-irkernel
```

### DADA2
Started running code in [jupyter notebook](dada2.ipynb) through unity interactive session with R kernel, but quickly realized that later portions would need to be run as an r script through unity because there are just so many samples! Saved edits to notebook on unity and commited those changes via command line.  

Wrote R code following [tutorial](https://benjjneb.github.io/dada2/tutorial.html) and Caroline's [script](https://github.com/cdesouza02/BEL_16S_ITS2/blob/51f1b7652672009b21ec146c69977494d83159f5/scripts/dada2.r), and then the bash script to run on unity from Caroline's [code](https://github.com/cdesouza02/BEL_16S_ITS2/blob/main/scripts/5_dada2).