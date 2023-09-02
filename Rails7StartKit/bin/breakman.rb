# frozen_string_literal: true

module Rails7StartKit
  class << self
    def breakman
      command = 'brakeman --color --no-pager --skip-files Rails7StartKit/'
      run_rails_command(command)
    end
  end
end
