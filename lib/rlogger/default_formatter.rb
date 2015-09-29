module RLogger
  class DefaultFormatter < Logger::Formatter
    def call(severity, time, progname, msg)
      hostname = Socket.gethostname
      "[#{time}] [Hostname: #{hostname} | Service: #{progname}] (#{severity}): #{msg}\n"
    end
  end
end
