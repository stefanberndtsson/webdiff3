FROM ruby:3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y wkhtmltopdf nvi less
RUN useradd -m -u 1000 appuser
RUN mkdir -p /app
RUN chown -R appuser:appuser /app

USER appuser
WORKDIR /home/appuser
RUN git clone --depth 1 https://github.com/stefanberndtsson/webdiff3 \
 && cd webdiff3 \
 && mv .??* * /app/
WORKDIR /app
RUN bundle install

CMD ["sh", "-c", "rm -f /app/tmp/pids/server.pid && rails server -b 0.0.0.0 -e production"]
