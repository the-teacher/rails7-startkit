# How to Update Versions

## Ruby

| Where to check                                   | File to edit                                          |
| ------------------------------------------------ | ----------------------------------------------------- |
| https://www.ruby-lang.org/en/downloads/releases/ | `__RailsApp__/.ruby-version`                          |
|                                                  | `docker/IMAGES/_Main.Dockerfile` → `ARG RUBY_VERSION` |
|                                                  | `__RailsApp__/Dockerfile` → `ARG RUBY_VERSION`        |

All three files must have the same version (`__RailsApp__/Dockerfile` is easy to forget). After updating — rebuild the image locally (see `how_to_update_images_locally.md`).

---

## RubyGems

| Where to check                                     | File to edit                                                 |
| -------------------------------------------------- | ------------------------------------------------------------ |
| https://rubygems.org/gems/rubygems-update/versions | `docker/IMAGES/_Main.Dockerfile` → `ARG DEFAULT_GEM_VERSION` |

After updating — rebuild the image.

---

## Bundler

| Where to check                             | File to edit                                              |
| ------------------------------------------ | --------------------------------------------------------- |
| https://rubygems.org/gems/bundler/versions | `__RailsApp__/Gemfile.lock` → `BUNDLED WITH` (last lines) |

After updating `Gemfile.lock`, run inside the container:

```bash
docker compose -f ./docker/docker-compose.yml exec rails gem install bundler -v X.X.X
docker compose -f ./docker/docker-compose.yml exec rails make bundle
```

---

## Rails

| Where to check                           | File to edit                                     |
| ---------------------------------------- | ------------------------------------------------ |
| https://rubygems.org/gems/rails/versions | `__RailsApp__/Gemfile` → `gem "rails", "~> X.X"` |

`gem "rails", "~> 8.0"` already allows any 8.x, so for a patch/minor update the `Gemfile` does not change — run `bundle update rails` instead. After updating, run:

```bash
docker compose -f ./docker/docker-compose.yml exec rails make bundle
docker compose -f ./docker/docker-compose.yml exec rails make db-migrate
```

### Other gems and security audit

`bundle update rails` updates only Rails and its dependencies. Check the rest for known vulnerabilities and update everything:

```bash
docker compose -f ./docker/docker-compose.yml exec rails bundle exec bundler-audit check --update
docker compose -f ./docker/docker-compose.yml exec rails bundle update
```

Then verify (the app currently has no tests, so rubocop/brakeman are the real checks):

```bash
docker compose -f ./docker/docker-compose.yml exec rails bundle exec rubocop
docker compose -f ./docker/docker-compose.yml exec rails bin/brakeman -q
docker compose -f ./docker/docker-compose.yml exec rails bin/rails test
```

---

## Node.js

| Where to check                 | File to edit                                          |
| ------------------------------ | ----------------------------------------------------- |
| https://nodejs.org/en/download | `docker/IMAGES/_Main.Dockerfile` → `ARG NODE_VERSION` |

Node.js is installed via **nvm** for the `rails` user. The `PATH` in the Dockerfile points to the versioned nvm binary directory and is updated automatically on rebuild.

After updating `ARG NODE_VERSION` — rebuild the image.

To verify after rebuild:

```bash
docker compose -f ./docker/docker-compose.yml exec rails node --version
```

> Node.js "Current" (even major, e.g. 26) is not LTS until about October. Check https://nodejs.org/en/about/previous-releases and choose Current or the latest LTS deliberately.
>
> When updating Node.js, also check if **npm** and **nvm** versions need updating (see sections below).

---

## npm

| Where to check                    | File to edit                                         |
| --------------------------------- | ---------------------------------------------------- |
| https://www.npmjs.com/package/npm | `docker/IMAGES/_Main.Dockerfile` → `ARG NPM_VERSION` |

npm is upgraded globally via nvm after Node.js installation. Before a major npm bump, check that it supports your Node version: `curl -s https://registry.npmjs.org/npm/X.Y.Z | jq .engines`. Update `ARG NPM_VERSION` and rebuild the image.

To verify after rebuild:

```bash
docker compose -f ./docker/docker-compose.yml exec rails npm --version
```

---

## nvm

| Where to check                         | File to edit                                         |
| -------------------------------------- | ---------------------------------------------------- |
| https://github.com/nvm-sh/nvm/releases | `docker/IMAGES/_Main.Dockerfile` → `ARG NVM_VERSION` |

nvm is installed via the official install script using the version specified in `ARG NVM_VERSION`. After updating — rebuild the image.

To verify after rebuild:

```bash
docker compose -f ./docker/docker-compose.yml exec rails bash -c '. ~/.nvm/nvm.sh && nvm --version'
```

---

## Summary table

| Package  | Version location                                   | Files to edit                                                         |
| -------- | -------------------------------------------------- | --------------------------------------------------------------------- |
| Ruby     | https://www.ruby-lang.org/en/downloads/releases/   | `__RailsApp__/.ruby-version`, `__RailsApp__/Dockerfile`, `_Main.Dockerfile` → `ARG RUBY_VERSION` |
| RubyGems | https://rubygems.org/gems/rubygems-update/versions | `_Main.Dockerfile` → `ARG DEFAULT_GEM_VERSION`                        |
| Bundler  | https://rubygems.org/gems/bundler/versions         | `__RailsApp__/Gemfile.lock` → `BUNDLED WITH` (usually equals RubyGems) |
| Rails    | https://rubygems.org/gems/rails/versions           | `__RailsApp__/Gemfile`                                                |
| Node.js  | https://nodejs.org/en/download                     | `_Main.Dockerfile` → `ARG NODE_VERSION`                               |
| npm      | https://www.npmjs.com/package/npm                  | `_Main.Dockerfile` → `ARG NPM_VERSION`                                |
| nvm      | https://github.com/nvm-sh/nvm/releases             | `_Main.Dockerfile` → `ARG NVM_VERSION`                                |

> After any change to `_Main.Dockerfile` — rebuild the image locally (see `how_to_update_images_locally.md`).
