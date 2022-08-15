source "http://rubygems.org"

# Specify your gem's dependencies in mongo_followable.gemspec
gemspec

rails_version = ENV['RAILS_VERSION'] || "7.0.3"
gem "rails", "~> #{rails_version}"

mongoid_version = ENV['MONGOID_VERSION'] || "8.0.2"
gem "mongoid", "~> #{mongoid_version}"

case ENV['MONGO_MAPPER_VERSION']
  when /0.12/
    gem "mongo_mapper", "~> 0.12"
end