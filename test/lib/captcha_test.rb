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
  
  test '#valid?' do
    captcha = Gore::Captcha::Info.create!(text: "RIGHT")
    assert Gore::Captcha.valid?(captcha.id, "right")
    assert Gore::Captcha.valid?(captcha.id, "RIGHT")
    assert !Gore::Captcha.valid?(captcha.id, "WRONG")
    assert !Gore::Captcha.valid?("4f3bd25fe999fb24ed000001", "right")
    assert !Gore::Captcha.valid?("invalid-id", "right")
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

describe "Captcha helpers" do
  test "GET /page-with-capthca" do
    get "/vacancies/new"
    captcha = Gore::Captcha::Info.last
    assert_have_selector "div.captcha input[type=text][name=captcha_text]"
    assert_have_selector "div.captcha input[type=hidden][name=captcha_id][value='#{captcha.id}']"      

    get "/vacancies/new", captcha_id: captcha.id, captcha_text: "WRONG"
    captcha2 = Gore::Captcha::Info.last
    assert captcha.id != captcha2.id
    assert_have_selector "div.captcha input[type=text][name=captcha_text]"
    assert_have_selector "div.captcha input[type=hidden][name=captcha_id][value='#{captcha2.id}']"

    get "/vacancies/new", captcha_id: captcha2.id, captcha_text: captcha2.text
    assert_have_selector "input[type=hidden][name=captcha_text][value='#{captcha2.text}']"
    assert_have_selector "input[type=hidden][name=captcha_id][value='#{captcha2.id}']"
  end
end
