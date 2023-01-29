# frozen_string_literal: true

# bundle exec sidekiq -C config/sidekiq.yml

redis_port = Settings.redis.port
redis_host = Settings.redis.host

redis_url = "redis://#{redis_host}:#{redis_port}"
puts "Sidekiq service address: #{redis_url}"

SQ_ERR_LOGGER = Logger.new(
  Rails.root.join('log/sidekiq.errors.log')
)

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url
  }
end

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url
  }

  config.error_handlers << proc do |ex, context|
    SQ_ERR_LOGGER.error "#{ex}\n#{context}\n\n"
  end
end
