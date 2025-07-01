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

## Configuration

### Pipeline config

Override the configuration (called `nextflow.config`) using an own config file
and using the `-C` flag on the nextflow run
([see docs](https://www.nextflow.io/docs/latest/cli.html)).

### Pipeline parameters

Parameters are either passed in as command line arguments (with double-dashed
arguments `--`)
```bash
nextflow run ... --input samplesheet.csv --genome genome.fa --annotation_gtf annotation.gtf
```
or in a yaml (or json) file via the `-params-file` argument.
```yaml
input: "path/to/samplesheet.csv"
genome: "path/to/genome.fasta"
annotation_gtf: "path/to/gene_annotation.gtf"
```
```bash
nextflow run NBorthLab/nf-rnaseq -params-file parameters.yml
```

The example below shows how such a sample sheet CSV file might look like
*(visually aligned for easier redability)*.
```plain
 sample,                    fastq_1,                    fastq_2, strandedness
sample1,   /data/sample1_1.fastq.gz,   /data/sample1_2.fastq.gz,         auto
sample2,     /data/sample2.fastq.gz,                           ,         auto
sample3, /data/sample3.1_1.fastq.gz, /data/sample3.1_2.fastq.gz,         auto
sample3, /data/sample3.2_1.fastq.gz, /data/sample3.2_2.fastq.gz,         auto
```

First column is the sample name; multiple mentions are allowed and will be
treated as technical replicates.
Second column is the first, third column the (optional) second fastq file.
Fourth column is the 'strandedness'. If unknown set to `auto`.

`sample1` is an example of a paired-end sequenced sample. `sample2` is
single-end. `sample3` is paired-end and has technical replicates.


### Notifications (optional)

Set up an account at [ntfy.sh](https://ntfy.sh) and set up a topic for yourself.
Add the URL of the ntfy topic as a secret to get notified on pipeline runs.

```bash
nextflow secrets set NTFY_URL http://ntfy.sh/<YOUR-TOPIC>
```


## Test pipeline

```bash
nextflow run NBorthLab/nf-rnaseq -profile test
```

## Run pipeline

```bash
nextflow run NBorthLab/nf-rnaseq

# or, for subsequent runs
nextflow run NBorthLab/nf-rnaseq -resume
```

## Output

Pipeline results can bee retrieved from the `results` directory.

```bash
results/
├── aligned_reads/          # Aligned reads
├── counts/                 # Counts of individual samles
│   └── all_counts.tsv      # (!!!) Combined counts of all samples
├── fastqc/                 # FASTQC of raw reads
├── genome_index/           # STAR genome index
├── multiqc/                # MULTIQC report
├── pipeline_info/          # Pipeline reports and software versions
└── trimmed_reads/          # trimmed reads and their fastqc reports
```


## File structure

```bash
bin/                        # Exectuable scripts used in the workflow (not used currently)
data/                       # Raw data (put your data here)
envs/                       # Conda environment definition files
modules/                    # Process definitions
results/                    # Results directory (is created)
work/                       # Working directory of nextflow (is created)
workflows/                  # RNA-seq workflow definition
main.nf                     # Entrypoint for the pipeline
nextflow.config             # (!!!) Configuration file
README.md
```
