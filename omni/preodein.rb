####################################################################
#
#	File:     preodein.rb
#
#	Subject:  Part of a Ruby program to generate a program ("diffeq.---")
#                  to solve a system of ordinary differential equations
#                  with long Taylor series. This program translates
#                  a ".ode" file from a standard format (that which is
#                  used for Maple) to a file to be used for a target
#                  language. It also inserts lines from an override.
#                  file if it exists.
#
#	Author:   Dennis J. Darland
#
#       Copyright (C) 2012 Dennis J. Darland
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



def trap_assign(linein,strin,strout)
  linein = linein.gsub(/ /,"")
  
  strin_re = Regexp.new(strin + ":=")
#  $stderr.puts show_regexp(linein,strin_re)
  if md = strin_re.match(linein) then
    rest = md.post_match 
    $difffile.puts strout + " = "  + rest[0..-2]
  end
end


def tran_assign(linein)
  trap_assign(linein,"max_terms","$max_terms")
  trap_assign(linein,"Digits","$digits")
  linein = linein.gsub(/ /,"")
  check_2d_re = Regexp.new(/\[/)
  check_2dB_re = Regexp.new(/\]/)
  if GEN != MAPLE and GEN != MAXIMA then
    if md = check_2d_re.match(linein) then
      lineout3 = linein.gsub(/\,/,"][")
      linein = lineout3
    end
  end
  if GEN == MAXIMA then
    lineout = linein.gsub(/:=/,":")
    lineout = lineout.gsub(/;/,",")
  elsif GEN == CPP or GEN == CCC then
    lineout = linein.gsub(/:=/,"=")
  elsif GEN == RUBY or GEN == RUBY_APFP then
    if (not linein[0].nil?) and (linein[0].chr < "A" or linein[0].chr > "Z") then # no constants
      lineout2 = linein.gsub(/:=/,"=")
      lineout = lineout2.gsub(/;/," ")
    else
      lineout = "# " + linein + " ELIMINATED in preodein.rb" 
    end
  else
    lineout = linein
  end
  return lineout
end
def show_regexp(str,re)
  # $stderr.puts "show_regexp re = " + re.inspect
  # $stderr.puts "str = " + str
  if str =~ re
    "#{$`}<<#{$&}>>#{$'}"
  else
    "no match"
  end
end

def tran_diff(linein)
  dep_var_re = Regexp.new(/^[a-zA-Z]+[a-zA-Z0-9]*/)
  # $stderr.puts show_regexp(linein,dep_var_re)
  if md = dep_var_re.match(linein) then
    y = md[0] 
    rest = md.post_match
    # $stderr.puts "y = " + y
    # $stderr.puts "rest = " + rest
    comma_re = Regexp.new(/^,/)
    # $stderr.puts show_regexp(rest,comma_re)
    
    if md = comma_re.match(rest) then
      rest = md.post_match
      ord_re = Regexp.new(/^[0-9]+/)
      # $stderr.puts show_regexp(rest,ord_re)
      if md = ord_re.match(rest) then
        ord = md[0]
        rest = md.post_match
        # $stderr.puts show_regexp(rest,comma_re)
        if md = comma_re.match(rest) then
          rest = md.post_match
          left = rest.size
          val = rest.slice(0..(left-2))
          return diff(y,ord,val)
        end
        $stderr.puts "Error 1 in Parsing diff in preodein.rb"
        exit(1)
      end
      $stderr.puts "Error 2 in Parsing diff in preodein.rb"
      exit(1)
    end
    # $stderr.puts comma_hdr.inspect
    # $stderr.puts "Error 3 in Parsing diff in preodein.rb"
    exit(1)
  end
#  $stderr.puts dep_var_re.inspect
  $stderr.puts "Error 4 in Parsing diff in preodein.rb"
  exit(1)
end
# example diff("y1","0","exact_soln_y1(x_start)");
def diff(dep_var,order,value)
  # this function is used to set initial conditions and mark variable as
  # not to be changed in atomall
  # dep_var is dependent variable (as string)
  # order is order of derivative initial condition is for - starts as zero here
  # also a string.
  # value is also string
  $difffile.puts '$set_initial["array_' + dep_var + '_R_' + order + '_R_"] = true'
  return "array_" + dep_var + "_init[" + order + " + 1]" + sl(GEN,ASSIGN,0,0,0,0) + value[0..-2] + sl(GEN,LINESEP,0,0,0,0)
