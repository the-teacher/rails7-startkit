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

# Update NPM and Yarn versions
RUN npm install -g npm@9.6.0
RUN npm install yarn -g
RUN yarn set version berry

# Make things available for `lucky` user
RUN chown -R lucky:lucky /opt/.nvm

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Loging as Lucky user
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

USER lucky
ENV EDITOR="vim"
WORKDIR /home/lucky
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
WORKDIR /home/lucky/app

COPY Gemfile Gemfile
COPY --chown=lucky:lucky Gemfile.lock Gemfile.lock
RUN bundle

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Install Node modules
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

COPY --chown=lucky:lucky package.json package.json
COPY --chown=lucky:lucky yarn.lock yarn.lock
RUN source /opt/.nvm/nvm.sh && yarn
