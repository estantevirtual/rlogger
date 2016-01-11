module RLogger
  class DefaultFormatter < Logger::Formatter
    def call(severity, time, progname, msg)
      hostname = Socket.gethostname
      "#{severity[0]}, [#{time}] [PID: ##{$$} Thread: ##{Thread.current.object_id}] [Hostname: #{hostname} | Service: #{progname}] (#{severity}): #{msg}\n"
    end
  end
end
