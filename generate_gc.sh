#/bin/sh
# create GC data

echo "a:" $1 
grep ">" $1 | awk -F "#" '{print $5}' \
  | awk -F ";" '{print $6}' \
  |  awk -F '=' '{print $2}' > data/circos/${1##*/}_gc_val.tmp

grep ">" $1 | awk '{print $1}' | sed 's/^.//' \
  | awk -F'_' '{print $1 "_" $2}' > data/circos/${1##*/}_gc_id.tmp
grep ">" $1 | awk -F'#' '{print $2}' > data/circos/${1##*/}_gc_start.tmp
grep ">" $1 | awk -F'#' '{print $3}' > data/circos/${1##*/}_gc_end.tmp

paste data/circos/${1##*/}_gc_id.tmp \
  data/circos/${1##*/}_gc_start.tmp \
  data/circos/${1##*/}_gc_end.tmp \
  data/circos/${1##*/}_gc_val.tmp \
  | sed -e "s/[[:space:]]\+/ /g" > data/circos/${1##*/}_gc.tmp

cat data/circos/${1##*/}_gc.tmp >> data/circos/gc.txt
rm data/circos/*.tmp
