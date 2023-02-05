# frozen_string_literal: true

module Rails7StartKit
  class << self
    # rubocop:disable Lint/UselessAssignment
    def sidekiq_start
      puts 'Launching SIDEKIQ'
      container_bash_exec('rails', 'bundle exec sidekiq -C config/_SIDEKIQ.yml', detached = true)
    end
    # rubocop:enable Lint/UselessAssignment

    def sidekiq_stop
      puts 'Stopping SIDEKIQ'
      container_bash_exec('rails', 'pkill -f sidekiq')
    end
  end
end
