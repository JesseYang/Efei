# encoding: utf-8
module UserComponents::SchoolAdmin
  extend ActiveSupport::Concern

  included do
    field :school_admin, type: Boolean, default: false
  end

  module ClassMethods
    def batch_create_teacher(user, csv_str)
      CSV.generate do |re_csv|
        CSV.parse(csv_str, :headers => true) do |row|
          if User.where(email: row[2]).present?
            re_csv << [row[0], row[1], row[2], row[3], "邮箱已存在"]
            next
          end
          if Subject::CODE[row[0]].nil?
            re_csv << [row[0], row[1], row[2], row[3], "不存在#{row[0]}学科（支持学科包括：语文，数学，英语，物理，化学，生物，历史，政治，其他 ）"]
            next
          end
          t = User.new(name: row[1], email: row[2], subject: Subject::CODE[row[0]], password: row[3])
          t.school = user.school
          t.save(validate: false)
          re_csv << [row[0], row[1], row[2], row[3], "添加成功"]
        end
      end
    end
  end
end