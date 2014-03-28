require 'mongo_followable/core_ext/util'

class Follow
  if defined?(Mongoid)
    include Mongoid::Document
    include Mongoid::Timestamps
  elsif defined?(MongoMapper)
    include MongoMapper::Document
    timestamps!
  end

  if defined?(Mongoid)
    belongs_to :followable, :polymorphic => true, index: true
    belongs_to :following, :polymorphic => true, index: true
  else
    belongs_to :followable, :polymorphic => true
    belongs_to :following, :polymorphic => true
  end

  scope :by_followee_type, lambda { |type| where(:followable_type => type.safe_capitalize) }
  scope :by_followee_model, lambda { |model| where(:followable_id => model.id).by_followee_type(model.class.name) }
  scope :by_follower_type, lambda { |type| where(:following_type => type.safe_capitalize) }
  scope :by_follower_model, lambda { |model| where(:following_id => model.id).by_follower_type(model.class.name) }

  if Mongo::Followable.mongoid2?
    index([[ :following_id, Mongo::ASCENDING ],[ :followable_id, Mongo::ASCENDING ],[ :following_type, Mongo::ASCENDING ],[ :followable_type, Mongo::ASCENDING ]], unique: true)
  elsif Mongo::Followable.mongoid3?
    index({ following_id: 1, followable_id: 1, following_type: 1, followable_type: 1 }, { unique: true })
  end
end