require 'pry-byebug'

require Bundler.root + 'lib/mongo_mapper/soft_deleted'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = "mm_soft_deleted"

def wipe_db
  MongoMapper.database.collections.each do |c|
    c.remove({}) unless (c.name =~ /system/)
  end
end

RSpec.configure do |config|
  config.before(:each) do
    wipe_db
  end
end
