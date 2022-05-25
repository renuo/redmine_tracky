FROM ruby:2.7

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get install -y git libc6-dev lsof

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir -p /usr/src/redmine
RUN cd /usr/src && git clone https://github.com/redmine/redmine redmine --depth 1

WORKDIR /usr/src/redmine

COPY ./config /usr/src/redmine/config/

RUN bundle config set without postgresql rmagick
RUN bundle config set path vendor/bundle
RUN gem update bundler
RUN cd /usr/src/redmine && bundle install
