Rabotnegi.helpers do
  def submit_section(label)
    %{<div class='submit'>
        <input type="submit" class='action-button' value='#{ label }'>
        <span class='cancel'>или <a href='#{ request.headers['Referer'] }' class='ui'>Отменить</a><span>
      </div>}
  end
  
  # def blank_option(label = '', value = '')
  #   content_tag :option, label, :value => value
  # end

  def errors_for(object, options = {})
    return '' if object.errors.empty?
        
    header_message = options.delete(:header_message) || translate("activerecord.errors.template.header")
    error_messages = object.errors.map do |attr, message|
      translate("errors.#{object.class.model_name.plural}.#{attr}", :default => message)
    end

    render "shared/errors", :header => header_message, :errors => error_messages
  end
  
  def edit_view(model, options = {})
    options[:id] ||= nil
    options.append_string(:class, "resource")
    form_for(model, url: options.delete(:url), html: options) do |f|
      yield EditViewBuilder.new(self, f)
    end
  end
  
  def edit_field(label, control, options = {})
    options.prepend_string(:class, "editor")

    element :div, options do
      element(:div, label, 'editor-label') + 
      element(:div, control, 'editor-content') 
    end    
  end
  
  # class ::ActionView::Helpers::FormBuilder
  #   def ui_text(attr, options = {})      
  #     text_field(attr, options.reverse_merge(size: nil))
  #   end
  # 
  #   def ui_text_area(attr, options = {})
  #     text_area(attr, options)
  #   end
  # 
  #   def ui_combo(attr, collection, options = {})
  #     if City === collection.first || Industry === collection.first
  #       collection = collection.map { |struct| [struct.name, struct.code] }
  #     end
  #     
  #     html_options = options.slice!(:include_blank, :selected)
  #     select(attr, collection, options, html_options)
  #   end
  #   
  #   def ui_date_time(attr, options = {})
  #     datetime_select(attr, options)
  #   end
  # 
  #   # text(attr)
  #   # hidden(attr)
  #   # text_area(attr)
  #   # password(attr)
  #   # check_box(attr, {on,off})
  #   # radio_button(attr)
  #   # select(attr, collection)
  #   # check_boxes(attr, collection)
  #   # radio_group(attr, collection)
  # end
  
  class EditViewBuilder
    attr_accessor :template, :form
    
    def initialize(template, form_builder)
      @template = template
      @form = form_builder
    end    
    
    def method_missing(*args, &block)
      method = args.shift
      attribute = args.shift
      label = args.shift
      options = args.extract_options!
      args << options
      template.edit_field form.label(attribute, label), form.send("ui_#{method}", attribute, *args), :class => "for-#{attribute}"
    end
    
    def buttons(caption = nil, options = {}, &block)
      options.append_string(:class, "buttons")
      template.field_set_tag(caption, options, &block)
    end
    
    def commit
      form.submit("Сохранить", name: nil)
    end
    
    def errors
      template.errors_for(form.object)
    end
    
    def item(field)
      case field.format
      when String
        send(field.format, field.name, field.title, *field.args)
      end
    end
  end  
end
