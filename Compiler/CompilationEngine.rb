#Author: Eric Gagnon and Mike Mercer
#Date: April 27, 2014

class CompilationEngine
  def initialize fileIn, fileOut
    @tokenizer = JackTokenizer.new(fileIn)
    @outfile = File.open(fileOut.gsub('.jack', '.xml'), 'w')
  end

  def compileClass
      @outfile << "<class>\n"
      while !@tokenizer.advance.match(/^(function|constructor|method)/)
        case @tokenizer.typeToken
        when "KEYWORD" 
          @outfile << " <keyword> #{@tokenizer.keyWord} </keyword>\n"
        when "IDENTIFIER" 
          @outfile << " <identifier> #{@tokenizer.identifier} </identifier>\n"
        when "SYMBOL" 
          @outfile << " <symbol> #{@tokenizer.symbol} </symbol>\n"
        end
      end
      compileSubroutine

      @outfile << "</class>\n"
  end

  def compileClassVarDec
    @outfile << "<classVaarDec>\n"
    @outfile << "<keyword>#{@tokenizer.keyWord}</keyword>\n"
    @tokenizer.advance
    if @tokenizer.typeToken == "KEYWORD" and [:int, :char, :boolean].include?(@tokenizer.keyWord)
      @outfile << "<keyword>#{@tokenizer.keyWord}</keyword>"
    else
      @outfile << "<identifier>#{@tokenizer.idnetifier}</identifier>"
    end
    @tokenizer.advance
    @outfile  << "<identifier>#{@tokenizer.identifier}</idnetifier>\n"
    @tokenizer.advance
    while @tokenizer.type == "SYMBOL" and @tokenizer.symbol == ','
      @outfile << "<symbol>{</symbol>\n"
      @tokenizer.advance
      @outfile << "<identifier>#{@tokenizer.identifier}</identifier>"
      @tokenizer.advance
    end
    @outfile << "<symbol>;</symbol>"
    @tokenizer.advance
    @outfile << "<classVaarDec>\n"
  end

  def compileSubroutine
    @outfile << " <subroutineDec>\n"
    @outfile << "   <keyword> #{@tokenizer.keyWord} </keyword>\n"
    while !@tokenizer.advance.match(/\(/)
      case @tokenizer.typeToken
      when "KEYWORD" 
        @outfile << "   <keyword> #{@tokenizer.keyWord} </keyword>\n"
      when "IDENTIFIER" 
        @outfile << "   <identifier> #{@tokenizer.identifier} </identifier>\n"
      end
    end
    compileParameterList
    @outfile << "   <subroutineBody>\n"
    @tokenizer.advance
    @outfile << "     <symbol> #{@tokenizer.symbol} </symbol>\n"
      while @tokenizer.advance.match(/^var/)
        compileVarDec
      end

    if @tokenizer.typeToken == "KEYWORD" and @tokenizer.keyWord.match(/^(do|let|while|if|return)/)
      @outfile << "   <statements>\n"
      until @tokenizer.currentToken.match(/^({|})/)
        compileStatements
        @tokenizer.advance
      end
      @outfile << "   </statements>\n"
    end
  end

  def compileParameterList
    @outfile << "   <symbol> #{@tokenizer.symbol} </symbol>\n"
    @outfile << "   <parameterList>\n"
    @outfile << "   </parameterList>\n"
    @tokenizer.advance
    @outfile << "   <symbol> #{@tokenizer.symbol} </symbol>\n"
  end

  def compileVarDec
    @outfile << "   <varDec>\n"
    @outfile << "     <keyword> #{@tokenizer.keyWord} </keyword>\n"
    until @tokenizer.advance.match(/;/)
      case @tokenizer.typeToken
      when "KEYWORD" 
        @outfile << "     <keyword> #{@tokenizer.keyWord} </keyword>\n"
      when "IDENTIFIER" 
        @outfile << "     <identifier> #{@tokenizer.identifier} </identifier>\n"
      when "SYMBOL"
        @outfile << "     <symbol> #{@tokenizer.symbol} </symbol>\n"
      end
    end
    @outfile << "     <symbol> #{@tokenizer.symbol} </symbol>\n"
    @outfile << "   </varDec>\n"
  end

  def compileStatements
    
    case @tokenizer.keyWord
    when "do"
      compileDo
    when "let"
      compileLet
    when "while"
      compileWhile
    when "return"
      compileReturn
    when "if"
      compileIf
    end
  end

  def compileDo
    @outfile << "     <doStatement>\n"
    @outfile << "<keyword>do</keyword>\n"
    @tokenizer.advance
    @outfile << "<identifier> #{@tokenizer.identifier} </identifier>\n"
    @tokenizer.advance
        if @tokenizer.symbol == "."
          @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
          @tokenizer.advance
          @outfile << "<identifier> #{@tokenizer.identifier} </identifier>\n"
          @tokenizer.advance
          @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
          compileExpressionList
       end
    @outfile << "<symbol>;</symbol>\n"
    @tokenizer.advance
    @outfile << "     </doStatement>\n"
  end

  def compileLet
    @outfile << "     <letStatement>\n"
    @outfile << "     <keyword> #{@tokenizer.keyWord} </keyword>\n"
    until @tokenizer.advance.match(/\=/)
      @outfile << "     <identifier> #{@tokenizer.identifier} </identifier>\n"
    end
    @outfile << "     <symbol> #{@tokenizer.symbol} </symbol>\n"
    
    compileExpression
    @outfile << "<symbol> ; </symbol>\n"
    @outfile << "     </letStatement>\n"
  end

  def compileWhile
    @outfile << "<whileStatement>\n"
    @outfile << "<keword>while</keyword>\n"
    @tokenizer.advance
    @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
    compileExpression
    @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
    compileExpression
    @outfile << "<symbol>)</symbol>\n"
    @tokenizer.advance
    @outfile << "<symbol>{</symbol>\n"
    @tokenizer.advance
    compileExpression
    @outfile << "<symbol>}</symbol>\n"
    @tokenizer.advance
    @outfile << "</whileStatement>\n"  
  end

  def compileReturn
    @outfile << "     <returnStatement>\n"
    @outfile << "<keyword>return</keyword>\n"
    @tokenizer.advance
    unless @tokenizer.typeToken == "Symbol" and @tokenizer.symbol == ';'
      compileExpression
    end
    @outfile << "<symbol>;</symbol\n>"
    @tokenizer.advance
    @outfile << "     </returnStatement>\n" 
  end

  def compileIf
    @outfile << "     <ifStatement>\n"
    @outfile << "<keyword>if</keyword>\n"
    @tokenizer.advance
    @outfile << "<symbol>)</symbol>\n"
    @tokenizer.advance
    @outfile << "<symbol>{</symbol>\n}"
    @tokenizer.advance
    compileStatements
    @outfile << "<symbol>}</symbol>\n}"
    @tokenizer.advance
    if @tokenizer.typeToken == "Keyword" and @tokenizer.keyWord == :else
      @outfile << "<keyword>else</keyword>\n"
      @tokenizer.advance
      @outfile << "<symbol>{</symbol>\n}"
      @tokenizer.advance
      compileStatements
      @outfile << "<symbol>}</symbol>\n"
      @tokenizer.advance
    end
    
    @outfile << "     </ifStatement>\n" 
  end

  def compileExpression
    @outfile << "<expression>\n"
    compileTerm
    while @tokenizer.typeToken == "SYMBOL" and ['+','-','*','/','&','|','<','>','='].include?(@tokenizer.symbol)
      @outfile << "<symbol>"
      case @tokenizer.symbol
        when '&'
          @outfile << "&amp;"
        when '<'
          @outfile << "&lt;"
        when '>'
          @outfile << "&gt;"
        else
          @outfile << @tokenizer.symbol
      end
      @outfile << "</symbol>"
      @tokenizer.advance
      compileTerm
    end
    @outfile << "</expression>\n"
  end

  def compileTerm
    @outfile << "<term>\n"
    @tokenizer.advance
    case @tokenizer.typeToken 
    when "INT_CONST"
      @outfile << "<integerConstant> #{@tokenizer.intVal} </integerConstant>\n" 
      @tokenizer.advance 
    when "STR_CONST"
      @outfile << "<stringConstant> #{@tokenizer.stringVal} </stringConstant>\n" 
      @tokenizer.advance 
    when "KEYWORD"
      @outfile << "<keyword> #{@tokenizer.keyWord} </keyword>\n" 
      @tokenizer.advance
    when "SYMBOL"
      if @tokenizer.symbol == '('
        @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
        @tokenizer.advance 
        compileExpression 
        @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
        @tokenizer.advance 
      elsif @tokenizer.symbol == '~' or @tokenizer.symbol == '-'
        @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n" 
        @tokenizer.advance 
        compileTerm
      end
    when "IDENTIFIER"
        @outfile << "<identifier> #{@tokenizer.identifier} </identifier>\n"
        @tokenizer.advance
      if @tokenizer.typeToken == "SYMBOL" and (@tokenizer.symbol == '.' or @tokenizer.symbol == ')')
        if @tokenizer.symbol == "."
          @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
          @tokenizer.advance
          @outfile << "<identifier> #{@tokenizer.identifier} </identifier>\n"
          @tokenizer.advance
          @outfile << "<symbol> #{@tokenizer.symbol} </symbol>\n"
          compileExpressionList
        end

      elsif @tokenizer.typeToken == "SYMBOL" and @tokenizer.symbol == '['
        @outfile << "<symbol>#{@tokenizer.symbol} </symbol>\n"
        @tokenizer.advance 
        compileExpression 
        @outfile << "<symbol>#{@tokenizer.symbol} </symbol>\n"
        @tokenizer.advance        
      end
      
    end
    @outfile << "</term>\n"
  end

  def compileExpressionList
    @outfile << "<expressionList>\n"
    until @tokenizer.currentToken == ")"
      compileExpression
      while @tokenizer.currentToken == ","
        @tokenizer.advance
        @outfile << "<symbol> , </symbol>\n"
        compileExpression
      end
    end
    @outfile << "</expressionList>\n"
    @outfile << "<symbol> ) </symbol>\n"
  end
end