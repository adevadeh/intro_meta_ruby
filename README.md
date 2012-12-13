# Introduction to Meta-Programming with Ruby

## About Ruby

[Ruby](http://ruby-lang.org) was created in Japan by a [Yukihiro “matz” Matsumoto](http://en.wikipedia.org/wiki/Yukihiro_Matsumoto), and was released publically in 1995. Matz explains that he wanted to make a language that was human friendly, yet powerful. It is largely based on Smalltalk, with elements of LISP and the convenience of perl. Matz is an active member of the Ruby community and he often speaks at conferences around the world. He says "I write C code, so you don't have to", referring to the fact that writing code in Ruby is a pleasant experience, and rubyists really appreciate it.

    puts "Hello World!"
    self.clap_hands if self.happy?
    5.times { jump_for_joy! }

Ruby got a boost in popularity when a young Danish programmer, [David Hanemeier Hannson](https://github.com/dhh), released the [Ruby on Rails](http://rubyonrails.org) framework in 2005. DHH used the inherent power of Ruby to build robust layers of abstraction into the framework, making it very easy to start building complex web applications. Some early users of the platform were [Twitter](http://twitter.com) and [Groupon](http://groupon.com), who used the framework to quickly iterate over designs and features, attracting millions of users.

In China there is a vibrant community at [Ruby China](http://ruby-china.org/), and you can even find Ruby in [TaoBao](http://ruby.taobao.org). Here in Guangzhou, you are welcome to join [gzruby - the Guangzhou Ruby Users's Group](http://www.gzruby.org). We meet once every two months to share ideas and have a good time.

Ruby is currently at [version 1.9.3](http://www.ruby-lang.org/en/news/2012/11/09/ruby-1-9-3-p327-is-released/), and this version will be used in the examples here. 

## Meta Programming Basics

Meta-Programming can be defined as: "Code that writes code". That is to say, rather than a human writing code that processes data, the human writes code that processes the code itself.

Ruby is structured so that everything acting within the system is itself an object. The number 5 is an object of class `Fixnum`, and class definitions are instances of the `Class` object. In Ruby you can easily write code that operates on these objects, meaning you are operating on the language itself.

What this means is that you have the power to go into classes at runtime - and redefine them. You can write code that builds its own classes or writes its own methods and you are able to craft intuitive APIs that cleverly hide complexity by providing flexible method names. Of course, this also makes it really easy to make a mistake, create bugs, and write code that no one else can understand.

When used properly, meta-programming can be a great way to build layers of abstraction or to automate tedious coding tasks. As a programmer, it gives you new tools to solve problems in ingenious ways. It's also a lot of fun.

### send()

One of the lightest meta-programming techniques is using the `send()` method. Rather than calling a method directly like this: 
    
    obj.method(arg) 
    student.add_class("Introduction to Ruby")
    
You can call a method programatically like this: 

    obj.send('method', arg)
    student.send("add_class", "Introduction to Ruby")
    
This allows you to do interesting things like:

    def calc(left, operator, right)
      raise "unknown operator" unless ['+', '-', '/', '*'].include?(operator)
      left.send(operator,right)
	end
	calc 1, '+', 1    #=> 2

The `send` method opens a world to you during runtime, where you can call methods for which you may not even know the name.

### monkey patching

In Ruby, a class definition isn't static. It's an object in memory that can be changed. You can do this is by redefining methods that have already been defined, or by adding methods to a class that you think you will need.

Let's add some methods to Array:

    class Array
      def hello
        "Hello, I'm an #{self.class.name}!"
      end
	  def foldl(method)
	    inject(0) { |result, element| 
	      result ? result.send(method, element) : 0
	    }
      end
      def first
       self.last
      end
    end
    
    a = [1,2,3,4,5,6,7,8,9,10]
    a.hello       #=> Hello, I'm an Array! 
    a.foldl('+')  #=> 55
    a.first       #=> 10 (yikes!!!)
    
As you can see, this is very powerful, but at the same time can be very dangerous. 
 
### define_method()

As `send()` allows you to call methods programatically, the `define_method()` method lets to define methods in an existing class at runtime. 

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
	
	missed_date_basket.lychees       #=> 36
	missed_date_basket.mangos        #=> 6
	missed_date_basket.mangosteens   #=> 8
	missed_date_basket.mangosteens = 99
	missed_date_basket.rambutan = 30      #=> No Method Error!

Note that `define_method` is not a method of the class FruitBasket. In fact, it is a method belonging to 

### method_missing()

So lets say you add some methods to existing classes, call methods for which you don't know the names, and create new methods at runtime, but you still need more? You want your class to respond to anything that someone might ask  of it.

Ruby has a very powerful way to implement this: the `method_missing()` method. When an object receives a method call, it will first search through its own class definition, then through parent classes, and finally, if no method is found - `method_missing` is called with the name of the method as an argument. In the root class, `method_missing` is something like this:

    def method_missing(method_name, *args)
      raise "NoMethodError: #{method_name} not defined!"
    end
    
This defines the default behavior for `method_missing`: just throw an exception.

But now we can override `method_missing` in our own class, and make it do whatever we want.

    class Greeter
      attr_reader :salutation
      def initialize(sal)
        @salutation = sal
      end
      def method_missing(method_name)
        super unless method_name.to_s =~ /^hello_(.+)$/
        
        puts "#{salutation} #{$1.capitalize}!"
      end
    end

    chinese = Greeter.new("你好")
    chinese.hello_jim	     #=> 你好 Jim
    swahili = Greeter.new("Habari")
    swahili.hello_paul      #=> Habari Paul
    chinese.goodbye_tim     #=> NoMethodError

This example wouldn't make much sense in the real world, but it does illustrate the power of method_missing.


## Practical Examples

Now that we have a good idea of what we can accomplish when using various meta-programming techniques, lets take a look at how these are implemented in the real world.

### Ruby attr_accessor

One of the most common things to find in object oriented languages are getter and setter methods for instance variables. At this point, most modern languages have built-in ways for dealing with expected functions. But Ruby pre-dated many of these using basic meta-programming.

In any Ruby class, you can do something like the folowing

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
    
    hao.inspect => #<Student:0x10a003650 
      @dorm="西区C座9楼304房", 
      @major="计算机科学", 
      @name="好朋友">
      
    hao.to_s => 好朋友学生在学习计算机科学，住在西区C座9楼304房
    
So lets think about this. We already know how we could implement this ourselves using the meta-programming we studied earlier.

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
	    
	puts tai #=> 太漂亮学生在学习计算机科学，住在东区Q座3楼409房
      
So not only are we able to create our own Chinese dialect of Ruby, we can do it in 10 lines. This is where you start to see how much fun it can be to write code the ruby way!


### Rails ActionController Filters

The Rails framework makes heavy use of meta-programming to provide really clean abstrations for the application developer. Here, they define powerful class methods and use the `send` method to implement a filter chain to process an incoming http request.
	
	class ApplicationController < ActionController::Base
	  before_filter :require_login, :ensure_ssl, :prepare_data
	  # ... 
	end
    # from <http://guides.rubyonrails.org/action_controller_overview.html>
 
 Many web application frameworks provide a filter chain as an way to better organize the code you would want to run for every request. In Rails, this is as simple as listing the methods you want to be called, in order. Any of these methods can halt the chain and respond with a redirect, or set up data structures for later use in the action method.


### Rails ActiveRecord Find

The ActiveRecord module is Rails' ORM solution, connecting the relational database with ruby objects that can be used in the web application. When creating ActiveRecord, the Rails core team uses method missing extensively to contrsuct a layer of abstraction over SQL.

In ActiveRecord, you can do things like this:

    student = Students.find_by_name_and_dorm(params[:name],params[:dorm])
    teacher = Teachers.find_by_shenfenzhen(params[:sfz])

By hand, you can't create method for each combination of columns in a model object, so how can you provide methods like `find_by_dorm_and_major()`? Well, by now you should know how it works: use `method_missing()`. Take a look at some code you can find in Rails `ActiveRecord::Base` :

    def method_missing(method_id, *arguments, &block)
      if match = DynamicFinderMatch.match(method_id)
			# verify this is a finder method
          self.class_eval <<-EOS, __FILE__, __LINE__ + 1
            def self.#{method_id}(*args)
				# define the finder method
            end
          EOS
          # then call the method we just defined!
          send(method_id, *arguments)  
        # … lots more code … 
        # from rails-2-3-14/activerecord/lib/activerecord/base.rb:1873

Lets take a look at this line by line and see how meta-programming was used:

    if match = DynamicFinderMatch.match(method_id)
    
This line looks at the missing method name and determines if it is the right kind of method we want to intercept.

    self.class_eval <<-EOS, __FILE__, __LINE__ + 1
      def self.#{method_id}(*args)
        # method implementation
      end
    EOS
    
This is another way of doing `define_method`. Here we are defining a new method with the same name as the missing method.

    send(method_id, *arguments) 
    
And right after the method is created, we invoke it using `send`. Since we wouldn't know the name of the method when we right the code, we are programmatically calling the method using the same missing method name. The difference is that now the method is no longer missing, it has been defined and it will be executed.


## Conclusion

We've gone over the basics of meta-programming in Ruby. Hopefully now you'll have a better idea of how to "write code that writes code". 

When used with caution and care, meta-programming can be of great service, improving the quality and elegance of your code. As with anything though, too much can become a burden as your procedures become more complex and difficult to follow.

Hopefully now you'll be ready to try tackling some of your own problems in Ruby. Remember: Matz writes C code so that we don't have to!

---

@ Kudelabs 2012 - Some Rights Reserved  

Released under a Creative Commons License: non-commercial, attribution.

The text and all examples can be found at:
<https://github.com/adevadeh/intro_meta_ruby>

