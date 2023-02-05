# frozen_string_literal: true

module Rails7StartKit
  class << self
    def chewy_index
      puts 'Indexing with CHEWY'
      container_exec('rails', 'rake chewy:update')
    end

    def chewy_reset
      puts 'Dropping CHEWY indicies'
      container_exec('rails', 'rake chewy:reset')
    end
  end
end
