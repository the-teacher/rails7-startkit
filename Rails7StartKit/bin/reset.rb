# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
module Rails7StartKit
  class << self
    def reset
      puts 'This command clean up ALL THE DATA for the project!'
      prompt!

      FileUtils.chdir APP_ROOT do
        remove_file('db/PGSQL/')
        remove_file('db/REDIS/')
        remove_file('db/ELASTIC/')

        remove_file('.yarn')
        remove_file('node_modules')
        remove_file('coverage')
        remove_file('public/assets')
        remove_file('app/assets/builds')

        # restore some

        make_dir('db/PGSQL/')
        make_dir('db/REDIS/')
        make_dir('db/ELASTIC/')
        make_dir('app/assets/builds')

        touch_file('db/PGSQL/.keep')
        touch_file('db/REDIS/.keep')
        touch_file('db/ELASTIC/.keep')
        touch_file('app/assets/builds/.keep')
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
