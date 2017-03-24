#/bin/sh
# extract orf locations

# $1: contig fasta file

echo "generate ORF data"

# id
grep ">" $1 \
  | awk '{print $1}' \
  | sed 's/^.//' \
  | awk -F'_' '{print $1 "_" $2}' > data/circos/orf/${1##*/}_chr.tmp


# start position
grep ">" $1 \
  | awk -F'#' '{print $2}' > data/circos/orf/${1##*/}_start.tmp

# end/color position
grep ">" $1 \
  | awk -F'#' '{print $3}' > data/circos/orf/${1##*/}_end.tmp

# strand
grep ">" $1 \
  | awk -F "#" '{print $4}' \
  | sed 's/^.//' > data/circos/orf/${1##*/}_strand.tmp

paste data/circos/orf/${1##*/}_chr.tmp data/circos/orf/${1##*/}_start.tmp data/circos/orf/${1##*/}_end.tmp | sed -e "s/[[:space:]]\+/ /g" > data/circos/orf/${1##*/}_orf.txt

cat data/circos/orf/${1##*/}_orf.txt >> data/circos/orf/all_orf.txt

