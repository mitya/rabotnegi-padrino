module Gore
  class Captcha
    include Mongoid::Document
    store_in "sys.captchas"
    field :text, type: String, default: -> { Captcha.generate_random_text }
    field :created_at, type: DateTime, default: -> { Time.now }

    validates_presence_of :text    
    
    def key
      id.to_s
    end

    # convert -fill darkblue -edge 10 -background white -size 100x28 -wave 3x69 -gravity 'Center' -pointsize 22 -implode 0.2 label:ABC01 'captcha.jpg' 2>&1
    def image_file
      outfile = Tempfile.new(['gore_captcha', '.jpg'])
      outfile.binmode

      Services.write_image_for_text(text, outfile)
      File.expand_path(outfile.path)
    end
    
    module Services
      extend self
      
      def generate
        Captcha.create!
      end

      def valid?(id, text)
        captcha = Captcha.find(id) rescue nil
        captcha && captcha.text == text.to_s.upcase
      end
          
      def generate_random_text(length = 5)
        Alphabet.sample(length).join
      end      
      
      # write_image File.open(Padrino.root("tmp/captcha.jpeg"), 'wb')
      def write_image_for_text(text, file)
        amplitude = 2 + rand(2)
        frequency = 50 + rand(20)

        params = ['-fill darkblue', '-edge 10', '-background white']
        params << "-size 100x28"
        params << "-wave #{amplitude}x#{frequency}"      
        params << "-gravity 'Center'"
        params << "-pointsize 22"
        params << "-implode 0.2"
        params << "label:#{text}"
        params << "'#{File.expand_path(file.path)}'"

        command = "convert #{params.join(' ')} 2>&1"
        output = `#{command}`

        raise StandardError, "Error while running #{command}: #{output}" unless $?.exitstatus == 0
      
      ensure
        file.close
      end       
    end

    extend Services
        
    Alphabet = ('A'..'Z').to_a + ('0'..'9').to_a
  end
end
