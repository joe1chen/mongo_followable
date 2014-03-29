class ChildUser
  include Mongoid::Document
  include MongoFollowable::Followed
  include MongoFollowable::Follower
  include MongoFollowable::Features::History
end