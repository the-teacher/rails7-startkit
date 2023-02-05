# frozen_string_literal: true

# rubocop:disable Style/GlobalVars
module Rails7StartKit
  class << self
    def prompt!(message = 'Are you sure to continue? [y/Y]')
      puts message
      prompt = $stdin.gets.chomp

      return if prompt.downcase == 'y'

      puts 'Bye! See you next time!'
      exit 1
    end

    def rails7_header
      puts '~' * 80
      puts 'Rails 7. StartKit'
      puts '~' * 80
    end

    def rails7_startkit_greetings!
      rails7_header
      puts 'We are going to setup and run Rails 7 application'
      puts 'Relax and wait for some minutes'
      puts '~' * 80
    end

    def rails7_ready
      rails7_header
      puts 'What was done:'
      puts $steps_messages.join("\n")
      puts '~' * 80
      puts 'Welcome to RAILS 7!'
      puts '~' * 80
    end

    def inside_rails_conainer?
      if system('docker -v')
        puts 'Docker is found. Looks like you are on the HOST machine'
        false
      else
        puts 'Docker is not found. Looks like you are in the container'
        true
      end
    end

    def system!(*args)
      system(*args) || abort("\n== Command #{args} failed ==")
    end

    def macos?
      !!`echo $OSTYPE`.match('darwin')
    end

    def msos?
      !!`echo $OSTYPE`.match('msys')
    end

    def ms_warning
      msos? ? nil : return

      puts '!' * 80
      puts 'Looks like you use MS Windows'
      puts 'Rails 7. StartKit - uses fallback to Linux Platform'
      puts '!' * 80

      sleep(3)
    end

    def platform_env
      macos? ? 'PLATFORM=arm64' : 'PLATFORM=amd64'
    end

    def container_exec(container_name = 'rails', cmd = 'ls')
      docker_compose("exec #{ENV['TTY_OFF']} -e='RAILS_ENV=#{ENV_NAME}' #{container_name} #{cmd}")
    end

    # rubocop:disable Style/OptionalBooleanParameter
    def container_bash_exec(container_name = 'rails', cmd = 'ls', detached = false)
      detached = detached ? '-d' : ''
      docker_compose("exec #{ENV['TTY_OFF']} #{detached} #{container_name} /bin/bash -c '#{cmd}'")
    end
    # rubocop:enable Style/OptionalBooleanParameter

    def containers_information
      puts
      puts '~' * 80
      system("docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.ID}}'")
      puts '~' * 80
      puts
    end

    # TODO: update with --remove-orphans

    def start_all_containers
      docker_compose('up -d')
    end

    def stop_all_containers
      docker_compose('down')
    end
  end
end
# rubocop:enable Style/GlobalVars
