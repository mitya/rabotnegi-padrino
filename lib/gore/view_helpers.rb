# depends on: element
# some functions depend on: localize, link_to, url, current_url, truncate, number_with_precision
module Gore::ViewHelpers
  module Common
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
  
    %w(div p b).each do |tag|
      class_eval <<-ruby
        def #{tag}(*args, &block)
          element(:#{tag}, *args, &block)
        end
      ruby
    end

    def br
      tag(:br)
    end

    # Fast cycling helper
    def xcycle(*values)
      @xcycle_counter ||= -1
      @xcycle_counter += 1
      values[@xcycle_counter.modulo(values.length)]
    end
    
    def centering_table(&proc)
      "<table class='centered'><tr><td>#{capture(&proc)}</table>".html_safe
    end    
  
    def lorem
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
      Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure 
      dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
      proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end
  
    def output(block, result)
      block_is_template?(block) ? concat_content(result) : result
    end
  
  end
  
  module Inspection
    def hash_as_lines(hash)
      hash.map { |key, val| "#{key}: #{val}" }.join("\n")
    end
  
    def hash_as_dl(hash)
      return element(:p, "—") if hash.blank?
    
      element :dl do
        hash.map { |key, val| element(:dt, key) + element(:dd, val) }.join.html_safe
      end
    end

    def hash_view(hash)
      return "" if hash.blank?
      element :table, "hash" do
        hash.map do |key, value|
          element(:tr) do
            title = key.to_s.titleize.gsub(' ', '-')
            element(:th, title) + element(:td, Gore.inspect_value(value))
          end        
        end.join.html_safe
      end
    end
  
    def hash_of_lines(hash)
      hash = hash.dup
      hash.each_key do |k|
        hash[k] = Gore.inspect_value(hash[k])
      end
      hash_view(hash)
    end
  
    def array_view(array)
      element :ul, "array" do
        array.map do |item|
          element(:li, item.to_s)
        end.join.html_safe
      end    
    end

    def array_inline(array)
      Gore.inspect_array(array)
    end
    
    def inline_multi_view(obj)
      case obj
        when Array then array_inline(obj)
        when Hash then Gore.inspect_hash(obj)
        when String then obj
      end
    end
  
    def multi_view(obj)
      case obj
        when Array then array_view(obj)
        when Hash then hash_view(obj)
        when String then obj
      end
    end
    
    # options: compact, trim
    def inspect_value(value, options = {})
      return "" if value.blank?

      case value
        when Time then options[:compact] ? l(value.localtime, format: :short) : l(value.localtime)
        when Integer then number(value)
        when BSON::ObjectId then options[:compact] ? short_object_id(value) : value
        when Symbol then value.to_s.humanize
        when String then trim(value, options[:trim])
        else trim(value, options[:trim])
      end
    end    
  end
  
  module Admin
    # <input type="search" id="q"> <input type="submit" value="Поиск">
    def search_tag
      text_field = text_field_tag(:q, value: params[:q], type: "search", id: 'q', :class => "search", autofocus: true)
      text_field + " " + submit_tag("Поиск")
    end

    # Render either a list of items with pager, either "no data" message.
    def listing(collection, &block)
      html = if collection.any?
        element(:table, "listing", &block).to_s + pagination(collection).to_s
      else
        element :div, "Ничего не найдено.", "no-data-message"
      end
      html
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
    
    Colors = %w(000 666 8f4bcf 519618 8f0d0d 387aad ab882e 8f88cf 4a7558 3aa c400b7 00f e10c02 800000 808000 008000 000080 800080 F0F 408099 FF8000 008080)

    def color_code(item)
      @color_codes ||= {}
      @color_codes[item] ||= Colors[@color_codes.size.remainder(Colors.length)]
      color = @color_codes[item]
      element :span, item, :class => "color", style: "background-color: ##{color}"
    end
    
  end
  
  module Formatting
    def trim(value, length = nil)
      length ? truncate(value.to_s, length: length, separator: ' ') : value.to_s
    end
        
    def stringify(obj)
      obj.to_s
    end

    def time(seconds)
      min = seconds.to_i / 60
      sec = seconds.to_i - min * 60
      "%02i:%02i" % [min, sec]
    end

    # 05:200
    # 02:30:200  
    def sec_usec(seconds)
      "%.3f" % [seconds] if seconds
    end
  
    def datetime(time)
      time.localtime.strftime("%d.%m.%Y %H:%M:%S %Z")
    end

    def datetime_full(time)
      time.localtime.strftime("%d.%m.%Y %H:%M")
    end
  
    def date_full(time)
      time.localtime.strftime("%d.%m.%Y")    
    end

    def number(value)
      number_with_delimiter(value)
    end

    def limited_number(value, threshold)
      value < threshold ? value : element(:span, value, :class => "extreme-number")
    end

    def short_object_id(value)
      "#{value.to_s.first(8)}-#{value.to_s.last(4)}"
    end
  end
  
  module Editing
    def submit_section(label)
      element :div, 'submit' do
        tag(:input, type: 'submit', value: label, :class => 'action-button') +
        element(:span, (" или " + element(:a, 'Отменить', 'ui', href: request.referer)), 'cancel')
      end
    end
  
    def errors_for(object, options = {})
      return '' if object.errors.empty?
        
      header_message = options.delete(:header_message) || translate("errors.system.header")
      error_messages = object.errors.map do |attr, message|
        translate("errors.#{object.class.model_name.plural}.#{attr}", :default => message)
      end

      partial "shared/errors", locals: {header: header_message, errors: error_messages}
    end   

    def trb(label, content = nil, options = {}, &block)
      if block_given?
        options = content || {}
        content = capture(&block)
      end
      
      options.assert_valid_keys(:required, :id, :before, :after, :comment, :class)
      label = [label]
      content = [content]
    
      row_id = options[:rid]
      row_id = row_id.join('_') if row_id.is_a?(Array)
    
      row_options = {}
      row_options[:id] = "#{row_id}_row" if row_id
      row_options[:class] = options[:class].present?? [options[:class]] : []
      row_options[:class] << "required" if options[:required]
      row_options[:class] << "high" if options[:high]
      row_options[:class] = row_options[:class].any?? row_options[:class].join(' ') : nil
        
      content.unshift options[:before] if options[:before]
      content.push content_tag(:span, '(обязательное поле)', :class => 'required-mark') if options[:required]
      content.push options[:after] if options[:after]
      content.push tag(:br) + content_tag(:small, options[:comment]) if options[:comment]

      element :tr, row_options do
        element(:th, label.join(' ').html_safe) +
        element(:td, content.join(' ').html_safe) + 
        element(:td, "", :class => "other")
      end
    end
  
    def trs(content, row_options = {})
      content_tag :tr, row_options do
        content_tag :td, content.html_safe, :colspan => 2
      end
    end
  
    def tr1(first, options = {})
      trb(first, nil, options)
    end

    def tr2(last, options = {})
      trb(nil, last, options)
    end
  
    def tr(name, title, content, options = {})
      label = label_tag(name, title + ':')
      trb(label, content, options)
    end
    
    def wrapper(&block)
      output block, element(:table, "form-layout", &block)
    end    
  end

  module Layout
    # sets the page title, id, class
    def page(id, title = nil, options = {})
      @page_id = id
      @page_title = title
      @page_class = options[:class] || options[:klass]
      @page_class = nil if @page_class.blank?

      if options[:path]
        options.merge! :tab => options[:path].first, :navbar => options[:path].second, :navlink => options[:path].third
      end

      @current_tab = "#{options[:tab]}-tab" if options[:tab]
      @current_navbar = "#{options[:navbar]}-nav-bar" if options[:navbar]
      @current_navlink = "#{options[:navlink]}-link" if options[:navlink]
    
      if @current_navbar == "casual-employers-nav-bar" && session[:employer_id]
        @current_navbar = "pro-employers-nav-bar"
      end
    end
  
  	def meta(name, content)
    	@meta_properties ||= {}
    	@meta_properties[name] = content
  	end
    
    # (nil) => "Работнеги.ру"
    # ("Вакансии") => "Вакансии - Работнеги.ру"
    # ("Строители", "Вакансии") => "Строители - Вакансии - Работнеги.ру"
    # ("Строители", " ", "Вакансии") => "Строители - Вакансии - Работнеги.ру"
  	def document_title
  	  [@page_title, "Работнеги.ру"].flatten.reject(&:blank?).join(' - ')
  	end
  end

  module Collections
  	def found_objects_info(collection, word, e1, e2, e5)
			object = Gore::RussianInflector.inflect(collection.total_pages <= 1 ? collection.size : collection.total_count, word, e1, e2, e5)

  		"Найдено #{b collection.total_count} #{object}. 
       Показаны #{b(collection.offset_value + 1)} — #{b(collection.offset_value + collection.limit_value)}".html_safe
  	end
	  
    def sorting_state_class_for(field)
      current_field, _ = Gore::SortExpressions.decode_order_to_array(params[:sort])
      field.to_s == current_field ? "sorted" : ""
    end    
    
    def pagination(collection, options = {})
      return "" unless collection.respond_to?(:total_pages) && collection.total_pages > 1
      element :div, "pager" do
        pagination_links(collection, options)
      end 
    end

    def pagination_links(collection, options = {})
      links_model = pagination_links_model(collection)
  
      links = links_model.map do |key|
        case
        when key == collection.current_page
          element :em, key
        when key.is_a?(Numeric)
          link_to key, current_url(page: key), :class => "num"
        when key == :gap
          element :span, '&hellip;', "gap"
        end
      end.join(' ')

      if collection.first_page?
        links.insert 0, element(:span, "&larr; предыдущая станица", "stub")
      else
        links.insert 0, element(:span, "&larr;", "dir") + link_to("предыдущая станица", current_url(page: collection.previous_page))
      end

      if collection.last_page?
        links << element(:span, "следующая страница &rarr;", "stub")
      else
        links << link_to("следующая страница", current_url(page: collection.next_page))
        links << element(:span, "&rarr;", "dir")
      end    
  
      element :div, links, "pagination"
    end

    def pagination_links_model(collection)
      links = []
  
      total_pages = collection.total_pages
      current_page = collection.current_page
      inner_window = 2
      outer_window = 0

      window_from = current_page - inner_window
      window_to = current_page + inner_window
  
      if window_to > total_pages
        window_from -= window_to - total_pages
        window_to = total_pages
      end
  
      if window_from < 1
        window_to += 1 - window_from
        window_from = 1
        window_to = total_pages if window_to > total_pages
      end
  
      middle = window_from..window_to

      # left window
      if outer_window + 3 < middle.first # there's a gap
        left = (1..(outer_window + 1)).to_a
        left << :gap
      else # runs into visible pages
        left = 1...middle.first
      end

      # right window
      if total_pages - outer_window - 2 > middle.last # again, gap
        right = ((total_pages - outer_window)..total_pages).to_a
        right.unshift :gap
      else # runs into visible pages
        right = (middle.last + 1)..total_pages
      end
  
      links = left.to_a + middle.to_a + right.to_a
    end    
  end

  class FormBuilder < Padrino::Helpers::FormBuilder::StandardFormBuilder
    def text_block(attr, caption, options = {})
      control_block_for(:text_field, attr, caption, options)
    end

    def text_area_block(attr, caption, options = {})
      control_block_for(:text_area, attr, caption, options)
    end

    def select_block(attr, caption, options = {})
      control_block_for(:select, attr, caption, options)
    end
    
    def submit_block(caption)
      template.tr2 template.submit_section(caption)
    end

    def captcha_block
      if template.captcha_valid?
        template.tr2 template.captcha_section
      else
        label = template.label_tag("Защитный код", for: "captcha_text")
        template.trb label, template.captcha_section, comment: "Введите 4 латинские буквы которые паказаны на картинке.", :class => "captcha"        
      end      
    end

    private
    
    def control_block_for(control_name, attr, caption, options)
      block_options = options.extract!(:required, :before, :after, :comment)
      label = label(attr, caption: caption + ':')
      control = send(control_name, attr, options)
      template.trb(label, control, block_options)
    end
  end
end
