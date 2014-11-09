# encoding: utf-8
class Teacher::QuestionsController < Teacher::ApplicationController
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
    q = Question.find(params[:id])
    students = {}
    note_type = [[], [], [], []]
    note_topic = { }
    summary = []
    q.notes.each do |e|
      stu = e.user
      next if !current_user.has_student?(stu)
      students[stu.id.to_s] = stu.name
      note_type[e.note_type-1] << stu
      e.topics.each do |t|
        note_topic[t.name] ||= []
        note_topic[t.name] << stu
      end
      summary << stu.name + ": " + e.summary
    end
    respond_to do |format|
      format.html
      format.json do
        render json: {
          students: students,
          note_type: note_type.map { |students| students.map { |e| e.name } .join(',') },
          note_type_data: note_type.map { |e| e.length },
          note_type_ary: ["不懂", "不会", "不对", "典型题"],
          note_topic: note_topic.values.map { |students| students.map { |e| e.name } .join(',') },
          note_topic_data: note_topic.values.map { |e| e.length },
          note_topic_ary: note_topic.keys,
          summary: summary.join("\n")
        }
      end
    end
  end
end
