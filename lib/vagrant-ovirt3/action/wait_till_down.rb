require 'log4r'
require 'vagrant-ovirt3/util/timer'
require 'vagrant/util/retryable'

module VagrantPlugins
  module OVirtProvider
    module Action

      # Wait till VM is stopped
      class WaitTillDown
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant_ovirt3::action::wait_till_down")
          @app = app
        end

        def call(env)

          env[:ui].info(I18n.t("vagrant_ovirt3.wait_till_down"))
          for i in 0..20
            ready = true
            server = env[:ovirt_compute].servers.get(env[:machine].id.to_s)
            if server.status != 'down'
              ready = false
            end
            break if ready
            sleep 2
          end

          if not ready
            raise Errors::WaitForShutdownVmTimeout
          end

          
          @app.call(env)
        end

      end
    end
  end
end

