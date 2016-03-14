require 'rlogger/agent_noticer_factory'

module RLogger
  class DefaultLogger < Logger
    attr_reader :config

    def initialize(config={})
      config[:formatter] = config[:formatter] ||= DefaultFormatter.new
      config[:service_name] = config[:service_name] ||= ''
      config[:output] = config[:output] ||= create_default_output
      @agent_noticer = AgentNoticerFactory.build(config)
      @config = config

      super(config[:output])
      setup!
    end

    def create_default_output
      if Rails.env.development? || Rails.env.test?
        return STDOUT
      end

      "log/#{Rails.env}.log"
    end

    public
    def error(progname = nil, &block)
      if error?
        begin
          msg = if block
            block.call
          else
            progname
          end

          super(msg)

          raise msg
        rescue => e
          @agent_noticer.notice_error(e)
        end
      end
    end

    private
    def setup!
      self.progname = config[:service_name]
      self.formatter = proc { |severity, datetime, progname, msg|
        config[:formatter].call(severity, datetime, progname, msg.dump)
      }
      self.level = config[:level] || Logger::INFO
    end
  end
end