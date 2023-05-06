# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "importmap/articlesIndex",      preload: true
pin "importmap/theSearchHighlight", preload: true

pin "importmap/application", preload: true

# ./bin/importmap pin react react-dom
# ./bin/importmap pin react react-dom --download
# ./bin/importmap unpin react react-dom

# pin "react",     preload: true # @18.2.0
# pin "react-dom", preload: true # @18.2.0
# pin "scheduler", preload: true # @0.23.0
