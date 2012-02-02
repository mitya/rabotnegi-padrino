Rabotnegi.helpers do
  include Gore::AdvAttrAccessor
  adv_attr_accessor :page_id, :page_title, :page_class

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
  
  # window title - <title>
  # (nil) => "Работнеги.ру"
  # ("Вакансии") => "Вакансии - Работнеги.ру"
  # ("Строители", "Вакансии") => "Строители - Вакансии - Работнеги.ру"
  # ("Строители", " ", "Вакансии") => "Строители - Вакансии - Работнеги.ру"
	def window_title
	  [@page_title, "Работнеги.ру"].flatten.reject(&:blank?).join(' - ')
	end
	
  # a title that is shown on the page - <h1>
	def content_title
    @page_title
	end
	
	def meta(name, content)
  	@meta_properties ||= {}
  	@meta_properties[name] = content
	end
	
	def meta_properties
  	@meta_properties || {}
	end
end
