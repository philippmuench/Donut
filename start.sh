#/bin/sh

# folder where circos files will be written to
rm -rf data/circos
rm -rf data/circos/orf/all_orf.txt
rm -rf data/circos/hmm/hmm_all.txt
rm -rf data/circos/prokka/prokka_orf.txt
mkdir -p data/circos/orf
mkdir -p data
mkdir -p data/output
mkdir -p data/circos/hmmvis1
mkdir -p data/circos/hmmvis2
mkdir -p data/circos/hmmvis3
mkdir -p data/circos/hmmvis4
mkdir -p data/circos/hmmvis5
mkdir -p data/circos/hmmvis6
mkdir -p data/circos/fasta/
mkdir -p data/circos/hmm
mkdir -p data/circos/coverage
mkdir -p data/circos/blast

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
  prokka --outdir data/circos/prokka/$name $file >/dev/null 2>/dev/null
  mv data/circos/prokka/$name/*.gff data/circos/prokka/$name.gff 
done

# run prodigal and hmmsearch on input fasta files
hmmvis/hmmvis/hmmvis --fasta_dir data/circos/fasta --output_dir data/circos/hmmvis1/ --hmm data/hmm/list1.hmm >/dev/null 2>/dev/null

hmmvis/hmmvis/hmmvis --fasta_dir data/circos/fasta --output_dir data/circos/hmmvis2/ --hmm data/hmm/list2.hmm >/dev/null 2>/dev/null

hmmvis/hmmvis/hmmvis --fasta_dir data/circos/fasta --output_dir data/circos/hmmvis3/ --hmm data/hmm/list3.hmm >/dev/null 2>/dev/null

hmmvis/hmmvis/hmmvis --fasta_dir data/circos/fasta --output_dir data/circos/hmmvis4/ --hmm data/hmm/list4.hmm >/dev/null 2>/dev/null

hmmvis/hmmvis/hmmvis --fasta_dir data/circos/fasta --output_dir data/circos/hmmvis5/ --hmm data/hmm/list5.hmm >/dev/null 2>/dev/null

hmmvis/hmmvis/hmmvis --fasta_dir data/circos/fasta --output_dir data/circos/hmmvis6/ --hmm data/hmm/list6.hmm >/dev/null 2>/dev/null

# generate circos files
colors_pos=(paired-12-qual-1 paired-12-qual-3 paired-12-qual-5 paired-12-qual-7 paired-12-qual-9)
colors_neg=(paired-12-qual-2 paired-12-qual-4 paired-12-qual-6 paired-12-qual-8 paired-12-qual-10)
n=1
for i in data/circos/hmmvis1/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_chr.sh 'data/circos/fasta/'${i##*/} ${colors_neg[@]:$n:1}
  ./generate_gc.sh $i >/dev/null 2>/dev/null
  ./generate_orf.sh $i >/dev/null 2>/dev/null
  ./generate_hmm.sh $i.out >/dev/null 2>/dev/null
  n=$(($n+1))
done

# process the hmm files
hmmcol=(paired-12-qual-2 paired-12-qual-4 paired-12-qual-6 paired-12-qual-8 paired-12-qual-10)
n=1
for i in data/circos/hmmvis1/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_hmm.sh $i.out data/circos/hmm/hmm_all_1.txt >/dev/null 2>/dev/null
done
n=$(($n+1))
for i in data/circos/hmmvis2/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_hmm.sh $i.out data/circos/hmm/hmm_all_2.txt >/dev/null 2>/dev/null
done
n=$(($n+1))
for i in data/circos/hmmvis3/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_hmm.sh $i.out data/circos/hmm/hmm_all_3.txt >/dev/null 2>/dev/null
done
n=$(($n+1))
for i in data/circos/hmmvis4/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_hmm.sh $i.out data/circos/hmm/hmm_all_4.txt >/dev/null 2>/dev/null
done
n=$(($n+1))
for i in data/circos/hmmvis5/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_hmm.sh $i.out data/circos/hmm/hmm_all_5.txt >/dev/null 2>/dev/null
done
n=$(($n+1))
for i in data/circos/hmmvis6/*.fasta; do
  echo "processing: 'data/circos/fasta/'${i##*/}"
  ./generate_hmm.sh $i.out data/circos/hmm/hmm_all_6.txt >/dev/null 2>/dev/null
done


for i in data/circos/prokka/*.gff; do
  # generate ORF locations
  ./generate_orf_prokka.sh $i >/dev/null 2>/dev/null
done

for i in data/circos/prokka/*.gff; do
  basename=${i##*/}
  name=${basename%.*}
 ./generate_coverage.sh $i data/circos/fasta/$name.fasta >/dev/null 2>/dev/null
 ./generate_coverage_hyp.sh $i data/circos/fasta/$name.fasta >/dev/null 2>/dev/null

done

# multiple karyotypes
echo "update circos config file"
list_karyo=(data/circos/karyotype/*.txt)
files=$(printf '%q,' "${list_karyo[@]}")
sed -i "2s|.*|karyotype     = $files|" data/config/circos.conf

echo "make blast search"

# make a list 
ls -1 data/circos/hmmvis1/*.fasta > data/circos/blast/list.txt

colors=(spectral-11-div-1 spectral-11-div-2 spectral-11-div-3 spectral-11-div-4 spectral-11-div-5 spectral-11-div-6 spectral-11-div-7 spectral-11-div-8 spectral-11-div-9 spectral-11-div-10 spectral-11-div-11)
# step 1: pick one and run vs. all others
firstline=$(head -n 1 data/circos/blast/list.txt)
tail -n +2 data/circos/blast/list.txt > data/circos/blast/list2.txt # to prevent self-comparison
n=1
while read line; do
  echo "comparing $firstline with $line"
  ./generate_blast.sh $firstline $line ${colors[@]:$n:1} >/dev/null 2>/dev/null
  n=$(($n+1))
done <data/circos/blast/list2.txt

# step 2: pick another one and run vs. all other without the first one picket
samplenum=$(wc -l /data/circos/blast/list2.txt | awk '{print $1}')
if [ $samplenum -gt 1 ]
then
  firstline=$(head -n 1 data/circos/blast/list2.txt)
  tail -n +2 /data/circos/blast/list2.txt > /data/circos/blast/list3.txt # to 
  while read line; do
    echo "comparing $firstline with $line"
    ./generate_blast.sh $firstline $line ${colors[@]:$n:1} >/dev/null 2>/dev/null
    n=$(($n+1))
  done </data/circos/blast/list3.txt

  # step 3: this should be recursive...
  samplenum=$(wc -l /data/circos/blast/list3.txt | awk '{print $1}')
  if [ $samplenum -gt 1 ]
  then
    firstline=$(head -n 1 /data/circos/blast/list3.txt)
    tail -n +2 /data/circos/blast/list3.txt > /data/circos/blast/list4.txt # to 
    while read line; do
      echo "comparing $firstline with $line"
      ./generate_blast.sh $firstline $line ${colors[@]:$n:1} >/dev/null 2>/dev/null
      n=$(($n+1))
     done <data/circos/blast/list4.txt
  fi
fi

#update link colors
Rscript updateLinkColors.R

# draw circos plot
/root/software/circos/current/bin/circos -conf data/config/circos.conf -noparanoid >/dev/null 2>/dev/null
echo "finished"




