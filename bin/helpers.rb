DELAY = 3

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

def container_exec(container_name = 'rails', cmd = 'ls')
  system("docker compose -f docker/docker-compose.yml exec #{container_name} #{cmd}")
end

def container_bash_exec(container_name = 'rails', cmd = 'ls')
  system("docker compose -f docker/docker-compose.yml exec #{container_name} /bin/bash -c '#{cmd}'")
end

def check_docker!
  unless system('docker -v')
    puts "Docker not found"
    exit 1
  end
end

def prompt!(message = "Are you sure to continue? [y/Y]")
  puts message
  prompt = STDIN.gets.chomp

  unless prompt.downcase == 'y'
    puts "Buy! See you next time!"
    exit 1
  end
end

def wait(details)
  puts "Waiting #{DELAY} seconds #{details}"
  sleep(DELAY)
end
