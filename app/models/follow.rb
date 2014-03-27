class Follow
  if defined?(Mongoid)
    include Mongoid::Document
    include Mongoid::Timestamps

    field :f_type, :type => String
    field :f_id, :type => String
  elsif defined?(MongoMapper)
    include MongoMapper::Document

    key :f_type, :type => String
    key :f_id, :type => String

    timestamps!
  end

  belongs_to :followable, :polymorphic => true
  belongs_to :following, :polymorphic => true

  scope :by_type, lambda { |type| where(:f_type => type.safe_capitalize) }
  scope :by_model, lambda { |model| where(:f_id => model.id.to_s).by_type(model.class.name) }
end