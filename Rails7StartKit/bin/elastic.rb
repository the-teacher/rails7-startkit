# frozen_string_literal: true

module Rails7StartKit
  class << self
    # rubocop:disable Layout/LineLength
    def turn_off_elastic_settings
      cmd1 = `curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_cluster/settings -d '{ "transient": { "cluster.routing.allocation.disk.threshold_enabled": false } }'`
      cmd2 = `curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_all/_settings -d '{"index.blocks.read_only_allow_delete": null}'`
      puts cmd1
      puts cmd2
    end
    # rubocop:enable Layout/LineLength
  end
end
