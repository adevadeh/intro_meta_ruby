class Array

  def hello
    "Hello, I'm an #{self.class.name}!"
  end
  
	
	def foldl(method)
		inject(0) {|res, i| res ? res.send(method, i) : 0}
  end
  
  def first
    self.last
  end
  
end


# begin

a = [1,2,3,4,5,6,7,8,9,10]

puts a.hello      #=> Hello, I'm an Array! 
puts a.foldl('+')  #=> 56
puts a.first      #=> 10

