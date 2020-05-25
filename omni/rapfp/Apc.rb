################################################################## ###
#
#	File:     Apc.rb
#
#	Subject:  Class for arbitrary precision complex.
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
class Apc
  #
  #  @re is real comonent
  #  @im is imaginary component
  def initialize(re,im)
    @re = re
    @im = im
    if re.error_flag or im.error_flag then
      @c_error_flag = true
    else
      @c_error_flag = false
    end
  end
  def re
    @re
  end
  def im
    @im
  end
  def c_error_flag
    @c_error_flag or @re.error_flag or @im.error_flag
  end
  def set_c_error_flag(str)
    @c_error_flag = true
    if RAILS_MODE == 0 then
      display_val("offending value")
    end
    do_error_report(str)
  end
    
  def setcconst(c)
    @@cconst = c
  end
  def setrconst(c)
    @@rconst = c
  end
  def neg
    Apc.new(@re.neg,@im.neg)
  end
  def to_s
    if c_error_flag then
      "BAD"
    elsif @im.mant >=0 then
      "#{@re.to_s} + #{@im.to_s}I"
    else
      "#{@re.to_s} - #{@im.neg.to_s}I"
    end
  end
  def display_val(label)
    if RAILS_MODE == 0 then
      puts label + " = " + self.to_s
    end
  end
  def +(other)
    if self.c_error_flag || other.c_error_flag then
      do_error_report("BAD in +")
    end
    
    Apc.new(@re+other.re,@im+other.im)
  end
  def -(other)
    if self.c_error_flag || other.c_error_flag then
      do_error_report("BAD in -")
    end
    Apc.new(@re-other.re,@im-other.im)
  end
  def *(other)
    if self.c_error_flag || other.c_error_flag then
      do_error_report("BAD in *")
    end

    Apc.new(@re*other.re-@im*other.im,@im*other.re+@re*other.im)
  end
  def /(other)
    if self.c_error_flag || other.c_error_flag then
      do_error_report("BAD in /")
    end

    de = other.re * other.re + other.im * other.im
    if de.maybe_zero then
      a = self.clone
      a.set_c_error_flag("BAD /: division by zero")
      return a
    end
    Apc.new((@re * other.re + @im * other.im)/de ,(@im * other.re - @re * other.im)/de)
  end
  def ==(other)
    if self.c_error_flag || other.c_error_flag then
      do_error_report("BAD in ==")
    end

    (@re == other.re) && (@im == other.im)
  end
   def eq(other)
    if self.c_error_flag || other.c_error_flag then
      do_error_report("BAD in eq")
    end
     (@re.eq(other.re)) && (@im.eq(other.im))
   end
   def abs
    if self.c_error_flag then
      do_error_report("BAD in abs")
    end

    if self == @@cconst.zero
      return @@rconst.zero
    end
    (@re * @re + @im * @im).sqrt
  end
  def exp
    if self.c_error_flag then
      do_error_report("BAD in exp")
    end

    w = @re.exp
    Apc.new(w * @im.cos,w * @im.sin)
  end
  def sin
    if self.c_error_flag then
      do_error_report("BAD in sin")
    end

    y1 = (self * @@cconst.i).exp
    y2 = (self * @@cconst.minus_i).exp
    (y1-y2) / @@cconst.two_i
  end
  def cos
    if self.c_error_flag then
      do_error_report("BAD in cos")
    end
    y1 = (self * @@cconst.i).exp
    y2 = (self * @@cconst.minus_i).exp
    (y1+y2) / @@cconst.two
  end
  def tan
    if self.c_error_flag then
      do_error_report("BAD in tan")
    end
    self.sin/self.cos
  end
  def sinh
    if self.c_error_flag then
      do_error_report("BAD in sinh")
    end

    y1 = self.exp
    y2 = (self * @@cconst.minus_one).exp
    (y1-y2) / @@cconst.two
  end
  def cosh
    if self.c_error_flag then
      do_error_report("BAD in cosh")
    end

    y1 = self.exp
    y2 = (self * @@cconst.minus_one).exp
    (y1+y2) / @@cconst.two
  end
  def tanh
    if self.c_error_flag then
      do_error_report("BAD in tanh")
    end

    self.sinh/self.cosh
  end
  def log
    if self.c_error_flag then
      do_error_report("BAD in log")
    end

    dd = self.abs
# puts "cx log dd = " + dd.to_s
    if dd > @@rconst.zero then
      lg = dd.log
