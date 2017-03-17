#/bin/sh

# run prodigal and hmmsearch on input fasta files
mkdir -p data/hmmvis_output
hmmvis/hmmvis/hmmvis --fasta_dir data/fasta --output_dir data/hmmvis_output/ --hmm data/model.hmm

# generate circos files
for i in data/hmmvis_output/*.fasta; do
  echo "processing" $i
  ./fasta2karyo.sh 'data/fasta/'${i##*/} $i 
done

# draw circos plot
#/root/software/circos/current/bin/circos -conf /data/circos.conf
