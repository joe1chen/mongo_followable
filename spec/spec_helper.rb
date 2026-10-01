require "logger"
require "rubygems"
require "bundler/setup"

require "database_cleaner/mongoid"
require "rspec"

CONFIG = { :authorization => true, :history => true }

# Only Mongoid is tested; the MongoMapper code paths in lib/ are legacy and untested.
require 'mongoid'
require File.expand_path("../../lib/mongo_followable", __FILE__)
require File.expand_path("../mongoid/user", __FILE__)
require File.expand_path("../mongoid/group", __FILE__)
require File.expand_path("../mongoid/childuser", __FILE__)

Mongoid.configure do |config|
  config.connect_to("mongo_followable_test")
end
Mongoid.logger.level = Logger::ERROR
Mongo::Logger.logger.level = Logger::ERROR

DatabaseCleaner[:mongoid].strategy = [:deletion]

RSpec.configure do |c|
  # RSpec 3 with the RSpec 2-era `should` syntax still enabled, so the existing specs run unchanged.
  c.expect_with(:rspec) { |e| e.syntax = [:should, :expect] }
  c.mock_with(:rspec) { |m| m.syntax = [:should, :expect] }
  c.before(:each) { DatabaseCleaner.clean }
end
