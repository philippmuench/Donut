#/bin/sh

# folder where circos files will be written to
rm -rf data/circos
rm -rf data/circos/orf/all_orf.txt
rm -rf data/circos/hmm/hmm_all.txt
rm -rf data/circos/prokka/prokka_orf.txt
mkdir -p data/circos/orf
mkdir -p data
mkdir -p data/output
mkdir -p data/circos/hmmvis
mkdir -p data/circos/fasta/
mkdir -p data/circos/hmm

rm -rf data/circos/karyotype/
mkdir -p data/circos/karyotype/

# make a copy from input files
mkdir -p data/circos/fasta/
cp data/genomes/*.fasta data/circos/fasta/

# add file name to fasta header
for f in data/circos/fasta/*.fasta; do
  header_string=$(basename ${f%.*})
  perl -pi -e "s/^>/>$header_string-/g" $f
done

# run prokka
for file in data/circos/fasta/*.fasta; do
  echo "run Prokka on $file"
  name=$(basename ${file%.*})
  prokka --outdir data/circos/prokka/$name $file
  mv data/circos/prokka/$name/*.gff data/circos/prokka/$name.gff 
done

# run prodigal and hmmsearch on input fasta files
hmmvis/hmmvis/hmmvis --fasta_dir data/circos/fasta --output_dir data/circos/hmmvis/ --hmm data/hmm/model.hmm

# generate circos files
colors_pos=(paired-12-qual-1 paired-12-qual-3 paired-12-qual-5 paired-12-qual-7)
colors_neg=(paired-12-qual-2 paired-12-qual-4 paired-12-qual-6 paired-12-qual-8)
n=1
for i in data/circos/hmmvis/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_chr.sh 'data/circos/fasta/'${i##*/} ${colors_neg[@]:$n:1}
  ./generate_gc.sh $i
  ./generate_orf.sh $i
  ./generate_hmm.sh $i.out
  n=$(($n+1))
done

# process prokka output
for i in data/circos/prokka/*.gff; do
  ./generate_orf_prokka.sh $i
done


# multiple karyotypes
echo "update circos config file"
list_karyo=(data/circos/karyotype/*.txt)
files=$(printf '%q,' "${list_karyo[@]}")
sed -i "2s|.*|karyotype     = $files|" data/config/circos.conf

# draw circos plot
/root/software/circos/current/bin/circos -conf data/config/circos.conf -noparanoid
echo "finished"

