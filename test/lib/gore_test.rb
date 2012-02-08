require "test_helper"

describe Gore do
  describe "helpers" do
    test '#object_id?' do
      assert Gore.object_id?(1234)
      assert Gore.object_id?("1234")
      
      assert Gore.object_id?("1234-hello")
      assert !Gore.object_id?("1234hello")
      
      assert Gore.object_id?("4f09f1975a12ae7d50000001")
      assert Gore.object_id?("4f09f1975a12ae7d50000001-hello")
      assert Gore.object_id?(BSON::ObjectId.new)
      
      assert !Gore.object_id?("msk")
      assert !Gore.object_id?("hello-1234")
      assert !Gore.object_id?("1f09f1975a1")
      assert !Gore.object_id?("")
    end    
  end
end
