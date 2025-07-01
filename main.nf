#!/usr/bin/env nextflow

include { RNASEQ } from "./workflows/rnaseq/main.nf"

// include { processVersionsFromYaml } from "./modules/local/util/main.nf"
// include { getNextflowVersion } from "./modules/local/util/main.nf"


workflow {

    // Genome files
    ch_gtf = Channel.fromPath(params.annotation_gtf)
    ch_genome = Channel.fromPath(params.genome)
    ch_samplesheet = Channel.fromPath(params.input)

    // ================================================
    //   Main Workflow
    // ================================================

    RNASEQ(
        ch_gtf,
        ch_genome,
        ch_samplesheet
    )


    // Process and save versions
    all_versions = RNASEQ.out.versions
        .map { version -> Util.processVersionsFromYaml(version) }
        .mix(Channel.of(Util.formatNextflowVersion(workflow.nextflow.version)))
        .unique()
        .collectFile(
            storeDir: "results/pipeline_info",
            name: "all_versions.yml",
            sort: true,
            newLine: true
        )
}


workflow.onComplete {
    log.info "Workflow completed at $workflow.complete"
    log.info "Duration: $workflow.duration"
    log.info "Execution status: ${workflow.success ? 'OK' : 'Failed'}"
    if (params.ntfy_url) {
        Util.sendNotification("${workflow.success ? 'OK': 'FAIL'}", params.ntfy_url)
    }
}
