require File.dirname(__FILE__) + '/lisp.rb'

env = Env.new
env['+'] = Proc.new {|a,b| a + b}

while true
  cmd = gets 
  val = lisp_eval(parse(cmd), env)
  puts val
end
