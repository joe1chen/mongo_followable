class User
  include MongoMapper::Document
  include MongoFollowable::Followed
  include MongoFollowable::Follower
  include MongoFollowable::Features::History
end