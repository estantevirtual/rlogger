module RLogger
  class DefaultLogger < Logger
    attr_reader :config

    def initialize(config={})
      config[:formatter] = config[:formatter] ||= DefaultFormatter.new
      config[:service_name] = config[:service_name] ||= ""
      config[:output] = config[:output] ||= STDOUT
      @agent_notifier = ::NewRelic::Agent if defined? ::NewRelic::Agent
      @agent_notifier = config[:agent_notifier] if config[:agent_notifier]
      @config = config

      super(config[:output])
      setup!
    end

    public
    def error(progname = nil, &block)
      if error?
        begin
          msg = block.call
          super(msg)
          raise msg
        rescue => e
          @agent_notifier.notice_error(e) if defined? @agent_notifier
        end
      end
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
