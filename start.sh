#/bin/sh

# make a copy from input files
mkdir -p data/fasta_tmp/
cp data/fasta/*.fasta data/fasta_tmp/

# add file name to fasta header
for f in data/fasta_tmp/*.fasta; do
  header_string=$(basename ${f%.*})
  perl -pi -e "s/^>/>$header_string-/g" $f
done

# run prodigal and hmmsearch on input fasta files
mkdir -p data/hmmvis_output
hmmvis/hmmvis/hmmvis --fasta_dir data/fasta_tmp --output_dir data/hmmvis_output/ --hmm data/model.hmm

# generate circos files
colors=(pastel1-4-qual-1 pastel1-4-qual-2 pastel1-4-qual-3 pastel1-4-qual-4)

for i in data/hmmvis_output/*.fasta; do
  echo "processing" $i
  ./fasta2karyo.sh 'data/fasta/'${i##*/} $i ${colors[@]:$i:1}
done

# multiple karyotypes
list_karyo=(data/data/karyotype/*.txt)
files=$(printf '%q,' "${list_karyo[@]}")
sed -i "2s|.*|karyotype     = $files|" /data/circos.conf

# draw circos plot
#/root/software/circos/current/bin/circos -conf /data/circos.conf
