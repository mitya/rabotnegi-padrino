Rabotnegi.helpers do
  def details_view(options = {}, &block)
    element :ul, 'resource' do
      capture(DetailsViewBuilder.new(self), &block)
    end
  end

  class DetailsViewBuilder
    def initialize(template)
      @template = template
    end
  
    def item(label, data = nil, options = {}, &block)
      content = block_given? ? capture(&block) : data
      content = inspect_value(content) unless options[:format] == false

      element :li, "item #{options[:klass]}".strip do
        content = element(:b, label, 'heading') + " " + content.to_s unless options[:header] == false
        content
      end
    end
    
    def actions(&block)
      element(:li, "actions", &block)
    end
    
    def method_missing(selector, *args, &block)
      @template.send(selector, *args, &block)
    end
  end
end
