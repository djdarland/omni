########################################################## ###
#
#	File:     atsinc.rb
#
#	Subject:  Part of a Ruby program to generate a rogram ("diffeq.---")
#                  to solve a system of ordinary differential equations
#                  with long Taylor series. Intended to Support
#                  programs with Ruby (native math) Ruby (APFP),
#                  Maple 12, maxima.
#
#	Author:   Dennis J. Darland
#       Copyright (C) 2008-2012 Dennis J. Darland
#
#
############################################################################
#######################################################################
# This file is part of omnisode.
#
#    omnisode is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Foobar is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
########################################################################
#
#
#    This program is free software you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITOUT ANY WARRANTY without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###########################################################################
#
# DEBUG OPTIONS
DEBUG_TESTTERMS = false
DEBUG_DIFF = false
DEBUG_GENINFO = false
DEBUG_ESTERR = false
DEBUG_JUMP = false

# LOG OPTION
HTML_LOG = true

#Language Generated
RUBY = 1
RUBY_APFP = 2
MAPLE = 3
MAXIMA = 4
CCC = 5
CPP = 6
NOP = 0
MAPLEDBG = 0 # make 0 to disable massive DEBUG - to MAPLE to get DEBUG 
# types of Pole
NOT_GIVEN = 0 # not tested
REAL = 1
COMPLEX = 2
NO_POLE = 3 # none found
IMPOSSIBLE = 4 # none found
SOME_POLE = 5 # none found

# for param_decl
# 0 = all eqs; -1 = no eqs; > 0 = that eq
NO_EQ = -1 
ALL_EQ = 0


# whether parm_decl generates globals - func def or call
GLOBS = 1
NO_GLOBS = 2
ATOMIC_GLOBS = 3
load 'langinc.rb'

# Code Segments
ASSIGN = 1
FUNDEF = 2
FUNSEP1 = 3
FUNSEP2 = 4
FUNEND = 5
SUBSC1 = 6
SUBSC2 = 7
LINESEP = 8
LINEEND = 9
DO = 10
OD = 11
THEN = 12
ELSE = 13
ELSEIF = 14
FI = 15
EQUALS = 16
NOTEQUALS = 17
ATSFILE = 18
MAIN_DECL = 19
SUB_DECL = 20
REM = 21
SPECIFIC = 22
EVALF = 23
ARRAY1 = 24
ARRAY2 = 25
IF = 26
L_AND = 27
L_OR = 28
L_NOT = 29
RETURN = 30

# INPUT BLOCKS
EQ_BLOCK = 1
CONSTANT_BLOCK = 2
PARAMETER_BLOCK = 3
FUNCTION_BLOCK = 4


# IO LEVELS
ALWAYS = 1
INFO = 2
DEBUGL = 3
DEBUGMASSIVE = 4

# Syntax
DEBUG = 1


## Values for $sym_tbl
# Constant
NUM = 1
# Constant
IDENTIFIER = 2
NONE = -1

## Values for $series_tbl
# Constant (1 term)
ID_CONST = 1
# Linear Series (2 term)
ID_LINEAR = 2
# Full ( > 2 term) series
ID_FULL = 3

FLOATTYPE = "double "
FLOATTYPE_ARRAY = "double *"
# types

FLOAT = 1
INTEGER = 2
CHARACTER = 3
STRING = 4
BOOLEAN = 5
VOID = 6
FLOAT_ARRAY = 7
FILE_PTR = 8
LONG = 9



def st(ts)
  case ts
  when FLOAT
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return "float "
    when CCC
      return FLOATTYPE
    when CPP
      return FLOATTYPE
    end
  when FLOAT_ARRAY
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return ""
    when CCC
      return FLOATTYPE_ARRAY
    when CPP
      return FLOATTYPE_ARRAY
    end

  when FILE_PTR
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return ""
    when CCC
      return "FILE * "
    when CPP
      return "FILE * "
    end

  when INTEGER
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return "fixnum "
    when CCC
      return "int "
    when CPP
      return "int "
    end
  when LONG
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return "fixnum "
    when CCC
      return "long "
    when CPP
      return "long "
    end
  when CHARACTER
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return ""
    when CCC
      return "char "
    when CPP
      return "char "
    end
  when STRING
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return ""
    when CCC
      return "char * "
    when CPP
      return "char * "
    end
  when BOOLEAN
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return "boolean "
    when CCC
      return "unsigned char "
    when CPP
      return "unsigned char "
    end
  when VOID
    case GEN
    when RUBY
      return ""
    when RUBY_APFP
      return ""  
    when MAPLE
      return ""
    when MAXIMA
      return ""
    when CCC
      return "void "
    when CPP
      return "void "
    end
  end
