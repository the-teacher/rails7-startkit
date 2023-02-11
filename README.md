# Rails 7. Start Kit

<img  alt="docker" src="Rails7StartKit/assets/logos/Rails7.StartKit.jpg">

## Install and Run `Ruby on Rails` now!

<i>Copy & Paste in your terminal</i>

```sh
git clone https://github.com/the-teacher/rails7-startkit.git && \
  cd rails7-startkit && \
  bin/setup
```

<details>
  <summary><b>OR</b> Super short one line option</summary>

```sh
eval "$(curl -sSL rails-start.com)"
```

*Executing scripts from the Internet can be dangerous! Check the source before using!*
</details>

### What Is That?

Rails App in a Docker container with some popular preinstalled tools.

### Why Do I Need It?

Save hours, days or weeks on setting up a typical Rails app.

### What Cases for Using It?

- You start new Rails project
- You need a playground for experiments
- You learn Rails and related technologies
- You teach people or record videos about Rails
- You are going to write a new article about Rails
### Show Me How It Works

<details>
  <summary>Show animated video</summary>
  <img width="500px" alt="rails7-startkit" src="Rails7StartKit/assets/images/rails7intro.gif">
</details>

## What Is Under the Hood?

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
    <td colspan="3"><b>Main</b></td>
  </tr>
  <tr>
    <td><img width="100px" alt="docker" src="Rails7StartKit/assets/images/docker.png"></td>
    <td><b>Docker</b></td>
    <td>Helps to keep all required services in containers. To have fast and predictable installation process in minutes</td>
  </tr>
  <tr>
    <td><img width="100px" alt="ruby" src="Rails7StartKit/assets/images/ruby.png"></td>
    <td><b>Ruby 3.2</b></td>
    <td>Most recent version of Ruby</td>
  </tr>
  <tr>
    <td><img width="100px" alt="rails7" src="Rails7StartKit/assets/images/rails7.png"></td>
    <td><b>Rails 7</b></td>
    <td>Most recent version of Rails</td>
  </tr>
  <tr>
    <td><img width="100px" alt="pgsql" src="Rails7StartKit/assets/images/pgsql.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/SQL_Database_Adapters">PostgresSQL</a></b></td>
    <td>Most popular relational database</td>
  </tr>
  <tr>
    <td colspan="3"><b>Cache and Delayed Jobs</b></td>
  </tr>
  <tr>
    <td><img width="100px" alt="redis" src="Rails7StartKit/assets/images/redis.png"></td>
    <td><b><a href="https://redis.io">Redis</a></b></td>
    <td>In-memory data store. For caching and as a dependency of Sidekiq</td>
  </tr>
  <tr>
    <td><img width="100px" alt="sidekiq" src="Rails7StartKit/assets/images/sidekiq.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/Background_Jobs">Sidekiq</a></b></td>
    <td>Job Scheduler and Async Tasks Executor. Can be used as a stand alone tool or as ActiveJob backend</td>
  </tr>
  <tr>
    <td><img width="100px" alt="whenever" src="Rails7StartKit/assets/images/whenever.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/scheduling">whenever</a></b></td>
    <td>Linux Cron based periodical tasks</td>
  </tr>
  <tr>
    <td colspan="3"><b>Full text search</b></td>
  </tr>
  <tr>
    <td><img width="100px" alt="elastic" src="Rails7StartKit/assets/images/elastic.png"></td>
    <td><b><a href="https://www.elastic.co">Elasticsearch</a></b></td>
    <td>The world’s leading Search engine</td>
  </tr>
  <tr>
    <td><img width="100px" alt="chewy" src="Rails7StartKit/assets/images/chewy.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/projects/chewy">Chewy</a></b></td>
    <td>Ruby Connector to Elasticsearch</td>
  </tr>
  <tr>
    <td colspan="3"><b>Front-end</b></td>
  </tr>
  <tr>
    <td><img width="100px" alt="import-maps" src="Rails7StartKit/assets/images/import-maps.png"></td>
    <td><b><a href="https://github.com/rails/importmap-rails">Import Maps</a></b></td>
    <td>Rails' recommended way to process JavaScript</td>
  </tr>
  <tr>
    <td colspan="3"><b>Application Level</b></td>
  </tr>
  <tr>
    <td><img width="100px" alt="gem config" src="Rails7StartKit/assets/images/config.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/projects/config">gem&nbsp;"config"</a></b></td>
    <td>Configuration management tool</td>
  </tr>
  <tr>
    <td><img width="100px" alt="faker" src="Rails7StartKit/assets/images/faker.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/random_data_generation">Faker</a></b></td>
    <td>Fake data for development and testing</td>
  </tr>
  <tr>
    <td><img width="100px" alt="sanitize" src="Rails7StartKit/assets/images/sanitize.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/projects/sanitize">Sanitize</a></b></td>
    <td>Sanitization of a dangerous users' input</td>
  </tr>
  <tr>
    <td><img width="100px" alt="kaminari" src="Rails7StartKit/assets/images/kaminari.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/pagination">Kaminari</a></b></td>
    <td>Pagination solution</td>
  </tr>
  <tr>
    <td><img width="100px" alt="letter_opener" src="Rails7StartKit/assets/images/mailcatcher.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/EMail_Fake_Servers">mailcatcher</a></b></td>
    <td>Email previewer for development</td>
  </tr>
  <tr>
    <td><img width="100px" alt="puma" src="Rails7StartKit/assets/images/puma.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/web_servers">Puma</a></b></td>
    <td>Application Web Server. To launch Rails app</td>
  </tr>
  <tr>
    <td colspan="3"><b>Code Quality</b></td>
  </tr>
  <tr>
    <td><img width="100px" alt="rspec" src="Rails7StartKit/assets/images/rubocop.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/code_metrics">Rubocop</a></b></td>
    <td>Ruby static code analyzer (a.k.a. linter) and formatter.</td>
  </tr>
  <tr>
    <td><img width="100px" alt="rspec" src="Rails7StartKit/assets/images/rspec.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/testing_frameworks">RSpec</a></b></td>
    <td>Testing Framework for Rails</td>
  </tr>
  <tr>
    <td><img width="100px" alt="devise" src="Rails7StartKit/assets/images/devise.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/rails_authentication">Devise</b></a></td>
    <td>Authentication solution for Rails + Emails confirmations</td>
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
    <td><img width="100px" alt="devise" src="Rails7StartKit/assets/images/devise.png"></td>
    <td><b><a href="https://www.ruby-toolbox.com/categories/rails_authentication">Devise</b></a></td>
    <td>Login with Facebook and Google</td>
  </tr>
  </tbody>
