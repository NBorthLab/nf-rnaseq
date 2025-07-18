process STAR_ALIGN {

    label 'big'

    container "https://depot.galaxyproject.org/singularity/star:2.7.11b--h5ca1c30_4"
    publishDir "results/aligned_reads",
        mode: "copy",
        saveAs: { filename -> filename.equals("versions.yml") ? null : filename }

    input:
    tuple val(meta), path(reads)
    path index

    output:
    tuple val(meta), path("*Aligned.sortedByCoord.out.bam"), emit: alignment
    tuple val(meta), path("*Log.final.out"),                 emit: log_final
    tuple val(meta), path("*Log.out"),                       emit: log
    path "versions.yml",                                     emit: versions

    script:
    def reads1 = []
    def reads2 = []
    meta.paired_end
        ? reads.eachWithIndex { v, i -> (i & 1 ? reads2 : reads1) << v }
        : [reads].flatten().each { reads1 << it }

    """
    STAR \\
        --runThreadN ${task.cpus} \\
        --genomeDir ${index} \\
        --readFilesCommand gunzip -c \\
        --readFilesIn ${reads1.join(",")} ${reads2.join(",")} \\
        --outSAMtype BAM SortedByCoordinate \\
        --outFileNamePrefix ${meta.id}.

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star: \$(STAR --version | sed -e "s/STAR_//g")
    END_VERSIONS
    """
}
