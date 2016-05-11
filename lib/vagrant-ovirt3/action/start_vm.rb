require 'log4r'

module VagrantPlugins
  module OVirtProvider
    module Action

      # Just start the VM.
      class StartVM

        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant_ovirt::action::start_vm")
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_ovirt3.starting_vm"))

          machine = env[:ovirt_compute].servers.get(env[:machine].id.to_s)
          if machine == nil
            raise Errors::NoVMError,
              :vm_name => env[:machine].id.to_s
          end

          status = ""
          for i in 1..60
            status = env[:ovirt_compute].servers.get(env[:machine].id.to_s).status
            break if status == "down" or status == "up"
            sleep 2
          end

          # Start VM.
          begin
            if status == "down"
              machine.start
            end
          rescue OVIRT::OvirtException => e
            raise Errors::StartVMError,
              :error_message => e.message
          end

          @app.call(env)
        end
      end
    end
  end
end
