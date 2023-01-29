# frozen_string_literal: true

def whenever_start
  container_exec('rails', 'bundle exec whenever --update-crontab --load-file config/_SCHEDULE.rb -i lucky')
end

def whenever_show
  container_exec('rails', 'crontab -l')
end

def whenever_stop
  container_exec('rails', 'crontab -r')
end
