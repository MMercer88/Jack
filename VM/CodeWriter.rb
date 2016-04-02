#Author: Mike Mercer
#Date: Apr. 13, 2014

class CodeWriter 
     
  
  def initialize stream 
   @output = File.open(stream.gsub(".vm", ".asm"), 'w') 
   @num = 1  
   @@callCount = 0
  end
  def setFileName fileName 
   fileName.gsub!(".vm", ".asm") 
     
  end
  def writeArithmetic cmd 
    case cmd 
    when "add"
      @output << ("@SP
        A=M-1
        D=M
        M=0
        @SP
        AM=M-1
        A=A-1
        M=M+D\n") 
    when "sub"
      @output << ("@SP
        A=M-1
        D=M
        M=0
        @SP
        AM=M-1
        A=A-1
    M=M-D\n") 
    when "neg"
      @output << ("@SP
        M=M-1
        A=M
        D=M
        M=-D
        @SP
        A=M
        M=D
        @SP
        M=M+1\n") 
  
    when "eq"
        
      @output << ("@SP
        M=M-1
        A=M
        D=M
        @SP
        M=M-1
        A=M
        D=D-M
        @eqfalse#{@num}  
        D;JNE  
        @SP
        A=M
        D=M
        M=-1
        @eqend#{@num} 
        0;JMP 
        (eqfalse#{@num}) 
        @SP
        A=M
        D=M
        M=0
        (eqend#{@num}) 
        @SP
        M=M+1\n") 
        @num+=1
        
    when "gt"
      @output << ("@SP
        M=M-1
        A=M
        D=M
        @SP
        M=M-1
        A=M
        D=D-M
        @gtfalse#{@num}
        D;JGE  
        @SP
        A=M
        D=M
        M=-1
        @gtend#{@num}
        0;JMP 
        (gtfalse#{@num}) 
        @SP
        A=M
        D=M
        M=0
        (gtend#{@num}) 
        @SP
        M=M+1\n") 
        @num+=1
    when "lt"
      @output << ("@SP
        M=M-1
        A=M
        D=M
        @SP
        M=M-1
        A=M
        D=D-M
        @ltfalse#{@num}
        D;JGT  
        @SP
        A=M
        D=M
        M=0
        @ltend#{@num}
        0;JMP 
        (ltfalse#{@num}) 
        @SP
        A=M
        D=M
        M=-1
        (ltend#{@num}) 
        @SP
        M=M+1\n")
        @num+=1 
    when "and"
      @output << ("@SP
        M=M-1
        A=M
        D=M
        @SP
        M=M-1
        A=M
        D=D&M
        M=D
        @SP
        M=M+1\n") 
  
    when "or"
      @output << ("@SP
        M=M-1
        A=M
        D=M
        @SP
        M=M-1
        A=M
        D=D|M
        M=D
        @SP
        M=M+1\n") 
  
    when "not"
      @output << ("@SP
        M=M-1
        A=M
        D=M
        M=!M
        @SP
        M=M+1\n") 
    else
  
    end
  end
  def writePushPop cmd, seg, index 
  case cmd 
    when "C_PUSH" , "C_POP"
    if seg=="local" 
      @output << "@LCL\nD=M\n"
    elsif seg=="argument" 
      @output << "@ARG\nD=M\n"
    elsif seg=="this" 
      @output << "@THIS\nD=M\n"
    elsif seg=="that" 
      @output << "@THAT\nD=M\n"
    elsif seg=="temp" 
      @output << "@5\nD=A\n"
    elsif seg=="pointer" 
      @output << "@3\nD=A\n"
    elsif seg == "static"
      @output << "@StaticTest.vm.#{index}\nD=A\n"
    elsif seg=="constant"
      if(index=="0"||index=="1") 
        @output << "D=#{index}\n"
      else 
        @output << "@#{index}
        D=A\n"
      end
  end
  
  
  if(seg!="static" && seg!="constant" && index!="0")
    @output << "@#{index}
     D=D+A\n"
  end
  if cmd=="C_PUSH"
    if seg=="constant" 
     @output << "@SP
     AM=M+1
     A=A-1
     M=D\n"
    else 
     @output << "A=D
     D=M
     @SP
     AM=M+1
     A=A-1
     M=D\n"
    end
  else 
      @output << "@R13
      M=D
      @SP
      AM=M-1
      D=M
      M=0
      @R13
      A=M
      M=D\n"
  end
end
 
  
  def close  
    @output.close 
  end    
end

  def writeInit
    @output << "@256
                D=A
                @SP
                M=D\n"
                writeCall("Sys.init",0)
                 
  end
  
  def writeLabel label
    @output << "(#{label})\n"
    
  end
  
  def writeGoto label
    @output << "@#{label} 
                0;JMP\n"
  end
  
  def writeIf label
    @output << "@SP
                M=M-1
                A=M
                D=M
                @#{label} 
                D;JNE\n"
  end
  
  def writeCall functionName,numArgs
    @argOffset = numArgs.to_i + 5
    @pushString ="D=M\n@SP\nAM=M+1\nA=A-1\nM=D\n"
    @output <<" @RETURN#{@@callCount}
                D=A
                @SP
                AM=M+1
                A=A-1
                M=D
                @LCL
                #{@pushString}
                @ARG
                #{@pushString}
                @THIS
                #{@pushString}
                @THAT
                #{@pushString}
                @SP
                D=M
                @#{@argOffset}
                D=D-A
                @ARG
                M=D
                @SP
                D=M
                @LCL
                M=D\n"
                writeGoto(functionName)
      @output << "@#{functionName}
                0;JMP
                (RETURN#{@@callCount})\n"
               
               @@callCount+=1
  end
  
  def writeReturn
    @output << "@LCL
                D=M
                @R14
                M=D
                @5
                A=D-A
                D=M
                @R13
                M=D
                @SP
                AM=M-1
                D=M
                @ARG
                A=M
                M=D
                @ARG
                D=M+1
                @SP
                M=D
                @R14
                AM=M-1
                D=M
                @THAT
                M=D
                @R14
                AM=M-1
                D=M
                @THIS
                M=D
                @R14
                AM=M-1
                D=M
                @ARG
                M=D
                @R14
                AM=M-1
                D=M
                @LCL
                M=D
                @R13
                A=M
                0;JMP\n"
  end
  
  def writeFunction functionName,numLocals
    
    writeLabel(functionName)
    (1..numLocals.to_i).each do
      @output <<"@SP
                  A=M
                  M=D
                  A=A+1
                  @#{numLocals}
                  D=A
                  @SP
                  M=D+M\n"
     end
  end

end