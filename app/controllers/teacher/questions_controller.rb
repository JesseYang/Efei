# encoding: utf-8
class Teacher::QuestionsController < Teacher::ApplicationController
  def point_list
    p = Point.find(params[:point_id])
    @questions = auto_paginate_ajax(p.questions, params[:page].to_i || 1, 10)
    render_json questions: @questions and return
  end

  def index
    @type = %w{tongbu zhuanxiang zonghe} .include?(params[:type]) ? params[:type] : "tongbu"
    if @type == "tongbu"
      @editions = Structure.editions
      @current_edition = Structure.default_edition(cookies[:edition_id])
      @books = @current_edition.books
      @current_book = @current_edition.default_book(cookies[:book_id])
    elsif @type == "zhuanxiang"
      @root_points = Point.points(0)
      @current_point = Point.where(id: params[:point_id]).first || @root_points[0]
      @current_root_point = @current_point.root_point
      @search_questions = @current_point.questions
      @question_type = %w{ all choice blank analysis } .include?(params[:question_type].to_s) ? params[:question_type].to_s : "all"
      @difficulty = %w{ -1 0 1 2 }.include?(params[:difficulty]) ? params[:difficulty].to_i : -1
      @search_questions = @search_questions.where(type: @question_type) if @question_type != "all"
      @search_questions = @search_questions.where(difficulty: @difficulty.to_i) if @difficulty != -1
      @questions = auto_paginate @search_questions
    else
    end
  end

  def update
    @question = Question.find(params[:id])
    @question.update_content(params[:question_content], params[:question_answer])
    if @question.type == "choice"
      @question.update_items(params[:items])
      @question.update_attributes(answer: params[:answer].to_i)
    end
    respond_to do |format|
      format.html
      format.json do
        render json: {
          success: true,
          content_for_show: render_to_string(:partial => 'partials/question_content', :layout => false, :locals => {:content => @question.content}),
          content_for_edit: @question.content.render_question_for_edit,
          answer_for_show: render_to_string(:partial => 'partials/question_content', :layout => false, :locals => {:content => @question.answer_content}),
          answer_for_edit: @question.answer_content.render_question_for_edit,
          items_for_show: @question.items.map { |e| e.render_question },
          items_for_edit: @question.items.map { |e| e.render_question_for_edit },
          answer: @question.answer
        }
      end
    end
  end

  def destroy
    question = Question.where(id: params[:id]).first
    question.homework.delete_question_by_id(params[:id])
    flash[:notice] = "删除题目成功"
    redirect_to teacher_homework_path(question.homework)
  end

  def ensure_qr_code
    q = Question.find(params[:id])
    respond_to do |format|
      format.json do
        render json: { qr_code: q.generate_qr_code }
      end
    end
  end

  def show
    question = Question.where(id: params[:id]).first
    download_url = "#{Rails.application.config.word_host}/#{question.generate}"
    redirect_to URI.encode download_url
  end

  def replace
    q = Question.where(id: params[:id]).first
    h = q.homework
    index =  h.q_ids.index(q.id.to_s)
    if index != -1
      document = Document.new
      document.document = params[:file]
      document.store_document!
      document.name = params[:file].original_filename
      new_q = document.parse_one_question(params[:subject].to_i)
      h.q_ids[index] = new_q.id.to_s
      h.questions << new_q
      h.save
      flash[:notice] = "替换题目成功"
    end
    redirect_to teacher_homework_path(h) and return
  end

  def export
    @question = Question.find(params[:id])
    redirect_to URI.encode Rails.application.config.word_host + "/#{@question.generate}"
  end

  def insert
    q = Question.where(id: params[:id]).first
    h = q.homework
    index =  h.q_ids.index(q.id.to_s)
    if index != -1
      document = Document.new
      document.document = params[:file]
      document.store_document!
      document.name = params[:file].original_filename
      new_qs = document.parse_multiple_questions(params[:subject].to_i)
      new_qs.reverse.each do |new_q|
        h.questions << new_q
        h.q_ids.insert(index + 1, new_q.id.to_s)
      end
      h.save
      flash[:notice] = "插入#{new_qs.length}道题目"
    end
    redirect_to teacher_homework_path(q.homework) and return
  end

  def stat
    qid = Question.find(params[:id])
    notes = []
    if params[:analyze_type] == "compare"
      params[:class_id].split(',').each do |cid|
        if cid == "-1"
          students = current_user.classes.map { |e| e.students } .flatten .uniq
        else
          klass = current_user.classes.find(cid)
          students = klass.students
        end
        temp_notes = []
        students.each do |s|
          n = s.notes.where(question_id: qid).first
          temp_notes << n if n.present?
        end
        notes << temp_notes
      end
    else
      if params[:class_id] = "-1"
        students = current_user.classes.map { |e| e.students } .flatten .uniq
      else
        klass = current_user.classes.find(params[:class_id])
        students = klass.students
      end
      students.each do |s|
        n = s.notes.where(question_id: qid).first
        notes << n if n.present?
      end
    end
    case params[:target]
    when "tag"
      if params[:analyze_type] == "single"
        categories = [ ]
        data = [ ]
        students = [ ]
        notes.each do |n|
          categories << n.tag if !categories.include? n.tag
          index = categories.index(n.tag)
          data[index] ||= 0
          data[index] += 1
          students[index] ||= []
          students[index] << n.user.name
        end
        students.map! { |e| e.join(", ") }
        render_json({
          categories: ["不懂", "不会", "不对", "典型题"],
          series: [
            {
              name: "选择人数",
              data:[10, 8, 2, 4]
            }
          ],
          students: ["白玉芬, 仓春莲, 仓红, 陈超云, 陈高, 陈国祥, 陈宏柳, 陈金娣, 陈丽丽, 陈平",
            "袁刚, 章丽丽, 张德梅, 张芳, 张红芳, 张珊珊, 赵勇, 赵哲明",
            "卞红巧, 蔡坤",
            "郑永军, 周风, 周娟娟, 周鹿屏"]
        }) and return
