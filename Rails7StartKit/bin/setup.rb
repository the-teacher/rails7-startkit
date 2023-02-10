# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/BlockLength
module Rails7StartKit
  class << self
    def setup!
      FileUtils.chdir APP_ROOT do
        ms_warning

        check_docker!
        check_docker_running!
        check_docker_compose_v2!

        rails7_startkit_greetings!

        step_info 'Pull all required Images'
        docker_compose('pull')

        # ElasticSearch
        step_info 'Launching ElasticSearch Container'
        docker_compose('up elastic -d')
        wait('to launch ElasticSearch Container')

        # Mailcatcher
        step_info 'Launching Mailcatcher Container'
        docker_compose('up mailcatcher -d')
        wait('to launch Mailcatcher Container')

        # PgSQL
        FileUtils.rm('db/PGSQL/.keep', force: true)
        step_info 'Launching PgSQL Container'
        docker_compose('up psql -d')
        wait('to initialize PgSQL database')
        FileUtils.touch('db/PGSQL/.keep', verbose: true)

        # Redis
        step_info 'Launching Redis Container'
        docker_compose('up redis -d')
        wait('to launch Redis Container')

        # Rails
        step_info 'Launching Rails Container'
        docker_compose('up rails -d')
        wait('to launch Rails Container')

        step_info 'Installing Gems'
        rails_install_gems

        step_info 'Turn off some ElasticSearch settings'
        turn_off_elastic_settings

        step_info 'Create DB. Migrate DB. Create Seeds'
        container_bash_exec('rails', 'rake db:prepare')

        step_info 'Indexing Article Model'
        chewy_index

        step_info 'Launching Rails App with Puma'
        puma_start

        step_info 'Launching Sidekiq'
        sidekiq_start

        step_info 'Rubocop is Checking'
        rubocop

        step_info 'RSpec is Checking'
        rspec

        step_info 'Visit Rails App: http://localhost:3000'
        step_info 'Visit Mail Service: http://localhost:1080'
        step_info 'Visit ElasticSearch: http://localhost:9200'

        containers_information

        rails7_ready
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/BlockLength
