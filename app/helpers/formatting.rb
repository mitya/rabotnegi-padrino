Rabotnegi.helpers do
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
  
  def stringify(obj)
    obj.to_s
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
    time.localtime.to_s(:rus_zone)
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
    value < threshold ? value : content_tag(:span, value, :class => "extreme-number")
  end

  Colors = %w(000 666 8f4bcf 519618 8f0d0d 387aad ab882e 8f88cf 4a7558 3aa c400b7 00f e10c02 800000 808000 008000 000080 800080 F0F 408099 FF8000 008080)

  def color_code(item)
    @color_codes ||= {}
    @color_codes[item] ||= Colors[@color_codes.size.remainder(Colors.length)]
    color = @color_codes[item]
    content_tag :span, item, :class => "color", style: "background-color: ##{color}"
  end

  def trim(value, length = nil)
    length ? truncate(value.to_s, length: length, separator: ' ') : value.to_s
  end

  def short_object_id(value)
    "#{value.to_s.first(8)}-#{value.to_s.last(4)}"
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
  
  alias f inspect_value

  def inspect_field(model, field, options = {})
    value = model.send_chain(field.name) unless field.custom?
    options[:trim] = field.trim

    result = case field.format
      when :city then City.get(value)
      when :industry then Industry.get(value)
      when :pre then element(:pre, trim(value, options[:trim]))
      when String then send(field.format, value)
      when Proc then trim(field.format.(model), options[:trim])
      else inspect_value(value, options)
    end
    
    result = link_to(result, url(:admin_items, :show, collection: field.collection.key, id: model)) if field.format == :link || field.link
    
    result
  end
end
