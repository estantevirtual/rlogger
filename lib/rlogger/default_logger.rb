require 'rlogger/agent_noticer_factory'

module RLogger
  class DefaultLogger < Logger
    attr_reader :config

    def initialize(config={})
      config[:formatter] = config[:formatter] ||= DefaultFormatter.new
      config[:service_name] = config[:service_name] ||= ''
      config[:output] = config[:output] ||= create_default_output
      config[:shift_age] = config[:shift_age] ||= 3
      config[:shift_size] = config[:shift_size] ||= 100 * 1024 * 1024
      config[:message_size_limit] = config[:message_size_limit] ||= 1000
      @agent_noticer = AgentNoticerFactory.build(config)
      @config = config

      super(config[:output], config[:shift_age], config[:shift_size])
      setup!
    end

    def create_default_output
      if is_test?
        return STDOUT
      end

      "log/#{Rails.env}.log"
    end

    public

    def info(progname = nil)
      super(compact_long_message(progname))
    end

    def debug(progname = nil)
      super(compact_long_message(progname))
    end

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
      super(compact_long_message(final_message))

      # notice error
      if exception
        @agent_noticer.notice_error(exception)
      else
        @agent_noticer.notice_error(final_message)
      end
    end

    def compact_long_message(msg)
      msg_limit = @config[:message_size_limit]
      msg_size = msg.size
      return msg if msg_size <= msg_limit

      second_limit = msg_size - 100
      second_limit = msg_limit + 100 if second_limit <= msg_limit
      "#{msg[0..msg_limit-1]}...#{msg[second_limit..msg_size]}"
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
