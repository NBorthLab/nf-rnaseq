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

Edit `nextflow.config` and change it accordingly to your needs.

In particular, you will need to change the `params` block.
Also double-check the computational settings. You might need to change
`singularity.cacheDir`.

```groovy
params {
    input = ""              # Samplesheet CSV file
    genome = ""             # FASTA file of the genome sequence
    annotation_gtf = ""     # GTF annotation file of the genome
}
```

The example below shows how such a sample sheet CSV file might look like.

```plain
sample,fastq_1,fastq_2,strandedness
sample1,/data/sample1_1.fastq.gz,/data/sample1_2.fastq.gz,auto
sample2,/data/sample2.fastq.gz,,auto
sample3,/data/sample3.1_1.fastq.gz,/data/sample3.1_2.fastq.gz,auto
sample3,/data/sample3.2_1.fastq.gz,/data/sample3.2_2.fastq.gz,auto
```

First column is the sample name; multiple mentions are allowed and will be
treated as technical replicates.
Second column is the first, third column the (optional) second fastq file.
Fourth column is the 'strandedness'. If unknown set to `auto`.

`sample1` is an example of a paired-end sequenced sample. `sample2` is
single-end. `sample3` is paired-end and has technical replicates.


## Test pipeline

```bash
nextflow run . -profile test
```

## Run pipeline

```bash
nextflow run .
```

## File structure

```plain
bin/                        # Exectuable script used in the workflow (not used currently)
data/                       # Raw data (recommended; put your data here)
envs/                       # Conda environment definition files
modules/                    # Process definitions
results/                    # Results directory (is created)
work/                       # Working directory of nextflow (is created)
workflows/                  # RNA-seq workflow definition
main.nf                     # Entrypoint for the pipeline
nextflow.config             # (!!!) Configuration file
README.md
```
