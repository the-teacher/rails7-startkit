# frozen_string_literal: true

module Rails7StartKit
  class << self
    def check_docker!
      if system('docker -v')
        puts '=> Docker found'
      else
        rails7_header
        puts '=> Docker not found'
        puts 'To continue please install Docker'
        puts 'More info: https://docs.docker.com/get-docker'
        puts '~' * 80
        exit 1
      end
    end

    def check_docker_running!
      output = `docker ps`
      if output.match(/CONTAINER ID/)
        puts '=> Docker is running'
      else
        rails7_header
        puts '=> Docker not running'
        puts 'To continue please run Docker'
        puts '~' * 80
        exit 1
      end
    end

    # rubocop:disable Metrics/MethodLength
    def check_docker_compose_v2!
      output = `docker compose version`
      if output.match(/Docker Compose version v2/)
        puts '=> Docker Compose v2 - found!'
      else
        rails7_header
        puts '=> Docker Compose v2 not found'
        puts 'To continue please install or upgrade Docker Compose v2'
        puts 'More info: https://docs.docker.com/compose/compose-v2'
        puts '~' * 80
        exit 1
      end
    end
    # rubocop:enable Metrics/MethodLength

    def docker_compose(cmd)
      to_exec = "#{platform_env} docker compose -f Rails7StartKit/docker/docker-compose.yml #{cmd}"
      puts to_exec
      system(to_exec)
    end
  end
end
