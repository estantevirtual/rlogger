require 'rlogger/nil_agent_noticer'

module RLogger
  class AgentNoticerFactory
    def self.build(config)
      if config[:agent_noticer]
        config[:agent_noticer]
      elsif defined? ::NewRelic::Agent
        ::NewRelic::Agent
      else
        NilAgentNoticer.new
      end
    end
  end
end
