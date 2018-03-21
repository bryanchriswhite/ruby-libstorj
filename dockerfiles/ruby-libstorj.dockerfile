FROM storjlabs/storj-integration

RUN apt update -yqq
RUN apt install -yqq ruby-dev rubygems-integration

# copy scripts and source
RUN mkdir -p /storj/ruby-libstorj
COPY options.yml Gemfile Gemfile.lock ruby-libstorj.gemspec Rakefile Guardfile /storj/ruby-libstorj/
COPY ./dockerfiles/setup-user /storj/ruby-libstorj/setup-user
COPY ./lib /storj/ruby-libstorj/lib
COPY ./spec /storj/ruby-libstorj/spec
COPY ./ext /storj/ruby-libstorj/ext

# modify file permissions
RUN chmod 655 /storj/ruby-libstorj/setup-user/*.{js,sh}
WORKDIR /storj/ruby-libstorj/setup-user

# setup env variables
ARG STORJ_EMAIL='username@example.com'
ARG STORJ_PASS='password'
ARG STORJ_KEYPASS=''
ARG STORJ_MNEMONIC='abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about'
ARG STORJ_BRIDGE='http://127.0.0.1:6382'
ARG LIBSTORJ_INCLUDE='/storj/ruby-libstorj/ext/libstorj/src'
ENV STORJ_EMAIL=$STORJ_EMAIL
ENV STORJ_KEYPASS=$STORJ_KEYPASS
ENV STORJ_PASS=$STORJ_PASS
ENV STORJ_MNEMONIC=$STORJ_MNEMONIC
ENV STORJ_BRIDGE=$STORJ_BRIDGE
ENV LIBSTORJ_INCLUDE=$LIBSTORJ_INCLUDE

# remove STORJ_BRIDGE export in .bashrc
RUN sed -i '/export STORJ_BRIDGE.*/d' /root/.bashrc

RUN ./setup_user.sh

# useful if you want to interact with mongo from
# a "linked" container (e.g. python_libstorj)
# or from your host (if using just docker - don't forget `-p`)
EXPOSE 27017

WORKDIR /storj/ruby-libstorj
RUN gem install bundler
RUN bundle install
#RUN bundle exec rake install[no-test]

CMD /bin/bash
#CMD ["bundle", "exec", "rake"]
