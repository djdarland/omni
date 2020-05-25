#########################################################
#
#	File:     omnisode.rb
#
#	Subject  Part of a Ruby program to generate a program ("diffeq.---")
#                  to solve a system of ordinary differential equations
#                  with long Taylor series. Intended to Support
#                  programs with Ruby (native math)),
#                  Maple 12, maxima, c and c++.
#
#	Author:   Dennis J. Darland
#
#       Copyright (C) 2008-2013 Dennis J. Darland
#
#######################################################################
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
require 'date'
require 'pathname'
load 'atsinc.rb'

def get_temp()
  re_linux = Regexp.new(/linux/)
  re_cygwin = Regexp.new(/cygwin/)
  re_windows = Regexp.new(/w32/)
  if (md = re_linux.match(RUBY_PLATFORM) and Dir.exist?('/media/ramdisk'))
  then $TEMP_DIR = '/media/ramdisk'
  elsif (md = re_linux.match(RUBY_PLATFORM))
  then  $TEMP_DIR = 'TEMP'
  elsif (md = re_cygwin.match(RUBY_PLATFORM) and Dir.exist?('/cygdrive/R/Temp'))
  then $TEMP_DIR = '/cygdrive/R/Temp'
  elsif (md = re_cygwin.match(RUBY_PLATFORM))
  then  $TEMP_DIR = 'TEMP'
  elsif  (md = re_windows.match(RUBY_PLATFORM) and Dir.exist?('R:\\Temp'))
  then $TEMP_DIR = 'R:\\Temp'
  elsif  (md = re_windows.match(RUBY_PLATFORM))
  else $TEMP_DIR = 'TEMP'
  end
end

class Global_Table_Entry
  def initialize(init_gb,typ_gb)
    @init_gb=init_gb
    @typ_gb=typ_gb
  end
  def init_gb=(other)
    @init_gb=other
  end
  def typ_gb=(other)
    @typ_gb=other
  end
  def init_gb
    @init_gb
  end
  def typ_gb
    @typ_gb
  end
end

class Global_Array_Entry
  def initialize(dim1,dim2,typ_arr,init_val)
    @dim1 = dim1
    @dim2 = dim2
    @typ_arr = typ_arr
    @init_val = init_val
  end
  def dim1=(other)
    @dim1=other
  end
  def dim2=(other)
    @dim2=other
  end
  def typ_arr=(other)
    @typ_arr=other
  end
  def init_val=(other)
    @init_val=other
  end
  def dim1
    @dim1
  end
  def dim2
    @dim2
  end
  def typ_arr
    @typ_arr
  end
  def init_val
    @init_val
  end
end

class  Token_Tables
  def initialize()
    @token_list_token1 = Array.new
    @token_list_token2 = Array.new
    @token_copy_token1 = Array.new
    @token_copy_token2 = Array.new
  end
  def push_tokens(t1,tokenval)
    @token_list_token1.push(t1)
    @token_list_token2.push(tokenval)
    @token_copy_token1.push(t1)
    @token_copy_token2.push(tokenval)
  end
  def get_token_list_1
    @token_list_token1.reverse!
    t = @token_list_token1.pop
    @token_list_token1.reverse!
    return t
  end
  def get_token_list_2
    @token_list_token2.reverse!
    t = @token_list_token2.pop
    @token_list_token2.reverse!
    return t
  end
  def get_token_copy_1
    @token_copy_token1.reverse!
    t = @token_copy_token1.pop
    @token_copy_token1.reverse!
    return t
  end
  def get_token_copy_2
    @token_copy_token2.reverse!
    t = @token_copy_token2.pop
    @token_copy_token2.reverse!
    return t
  end

end #Token_Tables

class  Eq
  def initialize(order_diff,dep_var_diff)
    @token_tables = Token_Tables.new
    @order_diff = order_diff
    @dep_var_diff = dep_var_diff
    @max_order_occurs = 0
    @tmp_series = 0
    @tmp_base = 0
  end

  def order_diff=(other)
    @order_diff = other
  end
  def max_order_occurs=(other)
    @max_order_occurs = other
  end

  def tmp_series
    @tmp_series
  end
  def tmp_series=(other)
    @tmp_series = other
  end

  def tmp_base
    @tmp_base
  end
  def tmp_base=(other)
    @tmp_base = other
  end

  def token_tables
    @token_tables
  end

  def token_list
    @token_list
  end
  def token_copy
    @token_copy
  end
  def order_diff
    @order_diff
  end
  def max_order_occurs
    @max_order_occurs
  end
  def dep_var_diff
    @dep_var_diff
  end
  def dep_var_diff=(other)
    @dep_var_diff = other
  end
end #Eq

class Eq_dep_rec

  def initialize(degree)
    @degree = degree
    @rhs_dat = Hash.new(0)
  end

  def rhs_dat
    @rhs_dat
  end
  def rhs_dat_val(i)
    @rhs_dat[i]
  end
  def rhs_dat_put(i,other)
    @rhs_dat[i]=other
  end

  def degree
    @degree
  end

end #eq_dep_rec
def add_to_constants(name_gb,init_gb,typ_gb)
  $constants[name_gb]=Global_Table_Entry.new(init_gb,typ_gb)
end
def add_to_arrays1(name_gb,dim1,nop,typ_arr,init_val)
  $arrays1[name_gb]=Global_Array_Entry.new(dim1,0,typ_arr,init_val)
end
def add_to_arrays2(name_gb,dim1,dim2,typ_arr,init_val)
  $arrays2[name_gb]=Global_Array_Entry.new(dim1,dim2,typ_arr,init_val)
end
def add_to_globals(name_gb,init_gb,typ_gb)
  $globals[name_gb]=Global_Table_Entry.new(init_gb,typ_gb)
end
def const_tran(str)
  strout = str
  $stderr.puts "tranin" + str
  strout2 = strout.gsub(/[\.]/,'D')
  strout3 = strout2.gsub(/[-]/,'M')
  strout4 = strout3.gsub(/[+]/,'P')
  $stderr.puts "tranout" + strout4
  return(strout4)
end
def const_untran(str)
  len = str.size
  strout = str[12..len]
  strout2 = strout.gsub(/[D]/,'.')
  strout3 = strout2.gsub(/[M]/,'-')
  strout4 = strout3.gsub(/[P]/,'+')
  return(strout4)
end

def generate_constants_definition(fd)
  if GEN == MAXIMA then
    $constants.each {|key , value  |
      fd.puts 'define_variable(' + key + ',' + value.init_gb + ',' + st(value.typ_gb) + ')$'
    }
  if GEN == CCC or GEN == CPP then
      $constants.each {|key , value  |
        fd.puts  st(value.typ_gb) + ' ' + key + '=' + value.init_gb + ';'
      }
    end

  end
end



def generate_constants_decl(fd)
  if GEN == MAPLE then
    $constants.each {|key, value |
      fd.puts key + ','
    }
  end
end

def generate_arrays_definition(fd)
  if GEN == MAXIMA then
    $arrays1.each {|key , value  |
      fd.puts 'completearray(' + key + ',[' + value.dim1 +  '],float)$'
    }
    $arrays2.each {|key , value  |
      fd.puts 'completearray(' + key + ',[' + value.dim1 + ',' + value.dim2 +  '],float)$'
    }
  elsif GEN == MAPLE
    $arrays1.each {|key , value  |
      fd.puts key + ':= Array(0..(' + value.dim1 +   '),[]);'
    }
    $arrays2.each {|key , value  |
      fd.puts key + ' := Array(0..(' + value.dim1 + ') ,(0..' + value.dim2 +  '+ 1),[]);'
    }
  elsif (GEN == RUBY) || (GEN == RUBY_APFP)
    $arrays1.each {|key , value  |
      fd.puts key + '= Array.new(' + value.dim1 +   ' + 1)'
    }
    $arrays2.each {|key , value  |
      fd.puts key + ' = array2d(' + value.dim1 + ' + 1 ,' + value.dim2 + ' + 1)'
    }
  elsif GEN == CPP || GEN == CCC
    $arrays1.each {|key , value  |
      fd.puts st(value.typ_arr) + ' ' + key + '[' + value.dim1 + ' + 1];'
    }
    $arrays2.each {|key , value  |
      fd.puts st(value.typ_arr) + ' ' + key + '[' + value.dim1 + ' + 1][' + value.dim2 +  ' + 1];'
    }
  end
end

def  generate_const_definition(fd)
  $const_tbl.each_key {|id|
    if (GEN == RUBY) || (GEN == RUBY_APFP) then
      fd.puts id + '= Array.new(ATS_MAX_TERMS + 1)'
    elsif GEN == CCC or GEN == CPP then
      if id != "array_m1" then
        fd.puts st2(FLOAT) + id + "[ATS_MAX_TERMS + 1];"
      end
    end
  }
end

def generate_arrays_decl(fd)
  if GEN == MAPLE then
    $arrays1.each {|key, value |
      fd.puts key + ','
    }
    $arrays2.each {|key, value |
      fd.puts key + ','
    }

  end
end

def generate_constants_assign(fd)
  if GEN == MAPLE then
    $constants.each {|key, value |
      fd.puts key + sl(GEN,ASSIGN,0,0,0,0) + value.init_gb + ";"
    }
  end
  if (GEN == RUBY) || (GEN == RUBY_APFP) then
    $constants.each {|key, value |
      fd.puts key + sl(GEN,ASSIGN,0,0,0,0) + value.init_gb
    }
  end
end
def generate_globals_assign(fd)
  if GEN == MAPLE || GEN == CCC || GEN == CPP then
    $globals.each {|key, value |
      fd.puts key + sl(GEN,ASSIGN,0,0,0,0) + value.init_gb + ";"
    }
  end
  if (GEN == RUBY) || (GEN == RUBY_APFP) then
    $globals.each {|key, value |
      fd.puts key + sl(GEN,ASSIGN,0,0,0,0) + value.init_gb
    }

  end
end




def echo_eq_db

  $eq_dep_data.each_key {|id|
    $stderr.puts "id = " + id
    $stderr.puts "degree = " + $eq_dep_data[id].degree.to_s
    $eq_dep_data[id].rhs_dat.each_key {|id2|
    $stderr.puts "id2 = " + id2
    $stderr.puts "$eq_dep_data[id].rhs_dat[id2] = " + $eq_dep_data[id].rhs_dat_val(id2).to_s
    }
  }
end

def strip_leading(str)
  re = Regexp.new("^.")
  if md = re.match(str) then
    str2 = md.post_match
  else
    str2 = str
  end
  return str2
end




def lexbox()
  linein = ""
  tok_no = 0
  $eq_no = 1
  $eq_rec = Array.new
  $stderr.puts "Created $eq_rec = " + $eq_rec.to_s
  $eq_rec[0] = Eq.new(0,"" )
  while $eq_no <= $no_eqs do
    $stderr.puts "Created $eq_rec for equation " + $eq_no.to_s
    $eq_rec[$eq_no] = Eq.new(0,"" )
    $eq_no += 1
  end
  $eq_no = 1
  t1  = lexan()
  while $eq_no <= $no_eqs and $linein != ";" do
    if DEBUG == 1 then
      $stderr.puts "entering lexbox t1 = #{t1}"
      $stderr.puts "entering lexbox $tokenval = #{$tokenval}"
      $stderr.puts "entering lexbox $linein  = #{$linein}"
    end
    while t1 != ";" and $linein != "!" do
      if DEBUG == 1 then
        $stderr.puts "lexbox t1 = #{t1}"
        $stderr.puts "lexbox $tokenval = #{$tokenval}"
        $stderr.puts "$linein = #{$linein}"
      end

      $eq_rec[$eq_no].token_tables.push_tokens(t1,$tokenval)
      tok_no += 1
      if DEBUG == 1
        $stderr.puts "lx.token_1 = #{t1} val = #{$tokenval}"
      end
      if (t1 == ";") then
        $eq_no += 1
        tok_no = 0
      end
      if t1 != ";" then
        t1  = lexan()
      end
    end
    t1  = lexan()
    $eq_no += 1
  end
  if DEBUG == 1 then
    $stderr.puts "exit lexbox t1 = #{t1}"
    $stderr.puts "exit lexbox $tokenval = #{$tokenval}"
  end
end

def get(list)

  tmp = list.reverse
  t = tmp.pop
  tmp = list.reverse
  return t
end


def lexan()
  if $linein == "!"
    return nil
  end
  if $linein == "" or $linein == ";"
    if $linein  = $infile.gets then
      $stderr.puts $linein
      $linein = $linein.chomp.lstrip.rstrip
      $lineno_in += 1
    end
  end
  if $linein == "!"
    return nil
  end
  while  ($linein == "" or $linein == ";") do
    if $linein  = $infile.gets then
      $stderr.puts $linein
      $linein = $linein.chomp.lstrip.rstrip
      $lineno_in += 1
    end
  end
  if $linein == "!"
    return nil
  end
  $linein = $linein.chomp.rstrip.lstrip

  lhs_re = Regexp.new("=")
  if md = lhs_re.match($linein) then
    equate_a = md.pre_match
    equate_b = md.post_match
    if $first == 1
      $linein = equate_a + " = 0.0 + " + equate_b
      $first = 0
    end
  end
  $lineno_in += 1
  never2 = 0
  if $linein == "" or $linein == "!" then
    if $linein  = $infile.gets then
      $linein = $linein.chomp.rstrip.lstrip
      $lineno_in += 1
      $stderr.puts "$linein = #{$linein}"
      return
    end
  end
  if $linein == "!"
    return nil
  end
  $linein = $linein.chomp.rstrip.lstrip
  $glob_t = gettoken
  if DEBUG == 1
    $stderr.puts "lexan $glob_t = #{$glob_t.to_s}"
  end
  return $glob_t
end


def gettoken
  $stderr.puts "TOP gettoken $linein = #{$linein}"
  num1_re = Regexp.new("^[-+]?[0-9]+\\.[0-9]+e[-+]?[0-9]+") #with exponent
  num2_re = Regexp.new("^[-+]?[0-9]+\\.[0-9]+") # no exponent
  num3_re = Regexp.new("^[-+]?[0-9]") # no decimal
  id_re = Regexp.new("^[a-zA-Z]+[a-zA-Z0-9]*")
  if md = num1_re.match($linein) then
    if DEBUG == 1
      $stderr.puts "gettoken linein matched num1_re"
    end
    $token = md[0]
    $li2 = md.post_match
    if DEBUG == 1
      $stderr.puts "gettoken NUM = #{$token}"
    end
    $tokenval = $token
    $linein = $li2
    const_name = "array_const_" + const_tran($token)
    $stderr.puts "IN LEXBOX 2014 name = " + const_name
    $series_tbl[const_name] = ID_CONST
    $const_tbl[const_name] = $token
    $stderr.puts "IN LEXBOX 2014 name = " + const_name
    return NUM
  elsif md = num2_re.match($linein) then
    if DEBUG == 1
      $stderr.puts "gettoken linein matched num2_re"
    end
    $token = md[0]
    $li2 = md.post_match
    if DEBUG == 1
      $stderr.puts "gettoken NUM = #{$token}"
    end
    $tokenval = $token
    $linein = $li2
    const_name = "array_const_" + const_tran($token)
    $const_tbl[const_name] = $token
    $series_tbl[const_name] = ID_CONST
    $stderr.puts "IN LEXBOX 2014 name = " + const_name
    return NUM
  elsif md = num3_re.match($linein) then
    if DEBUG == 1
      $stderr.puts "gettoken linein matched num2_re"
    end
    $token = md[0]
    $li2 = md.post_match
    if DEBUG == 1
      $stderr.puts "gettoken NUM = #{$token}"
    end
    $tokenval = $token
    $linein = $li2
    const_name = "array_const_" + const_tran($token)
    $const_tbl[const_name] = $token
    $series_tbl[const_name] = ID_CONST
    $stderr.puts "IN LEXBOX 2014 name = " + const_name
    return NUM
  elsif md = id_re.match($linein) then
    if DEBUG == 1
      $stderr.puts "gettoken linein matched id_re"
    end

    $token = md[0]
    $li2 = md.post_match
    $stderr.puts "gettoken IDENTIFIER = #{$token}"
    $stderr.puts "gettoken $sym_tbl = #{$sym_tbl}"
    if $reserved[$token] == 0 then
      lu = $sym_tbl[$token]
    end
    if (lu == -1) then
      $sym_tbl["array_" + $token] = IDENTIFIER
      $token = "array_" + $token #to make global
      if $token == $indep_var_diff
        $series_tbl[$token] = ID_LINEAR
      else
        $series_tbl[$token] = ID_FULL
      end
    end
    $stderr.puts "gettoken IDENTIFIER = #{$token}"
    $tokenval = $token
    $linein = $li2
    return IDENTIFIER
  else
    first_re = Regexp.new("^.{1}")
    if md = first_re.match($linein) then
      $token = md[0]
      $li2 = md.post_match
      if DEBUG == 1
        $stderr.puts "gettoken else clause #{$token}"
        $stderr.puts "gettoken else clause #{$li2}"
      end
      $tokenval = NONE
      if DEBUG == 1
        $stderr.puts "gettoken token = #{$token}"
      end
      $linein = $li2
      return $token
    end
  end
  return ";"
end


def parse
  $in_init_diff = 1
  $init_no = 1
  if DEBUG == 1
    $stderr.puts "0001 entering parse in diff = " + $in_diff.to_s + " in init_diff = " + $in_init_diff.to_s + "in no = " + $init_no.to_s + " eq_no = " + $eq_no.to_s
  end
  $lookahead = lexan_2
  while $lookahead
    if DEBUG == 1
      $stderr.puts "0002 while $lookahead in diff = " + $in_diff.to_s + " in init_diff = " + $in_init_diff.to_s + "in no = " + $init_no.to_s  + " eq_no = " + $eq_no.to_s
    end
    if $lookahead == ";" then
      return ";"
    end
    if DEBUG == 1
      $stderr.puts "parse $lookahead = #{$lookahead}"
      $stderr.puts "parse $tokenval = #{$tokenval}"
    end
    if ($lookahead == IDENTIFIER) then

      factor
      if DEBUG == 1
        $stderr.puts "IN PARSE $min_hdrs = #{$min_hdrs}"
      end

    end
    if $lookahead == "=" then
      $in_init_diff = 0
      meet("=")
    end
    expr
    emit_pre_assign
    emit_assign
    if $lookahead == ";" then
      return ";"

    end #?
    $lookahead = lexan_2
  end
  return
end

def expr

  term
  if $lookahead == ";" then
    return ";"
  end
  eprime

end

def eprime
  t = $lookahead
  if t == "+" || t == "-" then
    $op_stack.push(t)
    meet(t)
    e1 =  $sym_stack.pop
    term
    e2 =  $sym_stack.pop
    $series_tbl["array_tmp" + $tmp_no.to_s] = emit("array_tmp" + $tmp_no.to_s ,t,e1,e2)
    $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
    $sym_stack.push("array_tmp" + $tmp_no.to_s)
    $tmp_no += 1
    if $lookahead == ";" then
      return ";"
    end
    eprime
  end
end

def term

  factor
  if $lookahead == ";" then
    return ";"
  end
  tprime

end

def tprime
  t = $lookahead
  if t == "*" || t == "/" then
    $op_stack.push(t)
    meet(t)
    e1 =  $sym_stack.pop
    factor
    e2 =  $sym_stack.pop
    $series_tbl["array_tmp" + $tmp_no.to_s] = emit("array_tmp" + $tmp_no.to_s ,t,e1,e2)
    $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
    $sym_stack.push("array_tmp" + $tmp_no.to_s)
    $tmp_no += 1
    if $lookahead == ";" then
      return ";"
    end
    tprime
  end
end

def factor
  t = $lookahead

  case t
  when ";"
    return ";"
  when NUM
    if DEBUG == 1
      $stderr.puts "CASE SHOULD FOLLOW 0003 factor NUM in diff = " + $in_diff.to_s + " in init_diff = " + $in_init_diff.to_s + "in no = " + $init_no.to_s   + " eq_no = " + $eq_no.to_s
    end
    if $in_init_diff == 1 && $init_no == 3 then
      if DEBUG == 1 then
        $stderr.puts "CASE A"
      end
      $in_init_diff = 0

      if DEBUG == 1
        $stderr.puts "0001a Tokenval" + $tokenval.to_s
      end


      $eq_rec[$eq_no].order_diff = $tokenval.to_i

      if DEBUG == 1
        $stderr.puts "0001b Tokenval" + $tokenval.to_s + " o_d " +  $eq_rec[$eq_no].order_diff.to_s
      end

      if $tokenval.to_i > $eq_rec[$eq_no].max_order_occurs then
        $eq_rec[$eq_no].max_order_occurs = $tokenval.to_i
      end
      if $order_max < $tokenval.to_i then
        $order_max = $tokenval.to_i
      end
      if DEBUG == 1
        $stderr.puts "found order = #{$tokenval} $order_max = #{$order_max}"
        $stderr.puts "0001A  in diff = " + $in_diff.to_s + " in init_diff = " + $in_init_diff.to_s + "in no = " + $init_no.to_s   + " eq_no = " + $eq_no.to_s
      end
      $sym_stack.push($dep)
      $sym_stack.push($indep)
      $sym_stack.push( $tokenval)

      meet(NUM)
      if DEBUG == 1
        $stderr.puts "order_diff[#{$eq_no}] = #{$eq_rec[$eq_no].order_diff}"
      end
      $sym_stack.push( $tokenval.to_s)
      return $tokenval
    elsif $in_init_diff != 1 &&  $in_diff != 1 then
      if DEBUG == 1 then
        $stderr.puts "CASE B"
      end
      const_name = "array_const_" + const_tran($tokenval.to_s)
      $sym_stack.push(const_name)
      puts "const no = " + $const_no.to_s + "name = " + const_name + "value = " + t.to_s
    elsif $in_init_diff != 1 && $in_diff == 1 then
      if DEBUG == 1 then
        $stderr.puts "CASE C"
      end
      $indep = $sym_stack.pop()
      $dep = $sym_stack.pop()
      if $tokenval.to_i >  $max_order_occurs_tbl[$dep] then
        $max_order_occurs_tbl[$dep] = $tokenval.to_i
      end
      if $max_order_occurs_tbl[$dep] > $max_order
        $max_order = $max_order_occurs_tbl[$dep]
      end
      $sym_stack.push($dep)
      $sym_stack.push($indep)
      $sym_stack.push( $tokenval)
    end
    meet(NUM)
    return $tokenval
  when IDENTIFIER
    if DEBUG == 1
      $stderr.puts "0004 factor IDENTIFIER in diff = " + $in_diff.to_s + " in init_diff = " + $in_init_diff.to_s + "in no = " + $init_no.to_s   + " eq_no = " + $eq_no.to_s
    end
    if $in_init_diff == 1 && $init_no == 1  && $tokenval != "diff" then
      $eq_rec[$eq_no].dep_var_diff = $tokenval
     if DEBUG == 1
        $stderr.puts "dep_var_diff[#{$eq_no}] = #{$eq_rec[$eq_no].dep_var_diff}"
      end
      $dep = $tokenval

    elsif $in_init_diff == 1 && $init_no == 2
    then
      $indep = $tokenval
      $indep_var_diff =  $tokenval
      $series_tbl[$indep_var_diff] = ID_LINEAR
      if DEBUG == 1
        $stderr.puts "$indep_var_diff = #{$indep_var_diff}"
      end
    end
    if $in_init_diff != 1 then
      if ($tokenval == "m1") then
        $sym_tbl["array_m1"] = IDENTIFIER
        $series_tbl["array_m1"] = ID_CONST
        $sym_stack.push("array_m1")
      else
        $sym_stack.push($tokenval)
      end
    end
    if ($tokenval == "diff") then
      $in_diff = 1
    end
    if $reserved[$tokenval] > 0 then
      func_arity = $reserved[$tokenval]
    else
      func_arity = 0
    end
    if DEBUG == 1
      $stderr.puts "#{$tokenval} arity = #{func_arity}"
    end
    meet(IDENTIFIER)
    if $lookahead == '(' then
      meet("(")
      expr
      $init_no = 1
      expr_list

      case func_arity
      when 1
        e2 =  $sym_stack.pop
        e1 =  $sym_stack.pop
        $series_tbl["array_tmp" + $tmp_no.to_s] = emit_func("array_tmp" + $tmp_no.to_s ,e1,e2)
        $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
        $sym_stack.push("array_tmp" + $tmp_no.to_s)
        $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
        $tmp_no += 1
      when 2
        e3 =  $sym_stack.pop
        e2 =  $sym_stack.pop
        e1 =  $sym_stack.pop
        $series_tbl["array_tmp" + $tmp_no.to_s] = emit_func_2("array_tmp" + $tmp_no.to_s ,e1,e2,e3)
        $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
        $sym_stack.push("array_tmp" + $tmp_no.to_s)
        $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
        $tmp_no += 1
      when 3
        e4 =  $sym_stack.pop
        $stderr.puts "diff e4 = " + e4.to_s
        e3 =  $sym_stack.pop
        $stderr.puts "diff e3 = " + e3.to_s
        e2 =  $sym_stack.pop
        $stderr.puts "diff e2 = " + e2.to_s
        e1 =  $sym_stack.pop
        $stderr.puts "diff e1 = " + e1.to_s
        $series_tbl["array_tmp" + $tmp_no.to_s] = emit_func_3("array_tmp" + $tmp_no.to_s ,e1,e2,e3,e4)
        $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
        $sym_stack.push("array_tmp" + $tmp_no.to_s)
        $sym_tbl["array_tmp" + $tmp_no.to_s] = IDENTIFIER
        $tmp_no += 1
      end
      $in_diff = 0
      meet(")")
    end
  when "("
    meet(t)
    expr
    if $lookahead == ")" then
      meet($lookahead)
    else
      errormess(t,1)
    end
  else
    errormess(t,2)
  end
end
def expr_list
  t = $lookahead
  if t == "," then
    meet(t)
    $init_no += 1
    expr
    if $lookahead == ";" then
      return ";"
    end
    expr_list
  end
end
def const_tranold(nin2)
  nin = nin2.to_s
  nout = nin
  i = 0
  while i < nin.size do
    $stderr.puts "i = " + i.to_s + "nin[i] = " + nin[i].to_s
    case nin[i]
    when 45 # -
      nout[i] = 'M'
    when 46 # .
      nout[i] = 'D'
    when 43 # +
      nout[i] = 'P'
    end
    i += 1
  end
  $stderr.puts "nin = " + nin
  $stderr.puts "nout = " + nout
  return nout
end
def const_untranold(nin2)
  sz = "array_const_".size
  nin = nin2.to_s[sz..nin2.size]
  nout = nin
  i = 0
  while i < nin.size do
    $stderr.puts "i = " + i.to_s + "nin[i] = " + nin[i].to_s
    case nin[i]
    when 77 # -
      nout[i] = 45
    when 68 # .
      nout[i] = 46
    when 80
      nout[i] = 43
    end
    i += 1
  end
  $stderr.puts "nin = " + nin
  $stderr.puts "nout = " + nout
  return nout
end
def errormess(t,where)
  case $lookahead
  when NUM
    $stderr.puts "Error! processing Number"
  when IDENTIFIER
    $stderr.puts "Error! processing Identifier"
  when NONE
    $stderr.puts "Error! processing Operator"
  else ";"
    $stderr.puts "Error! processing other"
  end
  $stderr.puts "$eq_no = #{$eq_no}"
  $stderr.puts "$token_no = #{$token_no}"
  $stderr.puts "$lookahead = #{$lookahead}"
  $stderr.puts "$token = #{$token}"
  $stderr.puts "t = #{t}"
  $stderr.puts "where = #{where}"

  exit(1)
end

def init_reserved
  $stderr.puts "Initializing reserved"
  $reserved = Hash.new(0)
  $reserved["exp"] = 1
  $reserved["ln"] = 1
  $reserved["sin"] = 1
  $reserved["cos"] = 1
  $reserved["neg"] = 1
  $reserved["tan"] = 1
  $reserved["arcsin"] = 1
  $reserved["arccos"] = 1
  $reserved["arctan"] = 1
  $reserved["sinh"] = 1
  $reserved["cosh"] = 1
  $reserved["tanh"] = 1
  $reserved["Si"] = 1
  $reserved["erf"] = 1
  $reserved["sqrt"] = 1
  $reserved["expt"] = 2
  $reserved["diff"] = 3
  $stderr.puts "Initialized reserved"
  return
end

def meet(t)

  if ($lookahead == t) then
    $lookahead = lexan_2
  else
    $stderr.puts("syntax error -2 $lookahead = ",$lookahead,"t = ",t)
    exit(1)
  end
  return
end
def emit_pre_assign
  # $outfile4.puts sl(GEN,SPECIFIC,MAPLE,'print("BEGIN emit pre assign");',0,0)
  #
  # order_d is the degree of the current ($eq_no'th) equation
  # dep_var_diff is that equations dependent variable
  # pre assign computes the reduced derivative from the order (+1) of the eq
  # all subscripts are 1 higher than the order of the Taylor series term
  # as some code originated in FORTRAN
  #
  # i is the order we are working on (rhs)
  # the order of the dependent var will be i + order_d
  # pree computes thru min_hdrs, as the logic can be different in the initial terms
  # then the terms are computed in one loop
  #
  # the blocks of code are written to separate files initially, and merged later
  #
  order_d = $eq_rec[$eq_no].order_diff.to_i
  i = 1
  while i <= $min_hdrs do
    $outhdr[i].puts sl(GEN,REM,"emit pre assign xxx $eq_no = #{$eq_no} i = #{i} $min_hdrs = #{$min_hdrs}",0,0,0)
    $outhdr[i].puts "if (" + sl(GEN,L_NOT,0,0,0,0) + " " + $eq_rec[$eq_no].dep_var_diff + "_set_initial" + sl(GEN,SUBSC2,$eq_no.to_s,(i+order_d).to_s,0,0) + ")" + sl(GEN,THEN,0,0,0,0)
    $outhdr[i].puts "if (" + (i).to_s + " <= ATS_MAX_TERMS)" + sl(GEN,THEN,0,0,0,0)
    $outhdr[i].puts "temporary" + sl(GEN,ASSIGN,0,0,0,0) + "c(array_tmp" + ($tmp_no.to_i-1).to_s + sl(GEN,SUBSC1,(i).to_s,0,0,0) + ") * (expt((glob_h) , c(" + (order_d).to_s + "))) * c(factorial_3(" + (i - 1).to_s + "," + (i + order_d - 1).to_s + "))" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[i].puts "if (" + (i+order_d).to_s + " <= ATS_MAX_TERMS)" + sl(GEN,THEN,0,0,0,0)
    $outhdr[i].puts $eq_rec[$eq_no].dep_var_diff + sl(GEN,SUBSC1,(i + order_d).to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "temporary"  + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[i].puts $eq_rec[$eq_no].dep_var_diff + "_higher" + sl(GEN,SUBSC2,"1",(i + order_d).to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "temporary"  + sl(GEN,LINEEND,0,0,0,0)
    $outhdr[i].puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
    term = i + order_d - 1
    adj2 = i + order_d - 1
    adj3 = 2
    while term >= 1 do
      if adj3 <= order_d + 1 then
        if adj2 > 0 and term.to_i < $max_terms then
          $outhdr[i].puts "temporary"  + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary) / c(glob_h) * c(" + adj2.to_s + ")"   + sl(GEN,LINESEP,0,0,0,0) # 1.0 NEED check
# was          $outhdr[i].puts "temporary"  + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary) / c(glob_h) * c(" + adj2.to_s + "1)"   + sl(GEN,LINESEP,0,0,0,0) # 1.0 NEED check
        else
          $outhdr[i].puts "temporary"  + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary)"   + sl(GEN,LINESEP,0,0,0,0)
        end
        $outhdr[i].puts $eq_rec[$eq_no].dep_var_diff + "_higher" + sl(GEN,SUBSC2,adj3.to_s,term.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary)" + sl(GEN,LINESEP,0,0,0,0)
      end
      term -= 1
      adj2 -= 1
      adj3 += 1
    end
    $outhdr[i].puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    $outhdr[i].puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
    $outhdr[i].puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[i].puts "kkk" + sl(GEN,ASSIGN,0,0,0,0) + (i + 1).to_s + sl(GEN,LINESEP,0,0,0,0)
    i += 1
  end