end
def get_it(file)
  $lineno_in += 1
  if linein  = file.gets then 
    linein  = linein.chomp 
    linein = linein.rstrip 
    linein = linein.lstrip
 #   puts "linein=|" + linein + "|"
    trail_comm_re = Regexp.new('#')
    if md = trail_comm_re.match(linein) then 
      linein = md.pre_match.lstrip.rstrip
    end
    if not linein[0].nil? then
      while $in_eqs and ((linein[0].nil?) or (linein[0].chr == '#')) do 
          $lineno_out += 1
          if linein  = file.gets then
            linein  = linein.chomp 
            linein = linein.rstrip 
            linein = linein.lstrip
            if md = trail_comm_re.match(linein) then 
              linein = md.pre_match.lstrip.rstrip
            end
          end
      end
      if not $in_eqs then
        while (linein[0].chr == "#")  do # comment
          lineout = sl(GEN,REM,linein,0,0,0)
          put_it($outfile,lineout)
          $lineno_out += 1
          if linein  = file.gets then
            linein  = linein.chomp 
            linein = linein.rstrip 
            linein = linein.lstrip
            if linein != ""
          #    puts "linein=|" + linein + "|"
            else
              linein = " "
            end
          else
            linein = "!"
        #    puts "EOF"
          end
        end
      end
    end
    return(linein)
  else
    linein = "!"
    return(linein)
  #  puts "EOF"
  end
end
def put_it(file,str)
  $lineno_out += 1
  file.puts str
#  puts "lineout=|" + str + "|"
#  sleep 5
end
def finish_local(lang,str,infile)
  put_it($outfile,"/* Not Yet READY (locals in functions in Maxima ode defs */")
  str2 = linein.gsub(/;/,"],")

  put_it($outfile,"([" + str2)
end
def merge_eq_lines()
  loclinein = get_it($infile)
  $linein = loclinein
  puts loclinein
  sz = $linein.size
#  puts "merge size = " + sz.to_s
#  puts "merge $linein = " + $linein
  while $linein[sz-1].chr != ";" and loclinein != "!"
    loclinein = get_it($infile)
    if not loclinein[0].nil? then
      sz = loclinein.size
      # $stderr.puts "merge loc size = " + sz.to_s
      # $stderr.puts "merge loclinein = " + loclinein
      $linein += " " + loclinein
      sz = $linein.size
      # $stderr.puts "merge size = " + sz.to_s
      # $stderr.puts "merge $linein = " + $linein
    end
  end
  return $linein
end
def tran_proc(linein)
  if GEN == MAXIMA then
    prochdr = Regexp.new(/proc/)
    procend = Regexp.new(/end;/)
    prochdr2 = Regexp.new(/:=/)
    assign = Regexp.new(/:=/)
    local = Regexp.new(/local /)
    if md = local.match(linein) then
      vars = md.post_match
      vars2 = vars.gsub(/;/,"],")
      lineout = "[ " + vars2
    elsif md = prochdr.match(linein) then
      item = md[0]
      func = md.pre_match
      args = md.post_match
      if md = prochdr2.match(func)
        func2 = md.pre_match
        lineout = func2 + "(" + args[1..-1] + " := (block(" 
      else 
        puts "Error in Function"
      end
    elsif md = procend.match(linein) then
      lineout = "));"
    elsif md = assign.match(linein) then
      lhs = md.pre_match
      rhs = md.post_match
      rhs2 = rhs.gsub(/;/,",")
      lineout = lhs + ":" + rhs2
    else
      lineout2 = linein.gsub(/;/," ")
      lineout = lineout2.gsub(/return/," ")
    end
  elsif GEN == RUBY or GEN == RUBY_APFP then
    prochdr = Regexp.new(/proc/)
#    par1 = Regexp.new(/\(/)
    par2 = Regexp.new(/\)/)
#    parm = Regexp.new([a-z][A-Z][0-9])
    procend = Regexp.new(/end;/)
    prochdr2 = Regexp.new(/:=/)
    assign = Regexp.new(/:=/)
    local = Regexp.new(/local /)
    if md = local.match(linein) then
      lineout = " "
    elsif md = prochdr.match(linein) then
      item = md[0]
      func = md.pre_match
      args = md.post_match
      if md = prochdr2.match(func)
        func2 = md.pre_match
        
        lineout = "def " + func2 + "(" + args[1..-1] 
        put_it($outfile,lineout)
        var =  args[1..-1] 
        if md = par2.match(var) then
          var2 = md.pre_match
          lineout = var2 + ' = c(' + var2 + ')'
        else 
          puts "Error in Function"
        end
      else 
        puts "Error in Function"
      end
    elsif md = procend.match(linein) then
      lineout = "end"
    elsif md = assign.match(linein) then
      lhs = md.pre_match
      rhs = md.post_match
      lineout = lhs + "=" + rhs
      #    elsif md = local.match(linein) then
      #      lineout = "double " + md.post_match
    else
      lineout = linein.gsub(/;/," ")
    end
  elsif GEN == CPP or GEN == CCC then
    prochdr = Regexp.new(/proc/)
    procend = Regexp.new(/end;/)
    prochdr2 = Regexp.new(/:=/)
    assign = Regexp.new(/:=/)
    local = Regexp.new(/local /)
    if md = prochdr.match(linein) then
      item = md[0]
      func = md.pre_match
      args = md.post_match
      if md = prochdr2.match(func)
        func2 = md.pre_match
        lineout = "double " + func2 + "(double " + args[1..-1] + " { " 
      else puts "Error in Function"
      end
    elsif md = procend.match(linein) then
      lineout = "}"
    elsif md = assign.match(linein) then
      lhs = md.pre_match
      rhs = md.post_match
      lineout = lhs + "=" + rhs
    elsif md = local.match(linein) then
      lineout = "double " + md.post_match
    else
      lineout = linein
    end
  else
    lineout = linein
  end
  return lineout
