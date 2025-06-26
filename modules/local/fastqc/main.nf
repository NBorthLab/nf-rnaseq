process FASTQC {

    container "https://depot.galaxyproject.org/singularity/trim-galore:0.6.9--hdfd78af_0"
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
