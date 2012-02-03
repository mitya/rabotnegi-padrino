module Gore::Stubbing
  @@stubs = []
  
  def self.stub(target, method, &block)
    @@stubs << [target, method]
    target.singleton_class.instance_eval do
      alias_method "original_#{method}", method
      define_method(method, &block)
    end
  end
  
  def self.unstub_all
    @@stubs.each do |target, method|
      target.singleton_class.instance_eval do
        alias_method method, "original_#{method}"
      end      
    end
  end
end
