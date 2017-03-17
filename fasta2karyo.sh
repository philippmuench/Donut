# generates a karyotype file from fasta prodigal output

# $1: contig fasta file
# $2: ORF fasta file (prokka output)

# process chr
echo "extract chr informations"
cat $1 | awk '$0 ~ ">" {print c; c=0;printf "chr - " substr($0,2,100) " " substr($0,2,100) " " "0" " "; } $0 !~ ">" {c+=length($0);} END { print c; }' > ${1##*/}_chr.txt

# process band
echo "extract band informations"
grep ">" $2 | awk '{print $1}' | sed 's/^.//' | awk -F'_' '{print $1}' > ${2##*/}_contig.txt
grep ">" $2 | awk -F'#' '{print $2}' > ${2##*/}_start.txt 
grep ">" $2 | awk -F'#' '{print $3}' > ${2##*/}_end.txt

# merge files to one karyofile
