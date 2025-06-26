process STAR_INDEX {

    label 'huge'

    container "https://depot.galaxyproject.org/singularity/star:2.7.11b--h5ca1c30_4"
    publishDir "results/genome_index", mode: "copy"

    input:
    path genome
    path annotation

    output:
    path "genome_index", emit: index

    script:
    """
    mkdir genome_index

    STAR \\
        --runMode genomeGenerate \\
        --genomeFastaFiles $genome \\
        --sjdbGTFfile $annotation \\
        --genomeDir genome_index \\
        --runThreadN $task.cpus
    """
}
