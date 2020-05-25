######################################################################
#
#	File:     atsgen.rb
#
#	Subject:  Part of a Ruby program to generate a program ("diffeq.---")
#                  to solve a system of ordinary differential equations
#                  with long Taylor series. Intended to Support
#                  programs with Ruby (native math) Ruby (APFP),
#                  Maple 12, maxima, C, C++.
#
#	Author:   Dennis J. Darland
#
#       Copyright (C) 2008-2012 Dennis J. Darland
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
#
#
#    This program is free software you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software <Foundation either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###########################################################################
#
# The order and step size control comes from Angel Jorba and Maorong Zou's
# Taylor project version 1.3.8
#
##########################################################################

load 'atsinc.rb'
$procs = 0
$procno = 1
$ifs = 0
$ifno = 1
$dos = 0
$dono = 1

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

def openfile()
  $atsfile = File.new(sl(GEN,ATSFILE,0,0,0,0),"w")
end

def generic_io(lang)
  case lang
  when RUBY
#######################################################################
    # Put string
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts str'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put string without eol
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str_noeol" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel)"  + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf("%s", str)'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put Labeled string
   $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_labstr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,label,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts label + str'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts prelabel.ljust(30) + value.to_s + postlabel'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put integer
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_int" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts prelabel.ljust(32) + value.to_s + postlabel'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point array element
#DJDSTOP
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float_arr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,elemnt,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)    
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts (prelabel.ljust(12) + "  " + elemnt.to_s + "  "  + value.to_s + " " + postlabel)'  
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#DJDSTART
    # dump some of a 1d series
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name,arr_series,numb)" + sl(GEN,FUNSEP2,0,0,0,0) 
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "  i = 1"
    $atsfile.puts "  while (i <= numb) do "
    $atsfile.puts 'puts dump_label + series_name  + "[" + i.to_s + "]" + arr_series[i].to_s'
    $atsfile.puts "    i += 1"
    $atsfile.puts 'end'
    $atsfile.puts 'end'
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # dump some of a 2d series
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series_2" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name2,arr_series2,numb,subnum,arr_x)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "  sub = 1;"
    $atsfile.puts "  while (sub <= subnum) do "
    $atsfile.puts "    i =  1;"
    $atsfile.puts "  while (i <= numb) do "
    $atsfile.puts 'puts dump_label + series_name2 + "[" + sub.to_s + "," + i.to_s + "]" + arr_series2[sub,i].to_s'
    if DEBUG_TESTTERMS then
      $atsfile.puts 'ts_term := exact_terms_y(arr_x[1],i);'
      $atsfile.puts 'print("ts_term",numb,arr_x[1],ts_term);'
      $atsfile.puts "      i := i + 1;"
    end
    $atsfile.puts sl(GEN,OD,0,0,0,0)
    $atsfile.puts "sub += 1;"
    $atsfile.puts sl(GEN,OD,0,0,0,0)
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    #################################################################
    # misc info dump
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cs_info" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts "cs_info " + str  + " glob_correct_start_flag = " , glob_correct_start_flag.to_s + "glob_h := " + glob_h + "glob_reached_optimal_h := "  +  glob_reached_optimal_h'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    ########################## RUBY LOGTIME ############################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_time" + sl(GEN,FUNSEP1,0,0,0,0) + "(fd,secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts 'fd.printf("<td>")'
    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs_in / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (secs_in % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)

    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(years_int.to_s + " Years " + days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'fd.printf(sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'fd.printf(" 0.0 Seconds")' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts 'fd.printf("</td>")' 

    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ############################### RUBY TIMESTR #######################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_timestr" + sl(GEN,FUNSEP1,0,0,0,0) + "(secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs_in / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (secs_in % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts years_int.to_s + " Years " + days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'puts sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'puts " 0.0 Seconds"' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ########################################################
#########################################################################
  when RUBY_APFP
#######################################################################
    # Put string
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts str'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put string without eol
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str_noeol" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel)"  + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf("%s", str)'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put Labeled string
   $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_labstr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,label,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts label + str'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts prelabel.ljust(30) + value.to_s + postlabel'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put integer
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_int" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts prelabel.ljust(32) + value.to_s + postlabel'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point array element
#DJDSTOP
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float_arr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,elemnt,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)    
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts (prelabel.ljust(12) + "  " + elemnt.to_s + "  "  + value.to_s + " " + postlabel)'  
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#DJDSTART
    # dump some of a 1d series
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name,arr_series,numb)" + sl(GEN,FUNSEP2,0,0,0,0) 
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "  i = 1"
    $atsfile.puts "  while (i <= numb) do "
    $atsfile.puts 'puts dump_label + series_name  + "[" + i.to_s + "]" + arr_series[i].to_s'
    $atsfile.puts "    i += 1"
    $atsfile.puts 'end'
    $atsfile.puts 'end'
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # dump some of a 2d series
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series_2" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name2,arr_series2,numb,subnum,arr_x)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "  sub = 1;"
    $atsfile.puts "  while (sub <= subnum) do "
    $atsfile.puts "    i =  1;"
    $atsfile.puts "  while (i <= numb) do "
    $atsfile.puts 'puts dump_label + series_name2 + "[" + sub.to_s + "," + i.to_s + "]" + arr_series2[sub,i].to_s'
    if DEBUG_TESTTERMS then
      $atsfile.puts 'ts_term := exact_terms_y(arr_x[1],i);'
      $atsfile.puts 'print("ts_term",numb,arr_x[1],ts_term);'
      $atsfile.puts "      i := i + 1;"
    end
    $atsfile.puts sl(GEN,OD,0,0,0,0)
    $atsfile.puts "sub += 1;"
    $atsfile.puts sl(GEN,OD,0,0,0,0)
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    #################################################################
    # misc info dump
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cs_info" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts "cs_info " + str  + " glob_correct_start_flag = " , glob_correct_start_flag.to_s + "glob_h := " + glob_h + "glob_reached_optimal_h := "  +  glob_reached_optimal_h'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    ########################## RUBY LOGTIME ############################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_time" + sl(GEN,FUNSEP1,0,0,0,0) + "(fd,secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts 'fd.printf("<td>")'
    $atsfile.puts "secs_in " + sl(GEN,ASSIGN,0,0,0,0) + "secs_in.to_i" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs_in / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (secs_in % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)

    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(years_int.to_s + " Years " + days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fd.printf(minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'fd.printf(sec_int.to_s + " Seconds")' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'fd.printf(" 0.0 Seconds")' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts 'fd.printf("</td>")' 

    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ############################### RUBY_APFP TIMESTR #######################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_timestr" + sl(GEN,FUNSEP1,0,0,0,0) + "(secs_in)" + sl(GEN,FUNSEP2,0,0,0,0) 
    $atsfile.puts "secs_in " + sl(GEN,ASSIGN,0,0,0,0) + "secs_in.to_i" + sl(GEN,LINESEP,0,0,0,0)
   $atsfile.puts "  if (secs_in >= 0)" + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs_in / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (secs_in % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts years_int.to_s + " Years " + days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'puts minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'puts sec_int.to_s + " Seconds"' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'puts " 0.0 Seconds"' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ########################################################
#########################################################################
  when MAPLE
    # Put string
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "global glob_iolevel;"
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf("%s\n",str);'
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put string without eol
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str_noeol" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "global glob_iolevel;"
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf("%s",str);'
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put Labeled string
   $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_labstr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,label,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "global glob_iolevel;"
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'print(label,str);'
    #    $atsfile.puts 'printf("%s = %s\n",label,str);'
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "global glob_iolevel;"
    #    $atsfile.puts 'print(prelabel,value, postlabel);'  
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    #    $atsfile.puts 'print(prelabel," = ",value, postlabel, prelen, vallen);'
    $atsfile.puts 'if vallen = 4 then'
    $atsfile.puts 'printf("%-30s = %-42.4g %s \n",prelabel,value, postlabel);'
    $atsfile.puts 'else'
    $atsfile.puts 'printf("%-30s = %-42.32g %s \n",prelabel,value, postlabel);'
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put integer
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_int" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "global glob_iolevel;"
    #    $atsfile.puts 'print(prelabel,value, postlabel);'  
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    #    $atsfile.puts 'print("prelabel=",prelabel,"prelen=",prelen,"value=",value,"vallen=",vallen,"postlabel=",postlabel);'
    $atsfile.puts 'if vallen = 5 ' + sl(GEN,THEN,0,0,0,0) 
    $atsfile.puts 'printf("%-30s = %-32d  %s\n",prelabel,value, postlabel);'  
    $atsfile.puts 'else'
    $atsfile.puts 'printf("%-30s = %-32d  %s \n",prelabel,value, postlabel);'
    #    $atsfile.puts 'printf("%-30s = %d %s \n",prelabel,value, postlabel);'  
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point array element
#DJDSTOP
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float_arr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,elemnt,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)    
    $atsfile.puts "global glob_iolevel;"
    $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'print(prelabel,"[",elemnt,"]",value, postlabel);'  
    #    $atsfile.puts 'printf("%s = \[ %d \] %g %s \n". prelabel,elemnt,value, postlabel);'  
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#DJDSTART
    # dump some of a 1d series
    if false # may want someday for debug
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name,arr_series,numb)" + sl(GEN,FUNSEP2,0,0,0,0) 
      $atsfile.puts "global glob_iolevel;"
      $atsfile.puts "local i;"
      $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts "  i := 1;"
      $atsfile.puts "  while (i <= numb) " + sl(GEN,DO,0,0,0,0)
      $atsfile.puts 'print(dump_label,series_name'
      $atsfile.puts ',i,arr_series[i]);'
      $atsfile.puts "    i := i + 1;"
      $atsfile.puts sl(GEN,OD,0,0,0,0)
      $atsfile.puts sl(GEN,FI,0,0,0,0)
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      # dump some of a 2d series
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series_2" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name2,arr_series2,numb,subnum,arr_x)" + sl(GEN,FUNSEP2,0,0,0,0)
      $atsfile.puts "global glob_iolevel;"
      $atsfile.puts "local i,sub,ts_term;"
      $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts "  sub := 1;"
      $atsfile.puts "  while (sub <= subnum) " + sl(GEN,DO,0,0,0,0)
      $atsfile.puts "    i :=  1;"
      $atsfile.puts "  while (i <= numb) " + sl(GEN,DO,0,0,0,0)
      $atsfile.puts 'print(dump_label,series_name2,sub,i,arr_series2[sub,i]);'
      if DEBUG_TESTTERMS then
        $atsfile.puts 'ts_term := exact_terms_y(arr_x[1],i);'
        $atsfile.puts 'print("ts_term",numb,arr_x[1],ts_term);'
        $atsfile.puts "      i := i + 1;"
      end
      $atsfile.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $atsfile.puts "sub :=  sub + 1;"
      $atsfile.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      #################################################################
      # misc info dump
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cs_info" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
      $atsfile.puts "global glob_iolevel,glob_correct_start_flag,glob_h,glob_reached_optimal_h;"
      $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts '    print("cs_info " , str , " glob_correct_start_flag = " , glob_correct_start_flag , "glob_h := " , glob_h , "glob_reached_optimal_h := " , glob_reached_optimal_h)'
      $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      ################################################################
    end
    ################# MAPLE LOGTIME #####################################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_time" + sl(GEN,FUNSEP1,0,0,0,0) + "(fd,secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "global glob_sec_in_day, glob_sec_in_hour, glob_sec_in_minute, glob_sec_in_year;"
    $atsfile.puts "local  days_int, hours_int,minutes_int, sec_int, sec_temp, years_int;"
    $atsfile.puts 'fprintf(fd,"<td>")'  + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs_in / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs_in) mod int_trunc(glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " sec_temp mod int_trunc(glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " sec_temp mod int_trunc(glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "sec_temp mod int_trunc(glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Years %d Days %d Hours %d Minutes %d Seconds",years_int,days_int,hours_int,minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Days %d Hours %d Minutes %d Seconds",days_int,hours_int,minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Hours %d Minutes %d Seconds",hours_int,minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Minutes %d Seconds",minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'fprintf(fd,"%d Seconds",sec_int);' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'fprintf(fd," 0.0 Seconds");' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"</td>\n")'  + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ########################################################
    ######################### MAPLE TIMESTR ###############################

    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_timestr" + sl(GEN,FUNSEP1,0,0,0,0) + "(secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "global glob_sec_in_day, glob_sec_in_hour, glob_sec_in_minute, glob_sec_in_year;"
    $atsfile.puts "local  days_int, hours_int,minutes_int, sec_int, sec_temp, years_int;"
    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs_in / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) mod int_trunc(glob_sec_in_year))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp mod int_trunc(glob_sec_in_day)) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp mod int_trunc(glob_sec_in_hour))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp mod int_trunc(glob_sec_in_minute))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Years %d Days %d Hours %d Minutes %d Seconds\n",years_int,days_int,hours_int,minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Days %d Hours %d Minutes %d Seconds\n",days_int,hours_int,minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Hours %d Minutes %d Seconds\n",hours_int,minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Minutes %d Seconds\n",minutes_int,sec_int);' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'printf(" = %d Seconds\n",sec_int);' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'printf(" 0.0 Seconds\n");' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ########################################################

  when MAXIMA
    # Put string

    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel) >= iolevel " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"~a~%",string(str))'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put string without eol
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str_noeol" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel)"  + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"~a",string(str))'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put Labeled string
   $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_labstr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,label,str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) "  + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"~a = ~a~%",string(label),string(str))'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) "   + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'if vallen = 4 then ('
    $atsfile.puts 'printf(true,"~a = ~g ~s ~%",prelabel,value, postlabel)'
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'printf(true,"~a = ~g ~s ~%",prelabel,value, postlabel)'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put int
    $atsfile.puts "omniout_int(iolevel,prelabel,prelen,value,vallen,postlabel) := ("
    $atsfile.puts "if (glob_iolevel >= iolevel)" + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"~a = ~d ~a~%",prelabel,value, postlabel),'  
    $atsfile.puts 'newline()'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point array element
