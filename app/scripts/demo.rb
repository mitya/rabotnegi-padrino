HTML::FullSanitizer.new.sanitize(%{hello <strong>world</strong> and &quot;Apple&quot; and "Google"})

HTML::WhiteListSanitizer.new.sanitize(%{hello <strong>world</strong> and &quot;Apple&quot; and "Google"}, tags: %w(div strong em b i ul ol li p h3 h4 br hr h5), attributes: %w(id class style))


Vacancy.all.pluck(:description).map { |d| d.scan(/<\w+>/) }.flatten.uniq
