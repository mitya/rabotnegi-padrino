module Gore::EventHandling
  def event_handlers
    @event_handlers ||= {}
  end
  
  def event_handlers_for(event)
    event = event.to_sym
    event_handlers[event] || []
  end
  
  def add_event_handler(event, &block)
    event = event.to_sym
    event_handlers[event] ||= []
    event_handlers[event] << block
  end
  
  def remove_event_handler(event, &block)
    event = event.to_sym    
    event_handlers[event] ||= []
    event_handlers[event].delete_if { |h| h == block }
  end
  
  def raise_event(event, &block)
    event = event.to_sym
    return if event_handlers[event].blank?
    
    event_data = block.call
    event_handlers[event].each { |handler| handler.call(event_data) }
  end
end
