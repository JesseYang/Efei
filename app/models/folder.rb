# encoding: utf-8
class Folder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::Trashable

  field :name, type: String
  has_many :homeworks, class_name: "Homework", inverse_of: :folder
  has_many :children, class_name: "Folder", inverse_of: :parent
  belongs_to :parent, class_name: "Folder", inverse_of: :children
  belongs_to :user, class_name: "User", inverse_of: :folders

end
