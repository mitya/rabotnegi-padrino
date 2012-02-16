database_name = case Padrino.env
  when :development then 'rabotnegi_dev'
  when :production  then 'rabotnegi_prod'
  when :test        then 'rabotnegi_test'
  when :testui      then 'rabotnegi_testui'
  when :testprod    then 'rabotnegi_dev'
end

mongoid_options = {}
mongoid_options = {logger: Padrino.logger} if Padrino.env == :development # && ($*.first !~ /^(test|routes)/)

old_log_level, Padrino.logger.level = Padrino.logger.level, Padrino::Logger::Levels[:error]

Mongoid.database = Mongo::Connection.new('localhost', Mongo::Connection::DEFAULT_PORT, mongoid_options).db(database_name)
Mongoid::Config.add_language('ru')

Padrino.logger.level = old_log_level

# You can also configure Mongoid this way
# Mongoid.configure do |config|
#   name = @settings["database"]
#   host = @settings["host"]
#   config.master = Mongo::Connection.new.db(name)
#   config.slaves = [
#     Mongo::Connection.new(host, @settings["slave_one"]["port"], :slave_ok => true).db(name),
#     Mongo::Connection.new(host, @settings["slave_two"]["port"], :slave_ok => true).db(name)
#   ]
# end
