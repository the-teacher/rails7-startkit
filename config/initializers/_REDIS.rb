# frozen_string_literal: true

redis_port = Settings.redis.port
redis_host = Settings.redis.host

$redis = Redis.new(host: redis_host, port: redis_port)
puts "Redis service address: redis://#{redis_host}:#{redis_port}"
