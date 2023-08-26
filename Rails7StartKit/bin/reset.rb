# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
module Rails7StartKit
  class << self
    def reset
      puts 'This command clean up ALL THE DATA for the project!'
      prompt!

      FileUtils.chdir APP_ROOT do
        FileUtils.rm_rf('db/PGSQL/', verbose: true)
        FileUtils.rm_rf('db/REDIS/', verbose: true)
        FileUtils.rm_rf('db/ELASTIC/', verbose: true)

        FileUtils.rm_rf('.yarn', verbose: true)
        FileUtils.rm_rf('node_modules', verbose: true)
        FileUtils.rm_rf('coverage', verbose: true)
        FileUtils.rm_rf('public/assets', verbose: true)
        FileUtils.rm_rf('app/assets/builds', verbose: true)

        # restore some

        FileUtils.mkdir_p('db/PGSQL/', verbose: true)
        FileUtils.mkdir_p('db/REDIS/', verbose: true)
        FileUtils.mkdir_p('db/ELASTIC/', verbose: true)
        FileUtils.mkdir_p('app/assets/builds', verbose: true)

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
