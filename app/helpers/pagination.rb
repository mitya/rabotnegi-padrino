Rabotnegi.helpers do
  def pagination(collection, options = {})
    element :div, "pager" do
      page_links(collection, options)
    end if collection.respond_to?(:total_pages) && collection.total_pages > 1
  end

  def page_links_model(collection)
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

  def page_links(collection, options = {})
    links_model = page_links_model(collection)
  
    # params.merge!(options[:params]) if options[:params]
  
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
  
    element :div, "pagination" do
      links
    end
  end
end
