# frozen_string_literal: true

module Rails7StartKit
  class << self
    def start
      rails_install_gems
      rails_db_migrate

      container_bash_exec('rails', 'rake assets:precompile') if production?

      cron_start
      chewy_index

      sidekiq_start
      puma_start
    end

    def start_all
      start_all_containers
      system('bin/exec start')
      containers_information
    end

    def stop
      puma_stop
      cron_stop
      sidekiq_stop
    end

    def stop_all
      stop_all_containers
      containers_information
    end

    def restart
      system('bin/exec stop')
      system('bin/exec start')
    end

    def restart_all
      system('bin/exec stop_all')
      system('bin/exec start_all')
    end
  end
end
