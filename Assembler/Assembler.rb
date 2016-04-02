#Author: Mike Mercer
#Pair: Eric Gagnon, Jose Martinez
#Date: Mar. 9, 2014

require './code'
require './parser'
require './symtable'

class Assembler
     
  @@filename
  def initialize
    @file = IO.readlines(ARGV[0]).select{|s| !(s.gsub(/\/\/.*/, '').strip.empty?)}.map { |s|
    s.gsub(/\/\/.*/, '').strip } 
    @file2 = IO.readlines(ARGV[0]).select{|s| !(s.gsub(/\/\/.*/, '').strip.empty?)}.map { |s|
    s.gsub(/\/\/.*/, '').strip } 
    @parser = Parser.new(@file)
    @parser2 = Parser.new(@file2)
    @code = Code.new()
    @sym_table = SymTable.new()
    
    @@filename = File.open(ARGV[0].gsub(".asm",".hack"),'w')
  end 

  def run
    
    rom = 0
    while @parser.hasMoreCommands
      @parser.advance
      
      case @parser.commandType
      when "L_COMMAND"
        @sym_table.addEntry(@parser.symbol, rom)
      else
        rom += 1
      end
    end


     open(@@filename, 'w') { |f|
     while @parser2.hasMoreCommands
        @parser2.advance
        case @parser2.commandType
          when "A_COMMAND"
             f.puts a_command @parser2.symbol
          when "C_COMMAND"
            dest = @code.dest @parser2.dest
            jump = @code.jump @parser2.jump
            comp = @code.comp @parser2.comp  
            f.puts c_command comp, dest, jump
          else
        end
      end
     }

  end
  def a_command cmd
    ram = 16
    if(cmd.match(/^\d+/))
      cmd.to_i.to_s(2).rjust(16, '0')
    else
      if(@sym_table.contains?(cmd))
        address = @sym_table.getAddress(cmd)
        address.to_i.to_s(2).rjust(16, '0')
      else
        @sym_table.addEntry(cmd, ram)
        ram += 1
        address = @sym_table.getAddress(cmd)
        address.to_i.to_s(2).rjust(16, '0')
      end
    end
  end

  def c_command comp, dest, jump
    "111#{comp}#{dest}#{jump}"
  end

  
end

Assembler.new.run
