################################################################## ###
#
#	File:     Ap.rb
#
#	Subject:  Main Methods for arbitrary precision.
#
#	Author:   Dennis J. Darland
#
#	Date:     April 2, 2007
#
############################################################################
#
#    Copyright (C) 2007 Dennis J. Darland#
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
############################################################################
# if NUM_DIGITS <= 12 then
# 3/1/2015 - changed next line from require "rapfp/Real"
# require_relative "Real"
# Apfp_Mode = 0
# $Ap = Real
# $ApConst = RealConst
# else
# 3/1/2015 changed next line from require "rafp/Apfp"
require_relative "Apfp"
Apfp_Mode = 1
$Ap = Apfp
$ApConst = ApfpConst
# end

def ap_in(str)
  str = str.to_s
  str = elim_b(str)
  found = 0
  f_mant_re1 = Regexp.new("^-?[0-9]+\.[0-9]+")
  f_mant_re2 = Regexp.new("^-?[0-9]+")
  if str =~ f_mant_re1
    mant = "#{$&}"
    rest = "#{$'}"
    found = 1
  elsif str =~ f_mant_re2
    mant = "#{$&}" + ".0"
    rest = "#{$'}"
    found = 1
  end
  if found == 1 then
    restsav = rest.clone
    if rest != "" && rest[0].chr != "+" then
      f_sep_re = Regexp.new("^e|E")
      if rest =~ f_sep_re
        rest = "#{$'}"
        restsav = rest.clone
        f_expt_re = Regexp.new("^[-+]?[0-9]+")
        if rest =~ f_expt_re
          expt = "#{$&}"
          rest = "#{$'}"
        else 
          bad = Apfp.new(0,0,50,-DESIRED_DIGITS)
          bad.set_error_flag("ap_in: Bad input string 1")
          return bad
        end
      else
        expt = "0"
        rest = restsav
      end
    else
      expt = "0"
      rest = restsav
    end
    
    if rest != ""
      f_sep_err_re = Regexp.new("^\\+/-")
      if rest =~ f_sep_err_re
        rest = "#{$'}"
        f_mant_err_re = Regexp.new("^-?[0-9]+\.[0-9]+")
        if rest =~ f_mant_err_re
          mant_err = "#{$&}"
          rest = "#{$'}"
          if rest != ""
            f_sep_re = Regexp.new("^e|E")
            if rest =~ f_sep_re
              rest = "#{$'}"
              f_expt_err_re = Regexp.new("^[-+]?[0-9]+")
              if rest =~ f_expt_err_re
                expt_err = "#{$&}"
              else 
                bad = Apfp.new(0,0,50,-DESIRED_DIGITS)
                bad.set_error_flag("ap_in: Bad input string 2")
                return bad
              end
            else
              expt_err = "0"
            end
          else
            expt_err = "0"
          end
        else
          bad = Apfp.new(0,0,50,-DESIRED_DIGITS)
          bad.set_error_flag("ap_in: Bad input string 3")
          return bad
        end
      else
        bad = Apfp.new(0,0,50,-DESIRED_DIGITS)
        bad.set_error_flag("ap_in: Bad input string 4")
        return bad
      end
    else
      mant_err = "0"
      expt_err = "0"
    end
    if Apfp_Mode == 0  # built in floats
      if mant_err == "0"
        return $Ap.new("#{mant}e#{expt}".to_f,"#{mant}e#{expt}".to_f*Float::EPSILON)
      else
        return $Ap.new("#{mant}e#{expt}".to_f,"#{mant_err}e#{expt_err}".to_f)
      end
    else #Apfp floats
      mant = mant.to_s
      rmant = mant.reverse
      if rmant =~ /^[0-9]*\./
        cnt = "#{$&}".size
        mant.sub!(/\./,"")
        expt = expt.to_i - cnt + 1
      elsif  rmant =~ /^[0-9]*/
        #do nothing
      else
        bad = Apfp.new(0,0,50,-DESIRED_DIGITS)
        bad.set_error_flag("ap_in: Bad input string 5")
        return bad
      end
      if mant_err != "0"
        rmant = mant_err.reverse
        if rmant =~ /^[0-9]*\./
          cnt = "#{$&}".size
          mant_err.sub!(/\./,"")
          expt_err = expt_err.to_i - cnt + 1
        else
          bad = Apfp.new(0,0,50,-DESIRED_DIGITS)
          bad.set_error_flag("ap_in: Bad input string 6")
          return bad
        end
      end
      #     puts "Ap.rb mant = #{mant} expt = #{expt.to_s} err = #{mant_err} expt_err = #{expt_err}"
      if mant_err == "0"
        return Apfp.new(mant.to_i,expt.to_i,50,-DESIRED_DIGITS+expt.to_i+mant.to_s.size).norm
      else
        return Apfp.new(mant.to_i,expt.to_i,mant_err.to_i,expt_err.to_i).norm
      end
    end
  else
    bad = Apfp.new(0,0,50,-DESIRED_DIGITS)
    bad.set_error_flag("ap_in: Bad input string 7")
    return bad
  end
