# coding: utf-8

RECORD_COUNT = 1000

mysql = Mysql2::Client.new(host: "localhost", username: "root", database: "rabotnegi_dev")
query = "SELECT `vacancies`.* FROM `vacancies` LIMIT #{RECORD_COUNT}"

p_ar = -> do
  results = Vacancy.limit(RECORD_COUNT).all[1]
end

p_select_rows = -> do
  Vacancy.connection.select_rows(query)[1]
end

p_select_all = -> do
  Vacancy.connection.select_all(query)[1]
end

p_mysql_2 = -> do
  results = []
  mysql.query(query).each { |x| results << x }
  results
end

Vacancy.uncached do
  Vacancy.limit(5).all

  Benchmark.bm(20) do |b|
    Mu.logger.debug "---------------------------------------"

    b.report("p_ar", &p_ar)
    b.report("p_select_rows", &p_select_rows)
    b.report("p_select_all", &p_select_all)
    b.report("p_mysql_2", &p_mysql_2)
  end
end
