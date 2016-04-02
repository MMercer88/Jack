#Author: Mike Mercer
#Pair: Eric Gagnon, Jose Martinez
#Date: Mar. 9, 2014
class Code
  
  def dest d

    case d
    when nil
      return "000"
    when "M"
      return "001"
    when "D"
      return "010"
    when "MD"
      return "011"
    when "A"
      return "100"
    when "AM"
      return "101"
    when "AD"
      return "110"
    else
      return "111"        
    end 
  end
  def comp c

    case c
      when "0"
          return "0101010"
      when "1"
          return "0111111"
      when "-1"
          return "0111010"
      when "D"
          return "0001100"
      when "A"
          return "0110000"
      when "!D"
          return "0001101"
      when "!A"
          return "0110001"
      when "-D"
          return "0001111"
      when "-A"
          return "0110011"
      when "D+1"
          return "0011111"
      when "A+1"
          return "0110111"
      when "D-1"
          return "0001110"
      when "A-1"
          return "0110010"
      when "D+A"
          return "0000010"
      when "D-A"
          return "0010011"
      when "A-D"
          return "0000111"
      when "D&A"
          return "0000000"
      when "D|A"
          return "0010101"
      when "M"
          return "1110000"
      when "!M"
          return "1110001"
      when "-M"
          return "1110011"
      when "M+1"
          return "1110111"
      when "M-1"
          return "1110010"
      when "D+M"
          return "1000010"
      when "D-M"
          return "1010011"
      when "M-D"
          return "1000111"
      when "D&M"
          return "1000000"
      else
          return "1010101"
      end
    end
    def jump j

      case j
        when nil
          return "000"
        when "JGT"
          return "001"
        when "JEQ"
          return "010"
        when "JGE"
          return "011"
        when "JLT"
          return "100"
        when "JNE"
          return "101"
        when "JLE"
          return "110"
        else
          return "111"
       end
    end
end


raise "Code should return binary of destination mnemonic" unless Code.new().dest('AMD') == "111"

raise "Code should return binary of computation mnemonic" unless Code.new().comp('D|A') == "0010101"

raise "Code should return binary of jump mnemonic" unless Code.new().jump('JGT') == "001"
