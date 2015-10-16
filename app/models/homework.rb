# encoding: utf-8
require 'httparty'
class Homework < Node
  # user, exercise, paper
  field :type, type: String, default: "user"
  field :subject, type: Integer
  field :tag_set, type: String, default: "不懂,不会,不对,典型题"
  field :q_ids, type: Array, default: []
  field :q_durations, type: Array, default: { }
  field :q_scores, type: Array, default: { }
  field :q_knowledges, type: Array, default: { }
  ### for "paper" homeworks
  field :materials, type: Array, default: []
  field :year, type: Integer, default: 0
  field :province, type: String, default: ""
  field :paper_type, type: String, default: ""
  field :finished, type: Boolean, default: false
  ###
  # no, now, and later
  field :answer_time_type, type: String, default: "no"
  field :answer_time, type: Integer
  has_and_belongs_to_many :questions, class_name: "Question", inverse_of: :homeworks
  has_many :answers, class_name: "Answer", inverse_of: :homework
  has_one :compose
  has_many :notes
  has_many :tablet_answers, class_name: "TabletAnswer", inverse_of: :exercise
  belongs_to :lesson, class_name: "Lesson", inverse_of: :homework
  belongs_to :lesson_pre_test, class_name: "Lesson", inverse_of: :pre_test
  belongs_to :lesson_exercise, class_name: "Lesson", inverse_of: :exercise
  belongs_to :lesson_post_test, class_name: "Lesson", inverse_of: :post_test

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  def self.create_by_name(name, subject)
    name_ary = name.split('.')
    name = name_ary[0..-2].join('.') if %w{doc docx}.include?(name_ary[-1])
    Homework.create(name: name, subject: subject)
  end

  def self.homeworks_for_select
    hash = { "请选择" => -1 }
    Homework.all.each do |h|
      hash[h.name] = h.id.to_s
    end
    hash
  end

  def questions_in_order
    self.q_ids.map { |e| Question.find(e) }
  end

  def add_question(q)
    self.q_ids << q.id.to_s
    self.questions << q
    self.save
  end

  def add_questions(questions)
    questions.each do |q|
      self.q_ids << q.id.to_s
      self.questions << q
    end
    self.save
  end

  def replace_question(replace_question_id, question)
    self.questions.delete(Question.find(replace_question_id))
    index = self.q_ids.index(replace_question_id)
    self.q_ids[index] = question.id.to_s
    self.save
  end

  def insert_questions(before_question_id, questions)
    index = self.q_ids.index(before_question_id) + 1
    questions.reverse.each do |q|
      self.q_ids.insert(index, q.id.to_s)
      self.questions << q
    end
    self.save
  end

  def delete_question_by_index(index)
    self.q_ids.delete_at(index)
    self.save
  end

  def delete_question_by_id(qid)
    self.q_ids.delete(qid)
    self.save
  end

  def copy(user, folder)
    return if self.type != "user"
    folder_id = folder.user == user ? folder.id : user.root_folder.id
    new_homework = Homework.create(
      name: self.name + "（复件）",
      user_id: user.id,
      parent_id: folder_id,
      type: "user",
      subject: self.subject,
      q_ids: self.q_ids,
      tag_set: self.tag_set,
      answer_time: self.answer_time,
      answer_time_type: self.answer_time_type
    )
    self.questions.each { |q| new_homework.questions << q }
    new_homework.save
    new_homework
  end

  def insert_question(index, q)
    if index != -1
      self.q_ids.insert(index.to_i, q.id.to_s)
    else
      self.q_ids = [q.id.to_s] + self.q_ids
    end
    self.questions << q if !self.questions.include?(q)
  end

  def combine_questions(q_id_1, q_id_2)
    i1 = self.q_ids.index(q_id_1)
    i2 = self.q_ids.index(q_id_2)
    return false if i2 == -1 || i1 == -1 || i2 - i1 != 1
    q1 = Question.find(q_id_1)
    q2 = Question.find(q_id_2)
    cache = q1.cache + q2.cache
    q = Document.extract_one_question(self.subject, cache)
    self.questions.delete(q1)
    self.questions.delete(q2)
    self.questions << q
    self.q_ids.insert(i1, q.id.to_s)
    self.q_ids.delete(q_id_1)
    self.q_ids.delete(q_id_2)
    self.save
    q.id.to_s
  end

  def generate(question_qr_code, app_qr_code, with_number, with_answer, share_id = "")
    questions = []
    doc_id = share_id.present? ? share_id : self.id.to_s
    self.questions_in_order.each do |q|
      link = MongoidShortener.generate("#{doc_id},#{q.id.to_s}")
      question = {"type" => q.type, "image_path" => q.image_path, "content" => q.content, "items" => q.items, "link" => link}
      question.merge!({ "answer" => q.answer || -1, "answer_content" => q.answer_content || [] }) if with_answer
      questions << question
    end
    data = {
      "with_answer" => with_answer,
      "with_number" => with_number,
      "app_qr_code" => app_qr_code,
      "student_portal_url" => Rails.application.config.student_portal_url,
      "questions" => questions,
      "name" => self.name,
      "qrcode_host" => Rails.application.config.server_host,
      "doc_type" => "word",
      "qr_code" => question_qr_code
    }
    response = Homework.post("/Generate.aspx",
      :body => {data: data.to_json} )
    return response.body
  end

  def self.list_all
    self.desc(:updated_at).map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def self.list_recent(amount = 20)
    self.desc(:updated_at).limit(amount).map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def format_answer_time
    if self.answer_time.blank?
      ""
    else
      Time.at(self.answer_time).strftime("%Y-%m-%d")
    end
  end

  def refresh_score
    one_score = 100 / self.q_ids.length
    self.q_ids.each do |qid|
      if self.q_scores[qid].to_i == 0
        self.q_scores[qid] = one_score
      end
    end
    self.save
  end

  def refresh_duration
    self.q_ids.each do |qid|
      next if self.q_durations[qid] != 0
      q = Question.find(qid)
      next if q.video.blank?
      duration = q.video.duration("int")
      minute = duration * 1.0 / 60
      self.q_durations[qid] = [(minute / 2).round, 1].max
    end
    self.save
  end

  def last_update_time
    self.updated_at.today? ? self.updated_at.strftime("%H点%M分") : self.updated_at.strftime("%Y年%m月%d日")
  end

  def self.parse_exam
    Dir["public/papers/*"].each do |path|
      name = path.split("/")[-1]
      # starting with "done" means that the materials has been imported
      # ending with "done" means that the exam has been imported
      next if !name.start_with?("done") || name.end_with?("done")
      f = File.open(path)
      c = f.read
      f.close
      p = Nokogiri::HTML(c)
      h_name = f.path.split("paper_")[-1]
      materials = [ ]
      parts = p.css("#parts")[0]
      parts.children.each do |e|
        text = e.css(".part_header").text
        materials << { type: "text", content: text }
        part_body = e.css(".part_body").first
        q_ele_ary = part_body.xpath("div")
        q_ele_ary.each do |q_ele|
          external_id = q_ele.attr("data-id")
          material = Material.where(external_id: external_id).first
          materials << { type: "id", content: material.id.to_s }
        end
      end
      h = Homework.create(name: h_name, subject: 2, type: "paper", materials: materials)
      new_name = "#{name}_done"
      new_path = ( path.split("/")[0..-2] + [new_name] ).join("/")
      File.rename(path, new_path)
    end
  end

  def import_exam_question
    self.materials.each_with_index do |e, i|
      next if self.q_ids[i].present?
      if e["type"] == "text"
        q = Question.create(type: "text", content: [e["content"]])
        self.q_ids[i] = q.id.to_s
        self.questions << q
        self.save
      else
        m = Material.find(e["content"])
        next if m.dangerous
        # Question.import_material_question(m)
        q = Question.where(external_id: m.external_id).first
        next if q.nil?
        self.q_ids[i] = q.id.to_s
        self.questions << q
        self.save
      end
    end
    if self.q_ids.length == self.materials.length && !self.q_ids.include?(nil)
      self.update_attribute(:finished, true)
    end
  end

  def extract_exam_info
    return if self.type != "paper"
    if self.name.include?("二模") || self.name.include?("一模")
      self.paper_type = "高考模拟"
    else
      self.paper_type = "高考真题"
    end
    %w{2010 2011 2012 2013 2014} .each do |year|
      if self.name.include? year
        self.year = year.to_i
        break
      end
    end
    %w{江西 陕西 重庆 安徽 北京 山东 四川 江苏 广东 辽宁 福建 浙江 上海 天津 湖南 湖北} .each do |province|
      if self.name.include? province
        self.province = province
      end
    end
    self.province = "全国" if self.province.blank?
    self.save
  end

  def info_for_tablet(type)
      info = {
        server_id: self.id.to_s,
        type: type,
        q_ids: self.q_ids.join("__,__"),
        update_at: self.updated_at.to_s,
        questions: [ ]
      }
      self.q_ids.each do |qid|
        q = Question.find(qid)
        info[:questions] << q.info_for_tablet(self)
      end
      info
  end
end