#DJDSTOP
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float_arr" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,prelabel,elemnt,prelen,value,vallen,postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)    
    $atsfile.puts "if (glob_iolevel >= iolevel)"  + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'sprint(prelabel,"[",elemnt,"]=",value, postlabel),'  
    $atsfile.puts 'newline()'
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#DJDSTART

    if false then # may want someday
      # dump some of a 1d series
      $atsfile.puts "/*Function Start*/"
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name,arr_series,numb)" + sl(GEN,FUNSEP2,0,0,0,0) 
      $atsfile.puts "block(modedeclare([[i],fixnum]),"
      $atsfile.puts "if (glob_iolevel >= iolevel)" + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts "  i : 1,"
      $atsfile.puts "  while (i <= numb) do ("
      $atsfile.puts 'sprint(dump_label,series_name,"i = ",i,"series = ",array_series[i]),'
      $atsfile.puts 'newline(),'
      $atsfile.puts "    i : i + 1"
      $atsfile.puts ")"
      $atsfile.puts ")"
      $atsfile.puts sl(GEN,FI,0,0,0,0)
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      # dump some of a 2d series
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series_2" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,dump_label,series_name2,arr_series2,numb,subnum,arr_x)" + sl(GEN,FUNSEP2,0,0,0,0)
      $atsfile.puts "/*Function Start*/"
      $atsfile.puts "array_series2,numb,subnum"
      $atsfile.puts ") := ("
      $atsfile.puts "block(modedeclare([[i],fixnum,[sub],fixnum,[ts_term],float]),"
      $atsfile.puts "if (glob_iolevel >= iolevel)" + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts "  sub : 1,"
      $atsfile.puts "  while (sub <= subnum)"  + sl(GEN,DO,0,0,0,0)
      $atsfile.puts "    i :  1,"
      $atsfile.puts "  while (i <= num)"   + sl(GEN,DO,0,0,0,0)
      $atsfile.puts 'sprint(dump_label,series_name,"sub = ",sub,"i = ",i,"series2 = ",array_series2[sub,i]),'
      $atsfile.puts "      i : i + 1"
      $atsfile.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
      $atsfile.puts "sub :  sub + 1"
      $atsfile.puts sl(GEN,OD,0,0,0,0)
      $atsfile.puts sl(GEN,FI,0,0,0,0)
      $atsfile.puts ")"
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      # misc info dump
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cs_info" + sl(GEN,FUNSEP1,0,0,0,0) + "(iolevel,str)" + sl(GEN,FUNSEP2,0,0,0,0)
      $atsfile.puts "if (glob_iolevel >= iolevel)" + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts '    sprint(concat("cs_info " , str , " glob_correct_start_flag = " , glob_correct_start_flag , "glob_h := " , glob_h , "glob_reached_optimal_h := " , glob_reached_optimal_h))'
      $atsfile.puts sl(GEN,FI,0,0,0,0)
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    end
    ########################### MAXIMA LOGTIME #################################################
    ### Maxima
    $atsfile.puts "logitem_time(fd,secs_in) := ("
    $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[days_int,hours_int, minutes_int, sec_int, years_int],fixnum,[secs,secs_temp],float ]),",0,0)
    $atsfile.puts "  secs " + sl(GEN,ASSIGN,0,0,0,0) + " (secs_in)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts 'printf(fd,"<td>~%"),' 
    $atsfile.puts "  if (secs >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " mod(int_trunc(secs) , int_trunc(glob_sec_in_year))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " mod(sec_temp , int_trunc(glob_sec_in_day)) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " mod(sec_temp , int_trunc(glob_sec_in_hour))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "mod(sec_temp , int_trunc(glob_sec_in_minute))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "     "
    $atsfile.puts "if ((int_trunc(years_int)) > 0.1) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(fd,"~d Years ~f Days ~f Hours ~f Minutes ~f Seconds~%",years_int,days_int,hours_int,minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0.1) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(fd,"~d Days ~d Hours ~d Minutes ~d Seconds~%",days_int,hours_int,minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0.1) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(fd,"~d Hours ~d Minutes ~d Seconds~%",hours_int,minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0.1) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(fd,"~d Minutes ~d Seconds~%",minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'printf(fd,"~d Seconds~%",sec_int)' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'printf(fd," 0.0 Seconds~%")' 
    $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts 'printf(fd,"</td>~%")' 
    $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)

    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)

