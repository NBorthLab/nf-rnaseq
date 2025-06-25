#!/usr/bin/env nextflow

include { RNASEQ } from "./workflows/rnaseq/main.nf"


workflow {

    // Genome files
    ch_gtf = Channel.fromPath(params.annotation_gtf)
    ch_genome = Channel.fromPath(params.genome)
    ch_samplesheet = Channel.fromPath(params.input)

    RNASEQ(
        ch_gtf,
        ch_genome,
        ch_samplesheet
    )
}

