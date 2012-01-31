# vacancy(title, industry = 'it', city = 'spb', other = {})
def vacancy(title, *args)
  other = args.extract_options!
  attrs = {title: title}
  attrs[:industry] = args.first || 'it'
  attrs[:city] = args.second || 'spb'
  attrs[:created_at] = "2011-09-01"
  attrs[:description] = "lorem ipsum sit amet"
  attrs.merge!(other)
  Vacancy.create!(attrs)
end

vacancy "Designer", employer_name: "Apple"
vacancy "Ruby Developer", employer_name: "Apple"
vacancy "Python Developer", employer_name: "Apple"
vacancy "JavaScript Developer", employer_name: "Apple", description: "Do some JS and frontend stuff"
vacancy "Manager", employer_name: "Apple"
vacancy "Tester", employer_name: "Apple"

vacancy "Designer", city: 'msk', employer_name: "Msk Co"
vacancy "Ruby Developer", city: 'msk', employer_name: "Msk Co"

vacancy "Бухгалтер", "retail", employer_name: "Рога и Копыта"
vacancy "Главбух", "retail", employer_name: "Рога и Копыта"
vacancy "Ассистент", "retail", employer_name: "Рога и Копыта"
vacancy "Гендир", "retail", employer_name: "Рога и Копыта"
