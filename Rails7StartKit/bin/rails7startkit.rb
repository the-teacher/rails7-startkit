# frozen_string_literal: true

require 'fileutils'
require_relative './environment'
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
require_relative './start_stop'
require_relative './setup'

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

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
module Rails7StartKit
  class << self
    def status
      containers_information

      container_bash_exec('rails', 'ps a | grep puma')
      container_bash_exec('rails', 'ps a | grep sidekiq')
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

    # def get_secret_key
    #   container_bash_exec('rails', 'rake secret > tail')
    #   container_bash_exec('rails', 'printenv SECRET_KEY_BASE')
    # end

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
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
