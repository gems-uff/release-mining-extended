This repository is the replication package of our study "On the assignment of commits to releases" published on Empirical Software Engineering (EMSE), volume 28, on 2023 [[doi](https://doi.org/10.1007/s10664-022-10263-x)].

## Setup

### Project _Corpus_

The project corpus is available at https://doi.org/10.5281/zenodo.4408024. You must download the corpus to reproduce the experiment.

### Releasy tool

The experiment uses Releasy version 3.0.1. You can clone Releasy tool using the following command:

```bash
git clone git@github.com:gems-uff/releasy.git -b 3.0.1
```

### Project Configuration

You must clone this repository:

```bash
git clone git@github.com:gems-uff/release-mining-extended.git
```

Copy the `config.default` file and edit the configurations according to your local setup.

```bash
cp config.default config
vim config
```

For instance, a sample config file would be:

```bash
# The path to the previous cloned Releasy tool
export PYTHONPATH=/home/felipecrp/dev/releasy-emse:$PYTHONPATH

# The path to the previous downloaded repositories
export REPOPATH=/home/felipecrp/repos
```


Copy the `projects.default.py` file and add the projects path

```bash
cp projects.sample.py projects.py
```

### Setup python dependencies

The experiment uses [pipenv](https://pipenv.pypa.io/en/latest/) to handle dependencies. You can install the dependencies running the following command:

```bash
pipenv install --dev
```

## Running the main experiment

### Mining the repositories

The mining process generates the `raw_releases.csv` and `raw_releases.zip` (which is a python pickle file). These files are available in the repository. Hence, you can skip this step if you do not intend to reproduce the experiment from the scratch.

The experiment uses the script `experiment.py` to mine the repositories. You can run the script using the following command:

```bash
experiment.sh
```

### Calculating the precision and recall

The calculation generates the `data/releases.csv` and `data/releases.zip` (which is a python pickle file). These files are available in the repository. Hence, you can skip this step if you do not intend to reproduce the experiment from the scratch.

The experiment use the jupyter notebook `precision_recall.ipynb`. You can run the notebook using the following command:

```bash
pipenv run jupyter lab
```

## Analyzing the results

We use the R scripts available in the `experiment` folder to analyze the data.



