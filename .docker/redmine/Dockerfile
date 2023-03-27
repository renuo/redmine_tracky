FROM --platform=linux/amd64 redmine:5.0.5

ENV LANG=en_us
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -qq > /dev/null \
  && apt install -qqy curl build-essential wget gnupg2 make vim less > /dev/null

# Install chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update -qqy && \
    apt-get -qy install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN bundle config --delete without

CMD ["rails", "server", "-b", "0.0.0.0"]
