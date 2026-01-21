#!/usr/bin/env nextflow

include { RNASEQ } from "./workflows/rnaseq"

include { processVersionsFromYaml } from "./modules/local/util"
include { formatNextflowVersion   } from "./modules/local/util"
include { sendNotification        } from "./modules/local/util"

workflow {

    // Genome files
    gtf         = params.annotation_gtf
    genome      = params.genome
    samplesheet = params.input

    // ================================================
    //   Main Workflow
    // ================================================


    RNASEQ(
        gtf,
        genome,
        samplesheet
    )


    // Process and save versions
    RNASEQ.out.versions
        .map { version -> processVersionsFromYaml(version) }
        .mix(channel.of(formatNextflowVersion()))
        .unique()
        .collectFile(
            storeDir: "results/pipeline_info",
            name:     "all_versions.yml",
            sort:     true,
            newLine:  true
        )


    workflow.onComplete = {
        log.info "Workflow completed at $workflow.complete"
        log.info "Duration: $workflow.duration"
        log.info "Execution status: ${workflow.success ? 'OK' : 'Failed'}"

        if (secrets.NTFY_URL != null) {
            sendNotification("${workflow.success ? 'OK': 'FAIL'}", secrets.NTFY_URL)
        }
    }
}


