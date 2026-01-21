process COMBINE_COUNTS_RSEM {

    label 'small'

    container "https://depot.galaxyproject.org/singularity/bioconductor-tximport:1.34.0--r44hdfd78af_0"
    publishDir "${params.outdir}/counts",
        mode: "copy",
        saveAs: { filename -> filename.equals("versions.yml") ? null : filename }

    input:
    path "counts/*"

    output:
    path("all_gene_counts.rds"), emit: counts
    path("versions.yml"),        emit: versions

    script:
    template "concatenate_counts.R"
}


process COMBINE_COUNTS_FEATURECOUNTS {

    label 'small'

    publishDir "${params.outdir}/counts",
        mode: "copy",
        saveAs: { filename -> filename.equals("versions.yml") ? null : filename }

    input:
    path "counts.txt*"

    output:
    path("all_counts.tsv"), emit: counts

    script:
    """
    # Write the first few columns into the output file (Geneid + metadata of
    # genes)
    tail -n +2 counts.txt1 | cut -f 1-6 > all_counts.tsv

    # Add the counts column of the individual counts files to the output file.
    # The paste command can't modify inplace, therefore a temporary file is
    # used, therefore a temporary file is used.
    for file in counts.txt*; do
        paste all_counts.tsv <(tail -n +2 \$file | cut -f 7) > tmpfile
        cat tmpfile > all_counts.tsv
    done

    rm tmpfile
    """
}
