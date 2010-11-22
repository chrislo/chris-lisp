require File.dirname(__FILE__) + '/lisp.rb'

env = Env.new
Env.add_globals(env)

while true
  cmd = gets
  val = lisp_eval(parse(cmd), env)
  puts val
end
