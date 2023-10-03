# frozen_string_literal: true

module Rails7StartKit
  class << self
    def nginx_up
      docker_compose('up nginx -d')
    end

    def nginx_down
      docker_compose('stop nginx')
    end

    def nginx_generate_ssl
      command = "openssl req -new -newkey rsa:4096 -days 1000 -nodes -x509 \
                  -subj \"/C=US/ST=Denial/L=Springfield/O=Rails7Startkit/OU=the-teacher/CN=rails7-startkit.site\" \
                  -keyout config/_NGINX/nginx.key -out config/_NGINX/nginx.crt"

      system(command)
    end

    def nginx_restart
      nginx_down
      nginx_up
    end

    # rubocop:disable Metrics/MethodLength
    def nginx_message
      puts '~' * 80
      puts 'To make project available on `http://rails7-startkit.site`'
      puts 'Add: "127.0.0.1    rails7-startkit.site" to your local host file.'
      puts
      puts 'Linux/MacOS path: /etc/hosts'
      puts 'Windows path: C:\Windows\System32\drivers\etc\hosts'
      puts '(You may need Admin permissions)'
      puts
      puts 'On Linux/MacOS you can try:'
      puts 'sudo echo "127.0.0.1    rails7-startkit.site" >> /etc/hosts'
      puts '~' * 80
    end
    # rubocop:enable Metrics/MethodLength
  end
end
