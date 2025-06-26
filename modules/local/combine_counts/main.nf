process COMBINE_COUNTS {

    conda "envs/r.linux-64.pin.txt"

    publishDir "results/counts"

    input:
    path "counts.txt*"

    output:
    path("all_counts.tsv"), emit: counts
    // stdout

    script:
    """
    combine_counts.R counts.txt*
    """
}
