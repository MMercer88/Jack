#Author: Eric Gagnon
#Pair: Mike Mercer
#Date: Mar. 25, 2014

class Parser
  def initialize (array=nil)
  @array = array
  @array.unshift("dummy") if array
  end

  def hasMoreCommands
    !@array.nil? and @array.size > 1
  end

  def advance
    @array.shift
    self
  end

  def commandType
    case @array[0]
    when /^(add|sub|neg|eq|gt|lt|and|or|not)/
      return "C_ARITHMETIC"
    when /^push/
      return "C_PUSH"
    when /^pop/
      return "C_POP"
    when /^label/
      return "C_LABEL"
    when /^goto/
      return "C_GOTO"
    when /^if-goto/
      return "C_IF"
    when /^function/
      return "C_FUNCTION"
    when /^return/
      return "C_RETURN"
    else
      return "C_CALL"
    end 

  end

  def arg1
    if (@array[0].match(/^(add|sub|neg|eq|gt|lt|and|or|not)/))
      @array[0].gsub(/\s(.+)/, "")
    elsif(@array[0].match(/^(if-goto|label|goto)/))
      @array[0].gsub(/(.+)\s/, "")
    else 
      @array[0].gsub(/^\w+\s/, "").gsub(/\s\d+$/, "")
    end
  end

  def arg2
    case @array[0]
    when /^(push|pop|function|call)/
      return @array[0].gsub(/\D/, "")
    end
  end
end

raise "Default parser should not have any commands" unless Parser.new().hasMoreCommands == false
raise "Parser should have more commands" unless Parser.new(['push constant 7', 'push constant 8']).hasMoreCommands == true
raise "Parser should not have more commands" unless Parser.new(['push constant 7', 'push constant 8']).advance.advance.hasMoreCommands == false
raise "Parser should recognize greater than command" unless Parser.new(['gt']).advance.commandType == "C_ARITHMETIC"
raise "Parser should recognize add command" unless Parser.new(['add']).advance.commandType == "C_ARITHMETIC"
raise "Parser should recognize push command" unless Parser.new(['push x']).advance.commandType == "C_PUSH"
raise "Parser should recognize pop command" unless Parser.new(['pop z']).advance.commandType == "C_POP"
raise "Parser should recognize label command" unless Parser.new(['label loop']).advance.commandType == "C_LABEL"
raise "Parser should recognize goto command" unless Parser.new(['goto loop']).advance.commandType == "C_GOTO"
raise "Parser should recognize if command" unless Parser.new(['if-goto end']).advance.commandType == "C_IF"
raise "Parser should recognize function command" unless Parser.new(['function mult 2']).advance.commandType == "C_FUNCTION"
raise "Parser should recognize return command" unless Parser.new(['return']).advance.commandType == "C_RETURN"
raise "Parser should recognize call command" unless Parser.new(['call mult']).advance.commandType == "C_CALL"
raise "Parser should return 1st arg of current command" unless Parser.new(['sub']).advance.arg1 == "sub"
raise "Parser should return 2nd arg of current command" unless Parser.new(['push 7']).advance.arg2 == "7"
raise "Parser should return 2nd arg of current command" unless Parser.new(['pop 8']).advance.arg2 == "8"
raise "Parser should return 2nd arg of current command" unless Parser.new(['pop local 7']).advance.arg1 == "local"
raise "Parser should return 2nd arg of current command" unless Parser.new(['push constant 7']).advance.arg1 == "constant"
raise "Parser should return 2nd arg of current command" unless Parser.new(['push temp 6']).advance.arg1 == "temp"
raise "Parser should return 1st arg of current command" unless Parser.new(['label LOOP_START']).advance.arg1 == "LOOP_START"
raise "Parser should return 1st arg of current command" unless Parser.new(['if-goto LOOP_START']).advance.arg1 == "LOOP_START"
raise "Parser should return 1st arg of current command" unless Parser.new(['goto LOOP_START']).advance.arg1 == "LOOP_START"
raise "Parser should return 1st arg of current command" unless Parser.new(['function Sys.init 0']).advance.arg1 == "Sys.init"
raise "Parser should return 2nd arg of current command" unless Parser.new(['function Sys.init 0']).advance.arg2 == "0"

#puts "Passes Tests"







