# Standalone YouTube audio/video/metadata extractor.
#
# Autonomous on purpose: yt-dlp does the extraction, a tiny Ruby (WEBrick)
# HTTP API wraps it. No Rails/Bundler/gems from the main app — this talks to
# the rest of the project only through its HTTP port and the shared /data
# volume (see docker-compose.yml).
FROM ruby:3.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      python3 python3-pip ffmpeg curl ca-certificates unzip && \
    pip3 install --no-cache-dir --break-system-packages yt-dlp && \
    gem install webrick --no-document && \
    curl -fsSL https://deno.land/install.sh | sh -s -- -y && \
    mv /root/.deno/bin/deno /usr/local/bin/deno && \
    rm -rf /root/.deno /var/lib/apt/lists/* /var/cache/apt/archives

WORKDIR /app
COPY server.rb ./

ENV OUTPUT_DIR=/data
ENV PORT=4567
VOLUME ["/data"]
EXPOSE 4567

CMD ["ruby", "server.rb"]
