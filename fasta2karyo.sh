# generates a karyotype file from fasta prodigal output

# $1: contig fasta file
# $2: ORF fasta file (prokka output)

# process chr
cat $1 | awk '$0 ~ ">" {print c; c=0;printf "chr - " substr($0,2,100) " " substr($0,2,100) " " "0" " "; } $0 !~ ">" {c+=length($0);} END { print c; }' > chr.txt

# process band
# parse fasta header and extract contig information
grep ">" $2 | awk '{print $1}' | sed 's/^.//' | awk -F'_' '{print $1}' > contig.txt
grep ">" $2 | awk -F'#' '{print $2}' > start.txt 
grep ">" $2 | awk -F'#' '{print $3}' > end.txt
