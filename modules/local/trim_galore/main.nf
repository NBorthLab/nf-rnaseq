process TRIM_GALORE {

    container "quay.io/biocontainers/trim-galore:0.6.9--hdfd78af_0"
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
            --cores 4 \\
            $reads
        """
    } else {
        """
        trim_galore \\
            --fastqc \\
            --cores 4 \\
            $reads
        """
    }
}