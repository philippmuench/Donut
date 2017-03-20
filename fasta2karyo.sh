#/bin/sh
# generates a karyotype file from fasta prodigal output
# $1: contig fasta file
# $2: ORF fasta file (prokka output)
# $3: color for neg stand
# $4: color for pos strand

### process chr
cat $1 | awk '$0 ~ ">" {print c; c=0;printf "chr - " substr($0,2,100) " " substr($0,2,100) " " "0" " "; } $0 !~ ">" {c+=length($0);} END { print c; }' | sed '/^\s*$/d' > data/${1##*/}_chr.txt
# add color identification
while IFS= read -r line; do echo "$line $3"; done < data/${1##*/}_chr.txt > data/chr.tmp
mv data/chr.tmp data/data/karyotype/${1##*/}_chr.txt

### process band
grep ">" $2 | awk '{print $1}' | sed 's/^.//' | awk -F'_' '{print "band " $1 "_" $2}' > data/${2##*/}_contig.txt
grep ">" $2 | awk '{print $1}' | sed 's/^.//' | awk -F'_' '{print $1 "_" $2}' > data/${2##*/}_contig_id.txt
grep ">" $2 | awk -F'#' '{print $2}' > data/${2##*/}_start.txt
grep ">" $2 | awk -F'#' '{print $3}' > data/${2##*/}_end.txt
grep ">" $2 | awk -F "#" '{print $4}' | sed 's/^.//' > data/${2##*/}_strand.txt
grep ">" $2 | awk -F "#" '{print $5}' | awk -F ";" '{print $1}' | sed 's/^.//' > data/${2##*/}_id.txt
# replace -1/1 stand information with color id
sed -i.bak "s/^1/$3/g" data/${2##*/}_strand.txt
sed -i.bak "s/^-1/$4/g" data/${2##*/}_strand.txt
# join the columns together and add it to the chr file
paste data/${2##*/}_contig.txt data/${2##*/}_id.txt data/${2##*/}_id.txt data/${2##*/}_start.txt data/${2##*/}_end.txt data/${2##*/}_strand.txt | sed -e "s/[[:space:]]\+/ /g" > data/${2##*/}_bands.txt
cat data/${2##*/}_bands.txt >> data/data/karyotype/${1##*/}_chr.txt

# create GC heatmap
grep ">" $2 | awk -F "#" '{print $5}' | awk -F ";" '{print $6}' |  awk -F '=' '{print $2}' > data/${2##*/}_gc_val.txt
paste data/${2##*/}_contig_id.txt data/${2##*/}_start.txt data/${2##*/}_end.txt data/${2##*/}_gc_val.txt | sed -e "s/[[:space:]]\+/ /g" > data/${2##*/}_heatmap.txt

cat data/${2##*/}_heatmap.txt >> data/heatmap_all.txt

### process config file
chr_list=$(awk '{print $3}' data/${1##*/}_chr.txt)
function join_by { local IFS="$1"; shift; echo "$*"; }
chr=$(join_by ', ' $chr_list)
# add chr infor to config file
sed -i "14s/.*/cromosomes               = $chr/" /data/circos.conf
sed -i "15s/.*/chromosomes_order        = $chr/" /data/circos.conf
