#/bin/sh
# generates a karyotype file from fasta prodigal output
# $1: contig fasta file
# $2: ORF fasta file (prokka output)
# $3: color

# process chr
cat $1 | awk '$0 ~ ">" {print c; c=0;printf "chr - " substr($0,2,100) " " substr($0,2,100) " " "0" " "; } $0 !~ ">" {c+=length($0);} END { print c; }' | sed '/^\s*$/d' > ${1##*/}_chr.txt

# add color identification
while IFS= read -r line; do echo "$line $3"; done < ${1##*/}_chr.txt > chr.tmp 

# move chr file to karyotype folder
mv chr.tmp data/data/karyotype/${1##*/}_chr.txt

# process band
grep ">" $2 | awk '{print $1}' | sed 's/^.//' | awk -F'_' '{print $1}' > ${2##*/}_contig.txt
grep ">" $2 | awk -F'#' '{print $2}' > ${2##*/}_start.txt 
grep ">" $2 | awk -F'#' '{print $3}' > ${2##*/}_end.txt

#cp ${1##*/}_chr.txt data/data/karyotype/pca.karyotype.txt

# get list of chr
chr_list=$(awk '{print $3}' ${1##*/}_chr.txt)
function join_by { local IFS="$1"; shift; echo "$*"; }
chr=$(join_by ', ' $chr_list)

# add chr infor to config file
sed -i "14s/.*/cromosomes               = $chr/" /data/circos.conf
sed -i "15s/.*/chromosomes_order        = $chr/" /data/circos.conf

