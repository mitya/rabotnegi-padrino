require 'test_helper'

unit_test Gore::MongoReflector do
  test "real definitions" do
    vacancy = Gore::MongoReflector.metadata_for('vacancies')
  
    assert_equal 'vacancy', vacancy.singular
    assert_equal 'vacancies', vacancy.plural
    assert_equal 'vacancies', vacancy.key
    assert_equal true, vacancy.searchable?
    assert_equal Vacancy, vacancy.klass

    # log_item = Gore::MongoReflector.metadata_for('log_items')
    #   
    # assert_equal 'mongo_log_item', log_item.singular
    # assert_equal 'mongo_log_items', log_item.plural
    # assert_equal 'log_items', log_item.key
    # assert_equal true, log_item.searchable?
    # assert_equal MongoLog::Item, log_item.klass
  end
end

unit_test Gore::MongoReflector::Builder do
  dummy = temp_class Gore::ApplicationModel do
    field :name
    field :email    
  end
  
  test "list" do
    collection_1 = Gore::MongoReflector::Builder.new.desc(dummy) do
      list :id, [:name, :link], [:email, trim: 20], [:url, :link, trim: 30]
    end
    fields_1 = collection_1.list_fields.index_by { |field| field.name.to_sym }
  
    collection_2 = Gore::MongoReflector::Builder.new.desc(dummy) do
      list id: _, name: :link, email: {trim: 20}, url: [:link, trim: 30]
    end
    fields_2 = collection_2.list_fields.index_by { |field| field.name.to_sym }
  
    [fields_1, fields_2].each do |fields|
      assert_equal 'id', fields[:id].name
      assert_equal 'name', fields[:name].name
      assert_equal :link, fields[:name].format
      assert_equal 'email', fields[:email].name
      assert_equal nil, fields[:email].format
      assert_equal 20, fields[:email].trim
      assert_equal 'url', fields[:url].name
      assert_equal :link, fields[:url].format
      assert_equal 30, fields[:url].trim
    end
  end  
  
  test "list options" do
    collection = Gore::MongoReflector::Builder.new.desc(dummy) do
      list_order :name
      list_page_size 33
      actions update: false
    end
    
    assert_equal :name, collection.list_order
    assert_equal 33, collection.list_page_size
    assert_equal false, collection.actions[:update]    
    assert_equal nil, collection.actions[:delete]    
  end
  
  test "list_css_classes" do
    collection = Gore::MongoReflector::Builder.new.desc(dummy) do
      list_css_classes { |x| {joe: x.name == 'Joe'} }
    end
  
    assert_equal Hash[joe: true], collection.list_css_classes.(dummy.new(name: "Joe"))
    assert_equal Hash[joe: false], collection.list_css_classes.(dummy.new(name: "Bob"))
  end
  
  test "view_subcollection" do
    collection = Gore::MongoReflector::Builder.new.desc(dummy) do
      view_subcollection :loadings, 'rabotaru_loadings'
    end
    
    assert_equal :loadings, collection.view_subcollections.first.accessor
    assert_equal 'rabotaru_loadings', collection.view_subcollections.first.key
    assert_equal Gore::MongoReflector.metadata_for('rabotaru_loadings'), collection.view_subcollections.first.collection
  end
  
  test "edit" do
    collection = Gore::MongoReflector::Builder.new.desc(dummy) do
      edit title: 'text', city_name: ['combo', City.all], created_at: 'date_time'
    end
  
    fields = collection.edit_fields.index_by { |field| field.name.to_sym }
    assert_equal 'title', fields[:title].name
    assert_equal 'text', fields[:title].format
    assert_equal 'combo', fields[:city_name].format
    assert_equal [City.all], fields[:city_name].args
    assert_equal 'date_time', fields[:created_at].format
  end
end
