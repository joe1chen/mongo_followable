class Group
  include Mongoid::Document
  include MongoFollowable::Followed
  include MongoFollowable::Features::History
end