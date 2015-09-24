# encoding: utf-8
class Snapshot
  include Mongoid::Document
  include Mongoid::Timestamps

  field :time, type: Float
  # elemeng of key_point is a hash, keys include
  # => position: array with length 2, first is x and second is y
  # => desc: description for this key point
  field :key_point, type: Array, default: [ ]

  belongs_to :video
  belongs_to :question


  def delete_tags
    v = self.video
    tags = v.tags.select { |e| e["snapshot_id"].blank? || e["snapshot_id"] != self.id.to_s }
    v.tags = tags
    v.save
  end

  def info_for_tablet
    {
      server_id: self.id.to_s,
      time: self.time,
      key_point: self.key_point.map { |e| e["position"].join(",") + "," + e["desc"] } .join(";")
      video_id: self.video.id.to_s
    }
  end
end
