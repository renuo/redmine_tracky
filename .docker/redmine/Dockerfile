FROM --platform=linux/amd64 redmine:5.0.5

ENV LANG=en_us
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -qq > /dev/null \
  && apt install -qqy curl build-essential wget gnupg2 make vim less > /dev/null

# Install chrome
# TODO: remove hardcode as soon as https://www.redmine.org/issues/37558 is fixed
ENV CHROME_VERSION "114.0.5735.90-1"
RUN set -ex && \
  apt-get update -qqy && \
  wget --no-check-certificate https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb && \
  apt-get install -qqyf ./google-chrome-stable_${CHROME_VERSION}_amd64.deb && \
  rm google-chrome-stable_${CHROME_VERSION}_amd64.deb

CMD ["rails", "server", "-b", "0.0.0.0"]
