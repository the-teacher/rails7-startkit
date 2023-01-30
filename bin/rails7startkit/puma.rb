# frozen_string_literal: true

module Rails7StartKit
  class << self
    def puma_start
      puts 'Launching PUMA'
      container_bash_exec('rails', puma_start_command, detached = true)
    end

    def puma_stop
      puts 'Stopping PUMA'
      container_bash_exec('rails', puma_stop_command)
    end

    def puma_restart
      puma_stop
      puma_start
    end
  end
end
