#/bin/sh
# extract orf locations from prokka

# $1: prokka gff output

# chr
cat $1 \
  | sed '/^##FASTA$/,$d' \
  | sed '/^#/ d' \
  | awk '{print $1}' > data/circos/prokka/${1##*/}_chr.tmp

# start
cat $1 \
  | sed '/^##FASTA$/,$d' \
  | sed '/^#/ d' \
  | awk '{print $4}' > data/circos/prokka/${1##*/}_start.tmp

# end
cat $1 \
  | sed '/^##FASTA$/,$d' \
  | sed '/^#/ d' \
  | awk '{print $5}' > data/circos/prokka/${1##*/}_end.tmp

# strand
cat $1 \
  | sed '/^##FASTA$/,$d' \
  | sed '/^#/ d' \
  | awk '{print $7}' > data/circos/prokka/${1##*/}_strand.tmp

# annoation
cat $1 \
  | sed '/^##FASTA$/,$d' \
  | sed '/^#/ d' \
  | awk '{print $11}' \
  | awk -F';' '{print $3}' \
  | awk -F'=' '{print $2}' > data/circos/prokka/${1##*/}_annotation.tmp

# replace empty lines
sed -i.bak "s/^\s*$/O/g" data/circos/prokka/${1##*/}_annotation.tmp
sed -i.bak "s/^hypothetical/o/g" data/circos/prokka/${1##*/}_annotation.tmp

# merge per file
paste data/circos/prokka/${1##*/}_chr.tmp \
  data/circos/prokka/${1##*/}_start.tmp \
  data/circos/prokka/${1##*/}_end.tmp \
  data/circos/prokka/${1##*/}_annotation.tmp \
  | sed -e "s/[[:space:]]\+/ /g" > data/circos/prokka/${1##*/}_orf.txt

cat data/circos/prokka/${1##*/}_orf.txt >> data/circos/prokka/prokka_orf.txt


