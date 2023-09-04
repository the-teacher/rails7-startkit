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

def step_info_new_line
  $steps_messages << ''
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
def set_permissions_for_elastic
  [
    'mkdir -p db/ELASTIC',
    'mkdir -p log/ELASTIC',

    'chmod 777 db/ELASTIC',
    'chmod 777 log/ELASTIC'
  ].each do |command|
    run_rails_root_command(command)
  end
end

def set_lucky_permissions
  command = [
    'chown 7777:7777 Gemfile.lock',
    'chown 7777:7777 package-lock.json',
    'chown 7777:7777 db/schema.rb',

    'mkdir -p .yarn',
    'chown -R 7777:7777 .yarn',

    'mkdir -p node_modules',
    'chown -R 7777:7777 node_modules',

    'mkdir -p log',
    'chown -R 7777:7777 log',

    'mkdir -p coverage',
    'chown -R 7777:7777 coverage',

    'mkdir -p tmp',
    'chown -R 7777:7777 tmp',

    'mkdir -p app/assets/builds',
    'chown -R 7777:7777 app/assets/builds',

    'mkdir -p app/assets/builds/esbuild',
    'chown -R 7777:7777 app/assets/builds/esbuild',

    'mkdir -p app/assets/builds/sass',
    'chown -R 7777:7777 app/assets/builds/sass'
  ].join(' ; ')

  run_rails_root_command(command)
end
# rubocop:enable Metrics/MethodLength
