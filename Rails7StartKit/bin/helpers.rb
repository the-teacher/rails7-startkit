# frozen_string_literal: true

require 'fileutils'

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

def touch_file(file_path)
  FileUtils.touch(file_path, verbose: true)
rescue Errno::EACCES
  puts "Ooops! You do not have an access to the file: #{file_path}"
end
