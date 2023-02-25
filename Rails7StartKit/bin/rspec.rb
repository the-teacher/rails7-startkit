# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rspec
      container_bash_exec('rails', 'RAILS_ENV=test rake db:prepare')
      container_bash_exec('rails', 'rspec -f documentation')
    end

    def rspec_with_cov
      container_bash_exec('rails', 'RAILS_ENV=test rake db:prepare')
      container_bash_exec('rails', 'COVERAGE=true rspec -f documentation')
    end
  end
end
