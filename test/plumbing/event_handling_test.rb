require "test_helper"

unit_test Gore::EventHandling do
  service_klass = temp_class do
    include Gore::EventHandling
    attr :ivar
    
    def f1
      raise_event :hello do
        :hello_from_f1
      end
    end

    def f2
      raise_event :hello do
        :hello_from_f2
      end
    end
    
    def f3
      raise_event :hello do
        @ivar = :modified_in_f3_hello
        :hello_from_f3
      end      
    end
  end

  setup do
    @service = service_klass.new
  end

  test "basic handling" do
    hello_event_results = []
    
    @service.add_event_handler(:hello) { |data| hello_event_results << data }
    
    @service.f1
    @service.f2    

    assert hello_event_results.include?(:hello_from_f1)
    assert hello_event_results.include?(:hello_from_f2)
  end
  
  def foo(x)
    
  end
  
  test "event generator should not be invoked when there are no event handlers attached" do
    assert_nil @service.ivar
    @service.f3    
    assert_nil @service.ivar

    @service.add_event_handler(:hello) { |data| }

    @service.f3
    assert_equal :modified_in_f3_hello, @service.ivar
  end
  
  test "remove a handler" do
    handler = ->(data) { hello_event_results << data }
    
    @service.add_event_handler(:hello, &handler)
    assert_equal 1, @service.event_handlers_for(:hello).count
    
    @service.remove_event_handler(:hello, &handler)
    assert_equal 0, @service.event_handlers_for(:hello).count
  end
end
