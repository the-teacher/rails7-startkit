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
  puts "Touch file: #{file_path}. You do not have an access."
end

def remove_file(file_path)
  FileUtils.rm_rf(file_path, verbose: true)
rescue Errno::EACCES
  puts "Remove file: #{file_path}. You do not have an access."
end

def make_dir(dir_path)
  FileUtils.mkdir_p(dir_path, verbose: true)
rescue Errno::EACCES
  puts "Make Directory: #{dir_path}. You do not have an access."
end
