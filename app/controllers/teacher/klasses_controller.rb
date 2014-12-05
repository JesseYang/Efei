# encoding: utf-8
class Teacher::KlassesController < Teacher::ApplicationController
  before_filter :ensure_klass, only: [:destroy, :rename]

  def ensure_klass
    begin
      @klass = current_user.klasses.find(params[:id])
    rescue
      render_json ErrCode.ret_false(ErrCode::KLASS_NOT_EXIST)
    end
  end

  def create
    @klass = current_user.create_class(params[:name])
    render_json({ klass: @klass })
  end

  def rename
    render_json @klass.rename(params[:name])
  end

  def destroy
    
  end
end
