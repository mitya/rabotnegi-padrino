database_name = case Padrino.env
  when :development then 'rabotnegi_dev'
  when :production  then 'rabotnegi_prod'
  when :test        then 'rabotnegi_test'
  when :testui      then 'rabotnegi_testui'
  when :testprod    then 'rabotnegi_dev'
end

mongoid_options = {}
mongoid_options = {logger: Padrino.logger} if Padrino.env == :development && ($*.first !~ /^test/)
Mongoid.database = Mongo::Connection.new('localhost', Mongo::Connection::DEFAULT_PORT, mongoid_options).db(database_name)

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
