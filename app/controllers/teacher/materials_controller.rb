# encoding: utf-8
class Teacher::MaterialsController < Teacher::ApplicationController

  def index
    @list = ["集合", "命题与逻辑", "函数", "三角", "平面向量", "数列", "不等式", "微积分初步", "复数", "解析几何", "立体几何", "算法与框图", "统计", "概率", "计数", "矩阵与行列式初步", "选修4系列"]
    @category = params[:category].to_s
    @category = "" if !@list.include?(@category)
    if @category.present?
      @materials = Material.where(category: @category).asc(:created_at)
    end
  end

  def show
    @material = Material.find(params[:id])
  end
end
