process STAR_INDEX {

    cpus 8

    container "community.wave.seqera.io/library/star:2.7.11b--822039d47adf19a7"
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