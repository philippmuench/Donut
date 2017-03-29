FROM ubuntu:14.04.3

MAINTAINER Philipp Muench "philipp.muench@helmholtz-hzi.de"

# install java
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean

# install dependencies
RUN apt-get install -y build-essential make wget libgd2-xpm-dev libxml-simple-perl git vim fonts-circos-symbols python python-setuptools libblas-dev liblapack-dev gfortran libpython2.7-dev python-numpy libatlas-base-dev python-dev fort77 python-tk libdatetime-perl libxml-simple-perl libdigest-md5-perl bioperl filo zlib1g-dev zlib1g unzip apt-utils gcc-multilib libstdc++6 libc6 libgcc1  libpython2.7-dev curl

RUN wget https://bootstrap.pypa.io/get-pip.py \
  && python get-pip.py

RUN export PATH=$PATH:/usr/local/bin

RUN wget http://circos.ca/distribution/lib/libpng-1.6.14.tar.gz

RUN tar xvfz libpng-1.6.14.tar.gz
RUN cd libpng-1.6.14 \
  && ./configure --prefix=/usr/local \
  && make \
  && make install 

RUN wget http://circos.ca/distribution/lib/jpegsrc.v9.tar.gz
RUN tar xvfz jpegsrc.v9.tar.gz
RUN cd jpeg-9 \
  && ./configure --prefix=/usr/local \
  && make \
  && make install 

RUN wget http://circos.ca/distribution/lib/freetype-2.4.0.tar.gz 
RUN tar xvfz freetype-2.4.0.tar.gz \
  && cd freetype-2.4.0 \
  && ./configure --prefix=/usr/local \
  && make \
  && make install 

RUN wget http://circos.ca/distribution/lib/libgd-2.1.0.tar.gz

RUN tar xvfz libgd-2.1.0.tar.gz \
  && cd libgd-2.1.0 \
  && ./configure --with-png=/usr/local --with-freetype=/usr/local --with-jpeg=/usr/local --prefix=/usr/local \
  && make \
  && make install

RUN /usr/local/bin/gdlib-config --all

RUN mkdir -p fonts/symbols/

# prokka
# clone prokka
RUN git clone https://github.com/tseemann/prokka.git && \
	prokka/bin/prokka --setupdb
# set links to /usr/bin
ENV PATH $PATH:/prokka/bin

RUN cpan App::cpanminus
RUN cpanm List::MoreUtils Math::Bezier Math::Round Math::VecStat Params::Validate Readonly Regexp::Common SVG Set::IntSpan Statistics::Basic Text::Format Clone Config::General Font::TTF::Font GD

RUN mkdir ~/software \
  && mkdir ~/software/circos \
  && cd ~/software/circos \
  && wget http://circos.ca/distribution/circos-0.69-2.tgz \
  && tar xvfz circos-0.69-2.tgz \
  && ln -s circos-0.69-2 current \
  && echo 'export PATH=~/software/circos/current/bin:$PATH' >> ~/.bashrc \
  && rm -rf /*.tar.gz

# install prodigal
RUN wget https://github.com/hyattpd/Prodigal/releases/download/v2.6.3/prodigal.linux \
  && chmod a+x prodigal.linux \
  && mv prodigal.linux /usr/local/bin/prodigal

# install hmmer
RUN wget http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz
RUN tar -xzvf hmmer-3.1b2-linux-intel-x86_64.tar.gz
WORKDIR hmmer-3.1b2-linux-intel-x86_64
RUN ./configure
RUN make
RUN make install
WORKDIR /

# install hmmvis
RUN pip install numpy sklearn matplotlib pandas pytz Biopython seaborn
RUN git clone https://github.com/philippmuench/hmmvis.git
#WORKDIR hmmvis
#RUN python setup.py install

# install bedtools
WORKDIR /usr/local/
RUN git clone https://github.com/arq5x/bedtools2.git
WORKDIR /usr/local/bedtools2
RUN git checkout v2.25.0 
RUN pwd 
RUN make
RUN ln -s /usr/local/bedtools2/bin/* /usr/local/bin/
WORKDIR /

# install blast
# Download & install BLAST
RUN mkdir /opt/blast \
      && curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.30/ncbi-blast-2.2.30+-x64-linux.tar.gz \
      | tar -zxC /opt/blast --strip-components=1

ENV PATH /opt/blast/bin:$PATH

# install R
RUN apt-get -y install r-base libcurl4-openssl-dev
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
#RUN Rscript -e "source('https://bioconductor.org/biocLite.R')"
#RUN Rscript -e "biocLite('GenomicRanges')"

COPY etc/symbols.otf /fonts/symbols/symbols.otf
COPY etc/fonts/* /fonts/
COPY start_circos.sh /start_circos.sh
COPY start.sh /start.sh
COPY generate_chr.sh /generate_chr.sh
COPY generate_gc.sh /generate_gc.sh
COPY generate_orf.sh /generate_orf.sh
COPY generate_hmm.sh /generate_hmm.sh
COPY generate_orf_prokka.sh /generate_orf_prokka.sh
COPY generate_coverage.sh /generate_coverage.sh
COPY generate_coverage_hyp.sh /generate_coverage_hyp.sh
COPY generate_blast.sh /generate_blast.sh
COPY R/updateLinkColors.R updateLinkColors.R

ENTRYPOINT ["/bin/bash","./start.sh"]
