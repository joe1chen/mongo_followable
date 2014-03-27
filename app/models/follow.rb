class Follow
  if defined?(Mongoid)
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :f, polymorphic: true
  elsif defined?(MongoMapper)
    include MongoMapper::Document

    belongs_to :f, polymorphic: true
    timestamps!
  end

  belongs_to :followable, :polymorphic => true
  belongs_to :following, :polymorphic => true

  scope :by_type, lambda { |type| where(:f_type => type.safe_capitalize) }
  scope :by_model, lambda { |model| where(:f_id => model.id).by_type(model.class.name) }
end