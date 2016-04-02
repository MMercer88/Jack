#Author: Mike Mercer
#Pair: Eric Gagnon, Jose Martinez
#Date: Mar. 9, 2014

class Parser
  def initialize(array=nil)
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
    if(@array[0].start_with?("@"))
      return "A_COMMAND"
    elsif (@array[0].start_with?("("))
      return "L_COMMAND"
    else
      return "C_COMMAND"
    end
  end
  def symbol
    if(@array[0].start_with?("@"))
      return @array[0].gsub("@", "")
    else
      return @array[0].gsub(/[()]/, "")
    end  
  end
  def dest
    match = @array[0].match(/(.+)=/)
    match[1] if match 
  end
  def comp
    @array[0].gsub(/.+=/, "").gsub(/;.+/, "")
  end
  def jump
    match = @array[0].match(/;(.+)/)
    match[1] if match
  end 
end

raise "default parser should not have any commands" if Parser.new().hasMoreCommands == true

raise "parser with data should have commands" if Parser.new(['@7','D=M']).hasMoreCommands == false

raise "parser with two commands should have more " if Parser.new(['@7', 'D=M']).advance.advance.hasMoreCommands == true

raise "parser should recognize A command" unless Parser.new(['@7']).advance.commandType == "A_COMMAND"

raise "parser should recognize C command" unless Parser.new(['D=M']).advance.commandType == "C_COMMAND"

raise "parser should recognize symbol for A command" unless Parser.new(['@7']).advance.symbol == "7"

raise "parser should return destination mnemonic" unless Parser.new(['D=M']).advance.dest == "D" 

raise "parser should gracefully handle null destination" unless Parser.new(['M']).advance.dest == nil

raise "parser should return computation mnemonic" unless Parser.new(['D=D+A;JMP']).advance.comp == "D+A"

raise "parser should return jump mnemonic" unless Parser.new(['D=D+A;JMP']).advance.jump == 'JMP'

raise "parser should gracefully handle null jump" unless Parser.new(['D=D+A']).advance.jump == nil



