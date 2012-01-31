module SortExpressions
  module_function
  
  # generates a sort parameter like "date" or "-date"
  # reverses (adds a "-") when the pararmeter is already used for sorting
  def encode_order(field, param, reverse_by_default = false)
    param.blank??
      reverse_by_default ? "-#{field}" : field.to_s :
      param == field.to_s ?
        "-#{field}" :
        field.to_s
  end
  
  # "date"  => [:date, false]
  # "-date" => [:date, true]
  def decode_order_to_array(param)
    param.present??
      param.starts_with?('-') ? 
        [param.from(1), true] : 
        [param, false] :
      [nil, false]
  end  

  # "date"  => "date asc"
  # "-date" => "date desc"
  def decode_order_to_expr(param)
    field, reverse = decode_order_to_array(param)
    modifier = reverse ? :desc : :asc
    field.nil? ? nil : "#{field} #{modifier}"
  end

  # "date"  => ["date", Mongo::ASCENDING]
  # "-date" => ["date", Mongo::DESCENDING]
  def decode_order_to_mongo(param)
    field, reverse = decode_order_to_array(param)
    [[field, reverse ? Mongo::DESCENDING : Mongo::ASCENDING]]
  end
end
