#
# Debian GNU/Linux 11 (bullseye)
FROM --platform=$BUILDPLATFORM iamteacher/rails7.base

USER root

SHELL ["/bin/bash", "--login", "-c"]
RUN gem update --system 3.4.5

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# My Lucky User
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# CREATE GROUP `lucky`
RUN groupadd -g 7777 lucky

# CREATE USER `lucky`
RUN adduser lucky \
    -u 7777 \
    --ingroup lucky \
    --home /home/lucky \
    --shell /bin/bash \
    --disabled-password --gecos ''

# Assign user / groups
RUN usermod -G lucky root
RUN usermod -G lucky lucky

RUN chown -R lucky:lucky /usr/local/bin/ruby
RUN chown -R lucky:lucky /usr/local/bundle

# rails credentials:edit
ENV EDITOR="vim"

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# NODE.JS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

ENV NVM_DIR="/opt/.nvm"
RUN mkdir /opt/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
RUN nvm install 18.12.1

RUN chown -R lucky:lucky /opt/.nvm

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Loging as Lucky user
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

USER lucky
ENV EDITOR="vim"
WORKDIR /home/lucky/app
SHELL ["/bin/bash", "--login", "-c"]

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Register NODE.JS for this user
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

RUN touch ~/.bashrc
ENV NVM_DIR="/opt/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Install Gems
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

COPY Gemfile Gemfile
COPY --chown=lucky:lucky Gemfile.lock Gemfile.lock
RUN bundle
