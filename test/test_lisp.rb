require 'test/unit'
require 'yaml'

$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))
require 'lisp'

class EnvTest < Test::Unit::TestCase
  def test_initialize
    env = Env.new
    assert_nil(env.outer)
  end

  def test_add_key
    env = Env.new
    env[:a] = 5
    assert_equal(5, env[:a])
  end

  def test_initialize_with_kv_pairs
    keys = ['a', 'b', 'c']
    values = [1,2,3]
    env = Env.new(keys, values)
    assert_equal(2, env['b'])
    assert_equal(1, env['a'])
  end

  def test_find
    env = Env.new
    env[:a] = 5
    assert_equal(env, env.find(:a))
  end

  def test_find_outer_env
    outer_env = Env.new
    inner_env = Env.new([],[],outer_env)
    outer_env[:a] = 5
    assert_equal(outer_env, inner_env.find(:a))
  end
end

class LispTest < Test::Unit::TestCase
  def test_tokenize
    program = "(set! x*2 (* x 2))"
    assert_equal(['(', 'set!', 'x*2', '(', '*', 'x', '2', ')', ')'],
                 tokenize(program))
  end

  def test_parse
    program = "(set! x*2 (* x 2))"
    assert_equal(['set!', 'x*2', ['*', 'x', 2]],
                 parse(program))
  end

  def test_atom
    assert_equal(1, atom('1'))
    assert_equal(2.3, atom('2.3'))
    assert_equal('x*2', atom('x*2'))
  end

  def test_eval_quote
    assert_equal([1, 2, 3], lisp_eval(['quote', [1, 2, 3]]))
  end

  def test_eval_literal
    assert_equal(1, lisp_eval(1))
  end

  def test_eval_define
    env = {}
    lisp_eval(['define', 'x', 2], env)
    assert_equal(env['x'], 2)
  end

  def test_eval_set_undefined_variable
    env = Env.new
    assert_raises(RuntimeError) {lisp_eval(['set!', 'x', 2], env) }
  end

  def test_eval_set_defined_variable
    env = Env.new
    lisp_eval(['define', 'x', 1], env)
    lisp_eval(['set!', 'x', 2], env)
    assert_equal(env['x'], 2)
  end

  def test_eval_symbol
    env = Env.new
    env['+'] = 5
    assert_equal(5, lisp_eval('+', env))
  end

  def test_plus
    env = Env.new
    env['+'] = Proc.new {|a,b| a + b}

    code = '(+ 1 2)'
    assert_equal(3, lisp_eval(parse(code), env))
  end

  def test_double_plus
    env = Env.new
    env['+'] = Proc.new {|a,b| a + b}

    code = '(+ 1 (+ 2 3))'
    assert_equal(6, lisp_eval(parse(code), env))
  end

  def test_lambda
    env = Env.new
    env['+'] = Proc.new {|a,b| a + b}
    tokens = ["lambda", ["r"], ["+", "r", "r"]]
    proc = lisp_eval(tokens, env)
    assert_equal(4, proc.call(2))
  end

  def test_assign_lambda
    env = Env.new
    env['*'] = Proc.new {|a,b| a * b}
    code = '(define square (lambda (x) (* x x)))'
    lisp_eval(parse(code), env)

    code = '(square 3)'
    assert_equal(9, lisp_eval(parse(code), env))
  end
end


