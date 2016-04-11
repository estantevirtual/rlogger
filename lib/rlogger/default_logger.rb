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
      if is_test?
        return STDOUT
      end

      "log/#{Rails.env}.log"
    end

    public
    def error(progname = nil, message: nil, exception: nil, &block)
      return unless error?

      message = block.call if block

      exception_msg =
        if exception
          if exception.respond_to?(:message) && exception.message
            exception.message
          else
            exception.inspect
          end
        end

      # call super to print the msg
      final_message = message || exception_msg || progname
      super(final_message)

      # notice error
      if exception
        @agent_noticer.notice_error(exception)
      else
        @agent_noticer.notice_error(final_message)
      end
    end

    private
    def setup!
      self.progname = config[:service_name]

      set_formatter unless is_dev_or_test?

      self.level = config[:level] || Logger::INFO
    end

    def is_dev_or_test?
      Rails.env.development? || Rails.env.test?
    end

    def is_test?
      Rails.env.test?
    end

    def set_formatter
      self.formatter = proc { |severity, datetime, progname, msg|
        config[:formatter].call(severity, datetime, progname, msg.dump)
      }
    end
  end
end
