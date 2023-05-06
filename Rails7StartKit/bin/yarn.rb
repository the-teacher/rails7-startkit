# frozen_string_literal: true

module Rails7StartKit
  class << self
    INIT_NVM = 'source /opt/.nvm/nvm.sh'

    def yarn_install
      step_info 'Yarn: Install Node Packages'
      container_bash_exec('rails', "#{INIT_NVM} && yarn install")
    end

    def yarn_build
      step_info 'Yarn: Build JS/CSS Assets'
      container_bash_exec('rails', "#{INIT_NVM} && yarn build")
    end
  end
end