end      
def st2(ts)
  if GEN == CPP or GEN == CCC then
    return st(ts)
  else
    return ""
  end
end

def sl(lang,typ,op1,op2,op3,op4)
  case typ
  when ASSIGN
    case lang
    when RUBY
      return " = "
    when RUBY_APFP
      return " = "
    when MAPLE
      return " := "
    when MAXIMA
      return " : "
    when CCC
      return " = "
    when CPP
      return " = "
    end
  when RETURN
    case lang
    when RUBY
      return " return ( " + op1 + ")"
    when RUBY_APFP
      return " return ( " + op1 + ")"
    when MAPLE
      return op1 + ";"
    when MAXIMA
      return op1
    when CCC
      return "return " + op1 + ";"
    when CPP
      return "return " + op1 + ";"
    end
  when L_AND
    case lang
    when RUBY
      return " and "
    when RUBY_APFP
      return " and "
    when MAPLE
      return " and "
    when MAXIMA
      return " and "
    when CCC
      return " && "
    when CPP
      return " && "
    end
  when L_OR
    case lang
    when RUBY
      return " or "
    when RUBY_APFP
      return " or "
    when MAPLE
      return " or "
    when MAXIMA
      return " or "
    when CCC
      return " || "
    when CPP
      return " || "
    end
  when L_NOT
    case lang
    when RUBY
      return " not "
    when RUBY_APFP
      return " not "
    when MAPLE
      return " not "
    when MAXIMA
      return " not "
    when CCC
      return " ! "
    when CPP
      return " ! "
    end
  when FUNDEF
    case lang
    when RUBY 
      $procs += 1
      $procno += 1
      return "# Begin Function number " + $procno.to_s + "\ndef "
    when RUBY_APFP
      $procs += 1
      $procno += 1
      return "# Begin Function number " + $procno.to_s + "\ndef "
    when MAPLE
      $procs += 1
      $procno += 1
      return "# Begin Function number " + $procno.to_s + "\n "
    when MAXIMA
      $procs += 1
      $procno += 1
      return "/* Begin Function number " + $procno.to_s + "*/ \n "
    when CCC
      return st(op1)
    when CPP
      return st(op1)
    end
  when FUNSEP1
    case lang
    when RUBY 
      return ""
    when RUBY_APFP
      return ""
    when MAPLE
      return " := proc"
    when MAXIMA
      return ""
    when CCC
      return ""
    when CPP
      return ""
    end
  when FUNSEP2
    case lang
    when RUBY 
      return "\n#INDENT(1)\n"
    when RUBY_APFP
      return "\n#INDENT(1)\n"
    when MAPLE
      return "\n#INDENT(1)\n"
    when MAXIMA
      return " := ( \n/*INDENT(1)*/\n"
    when CCC
      return "\n { \n/*INDENT(1)*/\n"
    when CPP
      return "\n { \n//INDENT(1)\n"

    end
  when SUBSC1
    case lang
    when RUBY
      return "[" + op1.to_s + "]"
    when RUBY_APFP
      return "[" + op1.to_s + "]"
      return ""
    when MAPLE
      return "[" + op1.to_s + "]"
      return ""
    when MAXIMA
      return "[" + op1.to_s + "]"
    when CCC
      return "[" + op1.to_s + "]"
    when CPP
      return "[" + op1.to_s + "]"
    end
  when SUBSC2
    case lang
    when RUBY 
      return "[" + op1.to_s + "][" + op2.to_s + "]"
    when RUBY_APFP
      return "[" + op1.to_s + "][" + op2.to_s + "]"
      return ""
    when MAPLE
      return "[" + op1.to_s + "," + op2.to_s + "]"
      return ""
    when MAXIMA
      return "[" + op1.to_s + "," + op2.to_s + "]"
    when CCC
      return "[" + op1.to_s + "][" + op2.to_s + "]"
    when CPP
      return "[" + op1.to_s + "][" + op2.to_s + "]"
    end
  when LINESEP
    case lang
    when RUBY 
      return ""
    when RUBY_APFP
      return ""
    when MAPLE
      return ";"
    when MAXIMA
      return ","
    when CCC
      return ";"
    when CPP
      return ";"
    end
  when LINEEND
    case lang
    when RUBY 
      return ""
    when RUBY_APFP
      return ""
    when MAPLE
      return ";"
    when MAXIMA
      return ""
    when CCC
      return ";"
    when CPP
      return ";"
    end
  when FUNEND
    case lang
    when RUBY 
      $procs -= 1
      return "\n INDENT(2)\n end # End Function number " + $procno.to_s
    when RUBY_APFP
      $procs -= 1
      return "\n INDENT(2)\n end # End Function number " + $procno.to_s
    when MAPLE
      $procs -= 1
      return "\n INDENT(2)\n end;\n# End Function number " + $procno.to_s
    when MAXIMA
      $procs -= 1
      return "\n INDENT(2)\n )$ /* End Function number" + $procno.to_s + " */\n"
    when CCC
      return "\n INDENT(2)\n } /* End Function number" + $procno.to_s + " */\n"
    when CPP
      return "\n INDENT(2)\n } // End Function number" + $procno.to_s + "\n"
    end

  when DO
    case lang
    when RUBY 
      $dos += 1
      $dono +=1
      return " do " + "# do number " + $dos.to_s + "\n # INDENT(1)\n"
    when RUBY_APFP
      $dos += 1
      $dono +=1
      return " do " + "# do number " + $dos.to_s + "\n # INDENT(1)\n"
    when MAPLE
      $dos += 1
      $dono +=1
      return " do " + "# do number " + $dos.to_s + "\n # INDENT(1)\n"
    when MAXIMA
      $dos += 1
      $dono +=1
      return " do ( /* do number " + $dos.to_s +  "*/\n/* INDENT(1) */\n"
    when CCC
      $dos += 1
      $dono +=1
      return " { /* do number " + $dos.to_s +  "*/\n/* INDENT(1) */\n"
    when CPP
      $dos += 1
      $dono +=1
      return " { /* do number " + $dos.to_s +  "*/\n/* INDENT(1) */\n"
    end
  when OD
    case lang
    when RUBY 
      $dos -= 1
      return "\nINDENT(2)\n end" + "# end do number " + ($dos + 1).to_s
    when RUBY_APFP
      return "\nINDENT(2)\n end" + "# end do number " + ($dos + 1).to_s
    when MAPLE
      $dos -= 1
      return "\nINDENT(2)\n od;" + "# end do number " + ($dos + 1).to_s
    when MAXIMA
      $dos -= 1
      return "\nINDENT(2)\n )" + "/* end do number " + ($dos + 1).to_s + "*/\n"
    when CCC
      $dos -= 1
      return "\nINDENT(2)\n }" + "/* end do number " + ($dos + 1).to_s + "*/\n"
    when CPP
      $dos -= 1
      return "\nINDENT(2)\n }" + "/* end do number " + ($dos + 1).to_s + "*/\n"
    end
  when THEN
    case lang
    when RUBY 
      $ifs += 1
      $ifno +=1
      return " then " + "# if number " + $ifs.to_s + "\n # INDENT(1)\n"
    when RUBY_APFP
      $ifs += 1
      $ifno +=1
      return " then " + "# if number " + $ifs.to_s + "\n # INDENT(1)\n"
    when MAPLE
      $ifs += 1
      $ifno +=1
      return " then " + "# if number " + $ifs.to_s + "\n # INDENT(1)\n"
    when MAXIMA
      $ifs += 1
      $ifno +=1
      return " then ( /* if number " + $ifs.to_s + "*/ \n/* INDENT(1) */\n"  
    when CCC
      $ifs += 1
      $ifno +=1
      return "\n { /* if number " + $ifs.to_s + "*/ \n/* INDENT(1) */\n"  
    when CPP
      $ifs += 1
      $ifno +=1
      return "\n { /* if number " + $ifs.to_s + "*/ \n/* INDENT(1) */\n"  
    end
  when ELSE
    case lang
    when RUBY 
      return "\n#INDENT(2)\n else \n #INDENT(1)\n "
    when RUBY_APFP
      return "\n#INDENT(2)\n else \n #INDENT(1)\n "
    when MAPLE
      return "\n#INDENT(2)\n else \n #INDENT(1)\n "
    when MAXIMA
      return "\n/*INDENT(2)*/\n ) else ( \n /*INDENT(1)*/\n "
    when CCC
      return "\n /* INDENT(2) */ \n } else { \n /* INDENT(1) */ \n "
    when CPP
      return "\n #INDENT(2) \n } else { \n # INDENT(1)\n "
    end
  when IF
    case lang
    when RUBY 
      return "if "
    when RUBY_APFP
      return "if "
    when MAPLE
      return " if "
    when MAXIMA
      return " if "
    when CCC
      return " if  "
    when CPP
      return " if "
    end
  when ELSEIF
    case lang
    when RUBY 
      return "\n #INDENT(2) \n  elsif \n"
    when RUBY_APFP
      return "\n #INDENT(2) \n  elsif \n"
    when MAPLE
      return "\n #INDENT(2) \n  elif \n"
    when MAXIMA
      return " \n /* INDENT(2) */ \n ) elseif \n"
    when CCC
      return " \n} # INDENT(2) \n } else if \n"
    when CPP
      return " \n} # INDENT(2) \n } else if \n"
    end
  when FI
    case lang
    when RUBY 
      $ifs -= 1
      return "\n # INDENT(2)\n end" + "# end if " + ($ifs + 1).to_s
    when RUBY_APFP
      $ifs -= 1
      return "\n # INDENT(2)\n end" + "# end if " + ($ifs + 1).to_s
    when MAPLE
      $ifs -= 1
      return "\n # INDENT(2)\n fi;" + "# end if " + ($ifs + 1).to_s
    when MAXIMA
      $ifs -= 1
      return "\n /* INDENT(2) */\n  )" + "/* end if " + ($ifs + 1).to_s + "*/\n"
    when CCC
      $ifs -= 1
      return "\n /* INDENT(2) */\n  }" + "/* end if " + ($ifs + 1).to_s + "*/\n"
    when CPP
      $ifs -= 1
      return "\n /* INDENT(2) */\n  }" + "/* end if " + ($ifs + 1).to_s + "*/\n"
    end
  when EQUALS
    case lang
    when RUBY  
      return " == "
    when RUBY_APFP 
      return " == "
    when MAPLE
      return " = "
    when MAXIMA
      return " = "
    when CCC
      return " == "
    when CPP
      return " == "
    end
  when NOTEQUALS
    case lang
    when RUBY  
      return " != "
    when RUBY_APFP 
      return " != "
    when MAPLE
      return " <> "
    when MAXIMA
      return " # "
    when CCC
      return " != "
    when CPP
      return " != "
    end
  when ATSFILE
    case lang
    when RUBY  
      return "atsom2.rb"
    when RUBY_APFP 
      return "atsom2.rb"
    when MAPLE
      return "atsom2.mxt"
    when MAXIMA
      return "atsom2.max"
    when CCC
     return "atsom2.c"
    when CPP
     return "atsom2.cpp"
    end
  when REM
    case lang
    when RUBY
      return "#" + op1
    when RUBY_APFP
      return "#" + op1
    when MAPLE
      return "#" + op1
    when MAXIMA
      return "/* " + op1 + " */"
    when CCC
      return "/* " + op1 + " */"
    when CPP
      return "// " + op1
    end
  when SPECIFIC
    if lang == op1
      then return " " + op2
      else return " "
    end
  when EVALF
    case lang
    when RUBY
      return "(" + op1 + ")"
    when RUBY_APFP
      return "c(" + op1 + ")"
    when MAPLE
      return "evalf(" + op1 + ")"
    when MAXIMA
      return "(" + op1 + ")"
    when CCC
      return "(" + op1 + ")"
    when CPP
      return "(" + op1 + ")"
    end
  when ARRAY1
    case lang
    when RUBY
      return op1 + " = Array.new(" + op3 + " + 1 )"  
    when RUBY_APFP
      return op1 + " = Array.new(" + op3 + " + 1 )"  
    when MAPLE
      return op1 + " := Array(1..(" + op3 + " ),[])"  
    when MAXIMA
      return "array(" + op1 + "," + op3  +  " )"
    end
  when ARRAY2
    case lang
    when RUBY
      return op1 + " = array2d(" + op3 + " + 1 , " + op4 + " + 1 )"
    when RUBY_APFP
      return op1 + " = array2d(" + op3 + " + 1 , " + op4 + " + 1 )"
    when MAPLE
      return op1 + " := Array(1..(" + op3 + " + 1 ),1..(" + op4 + " ),[])"  
    when MAXIMA
      return "array(" + op1 + ","  + op3 + " + 1 ," + op4 + " )"
    end
  end
end
