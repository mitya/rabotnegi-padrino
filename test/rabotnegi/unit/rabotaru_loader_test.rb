require 'test_helper'

unit_test Rabotaru::Loader do
  setup do
    @directory = Se.rabotaru_dir.join(Mu.date_stamp)
  end

  teardown do
    FileUtils.rm_rf(@directory)
  end
  
  test "load loads the feed from the web and writes it to the file" do
    Http.stubs(:get).returns("downloaded data")

    loader = Rabotaru::Loader.new("spb", "it")
    loader.load
    
    assert @directory.directory?
    assert_equal "downloaded data", @directory.join("spb-it.json").read
  end
  
  test "load doesn't reload the file if it already exists" do
    @directory.mkpath
    File.write(@directory.join("spb-it.json"), "existing data")
    Http.stubs(:get).never

    loader = Rabotaru::Loader.new("spb", "it")
    loader.load
    
    assert_equal "existing data", @directory.join("spb-it.json").read
  end
end
