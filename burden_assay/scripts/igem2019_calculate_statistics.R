#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)
library(cowplot)

input.prefix = "04-normalization/output"
strain.metadata.file.string = "igem2019_strain_metadata.csv"
all.data.file.string = "02b-output-all-merged/output.csv"

strain.input.file.string = paste0(input.prefix, ".strain.burden.csv")
strain.means = read.csv(strain.input.file.string)

part.input.file.string = paste0(input.prefix, ".part.burden.csv")
parts.means = read.csv(part.input.file.string)

strain.metadata = read.csv(strain.metadata.file.string)

all.data = read.csv(all.data.file.string)

########################################################################
### Calculate KS test on different vectors

ks.test(
  (strain.means %>% filter(vector=="pSB1A2"))$normalized.growth.rate.mean,
  (strain.means %>% filter(vector=="pSB1C3"))$normalized.growth.rate.mean
)

########################################################################
### Compare strains measured in both vectors

measured.twice = parts.means %>% filter(vectors=="pSB1A2,pSB1C3")
measured.twice.strains = (strain.metadata %>% filter(accession %in% measured.twice$accession))$strain

measured.twice.data = all.data %>% filter(strain %in% measured.twice.strains)

measured.twice.data = measured.twice.data %>%left_join(strain.metadata, by="strain")

fit = lm(growth.rate~accession+vector, measured.twice.data )
anova(fit)

########################################################################
### Calculate one-tailed tests of more than certain burden cutoffs

not.control.data = parts.means %>% filter(burden.category != "control")

cat("burden cutoff", "# sig> than", "% sig > than", "\n")
for (b in seq(0, 0.5, by=0.05)) {
  
  p.values = pt((b-not.control.data$burden.mean)/not.control.data$burden.sem, not.control.data$replicates-1)
  #Uncomment for multiple testing correction
  #p.values = p.adjust(p.values, method="BH")
  num.significant = sum(p.values <= 0.05)
  cat(b, num.significant, (num.significant/length(p.values))*100, "\n")
}


