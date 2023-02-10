# Rails 7. Start Kit
# Image with the most common software

# STAGE | BASE DEBIAN
FROM --platform=$BUILDPLATFORM ruby:3.2 as base_debian
RUN apt-get update && apt-get install -y build-essential cmake nasm bash findutils

# STAGE | BASE RUST
FROM --platform=$BUILDPLATFORM rust:1 as base_rust
RUN apt-get update && apt-get install -y build-essential

# STAGE | oxipng
# amd 64 ? <jemalloc>: MADV_DONTNEED does not work (memset will be used instead)
# amd 64 ? <jemalloc>: (This is the expected behaviour if you are running under QEMU)
FROM base_rust as oxipng

RUN wget -O oxipng-8.0.0.tar.gz https://github.com/shssoichiro/oxipng/archive/refs/tags/v8.0.0.tar.gz
RUN tar -xvzf oxipng-8.0.0.tar.gz
WORKDIR /oxipng-8.0.0
RUN cargo build --release; exit 0
RUN cargo build --release
RUN install -c target/release/oxipng /usr/local/bin

# STAGE | jpegtran
FROM base_debian as libjpeg

RUN wget -O jpegsrc.v9e.tar.gz https://www.ijg.org/files/jpegsrc.v9e.tar.gz
RUN tar -xvzf jpegsrc.v9e.tar.gz
RUN cd jpeg-9e && \
    ./configure && \
    make install

# STAGE | LIB MOZ JPEG (common)
FROM base_debian as libmozjpeg

RUN wget -O mozjpeg-4.1.1.tar.gz https://github.com/mozilla/mozjpeg/archive/v4.1.1.tar.gz
RUN tar -xvzf mozjpeg-4.1.1.tar.gz
RUN cd mozjpeg-4.1.1 && \
    cmake -DPNG_SUPPORTED=0 . && \
    make install

# STAGE | jpeg-recompress
FROM libmozjpeg as jpegarchive

RUN wget -O jpegarchive-2.2.0.tar.gz https://github.com/danielgtaylor/jpeg-archive/archive/v2.2.0.tar.gz
RUN tar -xvzf jpegarchive-2.2.0.tar.gz
RUN cd jpeg-archive-2.2.0 && \
    CFLAGS=-fcommon make install

# STAGE | pngquant
FROM base_debian as pngquant

RUN wget -O pngquant-2.18.0.tar.gz https://pngquant.org/pngquant-2.18.0-src.tar.gz
RUN tar -xvzf pngquant-2.18.0.tar.gz
RUN cd pngquant-2.18.0 && \
    make install

# STAGE | pngout-static
FROM base_debian as pngout-static

RUN wget -O pngout-20200115-linux-static.tar.gz http://www.jonof.id.au/files/kenutils/pngout-20200115-linux-static.tar.gz
RUN tar -xvzf pngout-20200115-linux-static.tar.gz
RUN cd pngout-20200115-linux-static && \
    cp amd64/pngout-static /usr/local/bin/pngout

# STAGE | advpng
FROM base_debian as advancecomp

RUN wget -O advancecomp-2.5.tar.gz https://github.com/amadvance/advancecomp/releases/download/v2.5/advancecomp-2.5.tar.gz
RUN tar -xvzf advancecomp-2.5.tar.gz
RUN cd advancecomp-2.5 && \
    ./configure && \
    make install

# STAGE | MAIN
FROM --platform=$BUILDPLATFORM ruby:3.2

ARG TARGETARCH
ARG BUILDPLATFORM

RUN echo "$BUILDPLATFORM" > /BUILDPLATFORM
RUN echo "$TARGETARCH" > /TARGETARCH

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PRECOMPILED IMG PROCESSORS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

COPY --from=advancecomp   /usr/local/bin/advpng          /usr/bin
COPY --from=oxipng        /usr/local/bin/oxipng          /usr/bin
COPY --from=pngquant      /usr/local/bin/pngquant        /usr/bin
COPY --from=pngout-static /usr/local/bin/pngout          /usr/bin

COPY --from=jpegarchive  /usr/local/bin/jpeg-recompress  /usr/bin

COPY --from=libjpeg      /usr/local/bin/jpegtran         /usr/bin
COPY --from=libjpeg      /usr/local/lib/libjpeg.so.9     /usr/lib

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PRECOMPILED IMG PROCESSORS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

RUN apt-get update && apt-get install --yes \
    gifsicle \
    jhead \
    optipng \
    pngcrush

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# JPEGOPTIM
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

WORKDIR /tmp

RUN wget -O jpegoptim-1.5.1.tar.gz https://github.com/tjko/jpegoptim/archive/v1.5.1.tar.gz
RUN tar -xvzf jpegoptim-1.5.1.tar.gz

RUN cd jpegoptim-1.5.1 && \
    ./configure && \
    make install

RUN rm -rf jpegoptim-1.5.1*

WORKDIR /

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# COMMON
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

RUN apt-get update && apt-get install --yes \
    telnet \
    cron \
    vim

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IMG PROCESSORS TEST
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

RUN mkdir -p /tmp/image_optim
COPY Rails7StartKit/test/image_processors.sh /tmp/image_optim/image_processors.sh
