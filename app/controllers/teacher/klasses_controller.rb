# encoding: utf-8
class Teacher::KlassesController < Teacher::ApplicationController
  before_filter :ensure_klass, only: [:destroy, :rename]

  def ensure_klass
    begin
      @klass = current_user.classes.find(params[:id])
    rescue
      render_json ErrCode.ret_false(ErrCode::KLASS_NOT_EXIST)
    end
  end

  def index
    @classes = @current_user.classes.asc(:default)
    classes = 
      {
        classes: @classes.select { |e| e.id.to_s != params[:except] } .map do |e|
          {
            id: e.id.to_s,
            name: e.name.to_s
          }
        end
      }
    render_json({ classes: classes })
  end

  def create
    @klass = current_user.create_class(params[:name])
    render_json({ klass: @klass })
  end

  def rename
    render_json @klass.rename(params[:name])
  end

  def destroy
    @klass.clear_students
    @klass.destroy
    render_json
  end
end
