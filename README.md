# Introduction to Meta-Programming with Ruby

## About Ruby

[Ruby](http://ruby-lang.org) was created in Japan by a [Yukihiro “matz” Matsumoto](http://en.wikipedia.org/wiki/Yukihiro_Matsumoto), and was released publically in 1995. Matz explains that he wanted to make a language that was human friendly, yet powerful. It is largely based on Smalltalk, with elements of LISP, and the convenience of perl. Matz is an active member of the Ruby community and he often speaks at conferences around the world. He says "I write C code, so you don't have to", referring to the fact that writing code in Ruby is a pleasant experience, and rubyists really appreciate it.

    puts "Hello World!"
    clap_hands if happy?

Ruby got a huge boost in popularity when a young Danish programmer, [David Hanemeier Hannson](https://github.com/dhh), released the [Ruby on Rails](http://rubyonrails.org) framework in 2007. DHH used the inherent power of Ruby to build robust layers of abstraction into the framework, making it very easy to start building complex web applications. Some early users of the platform were [Twitter](http://twitter.com) and [Groupon](http://groupon.com), who used the framework to quickly iterate over designs and features to attract millions of users.

In China there is a vibrant community at [Ruby China](http://ruby-china.org/), and you can even find Ruby in [TaoBao](http://ruby.taobao.org). Here in Guangzhou, you are welcome to join [gzruby - the Guangzhou Ruby Users's Group](http://www.gzruby.org). We meet once every two months to share ideas and have a good time.

Ruby is currently at [version 1.9.3](http://www.ruby-lang.org/en/news/2012/11/09/ruby-1-9-3-p327-is-released/), and this version will be used in the examples here. 

## Meta Programming Basics

Meta-Programming can be defined as: "Code that writes code". 

Ruby is structured so that everything acting within the system is itself an object. The number 5 is an object of class `Fixnum`, and class definitions are instances of the `Class` object. You would normally expect code to be operating on a set of data, and in Ruby this set of data includes much of the language itself.

What this means for Ruby is that you have the power to go into classes at runtime - and redefine them; you can write code that builds its own classes or writes its own methods; you are able to craft intuitive APIs that cleverly hide complexity by providing flexible method names. Of course, this also makes it really easy to make a mistake, create bugs, and write code that no one else can understand.

When used properly, meta-programming can be a great way to build layers of abstraction, to automate tedious coding tasks, and to solve problems in ingenious ways. It's also a lot of fun.

### send

One of the lightest meta-programming techniques is using the send method: `BasicObject#send(method_name)`. 

Rather than calling a method directly like this: 
    
    obj.method(arg) 
    
You can call a method programatically like this: 

    obj.send('method', arg)
    
This allows you to do silly things like:

    def calc(left, operator, right)
      raise "unknown operator" unless ['+', '-', '/', '*'].include?(operator)
      left.send(operator,right)
	end
	
	puts calc 1, '+', 1    #=> 2

The `send` method opens a world to you during runtime, where you can call methods for which you may not even know the name.

### monkey patching

In Ruby, a class definition isn't static. It's an object in memory that can be changed. One easy way to do this is to redefine methods that have already been defined, or to add methods to a class that you might need.

Let's add some methods to Array:

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
    
    a = [1,2,3,4,5,6,7,8,9,10]

    puts a.hello       #=> Hello, I'm an Array! 
    puts a.foldl('+')  #=> 55
    puts a.first       #=> 10 (yikes!!!)
    
As you can see, this is very powerful, and at the same time can be very dangerous.
 
### define_method

As `send` allows you to call methods programatically, the `define_method` method lets to define methods in an existing class at runtime. This method belongs to the `Class` object, so you would call it on an instance of the `Class` object, otherwise known as a class definition.

    class FruitBasket
	
      def self.fruits(*fruits)
	    fruits.each do |fruit|
      
          define_method("#{fruit}s") {
	        instance_variable_get("@#{fruit}s")
		  }
      
		  define_method("#{fruit}s=") { |p|
	        instance_variable_set("@#{fruit}s", p)		  }
      
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
	
	puts missed_date_basket.lychees       #=> 36
	puts missed_date_basket.mangos        #=> 6
	puts missed_date_basket.mangosteens   #=> 8
	
	missed_date_basket.mangosteens = 99
	
	missed_date_basket.rambutan = 30      #=> No Method Error!

    

### method_missing

`TODO`


## Practical Examples

### ruby attr_accessor

### Active Record Relations

### Active Record Find





