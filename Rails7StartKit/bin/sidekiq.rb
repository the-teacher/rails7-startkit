# frozen_string_literal: true

module Rails7StartKit
  class << self
    def sidekiq_start
      puts 'Launching SIDEKIQ'
      container_bash_exec('rails', 'bundle exec sidekiq -C config/_SIDEKIQ.yml', detached = true)
    end

    def sidekiq_stop
      puts 'Stopping SIDEKIQ'
      container_bash_exec('rails', 'pkill -f sidekiq')
    end
  end
end
