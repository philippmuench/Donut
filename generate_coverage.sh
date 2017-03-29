#/bin/sh
# extract genome coverage information using bedtools from Prokka output

# $1 path to gff file
# $2 fasta file

# clean up gff file form fasta content
cat $1 | sed '/^##FASTA$/,$d' \
  | sed '/^#/ d' > data/circos/coverage/${1##*/}_windows.bed.clean 

# generate .genome file
samtools faidx $2

# generating windows
bedtools makewindows -g $2.fai \
  -w 10000 > data/circos/coverage/${2##*/}_windows.bed

# extract coverage informations
bedtools coverage -a data/circos/coverage/${2##*/}_windows.bed\
   -b data/circos/coverage/${1##*/}_windows.bed.clean -counts > data/circos/coverage/${1##*/}_coverage.tmp

# reformat
awk '{print $1" " $2" "$3" "$4}' data/circos/coverage/${1##*/}_coverage.tmp > data/circos/coverage/${1##*/}_cov.txt

cat data/circos/coverage/${1##*/}_cov.txt >> data/circos/coverage/cov_all.txt
