# Donut

just a simple tool that generates a circos plot from a bunch of fasta files

# usuage
1. clone this repo `git clone https://github.com/philippmuench/Donut.git`
2. put your fasta (one or multipe) files in the `data/genomes/` folder
3. add your Hidden Markov model file to `data/hmm/model.hmm`
4. start the docker container `docker run -v /absolute/path/to/data/folder:/data philippmuench/easycircos`
5. inspect the output written to `data/output/`

# example output
![image](data/output/circos.png)

from outer to inner:
- GC content
- ORFs identified with prodigal
- hits to `data/hmm/model.hmm` based on hmmsearch against ORFs
