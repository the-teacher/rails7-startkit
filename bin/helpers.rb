DELAY = 3

$steps_counter = 1
$steps_messages = []

def wait(details, delay = DELAY)
  puts "Waiting #{delay} seconds #{details}"
  sleep(delay)
end

def step_info(message)
  info_message = "#{$steps_counter}. #{message}"
  puts info_message
  $steps_counter = $steps_counter.next
  $steps_messages << info_message
end

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
    puts "Bye! See you next time!"
    exit 1
  end
end

def containers_information
  puts "\n" + ("~" * 50) + "\n"
  system("docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.ID}}'")
  puts ("~" * 50) + "\n"
end

# todo: update with --remove-orphans

def start_all_containers
  system('docker compose -f docker/docker-compose.yml up -d')
end

def stop_all_containers
  system('docker compose -f docker/docker-compose.yml down')
end

def rails_install_gems
  puts "Install Gems"
  container_bash_exec('rails', 'bundle install')
end

def rails_db_migrate
  puts "DB Migrate"
  container_bash_exec('rails', 'rake db:migrate')
end

def chewy_index
  puts "Indexing with CHEWY"
  container_exec('rails', 'rake chewy:update')
end

def chewy_index
  puts "Indexing with CHEWY"
  container_exec('rails', 'rake chewy:update')
end

def chewy_reset
  puts "Dropping CHEWY indicies"
  container_exec('rails', 'rake chewy:reset')
end

def puma_start
  puts "Launching PUMA"
  container_bash_exec('rails', 'bundle exec puma -C config/_PUMA.rb', detached = true)
end

def puma_stop
  puts "Stopping PUMA"
  container_bash_exec('rails', 'pkill -f puma')
end

def sidekiq_start
  puts "Launching SIDEKIQ"
  container_bash_exec('rails', 'bundle exec sidekiq -C config/_SIDEKIQ.yml', detached = true)
end

def sidekiq_stop
  puts "Stopping SIDEKIQ"
  container_bash_exec('rails', 'pkill -f sidekiq')
end
