#Author: Eric Gagnon
#Date: Mar. 25, 2014

require './parser'
require './codewriter'

class VM
  def initialize
    
    @files = ARGV
    @code = CodeWriter.new(@files[0])
  end

  def run
    if @files.length > 1
      @code.writeInit
    end
    @files.each do |file|
    thisFile = IO.readlines(file).select{|s| !(s.gsub(/\/\/.*/, '').strip.empty?)}.map { |s|
    s.gsub(/\/\/.*/, '').strip }
    @parser = Parser.new(thisFile)
      while @parser.hasMoreCommands
        @parser.advance
        case @parser.commandType
        when "C_PUSH"
          @code.writePushPop @parser.commandType, @parser.arg1, @parser.arg2
        when "C_POP"
          @code.writePushPop @parser.commandType, @parser.arg1, @parser.arg2
        when "C_ARITHMETIC"
          @code.writeArithmetic @parser.arg1
        when "C_IF"
          @code.writeIf @parser.arg1
        when "C_GOTO"
          @code.writeGoto @parser.arg1
        when "C_LABEL"
          @code.writeLabel @parser.arg1
        when "C_FUNCTION"
          @code.writeFunction @parser.arg1, @parser.arg2
        when "C_CALL"
          @code.writeCall @parser.arg1, @parser.arg2
        when "C_RETURN"
          @code.writeReturn
        end
      end
    end 
  end
end

VM.new.run