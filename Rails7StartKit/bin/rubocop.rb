# frozen_string_literal: true

module Rails7StartKit
  class << self
    def rubocop
      container_bash_exec('rails', 'rubocop --require rubocop-rails')
    end

    def rubocop_fix
      container_bash_exec('rails', 'rubocop --require rubocop-rails -A')
    end
  end
end
