process GUNZIP {

    input:
    path file

    output:
    path "${file.baseName}"

    script:
    """
    gunzip -c $file > ${file.baseName}
    """
}


process GTF2BED {

    container "https://depot.galaxyproject.org/singularity/bedops:2.4.40--h9f5acd7_0"

    input:
    path gtf

    output:
    path "*.bed"

    script:
    """
    gtf2bed < $gtf > ${gtf.baseName}.bed
    """
}
