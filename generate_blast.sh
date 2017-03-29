#/bin/sh
# runs blast all vs. all of $a against $band generates circos output

a=$1
a1=${a##*/}
a2=${a1%.*}

b=$2
b1=${b##*/}
b2=${b1%.*}

#$3: colors

# prepare blast db for sequences we want to query against
makeblastdb -in $a \
  -dbtype prot \
  -title $a2 \
  -out $a.blast.out

# blast sample against one other
blastp -query $b -db $a.blast.out \
  -out data/circos/blast/$b2.out \
  -evalue 0.00000001 \
  -outfmt '6 qseqid qstart qend sseqid sstart send ppos'

# search terms
awk '{print ">"$1"[[:space:]]"}' \
  data/circos/blast/$b2.out > /data/circos/blast/$b2.out.searchterms

while read f; do
  start_pos=$(grep $f $b | awk '{print $3}')
  end_pos=$(grep $f $b | awk '{print $5}')
  echo "$f $start_pos $end_pos" >> data/circos/blast/$b2.pos
done </data/circos/blast/$b2.out.searchterms

# do grep ORF id from file
awk '{print ">"$4"[[:space:]]"}' \
  data/circos/blast/$b2.out > /data/circos/blast/$a2.out.searchterms

while read f; do
  start_pos=$(grep $f $a | awk '{print $3}')
  end_pos=$(grep $f $a | awk '{print $5}')
  echo "$f $start_pos $end_pos" >> /data/circos/blast/$a2.pos
done </data/circos/blast/$a2.out.searchterms

# process chr
# data/circos/blast/$b2.out

# merge to one big file
paste  /data/circos/blast/$b2.out \
  /data/circos/blast/$b2.pos data/circos/blast/$a2.pos > data/circos/blast/$b2.$a2.joined

# sum columns
cat data/circos/blast/$b2.$a2.joined \
  | awk '{print $1" "$2+$9" "$3+$10" "$4" "$5+$9" "$6+$10}' > /data/circos/blast/blast.$a2.$b2.tmp

cat /data/circos/blast/blast.$a2.$b2.tmp \
  | awk '{sub(/\_/,"-",$1)};2' \
  | awk '{sub(/\_/,"-",$4)};2' \
  | awk '{sub(/\_/," ",$1)};2' \
  | awk '{sub(/\_/," ",$5)};2' \
  | awk '{print $1" "$3" "$4" "$5" "$7" "$8" color=vlgrey,thickness=1p"}' \
  | awk '{sub(/\-/,"_",$1)};2' \
  | awk '{sub(/\-/,"_",$4)};2' \
  | sed 's/ /\t/g' >> /data/circos/blast/blast_links.txt

rm -f /data/circos/blast/*.pos
rm -f /data/circos/blast/*.tmp
rm -f /data/circos/blast/*.joined
rm -f /data/circos/blast/*.out
rm -f /data/circos/blast/*.searchterms
rm -f /data/circos/blast/*out.searchterms
