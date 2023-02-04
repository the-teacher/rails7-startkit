# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rspec
      container_bash_exec('rails', 'rspec -f documentation')
    end
  end
end
