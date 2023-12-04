# prep_rts_dataset_scripts

This repository hosts codes that will be used for formatting contributions to the RTS Data Set while they are in preparation.

## Instructions for Use

**1. Fork this Respository and Clone Your Fork Onto Your Local Machine**

Fork this repository using the **Fork** button in the top right corner in the browser. Next, clone your forked repository. From the forked repository on your github page, copy the URL using the **Code** button in the top right of the browser. From the command line (whichever shell you use for git), navigate to the directory in which you would like to clone the repository (this should be the directory in which you would like to work on this project), and run: `git clone {URL}`.

**2. Set Up a Conda Environment from env.yml**

Make sure you have [Anaconda](https://www.anaconda.com/download/) or [Miniconda](https://docs.conda.io/projects/miniconda/en/latest/) installed, as well as [Mamba](https://anaconda.org/conda-forge/mamba) (mamba is not required, but is much faster than conda).

In the command line, make sure you are in the repository directory and run: `mamba env create -f env.yml` (or `conda env create -f env.yml`, if you don't have mamba installed). This will create a conda environment named **rts_dataset**. Run: `conda env list` to ensure that **rts_dataset** shows up.

**3. Run the Scripts (Choose either R or Python)**

Copy your new, pre-formatted RTS file into the **input_data** folder. Take a look at **input_data/metadata_description** for formatting requirements.
   
If using Python, ensure you are in the repository directory and activate the conda environment by running: `conda activate rts_dataset`. Open **python/rts_dataset_formatting.ipynb** in either Jupyter Notebook or Jupyter Lab by running: `jupyter notebook` or `jupyter lab`. Follow the instructions in the script to format your data set.
   
If using R, open the project, **rts_dataset.Rproj**, in RStudio. Open **r/rts_dataset_formatting.Rmd**. Install any missing packages required to run the script. Follow the instructions in the script to format your data set. If you encounter issues during uuid generation, make sure that **rts_dataset** is specified as the python interpreter in the python section of project options (Tools > Project Options > Python).
