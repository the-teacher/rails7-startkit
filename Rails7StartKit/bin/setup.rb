# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/BlockLength
module Rails7StartKit
  class << self
    def setup!
      FileUtils.chdir APP_ROOT do
        check_docker!
        check_docker_running!
        check_docker_compose_v2!

        rails7_startkit_greetings!

        step_info 'Pull all required Images'
        docker_compose('pull')
        step_info_new_line

        # Mailcatcher
        if development?
          step_info 'Launching Mailcatcher Container'
          docker_compose('up mailcatcher -d')
          wait('to launch Mailcatcher Container')
        end

        # PgSQL
        remove_file('db/PGSQL/.keep')
        step_info 'Launching PgSQL Container'
        docker_compose('up psql -d')
        wait('to initialize PgSQL database')
        touch_file('db/PGSQL/.keep')

        # Redis
        step_info 'Launching Redis Container'
        docker_compose('up redis -d')
        wait('to launch Redis Container')

        # Rails
        step_info 'Launching Rails Container'
        docker_compose('up rails -d')
        wait('to launch Rails Container')
        step_info_new_line

        # ElasticSearch
        step_info 'Launching ElasticSearch Container'
        set_permissions_for_elastic
        docker_compose('up elastic -d')
        wait('to launch ElasticSearch Container')

        # Sidekiq UI
        if development?
          step_info 'Launching Sidekiq UI Container'
          docker_compose('up sidekiq_web -d')
          wait('to launch Sidekiq UI Container')
        end

        step_info 'Correcting Permissions for Linux'
        set_lucky_permissions

        step_info 'Installing Gems'
        rails_install_gems

        step_info 'Turn off some ElasticSearch settings'
        turn_off_elastic_settings

        step_info 'Prepare Database (Create, Migrate, Create Seeds)'
        rails_db_prepare

        step_info 'Indexing Article Model'
        chewy_index

        step_info_new_line

        if development?
          step_info 'Quality: Rubocop'
          rubocop

          step_info 'Quality: RSpec with SimpleConv'
          rspec_with_cov

          step_info 'Quality: Breakman'
          breakman

          step_info_new_line
        end

        # Assets / Node & Yarn
        step_info 'Yarn: Install Node Packages'
        yarn_install

        step_info 'Yarn: Build JS/CSS Assets'
        yarn_build

        step_info 'Precompile Assets'
        rails_assets_precompile if production?

        step_info_new_line

        step_info 'Launching Sidekiq'
        sidekiq_start

        step_info 'Launching Rails App with Puma'
        puma_start

        # Nginx
        if development?
          step_info 'Launching Nginx'
          docker_compose('up nginx -d')
          wait('to launch Nginx')
        end

        step_info_new_line

        step_info 'Visit Rails App: http://localhost:3000'

        if development?
          step_info 'Visit Mail Service: http://localhost:1080'
          step_info 'Visit ElasticSearch: http://localhost:9200'
        end

        containers_information

        rails7_ready
        nginx_message if development?
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/BlockLength
