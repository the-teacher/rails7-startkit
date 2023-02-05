# frozen_string_literal: true

module Rails7StartKit
  class << self
    def whenever_start
      container_exec('rails', 'bundle exec whenever --update-crontab --load-file config/_SCHEDULE.rb -i lucky')
    end

    def whenever_show
      container_exec('rails', 'crontab -l')
    end

    def whenever_stop
      container_exec('rails', 'crontab -r')
    end
  end
end
