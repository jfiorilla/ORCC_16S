## 10.6.2026 setting up unity with R + Bionconductor
### Conda
Create environment `dada2-env` in terminal, easier than doing it in R
```
conda create -n dada2-env python=3.14 
conda activate dada2-env
conda install -c conda-forge -c bioconda --strict-channel-priority r-base r-biocmanager bioconductor-dada2
conda install -c conda-forge r-tidyverse
pip install jupyter
conda install -c conda-forge r-irkernel
```