##################################### MAXIMA TIMESTR ####################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_timestr" + sl(GEN,FUNSEP1,0,0,0,0) + "(secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[days_int,hours_int, minutes_int, sec_int, years_int],fixnum,[secs,secs_temp],float ]),",0,0)
#    $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([days, days_int, hours, hours_int, minutes, minutes_int, sec_int, seconds, secs, years, years_int],",0,0)
    $atsfile.puts "  secs " + sl(GEN,ASSIGN,0,0,0,0) + " (secs_in)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "  if (secs >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(secs / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " mod(int_trunc(secs) , int_trunc(glob_sec_in_year))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " mod(sec_temp , int_trunc(glob_sec_in_day)) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " int_trunc(sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " mod(sec_temp , int_trunc(glob_sec_in_hour))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "int_trunc(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "mod(sec_temp , int_trunc(glob_sec_in_minute))" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "     "
    $atsfile.puts "if (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"= ~f Years ~f Days ~f Hours ~f Minutes ~f Seconds~%",years_int,days_int,hours_int,minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0.1) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"= ~d Days ~d Hours ~d Minutes ~d Seconds~%",days_int,hours_int,minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0.1) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"= ~d Hours ~d Minutes ~d Seconds~%",hours_int,minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0.1) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(true,"= ~d Minutes ~d Seconds~%",minutes_int,sec_int)' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'printf(true,"= ~d Seconds~%",sec_int)' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'printf(true,"= 0.0 Seconds~%")' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)

    $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)

    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#######################################################################
## C++
  when CPP
    # Put string
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts 'printf("%s\n",str);'
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put string without eol
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str_noeol" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts 'printf("%s",str);'
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put Labeled string
   $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_labstr" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *label,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) {"
    $atsfile.puts 'printf("%s = %s\n",label,str);'
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *prelabel,int prelen,double value,int vallen,char *postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts "if (vallen == 4) {"
    $atsfile.puts 'printf("%-30s = %-42.4g %s \n",prelabel,value, postlabel);'
    $atsfile.puts "}"
    $atsfile.puts 'else'
    $atsfile.puts "{"
    $atsfile.puts 'printf("%-30s = %-42.16g %s \n",prelabel,value, postlabel);'
    $atsfile.puts "}"
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put integer
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_int" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *prelabel,int prelen,int value,int vallen,char *postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts "if (vallen == 5) {"
    $atsfile.puts 'printf("%-30s = %-32d  %s\n",prelabel,value, postlabel);'  
    $atsfile.puts "}"
    $atsfile.puts 'else'
    $atsfile.puts "{"
    $atsfile.puts 'printf("%-30s = %-32d  %s \n",prelabel,value, postlabel);'
    $atsfile.puts "}"
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point array element
#DJDSTOP
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float_arr" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *prelabel,int elemnt,int prelen,double *value,int vallen,char *postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)    
    $atsfile.puts "if (glob_iolevel >= iolevel) {"
    $atsfile.puts 'printf("%s = [ %d ] %g %s \n", prelabel,elemnt,value, postlabel);'  
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#DJDSTART
    if false then # may want someday
      # dump some of a 1d series
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *dump_label,char *series_name,double *arr_series,int numb)" + sl(GEN,FUNSEP2,0,0,0,0) 
      $atsfile.puts "int i;"
      $atsfile.puts "if (glob_iolevel >= iolevel) { "
      $atsfile.puts "  i = 1;"
      $atsfile.puts "  while (i <= numb) { "
      $atsfile.puts 'printf("%s %s [ %d ] %g\n" , dump_label,series_name'
      $atsfile.puts ',i,arr_series[i]);'
      $atsfile.puts "    i++;"
      $atsfile.puts "}"
      $atsfile.puts "}"
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      #################################################################
      # misc info dump
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cs_info" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
      $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts 'printf("cs_info %s glob_h: = %g\n",'
      $atsfile.puts "str,glob_h)" + sl(GEN,LINESEP,0,0,0,0)
      $atsfile.puts sl(GEN,FI,0,0,0,0)
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    end
    ################################################################
    ############################# CPP LOGTIME ###############################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_time" + sl(GEN,FUNSEP1,0,0,0,0) + "(FILE *fd,double secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
     $atsfile.puts sl(GEN,SPECIFIC,CPP,"int days_int, hours_int, minutes_int, sec_int, years_int,sec_temp;",0,0)
    $atsfile.puts sl(GEN,SPECIFIC,CPP,"double sec_dbl;",0,0)

#    $atsfile.puts 'printf("secs in = %d\n",secs_in);'
    $atsfile.puts 'fprintf(fd,"<td>")'  + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "sec_dbl " + sl(GEN,ASSIGN,0,0,0,0) + "secs_in - (double)(years_int * glob_sec_in_year + days_int * glob_sec_in_day + hours_int * glob_sec_in_hour + minutes_int * glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)

    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Years %d Days %d Hours %d Minutes %3.1f Seconds",years_int,days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Days %d Hours %d Minutes %3.1f Seconds",days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Hours %d Minutes %3.1f Seconds",hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Minutes %3.1f Seconds",minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'fprintf(fd,"%3.1f Seconds",sec_dbl);' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"0.0 Seconds");' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"</td>")' + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ############################### CPP TIMESTR #######################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_timestr" + sl(GEN,FUNSEP1,0,0,0,0) + "(double secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts sl(GEN,SPECIFIC,CPP,"int days_int, hours_int, minutes_int, sec_int, years_int,sec_temp;",0,0)
    $atsfile.puts sl(GEN,SPECIFIC,CPP,"double sec_dbl;",0,0)
#    $atsfile.puts 'printf("secs in = %d\n",secs_in);'
    $atsfile.puts "  if (secs_in >= 0.0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "sec_dbl " + sl(GEN,ASSIGN,0,0,0,0) + "secs_in - (double)(years_int * glob_sec_in_year + days_int * glob_sec_in_day + hours_int * glob_sec_in_hour + minutes_int * glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)

    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Years %d Days %d Hours %d Minutes %3.1f Seconds\n",years_int,days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Days %d Hours %d Minutes %3.1f Seconds\n",days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Hours %d Minutes %3.1f Seconds\n",hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Minutes %3.1f Seconds\n",minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'printf(" = %3.1f Seconds\n",sec_dbl);' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'printf(" 0.0 Seconds\n");' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ########################################################
    #######################################################

  when CCC
    # Put string
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts 'printf("%s\n",str);'
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put string without eol
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_str_noeol" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts 'printf("%s",str);'
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put Labeled string
   $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_labstr" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *label,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) {"
    $atsfile.puts 'printf("%s = %s\n",label,str);'
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *prelabel,int prelen,double value,int vallen,char *postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts "if (vallen == 4) {"
    $atsfile.puts 'printf("%-30s = %-42.4g %s \n",prelabel,value, postlabel);'
    $atsfile.puts "}"
    $atsfile.puts 'else'
    $atsfile.puts "{"
    $atsfile.puts 'printf("%-30s = %-42.16g %s \n",prelabel,value, postlabel);'
    $atsfile.puts "}"
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put integer
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_int" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *prelabel,int prelen,int value,int vallen,char *postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts "if (glob_iolevel >= iolevel) { "
    $atsfile.puts "if (vallen == 5) {"
    $atsfile.puts 'printf("%-30s = %-32d  %s\n",prelabel,value, postlabel);'  
    $atsfile.puts "}"
    $atsfile.puts 'else'
    $atsfile.puts "{"
    $atsfile.puts 'printf("%-30s = %-32d  %s \n",prelabel,value, postlabel);'
    $atsfile.puts "}"
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    # Put floating point array element
#DJDSTOP
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_float_arr" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *prelabel,int elemnt,int prelen,double *value,int vallen,char *postlabel)" + sl(GEN,FUNSEP2,0,0,0,0)    
    $atsfile.puts "if (glob_iolevel >= iolevel) {"
    $atsfile.puts 'printf("%s = [ %d ] %g %s \n", prelabel,elemnt,value, postlabel);'  
    $atsfile.puts "}"
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#DJDSTART
    # dump some of a 1d series
    if false then #may want someday
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "dump_series" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *dump_label,char *series_name,double *arr_series,int numb)" + sl(GEN,FUNSEP2,0,0,0,0) 
      $atsfile.puts "int i;"
      $atsfile.puts "if (glob_iolevel >= iolevel) { "
      $atsfile.puts "  i = 1;"
      $atsfile.puts "  while (i <= numb) { "
      $atsfile.puts 'printf("%s %s [ %d ] %g\n" , dump_label,series_name'
      $atsfile.puts ',i,arr_series[i]);'
      $atsfile.puts "    i++;"
      $atsfile.puts "}"
      $atsfile.puts "}"
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      #################################################################
      # misc info dump
      $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cs_info" + sl(GEN,FUNSEP1,0,0,0,0) + "(int iolevel,char *str)" + sl(GEN,FUNSEP2,0,0,0,0)
      $atsfile.puts "if (glob_iolevel >= iolevel) " + sl(GEN,THEN,0,0,0,0)
      $atsfile.puts 'printf("cs_info %s glob_h: = %g\n",'
      $atsfile.puts "str,glob_h)" + sl(GEN,LINESEP,0,0,0,0)
      $atsfile.puts sl(GEN,FI,0,0,0,0)
      $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
      ################################################################
    end
    ################################# CCC LOGTIME ###########################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_time" + sl(GEN,FUNSEP1,0,0,0,0) + "(FILE *fd,double secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts sl(GEN,SPECIFIC,CCC,"int days_int, hours_int, minutes_int, sec_int, years_int,sec_temp;",0,0)
    $atsfile.puts sl(GEN,SPECIFIC,CCC,"double sec_dbl;",0,0)

