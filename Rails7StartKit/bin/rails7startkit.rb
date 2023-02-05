# frozen_string_literal: true

require 'fileutils'
require_relative './helpers'

require_relative './common'
require_relative './docker'
require_relative './chewy'
require_relative './sidekiq'
require_relative './cron'
require_relative './whenever'
require_relative './rails'
require_relative './puma'
require_relative './rubocop'
require_relative './elastic'

# path to your application root
APP_ROOT = File.expand_path('../..', __dir__)

# `exist?` is defined in new ruby. Monkey patch for old versions
if File.methods.include?(:exists?) && !File.methods.include?(:exist?)
  class File
    def self.exist?(file_name)
      exists? file_name
    end
  end
end

# rubocop:disable Metrics/ModuleLength, Metrics/MethodLength
# rubocop:disable Metrics/BlockLength, Metrics/AbcSize
module Rails7StartKit
  class << self
    def start
      rails_install_gems
      rails_db_migrate

      cron_start
      chewy_index

      sidekiq_start
      puma_start
    end

    def start_all
      start_all_containers
      system('bin/exec start')
      containers_information
    end

    def stop
      puma_stop
      cron_stop
      sidekiq_stop
    end

    def stop_all
      stop_all_containers
      containers_information
    end

    def restart
      system('bin/exec stop')
      system('bin/exec start')
    end

    def restart_all
      system('bin/exec stop_all')
      system('bin/exec start_all')
    end

    def status
      containers_information

      container_bash_exec('rails', 'ps a | grep puma')
      container_bash_exec('rails', 'ps a | grep sidekiq')
    end

    def index
      start_all_containers

      rails_install_gems
      rails_db_migrate

      chewy_index
    end

    def reset
      puts 'This command clean up ALL THE DATA for the project!'
      prompt!

      FileUtils.chdir APP_ROOT do
        FileUtils.rm_rf('db/PGSQL/', verbose: true)
        FileUtils.rm_rf('db/REDIS/', verbose: true)
        FileUtils.rm_rf('db/ELASTIC/', verbose: true)

        FileUtils.mkdir_p('db/PGSQL/', verbose: true)
        FileUtils.mkdir_p('db/REDIS/', verbose: true)
        FileUtils.mkdir_p('db/ELASTIC/', verbose: true)

        FileUtils.touch('db/PGSQL/.keep', verbose: true)
        FileUtils.touch('db/REDIS/.keep', verbose: true)
        FileUtils.touch('db/ELASTIC/.keep', verbose: true)
      end
    end

    def cache
      puts 'Toggle App Cache in development mode'
      cache_toggle_file = 'tmp/caching-dev.txt'

      FileUtils.chdir APP_ROOT do
        if File.exist?(cache_toggle_file)
          puts "File '#{cache_toggle_file}' exists"
          FileUtils.rm_rf(cache_toggle_file, verbose: true)
          puts "File '#{cache_toggle_file}' is removed"
          puts 'Cache is OFF'
        else
          puts "File '#{cache_toggle_file}' does not exist"
          FileUtils.touch(cache_toggle_file, verbose: true)
          puts "File '#{cache_toggle_file}' is created"
          puts 'Cache is ON'
        end
      end

      # Not sure if for windows it will work.
      # https://stackoverflow.com/questions/11982057/how-can-i-trigger-a-shell-script-and-run-in-background-async-in-ruby
      #
      puts 'Restarting PUMA server'
      if inside_rails_conainer?
        system(@puma_stop_command)
        system("#{puma_start_command} & ")
      else
        puma_restart
      end
    end

    def setup!
      FileUtils.chdir APP_ROOT do
        ms_warning
        check_docker!
        check_docker_compose_v2!
        rails7_startkit_greetings!

        step_info 'Pull all required Images'
        docker_compose('pull')

        # ElasticSearch
        step_info 'Launching ElasticSearch Container'
        docker_compose('up elastic -d')
        wait('to launch ElasticSearch Container')

        # Mailcatcher
        step_info 'Launching Mailcatcher Container'
        docker_compose('up mailcatcher -d')
        wait('to launch Mailcatcher Container')

        # PgSQL
        FileUtils.rm('db/PGSQL/.keep', force: true)
        step_info 'Launching PgSQL Container'
        docker_compose('up psql -d')
        wait('to initialize PgSQL database')
        FileUtils.touch('db/PGSQL/.keep', verbose: true)

        # Redis
        step_info 'Launching Redis Container'
        docker_compose('up redis -d')
        wait('to launch Redis Container')

        # Rails
        step_info 'Launching Rails Container'
        docker_compose('up rails -d')
        wait('to launch Rails Container')

        step_info 'Installing Gems'
        rails_install_gems

        step_info 'Turn off some ElasticSearch settings'
        turn_off_elastic_settings

        step_info 'Create DB. Migrate DB. Create Seeds'
        container_bash_exec('rails', 'rake db:prepare')

        step_info 'Indexing Article Model'
        chewy_index

        step_info 'Launching Rails App with Puma'
        puma_start

        step_info 'Launching Sidekiq'
        sidekiq_start

        step_info 'Rubocop is Checking'
        rubocop

        step_info 'RSpec is Checking'
        rspec

        step_info 'Visit Rails App: http://localhost:3000'
        step_info 'Visit Mail Service: http://localhost:1080'
        step_info 'Visit ElasticSearch: http://localhost:9200'

        containers_information

        rails7_ready
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength, Metrics/AbcSize
# rubocop:enable Metrics/ModuleLength, Metrics/MethodLength