# puts "cx log lg = dd.log = " + lg.to_s
    else
      lg = self.clone
      lg.set_c_error_flag("BAD log: log of zero") #really error!
      return lg
    end
    if self.re == @@rconst.zero then 
      if self.im > @@rconst.zero then 
        ang = @@rconst.pi/@@rconst.two
      else  
        ang = @@rconst.pi/@@rconst.minus_two 
      end
    else 
      ang = self.calc_lg_ang 
    end
    return Apc.new(lg,ang)
  end
  def calc_lg_ang
    if self.c_error_flag then
      do_error_report("BAD in calc_lg_ang")
    end

    if @re >= @@rconst.zero && @im >= @@rconst.zero then
	return (@im / @re).atan
    elsif @re >= @@rconst.zero && @im < @@rconst.zero then
	return (@im / @re).atan
    elsif @re <= @@rconst.zero && @im >= @@rconst.zero then
        return @@rconst.pi + (@im / @re).atan
    else 
        return @@rconst.pi * @@rconst.minus_one + (@im / @re).atan
    end
  end
  def log10
    if self.c_error_flag then
      do_error_report("BAD in log10")
    end
    dd = self.abs
    if dd > @@rconst.zero then
      lg = self.log/@@cconst.ten.log
    else
      lg = self.clone
      lg.set_c_error_flag("BAD log: log of zero") #really error!
      return lg
    end
    return lg
  end
  def **(other)
    if self.c_error_flag || other.c_error_flag then
      do_error_report("BAD in **")
    end

    a = self.clone

    unless other.kind_of?(Apc) #other is integer
      b = @@cconst.one
      if other > 0 then
        other.times do
          b = b.clone * a
        end
      elsif other < 0 then
        (-other).times do
          b = b.clone * a
        end
        b = @@cconst.one/b.clone
      end
      return b
    else
      if other == @@cconst.zero then
        return @@cconst.one
      elsif other == @@cconst.one then
        return a
      elsif a == @@cconst.zero then
        return a
      elsif
        a == @@cconst.one then
        return a
      else
        lg = a.log
        lgt = lg * other
        b = lgt.exp
        return b
      end
    end 
  end
  def sqrt
    if self.c_error_flag then
      do_error_report("BAD in sqrt")
    end

    self ** @@cconst.half
  end
#  def **(other)
#    a = self.clone
#    unless other.kind_of?(Apc)
#      b = @@cconst.one.clone
#      if other > 0 then
#        other.times do
#          b = a * b.clone
#        end
#        return b
#      elsif other < 0
#        (-other).times do
#          b = a * b.clone
#        end
#        c = @@cconst.one.clone/b.clone
#        return c
#      end
#      return b
#    else
#      b = other
#      if b == (@@cconst.zero) then return @@cconst.one end
#      if b == @@cconst.one then return a end
#      if a == @@cconst.zero then return @@cconst.zero end
#      return (a.log*b).exp
#    end
#  end
  def asin
    if self.c_error_flag then
      do_error_report("BAD in ssin")
    end

#    if self.abs < c(0.000001) then
#      return self
#    end
    @@cconst.minus_i * (@@cconst.i * self+(@@cconst.one - self*self).sqrt).log
  end
  def acos
    if self.c_error_flag then
      do_error_report("BAD in acos")
    end

    Apc.new(@@rconst.pi / @@rconst.two,@@rconst.zero) - self.asin
  end
  def atan
    if self.c_error_flag then
      do_error_report("BAD in atan")
    end
#    if self.abs < c(0.000001) then
#      return self
#    end
    (@@cconst.i / @@cconst.two) * ((@@cconst.one - self * @@cconst.i).log - (@@cconst.one + self * @@cconst.i).log)
  end
  def asinh
    if self.c_error_flag then
      do_error_report("BAD in asinh")
    end

    (self + (self * self + @@cconst.one).sqrt).log
  end
  def acosh
    if self.c_error_flag then
      do_error_report("BAD in acosh")
    end

    (self + (self * self - @@cconst.one).sqrt).log
  end
  def atanh
    if self.c_error_flag then
      do_error_report("BAD in atanh")
    end

    @@cconst.half * ((@@cconst.one + self).log - (@@cconst.one - self).log)
  end
end #class Apc
class ApcConst
  def initialize(rConst)
    @ZERO = Apc.new(rConst.zero,rConst.zero)
    @ONE = Apc.new(rConst.one,rConst.zero)
    @TWO = Apc.new(rConst.two,rConst.zero)
    @TEN = Apc.new(rConst.ten,rConst.zero)
    @HALF = Apc.new(rConst.half,rConst.zero)
    @I = Apc.new(rConst.zero,rConst.one)
    @MINUS_I = Apc.new(rConst.zero,rConst.minus_one)
    @MINUS_ONE = Apc.new(rConst.minus_one,rConst.zero)
    @TWO_I = Apc.new(rConst.zero,rConst.two)
  end #initialize
  def zero
    @ZERO
  end
  def one
    @ONE
  end
  def two
    @TWO
  end
  def i
    @I
  end
  def minus_i
    @MINUS_I
  end
  def minus_one
    @MINUS_ONE
  end
  def two_i
    @TWO_I
  end
  def ten
    @TEN
  end
  def half
    @HALF
  end
end #ApcConst
