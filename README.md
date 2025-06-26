# Nextflow RNA-seq pipeline

## Initial setup

Install nextflow e.g. in an conda environment:

```bash
conda create -n nextflow -c bioconda nextflow
```

Activate the conda environment with nextflow:

```bash
conda activate nextflow
```

## Configuration options

Edit `nextflow.config` and change it accordingly to your needs. In particular,
you will need to change `singularity.cacheDir`.


## Run pipeline

```bash
nextflow run .
```

## File structure

```plain
bin/
data/
envs/
modules/
results/
work/
workflows/
main.nf                     # Main entrypoint for the pipeline
nextflow.config
README.md
samplesheet_test.csv
```
