xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  City.each do |city|
    Industry.each do |industry|
      xml.url {
        xml.loc absolute_url(:vacancies, :index, city: city.code, industry: industry.code)
        xml.changefreq 'daily'
      }
    end
  end
end
