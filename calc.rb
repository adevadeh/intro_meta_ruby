def calc(left, operator, right)
  raise "unknown operator" unless ['+', '-', '/', '*'].include?(operator)
  left.send(operator,right) 
end

puts calc(1,'+',1)
puts calc(2,'%',3)