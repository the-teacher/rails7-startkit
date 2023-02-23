# frozen_string_literal: true

def rails_env_name
  ENV.fetch('RAILS_ENV', 'development')
end

def production?
  rails_env_name == 'production'
end

def development?
  rails_env_name == 'development'
end

def test?
  rails_env_name == 'test'
end
