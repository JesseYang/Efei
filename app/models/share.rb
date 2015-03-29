# encoding: utf-8
class Share < Node
  include Mongoid::Document
  include Mongoid::Timestamps
  field :editable, type: Boolean, default: true
  belongs_to :sharer, class_name: "User", inverse_of: :shares
  belongs_to :node, class_name: "Node", inverse_of: :shares
  has_many :notes

  def subject
    self.find_node.subject
  end

  def name
    self.find_node.name
  end

  def tag_set
    self.find_node.tag_set
  end

  def find_node
    self.node || Node.unscoped.find(self.node_id)
  end
end
