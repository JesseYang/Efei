#encoding: utf-8
class DefaultTag
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

  TAG = {
    # 语文
    Subject::CHINESE => [],
    # 数学
    Subject::MATH => [
      "不懂,不会,不对,典型题",
      "审题不清,概念错误,未掌握方法,计算错误"
    ],
    # 英语
    Subject::ENGLISH => [],
    # 物理
    Subject::PHYSICS => [],
    # 化学
    Subject::CHEMISTRY => [],
    # 生物
    Subject::BIOLOGY => [],
    # 历史
    Subject::HISTORY => [],
    # 地理
    Subject::GEOGRAPHY => [],
    # 政治
    Subject::POLITICS => [],
    # 其他
    Subject::OTHERS => []
  }
end
