#!/usr/bin/env ruby

HELP=<<EOS
format markdown line break style

$ format.rb target.md
EOS

def tpl(key, val)
  {key: key, val: val}
end

def label(line)
  case line
  when "";             tpl(:br, "\n")
  when /^\#{1,6} .*/;  tpl(:header, line)
  when /^ *- .*/;      tpl(:ul, line)
  when /^ *\+ .*/;     tpl(:ol, line)
  when /^ *\d+\. .*/;  tpl(:num, line)
  when /```.*/;       tpl(:code, line)
  when /^\|.*/;        tpl(:table, line)
  else                 tpl(:p, line)
  end
end

def tokenize(data)
  data.split("\n").map(&method(:label))
end


class State
  attr_reader :acc
  def initialize
    @state = :title
    @acc = []
  end

  def title(key: 1, val: 2)
    if key == :header
      @acc << val
      @state = :intro
    else
      raise "state error"
    end
  end

  def intro(key: 1, val: 2)
    if key == :br
      @acc << val
    elsif key == :header
      @acc << "\n"
      @acc << val
      @state = :body
    else
      raise "state error"
    end
  end

  def body(key: 1, val: 2)
    case key
    when :header;
      @acc << "\n\n\n"
      @acc << val
    when :p;
      @acc << "\n\n"
      @acc << val
    when :ul;
      @acc << "\n\n"
      @acc << val
      @state = :ul
    when :ol;
      @acc << "\n\n"
      @acc << val
      @state = :ol
    when :num;
      @acc << "\n\n"
      @acc << val
      @state = :num
    when :code;
      @acc << "\n\n\n"
      @acc << val
      @state = :code
    when :table;
      @acc << "\n\n"
      @acc << val
      @state = :table
    when :br;
      # do nothing
    else
      raise "state error"
    end
  end

  def ul(key: 1, val: 2)
    if key == :ul
      @acc << "\n"
      @acc << val
    else
      @state = :body
    end
  end

  def ol(key: 1, val: 2)
    if key == :ol
      @acc << "\n"
      @acc << val
    else
      @state = :body
    end
  end

  def num(key: 1, val: 2)
    if key == :num
      @acc << "\n"
      @acc << val
    else
      @state = :body
      process({key: key, val: val})
    end
  end

  def code(key: 1, val: 2)
    if key == :code
      @acc << "\n"
      @acc << val
      @state = :body
    elsif key == :br
      @acc << val
    else
      @acc << "\n"
      @acc << val
    end
  end

  def table(key: 1, val: 2)
    if key == :table
      @acc << "\n"
      @acc << val
    else
      @acc << "\n"
      @state = :body
    end
  end

  def process(tuple)
    self.send(@state, tuple)
  end
end


def main(target)
  if target == nil
    puts HELP
    exit 0
  end

  path = File.absolute_path(target)
  data = File.read(path)


  state = State.new()
  tokenize(data).each{|tuple|
    state.process(tuple)
  }

  result = state.acc.join("") << "\n"


  puts result
  File.write(path, result)
end

main(ARGV[0])
