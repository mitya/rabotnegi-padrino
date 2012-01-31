require 'test_helper'

unit_test Object do
  dummy = temp_class do
    attr_accessor :fname, :lname
  end
  
  test "class" do
    assert_equal 123.class, 123._class
  end
  
  test "is?" do
    assert 132.is?(String, NilClass, Fixnum)
    assert !132.is?(String, NilClass, Symbol)
  end
  
  test "send_chain" do
    assert_equal "h", "hello".send_chain("first")
    assert_equal 104, "hello".send_chain("first.ord")
    assert_equal "104", "hello".send_chain("first.ord.to_s")
  end
  
  test "assign_attributes" do
    person = dummy.new
    person.assign_attributes(fname: "Joe", lname: "Smith", age: 25)
    assert_equal "Joe", person.fname
    assert_equal "Smith", person.lname
    assert_not_respond_to person, :age
  end

  test "assign_attributes!" do
    assert_raise NoMethodError do
      dummy.new.assign_attributes!(fname: "Joe", lname: "Smith", age: 25)
    end
  end
end

unit_test File do
  test "write" do
    assert_respond_to File, :write
  end
end

unit_test Hash do
  test "append_string" do
    hash = {aa: "AA"}

    hash.append_string(:aa, "and AA")
    assert_equal "AA and AA", hash[:aa]
    
    hash.append_string(:bb, "and BB")
    assert_equal "and BB", hash[:bb]  
  end

  test "prepend_string" do
    hash = {aa: "AA"}

    hash.prepend_string(:aa, "and AA")
    assert_equal "and AA AA", hash[:aa]
    
    hash.prepend_string(:bb, "and BB")
    assert_equal "and BB", hash[:bb]  
  end
end

unit_test "JSON conversions" do
  test "Time" do
    assert_equal "\"2012-01-01T12:00:00Z\"", "2012-01-01T12:00:00Z".to_time.to_json
    assert_equal "2012-01-01T12:00:00Z", "2012-01-01T12:00:00Z".to_time.as_json
  end
  
  test "BSON::ObjectId" do
    id = BSON::ObjectId.new
    assert_not_equal id.to_json, id.as_json
  end
end

unit_test Module do
  class TProcess
    attr_accessor :status
    def_state_predicates 'status', :started, :failed, :done
  end    

  test "def_state_predicates" do    
    assert_equal :status, TProcess._state_attr
    assert_equal [:started, :failed, :done], TProcess._states
    
    process = TProcess.new
    assert_respond_to process, :started?
    assert_respond_to process, :failed?
    assert_respond_to process, :done?
    
    process.status = "failed"
    assert process.failed?
    assert !process.done?

    process.status = :done
    assert !process.failed?
    assert process.done?
  end
end

unit_test Enumerable do
  test "select_xx/detect_xx" do
    ary = %w(1 2 3 4 5 6 7)
    assert_equal %w(3), ary.select_eq(to_i: 3)
    assert_equal %w(1 2 4 5 6 7), ary.select_neq(to_i: 3)
    assert_equal %w(3 4 5), ary.select_in(to_i: [3, 4, 5])
    assert_equal %w(1 2 6 7), ary.select_nin(to_i: [3, 4, 5])

    assert_equal "3", ary.detect_eq(to_i: 3)
    assert_equal "1", ary.detect_neq(to_i: 3)

    assert_equal %w(3), ary.select_eq(to_i: 3, to_s: "3")
    assert_equal "3", ary.detect_eq(to_i: 3, to_s: "3")
  end
  
  test "map_to_array" do
    assert_equal [ [1, 1], [22, 2] ], %w(1 22).map_to_array(:to_i, :length)
  end
  
  test "pluck_all" do
    assert_equal [ %w(1 2), %w(3 4) ], [ [1,2], [3,4] ].pluck_all(:to_s)
  end
end