#    $atsfile.puts 'printf("secs in = %d\n",secs_in);'
    $atsfile.puts 'fprintf(fd,"<td>")'  + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "sec_dbl " + sl(GEN,ASSIGN,0,0,0,0) + "secs_in - (double)(years_int * glob_sec_in_year + days_int * glob_sec_in_day + hours_int * glob_sec_in_hour + minutes_int * glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)

    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Years %d Days %d Hours %d Minutes %3.1f Seconds",years_int,days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Days %d Hours %d Minutes %3.1f Seconds",days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Hours %d Minutes %3.1f Seconds",hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"%d Minutes %3.1f Seconds",minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'fprintf(fd,"%3.1f Seconds",sec_dbl);' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"0.0 Seconds");' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts 'fprintf(fd,"</td>")' + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ############################## CCC TIMESTR ########################################
    $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "omniout_timestr" + sl(GEN,FUNSEP1,0,0,0,0) + "(double secs_in)" + sl(GEN,FUNSEP2,0,0,0,0)
    $atsfile.puts sl(GEN,SPECIFIC,CCC,"int days_int, hours_int, minutes_int, sec_int, years_int,sec_temp;",0,0)
    $atsfile.puts sl(GEN,SPECIFIC,CCC,"double sec_dbl;",0,0)
#    $atsfile.puts 'printf("secs in = %3.1f\n",secs_in);'

    $atsfile.puts "  if (secs_in >= 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts "    years_int " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) / glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (int_trunc(secs_in) % glob_sec_in_year)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    days_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_day) " + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    hours_int " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp / glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_temp " + sl(GEN,ASSIGN,0,0,0,0) + " (sec_temp % glob_sec_in_hour)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    minutes_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp / glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "    sec_int " + sl(GEN,ASSIGN,0,0,0,0) + "(sec_temp % glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)
    $atsfile.puts "sec_dbl " + sl(GEN,ASSIGN,0,0,0,0) + "secs_in - (double)(years_int * glob_sec_in_year + days_int * glob_sec_in_day + hours_int * glob_sec_in_hour + minutes_int * glob_sec_in_minute)" + sl(GEN,LINESEP,0,0,0,0)

    $atsfile.puts "     "
    $atsfile.puts sl(GEN,IF,0,0,0,0) + " (years_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Years %d Days %d Hours %d Minutes %3.1f Seconds\n",years_int,days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (days_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Days %d Hours %d Minutes %3.1f Seconds\n",days_int,hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (hours_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Hours %d Minutes %3.1f Seconds\n",hours_int,minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + " (minutes_int > 0) " + sl(GEN,THEN,0,0,0,0)
    $atsfile.puts 'printf(" = %d Minutes %3.1f Seconds\n",minutes_int,sec_dbl);' 
    $atsfile.puts sl(GEN,ELSE,0,0,0,0) 
    $atsfile.puts 'printf(" = %3.1f Seconds\n",sec_dbl);' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,ELSE,0,0,0,0)
    $atsfile.puts 'printf(" 0.0 Seconds\n");' 
    $atsfile.puts sl(GEN,FI,0,0,0,0)
    $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
    
    ########################################################
    #######################################################

  end
end

openfile()
generic_io(GEN)
###########################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "zero_ats_ar" + sl(GEN,FUNSEP1,0,0,0,0) + "("  + st2(FLOAT_ARRAY) + "arr_a) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global ATS_MAX_TERMS;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local iii;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([ iii],fixnum),",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CPP,"int iii;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CCC,"int iii;",0,0)
$atsfile.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + "1" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "while (iii <= ATS_MAX_TERMS)" + sl(GEN,DO,0,0,0,0)
$atsfile.puts "arr_a " + sl(GEN,SUBSC1,"iii",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "iii " + sl(GEN,ASSIGN,0,0,0,0) + " iii + 1" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,OD,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
############################################################################
###########################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "ats" + sl(GEN,FUNSEP1,0,0,0,0) + "("  + st2(INTEGER) + "mmm_ats," + st2(FLOAT_ARRAY) + "arr_a," + st2(FLOAT_ARRAY) + "arr_b," + st2(INTEGER) + "jjj_ats) " + sl(GEN,FUNSEP2,0,0,0,0)

$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global ATS_MAX_TERMS;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local iii_ats, lll_ats,ma_ats, ret_ats;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([ [iii_ats, lll_ats,ma_ats],fixnum, [ret_ats],float]),",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CPP,"int iii_ats, lll_ats, ma_ats;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + "  ret_ats;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CCC,"int iii_ats, lll_ats, ma_ats;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret_ats;",0,0) 
$atsfile.puts "  ret_ats " + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "  if (jjj_ats <=  mmm_ats) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "    ma_ats " + sl(GEN,ASSIGN,0,0,0,0) + " mmm_ats + 1" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "    iii_ats " + sl(GEN,ASSIGN,0,0,0,0) + " jjj_ats" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "    while (iii_ats <= mmm_ats)"  + sl(GEN,DO,0,0,0,0)
$atsfile.puts "      lll_ats " + sl(GEN,ASSIGN,0,0,0,0) + " ma_ats - iii_ats" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts  "if ((lll_ats <= ATS_MAX_TERMS " + sl(GEN,L_AND,0,0,0,0) + "(iii_ats <= ATS_MAX_TERMS) )) "+ sl(GEN,THEN,0,0,0,0)
$atsfile.puts "      ret_ats " + sl(GEN,ASSIGN,0,0,0,0) + " ret_ats + c(arr_a" + sl(GEN,SUBSC1,"iii_ats",0,0,0) + ")*c(arr_b" + sl(GEN,SUBSC1,"lll_ats",0,0,0) + ")" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

$atsfile.puts "      iii_ats " + sl(GEN,ASSIGN,0,0,0,0) + " iii_ats + 1" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,OD,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"ret_ats",0,0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
############################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "att" + sl(GEN,FUNSEP1,0,0,0,0) + "("  + st2(INTEGER) + "mmm_att," + st2(FLOAT_ARRAY) + "arr_aa," + st2(FLOAT_ARRAY)  + "arr_bb," + st2(INTEGER) + "jjj_att) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global ATS_MAX_TERMS;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local al_att, iii_att,lll_att, ma_att, ret_att;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([ [al_att, iii_att,lll_att, ma_att],float , [ret_att],fixnum]),",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CPP,"int al_att, iii_att,lll_att, ma_att;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret_att;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CCC,"int al_att, iii_att,lll_att, ma_att;",0,0) 
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret_att;",0,0) 
$atsfile.puts "  ret_att " + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "  if (jjj_att < mmm_att) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "    ma_att " + sl(GEN,ASSIGN,0,0,0,0) + " mmm_att + 2" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "    iii_att " + sl(GEN,ASSIGN,0,0,0,0) + " jjj_att" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "    while ((iii_att < mmm_att)" + sl(GEN,L_AND,0,0,0,0) + "(iii_att <= ATS_MAX_TERMS) )  " + sl(GEN,DO,0,0,0,0)

$atsfile.puts "      lll_att " + sl(GEN,ASSIGN,0,0,0,0) + " ma_att - iii_att" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "      al_att " + sl(GEN,ASSIGN,0,0,0,0) + " (lll_att - 1)" + sl(GEN,LINESEP,0,0,0,0)

$atsfile.puts  "if ((lll_att <= ATS_MAX_TERMS " + sl(GEN,L_AND,0,0,0,0) + "(iii_att <= ATS_MAX_TERMS) )) " + sl(GEN,THEN,0,0,0,0)


$atsfile.puts "      ret_att " + sl(GEN,ASSIGN,0,0,0,0) + "  ret_att + c(arr_aa" + sl(GEN,SUBSC1,"iii_att",0,0,0) +  ")*c(arr_bb" + sl(GEN,SUBSC1,"lll_att",0,0,0) + ")* c(al_att)" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "      iii_att " + sl(GEN,ASSIGN,0,0,0,0) + " iii_att + 1" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,OD,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "    ret_att " + sl(GEN,ASSIGN,0,0,0,0) + " ret_att / c(mmm_att) " + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"ret_att",0,0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logditto" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file)" + sl(GEN,FUNSEP2,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"ditto")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"</td>")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP)
  $atsfile.puts 'file.printf("<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'file.printf("ditto")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'file.printf("</td>")' + sl(GEN,LINEEND,0,0,0,0)
