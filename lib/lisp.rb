def tokenize(p)
  p.gsub('(',' ( ').gsub(')',' ) ').split
end

def parse(p)
  parse_tokens(tokenize(p))
end

def parse_tokens(tokens)
  token = tokens.shift
  if token == '(' 
    l = []
    while tokens[0] != ')' 
      l.push(parse_tokens(tokens))
    end
    tokens.shift
    return l
  elsif token == ')'
    raise SyntaxError
  else
    return atom(token)
  end
end

def atom(token)
  case token
  when /\d+\.\d+/
    return token.to_f
  when /\A\d+\z/
    return token.to_i
  else
    return token
  end
end

def lisp_eval(x, env = {})
  if x.class == String # symbol
    return env.find(x)[x]
  elsif x.class != Array # constant literal
    return x
  elsif x[0] == 'quote'   # (quote exp)
    _, exp = x
    return exp
  elsif x[0] == 'define'  # (define x 2)
    _, var, exp = x
    env[var] = lisp_eval(exp, env)
  elsif x[0] == 'set!'    # (set! x 2)
    _, var, exp = x
    raise "#{var} is not defined" unless env.find(var) 
    env[var] = lisp_eval(exp, env)
  elsif x[0] == 'lambda' # (lambda (r) (+ r r))
    _, formals, body = x
    Proc.new do |*args| 
      # create an environment local to this proc using the formal
      # parameters, e.g. 'r' and the arguments supplied, e.g. 2. Set
      # the outer env to the one supplied to lisp_eval
      local_env = Env.new(formals, args, env)

      # evaluate the body (e.g. '+ r r') using the local env
      lisp_eval(body, local_env)
    end
  else # procedure call (+ 1 2)
    exps = x.map {|exp| lisp_eval(exp, env)}
    proc = exps.shift
    proc.call(*exps)
  end
end

class Env < Hash
  attr_reader :outer
  def initialize(keys = [], values = [], outer = nil)
    @outer = outer
    pairs = keys.zip(values)
    pairs.each {|pair| self[pair[0]] = pair[1]}
  end

  def find(var)
    if self.has_key?(var)
      return self 
    else 
      if self.outer
        self.outer.find(var)
      else
        nil
      end
    end
  end

  def self.add_globals(env)
    env['+'] = Proc.new {|a,b| a + b}
    env['*'] = Proc.new {|a,b| a * b}
    env['-'] = Proc.new {|a,b| a - b}
    env['/'] = Proc.new {|a,b| a / b}
    env['<'] = Proc.new {|a,b| a < b}
    env['>'] = Proc.new {|a,b| a > b}
    env['car'] = Proc.new {|*args| args[0]}
    env['cdr'] = Proc.new {|*args| args.shift; args}
  end
end
