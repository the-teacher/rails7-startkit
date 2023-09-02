# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rspec
      command = 'RAILS_ENV=test rake db:prepare; rspec -f documentation'
      run_rails_command(command)
    end

    def rspec_with_cov
      command = 'RAILS_ENV=test rake db:prepare; COVERAGE=true rspec -f documentation'
      run_rails_command(command)
    end
  end
end
