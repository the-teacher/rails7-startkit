# frozen_string_literal: true

app = Rails.application

settings_file = "#{app.config.root}/config/_CONFIG.yml"
Settings.add_source!(settings_file)
puts "Settings: #{settings_file}"

Settings.reload!
