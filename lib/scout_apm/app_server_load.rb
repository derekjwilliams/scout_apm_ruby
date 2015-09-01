module ScoutApm
  class AppServerLoad
    attr_reader :logger

    def initialize(logger=Agent.instance.logger)
      @logger = logger
    end

    def run
      @thread = Thread.new do
        begin
          logger.info("Sending Startup Info: #{data.inspect}")
          payload = ScoutApm::Serializers::AppServerLoadSerializer.serialize(data)
          reporter = Reporter.new(:app_server_load)
          reporter.report(payload)
          logger.info("Finished sending Startup Info")
        rescue => e
          logger.debug("Failed Startup Info In Thread - #{e.message} \n\t#{e.backtrace.join("\t\n")}")
        end
      end
    rescue => e
      logger.debug("Failed Startup Info - #{e.message} \n\t#{e.backtrace.join("\t\n")}")
    end

    def data
      { :server_time        => Time.now,
        :framework          => ScoutApm::Environment.instance.framework_integration.human_name,
        :framework_version  => ScoutApm::Environment.instance.framework_integration.version,
        :environment        => ScoutApm::Environment.instance.framework_integration.env,
        :app_server         => ScoutApm::Environment.instance.app_server,
        :ruby_version       => RUBY_VERSION,
        :hostname           => ScoutApm::Environment.instance.hostname,
        :database_engine    => ScoutApm::Environment.instance.database_engine,
        :application_name   => ScoutApm::Environment.instance.application_name,
        :libraries          => ScoutApm::Utils::InstalledGems.new.run,
      }
    end
  end
end