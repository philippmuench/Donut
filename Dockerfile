FROM ubuntu:14.04.3

MAINTAINER Philipp Muench "philipp.muench@helmholtz-hzi.de"

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN apt-get install -y build-essential make wget libgd2-xpm-dev libxml-simple-perl git vim fonts-circos-symbols

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
COPY symbols.otf /fonts/symbols/symbols.otf
COPY start_circos.sh /start_circos.sh

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

#ENTRYPOINT ["/bin/bash","start_circos.sh"]