else # Maxima
  $atsfile.puts 'printf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"ditto")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"</td>"),0' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_integer" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file," + st2(INTEGER) + "n)" + sl(GEN,FUNSEP2,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"%d",n)' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"</td>")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP)
  $atsfile.puts 'file.printf("<td>")'
  $atsfile.puts 'file.printf("%d",n)'
  $atsfile.puts 'file.printf("</td>")'
else #Maxima
  $atsfile.puts 'printf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"~d",n)' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"</td>"),0' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_str" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file," + st2(STRING) + "str)" + sl(GEN,FUNSEP2,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,str)' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"</td>")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP)
  $atsfile.puts 'file.printf("<td>")'
  $atsfile.puts 'file.printf(str.to_s)'
  $atsfile.puts 'file.printf("</td>")'
else # Maxima
  $atsfile.puts 'printf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,str)' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"</td>"),0' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_good_digits" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file," + st2(FLOAT) + "rel_error)" + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_small_float,glob_prec;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[good_digits],fixnum]),",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local good_digits;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,"int good_digits;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,"int good_digits;",0,0)

if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP)
  $atsfile.puts 'file.printf("<td>")'
else # Maxima
  $atsfile.puts 'printf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
end
# $atsfile.puts "if (rel_error" + sl(GEN,NOTEQUALS,0,0,0,0) + "-1.0)" + sl(GEN,THEN,0,0,0,0) 
# $atsfile.puts "if (rel_error > glob_prec)" + sl(GEN,THEN,0,0,0,0) 
if (GEN == RUBY) || (GEN == RUBY_APFP) then
#  $atsfile.puts 'good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '3-int_trunc(log10(rel_error))' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'file.printf("%d",glob_min_good_digits)' + sl(GEN,LINEEND,0,0,0,0)
elsif GEN == MAPLE or GEN == CCC or GEN == CPP then 
#  $atsfile.puts 'good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '3-int_trunc(log10(rel_error))' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"%d",glob_min_good_digits)' + sl(GEN,LINEEND,0,0,0,0)
else # Maxima
#  $atsfile.puts 'good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '3-floor(log10(rel_error))' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"~d",glob_min_good_digits)' + sl(GEN,LINESEP,0,0,0,0)
end

#$atsfile.puts sl(GEN,ELSE,0,0,0,0)
# if GEN == MAPLE
#  $atsfile.puts 'good_digits' + sl(GEN,ASSIGN,0,0,0,0) + 'Digits' + sl(GEN,LINESEP,0,0,0,0)
#  $atsfile.puts 'fprintf(file,"%d",glob_min_good_digits)' + sl(GEN,LINEEND,0,0,0,0)
# elsif GEN == CCC or GEN == CPP or GEN == RUBY or GEN == RUBY_APFP then
#  $atsfile.puts 'good_digits' + sl(GEN,ASSIGN,0,0,0,0) + '16' + sl(GEN,LINESEP,0,0,0,0)
#
#  if (GEN == RUBY) || (GEN == RUBY_APFP) then
#    $atsfile.puts 'file.printf("%d",good_digits)' + sl(GEN,LINEEND,0,0,0,0)
#  else
#    $atsfile.puts 'fprintf(file,"%d",good_digits)' + sl(GEN,LINEEND,0,0,0,0)
#  end
#else # Maxima
#  $atsfile.puts 'good_digits' + sl(GEN,ASSIGN,0,0,0,0) + "16" + sl(GEN,LINESEP,0,0,0,0)
#  $atsfile.puts 'printf(file,"~d",good_digits)' + sl(GEN,LINEEND,0,0,0,0)
#end
#$atsfile.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
#$atsfile.puts sl(GEN,ELSE,0,0,0,0)
#if GEN == MAPLE or GEN == CCC or GEN == CPP
#  $atsfile.puts 'fprintf(file,"Unknown");' 
#elsif (GEN == RUBY) || (GEN == RUBY_APFP)
#  $atsfile.puts 'file.printf("Unknown")' 
#else
#  $atsfile.puts 'printf(file,"Unknown")' 
#end  
#$atsfile.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"</td>")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP)
  $atsfile.puts 'file.printf("</td>")'

else
  $atsfile.puts 'printf(file,"</td>")' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "log_revs" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file," + st2(STRING) + "revs)" + sl(GEN,FUNSEP2,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,revs)' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP) then
  $atsfile.puts 'file.printf(revs.to_s)' + sl(GEN,LINEEND,0,0,0,0)
else
  $atsfile.puts 'printf(file,revs)' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_float" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file," + st2(FLOAT) + "x)" + sl(GEN,FUNSEP2,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"%g",x)' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'fprintf(file,"</td>")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP) then
  $atsfile.puts 'file.printf("<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'file.printf(x.to_s)' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'file.printf("</td>")' + sl(GEN,LINEEND,0,0,0,0)
else # Maxima
  $atsfile.puts 'printf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"~g",x)' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"</td>"),0' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logitem_h_reason" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file)" + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_h_reason;",0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'if (glob_h_reason ' + sl(GEN,EQUALS,0,0,0,0) + '1)' + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'fprintf(file,"Max H")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "2)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'fprintf(file,"Display Interval")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "3)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'fprintf(file,"Optimal")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "4)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'fprintf(file,"Pole Accuracy")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "5)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'fprintf(file,"Min H (Pole)")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "6)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'fprintf(file,"Pole")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "7)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'fprintf(file,"Opt Iter")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSE,0,0,0,0)
  $atsfile.puts 'fprintf(file,"Impossible")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,FI,0,0,0,0)
  $atsfile.puts 'fprintf(file,"</td>")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP) then
  $atsfile.puts 'file.printf("<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'if (glob_h_reason ' + sl(GEN,EQUALS,0,0,0,0) + "1)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'file.printf("Max H")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "2)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'file.printf("Display Interval")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "3)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'file.printf("Optimal")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "4)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'file.printf("Pole Accuracy")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "5)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'file.printf("Min H (Pole)")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "6)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'file.printf("Pole")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "7)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'file.printf("Opt Iter")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSE,0,0,0,0)
  $atsfile.puts 'file.printf("Impossible")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'file.printf("</td>")' + sl(GEN,LINEEND,0,0,0,0)
else # Maxima
  $atsfile.puts 'printf(file,"<td>")' + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'if (glob_h_reason ' + sl(GEN,EQUALS,0,0,0,0) + "1)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'printf(file,"Max H")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "2)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'printf(file,"Display_interval")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "3)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'printf(file,"Optimal")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "4)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'printf(file,"Pole Accuracy")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "5)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'printf(file,"Min H (Pole)")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "6)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'printf(file,"Pole")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0) + "(glob_h_reason" + sl(GEN,EQUALS,0,0,0,0) + "7)" + sl(GEN,THEN,0,0,0,0) 
  $atsfile.puts 'printf(file,"Opt Iter")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,ELSE,0,0,0,0)
  $atsfile.puts 'printf(file,"Impossible")' + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts 'printf(file,"</td>"),0' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logstart" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file)" + sl(GEN,FUNSEP2,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"<tr>")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP) then
  $atsfile.puts 'file.printf("<tr>")' + sl(GEN,LINEEND,0,0,0,0)
else # Maxima
  $atsfile.puts 'printf(file,"<tr>"),0' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)

############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "logend" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FILE_PTR) + "file)" + sl(GEN,FUNSEP2,0,0,0,0)
if GEN == MAPLE or GEN == CCC or GEN == CPP then
  $atsfile.puts 'fprintf(file,"</tr>\n")' + sl(GEN,LINEEND,0,0,0,0)
elsif (GEN == RUBY) || (GEN == RUBY_APFP) then
  $atsfile.puts 'file.printf("</tr>")' + sl(GEN,LINEEND,0,0,0,0)
