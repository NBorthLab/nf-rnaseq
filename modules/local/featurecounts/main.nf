process FEATURECOUNTS {

    cpus 8
    memory '128 GB'
    scratch 'ram-disk'

    container "https://depot.galaxyproject.org/singularity/subread:2.0.8--h577a1d6_0"
    publishDir "results/counts/${meta.id}", mode: "copy"

    input:
    tuple val(meta), path(bam)
    each path(annotation)

    output:
    tuple val(meta), path("counts.txt"), emit: counts

    script:
    def strandedness = 0
    if (meta.strandedness == "forward") {
        strandedness = 1
    } else if (meta.strandedness == "reverse") {
        strandedness = 2
    }
    def p = meta.paired_end ? "-p --countReadPairs" : ""

    def id_bam = "${meta.id}.${bam}"

    """
    ln -s $bam $id_bam

    featureCounts \\
        -T $task.cpus \\
        $p \\
        -s $strandedness \\
        -a $annotation \\
        -o counts.txt \\
        $id_bam
    """
}
