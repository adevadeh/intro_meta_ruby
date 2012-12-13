class Student
  attr_accessor :name, :major, :dorm  
      
  def to_s
    "#{name}学生在学习#{major}，住在#{dorm}"
  end
end
    
hao       = Student.new
hao.name  = "好朋友"
hao.dorm  = "西区C座9楼304房"
hao.major = "计算机科学"
    
puts hao.inspect
puts hao