end
def emit_assign
  order_d = $eq_rec[$eq_no].order_diff.to_i
  $outfile4.puts sl(GEN,REM,"emit assign $eq_no = #{$eq_no}",0,0,0)
  $outfile4.puts "order_d " + sl(GEN,ASSIGN,0,0,0,0) + $eq_rec[$eq_no].max_order_occurs.to_s + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "if (kkk + order_d <= ATS_MAX_TERMS)" + sl(GEN,THEN,0,0,0,0)
  $outfile4.puts "if (" + sl(GEN,L_NOT,0,0,0,0) + " " + $eq_rec[$eq_no].dep_var_diff + "_set_initial" + sl(GEN,SUBSC2,$eq_no.to_s,"kkk + order_d",0,0) + ")" + sl(GEN,THEN,0,0,0,0)
  $outfile4.puts "temporary" + sl(GEN,ASSIGN,0,0,0,0) +  "c(array_tmp" + ($tmp_no-1).to_s + sl(GEN,SUBSC1,"kkk",0,0,0) + ") * expt((glob_h) , c(order_d))  * c(factorial_3((kkk - 1),(kkk + order_d - 1)))" + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts $eq_rec[$eq_no].dep_var_diff + sl(GEN,SUBSC1,"kkk + order_d",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary)" + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts $eq_rec[$eq_no].dep_var_diff + "_higher" + sl(GEN,SUBSC2,"1","kkk + order_d",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary)" + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "term" + sl(GEN,ASSIGN,0,0,0,0) + "kkk + order_d - 1" + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "adj2" + sl(GEN,ASSIGN,0,0,0,0) + "kkk + order_d - 1"  + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "adj3" + sl(GEN,ASSIGN,0,0,0,0) + "2"  + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "while ((term >= 1)" + sl(GEN,L_AND,0,0,0,0) + "(term <= ATS_MAX_TERMS)" + sl(GEN,L_AND,0,0,0,0) + "(adj3 < order_d + 1))" + sl(GEN,DO,0,0,0,0)
  $outfile4.puts "if (adj3 <= order_d + 1)" + sl(GEN,THEN,0,0,0,0)
  $outfile4.puts "if (adj2 > 0)" + sl(GEN,THEN,0,0,0,0)
  $outfile4.puts "temporary" + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary) / c(glob_h) * c(adj2)" + sl(GEN,LINEEND,0,0,0,0)
  $outfile4.puts sl(GEN,ELSE,0,0,0,0)
  $outfile4.puts "temporary" + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary)" + sl(GEN,LINEEND,0,0,0,0)
  $outfile4.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts $eq_rec[$eq_no].dep_var_diff + "_higher" + sl(GEN,SUBSC2,"adj3","term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(temporary)" + sl(GEN,LINEEND,0,0,0,0)
  $outfile4.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "term " + sl(GEN,ASSIGN,0,0,0,0) + "term - 1" + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "adj2" + sl(GEN,ASSIGN,0,0,0,0) + "adj2 - 1" + sl(GEN,LINESEP,0,0,0,0)
  $outfile4.puts "adj3" + sl(GEN,ASSIGN,0,0,0,0) + "adj3 + 1" + sl(GEN,LINEEND,0,0,0,0)
  $outfile4.puts sl(GEN,OD,0,0,0,0)
  $outfile4.puts sl(GEN,FI,0,0,0,0)
  $outfile4.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
end

def emit_func(no,func,operand)
  case func
  when "exp"
    ret = emit_pre_exp(no,operand)
    if ret != ID_CONST then
      emit_exp(no,operand)
    end
  when "ln"
    ret = emit_pre_ln(no,operand)
    if ret != ID_CONST then
      emit_ln(no,operand)
    end
  when "sin"
    ret = emit_pre_sin(no,operand)
    if ret != ID_CONST then
      emit_sin(no,operand)
    end
  when "neg"
    ret = emit_pre_neg(no,operand)
    if ret != ID_CONST then
      emit_neg(no,operand)
    end
  when "cos"
    ret = emit_pre_cos(no,operand)
    if ret != ID_CONST then
      emit_cos(no,operand)
    end
  when "tan"
    ret = emit_pre_tan(no,operand)
    if ret != ID_CONST then
      emit_tan(no,operand)
    end
  when "sinh"
    ret = emit_pre_sinh(no,operand)
    if ret != ID_CONST then
      emit_sinh(no,operand)
    end
  when "cosh"
    ret = emit_pre_cosh(no,operand)
    if ret != ID_CONST then
      emit_cosh(no,operand)
    end
  when "tanh"
    ret = emit_pre_tanh(no,operand)
    if ret != ID_CONST then
      emit_tanh(no,operand)
    end
  when "arcsin"
    ret = emit_pre_asin(no,operand)
    if ret != ID_CONST then
      emit_asin(no,operand)
    end
  when "arccos"
    ret = emit_pre_acos(no,operand)
    if ret != ID_CONST then
      emit_acos(no,operand)
    end
  when "arctan"
    ret = emit_pre_atan(no,operand)
    if ret != ID_CONST then
      emit_atan(no,operand)
    end
  when "sqrt"
    ret = emit_pre_sqrt(no,operand)
    if ret != ID_CONST then
      emit_sqrt(no,operand)
    end
  when "Si"
    ret = emit_pre_Si(no,operand)
    if ret != ID_CONST then
      emit_Si(no,operand)
    end
  when "erf"
    ret = emit_pre_erf(no,operand)
    if ret != ID_CONST then
      emit_erf(no,operand)
    end
  end
  return ret
end
def  emit_func_2(no,func,op1,op2)
  case func
  when "expt"
    ret = emit_pre_expt(no,op1,op2)
    if ret != ID_CONST then
      emit_expt(no,op1,op2)
    end
  end
  return ret
end
def  emit_func_3(no,func,op1,op2,op3)
  case func
  when "diff"
    $stderr.puts "emit_func_3 diff op3 = " + op3.to_s
    ret = emit_pre_diff(no,op1 + "_higher",op2,op3)
    if ret != ID_CONST then
      emit_diff(no,op1 + "_higher",op2,op3)
    end
  end
  return ret
end
def emit(no,oper,operand1,operand2)
  if DEBUG == 1 then
    $stderr.puts "emit no=#{no}  oper = #{oper} operand1 = #{operand1} operand2 = #{operand2}"
  end
  case oper
  when "+"
    ret = emit_pre_add(no,operand1,operand2)
    if ret == ID_FULL then
      $any_non_linear = true
      emit_add(no,operand1,operand2)
    end
  when "-"
    ret = emit_pre_sub(no,operand1,operand2)
    if ret == ID_FULL then
      $any_non_linear = true
      emit_sub(no,operand1,operand2)
    end
  when "*"
    ret = emit_pre_mult(no,operand1,operand2)
    if ret == ID_FULL then
      $any_non_linear = true
      emit_mult(no,operand1,operand2)
    end
  when "/"
    ret = emit_pre_div(no,operand1,operand2)
    if ret == ID_FULL then
      $any_non_linear = true
      emit_div(no,operand1,operand2)
    end
  when NUM
    $stderr.puts(no, " + sl(GEN,ASSIGN,0,0,0,0) + ", oper,"(",operand1,",",operand2,")")
    if $in_init_diff != 1 then
      $sym_tbl[$tokenval] = NUM
      $series_tbl[$tokenval] = ID_CONST
      $sym_stack.push("array_const_" + const_tran(num_val.to_s))
    end
    $stderr.puts(tval)
  when IDENTIFIER
    $stderr.puts(no, " + sl(GEN,ASSIGN,0,0,0,0) + ", oper,"(",operand1,",",operand2," ")
    if $in_init_diff != 1 then
      $stderr.puts($tokenval)
      if $tokenval == $indep_var_diff then
        $series_tbl[$tokenval] = ID_LINEAR
      else
        $any_non_linear = true
        $series_tbl[$tokenval] = ID_FULL
      end
      $stderr.puts(tval)
    else
      $stderr.puts("token = ", t,"$tokenval = ",tval)
    end
  end
  return ret
end
def emit_pre_add(no,operand1,operand2)
  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre add CONST CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_CONST
      $series_tbl[no] = ID_CONST
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre add CONST - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre add CONST - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre add CONST FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre add CONST FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end

  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre add LINEAR - CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre add LINEAR - CONST $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre add LINEAR - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre add LINEAR - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre add LINEAR - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre add LINEAR - FULL $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 3
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre add LINEAR FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre add FULL - CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre add FULL CONST $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre add FULL - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre add FULL - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 3

      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre add FULL - LINEAR $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_FULL
      i = 1
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre add FULL FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " + "  + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  end
end

#################################################################


def emit_add(no,operand1,operand2)
  if $series_tbl[operand1] == ID_FULL then
    if $series_tbl[operand2] == ID_FULL then
      $outfile4.puts sl(GEN,REM,"emit FULL - FULL add $eq_no = #{$eq_no} ",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " + " + operand2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    else
      $outfile4.puts sl(GEN,REM,"emit FULL - NOT FULL add $eq_no = #{$eq_no} ",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
    end
  else
    $outfile4.puts sl(GEN,REM,"emit NOT FULL - FULL add $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand2 + sl(GEN,SUBSC1,"kkk",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  end
  if $series_tbl[operand1] != ID_FULL and $series_tbl[operand2] != ID_FULL then     $outfile4.puts sl(GEN,REM,"emit NOT FULL - NOT FULL add $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINESEP,0,0,0,0)
  end

end
####################################################################
def emit_pre_sub(no,operand1,operand2)
  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre sub CONST CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_CONST
      $series_tbl[no] = ID_CONST
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre sub CONST - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre sub CONST - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" +  operand2 + sl(GEN,SUBSC1,"2",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre sub CONST FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre sub CONST FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " - " + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end

  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre sub LINEAR - CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre sub LINEAR - CONST $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre sub LINEAR - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre sub LINEAR - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre sub LINEAR - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre sub LINEAR - FULL $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 3
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre sub LINEAR FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg( "  + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre sub FULL - CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre sub FULL CONST $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre sub FULL - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre sub FULL - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 3

      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre sub FULL - LINEAR $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_FULL
      i = 1
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre sub FULL FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " - "  + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  end
end

def emit_sub(no,operand1,operand2)
  if $series_tbl[operand1] == ID_FULL then
    if $series_tbl[operand2] == ID_FULL then
      $outfile4.puts sl(GEN,REM,"emit FULL - FULL sub $eq_no = #{$eq_no} ",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - " + operand2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    else
      $outfile4.puts sl(GEN,REM,"emit FULL - NOT FULL sub $eq_no = #{$eq_no} ",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
    end
  else
    $outfile4.puts sl(GEN,REM,"emit NOT FULL - FULL sub $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg( " + operand2 + sl(GEN,SUBSC1,"kkk",0,0,0)  + ")" + sl(GEN,LINESEP,0,0,0,0)
  end
  if $series_tbl[operand1] != ID_FULL and $series_tbl[operand2] != ID_FULL then     $outfile4.puts sl(GEN,REM,"emit NOT FULL - NOT FULL sub $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,SUBSC1,"kkk",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  end

end
def emit_pre_mult(no,operand1,operand2)
  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre mult CONST CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_CONST
      $series_tbl[no] = ID_CONST
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre mult CONST - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre mult CONST - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_FULL
      i = 1
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre mult CONST FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end

  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre mult LINEAR - CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre mult LINEAR - CONST $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 +  sl(GEN,SUBSC1,"2",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
      iii = 3
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre mult LINEAR - CONST $eq_no = #{$eq_no} iii = #{iii}",0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 +  sl(GEN,SUBSC1,iii.to_s,0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
      end
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre mult LINEAR - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre mult LINEAR - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " + " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[3].puts sl(GEN,REM,"emit pre mult LINEAR - LINEAR $eq_no = #{$eq_no} i = 3",0,0,0)
      $outhdr[3].puts no + sl(GEN,SUBSC1,"3",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) +  sl(GEN,LINESEP,0,0,0,0)
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre mult LINEAR - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre mult LINEAR FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand2 + sl(GEN,SUBSC1,(i-1).to_s,0,0,0) + " * " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " + "   + operand2 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " * " + operand1 + sl(GEN,SUBSC1,"1",0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST
      i = 1
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre mult FULL CONST $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"1".to_s,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre mult FULL LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts sl(GEN,REM,"emit pre mult LINEAR - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre mult LINEAR FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " * " + operand1 + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " + "   + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM," emit pre mult FULL FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * (" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + "))" + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM," emit pre mult FULL FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ats(" + i.to_s + "," + operand1 + "," + operand2 + ",1)" + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  end
end
def emit_mult(no,operand1,operand2)
  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit mult CONST CONST (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      return
    when ID_LINEAR
      $outfile4.puts sl(GEN,REM,"emit mult CONST LINEAR (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL
      $outfile4.puts sl(GEN,REM,"emit mult CONST FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit mult LINEAR CONST (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_LINEAR
      $outfile4.puts sl(GEN,REM,"emit mult LINEAR - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      return
    when ID_FULL
      $outfile4.puts sl(GEN,REM,"emit mult LINEAR FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand2 + sl(GEN,SUBSC1,"kkk-1".to_s,0,0,0) + " * " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " + "   + operand2 + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + " * " + operand1 + sl(GEN,SUBSC1,"1",0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit mult FULL CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_LINEAR
      $outfile4.puts sl(GEN,REM,"emit mult FULL LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk-1".to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " + "   + operand1 + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"1",0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL
      $outfile4.puts sl(GEN,REM,"emit mult FULL FULL $eq_no = #{$eq_no}",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ats(kkk," + operand1 + "," + operand2 + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  end
end
def emit_pre_div(no,operand1,operand2)
  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre div CONST CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_CONST
      $series_tbl[no] = ID_CONST
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre div CONST - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[2].puts sl(GEN,REM,"emit pre div CONST - LINEAR $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + "neg(" + no + sl(GEN,SUBSC1,(i-1).to_s,0,0,0) +  ")* " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre div CONST FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre div CONST FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + "neg(ats(" + i.to_s + "," + operand2 + "," + no + ",2)) / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end

  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre div LINEAR - CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre div LINEAR - CONST $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_LINEAR
      $series_tbl[no] = ID_LINEAR
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre div LINEAR - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre div LINEAR - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " - "  + no + sl(GEN,SUBSC1,"1",0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + ") / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 3
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre div LINEAR - LINEAR $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + " neg( " + no + sl(GEN,SUBSC1,(i-1).to_s,0,0,0) + ") * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre div LINEAR - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre div LINEAR - FULL $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " -  "+ no + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + ") / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 3
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre div LINEAR FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg( ats(" + i.to_s + "," + operand2 + "," + no + ",2)) / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST
      i = 1
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre div $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_LINEAR
      $outhdr[1].puts sl(GEN,REM,"emit pre div FULL - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre div FULL - LINEAR $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " - " + no + sl(GEN,SUBSC1,(i-1).to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + ") / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    when ID_FULL
      $outhdr[1].puts sl(GEN,REM,"emit pre div FULL - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / (" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + "))" + sl(GEN,LINESEP,0,0,0,0)
      i = 2
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre div FULL - FULL $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ((" + operand1 + sl(GEN,SUBSC1,i.to_s,0,0,0) + " - ats(" + i.to_s + "," + operand2 + "," + no + ",2))/" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      return ret
    end
  end
end
def emit_div(no,operand1,operand2)
  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit div CONST CONST (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      return
    when ID_LINEAR
      $outfile4.puts sl(GEN,REM,"emit div CONST LINEAR (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL
      $outfile4.puts sl(GEN,REM,"emit div CONST FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(ats(kkk," + operand2 + "," + no + ",2)) / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit div LINEAR CONST (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      return
    when ID_LINEAR
      $outfile4.puts sl(GEN,REM,"emit div LINEAR - LINEAR (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + no + sl(GEN,SUBSC1,"kkk-1",0,0,0) + ") * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) +  " / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL
      $outfile4.puts sl(GEN,REM,"emit div LINEAR FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +
"neg(ats(kkk," + operand2 + "," + no + ",2)) / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit div FULL CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " / "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_LINEAR
      $outfile4.puts sl(GEN,REM,"emit div FULL LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(ats(kkk," + operand2 + "," + no + "," + "2)) / " + operand2 + sl(GEN,SUBSC1,"1",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL
      $outfile4.puts sl(GEN,REM,"emit div FULL FULL $eq_no = #{$eq_no}",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ((" + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - ats(kkk," + operand2 + "," + no + ",2)) /" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  end
end


def emit_pre_diff(no,y,x,order_d)
  i = 1
  while i <= $min_hdrs do
    $outhdr[i].puts sl(GEN,REM,"emit pre diff $eq_no = #{$eq_no} i = #{i} order_d = #{order_d}",0,0,0)
    if i.to_i < $max_terms then
      $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + y + sl(GEN,SUBSC2,((order_d.to_i)+ 1).to_s, i.to_s,0,0) + sl(GEN,LINESEP,0,0,0,0)
      if GEN == MAPLE and DEBUG_DIFF then
        $outhdr[i].puts 'print("emit_pre_diff order_d = ",' + (order_d.to_i).to_s + "," + '"i = ",' + i.to_s + "," + no + sl(GEN,SUBSC1,i.to_s,0,0,0) + ')' + sl(GEN,LINESEP,0,0,0,0)
      end
      i += 1
    end
  end
  $any_non_linear = true
  $series_tbl[no] = ID_FULL
  ret = ID_FULL
  return ret
end
def emit_diff(no,y,x,order_d)
  $outfile4.puts sl(GEN,REM,"emit diff $eq_no = #{$eq_no} ",0,0,0)
  $outfile4.puts "if (kkk <= ATS_MAX_TERMS)" + sl(GEN,THEN,0,0,0,0)
  $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " " + y + sl(GEN,SUBSC2,((order_d.to_i) + 1).to_s, "kkk",0,0) + sl(GEN,LINEEND,0,0,0,0)
  if GEN == MAPLE and DEBUG_DIFF then
    $outfile4.puts 'print("emit_diff order_d = ",' + (order_d.to_i).to_s + "," + '"kkk = ", kkk,' + no + sl(GEN,SUBSC1,"kkk",0,0,0) + ')' + sl(GEN,LINESEP,0,0,0,0)
  end
  $outfile4.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
end
###################################################################
def emit_pre_exp(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre exp ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " exp(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre exp 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " exp(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre exp ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no   + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " +  operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts sl(GEN,REM,"emit pre exp 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " exp(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre exp ID_FULL iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts sl(GEN,REM,"emit pre exp  #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no   + sl(GEN,SUBSC1,iii,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_exp(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit exp CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit exp LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    $outfile4.puts sl(GEN,REM,"emit exp FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
###################################################################
def emit_pre_ln(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre ln ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ln(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre ln 1 LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ln(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre ln 2 LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    iii = 3
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre ln ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no   + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + operand + sl(GEN,SUBSC1,"2",0,0,0) + ") * " +  no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * c(" + (iii-2).to_s + ") / " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts sl(GEN,REM,"emit pre ln 1 FULL $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ln(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre ln 2 FULL $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    iii = 3
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre ln ID_FULL iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts sl(GEN,REM,"emit pre ln  #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no   + sl(GEN,SUBSC1,iii,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " ( " + operand + sl(GEN,SUBSC1,(iii).to_s,0,0,0) + " -  att(" + (iii-1).to_s + "," + operand + "," + no + ",2) ) / " + operand + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
##########################################################################
def emit_ln(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit ln CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit ln LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + operand + sl(GEN,SUBSC1,"2",0,0,0) + ") * " + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * c(kkk - 2)/ " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    $outfile4.puts sl(GEN,REM,"emit ln FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + operand + sl(GEN,SUBSC1,"kkk",0,0,0) + " - att(kkk-1," + operand + "," + no + ",2))/" + operand + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
###################################################################
def emit_pre_sqrt(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre sqrt ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sqrt(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre sqrt 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sqrt(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre sqrt 2 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / "+  no + sl(GEN,SUBSC1,"1",0,0,0) + "/glob__2" + sl(GEN,LINESEP,0,0,0,0)
    iii = 3
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre sqrt ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(ats(" + iii.to_s + "," + no + "," + no + ",2)) / " + no + sl(GEN,SUBSC1,"1",0,0,0) + " /glob__2" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts sl(GEN,REM,"emit pre sqrt 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sqrt(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre sqrt ID_FULL iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts sl(GEN,REM,"emit pre sqrt  #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand + sl(GEN,SUBSC1,iii.to_s,0,0,0) + "-ats(" + iii.to_s + "," + no + "," + no + ",2)) / " + no + sl(GEN,SUBSC1,"1",0,0,0) + " /glob__2" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end

###################################################################

def emit_sqrt(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit sqrt CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit sqrt LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(ats(kkk," + no + "," + no + ",2)) /" + no + sl(GEN,SUBSC1,"1",0,0,0) + " / glob__2" + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    $outfile4.puts sl(GEN,REM,"emit sqrt FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + operand +  sl(GEN,SUBSC1,"kkk",0,0,0) + " - ats(kkk," + no + "," + no + ",2)) / " + no + sl(GEN,SUBSC1,"1",0,0,0) + " / glob__2"  + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
###################################################################
def emit_pre_sin(no,operand)
  no_g = no + "_g"
  $sym_tbl[no_g] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre sin ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_g] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre sin 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre sin ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no   + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_g + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " +  operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_g  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + ") * " +  operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre sin FULL $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no_g + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (neg(att(" + (iii-1).to_s + "," + no + "," + operand + ",1)))" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (att(" + (iii-1).to_s + "," + no_g + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_sin(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit sin CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit sin LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_g + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    $outfile4.puts sl(GEN,REM,"emit sin FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "att(kkk-1," + no_g + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(att(kkk-1," + no + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################
def emit_pre_neg(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre neg ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre neg 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre neg 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_LINEAR
    ret = ID_LINEAR
    return ret
  when ID_FULL
    iii = 1
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre neg FULL $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + operand  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_neg(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit neg CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit neg LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + operand + ")"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    $outfile4.puts sl(GEN,REM,"emit neg FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + operand + sl(GEN,SUBSC1,"kkk",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
###################################################################
def emit_pre_cos(no,operand)
  no_g = no + "_g"
  $sym_tbl[no_g] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre cos ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_g] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre cos 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre cos ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no   + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_g + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + ") * " +  operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_g  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " +  operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre cos FULL $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no_g + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (att(" + (iii-1).to_s + "," + no + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (neg(att(" + (iii-1).to_s + "," + no_g + "," + operand + ",1)))" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_cos(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit cos CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit cos LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_g + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    $outfile4.puts sl(GEN,REM,"emit cos FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(att(kkk-1," + no_g + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "att(kkk-1," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################

###################################################################
def emit_pre_cos_bad(no,operand)
  no_g = no + "_g"
  $sym_tbl[no_g] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre cos ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_g] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre cos 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre cos ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no   + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_g + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + ") * " +  operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_g  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " +  operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii -1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre cos FULL $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no_g + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (att(" + (iii-1).to_s + "," + no + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (neg(att(" + (iii-1).to_s + "," + no_g + "," + operand + ",1)))" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_cos_bad(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit cos CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit cos LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_g + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    $outfile4.puts sl(GEN,REM,"emit cos FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(att(kkk-1," + no_g + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "att(kkk-1," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################
def emit_pre_tan(no,operand)
  no_g = no + "_g"
  $sym_tbl[no_g] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre tan ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "tan(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_g] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $sym_tbl[no_a1] = IDENTIFIER
    $sym_tbl[no_a2] = IDENTIFIER
    $outhdr[1].puts sl(GEN,REM,"emit pre tan $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) +")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre tan $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +  no_a2 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +  "neg(" + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " - ats(" + iii.to_s + "," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    $series_tbl[no_a2] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $sym_tbl[no_a1] = IDENTIFIER
    $sym_tbl[no_a2] = IDENTIFIER

    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) +")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre tan $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s  + "," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(att(" + (iii-1).to_s + "," + no_a1 + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " - ats(" + iii.to_s + "," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    $series_tbl[no_a2] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_tan(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit tan CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a2 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"   + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"   + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - ats(kkk ," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    $series_tbl[no_a2] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1 ," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(att(kkk-1," + no_a1 + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - ats(kkk ," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################
def emit_pre_sinh(no,operand)
  no_g = no + "_g"
  $sym_tbl[no_g] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre sinh ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sinh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_g] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $sym_tbl[no_g] = IDENTIFIER
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sinh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cosh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre sinh LINEAR $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_g + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_g + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $sym_tbl[no_g] = IDENTIFIER
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sinh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cosh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre sinh FULL $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_g + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_g + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_sinh(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit sinh CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit sinh LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_g + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
  no_g = no + "_g"
    $outfile4.puts sl(GEN,REM,"emit sinh FULL $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_g + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################
def emit_pre_cosh(no,operand)
  no_g = no + "_g"
  $sym_tbl[no_g] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre cosh ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cosh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_g] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $sym_tbl[no_g] = IDENTIFIER
    $outhdr[1].puts sl(GEN,REM,"emit pre cosh LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cosh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sinh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_g + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_g + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    no_g = no + "_g"
    $sym_tbl[no_g] = IDENTIFIER
    $outhdr[1].puts sl(GEN,REM,"emit pre cosh $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no_g + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sinh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cosh(" +  operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre cosh $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no_g + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_g + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
def emit_cosh(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit cosh CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit cosh LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_g + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"  + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    no_g = no + "_g"
    $outfile4.puts sl(GEN,REM,"emit cosh $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts no_g + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_g + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################
def emit_pre_tanh(no,operand)
  no_g = no + "_g"
  $sym_tbl[no_g] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre tanh ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "tanh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_g] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $sym_tbl[no_a1] = IDENTIFIER
    $sym_tbl[no_a2] = IDENTIFIER
    $outhdr[1].puts sl(GEN,REM,"emit pre tanh $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sinh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cosh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) +")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre tanh $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +  no_a2 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " - ats(" + iii.to_s + "," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    $series_tbl[no_a2] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $sym_tbl[no_a1] = IDENTIFIER
    $sym_tbl[no_a2] = IDENTIFIER
    $outhdr[1].puts sl(GEN,REM,"emit pre tanh $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sinh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cosh(" + operand + sl(GEN,SUBSC1,"1",0,0,0) +")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre tanh $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s  + "," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_a1 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " - ats(" + iii.to_s + "," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_g] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    $series_tbl[no_a2] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
####################################################################
def emit_tanh(no,operand)
  no_g = no + "_g"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit tanh CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a2 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"   + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)"   + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - ats(kkk ," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1 ," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_a1 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - ats(kkk ," + no_a2 + "," + no + ",2)) / " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################
def emit_pre_asin(no,operand)
  no_a1 = no + "_a1"
  $sym_tbl[no_a1] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre asin ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arcsin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    $series_tbl[no_a1] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre asin ID_LINEAR iii = 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts sl(GEN,REM,"emit pre asin 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arcsin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre asin ID_LINEAR iii = 2 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre asin 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" +  operand + sl(GEN,SUBSC1,"1",0,0,0) + ") * " + no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    iii = 3
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre asin ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(att(" + (iii-1).to_s + "," + no_a1 + "," + no + ",2)) / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a1  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + ") * " +  operand + sl(GEN,SUBSC1,"1",0,0,0) + " - " + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * c(" + (iii - 2).to_s + ") / c(" + (iii - 1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts sl(GEN,REM,"emit pre arcsin FULL $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arcsin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre arcsin FULL $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts "temp  " + sl(GEN,ASSIGN,0,0,0,0) + " att("+ (iii-1).to_s + "," + no_a1 + "," + no + ",2)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + operand + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " - temp) / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts "temp2  " + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + operand + "," + no + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(temp2)" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
def emit_asin(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit asin CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    no_a1 = no + "_a1"
    $outfile4.puts sl(GEN,REM,"emit asin ID_LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no   + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(att(kkk-1" + "," + no_a1 + "," + no + ",2))/" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a1  + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no + sl(GEN,SUBSC1,"kkk",0,0,0) + ") * " +  operand + sl(GEN,SUBSC1,"1",0,0,0) + " - " + no + sl(GEN,SUBSC1,"kkk-1".to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * c(kkk - 2) / c(kkk - 1)" + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    no_a1 = no + "_a1"
    $outfile4.puts sl(GEN,REM,"emit arcsin $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts "temp  " + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_a1 + "," + no + ",2)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + operand + sl(GEN,SUBSC1,"kkk",0,0,0) + " - temp) / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts "temp2  " + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + operand + "," + no + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(temp2)" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################
def emit_pre_acos(no,operand)
  no_a1 = no + "_a1"
  $sym_tbl[no_a1] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre acos ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arccos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre acos ID_LINEAR iii = 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts sl(GEN,REM,"emit pre acos 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arccos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre acos ID_LINEAR iii = 2 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre acos 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + operand + sl(GEN,SUBSC1,"2",0,0,0) + ") / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +  operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    iii = 3
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre acos ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_a1 + "," + no + ",2) / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a1  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " * " +  operand + sl(GEN,SUBSC1,"1",0,0,0) + " + " + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * c(" + (iii - 2).to_s + ") / c(" + (iii - 1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts sl(GEN,REM,"emit pre arccos FULL $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arccos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre arccos FULL $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts "temp  " + sl(GEN,ASSIGN,0,0,0,0) + " att("+ (iii-1).to_s + "," + no_a1 + "," + no + ",2)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + operand + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " + temp) / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts "temp2  " + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + operand + "," + no + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " temp2" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
def emit_acos(no,operand)
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit acos CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    no_a1 = no + "_a1"
    $outfile4.puts sl(GEN,REM,"emit acos ID_LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no   + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1" + "," + no_a1 + "," + no + ",2)/" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a1  + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,"kkk",0,0,0) + " * " +  operand + sl(GEN,SUBSC1,"1",0,0,0) + " + " + no + sl(GEN,SUBSC1,"kkk-1".to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * c(kkk - 2) / c(kkk - 1)" + sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    no_a1 = no + "_a1"
    $outfile4.puts sl(GEN,REM,"emit arcsin $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts "temp  " + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_a1 + "," + no + ",2)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "  neg(" + operand + sl(GEN,SUBSC1,"kkk",0,0,0) + " + temp) / " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts "temp2  " + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + operand + "," + no + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " temp2" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
######################################################################


######################################################################
def emit_pre_atan(no,operand)
  no_a1 = no + "_a1"
  no_a2 = no + "_a2"
  $sym_tbl[no_a1] = IDENTIFIER
  $sym_tbl[no_a2] = IDENTIFIER
  case $series_tbl[operand]
  when ID_CONST
    $outhdr[1].puts sl(GEN,REM,"emit pre atan ID_CONST $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arctan(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $series_tbl[no] = ID_CONST
    ret = ID_CONST
    return ret
  when ID_LINEAR
    $outhdr[1].puts sl(GEN,REM,"emit pre atan ID_LINEAR iii = 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts sl(GEN,REM,"emit pre atan 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arctan(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre atan ID_LINEAR iii = 2 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts sl(GEN,REM,"emit pre atan 1 $eq_no = #{$eq_no}",0,0,0)
    $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * " + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " / (" + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " + " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +   no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[2].puts no_a2 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +   no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    iii = 3
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre atan ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * " + no_a2 + sl(GEN,SUBSC1,(iii - 1).to_s,0,0,0) + " - " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * att(" + (iii - 1).to_s + "," + no_a1 + "," + no + ",2) - att(" + (iii-1).to_s + "," + no_a2 + "," + no + ",2)) / (" + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " + " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" +  sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a1  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "att(" + (iii-1).to_s + "," + no_a2 + "," + no + ",1)"  +  sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a2  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(att(" + (iii-1).to_s + "," + no_a1 + "," + no + ",1))"  +  sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    $series_tbl[no_a2] = ID_FULL
    ret = ID_FULL
    return ret
  when ID_FULL
    $outhdr[1].puts sl(GEN,REM,"emit pre arctan $eq_no = #{$eq_no}",0,0,0)
    $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " arctan(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + no + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    iii = 2
    while iii <= $min_hdrs do
      $outhdr[iii].puts sl(GEN,REM,"emit pre arctan $eq_no = #{$eq_no}",0,0,0)
      $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (ats(" + iii.to_s + "," + operand + "," + no_a2 + ",2) - " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * att(" + (iii-1).to_s + "," + no_a1 + "," + no + ",2) - att(" + (iii-1).to_s + "," + no_a2 + "," + no + ",2)) / (" + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " + " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_a2 + "," + no + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(att(" + (iii-1).to_s + "," + no_a1 + "," + no + ",1))" + sl(GEN,LINESEP,0,0,0,0)
      iii += 1
    end
    $any_non_linear = true
    $series_tbl[no] = ID_FULL
    $series_tbl[no_a1] = ID_FULL
    $series_tbl[no_a2] = ID_FULL
    ret = ID_FULL
    return ret
  end
  return ret
end
def emit_atan(no,operand)
  no_a1 = no + "_a1"
  no_a2 = no + "_a2"
  case $series_tbl[operand]
  when ID_CONST
    $outfile4.puts sl(GEN,REM,"emit atan CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
    return
  when ID_LINEAR
    $outfile4.puts sl(GEN,REM,"emit pre atan ID_LINEAR $eq_no = #{$eq_no}",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * " + no_a2 + sl(GEN,SUBSC1,"kkk- 1",0,0,0) + " - " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * att(kkk-1," + no_a1 + "," + no + ",2) -  att(kkk - 1," + no_a2 + "," + no + ",2)) / (" + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " + " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" +  sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a1  + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "att(kkk-1," + no_a2 + "," + no + ",1)"  +  sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a2  + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(att(kkk-1," + no_a1 + "," + no + ",1))"  +  sl(GEN,LINESEP,0,0,0,0)
    return
  when ID_FULL
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    $outfile4.puts sl(GEN,REM,"emit atan $eq_no = #{$eq_no} ",0,0,0)
    $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (ats(kkk," + operand + "," + no_a2 + ",2) - " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * att(kkk-1," + no_a1 + "," + no + ",2) - att(kkk-1," + no_a2 + "," + no + ",2))/(" + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " + " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_a2 + "," + no + ",1)" + sl(GEN,LINESEP,0,0,0,0)
    $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(att(kkk-1," + no_a1 + "," + no + ",1))" + sl(GEN,LINESEP,0,0,0,0)
    return
  end
end
#########################################################################
def emit_pre_expt(no,operand1,operand2)
  no_c1 = no + "_c1"
  $sym_tbl[no_c1] = IDENTIFIER
  no_a1 = no + "_a1"
  $sym_tbl[no_a1] = IDENTIFIER
  no_a2 = no + "_a2"
  $sym_tbl[no_a2] = IDENTIFIER

  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre expt CONST CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " ,c( "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " )) " + sl(GEN,LINESEP,0,0,0,0)
      ret = ID_CONST
      $series_tbl[no] = ID_CONST
      return ret
    when ID_LINEAR # case 5 in chang - done
      $outhdr[1].puts sl(GEN,REM,"emit pre expt CONST - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " , c("  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + "))"  + sl(GEN,LINESEP,0,0,0,0)

      $outhdr[1].puts no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ln(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii = 2
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre expt CONST LINEAR $eq_no = #{$eq_no} iii = #{iii}",0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    when ID_FULL  # chang case 14 done
      $outhdr[1].puts sl(GEN,REM,"emit pre expt CONST FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " ,c( "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + "))"  + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ln(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      iii = 2
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre expt CONST FULL $eq_no = #{$eq_no} iii = #{iii}",0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + "att(" + (iii-1).to_s + "," + no + "," + operand2 + ",1) * " + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    end

  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST # chang case 4 done
      $outhdr[1].puts sl(GEN,REM,"emit pre expt LINEAR - CONST $eq_no = #{$eq_no} iii = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " , c("  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + "))" + sl(GEN,LINESEP,0,0,0,0)
      iii = 2
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre expt LINEAR - CONST $eq_no = #{$eq_no} i = #{iii}",0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " - c(" + (iii-2).to_s + ")) * " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " * " + no + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / c(" + (iii - 1).to_s + ")"  + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
        end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    when ID_LINEAR # chang case 6 - done
      $outhdr[1].puts sl(GEN,REM,"emit pre expt LINEAR - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " , c("  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " )) " + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ln(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " ) " + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre expt LINEAR - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + ") / glob_h" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " * glob_h" + sl(GEN,LINESEP,0,0,0,0)
      iii = 3
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre expt LINEAR - LINEAR $eq_no = #{$eq_no} i = #{iii}",0,0,0)
        $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + ") * " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " * c(" + (iii-2).to_s + ") / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / c(" + (iii - 1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + ") * c(" + (iii-1).to_s + ") / glob_h" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(" + (iii-1).to_s + "," + no + "," + no_a2 + ",1)*glob_h / c(" + (iii-1).to_s  + ")" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    when ID_FULL  # chang case 16 done
      $outhdr[1].puts sl(GEN,REM,"emit pre expt LINEAR - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " , c("  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " )) " + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ln(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " ) " + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre expt LINEAR - FULL $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " + "  + no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + ") / glob_h" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " * glob_h" + sl(GEN,LINESEP,0,0,0,0)
      iii = 3
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre expt LINEAR - FULL $eq_no = #{$eq_no} i = #{iii}",0,0,0)
        $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + ") * " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " * c(" + (iii-2).to_s + ") / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / c(" + (iii - 1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(" + iii.to_s + "," + operand2 + "," + no_a1  + ",1) * c(" +  (iii-1).to_s + ") / glob_h" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(" + (iii-1).to_s + "," + no + "," + no_a2 + ",1)*glob_h/c(" + (iii-1).to_s  + ")" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST # chang case 13 done
      $outhdr[1].puts sl(GEN,REM,"emit pre expt FULL - CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " , c("  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + "))" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts sl(GEN,REM,"emit pre expt FULL - CONST $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + no + sl(GEN,SUBSC1,"1",0,0,0) + "*" + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      i = 3
      while i <= $min_hdrs do
        $outhdr[i].puts sl(GEN,REM,"emit pre expt $eq_no = #{$eq_no} i = #{i}",0,0,0)
        $outhdr[i].puts no + sl(GEN,SUBSC1,i.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " * att(" + (i-1).to_s + "," + no + "," + operand1 + ",1) - att(" + (i-1).to_s + "," + operand1 + "," + no + ",2))/" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        i += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    when ID_LINEAR  # chang case 15 done djdd
      $outhdr[1].puts sl(GEN,REM,"emit pre expt FULL - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " , c("  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " )) " + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ln(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " ) " + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre expt FULL - LINEAR $eq_no = #{$eq_no} i = 2",0,0,0)
      $outhdr[2].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + " * "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + ") / glob_h" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no + sl(GEN,SUBSC1,"1",0,0,0) + " * "  + no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + " * glob_h" + sl(GEN,LINESEP,0,0,0,0)
      iii = 3
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre expt FULL - LINEAR $eq_no = #{$eq_no} i = #{iii}",0,0,0)
        $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand1 + sl(GEN,SUBSC1,(iii).to_s,0,0,0) + " -att(" + (iii-1).to_s + "," + operand1 + "," + no_a1 + ",2))/ " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,(iii).to_s,0,0,0) + " * " +  operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + ") * c(" + (iii-1).to_s + ") / glob_h" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(" + (iii-1).to_s + "," + no + "," + no_a2 + ",1)*glob_h/c(" + (iii-1).to_s  + ")" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    when ID_FULL   # chang case 17 done
      $outhdr[1].puts sl(GEN,REM,"emit pre expt FULL - FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "expt(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " ,c( "  + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " )) " + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ln(" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " ) " + sl(GEN,LINESEP,0,0,0,0)
      iii = 2
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre expt FULL - FULL $eq_no = #{$eq_no} i = #{iii}",0,0,0)
        $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand1 + sl(GEN,SUBSC1,(iii).to_s,0,0,0) + " -att(" + (iii-1).to_s + "," + operand1 + "," + no_a1 + ",2))/ " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(" + iii.to_s + "," + operand1  + "," + no_a1 + ",1) * c(" + (iii-1).to_s + ") / glob_h" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(" + (iii-1).to_s + "," + no + "," + no_a2 + ",1)*glob_h/c(" + (iii-1).to_s  + ")" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      ret = ID_FULL
      $series_tbl[no] = ID_FULL
      $series_tbl[no_c1] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      return ret
    end
  end
end
###########################################################################
def emit_expt(no,operand1,operand2)
  no_c1 = no + "_c1"
  no_a1 = no + "_a1"
  no_a2 = no + "_a2"

  case $series_tbl[operand1]
  when ID_CONST
    case $series_tbl[operand2]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit expt CONST CONST (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      return
    when ID_LINEAR # chang case 5 done
      $outfile4.puts sl(GEN,REM,"emit expt CONST LINEAR (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no + sl(GEN,SUBSC1,"kkk - 1",0,0,0) + " * " +  operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk - 1)" +  sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL # chang case 14 done
      $outfile4.puts sl(GEN,REM,"emit expt CONST FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "att(kkk-1," + no + "," + operand2 + ",1) * " + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  when ID_LINEAR
    case $series_tbl[operand2]
    when ID_CONST # chang case 4 done
      $outfile4.puts sl(GEN,REM,"emit expt LINEAR CONST (NOP) $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " - c(kkk-2)) * " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " * " + no + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / c(kkk-1)"  + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_LINEAR # chang case 6 done
      $outfile4.puts sl(GEN,REM,"emit expt LINEAR - LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + ") * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " * c(kkk-2) / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / c(kkk - 1)" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + ") * c(kkk-1) / glob_h" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(kkk-1," + no + "," + no_a2 + ",1)*glob_h/c(kkk-1)" + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL # chang case 16 done
      $outfile4.puts sl(GEN,REM,"emit expt LINEAR FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + ") * " + operand1 + sl(GEN,SUBSC1,"2",0,0,0) + " * c(kkk-2) / " + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + " / c(kkk - 1)" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(kkk," + operand2 + "," + no_a1  + ",1) * c(kkk-1) / glob_h" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(kkk-1," + no + "," + no_a2 + ",1) * glob_h/c(kkk-1)" + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  when ID_FULL
    case $series_tbl[operand2]
    when ID_CONST  # chang case 13 done
      $outfile4.puts sl(GEN,REM,"emit expt FULL CONST $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " * att(" + "(kkk-1)" + "," + no + "," + operand1 + ",1) - att(kkk-1," + operand1 + "," + no + ",2))/" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_LINEAR   # chang case 15 done
      $outfile4.puts sl(GEN,REM,"emit expt FULL LINEAR $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - att(kkk-1," + operand1 + "," + no_a1 + ",2))/" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) +  " * " + operand2 + sl(GEN,SUBSC1,"1",0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand2 + sl(GEN,SUBSC1,"2",0,0,0) + ") * c(kkk-1)/glob_h" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(kkk-1," + no + "," + no_a2 + ",1) * glob_h/c(kkk-1)" + sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL   # chang case 17 done
      $outfile4.puts sl(GEN,REM,"emit expt FULL FULL $eq_no = #{$eq_no} i = 1",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + operand1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - att(kkk-1," + operand1 + "," + no_a1 + ",2))/" + operand1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(kkk," + operand1 + "," + no_a1 + ",1) * c(kkk-1)/glob_h" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ats(kkk-1," + no + "," + no_a2 + ",1) * glob_h/c(kkk-1)" + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  end
end
######################################################################

def emit_pre_erf(no,operand)
  if GEN == MAPLE then # erf built in only available in Maple (so far)
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    no_c1 = no + "_c1"
    $sym_tbl[no_a1] = IDENTIFIER
    $sym_tbl[no_a2] = IDENTIFIER
    $sym_tbl[no_c1] = IDENTIFIER
    case $series_tbl[operand]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre erf ID_CONST $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " erf(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $series_tbl[no] = ID_CONST
      ret = ID_CONST
      return ret
    when ID_LINEAR # Chang case 40
      $outhdr[1].puts sl(GEN,REM,"emit pre erf ID_LINEAR iii = 1 $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts sl(GEN,REM,"emit pre erf 1 $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " erf(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " exp(neg(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")*"  + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "glob__2 / sqrt(evalf(Pi))" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre erf ID_LINEAR iii = 2 $eq_no = #{$eq_no}",0,0,0)
      $outhdr[2].puts sl(GEN,REM,"emit pre erf 1 $eq_no = #{$eq_no}",0,0,0)
      $outhdr[2].puts no + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[2].puts no_a1 + sl(GEN,SUBSC1,"2",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +   "neg(" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + "* glob__2" + sl(GEN,LINESEP,0,0,0,0)
      iii = 3
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre erf ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"1".to_s,0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,(iii-2).to_s,0,0,0) + " * "+ operand + sl(GEN,SUBSC1,"2",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " * glob__2 / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + "/ c(" + (iii-1).to_s + ")" +  sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      $series_tbl[no] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      $series_tbl[no_c1] = ID_CONST
      ret = ID_FULL
      return ret
    when ID_FULL # Chang case 41
      $outhdr[1].puts sl(GEN,REM,"emit pre erf $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " erf(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " exp(" + no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "glob__2 / sqrt(evalf(Pi))" + sl(GEN,LINESEP,0,0,0,0)
      iii = 2
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre erf $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(ats(" + iii.to_s + "," + operand + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + " * att(" + (iii-1).to_s + "," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      $series_tbl[no] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      $series_tbl[no_c1] = ID_CONST
      ret = ID_FULL
      return ret
    end
    return ret
  else
    puts "ERROR erf not available"
  end
end
def emit_erf(no,operand)
  if GEN == MAPLE then # erf built in only available in Maple (so far)

    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    no_c1 = no + "_c1"
    case $series_tbl[operand]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit erf CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
      return
    when ID_LINEAR # Chang Case 40
      $outfile4.puts sl(GEN,REM,"emit pre erf ID_LINEAR $eq_no = #{$eq_no}",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"kkk- 1",0,0,0) + " + " + no_a1 + sl(GEN,SUBSC1,"kkk-2",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk-1)" +  sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no  + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + " * " + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + "/ c(kkk)" +  sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL
      $outfile4.puts sl(GEN,REM,"emit erf $eq_no = #{$eq_no} ",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(ats(kkk," + operand + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_a2 + "," + no_a1 + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_c1 + sl(GEN,SUBSC1,"1",0,0,0) + " * att(kkk-1," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  else
    puts "ERROR erf not available"
  end
end

######################################################################
def emit_pre_Si(no,operand)
  if GEN == MAPLE then # Si built in only available in Maple (so far)
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    no_a3 = no + "_a3"
    $sym_tbl[no_a1] = IDENTIFIER
    $sym_tbl[no_a2] = IDENTIFIER
    $sym_tbl[no_a3] = IDENTIFIER
    case $series_tbl[operand]
    when ID_CONST
      $outhdr[1].puts sl(GEN,REM,"emit pre Si ID_CONST $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " Si(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $series_tbl[no] = ID_CONST
      ret = ID_CONST
      return ret
    when ID_LINEAR # Chang case 38
      $outhdr[1].puts sl(GEN,REM,"emit pre Si ID_LINEAR iii = 1 $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts sl(GEN,REM,"emit pre Si 1 $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " Si(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a3 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +  no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " / " + operand + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      iii = 2
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre Si ID_LINEAR iii = #{iii} $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no_a1  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a2 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii - 1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a2  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg( " + no_a1 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii - 1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a3  + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + "(" + no_a1 + sl(GEN,SUBSC1,(iii).to_s,0,0,0) + " - " + no_a3 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + ")" + " / " + operand + sl(GEN,SUBSC1,"1",0,0,0)  +  sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a3 + sl(GEN,SUBSC1,(iii-1).to_s,0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(" + (iii-1).to_s + ")" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      $series_tbl[no] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      $series_tbl[no_a3] = ID_FULL
      ret = ID_FULL
      return ret
    when ID_FULL # Chang Case 39
      $outhdr[1].puts sl(GEN,REM,"emit pre arctan $eq_no = #{$eq_no}",0,0,0)
      $outhdr[1].puts no + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " Si(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " sin(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a2 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " cos(" + operand + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
      $outhdr[1].puts no_a3 + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) +  no_a1 + sl(GEN,SUBSC1,"1",0,0,0) + " / " + operand + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      iii = 2
      while iii <= $min_hdrs do
        $outhdr[iii].puts sl(GEN,REM,"emit pre Si $eq_no = #{$eq_no}",0,0,0)
        $outhdr[iii].puts no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a2 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(att(" + (iii-1).to_s + "," + no_a1 + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no_a3 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,iii.to_s,0,0,0) + " - ats(" + (iii).to_s + "," + operand + "," + no_a3 + ",2))/" + operand + sl(GEN,SUBSC1,"1",0,0,0) + sl(GEN,LINESEP,0,0,0,0)
        $outhdr[iii].puts no + sl(GEN,SUBSC1,iii.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(" + (iii-1).to_s + "," + no_a3 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
        iii += 1
      end
      $any_non_linear = true
      $series_tbl[no] = ID_FULL
      $series_tbl[no_a1] = ID_FULL
      $series_tbl[no_a2] = ID_FULL
      $series_tbl[no_a3] = ID_FULL
      ret = ID_FULL
      return ret
    end
    return ret
  else
    puts "ERROR Si not available"
  end
end
def emit_Si(no,operand)
  if GEN == MAPLE then # Si built in only available in Maple (so far)
    no_a1 = no + "_a1"
    no_a2 = no + "_a2"
    no_a3 = no + "_a3"
    case $series_tbl[operand]
    when ID_CONST
      $outfile4.puts sl(GEN,REM,"emit Si CONST (NOP) $eq_no = #{$eq_no}",0,0,0)
      return
    when ID_LINEAR # Chang case 38
      $outfile4.puts sl(GEN,REM,"emit pre Si ID_LINEAR $eq_no = #{$eq_no}",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a2 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / glob__2" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "neg(" + no_a1 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + ") * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + "/ c(kkk-1)" +  sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a3 + sl(GEN,SUBSC1,"kkk".to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "(" + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - " + no_a3 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + ") / " + operand + sl(GEN,SUBSC1,"1",0,0,0) +  sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + no_a3 + sl(GEN,SUBSC1,"kkk-1",0,0,0) + " * " + operand + sl(GEN,SUBSC1,"2",0,0,0) + " / c(kkk-1)" +  sl(GEN,LINESEP,0,0,0,0)
      return
    when ID_FULL # Chang Case 39
      no_a1 = no + "_a1"
      no_a2 = no + "_a2"
      no_a2 = no + "_a3"
      $outfile4.puts sl(GEN,REM,"emit Si $eq_no = #{$eq_no} ",0,0,0)
      $outfile4.puts no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " att(kkk-1," + no_a2 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a2 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " neg(att(kkk-1," + no_a1 + "," + operand + ",1))" + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no_a3 + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " (" + no_a1 + sl(GEN,SUBSC1,"kkk",0,0,0) + " - ats(kkk," + operand + "," + no_a3 + ",2)) / " + operand + sl(GEN,SUBSC1,"1",0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
      $outfile4.puts no + sl(GEN,SUBSC1,"kkk",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "att(kkk-1," + no_a3 + "," + operand + ",1)" + sl(GEN,LINESEP,0,0,0,0)
      return
    end
  else
    puts "ERROR Si not available"
  end
end


#-BOTTOM EMITS---------------------------------------------------------
def write_end_atomall()
  $outfile3.puts sl(GEN,REM,"Top Atomall While Loop-- outfile3",0,0,0)
  if $any_non_linear then
    $outfile3.puts "while (kkk <= ATS_MAX_TERMS)" + sl(GEN,DO,0,0,0,0)
  else
    $outfile3.puts "while (false)" + sl(GEN,DO,0,0,0,0)
  end
  return
end
def remove_array_str(line)
  line2 = line.gsub(/array_/){|s| ""}
  return line2
end

def write_set_defaults(fd) # initializations
  fd.puts sl(GEN,REM,"Write Set Defaults",0,0,0)
  if GEN == MAXIMA then
    fd.puts "glob_log_10 : log(10.0),"
  end
  fd.puts " glob_orig_start_sec  " + sl(GEN,ASSIGN,0,0,0,0) + " elapsed_time_seconds()" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts " glob_display_flag  " + sl(GEN,ASSIGN,0,0,0,0) + "  true" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts " glob_no_eqs  " + sl(GEN,ASSIGN,0,0,0,0) + $no_eqs.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_iter  " + sl(GEN,ASSIGN,0,0,0,0) + " -1" + sl(GEN,LINESEP,0,0,0,0)  # start at -1 bacause incremented at top of loop
  fd.puts "opt_iter  " + sl(GEN,ASSIGN,0,0,0,0) + " -1" + sl(GEN,LINESEP,0,0,0,0)  # start at -1 bacause incremented at top of loop
  fd.puts "glob_max_iter  " + sl(GEN,ASSIGN,0,0,0,0) + " 50000" + sl(GEN,LINESEP,0,0,0,0)
# dont use c()n next 2
  fd.puts "glob_max_hours  " + sl(GEN,ASSIGN,0,0,0,0) + " (0.0)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_max_minutes  " + sl(GEN,ASSIGN,0,0,0,0) + " (15.0)" + sl(GEN,LINESEP,0,0,0,0)

  copyecho

  fd.puts "glob_unchanged_h_cnt  " + sl(GEN,ASSIGN,0,0,0,0) + " 0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_warned  " + sl(GEN,ASSIGN,0,0,0,0) + " false" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_warned2  " + sl(GEN,ASSIGN,0,0,0,0) + " false" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_small_float  " + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_smallish_float  " + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_large_float  " + sl(GEN,ASSIGN,0,0,0,0) + " c(1.0e100)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_larger_float  " + sl(GEN,ASSIGN,0,0,0,0) + "c( 1.1e100)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_almost_1  " + sl(GEN,ASSIGN,0,0,0,0) + "c( 0.99)" + sl(GEN,LINESEP,0,0,0,0)
  return
end

def generate_globals_definition(fd)
  fd.puts sl(GEN,REM,"Top Generate Globals Definition",0,0,0)

  if GEN == MAXIMA then
      $globals.each {|key , value  |
        fd.puts 'define_variable(' + key + ',' + value.init_gb + ',' + st(value.typ_gb) + ')$'
      }
    end
  if GEN == CCC or GEN == CPP then
      $globals.each {|key , value  |
        fd.puts  st(value.typ_gb) + ' ' + key + '=' + value.init_gb + ';'
      }
    end
  if (GEN == RUBY) || (GEN == RUBY_APFP)  then
      $globals.each {|key , value  |
        fd.puts key + '=' + value.init_gb
      }
    end

  fd.puts sl(GEN,REM,"Bottom Generate Globals Deninition",0,0,0)

end





def generate_globals_decl(fd)
  fd.puts sl(GEN,REM,"Top Generate Globals Decl",0,0,0)
  if GEN == MAXIMA then
      fd.puts ")"
  elsif GEN == CCC or GEN == CPP or GEN == MAPLE then
      $globals.each {|key, value |
        fd.puts key + ','
      }
  end
  fd.puts sl(GEN,REM,"Bottom Generate Globals Decl",0,0,0)
end

def first_input_block(fd)
  open_ode_file()
  fd.puts sl(GEN,REM,"BEGIN FIRST INPUT BLOCK",0,0,0)
  copy_nth_block(fd,CONSTANT_BLOCK)
  fd.puts sl(GEN,REM,"END FIRST INPUT BLOCK",0,0,0)
  fd.puts sl(GEN,REM,"START OF INITS AFTER INPUT BLOCK",0,0,0)
  fd.puts "glob_html_log" + sl(GEN,ASSIGN,0,0,0,0) + HTML_LOG.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"END OF INITS AFTER INPUT BLOCK",0,0,0)
end


def second_input_block(fd) # input block - complete initializations
  fd.puts sl(GEN,REM,"TOP SECOND INPUT BLOCK",0,0,0)

  fd.puts sl(GEN,REM,"BEGIN SECOND INPUT BLOCK",0,0,0)
  copy_nth_block(fd,PARAMETER_BLOCK)
  fd.puts sl(GEN,REM,"END SECOND INPUT BLOCK",0,0,0)
  fd.puts sl(GEN,REM,"BEGIN INITS AFTER SECOND INPUT BLOCK",0,0,0)
  fd.puts" glob_last_good_h" + sl(GEN,ASSIGN,0,0,0,0) + "glob_h" + sl(GEN,LINESEP,0,0,0,0)
# dont use c() on next
  fd.puts "glob_max_sec  " + sl(GEN,ASSIGN,0,0,0,0) + "(60.0) * (glob_max_minutes) + (3600.0) * (glob_max_hours)" + sl(GEN,LINESEP,0,0,0,0)

end



#
# MAIN OPTIMIZE CALCULATIONS
#

def write_optimize_loop(fd) # optimize glob_h
  fd.puts "glob_check_sign" + sl(GEN,ASSIGN,0,0,0,0) + "c(my_check_sign(" + $bounds + "))" + sl(GEN,LINESEP,0,0,0,0)
  if GEN == MAXIMA then
    fd.puts "glob__pi" + sl(GEN,ASSIGN,0,0,0,0) + "3.141592654"  + sl(GEN,LINESEP,0,0,0,0)
  elsif GEN != RUBY_APFP then
    fd.puts "glob__pi" + sl(GEN,ASSIGN,0,0,0,0) + "arccos(glob__m1)"  + sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "glob__pi" + sl(GEN,ASSIGN,0,0,0,0) + "rconst.pi"  + sl(GEN,LINESEP,0,0,0,0)

  end
  if GEN == MAPLE then # all others 16
    fd.puts "glob_prec = expt(10.0,c(-Digits));"
  elsif GEN == CCC || GEN == CPP then
    fd.puts "glob_prec = 1.0e-16;"
  elsif (GEN == RUBY) then
    fd.puts "glob_prec = 1.0e-16"
#  elsif (GEN == RUBY_APFP)  then
#    fd.puts 'glob_prec = Apfp.new(50,-DESIRED_DIGITS,50,NUM_DIGITS)'
  elsif GEN == MAXIMA then # Maxima
    fd.puts "glob_prec : 1.0e-16,"
  end
  fd.puts "if (glob_optimize) " + sl(GEN,THEN,0,0,0,0)
  fd.puts sl(GEN,REM,"BEGIN OPTIMIZE CODE",0,0,0)
  fd.puts 'omniout_str(ALWAYS,"START of Optimize")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"Start Series -- INITIALIZE FOR OPTIMIZE",0,0,0)
  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "false" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_min_pole_est" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "last_min_pole_est" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_given_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_ratio_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_3_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_6_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_min_h" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs(glob_min_h) * glob_check_sign" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_max_h" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs(glob_max_h) * glob_check_sign" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs(glob_min_h) * glob_check_sign" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_display_interval" + sl(GEN,ASSIGN,0,0,0,0) + "c((float_abs(c(glob_display_interval))) * (glob_check_sign))" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "display_max" + sl(GEN,ASSIGN,0,0,0,0) + "c(" + remove_array_str($indep_var_diff) + "_end)" + " - c(" + remove_array_str($indep_var_diff) + "_start)/glob__10" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if ((glob_display_interval) > (display_max))" + sl(GEN,THEN,0,0,0,0)
  fd.puts "glob_display_interval" + sl(GEN,ASSIGN,0,0,0,0) + "c(display_max)" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

  fd.puts "chk_data()" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "min_value" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float"  + sl(GEN,LINESEP,0,0,0,0)
   fd.puts "est_answer" + sl(GEN,ASSIGN,0,0,0,0) + "est_size_answer()" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "opt_iter" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "est_needed_step_err" + sl(GEN,ASSIGN,0,0,0,0) + "estimated_needed_step_error(" + $bounds + ",glob_h,est_answer)"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"est_needed_step_err",32,est_needed_step_err,16,"")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "estimated_step_error " + sl(GEN,ASSIGN,0,0,0,0) + "glob_small_float"   + sl(GEN,LINESEP,0,0,0,0)

  fd.puts "while ((opt_iter <= 100)" + sl(GEN,L_AND,0,0,0,0) + "(" + sl(GEN,L_NOT,0,0,0,0) + "found_h))" + sl(GEN,DO,0,0,0,0)
  fd.puts 'omniout_int(ALWAYS,"opt_iter",32,opt_iter,4,"")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts $indep_var_diff + "[1]  " + sl(GEN,ASSIGN,0,0,0,0) + "c(" + remove_array_str($indep_var_diff) + "_start)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts $indep_var_diff + "[2]  " + sl(GEN,ASSIGN,0,0,0,0) + " c(glob_h)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_next_display" + sl(GEN,ASSIGN,0,0,0,0) + "c(" + remove_array_str($indep_var_diff) + "_start)" + sl(GEN,LINESEP,0,0,0,0)

  ## START all series
  eq_no = 1
  while eq_no <= $no_eqs do
    start_series(fd,eq_no)
    eq_no +=1
  end

  if $no_eqs == 1 then # if one eq this should always work
    fd.puts "atomall()" + sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "if (glob_subiter_method " + sl(GEN,EQUALS,0,0,0,0) + " 1 )" + sl(GEN,THEN,0,0,0,0)  # method 1 always also does once
    fd.puts "atomall()" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_subiter_method " + sl(GEN,EQUALS,0,0,0,0) + " 2 )" +  sl(GEN,THEN,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "1"  + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "while (subiter <= " +  $total_order.to_s + ")" + sl(GEN,DO,0,0,0,0)
    fd.puts "atomall()" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "subiter + 1"  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0)   + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "1"  + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "while (subiter <= " +  $total_order.to_s + " + ATS_MAX_TERMS)" + sl(GEN,DO,0,0,0,0)
    fd.puts "atomall()" +  sl(GEN,LINESEP,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "subiter + 1"  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0)   + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)

  end
############################
  fd.puts sl(GEN,IF,0,0,0,0) + "(glob_check_sign * glob_min_h >= glob_check_sign * glob_h)" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR MIN H")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "glob_check_sign * float_abs(glob_min_h)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "true"   + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
###############################
  fd.puts sl(GEN,IF,0,0,0,0) + "(glob_check_sign * glob_display_interval <= glob_check_sign * glob_h)" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR DISPLAY INTERVAL")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "2" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "glob_display_interval" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "true"   + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (glob_look_poles) " + sl(GEN,THEN,0,0,0,0)
##########################
  fd.puts "check_for_pole()" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
#  fd.puts "if ((opt_iter > 2)"  + sl(GEN,THEN,0,0,0,0)
# + sl(GEN,L_AND,0,0,0,0) + "(" + sl(GEN,L_NOT,0,0,0,0) + " found_h)" + sl(GEN,L_AND,0,0,0,0) + "((glob_min_pole_est < glob_lower_ratio_limit * last_min_pole_est)" + sl(GEN,L_OR,0,0,0,0) + "(glob_min_pole_est > glob_upper_ratio_limit * last_min_pole_est)))" + sl(GEN,THEN,0,0,0,0)
#  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR POLE ACCURACY")' + sl(GEN,LINESEP,0,0,0,0)
#  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "4" + sl(GEN,LINESEP,0,0,0,0)
#  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "true"   + sl(GEN,LINESEP,0,0,0,0)
#  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "glob_h/glob__2" + sl(GEN,LINESEP,0,0,0,0)
#  fd.puts "last_min_pole_est" + sl(GEN,ASSIGN,0,0,0,0) + " glob_min_pole_est" + sl(GEN,LINEEND,0,0,0,0)
#  fd.puts sl(GEN,ELSE,0,0,0,0)
#  fd.puts "last_min_pole_est" + sl(GEN,ASSIGN,0,0,0,0) + " glob_min_pole_est" + sl(GEN,LINEEND,0,0,0,0)
#  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
#  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)


#################
  fd.puts "if (" + sl(GEN,L_NOT,0,0,0,0) + "found_h)" + sl(GEN,THEN,0,0,0,0)
  # estimated_step_error is estimated error with h = glob_h
  fd.puts "est_answer" + sl(GEN,ASSIGN,0,0,0,0) + "est_size_answer()" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "est_needed_step_err" + sl(GEN,ASSIGN,0,0,0,0) + "estimated_needed_step_error(" + $bounds + ",glob_h,est_answer)"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"est_needed_step_err",32,est_needed_step_err,16,"")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "estimated_step_error" + sl(GEN,ASSIGN,0,0,0,0) + "test_suggested_h()"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"estimated_step_error",32,estimated_step_error,32,"")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (estimated_step_error < est_needed_step_err)" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"Double H and LOOP")' + sl(GEN,LINESEP,0,0,0,0)

  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "glob_h*glob__2" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,ELSE,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"Found H for OPTIMAL")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "true"   + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "3" + sl(GEN,LINESEP,0,0,0,0)

  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "glob_h/glob__2" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
##################################

  fd.puts "opt_iter" + sl(GEN,ASSIGN,0,0,0,0) + "opt_iter + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
#########################
  fd.puts "if ((" + sl(GEN,L_NOT,0,0,0,0) + "found_h)" + sl(GEN,L_AND,0,0,0,0) + "(opt_iter" + sl(GEN,EQUALS,0,0,0,0) + "1))"  + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"Beginning glob_h too large.")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "false"   + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
############################
  fd.puts sl(GEN,IF,0,0,0,0) + "(glob_check_sign * glob_max_h <= glob_check_sign * glob_h)" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR MAX H")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "glob_check_sign * float_abs(glob_max_h)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "true"   + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
###############################
  fd.puts sl(GEN,ELSE,0,0,0,0)

############################
  fd.puts "found_h" + sl(GEN,ASSIGN,0,0,0,0) + "true" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + 'glob_h * glob_check_sign' + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"END OPTIMIZE CODE",0,0,0)
end #write_optimize_loop
##########################################################################
def generate_mode_defs(fd)
  fd.puts "keepfloat : true$"
#  fd.puts "debugmode(true)$"
#  fd.puts "alias(c,float)$"
  fd.puts "alias(convfloat,float)$"
  fd.puts "alias(int_trunc,truncate)$"
  fd.puts "alias(elapsed_time_seconds,elapsed_real_time)$"
  fd.puts "alias(ln,log)$"
  fd.puts "alias(arcsin,asin)$"
  fd.puts "alias(arccos,acos)$"
  fd.puts "alias(arctan,atan)$"
  fd.puts "alias(float_abs,abs)$"

  fd.puts "mode_declare(display_poles(),fixnum)$"
  fd.puts "mode_declare(est_size_answer(),float)$"
  fd.puts "mode_declare(test_suggested_h(),float)$"
  fd.puts "mode_declare(reached_interval(),boolean)$"
  fd.puts "mode_declare(display_alot([iter],fixnum),fixnum)$"
  fd.puts "mode_declare(prog_report([x_start],float,[x_end],float),fixnum)$"
  fd.puts "mode_declare(check_for_pole(),fixnum)$"
  fd.puts "mode_declare(atomall(),fixnum)$"
  fd.puts "mode_declare(log10([x],float),float)$"
  # The following functions take strings as parameters - how to declare???
  # string function omniout_str
  # string function omniout_str_no_eol
  # string function omniout_labstr
  # string function omniout_float
  # string function omniout_int
  # string function omniout_float_arr
  # string function dump_series
  # string function dump_series_2
  # string function cs_info
  fd.puts "mode_declare(logitem_timestr([fd],fixnum,[secs_in],number),fixnum)$"
  fd.puts "mode_declare(omniout_timestr(secs_in,number),fixnum)$"
  fd.puts "mode_declare(zero_ats_ar(ar,array([" + $max_terms.to_s + "],float)),fixnum)$"
  fd.puts "mode_declare(ats([mmm_ats],fixnum,[arr_a],completearray([" + $max_terms.to_s + "],float),[arr_b],completearray([" + $max_terms.to_s + "],float),[jjj_ats],fixnum),float)$"
  fd.puts "mode_declare(att([mmm_att],fixnum,[arr_a],completearray([" + $max_terms.to_s + "],float),[arr_b],completearray([" + $max_terms.to_s + "],float),[jjj_att],fixnum),float)$"
  fd.puts "mode_declare(logitem_ditto([file],fixnum),fixnum)$"
  fd.puts "mode_declare(logitem_integer([file],fixnum,[n],fixnum),fixnum)$"
  # string function logitem_str
  fd.puts "mode_declare(logitem_good_digits([file],fixnum,[relerror],float),fixnum)$"
  # string function log_revs
  fd.puts "mode_declare(logitem_number([file],fixnum,[x],number),fixnum)$"
  fd.puts "mode_declare(logitem_pole([file],fixnum,[pole],fixnum),fixnum)$"
  fd.puts "mode_declare(logstart([file],fixnum),fixnum)$"
  fd.puts "mode_declare(logend([file],fixnum),fixnum)$"
  fd.puts "mode_declare(chk_data(),fixnum)$"
  fd.puts "mode_declare(comp_expect_sec([t_end2],float,[t_start2],float,[t2],float,[clock_sec2],float),float)$"
  fd.puts "mode_declare(comp_percent([t_end2],float,[start2],float,[t2],float),float)$"
  fd.puts "mode_declare(comp_rad_from_ratio([term1],float,[term2],float,[last_no],fixnum),float)$"
  fd.puts "mode_declare(comp_ord_from_ratio([term1],float,[term2],float,[last_no],fixnum),float)$"
  fd.puts "mode_declare(comp_rad_from_three_terms([term1],float,[term2],float,[term3],float,[last_no],fixnum),float)$"
  fd.puts "mode_declare(comp_ord_from_three_terms([term1],float,[term2],float,[term3],float,[last_no],fixnum),float)$"
  fd.puts "mode_declare(comp_rad_from_six_terms([term1],float,[term2],float,[term3],float,[term4],float,[term5],float,[term6],float,[last_no],fixnum),float)$"
  fd.puts "mode_declare(comp_ord_from_six_terms([term1],float,[term2],float,[term3],float,[term4],float,[term5],float,[term6],float,[last_no],fixnum),float)$"
  fd.puts "mode_declare(neg([nnn],float),float)$"
  fd.puts "mode_declare(factorial_2([nnn],fixnum),float)$"
  fd.puts "mode_declare(factorial_1([nnn],fixnum),float)$"
  fd.puts "mode_declare(factorial_3([mmm],fixnum,[nnn],fixnum),float)$"
  fd.puts "mode_declare(float([mmm],fixnum),float)$"
  fd.puts "mode_declare(elaped_time_seconds(),float)$"
  fd.puts "mode_declare(Si([x],float),float)$" # Dummy function
  fd.puts "mode_declare(Ci([x],float),float)$" # Dummy function
  fd.puts "mode_declare(estimated_needed_step_error([x_start],float,[x_end],float,[estimated_h],float,[estimated_answer],float),float)$"
  # don't know how to declare user defined functions - like "exact_soln_y
  fd.puts "mode_declare(my_check_sign([x0],float,[xf],float),float)$"
  fd.puts "mode_declare(main_prog(),fixnum)$"
end

############################################################################
#
# MAIN SOLVE CALCULATIONS
#

def write_solve_loop(fd) # solve equation
  fd.puts sl(GEN,REM,"BEGIN SOLUTION CODE",0,0,0)
  fd.puts "if (found_h)" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"START of Soultion")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"Start Series -- INITIALIZE FOR SOLUTION",0,0,0)
  fd.puts $indep_var_diff + "[1]  " + sl(GEN,ASSIGN,0,0,0,0) + "c(" + remove_array_str($indep_var_diff) + "_start)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts $indep_var_diff + "[2]  " + sl(GEN,ASSIGN,0,0,0,0) + " c(glob_h)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_next_display" + sl(GEN,ASSIGN,0,0,0,0) + "c(" + remove_array_str($indep_var_diff) + "_start)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_min_pole_est" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_given_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_ratio_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_3_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_least_6_sing" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)

  ## START all series
  eq_no = 1
  while eq_no <= $no_eqs do
    start_series(fd,eq_no)
    eq_no +=1
  end
  fd.puts "current_iter  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)

  fd.puts "glob_clock_start_sec  " + sl(GEN,ASSIGN,0,0,0,0) + "elapsed_time_seconds()" + sl(GEN,LINESEP,0,0,0,0)

  if GEN == RUBY and false then # debug for h5h3.ode
    fd.puts 'puts "x = ".ljust(32) + array_x[1].to_s'
    fd.puts 'puts "xp =".ljust(32) + array_x[2].to_s'
    fd.puts 'puts "glob_h =".ljust(32) + glob_h.to_s'
    fd.puts 'dbg_i = 1'
    fd.puts 'while dbg_i <= 8 do'
    fd.puts 'str = ("y[" + dbg_i.to_s + "] =").ljust(32) + array_y[dbg_i].to_s'
    fd.puts 'puts str'

    fd.puts 'dbg_j = 1'
    fd.puts 'while dbg_j <= 6 do'
    fd.puts 'if dbg_i + dbg_j <= 7 then '
    fd.puts 'str = ("y_higher[" + dbg_j.to_s + "][" + dbg_i.to_s + "] = ").ljust(32) + array_y_higher[dbg_j][dbg_i].to_s'
    fd.puts 'puts str'
    fd.puts 'if ((dbg_j + dbg_i - 1) % 4) == 1 then puts "should be ".ljust(32) + ( cos(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 2 then puts "should be ".ljust(32) + ( -(sin(array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 3 then  puts "should be ".ljust(32) + ( -(cos(array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'else puts "should be ".ljust(32) + ( (sin (array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'

    fd.puts 'end'
    fd.puts 'end'
    fd.puts 'dbg_j = dbg_j + 1'
    fd.puts 'end'
    fd.puts 'dbg_i = dbg_i + 1'
    fd.puts 'end'
  end

  if GEN == RUBY and false then # debug for diff2.ode
    fd.puts 'puts "x = ".ljust(32) + array_x[1].to_s'
    fd.puts 'puts "xp =".ljust(32) + array_x[2].to_s'
    fd.puts 'puts "glob_h =".ljust(32) + glob_h.to_s'
    fd.puts 'dbg_i = 1'
    fd.puts 'while dbg_i <= 8 do'
    fd.puts 'puts ("y[" + dbg_i.to_s + "] =").ljust(32) + array_y[dbg_i].to_s'

    fd.puts 'dbg_j = 1'
    fd.puts 'while dbg_j <= 3 do'
    fd.puts 'if dbg_i + dbg_j <= 4 then '
    fd.puts 'puts ("y_higher[" + dbg_j.to_s + "][" + dbg_i.to_s + "] = ").ljust(32) + array_y_higher[dbg_j][dbg_i].to_s'

    fd.puts 'if ((dbg_j + dbg_i - 1) % 4) == 1 then puts "should be ".ljust(32) + ( -cos(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 2 then puts "should be ".ljust(32) + ( sin(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 3 then  puts "should be ".ljust(32) + ( cos(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'else puts "should be ".ljust(32) + ( -(sin (array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'

    fd.puts 'end'
    fd.puts 'end'
    fd.puts 'dbg_j = dbg_j + 1'
    fd.puts 'end'
    fd.puts 'dbg_i = dbg_i + 1'
    fd.puts 'end'
  end

  fd.puts "glob_clock_sec  " + sl(GEN,ASSIGN,0,0,0,0) + " elapsed_time_seconds()" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_iter  " + sl(GEN,ASSIGN,0,0,0,0) + " 0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str(DEBUGL," ")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_reached_optimal_h  " + sl(GEN,ASSIGN,0,0,0,0) + " true" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_optimal_clock_start_sec" + sl(GEN,ASSIGN,0,0,0,0) + "elapsed_time_seconds()" + sl(GEN,LINESEP,0,0,0,0)
#  fd.puts "while ((glob_iter < glob_max_iter) " + sl(GEN,L_AND,0,0,0,0) + "(glob_check_sign * " + $indep_var_diff + "[1] < glob_check_sign * " + remove_array_str($indep_var_diff) + "_end )) " + sl(GEN,DO,0,0,0,0) + sl(GEN,REM,"left paren 0001C",0,0,0)
  fd.puts "while ((glob_iter < glob_max_iter) " + sl(GEN,L_AND,0,0,0,0) + "(glob_check_sign * " + $indep_var_diff + "[1] < glob_check_sign * " + remove_array_str($indep_var_diff) + "_end ) " + sl(GEN,L_AND,0,0,0,0) + " (((glob_clock_sec) - (glob_orig_start_sec)) < (glob_max_sec)))" + sl(GEN,DO,0,0,0,0) + sl(GEN,REM,"left paren 0001C",0,0,0)
#  fd.puts "while (glob_iter < glob_max_iter) " + sl(GEN,DO,0,0,0,0) + sl(GEN,REM,"left paren 0001C",0,0,0)
  if GEN == RUBY_APFP and false then
    fd.puts '$stderr.puts "############################################"'
    fd.puts '$stderr.puts "TOPWHILE glob_iter= " + glob_iter.to_s'
    fd.puts '$stderr.puts "TOPWHILE glob_max_iter= " + glob_max_iter.to_s'
    fd.puts '$stderr.puts "TOPWHILE glob_check_sign= " + glob_check_sign.to_s'
    fd.puts '$stderr.puts "TOPWHILE array_x[1]= " + array_y[1].to_s'
    fd.puts '$stderr.puts "TOPWHILE x_end= " + x_end.to_s'
    fd.puts '$stderr.puts "TOPWHILE x_cmp = " + (array_x[1] * glob_check_sign < x_end * glob_check_sign).to_s'
    fd.puts '$stderr.puts "TOPWHILE glob_clock_sec= " + glob_clock_sec.to_s'
    fd.puts '$stderr.puts "TOPWHILE glob_orig_start_sec= " + glob_orig_start_sec.to_s'
    fd.puts '$stderr.puts "TOPWHILE [diff_sec]= " + (glob_clock_sec-glob_orig_start_sec).to_s'

    fd.puts '$stderr.puts "TOPWHILE glob_max_sec= " + glob_max_sec.to_s'
    fd.puts '$stderr.puts "############################################"'

  end

  fd.puts "if (reached_interval())" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(INFO," ")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str(INFO,"TOP MAIN SOLVE Loop")' + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_iter  " + sl(GEN,ASSIGN,0,0,0,0) + " glob_iter + 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_clock_sec  " + sl(GEN,ASSIGN,0,0,0,0) + "elapsed_time_seconds()" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "track_estimated_error()" +  sl(GEN,LINESEP,0,0,0,0)
  #
  # MAIN CALCULATIONS
  #
  #Compute Taylor series based on recurence relations.
  if GEN == MAPLE and DEBUG_GENINFO then
    fd.puts sl(GEN,SPECIFIC,MAPLE,'print("Above3 atomall");',0,0)
    fd.puts 'print("glob_iter=",glob_iter,"time =",(glob_clock_sec - glob_orig_start_sec));'
  end

  if $no_eqs == 1 then # if one eq this should always work
    fd.puts "atomall()" + sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "if (glob_subiter_method " + sl(GEN,EQUALS,0,0,0,0) + " 1 )" + sl(GEN,THEN,0,0,0,0)  # method 1 always also does once
    fd.puts "atomall()" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_subiter_method " + sl(GEN,EQUALS,0,0,0,0) + " 2 )" +  sl(GEN,THEN,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "1"  + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "while (subiter <= " +  $total_order.to_s + ")" + sl(GEN,DO,0,0,0,0)
    fd.puts "atomall()" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "subiter + 1"  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0)   + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "1"  + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "while (subiter <= " +  $total_order.to_s + " + ATS_MAX_TERMS)" + sl(GEN,DO,0,0,0,0)
    fd.puts "atomall()" +  sl(GEN,LINESEP,0,0,0,0)
    fd.puts "subiter" + sl(GEN,ASSIGN,0,0,0,0) + "subiter + 1"  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0)   + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)

  end
  fd.puts "track_estimated_error()" +  sl(GEN,LINESEP,0,0,0,0)

  # DISPLAY NEW POINT
  fd.puts 'display_alot(current_iter)'   + sl(GEN,LINESEP,0,0,0,0)

  if GEN == RUBY and false then # debug for h5h3.ode
    fd.puts 'puts "x = ".ljust(32) + array_x[1].to_s'
    fd.puts 'puts "xp =".ljust(32) + array_x[2].to_s'
    fd.puts 'puts "glob_h =".ljust(32) + glob_h.to_s'
    fd.puts 'dbg_i = 1'
    fd.puts 'while dbg_i <= 8 do'
    fd.puts 'str = ("y[" + dbg_i.to_s + "] =").ljust(32) + array_y[dbg_i].to_s'
    fd.puts 'puts str'

    fd.puts 'dbg_j = 1'
    fd.puts 'while dbg_j <= 6 do'
    fd.puts 'if dbg_i + dbg_j <= 7 then '
    fd.puts 'str = ("y_higher[" + dbg_j.to_s + "][" + dbg_i.to_s + "] = ").ljust(32) + array_y_higher[dbg_j][dbg_i].to_s'
    fd.puts 'puts str'
    fd.puts 'if ((dbg_j + dbg_i - 1) % 4) == 1 then puts "should be ".ljust(32) + ( cos(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 2 then puts "should be ".ljust(32) + ( -(sin(array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 3 then  puts "should be ".ljust(32) + ( -(cos(array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'else puts "should be ".ljust(32) + ( (sin (array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'

    fd.puts 'end'
    fd.puts 'end'
    fd.puts 'dbg_j = dbg_j + 1'
    fd.puts 'end'
    fd.puts 'dbg_i = dbg_i + 1'
    fd.puts 'end'
  end
  fd.puts "if (glob_look_poles) " + sl(GEN,THEN,0,0,0,0)

  fd.puts "check_for_pole()" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (reached_interval())" + sl(GEN,THEN,0,0,0,0)
  fd.puts "glob_next_display " + sl(GEN,ASSIGN,0,0,0,0) + "glob_next_display + glob_display_interval" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)

  # TO NEXT POINT
  fd.puts $indep_var_diff + "[1]  " + sl(GEN,ASSIGN,0,0,0,0) + $indep_var_diff + "[1] + glob_h" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts $indep_var_diff + "[2]  " + sl(GEN,ASSIGN,0,0,0,0) + " glob_h" + sl(GEN,LINEEND,0,0,0,0)
  eq_no = 1
  while eq_no <= $no_eqs do
    jump_series(fd,eq_no)
    eq_no +=1
  end

  # DISPLAY NEW POINT

  if GEN == RUBY and false then # debug for h5h3.ode
    fd.puts 'puts "x = ".ljust(32) + array_x[1].to_s'
    fd.puts 'puts "xp =".ljust(32) + array_x[2].to_s'
    fd.puts 'puts "glob_h =".ljust(32) + glob_h.to_s'
    fd.puts 'dbg_i = 1'
    fd.puts 'while dbg_i <= 8 do'
    fd.puts 'str = ("y[" + dbg_i.to_s + "] =").ljust(32) + array_y[dbg_i].to_s'
    fd.puts 'puts str'

    fd.puts 'dbg_j = 1'
    fd.puts 'while dbg_j <= 6 do'
    fd.puts 'if dbg_i + dbg_j <= 7 then '
    fd.puts 'str = ("y_higher[" + dbg_j.to_s + "][" + dbg_i.to_s + "] = ").ljust(32) + array_y_higher[dbg_j][dbg_i].to_s'
    fd.puts 'puts str'
    fd.puts 'if ((dbg_j + dbg_i - 1) % 4) == 1 then puts "should be ".ljust(32) + ( cos(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 2 then puts "should be ".ljust(32) + ( -(sin(array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 3 then  puts "should be ".ljust(32) + ( -(cos(array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'else puts "should be ".ljust(32) + ( (sin (array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'

    fd.puts 'end'
    fd.puts 'end'
    fd.puts 'dbg_j = dbg_j + 1'
    fd.puts 'end'
    fd.puts 'dbg_i = dbg_i + 1'
    fd.puts 'end'
  end

  if GEN == RUBY and false then # debug for diff2.ode
    fd.puts 'puts "x = ".ljust(32) + array_x[1].to_s'
    fd.puts 'puts "xp =".ljust(32) + array_x[2].to_s'
    fd.puts 'puts "glob_h =".ljust(32) + glob_h.to_s'
    fd.puts 'dbg_i = 1'
    fd.puts 'while dbg_i <= 8 do'
    fd.puts 'puts ("y[" + dbg_i.to_s + "] =").ljust(32) + array_y[dbg_i].to_s'

    fd.puts 'dbg_j = 1'
    fd.puts 'while dbg_j <= 3 do'
    fd.puts 'if dbg_i + dbg_j <= 4 then '
    fd.puts 'puts ("y_higher[" + dbg_j.to_s + "][" + dbg_i.to_s + "] = ").ljust(32) + array_y_higher[dbg_j][dbg_i].to_s'

    fd.puts 'if ((dbg_j + dbg_i - 1) % 4) == 1 then puts "should be ".ljust(32) + ( -cos(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 2 then puts "should be ".ljust(32) + ( sin(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'elsif ((dbg_j + dbg_i - 1) % 4) == 3 then  puts "should be ".ljust(32) + ( cos(array_x[1]) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'
    fd.puts 'else puts "should be ".ljust(32) + ( -(sin (array_x[1])) * expt(glob_h,c(dbg_i-1)) / c(factorial_1(dbg_i-1))).to_s'

    fd.puts 'end'
    fd.puts 'end'
    fd.puts 'dbg_j = dbg_j + 1'
    fd.puts 'end'
    fd.puts 'dbg_i = dbg_i + 1'
    fd.puts 'end'
  end
  if GEN == RUBY_APFP and false then
    fd.puts '$stderr.puts "############################################"'
    fd.puts '$stderr.puts "BOTWHILE glob_iter= " + glob_iter.to_s'
    fd.puts '$stderr.puts "BOTWHILE glob_max_iter= " + glob_max_iter.to_s'
    fd.puts '$stderr.puts "BOTWHILE glob_check_sign= " + glob_check_sign.to_s'
    fd.puts '$stderr.puts "BOTWHILE array_x[1]= " + array_y[1].to_s'
    fd.puts '$stderr.puts "BOTWHILE x_end= " + x_end.to_s'
    fd.puts '$stderr.puts "BOTWHILE x_cmp = " + (array_x[1] * glob_check_sign < x_end * glob_check_sign).to_s'

    fd.puts '$stderr.puts "BOTWHILE glob_clock_sec= " + glob_clock_sec.to_s'
    fd.puts '$stderr.puts "BOTWHILE glob_orig_start_sec= " + glob_orig_start_sec.to_s'
    fd.puts '$stderr.puts "BOTWHILE [diff_sec]= " + (glob_clock_sec-glob_orig_start_sec).to_s'

    fd.puts '$stderr.puts "BOTWHILE glob_max_sec= " + glob_max_sec.to_s'
    fd.puts '$stderr.puts "############################################"'
  end

  fd.puts  sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0) + sl(GEN,REM,"right paren 0001C",0,0,0)
  fd.puts 'omniout_str(ALWAYS,"Finished!")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (glob_iter >= glob_max_iter) " + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"Maximum Iterations Reached before Solution Completed!")' + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (elapsed_time_seconds() - (glob_orig_start_sec) >= (glob_max_sec  ))" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"Maximum Time Reached before Solution Completed!")' + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_clock_sec  " + sl(GEN,ASSIGN,0,0,0,0) + "elapsed_time_seconds()" + sl(GEN,LINESEP,0,0,0,0)
  eq_no = 1
  while eq_no <= $no_eqs do
    fd.puts 'omniout_str(INFO,"' + $equation[eq_no] + '")' + sl(GEN,LINESEP,0,0,0,0)
    eq_no += 1
  end
  label_str = "Iterations".to_s.ljust(32," ")
  fd.puts 'omniout_int(INFO,"' + label_str + '",32,glob_iter,4," ")'
  fd.puts  sl(GEN,LINESEP,0,0,0,0)
  fd.puts "prog_report(" + $bounds + ")" + sl(GEN,LINESEP,0,0,0,0)
  if $html_log then
    write_html_log(fd)
    write_html_close()
  end

  fd.puts sl(GEN,LINEEND,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
  if GEN == MAPLE and DEBUG_GENINFO then
    fd.puts 'print("glob_iter=",glob_iter,"time =",(glob_clock_sec - glob_orig_start_sec));'
  fd.puts sl(GEN,REM,"END SOLUTION CODE",0,0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
  end
  fd.puts sl(GEN,FI,0,0,0,0)
end #write_solve_loop

####################################################################

def general_radius(fd,test_number)
#
# test number = 1 for ratio test
# test number = 2 for three term test (real singularity)
# test number = 3 for six term test (complex singularity)
#
  eq_no = 1
  rad_poles = "array_rad_test_poles"
  ord_poles = "array_ord_test_poles"
  while eq_no <= $no_eqs do
    fd.puts "tmp_rad" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "prev_tmp_rad" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "tmp_ratio" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "rad_c" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts rad_poles + sl(GEN,SUBSC2,eq_no.to_s,test_number.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts ord_poles + sl(GEN,SUBSC2,eq_no.to_s,test_number.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
    order_diff = $eq_rec[eq_no].order_diff.to_s
    array_y_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
    fd.puts "found_sing" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "last_no" + sl(GEN,ASSIGN,0,0,0,0) + " ATS_MAX_TERMS - " + order_diff + " - 10" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "cnt" + sl(GEN,ASSIGN,0,0,0,0) + " 0" + sl(GEN,LINESEP,0,0,0,0)
    if test_number == 1 then
      fd.puts "while (last_no < ATS_MAX_TERMS-3" + sl(GEN,L_AND,0,0,0,0) + "found_sing" + sl(GEN,EQUALS,0,0,0,0) + "1)"  + sl(GEN,DO,0,0,0,0)
    elsif test_number == 2 then
      fd.puts "while (last_no < ATS_MAX_TERMS-4" + sl(GEN,L_AND,0,0,0,0) + "found_sing" + sl(GEN,EQUALS,0,0,0,0) + "1)"  + sl(GEN,DO,0,0,0,0)
    else # 3
      fd.puts "while (last_no < ATS_MAX_TERMS-7" + sl(GEN,L_AND,0,0,0,0) + "found_sing" + sl(GEN,EQUALS,0,0,0,0) + "1)"  + sl(GEN,DO,0,0,0,0)
    end
    fd.puts "tmp_rad" + sl(GEN,ASSIGN,0,0,0,0) + compute_rad(test_number,array_y_higher)
    if GEN != RUBY_APFP then
      fd.puts "if (float_abs(prev_tmp_rad) > glob__0)" + sl(GEN,THEN,0,0,0,0)
    else
      fd.puts "if " + sl(GEN,L_NOT,0,0,0,0) + " prev_tmp_rad.maybe_zero" + sl(GEN,THEN,0,0,0,0)
    end

    fd.puts "tmp_ratio" + sl(GEN,ASSIGN,0,0,0,0) + " tmp_rad / prev_tmp_rad" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts "tmp_ratio" + sl(GEN,ASSIGN,0,0,0,0) + " glob_large_float" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)


    fd.puts "if ((cnt > 0 )" + sl(GEN,L_AND,0,0,0,0) +  "(tmp_ratio < glob_upper_ratio_limit)" + sl(GEN,L_AND,0,0,0,0) +  "(tmp_ratio > glob_lower_ratio_limit))" + sl(GEN,THEN,0,0,0,0)
    fd.puts "rad_c" + sl(GEN,ASSIGN,0,0,0,0) + "tmp_rad"  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(cnt" + sl(GEN,EQUALS,0,0,0,0) + "0)"  + sl(GEN,THEN,0,0,0,0)
    fd.puts "rad_c" + sl(GEN,ASSIGN,0,0,0,0) + "tmp_rad"  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(cnt > 0)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "found_sing" + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "prev_tmp_rad" + sl(GEN,ASSIGN,0,0,0,0) + "tmp_rad"  + sl(GEN,LINEEND,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "cnt" + sl(GEN,ASSIGN,0,0,0,0) + " cnt + 1" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "last_no" + sl(GEN,ASSIGN,0,0,0,0) + "last_no + 1" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (found_sing" + sl(GEN,EQUALS,0,0,0,0)+ "1)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "if (rad_c  < " + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,test_number.to_s,0,0) + ")" + sl(GEN,THEN,0,0,0,0)
    fd.puts rad_poles + sl(GEN,SUBSC2,eq_no.to_s,test_number.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "rad_c" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "last_no" + sl(GEN,ASSIGN,0,0,0,0) + "last_no - 1" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "tmp_ord" + sl(GEN,ASSIGN,0,0,0,0) + compute_ord(test_number,array_y_higher)
    fd.puts rad_poles + sl(GEN,SUBSC2,eq_no.to_s,test_number.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "rad_c" + sl(GEN,LINESEP,0,0,0,0)
    if test_number != 1 # don' use ratio test
      fd.puts "if (rad_c  <  glob_min_pole_est)" + sl(GEN,THEN,0,0,0,0)
      fd.puts "glob_min_pole_est" + sl(GEN,ASSIGN,0,0,0,0) + "rad_c" + sl(GEN,LINEEND,0,0,0,0)
      fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    end
    fd.puts ord_poles + sl(GEN,SUBSC2,eq_no.to_s,test_number.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0)  + "tmp_ord" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
    fd.puts sl(GEN,REM,"BOTTOM general radius test" + eq_no.to_s,0,0,0)
    eq_no += 1
  end
end

####################################################################


def compute_rad(test_number,last_no)
  case test_number
  when 1
    ret = compute_rad_from_ratio(last_no)
  when 2
    ret = compute_rad_from_three_terms(last_no)
  when 3
    ret = compute_rad_from_six_terms(last_no)
  end
  return ret
end

def compute_ord(test_number,last_no)
  case test_number
  when 1
    ret = compute_ord_from_ratio(last_no)
  when 2
    ret = compute_ord_from_three_terms(last_no)
  when 3
    ret = compute_ord_from_six_terms(last_no)
  end
end

def compute_rad_from_ratio(array_y_higher)
  return "comp_rad_from_ratio(" + array_y_higher + sl(GEN,SUBSC2,"1","last_no-1",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no",0,0) + ",last_no)" + sl(GEN,LINESEP,0,0,0,0)
end
def compute_ord_from_ratio(array_y_higher)
  return "comp_ord_from_ratio(" + array_y_higher + sl(GEN,SUBSC2,"1","last_no-1",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no",0,0) + ",last_no)" + sl(GEN,LINESEP,0,0,0,0)
end
def compute_rad_from_three_terms(array_y_higher)
  return "comp_rad_from_three_terms(" + array_y_higher + sl(GEN,SUBSC2,"1","last_no-2",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-1",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no",0,0) + ",last_no)" + sl(GEN,LINESEP,0,0,0,0)
end
def compute_ord_from_three_terms(array_y_higher)
  return "comp_ord_from_three_terms(" + array_y_higher + sl(GEN,SUBSC2,"1","last_no-2",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-1",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no",0,0) + ",last_no)" + sl(GEN,LINESEP,0,0,0,0)
end
def compute_rad_from_six_terms(array_y_higher)
  return "comp_rad_from_six_terms(" + array_y_higher + sl(GEN,SUBSC2,"1","last_no-5",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-4",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-3",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-2",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-1",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no",0,0) + ",last_no)" + sl(GEN,LINESEP,0,0,0,0)
end
def compute_ord_from_six_terms(array_y_higher)
  return "comp_ord_from_six_terms(" + array_y_higher + sl(GEN,SUBSC2,"1","last_no-5",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-4",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-3",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-2",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no-1",0,0) + "," + array_y_higher + sl(GEN,SUBSC2,"1","last_no",0,0) + ",last_no)" + sl(GEN,LINESEP,0,0,0,0)
end


####################################################################

#########################################################################

def write_html_init(fd)
  rev_file = File.new(File.join("html","rev.html"),"r")
  $rev_html = rev_file.gets().chomp.rstrip.lstrip
  rev_file.close
  fd.puts "if (glob_html_log) " + sl(GEN,THEN,0,0,0,0)
  if GEN == MAPLE then
   fd.puts 'html_log_file := fopen("entry.html",WRITE,TEXT);'
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  elsif GEN == MAXIMA
    fd.puts 'html_log_file : openw("entry.html")'
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  elsif GEN == CPP or GEN == CCC then
    fd.puts 'html_log_file = fopen("entry.html","w");'
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  elsif GEN == RUBY then
    fd.puts 'html_log_file = File.new("entry.html","w")'
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  elsif GEN == RUBY_APFP then
    fd.puts 'html_log_file = File.new("entry.html","w")'
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  else
    puts("not_ready");
  end
end
def write_html_close()
  $outfilemain.puts "if (glob_html_log) " + sl(GEN,THEN,0,0,0,0)
  if GEN == MAPLE then
    $outfilemain.puts 'fclose(html_log_file);'
  elsif GEN == MAXIMA
    $outfilemain.puts 'close(html_log_file)'
  elsif GEN == CPP or GEN == CCC then
    $outfilemain.puts 'fclose(html_log_file);'
  elsif GEN == RUBY then
    $outfilemain.puts 'html_log_file.close;'
  elsif GEN == RUBY_APFP then
    $outfilemain.puts 'html_log_file.close;'
  else
    puts("not_ready");
  end
  $outfilemain.puts sl(GEN,FI,0,0,0,0)
  $outfilemain.puts sl(GEN,LINEEND,0,0,0,0)
end
############################################################################
def write_aux_functions(fd)
  ###############################################################################
  fd.puts sl(GEN,FUNDEF,VOID,0,0,0) + "display_poles" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE,"local rad_given;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE, "global ALWAYS,glob_display_flag,glob_larger_float, glob_large_float, glob_diff_ord_fm, glob_diff_ord_fmm1, glob_diff_ord_fmm2, glob_diff_rc_fm, glob_diff_rc_fmm1, glob_diff_rc_fmm2, glob_guess_error_ord, glob_guess_error_rc, glob_type_given_pole,array_given_rad_poles,array_given_ord_poles,array_rad_test_poles,array_ord_test_poles,glob_least_3_sing,glob_least_6_sing,glob_least_given_sing,glob_least_ratio_sing," + $indep_var_diff + " ;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[rad_given],float]),",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " rad_given;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " rad_given;",0,0)
  rad_poles = "array_rad_test_poles"
  ord_poles = "array_ord_test_poles"
  rad_given = "rad_given"
  ord_given = "array_given_ord_poles"

  eq_no = 1
  while eq_no <= $no_eqs do
    ##############################################################################
    # Given Value
    fd.puts "  if ((glob_type_given_pole" + sl(GEN,EQUALS,0,0,0,0) + "1)" + sl(GEN,L_OR,0,0,0,0) + "(glob_type_given_pole" + sl(GEN,EQUALS,0,0,0,0) + "2)) " + sl(GEN,THEN,0,0,0,0)
    fd.puts 'rad_given' + sl(GEN,ASSIGN,0,0,0,0) + 'sqrt((' + $indep_var_diff + '[1] - array_given_rad_poles' + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + ') * (' +  $indep_var_diff + '[1] - array_given_rad_poles' + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + ') +  array_given_rad_poles' + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + ' * array_given_rad_poles' + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + ')' + sl(GEN,LINESEP,0,0,0,0)
    label_str = ("Radius of convergence (given) for eq  " + eq_no.to_s).ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,' + rad_given + ',4," ")' + sl(GEN,LINESEP,0,0,0,0)
    label_str = "Order of pole (given)".to_s.ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,' + ord_given + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + ',4," ")' + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (rad_given < glob_least_given_sing) " + sl(GEN,THEN,0,0,0,0)
    fd.puts "glob_least_given_sing" + sl(GEN,ASSIGN,0,0,0,0) + " rad_given" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_type_given_pole" + sl(GEN,EQUALS,0,0,0,0) +  NO_POLE.to_s + ")"  + sl(GEN,THEN,0,0,0,0)
    fd.puts 'omniout_str(ALWAYS,"NO POLE (given) for Equation ' + eq_no.to_s + '")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_type_given_pole" + sl(GEN,EQUALS,0,0,0,0) +  SOME_POLE.to_s + ")"  + sl(GEN,THEN,0,0,0,0)
    fd.puts 'omniout_str(ALWAYS,"SOME POLE (given) for Equation ' + eq_no.to_s + '")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts 'omniout_str(ALWAYS,"NO INFO (given) for Equation ' + eq_no.to_s + '")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    ##################################################################
    # Ratio Test
    fd.puts "  if (" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + " < glob_large_float) " + sl(GEN,THEN,0,0,0,0)
    label_str = ("Radius of convergence (ratio test) for eq  " + eq_no.to_s).ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,' + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + ',4," ")' + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + "< glob_least_ratio_sing)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "glob_least_ratio_sing" + sl(GEN,ASSIGN,0,0,0,0) + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

    label_str = "Order of pole (ratio test)".to_s.ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4, ' + ord_poles + sl(GEN,SUBSC2,eq_no.to_s,"1",0,0) + ',4," ")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts 'omniout_str(ALWAYS,"NO POLE (ratio test) for Equation ' + eq_no.to_s + '")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    ####################################################################
    # three term test
    fd.puts "  if ((" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + " >  glob__small)" + sl(GEN,L_AND,0,0,0,0) + "(" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + " < glob_large_float)) " + sl(GEN,THEN,0,0,0,0)
    label_str = ("Radius of convergence (three term test) for eq " + eq_no.to_s).ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,' + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + ',4," ")' + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + "< glob_least_3_sing)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "glob_least_3_sing" + sl(GEN,ASSIGN,0,0,0,0) + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    label_str = "Order of pole (three term test)".to_s.ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4, ' + ord_poles + sl(GEN,SUBSC2,eq_no.to_s,"2",0,0) + ',4," ")' + sl(GEN,LINEEND,0,0,0,0)
    if false then
      label_str = "Derivative of radius w.r.t nth term".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_diff_rc_fm,4," ")' + sl(GEN,LINESEP,0,0,0,0)
      label_str = "Derivative of order w.r.t nth term".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_diff_ord_fm,4," ")' + sl(GEN,LINESEP,0,0,0,0)

      label_str = "Derivative of radius w.r.t (n-1)th term".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_diff_rc_fmm1,4," ")' + sl(GEN,LINESEP,0,0,0,0)
      label_str = "Derivative of order w.r.t (n-1)th term".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_diff_ord_fmm1,4," ")' + sl(GEN,LINESEP,0,0,0,0)

      label_str = "Derivative of radius w.r.t (n-2)th term".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_diff_rc_fmm2,4," ")' + sl(GEN,LINESEP,0,0,0,0)
      label_str = "Derivative of order w.r.t (n-2)th term".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_diff_ord_fmm2,4," ")' + sl(GEN,LINESEP,0,0,0,0)

      fd.puts 'omniout_str(ALWAYS,"Guess at Error should be multiplied by ratio of error in relevant terms (I used value of term instead of error in term).")' + sl(GEN,LINESEP,0,0,0,0)

      label_str = "Guess error in radius".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_guess_error_rc,4," ")' + sl(GEN,LINESEP,0,0,0,0)
      label_str = "Guess error in order".to_s.ljust(50," ")
      fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,glob_guess_error_ord,4," ")' + sl(GEN,LINEEND,0,0,0,0)
    end
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts 'omniout_str(ALWAYS,"NO REAL POLE (three term test) for Equation ' + eq_no.to_s + '")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
    #######################################################################
    # six term test
    fd.puts "  if ((" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"3",0,0) + " >  glob__small)" + sl(GEN,L_AND,0,0,0,0) + "(" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"3",0,0) + " < glob_large_float)) " + sl(GEN,THEN,0,0,0,0)
    label_str = ("Radius of convergence (six term test) for eq " + eq_no.to_s).ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4,' +  rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"3",0,0) + ',4," ")' + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (" + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"3",0,0) + "< glob_least_6_sing)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "glob_least_6_sing" + sl(GEN,ASSIGN,0,0,0,0) + rad_poles + sl(GEN,SUBSC2,eq_no.to_s,"3",0,0) + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    label_str = "Order of pole (six term test)".to_s.ljust(50," ")
    fd.puts '    omniout_float(ALWAYS,"' + label_str + '",4, ' + ord_poles + sl(GEN,SUBSC2,eq_no.to_s,"3",0,0) + ',4," ")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts 'omniout_str(ALWAYS,"NO COMPLEX POLE (six term test) for Equation ' + eq_no.to_s + '")' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)
    if eq_no < $no_eqs then
      fd.puts sl(GEN,LINESEP,0,0,0,0)
    else
      fd.puts sl(GEN,LINEEND,0,0,0,0)
    end
    ####################################################################
    eq_no += 1
  end
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0) # for block
  fd.puts sl(GEN,FUNEND,0,0,0,0)
  ###########################################################################
  fd.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "my_check_sign" + sl(GEN,FUNSEP1,0,0,0,0)  + "(" + st2(FLOAT) +  " x0 ," + st2(FLOAT) + "xf)" + sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"double ret;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"double ret;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block( [ret], ",0,0)
  fd.puts "if (xf > x0)" + sl(GEN,THEN,0,0,0,0)
  fd.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "glob__1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts  sl(GEN,ELSE,0,0,0,0)
  fd.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "glob__m1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts  sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,RETURN,"ret",0,0,0) + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
  ######################################################################
  fd.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "est_size_answer" + sl(GEN,FUNSEP1,0,0,0,0) + "()"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE,"local min_size;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"double min_size;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"double min_size;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block( [ min_size], ",0,0)

  fd.puts "min_size" + sl(GEN,ASSIGN,0,0,0,0) + "glob_estimated_size_answer" + sl(GEN,LINESEP,0,0,0,0)
  eq_no = 1
  while eq_no <= $no_eqs do
    series = $eq_rec[eq_no].dep_var_diff
    fd.puts "if (float_abs(" + series + sl(GEN,SUBSC1,"1",0,0,0) + ") < min_size)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "min_size" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs(" + series + sl(GEN,SUBSC1,"1",0,0,0) + ")" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts 'omniout_float(ALWAYS,"min_size",32,min_size,32,"")'  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
    eq_no += 1
  end
  fd.puts "if (min_size < glob__1)" + sl(GEN,THEN,0,0,0,0)
  fd.puts "min_size" + sl(GEN,ASSIGN,0,0,0,0) + "glob__1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"min_size",32,min_size,32,"")'  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,RETURN,"min_size",0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
  #########################################################################
  fd.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "test_suggested_h" + sl(GEN,FUNSEP1,0,0,0,0) + "()"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"double max_estimated_step_error,hn_div_ho,hn_div_ho_2,hn_div_ho_3,est_tmp;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"int no_terms;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"double max_estimated_step_error,hn_div_ho,hn_div_ho_2,hn_div_ho_3,est_tmp;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"int no_terms;",0,0)

  fd.puts sl(GEN,SPECIFIC,MAPLE,"local max_estimated_step_error,hn_div_ho,hn_div_ho_2,hn_div_ho_3,no_terms,est_tmp;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block ([max_estimated_step_error,hn_div_ho,hn_div_ho_2,hn_div_ho_3,no_terms,est_tmp],",0,0)

  fd.puts "max_estimated_step_error " + sl(GEN,ASSIGN,0,0,0,0) + "glob__small"   + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "no_terms" + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "hn_div_ho" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0_5" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "hn_div_ho_2" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0_25" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "hn_div_ho_3" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0_125" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"hn_div_ho",32,hn_div_ho,32,"")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"hn_div_ho_2",32,hn_div_ho_2,32,"")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"hn_div_ho_3",32,hn_div_ho_3,32,"")' + sl(GEN,LINESEP,0,0,0,0)
  # estimated_step_error is estimated error for nth series with this glob_h
  # max_estimated_step_error is largest error of all the series with this glob_h
  # smallest possible is 0.0 (its an absolute value)
  eq_no = 1
  while eq_no <= $no_eqs do
    series = $eq_rec[eq_no].dep_var_diff
    fd.puts "est_tmp" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs(" + series + sl(GEN,SUBSC1,"no_terms-3",0,0,0) + " + " + series + sl(GEN,SUBSC1,"no_terms - 2",0,0,0)  + " * hn_div_ho"  + " + " + series + sl(GEN,SUBSC1,"no_terms - 1",0,0,0)  + " * hn_div_ho_2" + " + " + series + sl(GEN,SUBSC1,"no_terms",0,0,0)  + " * hn_div_ho_3)"  + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (est_tmp >= max_estimated_step_error)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "max_estimated_step_error" + sl(GEN,ASSIGN,0,0,0,0) + "est_tmp" + sl(GEN,LINEEND,0,0,0,0)
    #    fd.puts 'omniout_float(ALWAYS,"estimated_step_error",32,estimated_step_error,32,"")'  + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
    eq_no += 1
  end
  fd.puts 'omniout_float(ALWAYS,"max_estimated_step_error",32,max_estimated_step_error,32,"")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,RETURN,"max_estimated_step_error",0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
  #########################################################################
  fd.puts sl(GEN,FUNDEF,VOID,0,0,0) + "track_estimated_error" + sl(GEN,FUNSEP1,0,0,0,0) + "()"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"double hn_div_ho,hn_div_ho_2,hn_div_ho_3,est_tmp;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"int no_terms;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"double hn_div_ho,hn_div_ho_2,hn_div_ho_3,est_tmp;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"int no_terms;",0,0)

  fd.puts sl(GEN,SPECIFIC,MAPLE,"local hn_div_ho,hn_div_ho_2,hn_div_ho_3,no_terms,est_tmp;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block ([hn_div_ho,hn_div_ho_2,hn_div_ho_3,no_terms,est_tmp],",0,0)

  fd.puts "no_terms" + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "hn_div_ho" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0_5" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "hn_div_ho_2" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0_25" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "hn_div_ho_3" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0_125" + sl(GEN,LINESEP,0,0,0,0)
  eq_no = 1
  while eq_no <= $no_eqs do
    series = $eq_rec[eq_no].dep_var_diff
    fd.puts "est_tmp" + sl(GEN,ASSIGN,0,0,0,0) + "c(float_abs(" + series + sl(GEN,SUBSC1,"no_terms-3",0,0,0) + ")) + c(float_abs(" + series + sl(GEN,SUBSC1,"no_terms - 2",0,0,0)  + ")) * c(hn_div_ho)"  + " + c(float_abs(" + series + sl(GEN,SUBSC1,"no_terms - 1",0,0,0)  + ")) * c(hn_div_ho_2)" + " + c(float_abs(" + series + sl(GEN,SUBSC1,"no_terms",0,0,0)  + ")) * c(hn_div_ho_3)"  + sl(GEN,LINESEP,0,0,0,0)
      fd.puts 'if (glob_prec * c(float_abs(' + series + sl(GEN,SUBSC1,"1",0,0,0) + ')) > c(est_tmp))' + sl(GEN,THEN,0,0,0,0)
    fd.puts "est_tmp" + sl(GEN,ASSIGN,0,0,0,0) + 'c(glob_prec) * c(float_abs(' + series + sl(GEN,SUBSC1,"1",0,0,0) + '))' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)   + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (c(est_tmp) >= c(array_max_est_error" + sl(GEN,SUBSC1,eq_no.to_s,0,0,0) + "))" + sl(GEN,THEN,0,0,0,0)
    fd.puts "array_max_est_error" + sl(GEN,SUBSC1,eq_no.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(est_tmp)" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)
    if eq_no < $no_eqs then
      fd.puts sl(GEN,LINESEP,0,0,0,0)
    else
      fd.puts sl(GEN,LINEEND,0,0,0,0)
    end
    eq_no += 1
  end
  fd.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
  ###########################################################################
  fd.puts sl(GEN,FUNDEF,INTEGER,0,0,0) + "reached_interval" + sl(GEN,FUNSEP1,0,0,0,0) + "()"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"int ret;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"int ret;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[ret],boolean]),",0,0)
  fd.puts "if ((glob_check_sign * " +  $indep_var_diff + "[1]) >= (glob_check_sign * glob_next_display - glob_h/glob__10))" + sl(GEN,THEN,0,0,0,0)
  fd.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "true" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,ELSE,0,0,0,0)
  fd.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "false" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "return(ret)" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)

  ############################################################################

  fd.puts sl(GEN,FUNDEF,VOID,0,0,0) + "display_alot" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(INTEGER) + "iter)"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE,"local abserr, closed_form_val_y, ind_var, numeric_val, relerr, term_no, est_rel_err;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[abserr,est_rel_err],float, [closed_form_val_y],float, [ind_var],float, [numeric_val],float, [relerr],float, [term_no],fixnum]),",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " abserr, est_rel_err, closed_form_val_y, ind_var, numeric_val, relerr;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,st2(INTEGER) + " term_no;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " abserr, est_rel_err, closed_form_val_y, ind_var, numeric_val, relerr;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,st2(INTEGER) + " term_no;",0,0)


  fd.puts sl(GEN,REM,"TOP DISPLAY ALOT",0,0,0)
  fd.puts "if (reached_interval()) " + sl(GEN,THEN,0,0,0,0)
  fd.puts "if (iter >= 0) " + sl(GEN,THEN,0,0,0,0)
  label_str = (remove_array_str($indep_var_diff) + '[1]').ljust(33," ")
  fd.puts 'ind_var' + sl(GEN,ASSIGN,0,0,0,0)  + $indep_var_diff + '[1]' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(ALWAYS,"' + label_str + '",33,ind_var,20," ")' + sl(GEN,LINESEP,0,0,0,0)
  $eq_no = 1
  while $eq_no <= $no_eqs do
    if GEN != MAPLE then
      fd.puts 'closed_form_val_y' + sl(GEN,ASSIGN,0,0,0,0) + 'exact_soln_' + remove_array_str($eq_rec[$eq_no].dep_var_diff) + '(ind_var)' + sl(GEN,LINESEP,0,0,0,0)
      label_str = (remove_array_str($eq_rec[$eq_no].dep_var_diff) + '[1] (closed_form)').ljust(33," ")
    else
      fd.puts 'closed_form_val_y' + sl(GEN,ASSIGN,0,0,0,0) + 'evalf(exact_soln_' + remove_array_str($eq_rec[$eq_no].dep_var_diff) + '(ind_var))' + sl(GEN,LINESEP,0,0,0,0)
      label_str = (remove_array_str($eq_rec[$eq_no].dep_var_diff) + '[1] (closed_form)').ljust(33," ")
    end
    fd.puts 'omniout_float(ALWAYS,"' + label_str + '",33,closed_form_val_y,20," ")' + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts 'numeric_val' + sl(GEN,ASSIGN,0,0,0,0) + $eq_rec[$eq_no].dep_var_diff + '[term_no]' + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "abserr" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs(numeric_val - closed_form_val_y)" + sl(GEN,LINESEP,0,0,0,0)
    label_str = (remove_array_str($eq_rec[$eq_no].dep_var_diff) + '[1] (numeric)').ljust(33," ")
    fd.puts 'omniout_float(ALWAYS,"' + label_str + '",33,numeric_val,20," ")' + sl(GEN,LINESEP,0,0,0,0)
    if GEN == RUBY_APFP then
      fd.puts 'if (est_expt(closed_form_val_y) > -DESIRED_DIGITS and closed_form_val_y.mant.abs > 0) ' + sl(GEN,THEN,0,0,0,0)
    else
      fd.puts 'if (c(float_abs(closed_form_val_y)) > c(glob_prec)) ' + sl(GEN,THEN,0,0,0,0)
    end
    fd.puts 'relerr' + sl(GEN,ASSIGN,0,0,0,0) + 'abserr/float_abs(closed_form_val_y)' + sl(GEN,LINESEP,0,0,0,0)
    if GEN == RUBY_APFP then
      fd.puts "if (est_expt(relerr) > -DESIRED_DIGITS) and relerr.mant.abs > 0" + sl(GEN,THEN,0,0,0,0)
    else
      fd.puts "if (c(relerr) > c(glob_prec))" + sl(GEN,THEN,0,0,0,0)
    end
    if GEN != MAXIMA then
      if GEN == RUBY_APFP then
#        label_str = "log10(c(relerr))".ljust(33," ")
#        fd.puts 'omniout_float(ALWAYS,"' + label_str + '",4,log10(relerr),20,"%")' + sl(GEN,LINESEP,0,0,0,0)
#        label_str = "-int_trunc(that)".ljust(33," ")
#        fd.puts 'omniout_float(ALWAYS,"' + label_str + '",4,-int_trunc(log10(relerr)),20,"%")' + sl(GEN,LINESEP,0,0,0,0)
        fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '-est_expt(relerr)' + sl(GEN,LINESEP,0,0,0,0)
      else
# new 12/11/2017
    fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + 'round(-log10(relerr))' + sl(GEN,LINESEP,0,0,0,0)

# OLD        fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '-int_trunc(log10(c(relerr))) + 3' + sl(GEN,LINESEP,0,0,0,0)
      end
    else
#NEW 12/11/2017
    fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + 'round(-log10(relerr))' + sl(GEN,LINESEP,0,0,0,0)
# OLD      fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '-floor(log10(c(relerr))) + 3' + sl(GEN,LINEEND,0,0,0,0)
    end
#    fd.puts '$stderr.puts "glob_good_digits = " + glob_good_digits.to_s'
    #g    fd.puts '$stderr.puts "glob_good_digits = " + glob_good_digits.to_s'
    fd.puts sl(GEN,ELSE,0,0,0,0)
    if GEN == MAPLE
      fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + "Digits" + sl(GEN,LINEEND,0,0,0,0)
    elsif GEN == RUBY_APFP then
      label_str = "glob_prec".ljust(33," ")
        fd.puts 'omniout_float(ALWAYS,"' + label_str + '",4,glob_prec * c(100.0),20,"%")' + sl(GEN,LINESEP,0,0,0,0)
      fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + "DESIRED_DIGITS" + sl(GEN,LINEEND,0,0,0,0)

      else
      fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + "16" + sl(GEN,LINEEND,0,0,0,0)
    end
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)

    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts 'relerr' + sl(GEN,ASSIGN,0,0,0,0) + ' glob__m1  ' + sl(GEN,LINESEP,0,0,0,0)  # cannot divide by zero so impossible value set
    fd.puts 'glob_good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '-16' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
###

    fd.puts 'if (glob_good_digits < glob_min_good_digits)' + sl(GEN,THEN,0,0,0,0)
    fd.puts 'glob_min_good_digits ' + sl(GEN,ASSIGN,0,0,0,0) + 'glob_good_digits' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
    if GEN == RUBY_APFP then
      fd.puts "glob_apfp_est_good_digits" + sl(GEN,ASSIGN,0,0,0,0) + "est_good_digits(numeric_val)"  + sl(GEN,LINESEP,0,0,0,0)
    end
    fd.puts 'if (glob_apfp_est_good_digits < glob_min_apfp_est_good_digits)' + sl(GEN,THEN,0,0,0,0)
    fd.puts 'glob_min_apfp_est_good_digits ' + sl(GEN,ASSIGN,0,0,0,0) + 'glob_apfp_est_good_digits' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
    if GEN != MAPLE then
      fd.puts 'if (c(float_abs(numeric_val)) > c(glob_prec)) ' + sl(GEN,THEN,0,0,0,0)
    else
      fd.puts 'if (evalf(float_abs(numeric_val)) > glob_prec) ' + sl(GEN,THEN,0,0,0,0)
    end

    if GEN != MAPLE then
      fd.puts 'est_rel_err' + sl(GEN,ASSIGN,0,0,0,0) + 'c(array_max_est_error' + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) + ')*glob__100 * c(sqrt(glob_iter))*c(' + $token_no.to_s + ')*c(ATS_MAX_TERMS)/c(float_abs(numeric_val))' + sl(GEN,LINESEP,0,0,0,0)
      fd.puts "if (est_rel_err > glob_prec)" + sl(GEN,THEN,0,0,0,0)
    else
      fd.puts 'est_rel_err' + sl(GEN,ASSIGN,0,0,0,0) + 'evalf(array_max_est_error' + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) + '*100.0 * sqrt(glob_iter)*' + $token_no.to_s + '*ATS_MAX_TERMS/float_abs(numeric_val))' + sl(GEN,LINESEP,0,0,0,0)
      fd.puts "if (evalf(est_rel_err) > glob_prec)" + sl(GEN,THEN,0,0,0,0)
    end

    if GEN != MAXIMA then
      fd.puts 'glob_est_digits' + sl(GEN,ASSIGN,0,0,0,0) + '-int_trunc(log10(est_rel_err)) + 3' + sl(GEN,LINEEND,0,0,0,0)
    else
      fd.puts 'glob_est_digits' + sl(GEN,ASSIGN,0,0,0,0) + '-floor(log10(est_rel_err)) + 3' + sl(GEN,LINEEND,0,0,0,0)
    end
    fd.puts sl(GEN,ELSE,0,0,0,0)
    if GEN == MAPLE
      fd.puts 'glob_est_digits' + sl(GEN,ASSIGN,0,0,0,0) + 'Digits' + sl(GEN,LINEEND,0,0,0,0)
    elsif GEN == RUBY_APFP then
      fd.puts 'glob_est_digits' + sl(GEN,ASSIGN,0,0,0,0) + DESIRED_DIGITS.to_s + sl(GEN,LINEEND,0,0,0,0)
    else
      fd.puts 'glob_est_digits' + sl(GEN,ASSIGN,0,0,0,0) + "16" + sl(GEN,LINEEND,0,0,0,0)
    end
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)

    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts 'relerr' + sl(GEN,ASSIGN,0,0,0,0) + ' glob__m1  ' + sl(GEN,LINESEP,0,0,0,0)  # cannot divide by zero so impossible value set
    fd.puts 'glob_est_digits' + sl(GEN,ASSIGN,0,0,0,0) + '-16' + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
###
    fd.puts "array_est_digits" + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "glob_est_digits" + sl(GEN,LINESEP,0,0,0,0)
#    fd.puts "array_good_digits" + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "glob_good_digits" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (glob_iter " + sl(GEN,EQUALS,0,0,0,0) + "1)" + sl(GEN,THEN,0,0,0,0)
    fd.puts "array_1st_rel_error" + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) +       sl(GEN,ASSIGN,0,0,0,0) + "relerr" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    fd.puts "array_last_rel_error" + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) +       sl(GEN,ASSIGN,0,0,0,0) + "relerr" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "array_est_rel_error" + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) +       sl(GEN,ASSIGN,0,0,0,0) + "est_rel_err" + sl(GEN,LINESEP,0,0,0,0)
    label_str = "absolute error".ljust(33," ")
    fd.puts 'omniout_float(ALWAYS,"' + label_str + '",4,abserr,20," ")' + sl(GEN,LINESEP,0,0,0,0)
    label_str = "relative error".ljust(33," ")
    fd.puts 'omniout_float(ALWAYS,"' + label_str + '",4,relerr * c(100.0),20,"%")' + sl(GEN,LINESEP,0,0,0,0)

    label_str = "Desired digits".to_s.ljust(33," ")
    fd.puts 'omniout_int(INFO,"' + label_str + '",32,glob_desired_digits_correct,4," ")' + sl(GEN,LINESEP,0,0,0,0)
    label_str = "Estimated correct digits".to_s.ljust(33," ")
    fd.puts 'omniout_int(INFO,"' + label_str + '",32,glob_est_digits,4," ")'   + sl(GEN,LINESEP,0,0,0,0)
    label_str = "Correct digits".to_s.ljust(33," ")
    fd.puts 'omniout_int(INFO,"' + label_str + '",32,glob_good_digits,4," ")'
    fd.puts  sl(GEN,LINESEP,0,0,0,0)

    label_str = "h".ljust(33," ")
    fd.puts 'omniout_float(ALWAYS,"' + label_str + '",4,glob_h,20," ")' + sl(GEN,LINEEND,0,0,0,0)
    if $eq_no < $no_eqs then
      fd.puts sl(GEN,LINESEP,0,0,0,0)
    end
    $eq_no += 1
  end
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,REM,"BOTTOM DISPLAY ALOT",0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
#########################################################################
  fd.puts sl(GEN,FUNDEF,VOID,0,0,0) + "prog_report" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + $bounds2 + ")"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE," local clock_sec, opt_clock_sec, clock_sec1, expect_sec, left_sec, percent_done, total_clock_sec;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([ [clock_sec],float, [opt_clock_sec],float, [clock_sec1],float, [expect_sec],float, [left_sec],float, [percent_done],float, [total_clock_sec],float]),",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) +"  clock_sec, opt_clock_sec, clock_sec1, expect_sec, left_sec, total_clock_sec;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) +"  percent_done;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) +"  clock_sec, opt_clock_sec, clock_sec1, expect_sec, left_sec, total_clock_sec;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) +"  percent_done;",0,0)
  #
  # PROGRESS REPORT
  #
  fd.puts sl(GEN,REM,"TOP PROGRESS REPORT ",0,0,0)
  fd.puts "clock_sec1  " + sl(GEN,ASSIGN,0,0,0,0) + "elapsed_time_seconds()" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "total_clock_sec  " + sl(GEN,ASSIGN,0,0,0,0) + " (clock_sec1) - (glob_orig_start_sec)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_clock_sec  " + sl(GEN,ASSIGN,0,0,0,0) + " (clock_sec1) - (glob_clock_start_sec)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "left_sec  " + sl(GEN,ASSIGN,0,0,0,0) + " (glob_max_sec) + (glob_orig_start_sec) - (clock_sec1)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "expect_sec  " + sl(GEN,ASSIGN,0,0,0,0) + " comp_expect_sec((" + remove_array_str($indep_var_diff) + "_end),(" + remove_array_str($indep_var_diff) + "_start),(" + $indep_var_diff + "[1]) + (glob_h)  ,( clock_sec1) - (glob_orig_start_sec))" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "opt_clock_sec  " + sl(GEN,ASSIGN,0,0,0,0) + "( clock_sec1) - (glob_optimal_clock_start_sec)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_optimal_expect_sec  " + sl(GEN,ASSIGN,0,0,0,0) + " comp_expect_sec((" + remove_array_str($indep_var_diff) + "_end),(" + remove_array_str($indep_var_diff) + "_start),(" + $indep_var_diff + "[1]) +( glob_h) ,( opt_clock_sec))" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_total_exp_sec  " + sl(GEN,ASSIGN,0,0,0,0) + "glob_optimal_expect_sec + c(total_clock_sec)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "percent_done  " + sl(GEN,ASSIGN,0,0,0,0) + " comp_percent((" + remove_array_str($indep_var_diff) + "_end),(" + remove_array_str($indep_var_diff) + "_start),(" + $indep_var_diff + "[1]) + (glob_h))" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_percent_done" + sl(GEN,ASSIGN,0,0,0,0) + "percent_done" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str_noeol(INFO,"Total Elapsed Time              ")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_timestr((total_clock_sec))'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str_noeol(INFO,"Elapsed Time(since restart)     ")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_timestr((glob_clock_sec))'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'if (c(percent_done) < glob__100) ' + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str_noeol(INFO,"Expected Time Remaining         ")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_timestr((expect_sec))'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str_noeol(INFO,"Optimized Time Remaining        ")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_timestr((glob_optimal_expect_sec))'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str_noeol(INFO,"Expected Total Time             ")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_timestr((glob_total_exp_sec))'  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str_noeol(INFO,"Time to Timeout                 ")'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_timestr((left_sec))'  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_float(INFO,    "Percent Done                    ",33,percent_done,4,"%")' + sl(GEN,LINEEND,0,0,0,0)

  fd.puts sl(GEN,REM,"BOTTOM PROGRESS REPORT ",0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)

  fd.puts sl(GEN,FUNEND,0,0,0,0)

###################################################################
  fd.puts sl(GEN,FUNDEF,VOID,0,0,0) + "check_for_pole" + sl(GEN,FUNSEP1,0,0,0,0) + "()"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE,"local cnt, dr1, dr2, ds1, ds2, hdrc, m, n, nr1, nr2, ord_no, term1, term2, term3, part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11, part12, part13, part14,  rad_c, rcs, rm0, rm1, rm2, rm3, rm4, found_sing, h_new, ratio, term, local_test, tmp_rad,tmp_ord, tmp_ratio, prev_tmp_rad, last_no;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([cnt],fixnum,[ dr1, dr2, ds1, ds2, hdrc],float ,[ m, n],fixnum,[ nr1, nr2],float,[ ord_no],fixnum , [term1, term2, term3, part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11, part12, part13, part14, rad_c, rcs, rm0, rm1, rm2, rm3, rm4],float ,[ found_sing],fixnum ,[ h_new, ratio, term, local_test, tmp_rad,tmp_ord, tmp_ratio, prev_tmp_rad],float, [last_no],fixnum),",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"int cnt, m, n, found_sing, term, local_test, last_no;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + "  dr1, dr2, ds1, ds2, hdrc, nr1, nr2, ord_no, term1, term2, term3, part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11, part12, part13, part14, rad_c, rcs, rm0, rm1, rm2, rm3, rm4, h_new, ratio, tmp_rad,tmp_ord, tmp_ratio, prev_tmp_rad;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"int cnt, m, n, found_sing, term, local_test, last_no;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + "  dr1, dr2, ds1, ds2, hdrc, nr1, nr2, ord_no, term1, term2, term3, part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11, part12, part13, part14,  rad_c, rcs, rm0, rm1, rm2, rm3, rm4, h_new, ratio, tmp_rad,tmp_ord, tmp_ratio, prev_tmp_rad;",0,0)
  fd.puts sl(GEN,REM,"TOP CHECK FOR POLE ",0,0,0)

  general_radius(fd,1) # ratio
  general_radius(fd,2) # three term
  general_radius(fd,3) # six term
  adjust_all_series(fd)
  fd.puts sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (reached_interval()) " + sl(GEN,THEN,0,0,0,0)
  fd.puts "display_poles()" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
################################################################
  fd.puts sl(GEN,FUNDEF,VOID,0,0,0) + "atomall" + sl(GEN,FUNSEP1,0,0,0,0) + "()"
  glob_decl(fd)
  fd.puts sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,SPECIFIC,MAPLE,"local kkk, order_d, adj2, adj3 , temporary, term;",0,0)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([ [kkk, order_d],fixnum,[ adj2, adj3,  temporary, term,temp,temp2],float]),",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,"int kkk, order_d, term, adj2, adj3;",0,0)
  fd.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " temporary,temp,temp2;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,"int kkk, order_d, term, adj2, adj3;",0,0)
  fd.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " temporary,temp,temp2;",0,0)
  fd.puts sl(GEN,REM,"TOP ATOMALL ",0,0,0)
  $eq_no = 1
end
def write_bottom_atomall(fd)
  fd.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)
  fd.puts sl(GEN,REM,"BOTTOM ATOMALL ???",0,0,0)
  fd.puts sl(GEN,FUNEND,0,0,0,0)
end
def write_ats_library_and_user_def_block(fd)
  fd.puts sl(GEN,REM,"BEGIN ATS LIBRARY BLOCK",0,0,0)
  while $linein  = $libfile.gets do
    $linein  = $linein.chomp.rstrip.lstrip
    fd.puts $linein
    $lineno_in += 1
  end
  fd.puts sl(GEN,REM,"END ATS LIBRARY BLOCK",0,0,0)
  fd.puts sl(GEN,REM,"BEGIN USER FUNCTION BLOCK",0,0,0)
  copy_nth_block(fd,FUNCTION_BLOCK)
  fd.puts sl(GEN,REM,"END USER FUNCTION BLOCK",0,0,0)
end

def copy_nth_block(fd,blockno)
  fd.puts sl(GEN,REM,"BEGIN BLOCK " + (blockno-1).to_s,0,0,0)

  blockcount = 0
  open_ode_file()

  blockcount += 1
  while $linein  = $infile.gets and blockcount <= blockno do
    $linein = $linein.chomp.rstrip.lstrip
    $stderr.puts "block " + blockno.to_s + "blockcount " + blockcount.to_s + $linein
    if $linein == "!" then
      blockcount += 1
      next
    elsif blockcount == blockno then
      fd.puts $linein
      $stderr.puts "writing " + $linein + fd.to_s
      $lineno_in += 1
    end
  end
  $lineno_in += 1
  $infile.close
  fd.puts sl(GEN,REM,"END BLOCK " + (blockno-1).to_s ,0,0,0)
end


def init_hdrs
  if $order_max + 5 > $min_hdrs then
    $min_hdrs = $max_order + 5
  end
  $outhdr = Array.new($min_hdrs + 1)
  local_fno = 1
  while local_fno <= $min_hdrs do
    $outhdr[local_fno] = File.new(File.join($TEMP_DIR,"atomhdr" + local_fno.to_s + ".mxi"),"w")
    $outhdr[local_fno].puts sl(GEN,REM,"BEGIN ATOMHDR" + local_fno.to_s ,0,0,0)
    local_fno += 1
  end
end
def close_hdrs
  local_fno = 1
  while local_fno <= $min_hdrs do
    $outhdr[local_fno].puts sl(GEN,REM,"END ATOMHDR" + local_fno.to_s,0,0,0)
    $outhdr[local_fno].close
    local_fno += 1
  end
end
def cat_files
  $outfile = File.new(File.join($TEMP_DIR,"diffeq.tmp"),"w")
  $infile = File.new(File.join($TEMP_DIR,"atomout1.mxi"),"r")
  while $linein = $infile.gets do
    $linein = $linein.chomp
    $outfile.puts $linein
  end
  $infile.close
  $infile = File.new(File.join($TEMP_DIR,"atomout2.mxi"),"r")
  while $linein = $infile.gets do
    $linein = $linein.chomp
    $outfile.puts $linein
  end
  $infile.close
  local_fno = 1
  while local_fno <= $min_hdrs do
    $fname = File.join($TEMP_DIR,"atomhdr" + local_fno.to_s + ".mxi")
    $infile = File.new($fname,"r")
    while $linein = $infile.gets do
      $linein = $linein.chomp
      $outfile.puts $linein
    end
    $infile.close
    local_fno += 1
  end
  $infile = File.new(File.join($TEMP_DIR,"atomout3.mxi"),"r")
  while $linein = $infile.gets do
    $linein = $linein.chomp
    $outfile.puts $linein
  end
  $infile.close
  $infile = File.new(File.join($TEMP_DIR,"atomout4.mxi"),"r")
  while $linein = $infile.gets do
    $linein = $linein.chomp
    $outfile.puts $linein
  end
  $infile.close
  $infile = File.new(File.join($TEMP_DIR,"atomout5.mxi"),"r")
  while $linein = $infile.gets do
    $linein = $linein.chomp
    $outfile.puts $linein
  end
  $infile.close
  $infile = File.new(File.join($TEMP_DIR,"atomoutmain.mxi"),"r")
  while $linein = $infile.gets do
    $linein = $linein.chomp
    $outfile.puts $linein
  end
  $infile.close
  $outfile.close
end
def count_lines_out
  $cnt_file = File.new(File.join($TEMP_DIR,"diffeq.tmp"),"r")
  while $cnt_line_in = $cnt_file.gets do
    $lineno_out += 1
  end
  $cnt_file.close
end
def lexan_2
  $token_no += 1
  t = $eq_rec[$eq_no].token_tables.get_token_copy_1
  $tokenval = $eq_rec[$eq_no].token_tables.get_token_copy_2
  if t then
    if t == ";" then
      #      $eq_no += 1
      return ";"
    end
    return t
  else
    #    $eq_no += 1
    return ";"
  end
end
def count_eqs(infile)
  cnt = 0
  in_eqs = true
  $equation = Array.new

  while line = infile.gets do
    line = line.chomp
    if DEBUG == 1
      $stderr.puts " eq count = #{cnt}"
    end
    if line == "!" then
      return cnt
    else
      $equation[cnt + 1] = line
      cnt += 1
    end
  end
end
def echo_problem(infile,fname)
  echout = File.new(File.join($TEMP_DIR,"echout.mxi"),"w")
  echout.puts 'omniout_str(ALWAYS,"##############ECHO OF PROBLEM#################")' + sl(GEN,LINESEP,0,0,0,0)
  echout.puts 'omniout_str(ALWAYS,"##############' + fname + '#################")' + sl(GEN,LINESEP,0,0,0,0)
  line = infile.gets
  line = line.chomp
  while line do
    line2 = line.gsub(/\"/,'\\\"')
    echout.puts 'omniout_str(ALWAYS,"' + line2 + '")' + sl(GEN,LINESEP,0,0,0,0)
    line = infile.gets
    if line != nil then
      line = line.chomp
    end
  end
  echout.puts 'omniout_str(ALWAYS,"#######END OF ECHO OF PROBLEM#################")' + sl(GEN,LINESEP,0,0,0,0)
  echout.close
end
def copyecho
  echoin = File.new(File.join($TEMP_DIR,"echout.mxi"),"r")
  linein = echoin.gets
  linein = linein.chomp
  while linein do
    $outfilemain.puts linein
    linein = echoin.gets
    if linein != nil then
      linein = linein.chomp
    end
  end
  echoin.close
end


def generate_const_decl(fd)
  if GEN == MAPLE then
    fd.puts sl(GEN,REM,"BEGIN CONST",0,0,0)

    $const_tbl.each_key {|id|
      fd.puts id + ","
    }
    fd.puts sl(GEN,REM,"END CONST",0,0,0)

  end
end
def arrays_defined(fd)
  if GEN != CCC && GEN != CPP then
    generate_arrays_definition(fd)
  end
end
def arrays_initialized(fd)
  $arrays1.each {|key, value |
    fd.puts "term" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "while (term <= " + value.dim1 + ")" + sl(GEN,DO,0,0,0,0)
    fd.puts key + sl(GEN,SUBSC1,"term",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + value.init_val + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "term" + sl(GEN,ASSIGN,0,0,0,0) + "term + 1" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  }
  $arrays2.each {|key, value |

    fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "while (ord <=" + value.dim1 + ")" + sl(GEN,DO,0,0,0,0)
    fd.puts "term" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "while (term <= " + value.dim2 + ")" + sl(GEN,DO,0,0,0,0)
    fd.puts key + sl(GEN,SUBSC2,"ord","term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + value.init_val + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "term" + sl(GEN,ASSIGN,0,0,0,0) + "term + 1" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + "ord + 1" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  }
end

def symbols_defined(fd)
  fd.puts sl(GEN,REM,"BEGIN SYMBOLS DEFINED",0,0,0)

  $sym_tbl.each_key {|id|
    if $sym_tbl[id] == IDENTIFIER then
      if GEN != CCC and GEN != CPP then
        fd.puts sl(GEN,ARRAY1,id,FLOAT,$max_terms.to_s,0)
        if GEN != MAXIMA then
          fd.puts sl(GEN,LINESEP,0,0,0,0)
        else
          fd.puts ";"
        end
      end
    end

  }
  $const_tbl.each_key {|id|
    if id != "array_m1" then
      if GEN != CCC and GEN != CPP then
        fd.puts sl(GEN,ARRAY1,id,FLOAT,$max_terms.to_s,0)
        if GEN != MAXIMA then
          fd.puts sl(GEN,LINESEP,0,0,0,0)
        else
          fd.puts ";"
        end

      end
    end
  }
  if GEN != CCC and GEN != CPP then
    fd.puts sl(GEN,ARRAY1,"array_m1",FLOAT,$max_terms.to_s,0)
    if GEN != MAXIMA then
      fd.puts sl(GEN,LINESEP,0,0,0,0)
    else
      fd.puts ";"
    end
  end
  fd.puts sl(GEN,REM,"END SYMBOLS DEFINED",0,0,0)
end




def symbols_initialized(fd)
  fd.puts sl(GEN,REM,"BEGIN SYMBOLS INITIALIZATED",0,0,0)

  $sym_tbl.each_key {|id|
    if $sym_tbl[id] == IDENTIFIER then
      fd.puts "zero_ats_ar(" + id + ")" + sl(GEN,LINESEP,0,0,0,0)
    end

  }
  $const_tbl.each_key {|id|
    if id != "array_m1" then
      fd.puts "zero_ats_ar(" + id + ")" + sl(GEN,LINESEP,0,0,0,0)
      fd.puts id + "[1]  " + sl(GEN,ASSIGN,0,0,0,0) + "c(" + const_untran(id) + ")" + sl(GEN,LINESEP,0,0,0,0)
    end
  }
  fd.puts "zero_ats_ar(array_m1)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "array_m1[1]  " + sl(GEN,ASSIGN,0,0,0,0) + "glob__m1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"END SYMBOLS INITIALIZATED",0,0,0)
end

def glob_decl(fd)
  if GEN == MAPLE
    fd.puts "global "
    generate_constants_decl(fd)
    generate_globals_decl(fd)
    generate_const_decl(fd)
    generate_arrays_decl(fd)
    fd.puts "ATS_MAX_TERMS,"
    fd.puts "glob_last;"
  end
end

def init_omniout_const(fd)
  if GEN != CCC and GEN != CPP and GEN != MAXIMA then
    if (GEN != RUBY) && (GEN != RUBY_APFP) then
      fd.puts "ALWAYS" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
      fd.puts "INFO" + sl(GEN,ASSIGN,0,0,0,0) + "2" + sl(GEN,LINESEP,0,0,0,0)
      fd.puts "DEBUGL" + sl(GEN,ASSIGN,0,0,0,0) + "3" + sl(GEN,LINESEP,0,0,0,0)
      fd.puts "DEBUGMASSIVE" + sl(GEN,ASSIGN,0,0,0,0) + "4" + sl(GEN,LINESEP,0,0,0,0)
      fd.puts "ATS_MAX_TERMS" + sl(GEN,ASSIGN,0,0,0,0) + $max_terms.to_s + sl(GEN,LINESEP,0,0,0,0)
    end
    fd.puts "glob_iolevel" + sl(GEN,ASSIGN,0,0,0,0) + "INFO" + sl(GEN,LINESEP,0,0,0,0)
  end
end

def gather_data_for_decl()
  if (GEN != RUBY) && (GEN != RUBY_APFP) then
    add_to_constants("ALWAYS","1",INTEGER)
    add_to_constants("INFO","2",INTEGER)
    add_to_constants("DEBUGL","3",INTEGER)
    add_to_constants("DEBUGMASSIVE","4",INTEGER)
    add_to_globals("MAX_UNCHANGED","10",INTEGER)
  end
  add_to_constants("glob_iolevel","5",INTEGER)
  add_to_constants("glob_yes_pole","4",INTEGER)
  add_to_constants("glob_no_pole","3",INTEGER)
  add_to_constants("glob_not_given","0",INTEGER)
  add_to_constants("glob_no_sing_tests","4",INTEGER)
  add_to_constants("glob_ratio_test","1",INTEGER)
  add_to_constants("glob_three_term_test","2",INTEGER)
  add_to_constants("glob_six_term_test","3",INTEGER)
  if GEN == MAXIMA then # MAXIMA FLOATS - no "c()"
    add_to_constants("ATS_MAX_TERMS",$max_terms.to_s,INTEGER)
    add_to_constants("glob_log_10","0.0",FLOAT)  # fill in later
    add_to_globals("glob__small","0.1e-50",FLOAT)
    add_to_globals("glob_small_float","0.1e-50",FLOAT)
    add_to_globals("glob_smallish_float","0.1e-60",FLOAT)
    add_to_globals("glob_large_float","1.0e100",FLOAT)
    add_to_globals("glob_larger_float","1.1e100",FLOAT)
    add_to_globals("glob__m2","-2.0",FLOAT)
    add_to_globals("glob__m1","-1.0",FLOAT)
    add_to_globals("glob__0","0.0",FLOAT)
    add_to_globals("glob__1","1.0",FLOAT)
    add_to_globals("glob__2","2.0",FLOAT)
    add_to_globals("glob__3","3.0",FLOAT)
    add_to_globals("glob__4","4.0",FLOAT)
    add_to_globals("glob__5","5.0",FLOAT)
    add_to_globals("glob__8","8.0",FLOAT)
    add_to_globals("glob__10","10.0",FLOAT)
    add_to_globals("glob__100","100.0",FLOAT)
    add_to_globals("glob__pi","0.0",FLOAT)
    add_to_globals("glob__0_5","0.5",FLOAT)
    add_to_globals("glob__0_8","0.8",FLOAT)
    add_to_globals("glob__m0_8","-0.8",FLOAT)
    add_to_globals("glob__0_25","0.25",FLOAT)
    add_to_globals("glob__0_125","0.125",FLOAT)
    add_to_globals("glob_prec","1.0e-16",FLOAT)
    add_to_globals("glob_check_sign","1.0",FLOAT)
    add_to_globals("glob_desired_digits_correct","8.0",FLOAT)
    add_to_globals("glob_max_estimated_step_error","0.0",FLOAT)
    add_to_globals("glob_ratio_of_radius","0.1",FLOAT)
    add_to_globals("glob_percent_done","0.0",FLOAT)
    add_to_globals("glob_total_exp_sec","0.1",FLOAT)
    add_to_globals("glob_optimal_expect_sec","0.1",FLOAT)
    add_to_globals("glob_estimated_size_answer","100.0",FLOAT)
    add_to_globals("glob_almost_1","0.9990",FLOAT)
    add_to_globals("glob_clock_sec","0.0",FLOAT)
    add_to_globals("glob_clock_start_sec","0.0",FLOAT)
    add_to_globals("glob_disp_incr","0.1",FLOAT)
    add_to_globals("glob_h","0.1",FLOAT)
    add_to_globals("glob_diff_rc_fm","0.1",FLOAT)
    add_to_globals("glob_diff_rc_fmm1","0.1",FLOAT)
    add_to_globals("glob_diff_rc_fmm2","0.1",FLOAT)
    add_to_globals("glob_diff_ord_fm","0.1",FLOAT)
    add_to_globals("glob_diff_ord_fmm1","0.1",FLOAT)
    add_to_globals("glob_diff_ord_fmm2","0.1",FLOAT)
    add_to_globals("glob_six_term_ord_save","0.1",FLOAT)
    add_to_globals("glob_guess_error_rc","0.1",FLOAT)
    add_to_globals("glob_guess_error_ord","0.1",FLOAT)
    add_to_globals("glob_least_given_sing","9.9e200",FLOAT)
    add_to_globals("glob_least_ratio_sing","9.9e200",FLOAT)
    add_to_globals("glob_least_3_sing","9.9e100",FLOAT)
    add_to_globals("glob_least_6_sing","9.9e100",FLOAT)
    add_to_globals("glob_last_good_h","0.1",FLOAT)
    add_to_globals("glob_max_h","0.1",FLOAT)
    add_to_globals("glob_min_h", "0.000001",FLOAT)
    add_to_globals("glob_display_interval","0.1",FLOAT)
    add_to_globals("glob_abserr","0.1e-10",FLOAT)
    add_to_globals("glob_relerr","0.1e-10",FLOAT)
    add_to_globals("glob_min_pole_est","0.1e+10",FLOAT)
    add_to_globals("glob_max_rel_trunc_err","0.1e-10",FLOAT)
    add_to_globals("glob_max_trunc_err","0.1e-10",FLOAT)
    add_to_globals("glob_max_hours","0.0",FLOAT)
    add_to_globals("glob_optimal_clock_start_sec","0.0",FLOAT)
    add_to_globals("glob_optimal_start","0.0",FLOAT)
    add_to_globals("glob_upper_ratio_limit","1.0001",FLOAT)
    add_to_globals("glob_lower_ratio_limit","0.9999",FLOAT)
    add_to_globals("glob_max_sec","10000.0",FLOAT)
    add_to_globals("glob_orig_start_sec","0.0",FLOAT)
    add_to_globals("glob_normmax","0.0",FLOAT)
    add_to_globals("glob_max_minutes","0.0",FLOAT)
    add_to_globals("glob_next_display","0.0",FLOAT)
  else

    ## Added to reduce repeated conversions
    if GEN == RUBY_APFP then
      add_to_globals("glob__small",'ap_in("0.1e-20+/-1.0e-100")',FLOAT)
      add_to_globals("glob_small_float",'ap_in("0.1e-20+/-1.0e-100")',FLOAT)
      add_to_globals("glob_smallish_float",'ap_in("0.1e-24+/-1.0e-100")',FLOAT)
      #A    add_to_globals("glob__small",'ap_in("0.1e-20+/-1.0e-24")',FLOAT)
      #A    add_to_globals("glob_small_float",'ap_in("0.1e-20+/-1.0e-24")',FLOAT)
      #    add_to_globals("glob_smallish_float",'ap_in("0.1e-24+/-1.0e-28")',FLOAT)
      add_to_globals("glob_large_float",'ap_in("1.0e100+/-1.0e90")',FLOAT)
      add_to_globals("glob_larger_float",'ap_in("1.1e100+/-1.1e90")',FLOAT)
      add_to_globals("glob__m2","c0(-2)",FLOAT)
      add_to_globals("glob__m1","c0(-1)",FLOAT)
      add_to_globals("glob__0","c0(0)",FLOAT)
      add_to_globals("glob__1","c0(1)",FLOAT)
      add_to_globals("glob__2","c0(2)",FLOAT)
      add_to_globals("glob__3","c0(3)",FLOAT)
      add_to_globals("glob__4","c0(4)",FLOAT)
      add_to_globals("glob__5","c0(5)",FLOAT)
      add_to_globals("glob__8","c0(8)",FLOAT)
      add_to_globals("glob__10","c0(10)",FLOAT)
      add_to_globals("glob__100","c0(100)",FLOAT)
    else
      add_to_globals("glob__small","c(0.1e-50)",FLOAT)
      add_to_globals("glob_small_float","c(0.1e-50)",FLOAT)
      add_to_globals("glob_smallish_float","c(0.1e-60)",FLOAT)
      add_to_globals("glob_large_float","c(1.0e100)",FLOAT)
      add_to_globals("glob_larger_float","c(1.1e100)",FLOAT)
      add_to_globals("glob__m2","c(-2)",FLOAT)
      add_to_globals("glob__m1","c(-1)",FLOAT)
      add_to_globals("glob__0","c(0)",FLOAT)
      add_to_globals("glob__1","c(1)",FLOAT)
      add_to_globals("glob__2","c(2)",FLOAT)
      add_to_globals("glob__3","c(3)",FLOAT)
      add_to_globals("glob__4","c(4)",FLOAT)
      add_to_globals("glob__5","c(5)",FLOAT)
      add_to_globals("glob__8","c(8)",FLOAT)
      add_to_globals("glob__10","c(10)",FLOAT)
      add_to_globals("glob__100","c(100)",FLOAT)
    end
    add_to_constants("glob_log_10","log(c(10.0))",FLOAT)
    add_to_globals("glob__pi","c(0.0)",FLOAT)
    add_to_globals("glob__0_5","c(0.5)",FLOAT)
    add_to_globals("glob__0_8","c(0.8)",FLOAT)
    add_to_globals("glob__m0_8","c(-0.8)",FLOAT)
    add_to_globals("glob__0_25","c(0.25)",FLOAT)
    add_to_globals("glob__0_125","c(0.125)",FLOAT)
    #######################
    add_to_globals("glob_prec","c(1.0e-16)",FLOAT)
    add_to_globals("glob_check_sign","c(1.0)",FLOAT)
    add_to_globals("glob_desired_digits_correct","c(8.0)",FLOAT)
    add_to_globals("glob_max_estimated_step_error","c(0.0)",FLOAT)
    add_to_globals("glob_ratio_of_radius","c(0.1)",FLOAT)
    add_to_globals("glob_percent_done","c(0.0)",FLOAT)
    add_to_globals("glob_total_exp_sec","c(0.1)",FLOAT)
    add_to_globals("glob_optimal_expect_sec","c(0.1)",FLOAT)
    add_to_globals("glob_estimated_size_answer","c(100.0)",FLOAT)
    add_to_globals("glob_almost_1","c(0.9990)",FLOAT)
    add_to_globals("glob_clock_sec","c(0.0)",FLOAT)
    add_to_globals("glob_clock_start_sec","c(0.0)",FLOAT)
    add_to_globals("glob_disp_incr","c(0.1)",FLOAT)
    add_to_globals("glob_h","c(0.1)",FLOAT)
    add_to_globals("glob_diff_rc_fm","c(0.1)",FLOAT)
    add_to_globals("glob_diff_rc_fmm1","c(0.1)",FLOAT)
    add_to_globals("glob_diff_rc_fmm2","c(0.1)",FLOAT)
    add_to_globals("glob_diff_ord_fm","c(0.1)",FLOAT)
    add_to_globals("glob_diff_ord_fmm1","c(0.1)",FLOAT)
    add_to_globals("glob_diff_ord_fmm2","c(0.1)",FLOAT)
    add_to_globals("glob_six_term_ord_save","c(0.1)",FLOAT)
    add_to_globals("glob_guess_error_rc","c(0.1)",FLOAT)
    add_to_globals("glob_guess_error_ord","c(0.1)",FLOAT)
    add_to_globals("glob_least_given_sing","c(9.9e200)",FLOAT)
    add_to_globals("glob_least_ratio_sing","c(9.9e200)",FLOAT)
    add_to_globals("glob_least_3_sing","c(9.9e100)",FLOAT)
    add_to_globals("glob_least_6_sing","c(9.9e100)",FLOAT)
    add_to_globals("glob_last_good_h","c(0.1)",FLOAT)
    add_to_globals("glob_max_h","c(0.1)",FLOAT)
    add_to_globals("glob_min_h", "c(0.000001)",FLOAT)
    add_to_globals("glob_display_interval","c(0.1)",FLOAT)
    add_to_globals("glob_abserr","c(0.1e-10)",FLOAT)
    add_to_globals("glob_relerr","c(0.1e-10)",FLOAT)
    add_to_globals("glob_min_pole_est","c(0.1e+10)",FLOAT)
    add_to_globals("glob_max_rel_trunc_err","c(0.1e-10)",FLOAT)
    add_to_globals("glob_max_trunc_err","c(0.1e-10)",FLOAT)
    add_to_globals("glob_max_hours","c(0.0)",FLOAT)
    add_to_globals("glob_optimal_clock_start_sec","c(0.0)",FLOAT)
    add_to_globals("glob_optimal_start","c(0.0)",FLOAT)
    add_to_globals("glob_upper_ratio_limit","c(1.0001)",FLOAT)
    add_to_globals("glob_lower_ratio_limit","c(0.9999)",FLOAT)
    add_to_globals("glob_max_sec","c(10000.0)",FLOAT)
    add_to_globals("glob_orig_start_sec","c(0.0)",FLOAT)
    add_to_globals("glob_normmax","c(0.0)",FLOAT)
    add_to_globals("glob_max_minutes","c(0.0)",FLOAT)
    add_to_globals("glob_next_display","c(0.0)",FLOAT)
  end
  add_to_globals("glob_est_digits","1",INTEGER)
  add_to_globals("glob_subiter_method","3",INTEGER)
  add_to_globals("glob_html_log","true",BOOLEAN)
  add_to_globals("glob_min_good_digits","99999",INTEGER)
  add_to_globals("glob_good_digits","0",INTEGER)
  add_to_globals("glob_min_apfp_est_good_digits","99999",INTEGER)
  add_to_globals("glob_apfp_est_good_digits","0",INTEGER)
  add_to_globals("glob_max_opt_iter","10",INTEGER)
  add_to_globals("glob_dump","false",BOOLEAN)
  add_to_globals("glob_djd_debug","true",BOOLEAN)
  add_to_globals("glob_display_flag","true",BOOLEAN)
  add_to_globals("glob_djd_debug2","true",BOOLEAN)
  add_to_globals("glob_h_reason","0",INTEGER)
  add_to_globals("glob_sec_in_minute","60 ",INTEGER)
  add_to_globals("glob_min_in_hour","60",INTEGER)
  add_to_globals("glob_hours_in_day","24",INTEGER)
  add_to_globals("glob_days_in_year","365",INTEGER)
  add_to_globals("glob_sec_in_hour","3600",INTEGER)
  add_to_globals("glob_sec_in_day","86400",INTEGER)
  add_to_globals("glob_sec_in_year","31536000",INTEGER)
  add_to_globals("glob_not_yet_finished","true" ,BOOLEAN)
  add_to_globals("glob_initial_pass","true" ,BOOLEAN)
  add_to_globals("glob_not_yet_start_msg","true" ,BOOLEAN)
  add_to_globals("glob_reached_optimal_h","false",BOOLEAN)
  add_to_globals("glob_optimal_done","false",BOOLEAN)
  add_to_globals("glob_type_given_pole","0",INTEGER)
  add_to_globals("glob_optimize","false",BOOLEAN)
  add_to_globals("glob_look_poles","false",BOOLEAN)
  add_to_globals("glob_dump_closed_form","false",BOOLEAN)
  add_to_globals("glob_max_iter","1000",INTEGER)
  add_to_globals("glob_no_eqs","0",INTEGER)
  add_to_globals("glob_unchanged_h_cnt","0",INTEGER)
  add_to_globals("glob_warned","false",BOOLEAN)
  add_to_globals("glob_warned2","false",BOOLEAN)
  add_to_globals("glob_start","0",INTEGER)
  add_to_globals("glob_iter","0",INTEGER)
  eq_no = 1
  while eq_no <= $no_eqs do
    add_to_arrays1($eq_rec[eq_no].dep_var_diff + "_init",$max_terms.to_s,"nop",FLOAT,"c(0.0)")
    add_to_arrays2($eq_rec[eq_no].dep_var_diff + "_higher",($eq_rec[eq_no].max_order_occurs + 1).to_s,$max_terms.to_s,FLOAT,"c(0.0)")
    add_to_arrays2($eq_rec[eq_no].dep_var_diff + "_higher_work",($eq_rec[eq_no].max_order_occurs + 1).to_s,$max_terms.to_s,FLOAT,"c(0.0)")
    add_to_arrays2($eq_rec[eq_no].dep_var_diff + "_higher_work2",($eq_rec[eq_no].max_order_occurs + 1).to_s,$max_terms.to_s,FLOAT,"c(0.0)")
    add_to_arrays2($eq_rec[eq_no].dep_var_diff + "_set_initial",($no_eqs + 1).to_s,$max_terms.to_s,FLOAT,"c(0.0)")
    eq_no += 1
  end
  add_to_arrays1("array_norms",$max_terms.to_s,"nop",FLOAT,"c(0.0)")
  add_to_arrays1("array_fact_1",$max_terms.to_s,"nop",FLOAT,"c(0.0)")
  add_to_arrays1("array_1st_rel_error",($no_eqs + 1).to_s,"nop",FLOAT,"c(0.0)")
  add_to_arrays1("array_last_rel_error",($no_eqs + 1).to_s,"nop",FLOAT,"c(0.0)")
  add_to_arrays1("array_est_rel_error",($no_eqs + 1).to_s,"nop",FLOAT,"c(0.0)")
  add_to_arrays1("array_max_est_error",($no_eqs + 1).to_s,"nop",FLOAT,"c(0.0)")
  add_to_arrays1("array_type_pole",($no_eqs + 1).to_s,"nop",INTEGER,"0")
  add_to_arrays1("array_type_real_pole",($no_eqs + 1).to_s,"nop",INTEGER,"0")
  add_to_arrays1("array_type_complex_pole",($no_eqs + 1).to_s,"nop",INTEGER,"0")
  add_to_arrays1("array_est_digits",($no_eqs + 1).to_s,"nop",INTEGER,"0")
#  add_to_arrays1("array_good_digits",($no_eqs + 1).to_s,"nop",INTEGER,"0")


  # second subscript below 1 for real part 2 for imaginary part
  add_to_arrays2("array_given_rad_poles",($no_eqs + 1).to_s,"3",FLOAT,"c(0.0)")
  # second subscript below 1 for real part 2 not used (no imaginary powers)
  add_to_arrays2("array_given_ord_poles",($no_eqs + 1).to_s,"3",FLOAT,"c(0.0)")
  # next 3 items second subscript indicates test
  add_to_arrays2("array_rad_test_poles",($no_eqs + 1).to_s,"4",FLOAT,"c(0.0)")
  add_to_arrays2("array_ord_test_poles",($no_eqs + 1).to_s,"4",FLOAT,"c(0.0)")
  add_to_arrays2("array_fact_2",$max_terms.to_s,$max_terms.to_s,FLOAT,"c(0.0)")

  # handy for param decls
  $bounds = remove_array_str($indep_var_diff) + "_start" + "," + remove_array_str($indep_var_diff) + "_end"
  $bounds2 = st2(FLOAT) + remove_array_str($indep_var_diff) + "_start" + "," + st2(FLOAT) + remove_array_str($indep_var_diff) + "_end"
  $bounds3 = st2(FLOAT) + remove_array_str($indep_var_diff) + "_start" + ";" + st2(FLOAT) + remove_array_str($indep_var_diff) + "_end" + ";"

  $sym_tbl.each_key {|id|
    if $sym_tbl[id] == IDENTIFIER then
      if id != "array_m1" then
        if $series_tbl[id] == ID_FULL then
          add_to_arrays1(id , $max_terms.to_s,"nop",FLOAT,"c(0.0)")
        else
          add_to_arrays1(id , $max_terms.to_s,"nop",FLOAT,"c(0.0)")  # should only need 2 instead of max terms but causes trouble
        end
      end
    end
  }
  add_to_arrays1("array_m1",$max_terms.to_s,"nop",FLOAT,"c(0.0)")
  $sym_tbl["array_m1"] = IDENTIFIER
  $series_tbl["array_m1"] = ID_CONST

  $total_order = 0
  eq_no = 1
  while eq_no <= $no_eqs do
    $total_order += $eq_rec[eq_no].order_diff.to_i
    eq_no +=1
  end
  eq_no = 1

end
# example diff("y1","0","exact_soln_y1(x_start)");
# def diff(dep_var,order,value)
# this function is used to set initial conditions and mark variable as
# not to be changed in atomall
# dep_var is dependent variable (as string)
# order is order of derivative initial condition is for - starts as zero here
# also a string.
# value is also string
# $outfilemain.puts 'array_' + dep_var + '_init[' + order + ' + 1]' + sl(GEN,ASSIGN,0,0,0,0) + value + sl(GEN,LINESEP,0,0,0)
# set_initial[dep_var + '[' + order + ' + 1]'] = true
# end
def start_series(fd,eq_no)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_init = $eq_rec[eq_no].dep_var_diff + "_init"
  fd.puts "order_diff" + sl(GEN,ASSIGN,0,0,0,0) + $eq_rec[eq_no].max_order_occurs.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"Start Series " + array_name_dep_var_diff,0,0,0)

  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term_no <= order_diff)" + sl(GEN,DO,0,0,0,0)
  fd.puts array_name_dep_var_diff + sl(GEN,SUBSC1,"term_no",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_init+ sl(GEN,SUBSC1,"term_no",0,0,0) + " * expt(glob_h , c(term_no - 1)) / c(factorial_1(term_no - 1))"+ sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " term_no + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "rows  " + sl(GEN,ASSIGN,0,0,0,0) + " order_diff" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "r_order  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (r_order <= rows)" + sl(GEN,DO,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term_no <= (rows - r_order + 1))" + sl(GEN,DO,0,0,0,0)
  fd.puts "it " + sl(GEN,ASSIGN,0,0,0,0) + "term_no + r_order - 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (term_no < ATS_MAX_TERMS)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher + sl(GEN,SUBSC2,"r_order","term_no",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_init + sl(GEN,SUBSC1,"it",0,0,0) + "* expt(glob_h , c(term_no - 1)) / (c(factorial_1(term_no - 1)))" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " term_no + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "r_order  " + sl(GEN,ASSIGN,0,0,0,0) + " r_order + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) # + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,LINESEP,0,0,0,0)
end

def jump_series(fd,eq_no)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_higher_work2 = $eq_rec[eq_no].dep_var_diff + "_higher_work2"
  order_diff = $eq_rec[eq_no].order_diff.to_i + 1
  fd.puts sl(GEN,REM,"Jump Series " + array_name_dep_var_diff,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "order_diff " + sl(GEN,ASSIGN,0,0,0,0) + order_diff.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"START PART 1  SUM AND ADJUST",0,0,0)
  sum_and_adjust(fd,eq_no)
  fd.puts sl(GEN,REM,"END PART 1 ",0,0,0)
  fd.puts sl(GEN,REM,"START PART 2  MOVE TERMS to REGULAR Array",0,0,0)
  fd.puts "term_no" + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term_no >= 1)" + sl(GEN,DO,0,0,0,0)
  fd.puts array_name_dep_var_diff + sl(GEN,SUBSC1,"term_no",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"1","term_no",0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (ord <= order_diff) " + sl(GEN,DO,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher + sl(GEN,SUBSC2,"ord","term_no",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"ord","term_no",0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + "ord + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " term_no - 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,REM,"END PART 2 HEVE MOVED TERMS to REGULAR Array",0,0,0)
### ---------------------END PART 2 --------------------------------
end
def adjust_all_series(fd)
  fd.puts sl(GEN,REM,"START ADJUST ALL SERIES",0,0,0)
  fd.puts "if (float_abs(glob_min_pole_est) * glob_ratio_of_radius < float_abs(glob_h))" + sl(GEN,THEN,0,0,0,0)

  fd.puts "h_new" + sl(GEN,ASSIGN,0,0,0,0) + "glob_check_sign * glob_min_pole_est * glob_ratio_of_radius" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR POLE")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "6" + sl(GEN,LINESEP,0,0,0,0)
######################
  fd.puts "if (glob_check_sign * glob_min_h > glob_check_sign * h_new)" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR MIN H")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "h_new" + sl(GEN,ASSIGN,0,0,0,0) + "glob_min_h" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "5" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
########################
  fd.puts "term"  + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ratio" + sl(GEN,ASSIGN,0,0,0,0) + "c(1.0)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term <= ATS_MAX_TERMS) " + sl(GEN,DO,0,0,0,0)
  eq_no = 1
  while eq_no <= $no_eqs do
    series = $eq_rec[eq_no].dep_var_diff
    fd.puts series + sl(GEN,SUBSC1,"term",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + series + sl(GEN,SUBSC1,"term",0,0,0) + "* ratio" + sl(GEN,LINESEP,0,0,0,0)

    fd.puts series + "_higher"+ sl(GEN,SUBSC2,"1","term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + series + "_higher" + sl(GEN,SUBSC2,"1","term",0,0) + "* ratio" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts $indep_var_diff + sl(GEN,SUBSC1,"term",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + $indep_var_diff + sl(GEN,SUBSC1,"term",0,0,0) + "* ratio" + sl(GEN,LINESEP,0,0,0,0)
    eq_no += 1
  end
  fd.puts "ratio" + sl(GEN,ASSIGN,0,0,0,0) + "ratio * h_new / float_abs(glob_h)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term"  + sl(GEN,ASSIGN,0,0,0,0) + "term + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "h_new"  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)

  fd.puts sl(GEN,REM,"BOTTOM ADJUST ALL SERIES",0,0,0)
end

def sum_and_adjust(fd,eq_no)
  fd.puts sl(GEN,REM,"START SUM AND ADJUST EQ =" + eq_no.to_s,0,0,0)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_work = $eq_rec[eq_no].dep_var_diff + "_higher_work"
  fd.puts sl(GEN,REM,"sum_and_adjust " + array_name_dep_var_diff,0,0,0)
  ord = $eq_rec[eq_no].order_diff.to_i + 1
  jjj = 1
  while (ord >= 1) do
    calc_term = jjj
    while (calc_term >= 1) do
      fd.puts sl(GEN,REM,"BEFORE ADJUST SUBSERIES EQ =" + eq_no.to_s,0,0,0)

      adjust_subseries(fd,eq_no,ord,calc_term)
      fd.puts sl(GEN,REM,"AFTER ADJUST SUBSERIES EQ =" + eq_no.to_s,0,0,0)
      fd.puts sl(GEN,REM,"BEFORE SUM SUBSERIES EQ =" + eq_no.to_s,0,0,0)
      sum_subseries(fd,eq_no,ord,calc_term)
      fd.puts sl(GEN,REM,"AFTER SUM SUBSERIES EQ =" + eq_no.to_s,0,0,0)
      calc_term -= 1
    end
    ord -= 1
    jjj += 1
  end
  fd.puts sl(GEN,REM,"END SUM AND ADJUST EQ =" + eq_no.to_s,0,0,0)
end

def adjust_subseries(fd,eq_no,ord,calc_term)
  if GEN == MAPLE and DEBUG_JUMP then
    fd.puts 'print("adjust_subseries(array,array_work",ord,calc_term);'
  end
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_higher_work = $eq_rec[eq_no].dep_var_diff + "_higher_work"
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + ord.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "calc_term" + sl(GEN,ASSIGN,0,0,0,0) + calc_term.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"adjust_subseries" + array_name_dep_var_diff,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (iii >= calc_term)  " + sl(GEN,DO,0,0,0,0)
  if GEN == RUBY and false then
    fd.puts 'puts "' + array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + ' / expt(" + glob_h.to_s + "," +  c(calc_term - 1).to_s + ") * c(factorial_3(" + ' + '(iii - calc_term).to_s' + ',' + '( iii  - 1).to_s' + '+ "))"'  + sl(GEN,LINESEP,0,0,0,0)
  end
  fd.puts array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + " / expt(glob_h , c(calc_term - 1)) / c(factorial_3(iii - calc_term , iii  - 1))"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "iii - 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

end

def sum_subseries(fd,eq_no,ord,calc_term)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_higher_work = $eq_rec[eq_no].dep_var_diff + "_higher_work"
  array_name_dep_var_diff_higher_work2 = $eq_rec[eq_no].dep_var_diff + "_higher_work2"
  fd.puts "temp_sum" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + ord.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "calc_term" + sl(GEN,ASSIGN,0,0,0,0) + calc_term.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"sum_subseries" + array_name_dep_var_diff,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (iii >= calc_term)  " + sl(GEN,DO,0,0,0,0)
  fd.puts "temp_sum" + sl(GEN,ASSIGN,0,0,0,0) + "temp_sum + " + array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,"ord","iii",0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "iii - 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"ord","calc_term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "temp_sum" + " * expt(glob_h , c(calc_term - 1)) / c(factorial_1(calc_term - 1))" + sl(GEN,LINESEP,0,0,0,0)
end

def start_series_bad(fd,eq_no)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_init = $eq_rec[eq_no].dep_var_diff + "_init"
  fd.puts "order_diff" + sl(GEN,ASSIGN,0,0,0,0) + $eq_rec[eq_no].max_order_occurs.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"Start Series " + array_name_dep_var_diff,0,0,0)

  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (term_no <= order_diff)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff + sl(GEN,SUBSC1,"term_no",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(" + array_name_dep_var_diff_init + sl(GEN,SUBSC1,"term_no",0,0,0) + ")"+ sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 2" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (term_no <= order_diff)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff + sl(GEN,SUBSC1,"term_no",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(" + array_name_dep_var_diff_init + sl(GEN,SUBSC1,"term_no",0,0,0) + ") * glob_h"+ sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 3" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term_no <= order_diff)" + sl(GEN,DO,0,0,0,0)
  fd.puts array_name_dep_var_diff + sl(GEN,SUBSC1,"term_no",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(" + array_name_dep_var_diff_init + sl(GEN,SUBSC1,"term_no",0,0,0) + ") * expt(glob_h , c(term_no - 1)) / c(factorial_1(term_no - 1))"+ sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " term_no + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "rows  " + sl(GEN,ASSIGN,0,0,0,0) + " order_diff" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "r_order  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (r_order <= rows)" + sl(GEN,DO,0,0,0,0)
  fd.puts "r_order  " + sl(GEN,ASSIGN,0,0,0,0) + " 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "it " + sl(GEN,ASSIGN,0,0,0,0) + "term_no + r_order - 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (term_no <= order_diff)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher + sl(GEN,SUBSC2,"r_order","term_no",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(" + array_name_dep_var_diff_init + sl(GEN,SUBSC1,"it",0,0,0) + ")" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 2" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "r_order  " + sl(GEN,ASSIGN,0,0,0,0) + " 2" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "it " + sl(GEN,ASSIGN,0,0,0,0) + "term_no + r_order - 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (term_no <= order_diff)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher + sl(GEN,SUBSC2,"r_order","term_no",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(" + array_name_dep_var_diff_init + sl(GEN,SUBSC1,"it",0,0,0) + ") * glob_h" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " 3" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "r_order  " + sl(GEN,ASSIGN,0,0,0,0) + " 3" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term_no <= (rows - r_order + 1))" + sl(GEN,DO,0,0,0,0)
  fd.puts "it " + sl(GEN,ASSIGN,0,0,0,0) + "term_no + r_order - 1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (term_no < ATS_MAX_TERMS)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher + sl(GEN,SUBSC2,"r_order","term_no",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "c(" + array_name_dep_var_diff_init + sl(GEN,SUBSC1,"it",0,0,0) + ") * expt(glob_h , c(term_no - 1)) / (c(factorial_1(term_no - 1)))" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " term_no + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "r_order  " + sl(GEN,ASSIGN,0,0,0,0) + " r_order + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) # + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,LINESEP,0,0,0,0)
end
def jump_series_bad(fd,eq_no)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_higher_work2 = $eq_rec[eq_no].dep_var_diff + "_higher_work2"
  order_diff = $eq_rec[eq_no].order_diff.to_i + 1
  fd.puts sl(GEN,REM,"Jump Series " + array_name_dep_var_diff,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "order_diff " + sl(GEN,ASSIGN,0,0,0,0) + order_diff.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"START PART 1  SUM AND ADJUST",0,0,0)
  sum_and_adjust(fd,eq_no)
  fd.puts sl(GEN,REM,"END PART 1 ",0,0,0)
  fd.puts sl(GEN,REM,"START PART 2  MOVE TERMS to REGULAR Array",0,0,0)
  fd.puts "term_no" + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term_no >= 1)" + sl(GEN,DO,0,0,0,0)
  fd.puts array_name_dep_var_diff + sl(GEN,SUBSC1,"term_no",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"1","term_no",0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (ord <= order_diff) " + sl(GEN,DO,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher + sl(GEN,SUBSC2,"ord","term_no",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"ord","term_no",0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + "ord + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term_no  " + sl(GEN,ASSIGN,0,0,0,0) + " term_no - 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,REM,"END PART 2 HEVE MOVED TERMS to REGULAR Array",0,0,0)
### ---------------------END PART 2 --------------------------------
end
def adjust_all_series_bad(fd)
  fd.puts sl(GEN,REM,"START ADJUST ALL SERIES",0,0,0)
  fd.puts "if (float_abs(glob_min_pole_est) * glob_ratio_of_radius < float_abs(glob_h))" + sl(GEN,THEN,0,0,0,0)

  fd.puts "h_new" + sl(GEN,ASSIGN,0,0,0,0) + "glob_check_sign * glob_min_pole_est * glob_ratio_of_radius" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR POLE")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "6" + sl(GEN,LINESEP,0,0,0,0)
######################
  fd.puts "if (glob_check_sign * glob_min_h > glob_check_sign * h_new)" + sl(GEN,THEN,0,0,0,0)
  fd.puts 'omniout_str(ALWAYS,"SETTING H FOR MIN H")' + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "h_new" + sl(GEN,ASSIGN,0,0,0,0) + "glob_min_h" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h_reason" + sl(GEN,ASSIGN,0,0,0,0) + "5" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
########################
  fd.puts "term"  + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ratio" + sl(GEN,ASSIGN,0,0,0,0) + "glob__1" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (term <= ATS_MAX_TERMS) " + sl(GEN,DO,0,0,0,0)
  eq_no = 1
  while eq_no <= $no_eqs do
    series = $eq_rec[eq_no].dep_var_diff
    fd.puts series + sl(GEN,SUBSC1,"term",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + series + sl(GEN,SUBSC1,"term",0,0,0) + "* ratio" + sl(GEN,LINESEP,0,0,0,0)

    fd.puts series + "_higher"+ sl(GEN,SUBSC2,"1","term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + series + "_higher" + sl(GEN,SUBSC2,"1","term",0,0) + "* ratio" + sl(GEN,LINESEP,0,0,0,0)
    fd.puts $indep_var_diff + sl(GEN,SUBSC1,"term",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + $indep_var_diff + sl(GEN,SUBSC1,"term",0,0,0) + "* ratio" + sl(GEN,LINESEP,0,0,0,0)
    eq_no += 1
  end
  fd.puts "ratio" + sl(GEN,ASSIGN,0,0,0,0) + "ratio * h_new / float_abs(glob_h)" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "term"  + sl(GEN,ASSIGN,0,0,0,0) + "term + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "glob_h" + sl(GEN,ASSIGN,0,0,0,0) + "h_new"  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)

  fd.puts sl(GEN,REM,"BOTTOM ADJUST ALL SERIES",0,0,0)
end

def sum_and_adjust_bad(fd,eq_no)
  fd.puts sl(GEN,REM,"START SUM AND ADJUST EQ =" + eq_no.to_s,0,0,0)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_work = $eq_rec[eq_no].dep_var_diff + "_higher_work"
  fd.puts sl(GEN,REM,"sum_and_adjust " + array_name_dep_var_diff,0,0,0)
  ord = $eq_rec[eq_no].order_diff.to_i + 1
  jjj = 1
  while (ord >= 1) do
    calc_term = jjj
    while (calc_term >= 1) do
      fd.puts sl(GEN,REM,"BEFORE ADJUST SUBSERIES EQ =" + eq_no.to_s,0,0,0)

      adjust_subseries(fd,eq_no,ord,calc_term)
      fd.puts sl(GEN,REM,"AFTER ADJUST SUBSERIES EQ =" + eq_no.to_s,0,0,0)
      fd.puts sl(GEN,REM,"BEFORE SUM SUBSERIES EQ =" + eq_no.to_s,0,0,0)
      sum_subseries(fd,eq_no,ord,calc_term)
      fd.puts sl(GEN,REM,"AFTER SUM SUBSERIES EQ =" + eq_no.to_s,0,0,0)
      calc_term -= 1
    end
    ord -= 1
    jjj += 1
  end
  fd.puts sl(GEN,REM,"END SUM AND ADJUST EQ =" + eq_no.to_s,0,0,0)
end

def adjust_subseries_bad(fd,eq_no,ord,calc_term)
  if GEN == MAPLE and DEBUG_JUMP then
    fd.puts 'print("adjust_subseries(array,array_work",ord,calc_term);'
  end
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_higher_work = $eq_rec[eq_no].dep_var_diff + "_higher_work"
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + ord.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "calc_term" + sl(GEN,ASSIGN,0,0,0,0) + calc_term.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"adjust_subseries" + array_name_dep_var_diff,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (iii >= calc_term)  " + sl(GEN,DO,0,0,0,0)
  if GEN == RUBY and false then
    fd.puts 'puts "' + array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + ' / expt(" + glob_h.to_s + "," +  c(calc_term - 1).to_s + ") * c(factorial_3(" + ' + '(iii - calc_term).to_s' + ' ,' + '( iii  - 1).to_s' + '+ "))"'  + sl(GEN,LINESEP,0,0,0,0)
  end
  fd.puts "if (calc_term " + sl(GEN,EQUALS,0,0,0,0) + "1)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher + sl(GEN,SUBSC2,ord.to_s,"iii",0,0)  + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(calc_term " + sl(GEN,EQUALS,0,0,0,0) + "2)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + " / glob_h / c(factorial_3(iii - calc_term , iii  - 1))"  + sl(GEN,LINESEP,0,0,0,0)
   fd.puts sl(GEN,ELSE,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + sl(GEN,ASSIGN,0,0,0,0) + array_name_dep_var_diff_higher + sl(GEN,SUBSC2,ord.to_s,"iii",0,0) + " / expt(glob_h , c(calc_term - 1)) / c(factorial_3(iii - calc_term , iii  - 1))"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "iii - 1" + sl(GEN,LINEEND,0,0,0,0)

  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

end

def sum_subseries_bad(fd,eq_no,ord,calc_term)
  array_name_dep_var_diff = $eq_rec[eq_no].dep_var_diff
  array_name_dep_var_diff_higher = $eq_rec[eq_no].dep_var_diff + "_higher"
  array_name_dep_var_diff_higher_work = $eq_rec[eq_no].dep_var_diff + "_higher_work"
  array_name_dep_var_diff_higher_work2 = $eq_rec[eq_no].dep_var_diff + "_higher_work2"
  fd.puts "temp_sum" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "ord" + sl(GEN,ASSIGN,0,0,0,0) + ord.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "calc_term" + sl(GEN,ASSIGN,0,0,0,0) + calc_term.to_s + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"sum_subseries" + array_name_dep_var_diff,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "ATS_MAX_TERMS" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (iii >= calc_term)  " + sl(GEN,DO,0,0,0,0)
  fd.puts "temp_sum" + sl(GEN,ASSIGN,0,0,0,0) + "temp_sum + " + array_name_dep_var_diff_higher_work + sl(GEN,SUBSC2,"ord","iii",0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "iii - 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "if (calc_term " + sl(GEN,EQUALS,0,0,0,0) + "1)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"ord","calc_term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "temp_sum" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(calc_term " + sl(GEN,EQUALS,0,0,0,0) + "2)" + sl(GEN,THEN,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"ord","calc_term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "temp_sum" + " * glob_h" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,ELSE,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"ord","calc_term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "temp_sum" + " * expt(glob_h , c(calc_term - 1)) / c(factorial_1(calc_term - 1))" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts array_name_dep_var_diff_higher_work2 + sl(GEN,SUBSC2,"ord","calc_term",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "temp_sum" + " * expt(glob_h , c(calc_term - 1)) / c(factorial_1(calc_term - 1))" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0)
end
def write_html_log(fd)
  $eq_no = 1
  fd.puts "if (glob_html_log) " + sl(GEN,THEN,0,0,0,0)
  fd.puts "logstart(html_log_file)" + sl(GEN,LINESEP,0,0,0,0)
  while $eq_no <= $no_eqs do
    log_html_str(fd,$date_start.to_s,false)
    if GEN == MAPLE then
      log_html_str(fd,'"Maple"' ,false)
    elsif GEN == RUBY then
      log_html_str(fd,'"Ruby"',false)
    elsif GEN == RUBY_APFP then
      log_html_str(fd,'"Ruby Apfp"',false)
    elsif GEN == MAXIMA then
      log_html_str(fd,'"Maxima"',false)
    elsif GEN == CPP then
      log_html_str(fd,'"c++"',false)
    elsif GEN == CCC then
      log_html_str(fd,'"c"',false)
    else
      log_html_str(fd,'"Unknown"',false)
    end
    log_html_ode_html(fd,  $odename ,false)
    log_html_str(fd,'"' + $equation[$eq_no] + '"',true)
    log_html_float(fd,remove_array_str($indep_var_diff) + '_start',false)
    log_html_float(fd,remove_array_str($indep_var_diff) + '_end',false)
    log_html_float(fd, $indep_var_diff + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0)  ,false)
    log_html_float(fd,'glob_h',false)
    log_html_h_reason(fd,'glob_h_reason',false)
    if GEN == MAPLE
      log_html_integer(fd,'Digits',false)
    fd.puts sl(GEN,LINESEP,0,0,0,0)
    elsif GEN == RUBY then
      log_html_str(fd,'"16"',false)
    elsif GEN == RUBY_APFP then
      log_html_str(fd,DESIRED_DIGITS.to_s,false)
    elsif GEN == MAXIMA then
      log_html_str(fd,'"16"',false)
    elsif GEN == CCC then
      log_html_str(fd,'"16"',false)
    elsif GEN == CPP then
      log_html_str(fd,'"16"',false)
    else
      log_html_str(fd,'"Unknown"',false)
    end
    log_html_float(fd,'glob_desired_digits_correct',false)

    fd.puts 'if (array_est_digits' + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0) + sl(GEN,NOTEQUALS,0,0,0,0) + "-16)" + sl(GEN,THEN,0,0,0,0)
    log_html_integer(fd,'array_est_digits' + sl(GEN,SUBSC1,$eq_no.to_s,0,0,0),true)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    log_html_str(fd,'"Unknown"',true)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
##
    fd.puts 'if (glob_min_good_digits' + sl(GEN,NOTEQUALS,0,0,0,0) + "-16)" + sl(GEN,THEN,0,0,0,0)
    log_html_integer(fd,'glob_min_good_digits',true)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    log_html_str(fd,'"Unknown"',true)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
###
    fd.puts 'if (glob_good_digits' + sl(GEN,NOTEQUALS,0,0,0,0) + "-16)" + sl(GEN,THEN,0,0,0,0)
    log_html_integer(fd,'glob_good_digits',true)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    log_html_str(fd,'"Unknown"',true)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
##
    if GEN == RUBY_APFP then
    log_html_integer(fd,'glob_min_apfp_est_good_digits',true)
    else
    log_html_str(fd,'"NA"',true)
    end
##

    if GEN == RUBY_APFP then
    log_html_integer(fd,'glob_apfp_est_good_digits',true)
    else
    log_html_str(fd,'"NA"',true)
    end
###
###
    log_html_integer(fd,'ATS_MAX_TERMS',false )

    fd.puts "if (glob_type_given_pole " + sl(GEN,EQUALS,0,0,0,0) + "0)" + sl(GEN,THEN,0,0,0,0)
    log_html_str(fd,'"Not Given"',false)
    log_html_str(fd,'"NA"',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_type_given_pole " + sl(GEN,EQUALS,0,0,0,0) + "4)" + sl(GEN,THEN,0,0,0,0)
    log_html_str(fd,'"No Solution"',false)
    log_html_str(fd,'"NA"',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_type_given_pole " + sl(GEN,EQUALS,0,0,0,0) + "5)" + sl(GEN,THEN,0,0,0,0)
    log_html_str(fd,'"Some Pole"',false)
    log_html_str(fd,'"????"',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_type_given_pole " + sl(GEN,EQUALS,0,0,0,0) + "3)" + sl(GEN,THEN,0,0,0,0)
    log_html_str(fd,'"No Pole"',false)
    log_html_str(fd,'"NA"',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_type_given_pole " + sl(GEN,EQUALS,0,0,0,0) + "1)" + sl(GEN,THEN,0,0,0,0)
    log_html_str(fd,'"Real Sing"',false)
    log_html_float(fd,'glob_least_given_sing',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_type_given_pole " + sl(GEN,EQUALS,0,0,0,0) + "2)" + sl(GEN,THEN,0,0,0,0)
    log_html_str(fd,'"Complex Sing"',false)
    log_html_float(fd,'glob_least_given_sing',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

    fd.puts "if (glob_least_ratio_sing < glob_large_float)" + sl(GEN,THEN,0,0,0,0)
    log_html_float(fd,'glob_least_ratio_sing',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    log_html_str(fd,'"NONE"',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (glob_least_3_sing < glob_large_float)" + sl(GEN,THEN,0,0,0,0)
    log_html_float(fd,'glob_least_3_sing',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    log_html_str(fd,'"NONE"',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    fd.puts "if (glob_least_6_sing < glob_large_float)" + sl(GEN,THEN,0,0,0,0)
    log_html_float(fd,'glob_least_6_sing',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    log_html_str(fd,'"NONE"',false)
    fd.puts sl(GEN,SPECIFIC,MAXIMA,"0",0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

    log_html_integer(fd,'glob_iter',false )
    log_html_time(fd,"(glob_clock_sec)",false)
    fd.puts "if (c(glob_percent_done) < glob__100) " + sl(GEN,THEN,0,0,0,0)
    log_html_time(fd,"(glob_total_exp_sec)",false)
    fd.puts "0" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,ELSE,0,0,0,0)
    log_html_str(fd,'"Done"',false)
    fd.puts "0" + sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    log_revs(fd,$rev_html,false)
    log_html_diffeq_html(fd,  $odename   ,false)
    log_html_results_html(fd,  $odename   ,false)
    log_html_str(fd,'"' +  $comment + '"',false)
    fd.puts "logend(html_log_file)"
    if $eq_no < $no_eqs then
      fd.puts sl(GEN,LINESEP,0,0,0,0)
    else
      fd.puts sl(GEN,LINEEND,0,0,0,0)
    end
    $eq_no += 1
  end
  fd.puts sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
end
def log_html_str(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_str(html_log_file," + item + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_ode_html(fd,item,flag)
  if flag or $eq_no == 1 then
    html_str = '"<a href=\"' + item + '.ode.txt\">' + item + '</a>"'
    fd.puts "logitem_str(html_log_file," + html_str + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_diffeq_html(fd,item,flag)
  if flag or $eq_no == 1 then
    if GEN == MAPLE then
      html_str = '"<a href=\"diffeq.' + item + '.mxt.txt\">' + item + ' diffeq.mxt</a>"'
    elsif GEN == MAXIMA
      html_str = '"<a href=\"diffeq.' + item + '.max.txt\">' + item + ' diffeq.max</a>"'
    elsif GEN == RUBY
      html_str = '"<a href=\"diffeq.' + item + '.rb.txt\">' + item + ' diffeq.rb</a>"'
    elsif GEN == RUBY_APFP
      html_str = '"<a href=\"diffeq.' + item + '.rapfp.rb.txt\">' + item + ' diffeq.rapfp.rb</a>"'
    elsif GEN == CPP
      html_str = '"<a href=\"diffeq.' + item + '.cpp.txt\">' + item + ' diffeq.cpp</a>"'
    else
      html_str = '"<a href=\"diffeq.' + item + '.c.txt\">' + item + ' diffeq.c</a>"'
    end
    fd.puts "logitem_str(html_log_file," + html_str + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_results_html(fd,item,flag)
  if flag or $eq_no == 1 then
    if GEN == MAPLE then
      html_str = '"<a href=\"results.' + item +  '.mxt.txt\">' + item + ' maple results</a>"'
    elsif GEN == MAXIMA
      html_str = '"<a href=\"results.' + item + '.max.txt\">' + item + ' maxima results</a>"'
    elsif GEN == RUBY
      html_str = '"<a href=\"results.' + item + '.rb.txt\">' + item + ' Ruby results</a>"'
    elsif GEN == RUBY_APFP
      html_str = '"<a href=\"results.' + item + '.rapfp.rb.txt\">' + item + ' Ruby Apfp results</a>"'
    elsif GEN == CPP
      html_str = '"<a href=\"results.' + item + '.cpp.txt\">' + item + ' c++ results</a>"'
    else
      html_str = '"<a href=\"results.' + item + '.c.txt\">' + item + ' c results</a>"'
    end
    fd.puts "logitem_str(html_log_file," + html_str + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_integer(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_integer(html_log_file," + item + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_float(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_float(html_log_file," + item + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_est_digits(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_est_digits(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_good_digits(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_good_digits(html_log_file," + item + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end

def log_html_pole(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_pole(html_log_file," + item + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_h_reason(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_h_reason(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def log_html_time(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts "logitem_time(html_log_file," + item + ")"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end

def log_revs(fd,item,flag)
  if flag or $eq_no == 1 then
    fd.puts 'log_revs(html_log_file,"' + item + '")'
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  else
    fd.puts "logditto(html_log_file)"+ sl(GEN,LINEEND,0,0,0,0)
    fd.puts sl(GEN,LINESEP,0,0,0,0)
  end
end
def fix_max_order_occurs()
  eq_no = 1
  while eq_no <= $no_eqs do
    id = $eq_rec[eq_no].dep_var_diff
    if $eq_rec[eq_no].max_order_occurs.to_i < $max_order_occurs_tbl[id].to_i
      $eq_rec[eq_no].max_order_occurs = $max_order_occurs_tbl[id].to_i
    end
    eq_no += 1
  end
end
def set_diff_initial(fd)
  eq_no = 1
  while eq_no <= $no_eqs do
    term = 1
    while term <= $max_terms do
      compare = $eq_rec[eq_no].dep_var_diff + "_R_" + (term-1).to_s + "_R_"
      puts "hereiam" + compare + $set_initial[compare].to_s
      if $set_initial[compare] then
      fd.puts $eq_rec[eq_no].dep_var_diff + "_set_initial" + sl(GEN,SUBSC2,eq_no.to_s,term.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "true" + sl(GEN,LINESEP,0,0,0,0)
      else
      fd.puts $eq_rec[eq_no].dep_var_diff + "_set_initial" + sl(GEN,SUBSC2,eq_no.to_s,term.to_s,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "false" + sl(GEN,LINESEP,0,0,0,0)
      end
      term += 1
    end
    eq_no += 1
  end
end
def factorials_init(fd)
  fd.puts sl(GEN,REM,"Initing Factorial Tables",0,0,0)
  fd.puts "iiif" + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (iiif <= ATS_MAX_TERMS)" + sl(GEN,DO,0,0,0,0)
  fd.puts "jjjf" + sl(GEN,ASSIGN,0,0,0,0) + "0" + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "while (jjjf <= ATS_MAX_TERMS)" + sl(GEN,DO,0,0,0,0)
  fd.puts "array_fact_1" + sl(GEN,SUBSC1,"iiif",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "array_fact_2" + sl(GEN,SUBSC2,"iiif","jjjf",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "0"  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "jjjf" + sl(GEN,ASSIGN,0,0,0,0) + "jjjf + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts "iiif" + sl(GEN,ASSIGN,0,0,0,0) + "iiif + 1" + sl(GEN,LINEEND,0,0,0,0)
  fd.puts sl(GEN,OD,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
  fd.puts sl(GEN,REM,"Done Initing Factorial Table",0,0,0)
end

# MAIN GLOBALS
def write_ccc_or_cpp_top_matter(fd)
  fd.puts '#define true 1'
  fd.puts '#define false 0'
  fd.puts '#define ALWAYS 1'
  fd.puts '#define INFO 2'
  fd.puts '#define DEBUGL 3'
  fd.puts '#define DEBUGMASSIVE 4'
  fd.puts '#define glob_iolevel INFO'

  fd.puts "#define ATS_MAX_TERMS " + $max_terms.to_s
  fd.puts "#include <stdio.h>"
  fd.puts "#include <stdlib.h>"
  fd.puts "#include <math.h>"
  fd.puts "#include <sys/time.h>"
  fd.puts "#include <sys/resource.h>"
  fd.puts "#define c(x) ((double)x)"
  fd.puts "#define convfloat(x) ((double)x)"
  fd.puts "#define arcsin(x) asin(x)"
  fd.puts "#define arccos(x) acos(x)"
  fd.puts "#define arctan(x) atan(x)"
  fd.puts "#define float_abs(x) fabs(x)"
  fd.puts "#define int_abs(x) abs(x)"
  fd.puts "#define expt(x,y) pow(x,y)"
  fd.puts "#define ln(x) log(x)"
  fd.puts "#define Si(x) (0.0)"
  fd.puts "#define Ci(x) (0.0)"
  fd.puts "long elapsed_time_seconds();"
  fd.puts "int reached_interval();"
  fd.puts "int not_reached_end(" + st2(FLOAT) + "," + st2(FLOAT) + ");"
  fd.puts st2(FLOAT) + " ats(int," + st2(FLOAT_ARRAY) + "," + st2(FLOAT_ARRAY) + ",int);"
  fd.puts st2(FLOAT) + " att(int," + st2(FLOAT_ARRAY) + "," + st2(FLOAT_ARRAY) + ",int);"
  fd.puts st2(FLOAT) + " neg(" + st2(FLOAT) + ");"
  fd.puts st2(FLOAT) + " factorial_1(int);"
  fd.puts st2(FLOAT) + " factorial_2(int);"
  fd.puts st2(FLOAT) + " factorial_3(int,int);"
  fd.puts st2(FLOAT) + " comp_rad_from_ratio(" + st2(FLOAT) + "," + st2(FLOAT) + ",int);"
  fd.puts st2(FLOAT) + " comp_ord_from_ratio(" + st2(FLOAT) + "," + st2(FLOAT) + ",int);"
  fd.puts st2(FLOAT) + " comp_rad_from_three_terms(" + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + ",int);"
  fd.puts st2(FLOAT) + " comp_ord_from_three_terms(" + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + ",int);"
  fd.puts st2(FLOAT) + " comp_rad_from_six_terms(" + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + ","  + st2(FLOAT) + ","  + st2(FLOAT) + ",int);"
  fd.puts st2(FLOAT) + " comp_ord_from_six_terms(" + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + ","  + st2(FLOAT) + ","  + st2(FLOAT) + ",int);"


  fd.puts "int int_trunc(double);"
  fd.puts "void track_estimated_error();"
  fd.puts "void display_poles();"
  fd.puts "void display_pole_debug(int,int,double,double);"
  fd.puts st2(FLOAT) + " comp_expect_sec(" + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + ");"
  fd.puts st2(FLOAT) + " comp_percent("  + st2(FLOAT) + "," + st2(FLOAT) + "," + st2(FLOAT) + ");"
  fd.puts "void omniout_str(int iolevel,char *str);"
  fd.puts "void omniout_str_noeol(int iolevel,char *str);"
  fd.puts "void omniout_labstr(int iolevel,char *label,char *str);"
  fd.puts "void omniout_float(int iolevel,char *prelabel,int prelen," + st2(FLOAT) + " value,int vallen,char * postlabel);"
  fd.puts "void omniout_int(int iolevel,char *prelabel,int prelen,int value,int vallen,char * postlabel);"
  fd.puts "void dump_series(int iolevel,char *dump_label,char *series_name,"
  fd.puts st2(FLOAT) + " *array_series,int numb);"
  fd.puts "void cs_info(int iolevel,char *str);"
  fd.puts "void logitem_time(FILE *fd,double secs_in);"
  fd.puts "double frac(double);"
  fd.puts "void omniout_timestr(double secs_in); "
  fd.puts st2(FLOAT) + " array_const_m1[" + $max_terms.to_s + "];"

  fd.puts "double estimated_needed_step_error(" + $bounds2 + ",double glob_h,double est_answer);"
  fd.puts "double test_suggested_h();"
  fd.puts "double est_size_answer();"
  fd.puts "double my_check_sign(double x0,double xf);"
  fd.puts "double neg(double x);"

  eq_no = 1
  while eq_no <= $no_eqs do
    fd.puts st2(FLOAT) + " exact_soln_" + remove_array_str($eq_rec[eq_no].dep_var_diff) + "(" + st2(FLOAT) + ");"
    eq_no += 1
  end
end
def write_ruby_top_matter(fd)
  # Ruby Const
  fd.puts "ALWAYS = 1"
  fd.puts "INFO = 2"
  fd.puts "DEBUGL = 3"
  fd.puts "DEBUGMASSIVE = 4"
  fd.puts "MAX_UNCHANGED = 10"
  fd.puts "ATS_MAX_TERMS = " + $max_terms.to_s
end

def write_maple_top_matter()
  glob_decl($outfilemain) # for Maple
end
def write_maxima_top_matter(fd)
#  fd.puts "alias(c,convfloat)$"
  generate_mode_defs(fd) # for maxima
  generate_constants_definition(fd) # for maxima
  generate_globals_definition(fd) # for maxima
  generate_arrays_definition(fd)
  generate_const_definition(fd)
end
def write_ruby_main_top_matter(fd)
  fd.puts sl(GEN,FUNDEF,INTEGER,0,0,0) + "main" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,REM,"BEGIN OUTFILEMAIN",0,0,0)
end

def write_ccc_or_cpp_main_top_matter(fd)
  fd.puts sl(GEN,FUNDEF,INTEGER,0,0,0) + "main" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,REM,"BEGIN OUTFIEMAIN",0,0,0)
  fd.puts st2(FLOAT) + "  d1,d2,d3,d4,est_err_2,Digits;"
  fd.puts "int niii,done_once,it,opt_iter, max_terms;"
  fd.puts "int term,ord,order_diff,term_no,iiif,jjjf,subiter;"
  fd.puts "FILE *html_log_file;"
  fd.puts "int rows,r_order,sub_iter,calc_term,iii,current_iter,repeat_it,found_h;"
  fd.puts st2(FLOAT) + " temp_sum, est_needed_step_err,estimated_step_error,min_value,est_answer,last_min_pole_est,display_max;"
  fd.puts  $bounds3
  fd.puts st2(FLOAT) + " tmp;"

end
def write_maxima_main_top_matter(fd)
  fd.puts sl(GEN,FUNDEF,INTEGER,0,0,0) + "main_prog" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,REM,"BEGIN OUTFIEMAIN",0,0,0)
  fd.puts "block(modedeclare([[ d1,d2,d3,d4,est_err_2,display_max],float,[niii,done_once,"
  fd.puts "term,ord,order_diff,term_no,html_log_file,iiif,jjjf,"
  fd.puts "rows,r_order,sub_iter,calc_term,iii],fixnum,[temp_sum],float,[current_iter],fixnum,["
  fd.puts $bounds2
  fd.puts "],float,[it, opt_iter],fixnum, [tmp],float,[subiter],fixnum,[ est_needed_step_err,estimated_step_error,min_value,est_answer,last_min_pole_est],float,[repeat_it],fixnum],[found_h],boolean),"
end
def write_maple_main_top_matter(fd)
  fd.puts sl(GEN,FUNDEF,INTEGER,0,0,0) + "main" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0)
  fd.puts sl(GEN,REM,"BEGIN OUTFIEMAIN",0,0,0)
  fd.puts "local d1,d2,d3,d4,est_err_2,niii,done_once,max_terms,display_max,"
  fd.puts "term,ord,order_diff,term_no,html_log_file,iiif,jjjf,"
  fd.puts "rows,r_order,sub_iter,calc_term,iii,temp_sum,current_iter,"
  fd.puts $bounds2
  fd.puts ",it,last_min_pole_est, opt_iter, tmp,subiter, est_needed_step_err,estimated_step_error,min_value,est_answer,found_h,repeat_it;"
  glob_decl(fd)
  fd.puts "ATS_MAX_TERMS := " + $max_terms.to_s + ";"
end

def open_ode_file()
  if File.exists?($fname) then
    $stderr.puts "Opening " + $fname
    $infile = File.new($fname,"r")
  else
    $fname += ".ode"
    if File.exists?($fname) then
      $stderr.puts "Opening " + $fname
      $infile = File.new($fname,"r")
    else
      $stderr.puts "Cannot open input file " + $fname
      $stderr.puts "Cannot open input file "  + $fname
      exit(1)
    end
  end
end

def write_definitions(fd)
  symbols_defined(fd)
  arrays_defined(fd)
end
def write_main_body(fd)
  write_optimize_loop(fd) #NEWNEW
  write_html_init(fd)
  write_solve_loop(fd)
end


#####################################################
# MAIN PROGRAM GENERATION FOLLOWS
get_temp()
if DEBUG == 1
  $stderr.puts "Entering Main"
end
## FOR WINDOWS
##
$in_diff = 0
$token_no = 0
$line_no = 0
$first = 1
$linein = ""
$order_max = 0
$min_hdrs = 3
$tmp_no = 0
$const_no = 0
$glob_html_log = true
$set_initial  = Hash.new(false)
# have to load after hash created
$constants = Hash.new(0)
$globals = Hash.new(0)
$arrays1 = Hash.new(0)
$arrays2 = Hash.new(0)
$sym_tbl = Hash.new(-1)
$series_tbl = Hash.new(-1)
$const_tbl = Hash.new(-1)
$html_log = HTML_LOG


init_reserved
cpyfile = File.new("license.t","r")
while line = cpyfile.gets do
  line = line.chomp
  puts line
end
cpyfile.close
argcount = 0
ARGV.each {|arg|
           argcount += 1
         }
if argcount < 3 then
  $stderr.puts "Ode File Name Required"
  exit(1)
end
$fname = ARGV[0]
$odename = ARGV[1]
$subdir = ARGV[2]

if argcount < 4 then
  $comment = " "
else
  $comment = ARGV[3]
end
now = DateTime.now
$date_start = '"' + now.to_s + '"'

$fname = $fname.rstrip
if $fname == "" then
  $fname = "test.ode"
end

open_ode_file()

$outfilename = $fname + ".out.txt"
$no_eqs = count_eqs($infile)
$infile.close

open_ode_file()

# echo_problem($infile,File.join($TEMP_DIR,$fname))
echo_problem($infile,$fname)
$infile.close

open_ode_file()


if File.exists?(sl(GEN,ATSFILE,0,0,0,0)) then
  $libfile = File.new(sl(GEN,ATSFILE,0,0,0,0))
else
  puts 'Cannot File.new(' + sl(GEN,ATSFILE,0,0,0,0) + ")"
  $stderr.puts 'Cannot File.new(' + sl(GEN,ATSFILE,0,0,0,0) + ")"
  exit(1)
end
# jump method 1 means use order from LHS of diff for order of _higher to jump
# jump method 2 means use highest order from diff occurring anywhere for order of _higher to jump
$jump_method = 2 # 6/6/2012 not sure which is correct
$procs = 0
$procno = 1
$ifs = 0
$ifno = 1
$dos = 0
$dono = 1
$lineno_in = 0
$lineno_out = 0
$linein = ""
$tot_order = 0
$any_non_linear = false
$tokenval = NONE
$eq_dep_data = Hash.new(0)
$max_order = 0
$max_order_occurs_tbl = Hash.new(0)
if GEN == RUBY_APFP then
  require_relative '../rapfp/ApConfig'
#  require_relative '../rapfp/Ap'
#  rconst = $ApConst.new
#  rconst.one.setrconst(rconst)
#  rconst.init2
#  rconst.one.setrconst(rconst)
#  $RConst = rconst
#  cconst = ApcConst.new(rconst)
#  cconst.one.setcconst(cconst)
#  cconst.one.setrconst(rconst)
#  $CConst = cconst
end
$outfilemain = File.new(File.join($TEMP_DIR,"atomoutmain.mxi"),"w")
$outfile1 = File.new(File.join($TEMP_DIR,"atomout1.mxi"),"w")
$outfile1.puts sl(GEN,REM,"BEGIN OUTFILE1",0,0,0)
# $outfile1.puts sl(GEN,SPECIFIC,MAXIMA,'debugmode(true);',0,0)
$outfile1.puts sl(GEN,SPECIFIC,MAXIMA,'load("stringproc")$',0,0)
$sym_stack = Array.new
$op_stack = Array.new
load File.join($TEMP_DIR,'difffile.rb')

diffinit()
puts "BEFORE LEXBOX 2014"
lexbox()
puts "AFTER LEXBOX 2014"
$outfile2 = File.new(File.join($TEMP_DIR,"atomout2.mxi"),"w")
$outfile2.puts sl(GEN,REM,"BEGIN OUTFILE2",0,0,0)
$outfile4 = File.new(File.join($TEMP_DIR,"atomout4.mxi"),"w")
$outfile4.puts sl(GEN,REM,"BEGIN OUTFILE4",0,0,0)
$outfile5 = File.new(File.join($TEMP_DIR,"atomout5.mxi"),"w")
$outfile5.puts sl(GEN,REM,"BEGIN OUTFILE5",0,0,0)
init_hdrs
$eq_no = 1
while $eq_no <= $no_eqs do
  $stderr.puts "Before Parse $eq_no = #{$eq_no}"
  $eq_rec[$eq_no].tmp_base = $tmp_no + 1
  parse()
  $lookahead = lexan_2
  $eq_rec[$eq_no].tmp_series = $tmp_no-1
  $stderr.puts "After Parse $eq_no = #{$eq_no}"
  $eq_no += 1
end
$infile.close


$stderr.puts "POINT 1"
fix_max_order_occurs()
$stderr.puts "POINT 2"
$stderr.puts "POINT 3"
############################################################### mainprog
$eq_no = 1
gather_data_for_decl()

if GEN == MAPLE then
  $outfile1.puts "# before write maple top matter"
  $outfile1.puts "# before write_ats library and user def block"
  write_ats_library_and_user_def_block($outfile1)
  $outfile1.puts "# before write_aux functions"
  write_aux_functions($outfile1)
  $outfile1.puts "# before write maple main top matter"
  write_maple_main_top_matter($outfilemain)
  $outfilemain.puts "# before first input block"
  first_input_block($outfilemain)
  $outfilemain.puts "# before generate arrays"
  generate_arrays_definition($outfilemain)
  $outfilemain.puts "# before generate constants"
  generate_constants_definition($outfilemain)
  $outfilemain.puts "# before generate globals definition"
  generate_globals_definition($outfilemain)
  $outfilemain.puts "# before generate const definition"
  generate_const_definition($outfilemain)
  $outfilemain.puts "# before arrays initialized"
  arrays_initialized($outfilemain)
  $outfilemain.puts "# before symbols initialized"
  symbols_initialized($outfilemain)
  $outfilemain.puts "# before generate factorials init"
  factorials_init($outfilemain)
  $outfile1.puts "# before generate constants assign"
  generate_constants_assign($outfilemain)
  $outfile1.puts "# before generate globals assign"
  generate_globals_assign($outfilemain)
  $outfilemain.puts "# before generate set diff initial"
  set_diff_initial($outfilemain)
  $outfilemain.puts "# before generate init omniout const"
  init_omniout_const($outfilemain)
  $outfilemain.puts "# set default block"
  write_set_defaults($outfilemain) # initializations
  $outfilemain.puts "# before second block"
  second_input_block($outfilemain)
  $outfilemain.puts "#  after second input block"
elsif (GEN == RUBY) || (GEN == RUBY_APFP) then
  $outfile1.puts "# before write_ruby top matter"
  write_ruby_top_matter($outfile1)
  $outfile1.puts "# before generate init omniout const"
  init_omniout_const($outfile1)
  $outfile1.puts "# before write_ats library and user def block"
  write_ats_library_and_user_def_block($outfile1)
  $outfile1.puts "# before write_aux functions"
  write_aux_functions($outfile1)
  $outfilemain.puts "# before write_ruby_main_top"
  write_ruby_main_top_matter($outfilemain)
  if GEN == RUBY_APFP then
    $outfilemain.puts 'require_relative "../rapfp/ApConfig"'
    $outfilemain.puts 'require_relative "../rapfp/Ap"'
    $outfilemain.puts 'rconst = $ApConst.new'
    $outfilemain.puts 'rconst.one.setrconst(rconst)'
    $outfilemain.puts 'rconst.init2'
    $outfilemain.puts 'rconst.one.setrconst(rconst)'
    $outfilemain.puts '$RConst = rconst'
    $outfilemain.puts 'cconst = ApcConst.new(rconst)'
    $outfilemain.puts 'cconst.one.setcconst(cconst)'
    $outfilemain.puts 'cconst.one.setrconst(rconst)'
    $outfilemain.puts '$CConst = cconst'
  end
  $outfilemain.puts "# before first input block"
  first_input_block($outfilemain)
  $outfilemain.puts "# before generate arrays"
  generate_arrays_definition($outfilemain)
  $outfilemain.puts "# before generate constants"
  generate_constants_definition($outfilemain)
  $outfilemain.puts "# before generate globals definition"
  generate_globals_definition($outfilemain)
  $outfilemain.puts "# before generate const definition"
  generate_const_definition($outfilemain)
  $outfilemain.puts "# before arrays initialized"
  arrays_initialized($outfilemain)
  $outfilemain.puts "# before symbols initialized"
  symbols_initialized($outfilemain)
  $outfilemain.puts "# before generate factorials init"
  factorials_init($outfilemain)
  $outfilemain.puts "# before generate constants assign"
  generate_constants_assign($outfilemain)   # assign constants
  $outfilemain.puts "# before generate globals assign"
  generate_globals_assign($outfilemain)     # assign globals
  $outfilemain.puts "# before generate set diff initial"
  set_diff_initial($outfilemain)
  $outfilemain.puts "# set default block"
  write_set_defaults($outfilemain) # initializations
  $outfilemain.puts "# before second block"
  second_input_block($outfilemain)
  $outfilemain.puts "#  after second input block"
elsif GEN == CCC or GEN == CPP then
  $outfile1.puts "// before write ccc cpp top matter"
  write_ccc_or_cpp_top_matter($outfile1)
  $outfilemain.puts "//  before generate arrays"
  generate_arrays_definition($outfile1)
  $outfile1.puts "//  before generate constants"
  generate_constants_definition($outfile1)
  $outfile1.puts "//  before generate globals definition"
  generate_globals_definition($outfile1)
  $outfile1.puts "//  before generate const definition"
  generate_const_definition($outfile1)
  $outfile1.puts "// before write_aux functions"
  write_aux_functions($outfile1)
  $outfile1.puts "// before write ccc cpp library user def"
  write_ats_library_and_user_def_block($outfilemain)
  write_ccc_or_cpp_main_top_matter($outfilemain)
  $outfilemain.puts "//  before first input block"
  first_input_block($outfilemain)
  $outfilemain.puts "//  before arrays initialized"
  arrays_initialized($outfilemain)
  $outfilemain.puts "//  before symbols initialized"
  symbols_initialized($outfilemain)
  $outfilemain.puts "//  before generate factorials init"
  factorials_init($outfilemain)
  $outfilemain.puts "//  before generate constants assign"
  generate_constants_assign($outfilemain) # assign constants
  $outfilemain.puts "//  before generate globals assign"
  generate_globals_assign($outfilemain)   # assign globasls
  $outfilemain.puts "//  before generate set diff initial"
  set_diff_initial($outfilemain)
  $outfilemain.puts "//  before generate init omniout const"
  init_omniout_const($outfilemain)
  $outfilemain.puts "/* set default block */"
  write_set_defaults($outfilemain) # initializations
  $outfilemain.puts "/* before second block */"
  second_input_block($outfilemain)
  $outfilemain.puts "//  after second input block"
elsif GEN == MAXIMA then
  $outfile1.puts "/* before maxima top matter */"
  write_maxima_top_matter($outfile1)
  $outfile1.puts "/* before library and user */"
  write_ats_library_and_user_def_block($outfile1)
  $outfile1.puts "/* before write_aux functions */"
  write_aux_functions($outfile1)
  $outfilemain.puts "/* before write ccc cpp library user def */"
  write_ats_library_and_user_def_block($outfilemain)
  write_maxima_main_top_matter($outfilemain)
  $outfilemain.puts "/* before first input block */"
  first_input_block($outfilemain)
  $outfilemain.puts "/* before generate arrays */"
  $outfilemain.puts "/*before arrays initialized */"
  arrays_initialized($outfilemain)
  $outfilemain.puts "/*before symbols initialized */"
  symbols_initialized($outfilemain)
  $outfilemain.puts "/*before generate factorials init */"
  factorials_init($outfilemain)
  $outfilemain.puts "/*before generate set diff initial */"
  set_diff_initial($outfilemain)
  $outfilemain.puts "/*before generate init omniout const */"
  init_omniout_const($outfilemain)
  $outfilemain.puts "/* set default block */"
  write_set_defaults($outfilemain) # initializations
  $outfilemain.puts "/* before second block */"
  second_input_block($outfilemain)
end
# MAIN BODY
write_main_body($outfilemain)
$outfilemain.puts sl(GEN,REM,"END OUTFILEMAIN",0,0,0)
$outfilemain.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$outfilemain.puts sl(GEN,FUNEND,0,0,0,0)
if GEN == MAXIMA
  $outfilemain.puts sl(GEN,FUNDEF,INTEGER,0,0,0) + "main" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0)
#  $outfilemain.puts "ALWAYS" + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
#  $outfilemain.puts "INFO" + sl(GEN,ASSIGN,0,0,0,0) + "2" + sl(GEN,LINESEP,0,0,0,0)
#  $outfilemain.puts "DEBUGL" + sl(GEN,ASSIGN,0,0,0,0) + "3" + sl(GEN,LINESEP,0,0,0,0)
#  $outfilemain.puts "DEBUGMASSIVE" + sl(GEN,ASSIGN,0,0,0,0) + "4" + sl(GEN,LINESEP,0,0,0,0)
#  $outfilemain.puts "ATS_MAX_TERMS" + sl(GEN,ASSIGN,0,0,0,0) + $max_terms.to_s + sl(GEN,LINESEP,0,0,0,0)
  $outfilemain.puts "glob_iolevel" + sl(GEN,ASSIGN,0,0,0,0) + "2" + sl(GEN,LINESEP,0,0,0,0)  # INFO


#  $outfilemain.puts "alias(convfloat,float),"

  $outfilemain.puts "compile(all),"
  $outfilemain.puts "main_prog()"
  $outfilemain.puts sl(GEN,FUNEND,0,0,0,0)
  $outfilemain.puts "main()$"
elsif GEN == CCC or GEN == CPP
elsif GEN == MAPLE
  $outfilemain.puts "main();"
else # Ruby
  $outfilemain.puts "main()"
end
$outfilemain.close
$outfile1.puts sl(GEN,REM,"END OUTFILE1",0,0,0)
$outfile1.close
$outfile2.puts sl(GEN,REM,"END OUTFILE2",0,0,0)
$outfile2.close
$outfile3 = File.new(File.join($TEMP_DIR,"atomout3.mxi"),"w")
$outfile3.puts sl(GEN,REM,"BEGIN OUTFILE3",0,0,0)
write_end_atomall() # outfile3
$outfile3.puts sl(GEN,REM,"END OUTFILE3",0,0,0)
$outfile3.close
$outfile4.puts "kkk  " + sl(GEN,ASSIGN,0,0,0,0) + " kkk + 1"  + sl(GEN,LINEEND,0,0,0,0)
$outfile4.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
$outfile4.puts sl(GEN,REM,"BOTTOM ATOMALL",0,0,0)
$outfile4.puts sl(GEN,REM,"END OUTFILE4",0,0,0)
$outfile4.close
write_bottom_atomall($outfile5)
$outfile5.puts sl(GEN,REM,"END OUTFILE5",0,0,0)
$outfile5.close
close_hdrs
$libfile.close
cat_files
count_lines_out
$stderr.puts "OmniSode.rb Normal Completion."
$stderr.puts "OmniSode.rb Processed #{$no_eqs} Equations."
$stderr.puts "OmniSode.rb Processed #{$lineno_in} lines in."
$stderr.puts "OmniSode.rb Processed #{$lineno_out} lines out."
$stderr.puts "OmniSode.rb Processed #{$token_no} tokens."
puts "OmniSode.rb Normal Completion."
puts "OmniSode.rb Processed #{$no_eqs} Equations."
puts "OmniSode.rb Processed #{$lineno_in} lines in."
puts "OmniSode.rb Processed #{$lineno_out} lines out."
puts "OmniSode.rb Processed #{$token_no} tokens."
exit(0)
