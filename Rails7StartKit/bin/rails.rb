# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rails_install_gems
      container_bash_exec('rails', 'bundle install')
    end

    def rails_db_migrate
      container_bash_exec('rails', 'rake db:migrate')
    end

    def rails_assets_precompile
      container_bash_exec('rails', 'rake assets:precompile')
    end

    def rails_db_prepare
      container_bash_exec('rails', 'rake db:prepare')
    end
  end
end
