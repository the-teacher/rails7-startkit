# frozen_string_literal: true

workers_count = ENV.fetch('PUMA_WORKERS', 0).to_i
env_name = ENV.fetch('RAILS_ENV', 'development')

workers workers_count
threads 2, 4

environment env_name

# unless env_name == 'development'
#   bind 'unix:///home/lucky/app/tmp/sockets/puma.sock'
# end

bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

pidfile    '/home/lucky/app/tmp/pids/puma.pid'
state_path '/home/lucky/app/tmp/pids/puma.state'

# unless workers_count.zero?
stdout_redirect \
  '/home/lucky/app/log/puma.log',
  '/home/lucky/app/log/puma.errors.log',
  true
# end

activate_control_app

on_worker_boot do
  require 'active_record'
  begin
    ActiveRecord::Base.connection.disconnect!
  rescue StandardError
    ActiveRecord::ConnectionNotEstablished
  end
  ActiveRecord::Base.establish_connection(YAML.load_file('/home/lucky/app/config/database.yml')[env_name])
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
