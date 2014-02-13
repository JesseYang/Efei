#encoding: utf-8
class Paper
  include Mongoid::Document
  include Mongoid::Timestamps
  field :current, type: Boolean, default: true
  field :question_ids, type: Array, default: []
  field :name, type: String, default: "未命名试卷"

  scope :cur, -> { where(current: true) }
  scope :not_cur, -> { where(current: false) }
  belongs_to :user

  def print
    questions = []
    self.question_ids.each do |qid|
      q = Question.find(qid)
      next if q.nil?
      link = "#{MongoidShortener.generate(Rails.application.config.server_host)}"
      questions << {"content" => q.content, "items" => q.items, "link" => link}
    end
    response = HTTParty.post("http://localhost:9292/generate",
      :body => { questions: questions, name: Time.now.strftime("%Y年%m月%d日%H时%M分打印") }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return JSON.parse(response.body)["filename"]
  end

  def archive
    # only current paper can be archived
    return false if !self.current

    user = self.user
    archived_paper = self.clone
    archived_paper.current = false
    archived_paper.save
    user.papers << archived_paper
    self.update_attributes({
      question_ids: [],
      name: "未命名试卷"
    })
  end
end
