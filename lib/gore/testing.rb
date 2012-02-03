module Gore::Testing
  module Globals
    def ui_test(name, &block)
      test_case = Class.new(Gore::CapybaraTest)
      Object.const_set((name.to_s.tr_s(' :', '_') + 'CapybaraTest').classify, test_case)
      test_case.class_eval(&block)
    end
  
    def make(factory_name, *args, &block)
      factory_name = factory_name.model_name.singular if Class === factory_name
      Factory(factory_name, *args, &block)
    end
    
    def patch(*args)
      Stubber.stub(*args)
    end    
  end
  
  module Cases
    def no_test(*args)
    end
    
    def visual_test(name, &block)
      # test(name, &block)
    end
    
    def temp_class(base = Object, &block)
      name = "TempClass#{rand(1000)}"
      Gore::Testing::Cases.const_set(name, Class.new(base, &block))
    end        
  end
  
  module Assertions
    def assert_size(size, collection)
      assert_equal size, collection.size
    end
    
    def assert_blank(object)
      assert object.blank?
    end
    
    def assert_same_elements(a1, a2)
      assert_equal a1.size, a2.size
      a1.each { |x| assert a2.include?(x), "#{a2.inspect} is expected to include #{x.inspect}" }
    end
  end
end

