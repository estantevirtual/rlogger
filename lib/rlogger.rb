require 'logger'
require 'socket'
require 'rlogger/default_formatter'
require 'rlogger/default_logger'

module RLogger
  extend self

  def logger
    RLogger::DefaultLogger.new
  end

  def load_config
    Config.load('')
  end
end
