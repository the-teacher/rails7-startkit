# Rails 7. Start Kit

Rails 7 App with Preinstalled Tools is Ready in Minutes!
## Why?

Usually It is difficult and time consuming to setup a typical Rails environment from scratch.

Since now if you have Ruby and Docker then you have working Rails environment in about 5 minutes without any manual efforts.
## What is under the hood?

<table>
  <thead>
    <tr>
      <th>Logotype</th>
      <th>Description</th>
      <th>Why it was added</th>
    </tr>
  </thead>
  <tbody>
  <tr>
    <td><img width="100px" alt="docker" src="docs/docker.png"></td>
    <td><b>Docker</b></td>
    <td>Helps to keep all required services in containers. To have fast and predictable installation process in minutes</td>
  </tr>
  <tr>
    <td><img width="100px" alt="pgsql" src="docs/pgsql.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/SQL_Database_Adapters">PostgresSQL</a></b></td>
    <td>Most popular relation database</td>
  </tr>
  <tr>
    <td><img width="100px" alt="ruby" src="docs/ruby.png"></td>
    <td><b>Ruby 3.2</b></td>
    <td>Most recent version of Ruby</td>
  </tr>
  <tr>
    <td><img width="100px" alt="rails7" src="docs/rails7.png"></td>
    <td><b>Rails 7</b></td>
    <td>Most recent version of Rails</td>
  </tr>
  <tr>
    <td><img width="100px" alt="gem config" src="docs/config.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/projects/config">gem&nbsp;"config"</a></b></td>
    <td>Configuration management tool</td>
  </tr>
  <tr>
    <td><img width="100px" alt="elastic" src="docs/elastic.png"></td>
    <td><b><a href="https://www.elastic.co">Elasticsearch</a></b></td>
    <td>The world’s leading Search engine</td>
  </tr>
  <tr>
    <td><img width="100px" alt="chewy" src="docs/chewy.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/projects/chewy">Chewy</a></b></td>
    <td>Ruby Connector to Elasticsearch</td>
  </tr>
  <tr>
    <td><img width="100px" alt="redis" src="docs/redis.png"></td>
    <td><b><a href="https://redis.io">Redis</a></b></td>
    <td>In-memory data store. For caching and as a dependency of Sidekiq</td>
  </tr>
  <tr>
    <td><img width="100px" alt="sidekiq" src="docs/sidekiq.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/Background_Jobs">Sidekiq</a></b></td>
    <td>Job Scheduler and Async Tasks Executor. Can be used as a stand alone tool or as ActiveJob backend</td>
  </tr>
  <tr>
    <td><img width="100px" alt="import-maps" src="docs/import-maps.png"></td>
    <td><b><a href="https://github.com/rails/importmap-rails">Import Maps</a></b></td>
    <td>Rails' recommended way to process JavaScript</td>
  </tr>
  <tr>
    <td><img width="100px" alt="faker" src="docs/faker.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/random_data_generation">Faker</a></b></td>
    <td>Fake data for development and testing</td>
  </tr>
  <tr>
    <td><img width="100px" alt="puma" src="docs/puma.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/web_servers">Puma</a></b></td>
    <td>Application Web Server. To launch Rails app</td>
  </tr>
  </tbody>
</table>

What I'm going to add...

<table>
  <thead>
    <tr>
      <th>Logotype</th>
      <th>Description</th>
      <th>Why it was added</th>
    </tr>
  </thead>
  <tbody>
  <tr>
    <td><img width="100px" alt="kaminari" src="docs/kaminari.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/pagination">Kaminari</a></b></td>
    <td>Pagination solution</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="docs/devise.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/rails_authentication">Devise</b></a></td>
    <td>Authentication solution for Rails</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="docs/devise.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/rails_authentication">Devise</b></a></td>
    <td>Login with Facebook and Google</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="docs/devise.png"></td>
    <td><b>Devise and Action&nbsp;Mailer</b></td>
    <td>Sending emails for account confirmations</td>
  </tr>
  <tr>
    <td><img width="100px" alt="letter_opener" src="docs/letter_opener.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/EMail_Fake_Servers">Letter Opener</a></b></td>
    <td>Email previwer for development</td>
  </tr>
  <tr>
    <td><img width="100px" alt="whenever" src="docs/whenever.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/scheduling">whenever</a></b></td>
    <td>Linux Cron based periodical tasks</td>
  </tr>
  <tr>
    <td><img width="100px" alt="rspec" src="docs/rspec.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/testing_frameworks">RSpec</a></b></td>
    <td>Testing Framework for Rails</td>
  </tr>
  <tr>
    <td><img width="100px" alt="rspec" src="docs/rubocop.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/code_metrics">Rubocop</a></b></td>
    <td>Ruby static code analyzer (a.k.a. linter) and formatter.</td>
  </tr>
  </tbody>
</table>

*All trademarks, logos and brand names are the property of their respective owners.*

### Prerequisites

On your host you have:

- Ruby 2+
- Docker
- Git

### How to start?

**ONE!**

```
git clone https://github.com/the-teacher/rails7-startkit.git
```

**TWO!**

```
cd rails7-startkit
```

**THREE!**

```
bin/setup
```

You will see something like that:

```
1. Launching PgSQL container
2. Launching ElasticSearch Container
3. Launching Rails container
4. Installing Gems. Please Wait
5. Create DB. Migrate DB. Create Seeds
6. Launching Redis Container
7. Indexing Article Model
8. Launching Rails App with Puma
9. Launching Sidekiq
10. Visit: http://localhost:3000
```

