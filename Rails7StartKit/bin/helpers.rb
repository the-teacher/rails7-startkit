# frozen_string_literal: true

DELAY = 3

# rubocop:disable Style/GlobalVars
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

# rubocop:enable Style/GlobalVars
