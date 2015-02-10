# encoding: utf-8
class Resource
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri, type: String
  field :subject, type: Integer
  field :type, type: String
  field :info, type: Array, default: []
  field :content, type: Array, default: []
  field :items, type: Array, default: []
  field :answer, type: Array, default: []
  field :answer_content, type: Array, default: []
  field :status, type: String

  index({ uri: 1 }, { unique: true, name: "uri_index" })

  has_many :questions, class_name: "Resource", inverse_of: :structure
  belongs_to :structure, class_name: "Resource", inverse_of: :questions

end
