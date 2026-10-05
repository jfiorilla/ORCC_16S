## 10.5.2026 setting up unity with kernel to run R
### Conda
Created new environment `skbio` to run python kernel in jupyter notebooks on unity
```
conda create --name skbio python=3.14
conda activate skbio
conda install -c conda-forge scikit-bio
pip install jupyter
pip install ipykernel
python -m ipykernel install --user --name skbio --display-name "Python (skbio)"
```
- Belated realized I won't really need to use this kernel since I won't be running python, but good to have...

Created new environment `r-env` to run R kernel in jupyter notebooks on unity
```
conda create -n r-env python=3.14
conda activate r-env
conda config --add channels conda-forge
conda config --set channel_priority strict
conda install r-base
conda install -c conda-forge r-tidyverse
pip install jupyter
conda install -c conda-forge r-irkernel
```