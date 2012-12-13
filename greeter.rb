
class Greeter
  attr_reader :salutation
  
  def initialize(sal)
    @salutation = sal
  end
    
  def method_missing(method_name)
    if method_name.to_s =~ /^hello_(.+)$/
      
      puts "#{salutation} #{$1}!"
      
    else
      super # important!
    end
  end
      
end

chinese = Greeter.new("你好")
chinese.hello_jim

swahili = Greeter.new("Habari")
swahili.hello_paul

chinese.goodbye_tim