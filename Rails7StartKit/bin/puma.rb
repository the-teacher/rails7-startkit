# frozen_string_literal: true

module Rails7StartKit
  class << self
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

    # Do not use: `pkill -f puma`
    # It matches the running script name and kills it also :)
    def puma_stop
      if inside_rails_conainer?
        puts 'Stopping PUMA'
        pids = `pgrep -f puma`.split("\n")
        pids.delete(Process.pid.to_s)
        pids.each { |pid| system "kill -9 #{pid}" }
      else
        run_rails_command('pkill -f puma')
      end
    end
    # rubocop:enable Lint/UselessAssignment

    def puma_restart
      puma_stop
      puma_start
    end
  end
end
