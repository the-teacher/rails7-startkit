# frozen_string_literal: true

workers 1
threads 2, 4

env_name = ENV.fetch('RAILS_ENV', 'development')
environment env_name

if env_name == 'development'
  bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"
else
  bind 'unix:///home/lucky/app/tmp/sockets/puma.sock'
end

pidfile    '/home/lucky/app/tmp/pids/puma.pid'
state_path '/home/lucky/app/tmp/pids/puma.state'

stdout_redirect \
  '/home/lucky/app/log/puma.log',
  '/home/lucky/app/log/puma.errors.log',
  true

activate_control_app

on_worker_boot do
  require 'active_record'
  begin
    ActiveRecord::Base.connection.disconnect!
  rescue StandardError
    ActiveRecord::ConnectionNotEstablished
  end
  ActiveRecord::Base.establish_connection(YAML.load_file('/home/lucky/app/config/database.yml')['production'])
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
