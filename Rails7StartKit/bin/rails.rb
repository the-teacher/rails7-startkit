# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rails_install_gems
      step_info 'Install Gems'
      container_bash_exec('rails', 'bundle install')
    end

    def rails_db_migrate
      step_info 'DB Migrate'
      container_bash_exec('rails', 'rake db:migrate')
    end

    def rails_assets_precompile
      step_info 'Precompile Assets'
      container_bash_exec('rails', 'rake assets:precompile')
    end

    def rails_db_prepare
      step_info 'Create DB. Migrate DB. Create Seeds'
      container_bash_exec('rails', 'rake db:prepare')
    end
  end
end
