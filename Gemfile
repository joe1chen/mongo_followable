source "http://rubygems.org"

# Specify your gem's dependencies in mongo_followable.gemspec
gemspec

case ENV['MONGOID_VERSION']
  when /4/
    gem "mongoid", :github => 'mongoid/mongoid'
  when /3/
    gem "mongoid", "~> 3.1"
  when /2/
    gem "mongoid", "~> 2.8"
end

case ENV['MONGO_MAPPER_VERSION']
  when /0.12/
    gem "mongo_mapper", "~> 0.12"
end