end
def elim_b(str)
  out = ""
  len = str.size
  pos = 0
  while pos < len do
    if str[pos].chr != " " then
#      puts "out = " + out.to_s
#      puts "str = " + str.to_s
#      puts "pos = " + pos.to_s
      out = out + str[pos].chr
    end
    pos += 1
  end
return out
end
def ap_int(v)
  if Apfp_Mode == 0
    c0(Real.new(v.to_f,v*Float::EPSILON))
  else
    if v >= 0 then
      Apfp.new(v.to_i,0,50,(((v.to_i).to_s).size)-DESIRED_DIGITS).norm
    else
      Apfp.new(v.to_i,0,50,((((-v).to_i).to_s).size)-DESIRED_DIGITS).norm
    end
  end
end

# now returns error same as c (not sure if is should - used in Sode.rb for
# increment etc which in a way cannot have error.
def c0(val)

  unless val.kind_of?(Fixnum) || val.kind_of?(Integer)
    v = val.to_s
    return(ap_in(v))
  else
    return ap_int(val)
  end
end
def c(val)
#  $stderr.puts " in c val = " + val.to_s
  unless val.kind_of?(Apfp)
    unless val.kind_of?(Fixnum) || val.kind_of?(Integer)
      v = val.to_s
      return(ap_in(v))
    else
      return ap_int(val)
    end
  else
    return val
  end
end
def ap_min(a,b)
  if a < b then
    return a
  else 
    return b
  end
end
def ap_max(a,b)
  if a > b then
    return a
  else 
    return b
  end
end

def do_error_report(str)
  if ERROR_REPORTING == CAUSE_DIV_BY_ZERO then
    puts str
    1/0
  elsif ERROR_REPORTING == BAD_STRING_FOR_RAILS then
    return "BAD"
  elsif ERROR_REPORTING == MESSAGE_ONLY and RAILS_MODE == 1 then
    puts str
  elsif ERROR_REPORTING == MESSAGE_ONLY then
    # do nothing
  elsif ERROR_REPORTING == FLAG_ONLY then
    # do nothing
  else
    puts "BAD CASE IN do_error_report"
    1/0
  end
end
def est_good_digits(val)
    if val.error_flag then
      return "BAD"
    end
    if val.mant < 0 then 
      mant = -val.mant
      s1 = val.mant.to_s.size - 1
    else
      mant = val.mant
      s1 = val.mant.to_s.size
    end
    if val.errmant < 0 then 
      errmant = -val.errmant
      s2 = val.errmant.to_s.size - 1
    else
      errmant = val.errmant 
      s2 = val.errmant.to_s.size
    end
    
    return ((val.expt+s1) - (val.errexpt+s2))
end
def est_expt(val)
    if val.error_flag then
      return "BAD"
    end
    if val.mant.to_i < 0 then 
      mant = -val.mant.to_i
      s1 = val.mant.to_s.size - 1
    else
      mant = val.mant.to_i
      s1 = val.mant.to_s.size
    end
    return (val.expt.to_i+s1.to_i-1)
end

# changed next line from require "rapfp/Apc"
require_relative "Apc"


