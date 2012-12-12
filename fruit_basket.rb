class FruitBasket
	
	def self.fruits(*fruits)
		fruits.each do |fruit|
      
			define_method("#{fruit}s") {
			  instance_variable_get("@#{fruit}s")
			}
      
			define_method("#{fruit}s=") { |p|
			  instance_variable_set("@#{fruit}s", p)			  
			}
      
    end
	end

end

class SorryBasket < FruitBasket
  
  fruits :lychee, :mango, :mangosteen 
  
  def initialize(a,b,c) 
    @lychees      = a
    @mangos       = b
    @mangosteens  = c
  end
  
end

missed_date_basket = SorryBasket.new(36,6,8)

puts missed_date_basket.lychees
puts missed_date_basket.mangos
puts missed_date_basket.mangosteens

missed_date_basket.mangosteens = 99

missed_date_basket.rambutan = 30
