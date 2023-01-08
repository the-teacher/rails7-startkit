DELAY = 3

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

def container_exec(container_name = 'rails', cmd = 'ls')
  to_exec = "docker compose -f docker/docker-compose.yml exec #{container_name} #{cmd}"
  puts to_exec
  system(to_exec)
end

def container_bash_exec(container_name = 'rails', cmd = 'ls', detached = false)
  detached = detached ? '-d' : ''
  to_exec = "docker compose -f docker/docker-compose.yml exec #{detached} #{container_name} /bin/bash -c '#{cmd}'"
  puts to_exec
  system(to_exec)
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

def containers_information
  puts "\n" + ("~" * 50) + "\n"
  system("docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.ID}}'")
  puts ("~" * 50) + "\n"
end
