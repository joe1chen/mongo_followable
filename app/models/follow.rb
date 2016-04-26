require 'mongo_followable/core_ext/util'
require 'mongoid_magic_counter_cache'

class Follow
  if defined?(Mongoid)
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::MagicCounterCache
  elsif defined?(MongoMapper)
    include MongoMapper::Document
    timestamps!
  end

  if defined?(Mongoid)
    belongs_to :followable, :polymorphic => true, index: true
    counter_cache :followable, field: 'followers_cached_count'

    belongs_to :following, :polymorphic => true, index: true
    counter_cache :following, field: 'followees_cached_count'
  else
    belongs_to :followable, :polymorphic => true
    belongs_to :following, :polymorphic => true
  end

  scope :by_followee_type, lambda { |type| where(:followable_type => type.safe_capitalize) }
  scope :by_followee_model, lambda { |model| where(:followable_id => model.id).by_followee_type(model.class.name) }
  scope :by_follower_type, lambda { |type| where(:following_type => type.safe_capitalize) }
  scope :by_follower_model, lambda { |model| where(:following_id => model.id).by_follower_type(model.class.name) }

  validates_presence_of :followable
  validates_presence_of :following

  field :fixed_ts

  if Mongo::Followable.mongoid2?
    index([[ :following_id, Mongo::ASCENDING ],[ :followable_id, Mongo::ASCENDING ],[ :following_type, Mongo::ASCENDING ],[ :followable_type, Mongo::ASCENDING ]], unique: true)
    index([[ :followable_id, Mongo::ASCENDING ],[ :following_type, Mongo::ASCENDING ],[ :created_at, Mongo::ASCENDING ]])
  else
    index({ following_id: 1, followable_id: 1, following_type: 1, followable_type: 1 }, { unique: true })
    index({ followable_id: 1, following_type: 1, created_at: 1 })
  end
end