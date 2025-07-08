include { FASTQC               } from "../../modules/local/fastqc"
include { TRIM_GALORE          } from "../../modules/local/trim_galore"
include { STAR_INDEX           } from "../../modules/local/star/index"
include { STAR_ALIGN           } from "../../modules/local/star/align"
include { INFER_STRAND         } from "../../modules/local/rseqc/infer_strand"
include { FEATURECOUNTS        } from "../../modules/local/featurecounts"
include { GUNZIP as GUNZIP_GTF } from "../../modules/local/util"
include { GTF2BED              } from "../../modules/local/util"
include { COMBINE_COUNTS       } from "../../modules/local/combine_counts"
include { MULTIQC              } from "../../modules/local/multiqc"


workflow RNASEQ {

    take:
    ch_gtf
    ch_genome
    ch_samplesheet

    main:

    ch_multiqc_files = Channel.empty()
    ch_versions      = Channel.empty()

    // Read sample sheet
    ch_samplesheet
        .splitCsv(skip: 1)
        .map { sample, fastq_1, fastq_2, strandedness ->
            [
                sample as String,
                file(fastq_1),
                fastq_2 ? file(fastq_2) : null,
                strandedness as String,
            ]
        }
        .map { sample, fastq_1, fastq_2, strandedness ->
            if (!fastq_2) {
                return [
                    [
                        "id": sample,
                        "strandedness": strandedness,
                        "paired_end": false,
                    ],
                    fastq_1,
                ]
            }
            else {
                return [
                    [
                        "id": sample,
                        "strandedness": strandedness,
                        "paired_end": true,
                    ],
                    [fastq_1, fastq_2],
                ]
            }
        }
        .groupTuple()
        .map { meta, reads -> [meta, reads.flatten()] }
        .set { ch_fastq }


    // ================================================
    //   RAW READS QC
    // ================================================

    // Quality check of raw reads
    FASTQC(
        ch_fastq
    )

    ch_versions = ch_versions.mix(FASTQC.out.versions)

    // ================================================
    //   TRIM READS
    // ================================================

    // Trimming of raw reads 
    TRIM_GALORE(
        ch_fastq
    )
    ch_trimmed_reads = TRIM_GALORE.out.reads

    ch_versions = ch_versions.mix(TRIM_GALORE.out.versions)
    ch_multiqc_files = ch_multiqc_files
        .mix(TRIM_GALORE.out.report)
        .mix(TRIM_GALORE.out.zip)


    // ================================================
    //   ALIGN READS
    // ================================================

    // Unzip annotation GTF file
    GUNZIP_GTF(
        ch_gtf
    )
    ch_unzipped_gtf = GUNZIP_GTF.out

    // Index genome
    STAR_INDEX(
        ch_genome,
        ch_unzipped_gtf
    )

    // .collect() is needed to transform from a queue channel (that can only be
    // consued once) to a value channel (multiple consumptions).
    ch_index = STAR_INDEX.out.index.collect()
    ch_versions = ch_versions.mix(STAR_INDEX.out.versions)

    // Align trimmed reads to genome
    STAR_ALIGN(
        ch_trimmed_reads,
        ch_index
    )
    ch_alignment = STAR_ALIGN.out.alignment

    ch_versions = ch_versions.mix(STAR_ALIGN.out.versions)
    ch_multiqc_files = ch_multiqc_files
        .mix(STAR_ALIGN.out.log)
        .mix(STAR_ALIGN.out.log_final)


    // ================================================
    //   INFER STRANDEDNESS
    // ================================================

    // Convert GTF to BED
    GTF2BED(
        ch_unzipped_gtf
    )
    ch_annotation_bed = GTF2BED.out.collect()

    // Infer strandedness of alignment
    INFER_STRAND(
        ch_alignment,
        ch_annotation_bed
    )
    ch_inferred_strand = INFER_STRAND.out.inferred

    ch_versions = ch_versions.mix(INFER_STRAND.out.versions)

    // Update the metadata to include the inferred strandedness information
    ch_inferred_strand
        .map {
            meta, log, alignment ->
                def log_file = file(log)
                def log_text = log_file.readLines()
                def fw = log_text[4] =~ /.+ (.+)$/
                def rv = log_text[5] =~ /.+ (.+)$/
                def fw_stranded = fw[0][1] as Float > 0.75
                def rv_stranded = rv[0][1] as Float > 0.75

                if (!fw_stranded && !rv_stranded) {
                    meta.strandedness = "unstranded"
                } else if (fw_stranded && !rv_stranded) {
                    meta.strandedness = "forward"
                } else if (!fw_stranded && rv_stranded) {
                    meta.strandedness = "reverse"
                }
                return [meta, alignment]
        }
        .set { ch_alignment_inferred }


    // ================================================
    //   Quantify reads
    // ================================================

    FEATURECOUNTS(
        ch_alignment_inferred,
        ch_unzipped_gtf.collect()
    )
    ch_counts = FEATURECOUNTS.out.counts

    ch_versions = ch_versions.mix(FEATURECOUNTS.out.versions)
    ch_multiqc_files = ch_multiqc_files
        .mix(FEATURECOUNTS.out.summary)

    // Get only counts file paths, remove meta data
    ch_counts
        .collect(flat: false) { meta, counts -> counts }
        .set { ch_counts }

    COMBINE_COUNTS(
        ch_counts
    )


    // ================================================
    //   MULTIQC
    // ================================================

    // Remove meta data and get only the file paths
    ch_multiqc_files = ch_multiqc_files.transpose().collect { it[1] }

    MULTIQC(
        ch_multiqc_files
    )


    emit:
    aligned_reads = STAR_ALIGN.out.alignment
    all_counts = COMBINE_COUNTS.out.counts
    versions = ch_versions
}