<details>
  <summary>Index Page of the Project</summary>
  <img alt="rails7-startkit" src="docs/index.png">
</details>

### `bin/` commands

From the root of the project

<table>
  <thead>
    <tr>
      <th>Command</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>bin/setup</b></td>
      <td>Download images, run containers, initialize data, launch all processes.</td>
    </tr>
    <tr>
      <td><b>bin/open</b></td>
      <td>Get in <b>Rails</b> Container (`rails` by default)</td>
    </tr>
    <tr>
      <td><b>bin/open&nbsp;rails</b></td>
      <td>Get in <b>Rails</b> Container</td>
    </tr>
    <tr>
      <td><b>bin/open&nbsp;psql</b></td>
      <td>Get in <b>PgSQL</b> Container</td>
    </tr>
    <tr>
      <td><b>bin/open&nbsp;redis</b></td>
      <td>Get in <b>Redis</b> Container</td>
    </tr>
    <tr>
      <td><b>bin/open&nbsp;elastic</b></td>
      <td>Get in <b>ElasticSearch</b> Container</td>
    </tr>
    <tr>
      <td><b>bin/status</b></td>
      <td>To see running containers and launched services</td>
    </tr>
    <tr>
      <td><b>bin/start</b></td>
      <td>Start everything if it is stopped</td>
    </tr>
    <tr>
      <td><b>bin/stop</b></td>
      <td>Stop processes in <b>Rails</b> container</td>
    </tr>
    <tr>
      <td><b>bin/stop_all</b></td>
      <td>Stop everything if it is running</td>
    </tr>
    <tr>
      <td><b>bin/cache</b></td>
      <td>Toggle caching in development and restart web server</td>
    </tr>
    <tr>
      <td><b>bin/index</b></td>
      <td>Run Search engines indexation</td>
    </tr>
    <tr>
      <td><b>bin/reset</b></td>
      <td>Reset data od services in <b>./db</b> folder</td>
    </tr>
  </tbody>
</table>

### Conventions and Agreements

For demonstration, education and maintainance purposes I use the following approach:

**Data**

- All services' data related folders are placed in `./db`
- All folders are `UPPERCASED`

```
./db
├── ELASTIC
├── PGSQL
└── REDIS
```

**Configuration Files**

- All services' configurations are placed in `./config`
- All configs are `_UNDERSCORED` and `UPPERCASED`

```
./config
├── _CONFIG.yml
├── _PUMA.rb
└── _SIDEKIQ.yml
```

**Initialazers**

- All services' initializers are placed in `./config/initializers`
- All files are `_UNDERSCORED` and `UPPERCASED`

```
./config/initializers/
├── _CHEWY.rb
├── _CONFIG.rb
├── _REDIS.rb
└── _SIDEKIQ.rb
```

### Rails user

As a user to own files and run Rails inside a container I use

`user:group` => `lucky:lucky` => `7777:7777`

If you would like to run the project on a linux environment then:

- create group `lucky (7777)` and user `lucky (7777)`
- run the project with `RUN_AS=7777:7777` option

### How to Run Tests

From the root of the project

```sh
  bin/open rails
```

Now you are in the Rails container and you can do everything as usual

```sh
  RAILS_ENV=test rake db:create
  rake test
```

### Questions and Answers

<details>
  <summary>What is an idea of this project?</summary>
  <br>
  <p>For many years Rails gives you freedom to choose development tools. Different databases, different paginators, different search engines, different delayed job solutions.</p>
  <p>It is great. But all the time you need to choose something and install it from scratch.</p>
  <p>I think I did my choice about many solutions and tools.</p>
  <p>I want to install my minimal pack of tools now and reuse my StartKit every time when I start a new project.</p>
  <p>With Docker I can roll out my minimal application with all required preinstalled tools in minutes, not in hours or in days.</p>
</details>

<details>
  <summary>Why did you create this project?</summary>
  <br>
  <p>
    I didn't work with Rails last 4 or 5 years. I wanted to learn new approaches and techniques. I found that there is still no a simple way to setup a blank app with most popular tools.
  </p>
  <p>So. Why not to make my own playground?</p>
</details>

<details>
  <summary>How do you choose technologies for the StartKit?</summary>
  <br>
  <p>I use tools that I like or want to learn.</p>
  <p>I use tools that I think are the most popular ones.</p>
</details>

<details>
  <summary>It looks good for development. What about production?</summary>
  <br>
  <p>I'm not a DevOps, but I have a vision how to deploy this code to production.</p>
  <p>Right now it is not described somehow. It is in my plans.</p>
</details>

### TODO

- <s>ElasticSearch. [Chewy](https://github.com/toptal/chewy)</s>
- <s>Memcached [Link](https://devcenter.heroku.com/articles/building-a-rails-3-application-with-memcache)</s> [Rejected](https://stackoverflow.com/questions/10558465/memcached-vs-redis)
- <s>Puma on systemd [Link](https://github.com/puma/puma/blob/master/docs/systemd.md)</s> [Rejected](https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container)
- <s>Sidekiq on systemd [Link](https://github.com/mperham/sidekiq/blob/main/examples/systemd/sidekiq.service)</s> [Rejected](https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container)
- Action Cable [Link](https://guides.rubyonrails.org/action_cable_overview.html)
- Nginx

### License

MIT
