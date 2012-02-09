module Gore::SassFunctions
  def self.register
    Sass::Script::Functions.module_eval do
      def image_url(source)
        ::Sass::Script::String.new "url(/rabotnegi/assets/#{source.value})"
      end
  
      declare :image_url, [:source]
    end
  end
end
