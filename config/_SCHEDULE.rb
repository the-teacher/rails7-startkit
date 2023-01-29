# frozen_string_literal: true

# Learn more: http://github.com/javan/whenever
#
# How to initialize whenever
# `bundle exec wheneverize .`
#
# How to start cron service
# as ROOT: /etc/init.d/cron start
#
# How to start whenever
# whenever --update-crontab --load-file config/_SCHEDULE.rb -i lucky
#
# How to see current crontab
# crontab -l

env :GEM_HOME, ENV['GEM_HOME']
set :environment, ENV.fetch('RAILS_ENV', 'development')

set :output, {
  standard: '/home/lucky/app/log/cron.log',
  error: '/home/lucky/app/log/cron.error.log'
}

job_type :rails, 'cd :path && :environment_variable=:environment bundle exec rails :task :output'

every 1.minute do
  rails "runner \"CurrencyRate.get('USD', 'EUR')\""
end
