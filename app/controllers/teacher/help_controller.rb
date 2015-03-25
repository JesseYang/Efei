# encoding: utf-8
class Teacher::HelpController < Teacher::ApplicationController

  def index
    @title = "使用指南"
  end

  def quick_guide
    @title = "快速上手指南"
  end

  def homework_manage
    @title = "作业创建及编辑"
  end

  def folder_manage
    @title = "云盘组织及使用"
  end

  def class_manage
    @title = "班级和学生管理"
  end

  def stat_check
    @title = "统计数据查看"
  end
end
