FROM ubuntu:14.04.3

MAINTAINER Dennis Hazelett "dennis.hazelett at csmc.edu"

RUN DEBIAN_FRONTEND=noninteractive apt-get update 
RUN apt-get install -y build-essential make wget libgd2-xpm-dev libxml-simple-perl git vim

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
  #https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.1.tar.gz
RUN tar xvfz libgd-2.1.0.tar.gz \
  && cd libgd-2.1.0 \
  && ./configure --with-png=/usr/local --with-freetype=/usr/local --with-jpeg=/usr/local --prefix=/usr/local \
  && make \
  && make install

RUN /usr/local/bin/gdlib-config --all

#RUN wget http://circos.ca/distribution/lib/GD-2.53.tar.gz \
#  && tar xvfz GD-2.53.tar.gz \
#  && cd GD-2.53 \
#  && perl Makefile.PL \
#  && make \
#  && make install

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