end
get_temp()
$lineno_in = 0
$lineno_out = 0
$in_eqs = true
$fnamein = ARGV[0]
$pwd = ARGV[1]
# changed to join in doing change to RAM disk
$fnameout = File.join($TEMP_DIR, $fnamein + "postode.ode")
$diffout = File.join($TEMP_DIR, "difffile.rb")
$fnamein += ".ode"

if File.exists?($fnamein) then 
  puts "Opening " + $fnamein
  $infile = File.new($fnamein,"r")
  $outfile = File.new($fnameout,"w")
  $difffile = File.new($diffout,"w")
  $difffile.puts 'def diffinit()'
else
  puts "Cannot open input file " + $fnamein
  $stderr.puts "Cannot open input file " + $fnamein
  exit(false)
end

$overode = "ode.over"
if File.exists?($overode) then 
  puts "Opening " + $overode
  $overfile = File.new($overode,"r")
  $over = true
else
#  puts "No override file"
  $over = false
end

#  $outfile.puts sl(GEN,REM,"BEGIN ODES DEFINITION BLOCK",0,0,0)

#$linein  = get_it($infile)
$linein = merge_eq_lines()
while $linein != "!" do
#  puts "process ode $linein = " + $linein
  $linein = $linein.gsub('(',' (1 ')
  $linein = $linein.gsub(')',' )1 ')
  $linein = $linein.gsub(',',' ,1 ')
  $linein = $linein.gsub(';',' ;1 ')
  $linein = $linein.gsub('=',' =1 ')
  $linein = $linein.gsub('*',' *1 ')
  $linein = $linein.gsub('/',' /1 ')
  $linein = $linein.gsub('+',' +1 ')
  $linein = $linein.gsub('-',' -1 ')
  $linein = $linein.gsub(' (1 ',' ( ')
  $linein = $linein.gsub(' )1 ',' ) ')
  $linein = $linein.gsub(' ,1 ',' , ')
  $linein = $linein.gsub(' ;1 ',' ; ')
  $linein = $linein.gsub(' =1 ',' = ')
  $linein = $linein.gsub(' *1 ',' * ')
  $linein = $linein.gsub(' /1 ',' / ')
  $linein = $linein.gsub(' +1 ',' + ')
  $linein = $linein.gsub(' -1 ',' - ')

  put_it($outfile,$linein)
#  $linein = get_it($infile)
  $linein = merge_eq_lines()
  $in_eqs = false
end
put_it($outfile,$linein)

#  $outfile.puts sl(GEN,REM,"END ODES DEFINITION BLOCK",0,0,0)
put_it($outfile,sl(GEN,REM,"BEGIN FIRST INPUT BLOCK",0,0,0))
$linein  = get_it($infile)
while $linein  != "!" do 
  $lineout = tran_assign($linein)
  put_it($outfile,$lineout)
  $linein  = get_it($infile)
end
put_it($outfile,$linein)
put_it($outfile,sl(GEN,REM,"END FIRST INPUT BLOCK",0,0,0))
put_it($outfile,sl(GEN,REM,"BEGIN SECOND INPUT BLOCK",0,0,0))
$linein  = get_it($infile)
diff_hdr =  Regexp.new(/^diff\([\ ]*/)
while not $linein.nil? and $linein    != "!" do 
  if md = diff_hdr.match($linein) then
    $lineout = tran_diff(md.post_match) # also writes diff info for ruby omnisode 
  elsif GEN != MAPLE then
    $lineout = tran_assign($linein)
  else #Maple
    $lineout = $linein
  end
  put_it($outfile,$lineout)
  $linein = get_it($infile)
end
put_it($outfile,sl(GEN,REM,"END SECOND INPUT BLOCK",0,0,0))
put_it($outfile,sl(GEN,REM,"BEGIN OVERRIDE  BLOCK",0,0,0))
if $over then
  $linein = get_it($overfile)
  while $linein != "!" do
    $lineout = tran_assign($linein)
    put_it($outfile,$lineout)
    $linein = get_it($overfile)
  end
end
put_it($outfile,sl(GEN,REM,"END OVERRIDE BLOCK",0,0,0))
put_it($outfile,"!")
put_it($outfile,sl(GEN,REM,"BEGIN USER DEF BLOCK",0,0,0))
$thru_local = false
$linein  = get_it($infile)
while $linein != "!" do
  $lineout = tran_proc($linein)
  put_it($outfile,$lineout)
  $linein  = get_it($infile)
end
put_it($outfile,sl(GEN,REM,"END USER DEF BLOCK",0,0,0))
puts $lineno_in.to_s + " lines in"
puts $lineno_out.to_s + " lines out"
$infile.close
$difffile.puts "end"
$difffile.close
$outfile.close
if $over then
  $overfile.close
end
exit(0)

  