else # Maxima
  $atsfile.puts 'printf(file,"</tr>~%"),0' + sl(GEN,LINEEND,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
############################################################################
$atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "chk_data" + sl(GEN,FUNSEP1,0,0,0,0) + "() " + sl(GEN,FUNSEP2,0,0,0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_max_iter,ALWAYS, ATS_MAX_TERMS;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local  errflag;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([  [errflag],boolean]),",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,"int  errflag;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,"int  errflag;",0,0)
$atsfile.puts "  errflag " + sl(GEN,ASSIGN,0,0,0,0) + " false" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "  "

$atsfile.puts "  if (glob_max_iter < 2) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts '    omniout_str(ALWAYS,"Illegal max_iter")' + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "    errflag " + sl(GEN,ASSIGN,0,0,0,0) + " true" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "  if (errflag)  " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"quit()",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,'quit;',0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"),0",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###########################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_expect_sec" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "t_end2," + st2(FLOAT) + "t_start2," + st2(FLOAT) + "t2," + st2(FLOAT) + "clock_sec2) " + sl(GEN,FUNSEP2,0,0,0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_small_float;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ms2, rrr, sec_left, sub1, sub2;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[ ms2, rrr, sec_left, sub1, sub2], float]),",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ms2, rrr, sec_left, sub1, sub2;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ms2, rrr, sec_left, sub1, sub2;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLEDBG,'print("t_end2=",t_end2,"t_start2=",t_start2,"t2=",t2,"clock_sec2=",clock_sec2);',0,0) + sl(GEN,LINEEND,0,0,0,0)

$atsfile.puts "ms2" + sl(GEN,ASSIGN,0,0,0,0) + "c(clock_sec2)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "sub1" + sl(GEN,ASSIGN,0,0,0,0) + "c(t_end2-t_start2)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "sub2" + sl(GEN,ASSIGN,0,0,0,0) + "c(t2-t_start2)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "if (sub1" + sl(GEN,EQUALS,0,0,0,0) + "glob__0) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "sec_left" + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "if (sub2 > glob__0) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "rrr" + sl(GEN,ASSIGN,0,0,0,0) + "(sub1/sub2)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "sec_left " + sl(GEN,ASSIGN,0,0,0,0) + "rrr * c(ms2) - c(ms2)" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "sec_left " + sl(GEN,ASSIGN,0,0,0,0) + "glob__0" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"sec_left",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
###########################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_percent" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "t_end2," + st2(FLOAT) + "t_start2," + st2(FLOAT) + " t2) " + sl(GEN,FUNSEP2,0,0,0,0) 
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_small_float;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local rrr, sub1, sub2;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([ [rrr, sub1, sub2],float]),",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " rrr, sub1, sub2;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " rrr, sub1, sub2;",0,0)
$atsfile.puts "  sub1 " + sl(GEN,ASSIGN,0,0,0,0) + " (t_end2-t_start2)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "  sub2 " + sl(GEN,ASSIGN,0,0,0,0) + " (t2-t_start2)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "  if (sub2 > glob_small_float) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "    rrr " + sl(GEN,ASSIGN,0,0,0,0) + " (glob__100*sub2)/sub1" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "    rrr " + sl(GEN,ASSIGN,0,0,0,0) + " 0.0" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"  rrr",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
####################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_rad_from_ratio" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "term1," + st2(FLOAT) + "term2," + st2(INTEGER) + "last_no) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,REM,"TOP TWO TERM RADIUS ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_h,glob_larger_float;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret;",0,0)
if GEN != RUBY_APFP then
  $atsfile.puts "if (float_abs(term2) > glob__0) " + sl(GEN,THEN,0,0,0,0)
else
  $atsfile.puts "if (" + sl(GEN,L_NOT,0,0,0,0) + "term2.maybe_zero)" + sl(GEN,THEN,0,0,0,0)
