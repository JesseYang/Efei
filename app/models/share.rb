# encoding: utf-8
class Share < Node
  include Mongoid::Document
  include Mongoid::Timestamps
  field :editable, type: Boolean, default: true
  belongs_to :sharer, class_name: "User", inverse_of: :shares
  belongs_to :node, class_name: "Node", inverse_of: :shares
  has_many :notes

  def subject
  	self.node.subject
  end

  def name
  	self.node.name
  end
end