=begin
        render_json({
          categories: categories,
          data: data,
          students: students
        }) and return
=end
      else
        render_json({
          categories: ["不懂", "不会", "不对", "典型题"],
          series: [
            {
              name: "高一（1)班",
              data: [4, 2, 6, 2]
            },
            {
              name: "高一（2)班",
              data: [5, 7, 8, 4]
            }
          ],
          students: ["白玉芬, 仓春莲, 仓红, 陈超云, 陈高, 陈国祥, 陈宏柳, 陈金娣, 陈丽丽, 陈平",
            "袁刚, 章丽丽, 张德梅, 张芳, 张红芳, 张珊珊, 赵勇, 赵哲明",
            "卞红巧, 蔡坤",
            "郑永军, 周风, 周娟娟, 周鹿屏"]
        }) and return
      end
    when "topic"
      if params[:analyze_type] == "single"
        categories = [ ]
        data = [ ]
        students = [ ]
        notes.each do |n|
          n.topic_str.split(',').each do |t|
            categories << t if !categories.include? t
            index = categories.index(t)
            data[index] ||= 0
            data[index] += 1
            students[index] ||= []
            students[index] << n.user.name
          end
        end
        students.map! { |e| e.join(", ") }
        render_json({
          categories: ["三角函数", "辅助角公式", "诱导公式"],
          series: [
            {
              name: "选择人数",
              data:[10, 8, 2, 4]
            }
          ],
          students: ["陈金娣, 陈丽丽, 陈平",
            "袁刚, 章丽丽, 卞红巧, 白玉芬, 仓春莲, 仓红, 陈超云, 陈高, 陈国祥, 陈宏柳, 张德梅, 张芳, 张红芳, 张珊珊, 赵勇, 赵哲明",
            "郑永军, 周风, 周娟娟, 周鹿屏, 蔡坤"]
        }) and return
=begin
        render_json({
          categories: categories,
          data: data,
          students: students
        }) and return
=end
      else
        render_json({
          categories: ["三角函数", "辅助角公式", "诱导公式"],
          series: [
            {
              name: "高一（1)班",
              data: [4, 4, 6]
            },
            {
              name: "高一（2)班",
              data: [5, 9, 10]
            }
          ],
          students: ["陈金娣, 陈丽丽, 陈平",
            "袁刚, 章丽丽, 卞红巧, 白玉芬, 仓春莲, 仓红, 陈超云, 陈高, 陈国祥, 陈宏柳, 张德梅, 张芳, 张红芳, 张珊珊, 赵勇, 赵哲明",
            "郑永军, 周风, 周娟娟, 周鹿屏, 蔡坤"]
        }) and return
      end
    when "summary"
      summary = [ ]
      notes.each do |n|
        summary << { student_id: n.user.id.to_s, student_name: n.user.name, summary: n.summary }
      end
=begin
      render_json({
        summary: summary
      }) and return
=end
      render_json({
        summary: [
          { student_id: "", student_name: "陈金娣", summary: "诱导公式背错了"},
          { student_id: "", student_name: "陈丽丽", summary: "没有想起用辅助角公式"},
          { student_id: "", student_name: "陈平", summary: ""},
          { student_id: "", student_name: "章丽丽", summary: ""},
          { student_id: "", student_name: "袁刚", summary: "辅助角公式提公因子计算错误"},
          { student_id: "", student_name: "卞红巧", summary: ""},
          { student_id: "", student_name: "白玉芬", summary: "三角函数掌握不牢固"},
          { student_id: "", student_name: "仓春莲", summary: "诱导公式没记住"},
          { student_id: "", student_name: "仓红", summary: ""},
          { student_id: "", student_name: "陈超云", summary: ""},
          { student_id: "", student_name: "陈高", summary: "没有想起用诱导公式"},
          { student_id: "", student_name: "陈国祥", summary: "万能公式"},
          { student_id: "", student_name: "陈宏柳", summary: "三角函数不扎实"},
          { student_id: "", student_name: "张德梅", summary: ""},
          { student_id: "", student_name: "张芳", summary: "诱导公式白学了"},
          { student_id: "", student_name: "张红芳", summary: "计算错误"},
          { student_id: "", student_name: "张珊珊", summary: "审题不清楚，直接看错题目了"},
          { student_id: "", student_name: "赵勇", summary: "没时间了做不完了"},
          { student_id: "", student_name: "赵哲明", summary: "算错了..."},
          { student_id: "", student_name: "郑永军", summary: "诱导公式"},
          { student_id: "", student_name: "周风", summary: ""},
          { student_id: "", student_name: "周娟娟", summary: "错得很不应该"},
          { student_id: "", student_name: "周鹿屏", summary: "不扎实，完全没有思路"},
          { student_id: "", student_name: "蔡坤", summary: ""}
        ]
      }) and return
    end
  end
end
