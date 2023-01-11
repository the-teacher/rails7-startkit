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
    <td><b>Docker</b><br>Containerization for Services</td>
    <td>Helps to keep all required services in containers. To have fast and predictable installation process in minutes</td>
  </tr>
  <tr>
    <td><img width="100px" alt="pgsql" src="docs/pgsql.png"></td>
    <td><b>PostgresSQL</b><br>Database</td>
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
    <td><b>gem "config"</b></td>
    <td>Configuration management tool</td>
  </tr>
  <tr>
    <td><img width="100px" alt="elastic" src="docs/elastic.png"></td>
    <td><b>Elasticsearch</b><br></td>
    <td>The world’s leading Search engine</td>
  </tr>
  <tr>
    <td><img width="100px" alt="chewy" src="docs/chewy.png"></td>
    <td><b>Chewy</b><br></td>
    <td>Ruby Connector to Elasticsearch</td>
  </tr>
  <tr>
    <td><img width="100px" alt="redis" src="docs/redis.png"></td>
    <td><b>Redis</b></td>
    <td>In-memory data store. For caching and as a dependency of Sidekiq</td>
  </tr>
  <tr>
    <td><img width="100px" alt="sidekiq" src="docs/sidekiq.png"></td>
    <td><b>Sidekiq</b></td>
    <td>Job Scheduler and Async Tasks Executor. Can be used as a stand alone tool or as ActiveJob backend</td>
  </tr>
  <tr>
    <td><img width="100px" alt="import-maps" src="docs/import-maps.png"></td>
    <td><b>Import Maps</b></td>
    <td>Rails' recommended way to process JavaScript</td>
  </tr>
  <tr>
    <td><img width="100px" alt="puma" src="docs/puma.png"></td>
    <td><b>Puma</b></td>
    <td>Application Web Server. To launch Rails app</td>
  </tr>
  <tr>
    <td>TODO:</td>
    <td>~~~~~~~~~~~~</td>
    <td>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="docs/devise.png"></td>
    <td><b>Devise</b></td>
    <td>Authentication solution for Rails</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="docs/devise.png"></td>
    <td><b>Devise</b></td>
    <td>Login with Facebook and Google</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="docs/devise.png"></td>
    <td><b>Devise and Action Mailer</b></td>
    <td>Sending emails for account confirmations</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="docs/whenever.png"></td>
    <td><b>Whenever.png</b></td>
    <td>Cron based periodical tasks</td>
  </tr>
  <tr>
    <td>Logo</td>
    <td>New Thing</td>
    <td>...Coming Soon</td>
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
2. Launching Rails container
3. Installing Gems. Please Wait
4. Create DB. Migrate DB. Create Seeds
5. Launching Redis Container
8. Indexing Article Model
9. Launching Rails App with Puma
10. Launching Sidekiq
11. Visit: http://localhost:3000
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
      <td>bin/setup</td>
      <td>Download images, run containers, initialize data, launch all processes.</td>
    </tr>
    <tr>
      <td>bin/open</td>
      <td>Get in <code>Rails</code> Container (`rails` by default)</td>
    </tr>
    <tr>
      <td>bin/open rails</td>
      <td>Get in <code>Rails</code> Container</td>
    </tr>
    <tr>
      <td>bin/open psql</td>
      <td>Get in <code>PgSQL</code> Container</td>
    </tr>
    <tr>
      <td>bin/open redis</td>
      <td>Get in <code>Redis</code> Container</td>
    </tr>
    <tr>
      <td>bin/open elastic</td>
      <td>Get in <code>ElasticSearch</code> Container</td>
    </tr>
    <tr>
      <td>bin/status</td>
      <td>To see running containers and launched services</td>
    </tr>
    <tr>
      <td>bin/start</td>
      <td>Start everything if it is stopped</td>
    </tr>
    <tr>
      <td>bin/stop</td>
      <td>Stop processes in <code>Rails</code> container</td>
    </tr>
    <tr>
      <td>bin/stop_all</td>
      <td>Stop everything if it is running</td>
    </tr>
    <tr>
      <td>bin/index</td>
      <td>Run Search engines indexation</td>
    </tr>
    <tr>
      <td>bin/reset</td>
      <td>Reset data od services in <code>./db</code> folder</td>
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
├── _SIDEKIQ.yml
└── _THINKING_SPHINX.yml
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
