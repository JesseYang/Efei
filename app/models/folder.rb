# encoding: utf-8
class Folder < Node
  field :is_root, type: Boolean, default: false
  has_many :children, class_name: "Node", inverse_of: :parent
  # has_many :homeworks, class_name: "Homework", inverse_of: :folder, dependent: :destroy
  # has_many :slides, class_name: "Slide", inverse_of: :folder, dependent: :destroy
  # has_many :children, class_name: "Folder", inverse_of: :parent, dependent: :destroy
  # belongs_to :parent, class_name: "Folder", inverse_of: :children
  # belongs_to :user, class_name: "User", inverse_of: :folders

  def self.folder_tree(user, parent_id = nil)
    tree = [ ]
    parent = parent_id.nil? ? user.root_folder : user.folders.find(parent_id)
    tree = {
      id: parent.id.to_s,
      name: parent.name,
      children: []
    }
    collection = parent.children
    collection.each do |n|
      tree[:children] << self.folder_tree(user, n.id) if n._type == "Folder"
    end
    tree
  end

  def ancestor_chain
    self.is_root ? [self] : self.parent.ancestor_chain + [self]
  end

  def touch_ancestor
    self.parent.try :touch_ancestor
    self.touch
  end

  def folder_path
    path = self.parent.try(:folder_path) || []
    path << { id: self.id.to_s, name: self.name }
    path
  end

  def self.create_new(user, name, parent_id = nil)
    f = user.folders.create(name: name)
    parent = parent_id == "root" ? user.root_folder : user.folders.find(parent_id)
    f.update_attribute :parent_id, parent.id
    f
  end

  def last_update_time
    children_time = self.children.map { |e| e.updated_at } .to_a
    time = ( children_time + [self.updated_at] ).max
    time.today? ? time.strftime("%H点%M分") : time.strftime("%Y年%m月%d日")
  end
end