end
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + " float_abs(term1 * glob_h / term2)" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"  ret",0,0,0)
$atsfile.puts sl(GEN,REM,"BOTTOM TWO TERM RADIUS ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
####################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_ord_from_ratio" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "term1," + st2(FLOAT) + "term2," + st2(INTEGER) + "last_no) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,REM,"TOP TWO TERM ORDER ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_h,glob_larger_float;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret;",0,0)
if GEN != RUBY_APFP then
  $atsfile.puts "if (float_abs(term2) > glob__0) " + sl(GEN,THEN,0,0,0,0)
else
  $atsfile.puts "if (" + sl(GEN,L_NOT,0,0,0,0) + "term2.maybe_zero)" + sl(GEN,THEN,0,0,0,0)
end
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "glob__1 +  float_abs(term2) * c(last_no) * ln(float_abs(term1 * glob_h / term2))/ln(c(last_no))" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"  ret",0,0,0)
$atsfile.puts sl(GEN,REM,"BOTTOM TWO TERM ORDER ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
####################################################################
if GEN != RUBY_APFP && GEN != CPP && GEN != CCC then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "c" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "in_val) " + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts sl(GEN,REM,"To Force Conversion when needed",0,0,0)
  $atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret;",0,0)
  if GEN == RUBY or GEN == CCC or GEN ==CPP then
    $atsfile.puts "ret = in_val" + sl(GEN,LINEEND,0,0,0,0) 
  elsif GEN == MAPLE then
    $atsfile.puts "ret := evalf(in_val);"
  elsif GEN == MAXIMA then
    $atsfile.puts "ret : in_val,"
  else # APFP
    $atsfile.puts "ret = ap_in(in_val.to_s)"
  end
  $atsfile.puts sl(GEN,RETURN,"  ret",0,0,0)
  $atsfile.puts sl(GEN,REM,"End Conversion",0,0,0)
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
end
####################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_rad_from_three_terms" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "term1," + st2(FLOAT) + "term2," + st2(FLOAT) + "term3," + st2(INTEGER) + "last_no) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,REM,"TOP THREE TERM RADIUS ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_h,glob_larger_float;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret,temp;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret,temp;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret,temp;",0,0)
$atsfile.puts "temp" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs(term2*term2*c(last_no)+glob__m2*term2*term2-term1*term3*c(last_no)+term1*term3)" + sl(GEN,LINESEP,0,0,0,0)
if GEN != RUBY_APFP then
  $atsfile.puts "if (float_abs(temp) > glob__0) " + sl(GEN,THEN,0,0,0,0)
else
  $atsfile.puts "if (" + sl(GEN,L_NOT,0,0,0,0) + "temp.maybe_zero)" + sl(GEN,THEN,0,0,0,0)
end
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs((term2*glob_h*term1)/(temp))" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"ret",0,0,0)
$atsfile.puts sl(GEN,REM,"BOTTOM THREE TERM RADIUS ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
####################################################################
#
#                                          2           2       2  2            2
#          4 fmm2 fm m - 3 fmm2 fm - 4 fmm1  m + 4 fmm1  + fmm1  m  - fmm2 fm m
#    p = - ---------------------------------------------------------------------
#                             2           2
#                         fmm1  m - 2 fmm1  - fmm2 fm m + fmm2 fm
#
#                        fmm1 h fmm2
#    , a = ---------------------------------------]]
#              2           2
#          fmm1  m - 2 fmm1  - fmm2 fm m + fmm2 fm
#
#
####################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_ord_from_three_terms" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "term1," + st2(FLOAT) + "term2," + st2(FLOAT) + "term3," + st2(INTEGER) + "last_no) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,REM,"TOP THREE TERM ORDER ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret;",0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "float_abs((glob__4*term1*term3*c(last_no)-glob__3*term1*term3-glob__4*term2*term2*c(last_no)+glob__4*term2*term2+term2*term2*c(last_no*last_no)-term1*term3*c(last_no*last_no))/(term2*term2*c(last_no)-glob__2*term2*term2-term1*term3*c(last_no)+term1*term3))" + sl(GEN,LINESEP,0,0,0,0)

$atsfile.puts sl(GEN,RETURN,"ret",0,0,0)
$atsfile.puts sl(GEN,REM,"TOP THREE TERM ORDER ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
####################################################################
####################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_rad_from_six_terms" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "term1," + st2(FLOAT) + "term2," + st2(FLOAT) + "term3," + st2(FLOAT) + "term4," + st2(FLOAT) + "term5," + st2(FLOAT) + "term6," + st2(INTEGER) + "last_no) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,REM,"TOP SIX TERM RADIUS ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_h,glob_larger_float,glob_six_term_ord_save;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret,rm0,rm1,rm2,rm3,rm4,nr1,nr2,dr1,dr2,ds2,rad_c,ord_no,ds1,rcs;",0,0)

$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret,rm0,rm1,rm2,rm3,rm4,nr1,nr2,dr1,dr2,ds2,rad_c,ord_no,ds1,rcs;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret,rm0,rm1,rm2,rm3,rm4,nr1,nr2,dr1,dr2,ds2,rad_c,ord_no,ds1,rcs;",0,0)

$atsfile.puts "if ((term5 " + sl(GEN,NOTEQUALS,0,0,0,0) + "glob__0)" + sl(GEN,L_AND,0,0,0,0) + "(term4 " + sl(GEN,NOTEQUALS,0,0,0,0) + "glob__0)" + sl(GEN,L_AND,0,0,0,0) + "(term3 " + sl(GEN,NOTEQUALS,0,0,0,0) + "glob__0)" + sl(GEN,L_AND,0,0,0,0) + " (term2 " + sl(GEN,NOTEQUALS,0,0,0,0) + "glob__0)" + sl(GEN,L_AND,0,0,0,0) +  "(term1 " + sl(GEN,NOTEQUALS,0,0,0,0) + "glob__0))" + sl(GEN,THEN,0,0,0,0)  
$atsfile.puts "rm0" + sl(GEN,ASSIGN,0,0,0,0) + "term6/term5" + sl(GEN,LINESEP,0,0,0,0) 
$atsfile.puts "rm1" + sl(GEN,ASSIGN,0,0,0,0) + "term5/term4" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "rm2" + sl(GEN,ASSIGN,0,0,0,0) + "term4/term3" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "rm3" + sl(GEN,ASSIGN,0,0,0,0) + "term3/term2" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "rm4" + sl(GEN,ASSIGN,0,0,0,0) + "term2/term1" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "nr1" + sl(GEN,ASSIGN,0,0,0,0) + " c(last_no-1)*rm0 - glob__2*c(last_no-2)*rm1 + c(last_no-3)*rm2" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "nr2" + sl(GEN,ASSIGN,0,0,0,0) + " c(last_no-2)*rm1 - glob__2*c(last_no-3)*rm2 + c(last_no-4)*rm3" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "dr1" + sl(GEN,ASSIGN,0,0,0,0) + " glob__m1/rm1 + glob__2/rm2 - glob__1/rm3" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "dr2" + sl(GEN,ASSIGN,0,0,0,0) + " glob__m1/rm2 + glob__2/rm3 - glob__1/rm4" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "ds1" + sl(GEN,ASSIGN,0,0,0,0) + " glob__3/rm1 - glob__8/rm2 + glob__5/rm3" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "ds2" + sl(GEN,ASSIGN,0,0,0,0) + " glob__3/rm2 - glob__8/rm3 + glob__5/rm4" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "if ((float_abs(nr1 * dr2 - nr2 * dr1) " + sl(GEN,EQUALS,0,0,0,0) +" glob__0) " + sl(GEN,L_OR,0,0,0,0) + " (float_abs(dr1)" + sl(GEN,EQUALS,0,0,0,0) + "glob__0)) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "rad_c" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "ord_no" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
#  term + dr1*dr2 added to Manuel Prieto"s analysis
#if GEN ==RUBY_APFP then 
#  $atsfile.puts "zchk" + sl(GEN,ASSIGN,0,0,0,0) + " (nr1*dr2 - nr2 * dr1)" + sl(GEN,LINESEP,0,0,0,0)
#  $atsfile.puts "if (zchk.mant != 0) " + sl(GEN,THEN,0,0,0,0)
#else
if GEN != RUBY_APFP then
  $atsfile.puts "if (float_abs(nr1*dr2 - nr2 * dr1) > glob__0) " + sl(GEN,THEN,0,0,0,0)
else
  $atsfile.puts "if (" + sl(GEN,L_NOT,0,0,0,0) + "(nr1*dr2 - nr2 * dr1).maybe_zero)" + sl(GEN,THEN,0,0,0,0)
end
#end
$atsfile.puts "rcs" + sl(GEN,ASSIGN,0,0,0,0) + " ((ds1*dr2 - ds2*dr1 +dr1*dr2)/(nr1*dr2 - nr2 * dr1))" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,REM,"(Manuels)  rcs " + sl(GEN,ASSIGN,0,0,0,0) + " (ds1*dr2 - ds2*dr1)/(nr1*dr2 - nr2 * dr1)",0,0,0)
$atsfile.puts "ord_no" + sl(GEN,ASSIGN,0,0,0,0) + " (rcs*nr1 - ds1)/(glob__2*dr1) -c(last_no)/glob__2" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "if (float_abs(rcs) " + sl(GEN,NOTEQUALS,0,0,0,0) + "glob__0) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "if (rcs > glob__0) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "rad_c " + sl(GEN,ASSIGN,0,0,0,0) + " sqrt(rcs) * float_abs(glob_h)" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "rad_c " + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "ord_no" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "rad_c" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "ord_no" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "rad_c" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "ord_no" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "rad_c" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "ord_no" + sl(GEN,ASSIGN,0,0,0,0) + " glob_larger_float" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "glob_six_term_ord_save" + sl(GEN,ASSIGN,0,0,0,0) + " ord_no" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"rad_c",0,0,0)
$atsfile.puts sl(GEN,REM,"BOTTOM SIX TERM RADIUS ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
########################################################################################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "comp_ord_from_six_terms" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "term1," + st2(FLOAT) + "term2," + st2(FLOAT) + "term3," + st2(FLOAT) + "term4," + st2(FLOAT) + "term5," + st2(FLOAT) + "term6," + st2(INTEGER) + "last_no) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_six_term_ord_save;",0,0)
$atsfile.puts sl(GEN,REM,"TOP SIX TERM ORDER ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,REM,"TOP SAVED FROM SIX TERM RADIUS ANALYSIS",0,0,0)

$atsfile.puts sl(GEN,RETURN,"glob_six_term_ord_save",0,0,0)
$atsfile.puts sl(GEN,REM,"BOTTOM SIX TERM ORDER ANALYSIS",0,0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
####################################################################

########################################################
#
# The following added to avoid repeated calculations. Maple does this
# internally but Maxima does not.
#
####################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "factorial_2" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(INTEGER) + "nnn) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[ ret],float]),",0,0)
if GEN == MAPLE then
$atsfile.puts "ret := nnn!" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"ret",0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
elsif GEN == MAXIMA then
$atsfile.puts "ret : nnn!" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"ret",0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
else 
$atsfile.puts "if (nnn > 0) " + sl(GEN,THEN,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"nnn * factorial_2(nnn - 1)",0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"1.0",0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)
end
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
####################################################################

$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "factorial_1" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(INTEGER) + "nnn) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global ATS_MAX_TERMS,array_fact_1;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[ ret],float]),",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret;",0,0)
$atsfile.puts "if (nnn <= ATS_MAX_TERMS)" + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "if (array_fact_1" + sl(GEN,SUBSC1,"nnn",0,0,0) + sl(GEN,EQUALS,0,0,0,0) + "0)" + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "factorial_2(nnn)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "array_fact_1" + sl(GEN,SUBSC1,"nnn",0,0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ret"  + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "array_fact_1" + sl(GEN,SUBSC1,"nnn",0,0,0) + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "factorial_2(nnn)" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"ret",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)

########################################################################
if GEN == MAXIMA then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "factorial_1" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(INTEGER) + "in) " + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[ ret],float]),",0,0)
  $atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "(in!)" + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts sl(GEN,RETURN,"ret",0,0,0)
  $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "neg" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(FLOAT) + "in) " + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([[ ret],float]),",0,0)
  $atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "(-in)" + sl(GEN,LINESEP,0,0,0,0)
  $atsfile.puts sl(GEN,RETURN,"ret",0,0,0)
  $atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
end
########################################################################
$atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "factorial_3" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(INTEGER) + "mmm," + st2(INTEGER) + "nnn) " + sl(GEN,FUNSEP2,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global ATS_MAX_TERMS,array_fact_2;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block(modedeclare([ [ret],float]),",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,st2(FLOAT) + " ret;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CCC,st2(FLOAT) + " ret;",0,0)
$atsfile.puts "if ((nnn <= ATS_MAX_TERMS) " + sl(GEN,L_AND,0,0,0,0) + " (mmm <= ATS_MAX_TERMS))" + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "if (array_fact_2" + sl(GEN,SUBSC2,"mmm","nnn",0,0) + sl(GEN,EQUALS,0,0,0,0) + "0)" + sl(GEN,THEN,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "factorial_1(mmm)/factorial_1(nnn)" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "array_fact_2" + sl(GEN,SUBSC2,"mmm","nnn",0,0) + sl(GEN,ASSIGN,0,0,0,0) + "ret"  + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "array_fact_2" + sl(GEN,SUBSC2,"mmm","nnn",0,0) + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,ELSE,0,0,0,0)
$atsfile.puts "ret" + sl(GEN,ASSIGN,0,0,0,0) + "factorial_2(mmm)/factorial_2(nnn)" + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,FI,0,0,0,0)  + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"ret",0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)
########################################################################
if GEN == RUBY or GEN == MAPLE or GEN == RUBY_APFP then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "convfloat" + sl(GEN,FUNSEP1,0,0,0,0) + "(" + st2(INTEGER) + "mmm) " + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,MAPLE,"(mmm);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,RUBY,"return(mmm.to_f)",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,RUBY_APFP,"return(mmm.to_f)",0,0)
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
end
########################################################################
if GEN == MAPLE or GEN == RUBY or GEN == RUBY_APFP then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "elapsed_time_seconds" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,MAPLE,"time();",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,RUBY,"t = Time.now",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,RUBY,"return(t.to_i)",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,RUBY_APFP,"t = Time.now",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,RUBY_APFP,"return(t.to_i)",0,0)
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
end
if GEN == MAPLE then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "float_abs" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,MAPLE,"abs(x);",0,0)
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "expt" + sl(GEN,FUNSEP1,0,0,0,0) + "(x,y)" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,MAPLE,"x^y;",0,0)
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "neg" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,MAPLE,"-x;",0,0)
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "int_trunc" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,MAPLE,"trunc(x);",0,0)
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
end
####################################################################
if GEN == MAXIMA  then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "log10" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "(log(x)/glob_log_10)"
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "c" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "x"
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "expt" + sl(GEN,FUNSEP1,0,0,0,0) + "(x,y)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "if (y = 0.0)" + sl(GEN,THEN,0,0,0,0)
  $atsfile.puts "1.0"
  $atsfile.puts sl(GEN,ELSEIF,0,0,0,0)
  $atsfile.puts "((x <= 0.0) and (y < 0.0))" + sl(GEN,THEN,0,0,0,0)
  $atsfile.puts 'print("expt error x = ",x,"y = ",y)'
  $atsfile.puts sl(GEN,ELSE,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts "(x^y)"
  $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINEEND,0,0,0,0)
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
end
if GEN == RUBY  then
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "expt" + sl(GEN,FUNSEP1,0,0,0,0) + "(x,y)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "if ((x <= 0.0) and (y < 0.0))" + sl(GEN,THEN,0,0,0,0)
  $atsfile.puts 'puts "expt error x = " + x.to_s + "y = " + y.to_s'
  $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

  $atsfile.puts "return(x**y)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "Si" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(0.0)" # not avail in Ruby
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "Ci" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(0.0)" # not avail in Ruby
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "float_abs" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(x.abs)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "int_abs" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(x.abs)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "exp" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.exp(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "int_trunc" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(x.to_i)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "floor" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(x.floor)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "round" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(x.round)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "sin" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.sin(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "neg" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(-x)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cos" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.cos(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "tan" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.tan(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arccos" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.acos(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arccosh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.acosh(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arcsin" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.asin(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arcsinh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.asinh(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arctan" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.atan(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arctanh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.atanh(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cosh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.cosh(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "erf" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.erf(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "log" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.log(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "ln" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.log(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "log10" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.log10(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "sinh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.sinh(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "tanh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.tanh(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "sqrt" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(Math.sqrt(x))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
elsif GEN == RUBY_APFP  then
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "expt" + sl(GEN,FUNSEP1,0,0,0,0) + "(x,y)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "if ((c(x) <= glob__0) and (c(y) < glob__0))" + sl(GEN,THEN,0,0,0,0)
  $atsfile.puts 'puts "expt error x = " + x.to_s + "y = " + y.to_s'
  $atsfile.puts sl(GEN,FI,0,0,0,0) + sl(GEN,LINESEP,0,0,0,0)

  $atsfile.puts "return(c(x)**c(y))"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "Si" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(0.0)" # not avail in Ruby
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "Ci" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(0.0)" # not avail in Ruby
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "float_abs" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).abs)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "int_abs" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).abs)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "exp" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).exp)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "int_trunc" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).to_i)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "floor" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).floor)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "sin" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).sin)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "neg" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).neg)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cos" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).cos)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "tan" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).tan)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arccos" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).acos)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arccosh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).acosh)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arcsin" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).asin)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arcsinh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).asinh)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arctan" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).atan)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "arctanh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).atanh)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "cosh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).cosh)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "erf" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).erf)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "log" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).log)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "ln" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).log)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "log10" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).log10)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "sinh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).sinh)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "tanh" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).tanh)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "sqrt" + sl(GEN,FUNSEP1,0,0,0,0) + "(x)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "return(c(x).sqrt)"
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#################################################
elsif GEN == CCC || GEN == CPP  then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "neg" + sl(GEN,FUNSEP1,0,0,0,0) + "(double in)" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"double out;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"out = -in;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"return(out);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"double out;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"out = -in;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"return(out);",0,0)
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
#######################################
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "frac" + sl(GEN,FUNSEP1,0,0,0,0) + "(double in)" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"double out;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"out = in - trunc(in);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"return(out);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"double out;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"out = in - trunc(in);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"return(out);",0,0)
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  ########################################################################
  $atsfile.puts sl(GEN,FUNDEF,INTEGER,0,0,0) + "int_trunc" + sl(GEN,FUNSEP1,0,0,0,0) + "(double in)" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"int out;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"out = (int)trunc(in);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"return(out);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"int out;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"out = (int)trunc(in);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"return(out);",0,0)
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  ########################################################################
  $atsfile.puts sl(GEN,FUNDEF,LONG,0,0,0) + "elapsed_time_seconds" + sl(GEN,FUNSEP1,0,0,0,0) + "()" + sl(GEN,FUNSEP2,0,0,0,0) 
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"struct timeval t;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"struct timezone tz;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"gettimeofday(&t,&tz);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"struct timeval t;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"struct timezone tz;",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"gettimeofday(&t,&tz);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CCC,"return (t.tv_sec);",0,0)
  $atsfile.puts sl(GEN,SPECIFIC,CPP,"return (t.tv_sec);",0,0)
  $atsfile.puts sl(GEN,FUNEND,0,0,0,0)
  ########################################################################
