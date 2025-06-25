process COMBINE_COUNTS {

    container "community.wave.seqera.io/library/r-essentials:4.4--6b522ecbb9ba5bdc"
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