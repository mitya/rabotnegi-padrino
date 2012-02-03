module Gore::LogFilter
  FILTERED_LOG_ENTRIES = [
    "Served asset", 'Started GET "/assets/',
    "['system.namespaces'].find({})",
  ]

  def self.register
    Padrino::Logger.class_eval do  
      def write(message = nil)
        return if String === message && FILTERED_LOG_ENTRIES.any? { |pattern| message.include?(pattern) }
        self << message
      end  
    end    
  end
end
