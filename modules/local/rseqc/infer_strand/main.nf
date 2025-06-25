process INFER_STRAND {

    container "community.wave.seqera.io/library/pip_rseqc:2889b03904e9d027"

    input:
    tuple val(meta), path(alignment)
    each path(annotation)

    output:
    tuple val(meta), path("infer_experiment.out.txt"), path(alignment)

    script:
    """
    infer_experiment.py -r $annotation -i $alignment \\
        > infer_experiment.out.txt
    """
}
