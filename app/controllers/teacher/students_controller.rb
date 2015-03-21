# encoding: utf-8
class Teacher::StudentsController < Teacher::ApplicationController

  before_filter :ensure_student, only: [:move, :copy, :destroy]

  def ensure_student
    begin
      @klass = current_user.classes.find(params[:class_id])
      @student = @klass.students.find(params[:id])
    rescue
      render_json ErrCode.ret_false(ErrCode::STUDENT_NOT_EXIST)
    end
  end

  def index
    current_user.ensure_default_class
    @classes = @current_user.classes.asc(:default)
    @cid = params[:cid]
    @keyword = params[:keyword].to_s.strip
  end

  def show
    @student = User.find(params[:id])
    @notes = @student.notes.where(subject: current_user.subject)
    @subject = Subject::NAME[current_user.subject]
  end

  def stat
    @student = User.find(params[:id])
    @notes = @student.notes.where(subject: current_user.subject)
    @subject = Subject::NAME[current_user.subject]
    tag_categories = [ ]
    tag_series_data = [ ]
    topic_categories = [ ]
    topic_series_data = [ ]
    @notes.each do |n|
      tag_categories << n.tag if !tag_categories.include? n.tag
      index = tag_categories.index(n.tag)
      tag_series_data[index] ||= 0
      tag_series_data[index] += 1
      n.topic_str.split(',').each do |t|
        topic_categories << t if !topic_categories.include? t
        index = topic_categories.index(t)
        topic_series_data[index] ||= 0
        topic_series_data[index] += 1
      end
    end
    i = tag_categories.index("")
    if i != -1
      tag_categories.delete("")
      tag_categories << "未选择标签"
      d = tag_series_data.delete_at(i)
      tag_series_data << d
    end
    if topic_categories.length > 8
      topic_categories = topic_categories[0..6] + ["其他"]
      topic_series_data = topic_series_data[0..6] + [topic_series_data[7..-1].sum]
    end
=begin
    # demo data
    @tag_stat = {
      tag_categories: ["不懂", "不会", "不对", "典型题"],
      tag_series: [
        name: "题目数量",
        data: [13, 2, 5, 10]
      ]
    }
    @topic_stat = {
      topic_categories: ["函数", "导数", "立体几何"],
      topic_series: [
        name: "题目数量",
        data: [15, 8, 20]
      ]
    }
=end
    @tag_stat = {
      tag_categories: tag_categories,
      tag_series: [
        name: "题目数量",
        data: tag_series_data
      ]
    }
    @topic_stat = {
      topic_categories: topic_categories,
      topic_series: [
        name: "题目数量",
        data: topic_series_data
      ]
    }
    render_json({tag_stat: @tag_stat, topic_stat: @topic_stat}) and return
  end

  def list
    current_user.ensure_default_class
    @klass = current_user.classes.where(id: params[:cid]).first
    k = params[:keyword]
    @students = [ ]
    if @klass.present?
      @klass.students.each do |s|
        @students << {
          id: s.id.to_s,
          name: s.name.to_s,
          email: s.email,
          mobile: s.mobile,
          class_id: @klass.id.to_s,
          class_name: @klass.name.to_s
        }
      end
      students_summary = { class_name: @klass.name }
    elsif k.present?
      current_user.classes.each do |c|
        c.students.each do |s|
          @students << {
            id: s.id.to_s,
            name: s.name.to_s,
            email: s.email,
            mobile: s.mobile,
            class_id: c.id.to_s,
            class_name: c.name.to_s
          } if s.name.include?(k) || s.email.include?(k) || s.mobile.include?(k)
        end
      end
      students_summary = { class_name: "搜索结果" }
    else
      current_user.classes.each do |c|
        c.students.each do |s|
          @students << {
            id: s.id.to_s,
            name: s.name.to_s,
            email: s.email,
            mobile: s.mobile,
            class_id: c.id.to_s,
            class_name: c.name.to_s
          }
        end
      end
      students_summary = { class_name: "所有学生" }
    end
    students_summary[:students_number] = @students.length
    students_table = {
      students_number: @students.length,
      students: @students
    }
    render_json({students_summary: students_summary, students_table: students_table})
  end

  def move
    @student.move_to(@klass, params[:new_class_id])
    render_json
  end

  def copy
    @student.copy_to(params[:new_class_id])
    render_json
  end

  def destroy
    @student.delete_from_class(@klass)
    render_json
  end
end
