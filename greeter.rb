class Greeter
  attr_reader :salutation
  
  def initialize(sal)
    @salutation = sal
  end
    
  def method_missing(method_name)
    super unless method_name.to_s =~ /^hello_(.+)$/
    puts "#{salutation} #{$1}!"
  end
      
end

chinese = Greeter.new("你好")
chinese.hello_jim

swahili = Greeter.new("Habari")
swahili.hello_paul

chinese.goodbye_tim