process TRIM_GALORE {

    label 'big'

    container "https://depot.galaxyproject.org/singularity/trim-galore:0.6.9--hdfd78af_0"
    publishDir "${params.outdir}/trimmed_reads", mode: "copy", pattern: "!versions.yml"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_{trimmed,val}*.fq.gz"),  emit: reads
    tuple val(meta), path("*_trimming_report.txt"),   emit: report
    tuple val(meta), path("*_fastqc.zip"),            emit: zip
    tuple val(meta), path("*_fastqc.html"),           emit: html
    path "versions.yml",                              emit: versions

    script:
    if (meta.paired_end) {
        """
        trim_galore \\
            --fastqc \\
            --paired \\
            --cores $task.cpus \\
            $reads

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            trimgalore: \$(echo \$(trim_galore --version 2>&1) | sed 's/^.*version //; s/Last.*\$//')
        END_VERSIONS
        """
    } else {
        """
        trim_galore \\
            --fastqc \\
            --cores $task.cpus \\
            $reads

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            trimgalore: \$(echo \$(trim_galore --version 2>&1) | sed 's/^.*version //; s/Last.*\$//')
        END_VERSIONS
        """
    }
}
