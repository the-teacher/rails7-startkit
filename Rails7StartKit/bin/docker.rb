# frozen_string_literal: true

module Rails7StartKit
  class << self
    def check_docker!
      return if system('docker -v')

      rails7_header
      puts 'Docker not found'
      puts '~' * 80
      exit 1
    end

    # rubocop:disable Metrics/MethodLength
    def check_docker_compose_v2!
      output = `docker compose version`
      if output.match(/Docker Compose version v2/)
        puts 'Docker Compose v2 - found!'
      else
        rails7_header
        puts 'Docker Compose v2 not found'
        puts 'Please Upgrade to Docker Compose v2'
        puts 'More info: https://docs.docker.com/compose/compose-v2'
        puts '~' * 80
        exit 1
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
