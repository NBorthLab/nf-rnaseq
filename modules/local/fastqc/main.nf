process FASTQC {

    container "community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18"
    publishDir "results/fastqc", mode: "copy"

    input:
    tuple val(meta), path(reads)

    output:
    // reads.simpleName is the same as .getSimpleName()
    tuple val(meta), path("*_fastqc.zip"), emit: zip
    tuple val(meta), path("*_fastqc.html"), emit: html

    script:
    """
    fastqc $reads
    """
}
