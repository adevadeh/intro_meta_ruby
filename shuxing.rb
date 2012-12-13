class Shuxingable

  def self.wo_de_shuxing(*shuxings)
    
    shuxings.each do |shuxing|
    
	    define_method(shuxing) {
	      instance_variable_get("@#{shuxing}")
	    }
      
	    define_method("#{shuxing}=") { |p|
	      instance_variable_set("@#{shuxing}", p)			  
      }
      
    end 
  end
end

class Student < Shuxingable      
  wo_de_shuxing :name, :major, :dorm  
      
  def to_s
    "#{name}学生在学习#{major}，住在#{dorm}"
  end
end

tai       = Student.new
tai.name  = "太漂亮"
tai.dorm  = "东区Q座3楼409房"
tai.major = "计算机科学"
    
puts tai.inspect
puts tai