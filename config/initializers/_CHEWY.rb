# frozen_string_literal: true

elastic_host = Settings.elastic.host
elastic_port = Settings.elastic.port

elastic_address = "#{elastic_host}:#{elastic_port}"
puts "ElasticSearch and Chewy service address: #{elastic_address}"

Chewy.settings = {
  host: elastic_address
}