end
if GEN == RUBY or GEN == RUBY_APFP then
  $atsfile.puts sl(GEN,FUNDEF,VOID,0,0,0) + "array2d" + sl(GEN,FUNSEP1,0,0,0,0) + "(op3,op4)" + sl(GEN,FUNSEP2,0,0,0,0)
  $atsfile.puts "i = 0"
  $atsfile.puts "x1 = Array.new(op3.to_i + 1)"
  $atsfile.puts "while i <= op3.to_i + 1 " + sl(GEN,DO,0,0,0,0)
  $atsfile.puts "x1[i] = Array.new(op4.to_i + 1)"
  $atsfile.puts "i += 1"
  $atsfile.puts sl(GEN,OD,0,0,0,0)
  $atsfile.puts "return x1"
  $atsfile.puts  sl(GEN,FUNEND,0,0,0,0)
end


if GEN == CCC or GEN == CPP then
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "estimated_needed_step_error" + sl(GEN,FUNSEP1,0,0,0,0) + "(double x_start,double x_end,double estimated_h,double estimated_answer)" + sl(GEN,FUNSEP2,0,0,0,0)
else
  $atsfile.puts sl(GEN,FUNDEF,FLOAT,0,0,0) + "estimated_needed_step_error" + sl(GEN,FUNSEP1,0,0,0,0) + "(x_start,x_end,estimated_h,estimated_answer)" + sl(GEN,FUNSEP2,0,0,0,0)
  
end
get_temp()
$atsfile.puts sl(GEN,SPECIFIC,CCC,"double desired_abs_gbl_error,range,estimated_steps,step_error;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,CPP,"double desired_abs_gbl_error,range,estimated_steps,step_error;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"local desired_abs_gbl_error,range,estimated_steps,step_error;",0,0)      
$atsfile.puts sl(GEN,SPECIFIC,MAPLE,"global glob_desired_digits_correct,ALWAYS,ATS_MAX_TERMS;",0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,"block ([ desired_abs_gbl_error,range,estimated_steps,step_error],",0,0)
$atsfile.puts 'omniout_float(ALWAYS,"glob_desired_digits_correct",32,glob_desired_digits_correct,32,"")'  + sl(GEN,LINESEP,0,0,0,0)

$atsfile.puts "desired_abs_gbl_error" + sl(GEN,ASSIGN,0,0,0,0) + "expt(glob__10,c( -glob_desired_digits_correct)) * c(float_abs(c(estimated_answer)))" + sl(GEN,LINESEP,0,0,0,0) 
$atsfile.puts 'omniout_float(ALWAYS,"estimated_h",32,estimated_h,32,"")'  + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts 'omniout_float(ALWAYS,"estimated_answer",32,estimated_answer,32,"")'  + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts 'omniout_float(ALWAYS,"desired_abs_gbl_error",32,desired_abs_gbl_error,32,"")'  + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "range" + sl(GEN,ASSIGN,0,0,0,0) + "(x_end - x_start)" + sl(GEN,LINESEP,0,0,0,0) 
$atsfile.puts 'omniout_float(ALWAYS,"range",32,range,32,"")'  + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "estimated_steps" + sl(GEN,ASSIGN,0,0,0,0) + "range / estimated_h"  + sl(GEN,LINESEP,0,0,0,0) 
$atsfile.puts 'omniout_float(ALWAYS,"estimated_steps",32,estimated_steps,32,"")'  + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts "step_error" + sl(GEN,ASSIGN,0,0,0,0) + "(c(float_abs(desired_abs_gbl_error) /sqrt(c( estimated_steps)" + $token_no.to_s + ")/c(ATS_MAX_TERMS)))" + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts 'omniout_float(ALWAYS,"step_error",32,step_error,32,"")' + sl(GEN,LINESEP,0,0,0,0)
$atsfile.puts sl(GEN,RETURN,"(step_error)",0,0,0)  + sl(GEN,LINEEND,0,0,0,0)
$atsfile.puts sl(GEN,SPECIFIC,MAXIMA,")",0,0)
$atsfile.puts sl(GEN,FUNEND,0,0,0,0)





$atsfile.close
