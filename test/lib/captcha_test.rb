require 'test_helper'

describe Gore::Captcha do
  subject { Gore::Captcha.generate }
    
  it "has a long random generated key" do
    subject.key.must_match %r<[0-9a-f]{24}>
  end
    
  it "has a random generated text" do
    subject.text.wont_be_nil
    subject.text.must_match %r<[0-9A-Z]{5}>
  end
  
  it "generates an image and writes it to a file" do
    image_path = Padrino.root("tmp/test.tempfiles/#{subject.id}.jpeg")
    Gore::Captcha.write_image_for_text("ABCD", File.open(image_path, "wb"))

    file_info = `file #{image_path}`
    file_info.must_match %r{JPEG image data}
  end
  
  test '#image_file returns a path to the tempfile with the captcha image' do
    file_path = subject.image_file
    file_info = `file #{file_path}`
    file_info.must_match %r{JPEG image data}
  end
end

describe "Capcha Controller" do
  let(:captcha) { Gore::Captcha.generate }
  
  test "GET /captcha/:id.jpeg" do
    get "/captcha/#{captcha.id}.jpeg"
    response.status.must_equal 200
    response.content_type.must_equal "image/jpeg"
    response.content_length.must_be_close_to 2.kilobytes, 500.bytes
  end

  test "GET /captcha/:invalid-id.jpeg" do
    get "/captcha/#{BSON::ObjectId.new}.jpeg"
    response.status.must_equal 404
  end
end
