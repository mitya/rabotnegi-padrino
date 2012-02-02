class Gore::ApplicationModel
  def self.inherited(derived)
    derived.class_eval do
      include Mongoid::Document
      include Mongoid::Timestamps
      include Gore::EventLog::Accessor
    end
  end
end
