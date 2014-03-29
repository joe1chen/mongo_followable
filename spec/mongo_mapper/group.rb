class Group
  include MongoMapper::Document
  include MongoFollowable::Followed
  include MongoFollowable::Features::History
end