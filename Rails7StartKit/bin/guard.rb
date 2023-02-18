# frozen_string_literal: true

module Rails7StartKit
  class << self
    def guard_start
      puts 'Launching GUARD'
      container_bash_exec('rails', 'bundle exec guard')
    end

    def guard_stop
      puts 'Stopping GUARD'
      container_bash_exec('rails', 'pkill -f guard')
    end
  end
end
