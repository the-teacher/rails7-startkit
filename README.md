# README

This project is Playground for `Rails 7` + `Docker`

## Why?

Usually It is difficult and time consuming to setup a typical rails environment from scratch.

**With this project you can start development in minutes.**

### What is under the hood?

- Ruby 3.2
- Rails 7
- PgSQL (Database)
- Redis (Cache)
- Sidekiq (Async and Delayed Jobs)
- Sphinx (Full text search)
- Puma

<table bgcolor="white">
  <tr>
    <td><img width="400" src="docs/docker.png" /></td></td>
    <td><img width="400" src="docs/ruby.png" /></td>
    <td><img width="400" src="docs/rails7.png" /></td>
    <td><img width="400" src="docs/puma.png" /></td></td>
  </tr>
  <tr>
    <td><img width="400" src="docs/pgsql.png" /></td>
    <td><img width="400" src="docs/redis.png" /></td>
    <td><img width="400" src="docs/sidekiq.png" /></td>
    <td><img width="400" src="docs/sphinx.png" /></td>
  </tr>
</table>

### Prerequisites

On your host you have:

- Ruby 2+
- Docker
- Git

### How to start?

- `git clone git@github.com:the-teacher/rails7-docker.git`
- `cd rails7-docker`
- `bin/setup`

In some minutes you can visit `localhost:3000`

### License

MIT
