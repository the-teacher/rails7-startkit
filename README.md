# README

### How to Start

- `cd docker`
- remove `.keep` file form `db/PGSQL`
- `docker compose -f docker-compose.yml up psql`
- Stop after `database system is ready to accept connections`
- restore `.keep` file in `db/PGSQL`
- `docker compose -f docker-compose.yml up psql rails`
- `docker exec -ti --user=root rails7app-rails-1 bash`
- `cd /home/lucky/app`
- `bundle`
- `su lucky`
- `rake db:create`

### Other Sections

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
