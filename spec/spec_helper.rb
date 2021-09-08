require "rubygems"
require "bundler/setup"

require "database_cleaner"
require "rspec"

CONFIG = { :authorization => true, :history => true }

if ENV['MONGO_MAPPER_VERSION']
  puts 'MongoMapper'
  require 'mongo_mapper'
  require File.expand_path("../../lib/mongo_followable", __FILE__)
  require File.expand_path("../mongo_mapper/user", __FILE__)
  require File.expand_path("../mongo_mapper/group", __FILE__)
  require File.expand_path("../mongo_mapper/childuser", __FILE__)
  MongoMapper.database = 'mongo_followable_test'
else
  puts 'Mongoid'
  require 'mongoid'
  require File.expand_path("../../lib/mongo_followable", __FILE__)
  require File.expand_path("../mongoid/user", __FILE__)
  require File.expand_path("../mongoid/group", __FILE__)
  require File.expand_path("../mongoid/childuser", __FILE__)

  Mongoid.configure do |config|
    name = "mongo_followable_test"
    config.respond_to?(:connect_to) ? config.connect_to(name) : config.master = Mongo::Connection.new.db(name)
  end
end

RSpec.configure do |c|
  c.before(:all)  { DatabaseCleaner.strategy = :truncation }
  c.before(:each) { DatabaseCleaner.clean }
end
