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
    return env[x]
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
  else # procedure call
    exps = x.map {|exp| lisp_eval(exp, env)}
    proc = exps.shift
    proc.call(*exps)
  end
end

class Env < Hash
  attr_reader :outer
  def initialize(outer = nil)
    @outer = outer
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
end
