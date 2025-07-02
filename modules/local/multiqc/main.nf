process MULTIQC {

    label 'medium'

    container "https://depot.galaxyproject.org/singularity/multiqc:1.9--pyh9f0ad1d_0"
    publishDir "results/multiqc",
        mode: "copy",
        saveAs: { filename -> filename.equals("versions.yml") ? null : filename }


    input:
    path multiqc_files

    output:
    path "*multiqc_report.html", emit: report
    path "*_data",               emit: data

    script:
    """
    multiqc .
    """
}
