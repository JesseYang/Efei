#encoding: utf-8
class Subject
  CHINESE = 1
  MATH = 2
  ENGLISH = 4
  PHYSICS = 8
  CHEMISTRY = 16
  BIOLOGY = 32
  HISTORY = 64
  GEOGRAPHY = 128
  POLITICS = 256
  OTHERS = 512

  NAME = {
    1 => "语文",
    2 => "数学",
    # 4 => "英语",
    8 => "物理"
    # 16 => "化学",
    # 32 => "生物",
    # 64 => "历史",
    # 128 => "地理",
    # 256 => "政治",
    # 512 => "其他"
  }

  CODE = {
    "语文" => 1,
    "数学" => 2,
    # "英语" => 4,
    "物理" => 8
    # "化学" => 16,
    # "生物" => 32,
    # "历史" => 64,
    # "地理" => 128,
    # "政治" => 256,
    # "其他" => 512
  }

  CODE_WITH_ALL = {"全部科目" => 0}.merge(CODE)

  NAME_WITH_ALL = {0 => "全部"}.merge(NAME)
end