</table>

*All trademarks, logos and brand names are the property of their respective owners.*

## Installation and Running

<i>Copy & Paste in your terminal</i>

```sh
git clone https://github.com/the-teacher/rails7-startkit.git && \
  cd rails7-startkit && \
  bin/setup
```

**OR**

<details>
  <summary>Super short option</summary>

```sh
eval "$(curl -sSL rails-start.com)"
```

*Executing scripts from the Internet can be dangerous! Check the source before using!*
</details>

You will see something like that:

```
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rails 7. StartKit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
What was done:
1. Pull all required Images
2. Launching ElasticSearch Container
3. Launching Mailcatcher Container
4. Launching PgSQL Container
5. Launching Redis Container
6. Launching Rails Container
7. Installing Gems
8. Create DB. Migrate DB. Create Seeds
9. Indexing Article Model
10. Launching Rails App with Puma
11. Launching Sidekiq
12. Rubocop is Checking
13. RSpec is Checking
14. Visit Rails App: http://localhost:3000
15. Visit Mail Service: http://localhost:1080
16. Visit ElasticSearch: http://localhost:9200
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Welcome to RAILS 7!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

## `bin/` commands

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
      <td colspan="2">Most important</td>
    </tr>
    <tr>
      <td><b>bin/setup</b></td>
      <td>Download images, run containers, initialize data, launch all processes.</td>
    </tr>
    <tr>
      <td><b>bin/open</b></td>
      <td>Get in <b>Rails</b> Container</td>
    </tr>
    <tr>
      <td><b>bin/exec&nbsp;[COMMAND]</b></td>
      <td>Execute a command from <code>Rails7StartKit</code> module</td>
    </tr>
  </tbody>
</table>

## `bin/open` command

<table>
  <thead>
    <tr>
      <th>Command</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2">Get in a container</td>
    </tr>
    <tr>
      <td><b>bin/open&nbsp;[NAME]</b></td>
      <td>
        Get in a Container. <code>[NAME]</code> can be <code>rails</code>,
        <code>psql</code>, <code>redis</code>, <code>elastic</code>, <code>mailcatcher</code>. Default value is <code>rails</code>.
      </td>
    </tr>
  </tbody>
</table>

## `bin/exec` command

<table>
  <thead>
    <tr>
      <th>Command</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2">bin/exec</td>
    </tr>
    <tr>
      <td><b>bin/exec&nbsp;[COMMAND]</b></td>
      <td>Execute a command from <code>Rails7StartKit</code> module</td>
    </tr>
    <tr>
      <td colspan="2">Start/Stop/Restart</td>
    </tr>
    <tr>
      <td><b>bin/exec start</b></td>
      <td>Start processes in <b>rails</b> container</td>
    </tr>
    <tr>
      <td><b>bin/exec stop</b></td>
      <td>Stop processes in <b>rails</b> container</td>
    </tr>
    <tr>
      <td><b>bin/exec restart</b></td>
      <td><code>bin/exec&nbsp;stop</code> + <code>bin/exec&nbsp;start</code></td>
    </tr>
    <tr>
      <td><b>bin/exec&nbsp;start_all</b></td>
      <td>Start processes and containers</td>
    </tr>
    <tr>
      <td><b>bin/exec&nbsp;stop_all</b></td>
      <td>Stop processes and containers</td>
    </tr>
    <tr>
      <td><b>bin/exec restart_all</b></td>
      <td><code>bin/exec&nbsp;stop_all</code> + <code>bin/exec&nbsp;start_all</code></td>
    </tr>
    <tr>
      <td colspan="2">Helpers</td>
    </tr>
    <tr>
      <td><b>bin/exec status</b></td>
      <td>To see running containers and launched services</td>
    </tr>
    <tr>
      <td><b>bin/exec cache</b></td>
      <td>Toggle caching in development and restart web server</td>
    </tr>
    <tr>
      <td><b>bin/exec index</b></td>
      <td>Run Search engines indexation</td>
    </tr>
    <tr>
      <td><b>bin/exec reset</b></td>
      <td>Reset data of services in <b>./db</b> folder</td>
    </tr>
  </tbody>
</table>

### Prerequisites

On your host you have:

- Ruby 2+
- Docker
- Git

### Conventions and Agreements

<details>
  <summary>Show details</summary>

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
</details>

### Rails user

<details>
  <summary>Show Details</summary>

As a user to own files and run Rails inside a container I use

`user:group` => `lucky:lucky` => `7777:7777`

If you would like to run the project on a linux environment then:

- create group `lucky (7777)` and user `lucky (7777)`
- run the project with `RUN_AS=7777:7777` option
</details>

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

<details>
  <summary>Show details</summary>

- One command install and run
- Nginx
- Production roll up
- Action Cable [Link](https://guides.rubyonrails.org/action_cable_overview.html)
</details>

### License

MIT
