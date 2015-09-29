module RLogger
  class DefaultLogger < Logger
    attr_reader :config

    def initialize(config={})
      config[:formatter] = config[:formatter] ||= DefaultFormatter.new
      config[:service_name] = config[:service_name] ||= ""
      config[:output] = config[:output] ||= STDOUT
      @config = config

      super(config[:output])
      setup!
    end

    private

    def setup!
      self.progname = config[:service_name]
      self.formatter = proc { |severity, datetime, progname, msg|
        config[:formatter].call(severity, datetime, progname, msg.dump)
      }
    end
  end
end
