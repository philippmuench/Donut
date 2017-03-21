#/bin/sh

# $1: contig fasta file
# $2: color

# extract informations
cat $1 | awk '$0 ~ ">" {print c; c=0;printf "chr - " substr($0,2,100) " " substr($0,2,100) " " "0" " "; } $0 !~ ">" {c+=length($0);} END { print c; }' | sed '/^\s*$/d' > data/circos/karyotype/${1##*/}_chr.txt

# add color identification
while IFS= read -r line; do echo "$line $2"; done < data/circos/karyotype/${1##*/}_chr.txt > data/chr.tmp
mv data/chr.tmp data/circos/karyotype/${1##*/}_chr.txt

# process config file
chr_list=$(awk '{print $3}' data/circos/karyotype/${1##*/}_chr.txt)
function join_by { local IFS="$1"; shift; echo "$*"; }
chr=$(join_by ', ' $chr_list)
# add chr infor to config file
sed -i "14s/.*/cromosomes               = $chr/" /data/config/circos.conf
sed -i "15s/.*/chromosomes_order        = $chr/" /data/config/circos.conf
