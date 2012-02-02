Rabotnegi.helpers do
	def found_objects_info(collection, word, e1, e2, e5)
		if collection.total_pages <= 1
			count = collection.size
			object = Gore::RussianInflector.inflect(collection.size, word, e1, e2, e5)
		else
			object = Gore::RussianInflector.inflect(collection.total_count, word, e1, e2, e5)
		end

		"Найдено <b>#{collection.total_count}</b> #{object}.
		 Показаны <b>#{collection.offset_value + 1}</b> — <b>#{collection.offset_value + collection.limit_value}</b>".html_safe
	end
	
  # <input type=search id=q> <input type=submit value=Поиск>
  def search_tag
    text_field = text_field_tag(:q, value: params[:q], type: "search", id: 'q', :class => "search", autofocus: true)
    text_field + " " + submit_tag("Поиск", name: nil)
  end

  # #search
  #   form
  #     input#q(type=search) 
  #     input(type=submit value=Поиск)
  def search_form(url)
    element :div, "search" do
      form_tag url, method: "get" do
        search_tag
      end
    end
  end
  
  # Render either a list of items with pager, either "no data" message.
  def listing(collection, &block)
    html = if collection.any?
      element(:table, "listing", &block) + pagination(collection)
    else
      element :div, "Ничего не найдено.", "no-data-message"
    end
    html
  end
  
  def sorting_state_class_for(field)
    current_field, reverse = Gore::SortExpressions.decode_order_to_array(params[:sort])
    field.to_s == current_field ? "sorted" : ""
  end    
end
