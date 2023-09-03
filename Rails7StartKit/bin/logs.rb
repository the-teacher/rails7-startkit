# frozen_string_literal: true

module Rails7StartKit
  class << self
    def log_server
      command = "tail -n 50 -f log/#{rails_env_name}.log"
      run_rails_command(command)
    end

    def log_puma
      command = "tail -n 50 -f log/puma.log log/puma.errors.log"
      run_rails_command(command)
    end

    def log_sidekiq
      command = "tail -n 50 -f log/sidekiq.errors.log"
      run_rails_command(command)
    end
  end
end
