require 'mongo_followable/core_ext/util'

class Follow
  if defined?(Mongoid)
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :f, polymorphic: true, index: true
  elsif defined?(MongoMapper)
    include MongoMapper::Document

    belongs_to :f, polymorphic: true
    timestamps!
  end

  if defined?(Mongoid)
    belongs_to :followable, :polymorphic => true, index: true
    belongs_to :following, :polymorphic => true, index: true
  else
    belongs_to :followable, :polymorphic => true
    belongs_to :following, :polymorphic => true
  end

  if Mongo::Followable.mongoid2?
    index([[ :f_id, Mongo::ASCENDING ],[ :followable_id, Mongo::ASCENDING ]], unique: true)
    index([[ :f_id, Mongo::ASCENDING ],[ :following_id, Mongo::ASCENDING ]], unique: true)
  elsif Mongo::Followable.mongoid3?
    index({ f_id: 1, followable_id: 1 }, { unique: true })
    index({ f_id: 1, following_id: 1 }, { unique: true })
  end

  scope :by_type, lambda { |type| where(:f_type => type.safe_capitalize) }
  scope :by_model, lambda { |model| where(:f_id => model.id).by_type(model.class.name) }
end