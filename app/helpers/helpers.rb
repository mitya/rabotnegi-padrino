Rabotnegi.helpers do
  def centered(&proc)
    "<table class='centered'><tr><td>#{capture(&proc)}</table>".html_safe
  end

  def required_mark(options = {})
    content_tag :span, '(обязательное поле)', {:class => 'required-mark'}.update(options)
  end 
  
  def edit_icon
    image_tag 'edit.gif', :title => 'Редактировать', :alt => 'Редактировать'
  end
  
  def delete_icon
    image_tag 'delete.gif', :title => 'Удалить', :alt => 'Удалить'
  end
  
  # Fast cycling helper
  def xcycle(*values)
    @xcycle_counter ||= -1
    @xcycle_counter += 1
    values[@xcycle_counter.modulo(values.length)]
  end
  
  # (vacancy#1234) => "v-2134"
  def web_id_for_record(record)
    return nil unless record
    [web_prefix_for_class(record.class), record.id].join("-")
  end
  
  # (Vacancy) => "v"
  # (User) => "user"  
  def web_prefix_for_class(klass)
    case klass
      when Vacancy then "v"
      else ActiveModel::Naming.singular(record)
    end    
  end
  
  # (vacancy#1234) => "v-1234"
  # (:edit, vacancy#1234, :custom) => "edit-v-1234-custom"
  def web_id(*args)
    args.map { |x| x.respond_to?(:to_key) ? web_id_for_record(x) : x }.join("-")
  end

  # (wide: true, narrow: false, thin: true) => "wide thin"
  def classes_from(*args)
    M.css_classes_for(*args)
  end  
  
  def block_is_template?(block)
    false
  end
    
  # Works like content_tag. But:
  #   * :klass option can be used as :class
  #   * last argument is treated like a :class
  def element(name, *args, &block)
    options = args.extract_options!
    
    css_class = options.delete(:klass) if options.include?(:klass)
    css_class = args.pop if args.last.is_a?(String) && (args.length == 2 || args.length == 1 && block)

    options[:class] = css_class if css_class.present?
    content_tag(name, args.first, options, &block)
  end  
  
  def b(text)
    element(:b, text)
  end
  
  def current_url(params = {})
    current_path(params.stringify_keys)
  end
end
