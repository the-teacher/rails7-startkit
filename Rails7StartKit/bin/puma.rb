# frozen_string_literal: true

module Rails7StartKit
  class << self
    def puma_start_command
      'bundle exec puma -C config/_PUMA.rb'
    end

    # rubocop:disable Lint/UselessAssignment
    def puma_dev_start
      puts 'Launching PUMA (single mode)'
      command = 'PUMA_WORKERS=0 bundle exec puma -C config/_PUMA.rb & '
      run_rails_command(command, detached = true)
    end

    def puma_start
      puts 'Launching PUMA'
      command = 'bundle exec puma -C config/_PUMA.rb'
      run_rails_command(command, detached = true)
    end

    def puma_stop
      puts 'Stopping PUMA'
      command = 'pkill -f puma'
      run_rails_command(command)
    end
    # rubocop:enable Lint/UselessAssignment

    def puma_restart
      puma_stop
      puma_start
    end
  end
end
