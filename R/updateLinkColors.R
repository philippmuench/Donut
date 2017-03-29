source("http://bioconductor.org/biocLite.R")
biocLite("GenomicRanges", suppressUpdates=T, suppressAutoUpdate=T, ask=F)
library(GenomicRanges)

updateCol <- function(links, hmm, color){
  links$V7 <- as.character(as.matrix(links$V7))
  colnames(hmm) <- c('chr', 'start', 'end')
  links_left <- links[,1:3]
  colnames(links_left) <- c('chr', 'start', 'end')
  links_right <- links[,4:6]
  colnames(links_right) <- c('chr', 'start', 'end')
  # make Grange objects
  gr_links_l = with(links_left, GRanges(chr, IRanges(start = start, end = end)))
  gr_links_r = with(links_right, GRanges(chr, IRanges(start = start, end = end)))
  gr_hmm = with(hmm, GRanges(chr, IRanges(start = start, end = end)))
  
  # find intersection between link coordinates and hmm hit coordinates and update color information
  intersec1 = findOverlaps(query = gr_links_l, subject = gr_hmm, type = "within")
  intersec2 = findOverlaps(query = gr_links_r, subject = gr_hmm, type = "within")
  
  # update color on intersect links
  if (length(queryHits(intersec1))>0){
    links[unique(queryHits(intersec1)),]$V7 <- paste("color=", color, ",thickness=4p", sep='')
  }
  if (length(queryHits(intersec2))>0){
    links[unique(queryHits(intersec2)),]$V7 <- paste("color=", color, ",thickness=4p", sep='')
  }
  return(links)
}

links <- as.data.frame(read.table('/data/circos/blast/blast_links.txt', header=F))
hmm1 <- read.table('/data/circos/hmm/hmm_all_1.txt', header=F)
hmm2 <- read.table('/data/circos/hmm/hmm_all_2.txt', header=F)
hmm3 <- read.table('/data/circos/hmm/hmm_all_3.txt', header=F)
hmm4 <- read.table('/data/circos/hmm/hmm_all_4.txt', header=F)
hmm5 <- read.table('/data/circos/hmm/hmm_all_5.txt', header=F)
hmm6 <- read.table('/data/circos/hmm/hmm_all_6.txt', header=F)


links <- updateCol(links, hmm1, "dark2-6-qual-1" )
links <- updateCol(links, hmm2, "dark2-6-qual-2" )
links <- updateCol(links, hmm3, "dark2-6-qual-3" )
links <- updateCol(links, hmm4, "dark2-6-qual-4" )
links <- updateCol(links, hmm5, "dark2-6-qual-5" )
links <- updateCol(links, hmm5, "dark2-6-qual-6" )

write.table(links, file='data/circos/blast/blast_links_colored.txt', sep='\t', col.names=F, row.names=F, quote=F)
