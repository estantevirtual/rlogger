require 'rlogger/agent_noticer'

module RLogger
  class AgentNoticerFactory
    def self.build
      if defined? ::NewRelic::Agent
        ::NewRelic::Agent
      else
        AgentNoticer.new
      end
    end
  end
end
