DELAY = 3
ENV_NAME = ENV.fetch("RAILS_ENV") { 'development' }

$steps_counter = 1
$steps_messages = []

@puma_start_command = 'bundle exec puma -C config/_PUMA.rb'
@puma_stop_command  = 'pkill -f puma'

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
  to_exec = "docker compose -f docker/docker-compose.yml exec -e='RAILS_ENV=#{ENV_NAME}' #{container_name} #{cmd}"
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

def inside_rails_conainer?
  if system('docker -v')
    puts "Docker is found. Looks like you are on the HOST machine"
    return false
  else
    puts "Docker is not found. Looks like you are in the container"
    return true
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
  container_bash_exec('rails', @puma_start_command, detached = true)
end

def puma_stop
  puts "Stopping PUMA"
  container_bash_exec('rails', @puma_stop_command)
end

def puma_restart
  puma_stop
  puma_start
end

def sidekiq_start
  puts "Launching SIDEKIQ"
  container_bash_exec('rails', 'bundle exec sidekiq -C config/_SIDEKIQ.yml', detached = true)
end

def sidekiq_stop
  puts "Stopping SIDEKIQ"
  container_bash_exec('rails', 'pkill -f sidekiq')
end

def cron_start
  container_exec('--user root rails', '/etc/init.d/cron start')
end

def cron_stop
  container_exec('--user root rails', '/etc/init.d/cron stop')
end

def whenever_start
  container_exec('rails', "bundle exec whenever --update-crontab --load-file config/_SCHEDULE.rb -i lucky")
end

def whenever_show
  container_exec('rails', 'crontab -l')
end

def whenever_stop
  container_exec('rails', 'crontab -r')
end
