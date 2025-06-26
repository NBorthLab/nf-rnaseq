process TRIM_GALORE {

    cpus 4
    memory '64 GB'
    scratch 'ram-disk'

    container "https://depot.galaxyproject.org/singularity/trim-galore:0.6.9--hdfd78af_0"
    publishDir "results/trimmed_reads", mode: "copy"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_{trimmed,val}*.fq.gz"), emit: reads
    tuple val(meta), path("*_trimming_report.txt"),   emit: report
    tuple val(meta), path("*_fastqc.zip"),            emit: zip
    tuple val(meta), path("*_fastqc.html"),           emit: html

    script:
    if (meta.paired_end) {
        """
        trim_galore \\
            --fastqc \\
            --paired \\
            --cores $task.cpus \\
            $reads
        """
    } else {
        """
        trim_galore \\
            --fastqc \\
            --cores $task.cpus \\
            $reads
        """
    }
}
