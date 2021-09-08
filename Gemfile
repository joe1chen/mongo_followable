source "http://rubygems.org"

# Specify your gem's dependencies in mongo_followable.gemspec
gemspec

rails_version = ENV['RAILS_VERSION'] || "5.2.0"
gem "rails", "~> #{rails_version}"

mongoid_version = ENV['MONGOID_VERSION'] || "6.4.4"
gem "mongoid", "~> #{mongoid_version}"

case ENV['MONGO_MAPPER_VERSION']
  when /0.12/
    gem "mongo_mapper", "~> 0.12"
end