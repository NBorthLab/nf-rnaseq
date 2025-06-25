#!/usr/bin/env Rscript

library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

counts_files <- args

counts <- map(counts_files, read_tsv, skip = 1) %>%
  reduce(inner_join, by = join_by(Geneid, Chr, Start, End, Strand, Length)) %>%
  rename_with(~ str_split(.x, "\\.") %>% map_chr(`[`(1)))


write_tsv(counts, "all_counts.tsv")
