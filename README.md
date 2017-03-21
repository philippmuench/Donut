# Donut

just a simple tool that generates a circos plot from a bunch of fasta files.

# usuage
1. clone this repo `git clone https://github.com/philippmuench/Donut.git`
2. put your fasta (one or multipe) files in the `data/genomes/` folder
3. start the docker container `docker run -v /absolute/path/to/data/folder:/data philippmuench/easycircos`
4. inspect the output written to `data/output/`

# example output
![image](data/output/circos.png)
