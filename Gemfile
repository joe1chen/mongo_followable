source "https://rubygems.org"

# Specify your gem's dependencies in mongo_followable.gemspec
gemspec

# CI matrix (see .github/workflows/test.yml): MONGOID_VERSION / RAILS_VERSION select versions.
# Defaults are what production (dogo-web) runs today.
rails_version = ENV['RAILS_VERSION'] || "6.1"
gem "rails", "~> #{rails_version}.0"

mongoid_version = ENV['MONGOID_VERSION'] || "7.5"
gem "mongoid", "~> #{mongoid_version}.0"

# ActiveSupport < 7.1 breaks with concurrent-ruby >= 1.3.5 (Logger no longer preloaded).
gem "concurrent-ruby", "< 1.3.5" if Gem::Version.new(rails_version) < Gem::Version.new("7.1")
