process INFER_STRAND {

    label 'medium'

    container "https://depot.galaxyproject.org/singularity/rseqc:5.0.4--pyhdfd78af_0"

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
