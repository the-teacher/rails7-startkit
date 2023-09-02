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

def inside_rails_conainer?
  if system('docker -v')
    puts 'Docker is found. Looks like you are on the HOST machine'
    false
  else
    puts 'Docker is not found. Looks like you are in the container'
    true
  end
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

# rubocop:disable Style/OptionalBooleanParameter
def run_rails_command(command, detached = false)
  if inside_rails_conainer?
    system(command)
  else
    container_bash_exec('rails', command, detached)
  end
end

def run_rails_root_command(command, detached = false)
  if inside_rails_conainer?
    puts 'Not vavilable inside the rails container'
  else
    container_bash_exec('rails', command, detached, true)
  end
end
# rubocop:enable Style/OptionalBooleanParameter

# rubocop:disable Metrics/MethodLength
def set_lucky_permissions
  [
    'chown 7777:7777 Gemfile.lock',
    'chown 7777:7777 package-lock.json',

    'mkdir .yarn',
    'chown -R 7777:7777 .yarn',

    'mkdir node_modules',
    'chown -R 7777:7777 node_modules',

    'mkdir log',
    'chown -R 7777:7777 log',

    'mkdir coverage',
    'chown -R 7777:7777 coverage'
  ].each do |command|
    run_rails_root_command(command)
  end
end
# rubocop:enable Metrics/MethodLength
