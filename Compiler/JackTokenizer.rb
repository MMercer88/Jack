#Author: Eric Gagnon and Mike Mercer
#Date: May 4, 2014

class JackTokenizer
  @@keywords = ['class', 'constructor', 'function', 'method', 'field', 'static', 'var', 'int', 'char', 'boolean', 'void', 'true', 'false', 'null', 'this', 'let', 'do', 'if', 'else', 'while', 'return']
  @@symbols = ['{', '}','(',')','[',']', '.',',',';','+','-','*','/','&','|','<','>','=','~']

  def initialize input
    @fileIn = IO.readlines(input).select{|s| !(s.gsub(/\/\/.*/, '').strip.empty?)}.map { |s|
    s.gsub(/\/\/.*/, '').gsub(/\/(.*)/, '').gsub(/[*].+/, '').gsub(/^\s[*]/, '') }
    @fileIn.collect! do |line| 
      line.split(/(".*?"|[{}()\[\].,;+\-*\/&|<>=~]|\s+)/)
    end
    @fileIn.flatten!
    @fileIn.reject! {|line| line =~ /^\s*$/}
    @currentToken = ""
    @index = -1
  end

  def hasMoreTokens?
    @index + 1 < @fileIn.length
  end

  def advance
    @index+=1
    @currentToken = @fileIn[@index]
  end

  def typeToken
    if @@keywords.include?(@currentToken.downcase)
      "KEYWORD"
    elsif @@symbols.include?(@currentToken)
      "SYMBOL"    
    elsif @currentToken.match(/\d+/)
      "INT_CONST"
    elsif @currentToken.match(/^[a-zA-Z_][A-Za-z0-9_]*$/)
      "IDENTIFIER"
    else
      "STR_CONST"
    end
  end

  def keyWord
    @currentToken
  end

  def symbol
    case @currentToken
    when '<'
      "&lt;"
    when '>'
      "&gt;"
    when '&'
      "&amp;"
    else
      @currentToken
    end
  end

  def identifier
    @currentToken
  end

  def intVal
    @currentToken
  end

  def stringVal
    @currentToken.gsub(/\A"|"\Z/, '')
  end

end

=begin
raise "JackTokenizer should have more tokens" unless JackTokenizer.new('while {').hasMoreTokens? == true
raise "JackTokenizer should not have more tokens" unless JackTokenizer.new('').hasMoreTokens? == false
raise "JackTokenizer should advance" unless JackTokenizer.new('while {').advance == 'while'
=end

files = []
dir = "../" + ARGV[0]
Dir.chdir(dir)
Dir.glob('*.jack').inject(0) do |count, file|
  files[count] = file
  count += 1
end

files.each do |file|
  tokens = JackTokenizer.new(file)

  name = file.dup
  outfile = File.open(name.gsub('.jack', '.xml'), 'w')

  outfile << "<tokens>\n"
  while tokens.hasMoreTokens?
      tokens.advance
      case tokens.typeToken
      when "KEYWORD"
        outfile << "<keyword> #{tokens.keyWord} </keyword>\n"
      when "SYMBOL"
        outfile << "<symbol> #{tokens.symbol} </symbol>\n"
      when "INT_CONST"
        outfile << "<integerConstant> #{tokens.intVal} </integerConstant>\n"
      when "STR_CONST"
        outfile << "<stringConstant> #{tokens.stringVal} </stringConstant>\n"
      when "IDENTIFIER"
        outfile << "<identifier> #{tokens.identifier} </identifier>\n"
      end
  end
  outfile << "</tokens>\n"
  outfile.close
end


