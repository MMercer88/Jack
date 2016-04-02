#Author: Mike Mercer
#Pair: Eric Gagnon, Jose Martinez
#Date: Mar. 9, 2014

class SymTable
  def initialize 
    @sym_table = Hash.new()
    (0..15).each {|num|  addEntry("R#{num}", num)}
    { "SCREEN" => 16384, "KBD" => 24576, "SP" => 0, "LCL" => 1,
      "ARG" => 2, "THIS" => 3, "THAT" =>4}.each {|sym, address|
      addEntry(sym, address)} 
  end

  def addEntry sym, address
    @sym_table[sym] = address
  end

  def contains? sym
    @sym_table.has_key?(sym)
  end

  def getAddress sym    
    @sym_table[sym]
  end
end

