include { FASTQC                   } from "../../modules/local/fastqc"
include { TRIM_GALORE              } from "../../modules/local/trim_galore"
include { RSEM_PREPAREREFERENCE    } from "../../modules/local/rsem/preparereference"
include { RSEM_CALCULATEEXPRESSION } from "../../modules/local/rsem/calculateexpression"
include { STAR_INDEX               } from "../../modules/local/star/index"
include { STAR_ALIGN               } from "../../modules/local/star/align"
include { INFER_STRAND             } from "../../modules/local/rseqc/infer_strand"
include { FEATURECOUNTS            } from "../../modules/local/featurecounts"
include { GUNZIP as GUNZIP_GTF     } from "../../modules/local/util"
include { GUNZIP as GUNZIP_FNA     } from "../../modules/local/util"
include { GTF2BED                  } from "../../modules/local/util"
include { COMBINE_COUNTS_RSEM      } from "../../modules/local/combine_counts"
include { MULTIQC                  } from "../../modules/local/multiqc"


workflow RNASEQ {

    take:
    gtf
    genome
    samplesheet

    main:

    ch_multiqc_files = channel.empty()
    ch_versions      = channel.empty()


    // Read sample sheet
    channel.fromPath(samplesheet)
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
    ch_versions      = ch_versions.mix(TRIM_GALORE.out.versions)
    ch_multiqc_files = ch_multiqc_files
        .mix(TRIM_GALORE.out.report)
        .mix(TRIM_GALORE.out.zip)


    // ================================================
    //   ALIGN READS
    // ================================================

    if (gtf.endsWith(".gz")) {
        GUNZIP_GTF(
            gtf
        )
        ch_unzipped_gtf = GUNZIP_GTF.out
    } else {
        ch_unzipped_gtf = channel.fromPath(gtf)
    }

    if (genome.endsWith(".gz")) {
        GUNZIP_FNA(
            genome
        )
        ch_unzipped_genome = GUNZIP_FNA.out
    } else {
        ch_unzipped_genome = channel.fromPath(genome)
    }


    RSEM_PREPAREREFERENCE(
        ch_unzipped_genome,
        ch_unzipped_gtf
    )
    ch_index    = RSEM_PREPAREREFERENCE.out.index.collect()
    ch_versions = ch_versions.mix(RSEM_PREPAREREFERENCE.out.versions)


    // Align trimmed reads to genome
    STAR_ALIGN(
        ch_trimmed_reads,
        ch_index
    )
    ch_genome_bam        = STAR_ALIGN.out.genome_bam
    ch_transcriptome_bam = STAR_ALIGN.out.transcriptome_bam
    ch_versions          = ch_versions.mix(STAR_ALIGN.out.versions)
    ch_multiqc_files     = ch_multiqc_files
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
        ch_genome_bam,
        ch_annotation_bed
    )
    ch_inferred_strand = INFER_STRAND.out.inferred
    ch_versions        = ch_versions.mix(INFER_STRAND.out.versions)


    // Update the metadata to include the inferred strandedness information
    ch_inferred_strand
        .join(ch_transcriptome_bam)
        .map {
            meta, log, _genome_bam, transcriptome_bam ->
                def log_file = file(log)
                def log_text = log_file.readLines()
                def fw = log_text[4] =~ /.+ (.+)$/
                def rv = log_text[5] =~ /.+ (.+)$/
                def fw_stranded = fw[0][1] as Float > 0.75
                def rv_stranded = rv[0][1] as Float > 0.75
                def new_meta = [:]

                if (!fw_stranded && !rv_stranded) {
                    new_meta = meta + [strandedness: "unstranded"]
                } else if (fw_stranded && !rv_stranded) {
                    new_meta = meta + [strandedness: "forward"]
                } else if (!fw_stranded && rv_stranded) {
                    new_meta = meta + [strandedness: "reverse"]
                }

                return [new_meta, transcriptome_bam]
        }
        .set { ch_alignment_inferred }


    // ================================================
    //   Quantify reads
    // ================================================

    RSEM_CALCULATEEXPRESSION(
        ch_alignment_inferred,
        ch_index
    )
    ch_counts_gene   = RSEM_CALCULATEEXPRESSION.out.counts_gene
    ch_versions      = ch_versions.mix(RSEM_CALCULATEEXPRESSION.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(RSEM_CALCULATEEXPRESSION.out.stat)


    // Get only counts file paths, remove meta data
    ch_counts_gene
        .collect(flat: false) { meta, counts -> counts }
        .set { ch_counts }

    COMBINE_COUNTS_RSEM(
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
    all_counts = COMBINE_COUNTS_RSEM.out.counts
    versions   = ch_versions
}
