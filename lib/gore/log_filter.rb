module Gore::LogFilter
  FILTERED_LOG_ENTRIES = [
    "Served asset", 'Started GET "/assets/',
    "['system.namespaces'].find({})",
    "MONGODB [WARNING] Please note that logging negatively impacts client-side performance.",
    "MONGODB admin['$cmd'].find({:ismaster=>1}).limit(-1)",
    "MONGODB admin['$cmd'].find({:buildinfo=>1}).limit(-1)"
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
