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

    container "community.wave.seqera.io/library/bedops:2.4.42--91acb3d4e24f8e85"

    input:
    path gtf

    output:
    path "*.bed"

    script:
    """
    gtf2bed < $gtf > ${gtf.baseName}.bed
    """
}