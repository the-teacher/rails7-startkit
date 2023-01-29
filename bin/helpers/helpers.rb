require_relative './common'
require_relative './docker'
require_relative './chewy'
require_relative './sidekiq'
require_relative './cron'
require_relative './whenever'
require_relative './rails'
require_relative './puma'

DELAY = 3
ENV_NAME = ENV.fetch('RAILS_ENV') { 'development' }

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
