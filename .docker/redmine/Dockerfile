FROM redmine:4.2

ENV LANG=en_us
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -qq > /dev/null \
  && apt install -qqy build-essential wget gnupg make vim less > /dev/null

RUN apt install chromium -y

CMD ["rails", "server", "-b", "0.0.0.0"]
