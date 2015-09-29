require 'logger'
require 'socket'

class RFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    hostname = Socket.gethostname
    "[#{time}] [Hostname: #{hostname} | Service: #{progname}] (#{severity}): #{msg}\n"
  end
end

class RLogger < Logger
  def self.logger
    logger = RLogger.new(STDOUT)
    logger.progname = 'Ecommerce'
    r_formatter = RFormatter.new
    logger.formatter = proc { |severity, datetime, progname, msg|
      r_formatter.call(severity, datetime, progname, msg.dump)
    }
    logger
  end
end
