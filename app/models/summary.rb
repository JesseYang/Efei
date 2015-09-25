# encoding: utf-8
class Summary
  include Mongoid::Document
  include Mongoid::Timestamps

  # key is question id value, value is a hasn which has two keys:
  # => answer
  # => duration
  field :checked, type: Array, default: [ ]

  belongs_to :snapshot, class_name: "Snapshot", inverse_of: :summaries
  belongs_to :student, class_name: "User", inverse_of: :summaries

  def self.create_new(student, snapshot, checked)
    summary = Summary.where(student_id: student.id, snapshot_id: snapshot.id).first ||  Summary.new
    summary.snapshot = snapshot
    summary.student = student
    summary.checked = checked
    summary.save
  end
end
