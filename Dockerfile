FROM ruby:3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y wkhtmltopdf nvi less
RUN useradd -m -u 1000 appuser
RUN mkdir -p /app

USER appuser
WORKDIR /app

CMD ["sh", "-c", "rm -f /app/tmp/pids/server.pid && rails server -b 0.0.0.0 -e production"]
