#/bin/sh
# extract hmm hits

# $1: hmmnsearch output
# $2: export file path

echo "generate HMM data"

# id
cat $1 \
  | sed '/^#/ d' \
  | awk '{print $1}' \
  | awk -F '_' '{print $1"_"$2}' >  data/circos/hmm/${1##*/}_chr.tmp

cat $1 \
  | sed '/^#/ d' \
  | awk -F '#' '{print $2}' > data/circos/hmm/${1##*/}_start.tmp

cat $1 \
  | sed '/^#/ d' \
  | awk -F '#' '{print $3}' > data/circos/hmm/${1##*/}_end.tmp

paste data/circos/hmm/${1##*/}_chr.tmp \
  data/circos/hmm/${1##*/}_start.tmp \
  data/circos/hmm/${1##*/}_end.tmp \
  | sed -e "s/[[:space:]]\+/ /g" > data/circos/hmm/${1##*/}_hmm.txt

cat data/circos/hmm/${1##*/}_hmm.txt >> $2

