# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rails_install_gems
      puts 'Install Gems'
      container_bash_exec('rails', 'bundle install')
    end

    def rails_db_migrate
      puts 'DB Migrate'
      container_bash_exec('rails', 'rake db:migrate')
    end
  end
end
