# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rubocop
      command = 'rubocop --require rubocop-rails'
      run_rails_command(command)
    end

    def rubocop_fix
      command = 'rubocop --require rubocop-rails -A'
      run_rails_command(command)
    end
  end
end
