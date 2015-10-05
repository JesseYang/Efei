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

  def list
    if params[:check] == "true"
      @materials = Material.where(check: true)
    else
      @materials = Material.where(dangerous: true)
    end
  end

  def show
    @type = params[:type]
    @preview = params[:preview]
    @material = Material.find(params[:id])
  end

  def upload
  end

  def upload_image
    material_image = MaterialImage.new
    material_image.material_image = params[:image_file]
    filetype = params[:image_file].original_filename.split(".")[-1]
    material_image.store_material_image!
    redirect_to action: :upload, filename: material_image.material_image.file.file
  end

  def confirm
    @material = Material.find(params[:id])
    @material.content_old = @material.content
    @material.items_old = @material.items
    @material.answer_old = @material.answer
    @material.answer_content_old = @material.answer_content

    @material.content = @material.content_preview
    @material.items = @material.items_preview
    @material.answer = @material.answer_preview
    @material.answer_content = @material.answer_content_preview

    @material.dangerous = false

    @material.save

    redirect_to teacher_material_path(id: @material.id.to_s) and return
  end

  def recover
    @material = Material.find(params[:id])
    @material.content = @material.content_old
    @material.items = @material.items_old
    @material.answer = @material.answer_old
    @material.answer_content = @material.answer_content_old

    @material.content_old = []

    @material.dangerous = true

    @material.save
    
    redirect_to teacher_material_path(id: @material.id.to_s) and return
  end

  def update
    @material = Material.find(params[:id])
    @material.content_preview = params[:content].split("\r\n")
    @material.answer_preview = params[:answer].split("\r\n")
    @material.answer_content_preview = params[:answer_content].split("\r\n")
    if @material.items.present? && @material.items[0].present?
      @material.items_preview = [params[:items_0].split("\r\n"),
        params[:items_1].split("\r\n"),
        params[:items_2].split("\r\n"),
        params[:items_3].split("\r\n")]
    end
    @material.save
    redirect_to teacher_material_path(id: @material.id.to_s, preview: true) and return
  end
end
