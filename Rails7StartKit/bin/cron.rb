# frozen_string_literal: true

module Rails7StartKit
  class << self
    def cron_start
      container_exec('--user root rails', '/etc/init.d/cron start')
    end

    def cron_stop
      container_exec('--user root rails', '/etc/init.d/cron stop')
    end
  end
end
