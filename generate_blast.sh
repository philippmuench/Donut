#/bin/sh
# runs blast all vs. all of $a against $band generates circos output

a=data/circos/hmmvis/arman_2.fasta
a1=${a##*/}
a2=${a1%.*}

b=data/circos/hmmvis/dke_a.fasta
b1=${b##*/}
b2=${b1%.*}

# prepare blast db for sequences we want to query against
makeblastdb -in $a \
  -dbtype prot \
  -title $a2 \
  -out $a.blast.out

# blast sample against one other
blastp -query $b -db $a.blast.out \
  -out data/circos/blast/$b2.out \
  -evalue 0.00001 \
  -outfmt '6 qseqid qstart qend sseqid sstart send ppos' 

# search terms
awk '{print ">"$1" "}' \
  data/circos/blast/$b2.out > /data/circos/blast/$b2.out.searchterms

#while read f; do
#  start_pos=$(grep $f $b | awk '{print $3}')
#  end_pos=$(grep $f $b | awk '{print $4}')
#  printf '%s\t%s\n' $start_pos $end_pos >> /data/circos/blast/$b2.start.tmp
#done </data/circos/blast/$b2.out.searchterms

# remove ORF information form query files
