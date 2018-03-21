FROM ubuntu:16.04

# install global deps & tools
RUN apt-get update -yqq
RUN apt-get install -yqq git vim ruby-dev rubygems-integration python

# install libstorj
RUN apt-get install -yqq build-essential libtool autotools-dev automake libmicrohttpd-dev bsdmainutils
RUN apt-get install -yqq libcurl4-gnutls-dev nettle-dev libjson-c-dev libuv1-dev

RUN mkdir /storj
WORKDIR /storj
RUN git clone https://github.com/storj/libstorj
WORKDIR /storj/libstorj
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# install ruby-libstorj
RUN gem install ruby-libstorj

WORKDIR /storj
COPY ./dockerfiles/test.rb ./test.rb
COPY ./options.example.yml ./options.yml
CMD bash -c 'echo "### Edit ./options.yml & edit/run ruby ./test.rb ###" && /bin/bash'
