# README

This project is Playground for `Rails 7` with using `Docker`.

## Why?

Usually It is difficult and time consuming to setup a typical rails environment from scratch.

**With this project you can start development process in minutes.**

### What is under the hood?

- Ruby 3.2
- Rails 7
- PgSQL (Database)
- Redis (Cache)
- Sidekiq (Async and Delayed Jobs)
- Sphinx (Full text search)
- Puma (Web Server)

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

*All trademarks, logos and brand names are the property of their respective owners.*

### Prerequisites

On your host you have:

- Ruby 2+
- Docker
- Git

### How to start?

- `git clone git@github.com:the-teacher/rails7-docker.git`
- `cd rails7-docker`
- `bin/setup`

```
1. Launching PgSQL container
2. Launching Rails container
3. Installing Gems. Please Wait
4. Create DB. Migrate DB. Create Seeds
5. Launching Redis Container
6. Generate Sphinx Config
7. Launching Sphinx Container
8. Indexing Article Model
9. Launching Rails App on the port 3000
10. Visit: http://localhost:3000
```

### To Run All Containers

From the root of the project

```sh
docker compose -f docker/docker-compose.yml up -d
```

```sh
[+] Running 4/4
  ⠿ Container rails7app-redis-1   Running
  ⠿ Container rails7app-psql-1    Running
  ⠿ Container rails7app-sphinx-1  Running
  ⠿ Container rails7app-rails-1   Running
```

### To See Running Containers

```sh
docker ps --format 'table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Ports}}'
```

```
NAMES                CONTAINER ID   IMAGE                          PORTS
rails7app-sphinx-1   7379414a8127   macbre/sphinxsearch:3.4.1      36307/tcp
rails7app-redis-1    df3cc69795bb   redis:7.0.5-alpine             6379/tcp
rails7app-rails-1    2042c1346ef1   iamteacher/rails7:2023.arm64   0.0.0.0:3000->3000/tcp
rails7app-psql-1     60bf07fc70fe   postgres:15.1-bullseye         5432/tcp
```

### To Get In a Container

**Rails**

```sh
docker exec -ti rails7app-rails-1 bash
```

**PgSQL**

```sh
docker exec -ti rails7app-psql-1 bash
```

**Redis**

```sh
docker exec -ti rails7app-psql-1 ash
```

**Sphinx**

```sh
docker exec -ti rails7app-sphinx-1 ash
```

### To Stop All Containers

From the root of the project

```sh
docker compose -f docker/docker-compose.yml down
```

```sh
[+] Running 4/4
  ⠿ Container rails7app-redis-1   Removed
  ⠿ Container rails7app-psql-1    Removed
  ⠿ Container rails7app-sphinx-1  Removed
  ⠿ Container rails7app-rails-1   Removed
```

### Conventions and Agreements

For demonstration, education and maintainance purposes I use the following approach:

**Data**

- All data related folders for services are placed in `./db`
- All service related folders are `UPPERCASED`

```
./db
├── PGSQL
├── REDIS
└── SPHINX
```

**Configuration Files**

- All services' configurations are placed in `./config`
- All service related configs are `_UNDERSCORED` and `UPPERCASED`

```
./config
├── _SPHINX (<< folder)
├── _PUMA.rb
├── _SIDEKIQ.yml
└── _THINKING_SPHINX.yml
```

**Initialazers**

- All services' initializers are placed in `./config/initializers`
- All services' initializers are `_UNDERSCORED` and `UPPERCASED`

```
./config/initializers/
├── _REDIS.rb
├── _SIDEKIQ.rb
└── _SPHINX.rb
```

**Rails user**

As a user to own files and run Rails inside a container I use

`user:group` => `lucky:lucky` => `7777:7777`

If you would like to run the project on a linux environment then:

- create group `lucky (7777)` and user `lucky (7777)`
- run the project with `RUN_AS=7777:7777` option

### TODO

- ElasticSearch. [Chewy](https://github.com/toptal/chewy)
- Memcached [Link](https://devcenter.heroku.com/articles/building-a-rails-3-application-with-memcache)
- Puma on systemd [Link](https://github.com/puma/puma/blob/master/docs/systemd.md)
- Sidekiq on systemd [Link](https://github.com/mperham/sidekiq/blob/main/examples/systemd/sidekiq.service)
- Action Cable [Link](https://guides.rubyonrails.org/action_cable_overview.html)
- Nginx

### License

MIT
