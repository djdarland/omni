####################################################################### ###
#
#	File:     Real.rb
#
#	Subject:  Class for built in floating point tracking error.
#
#	Author:   Dennis J. Darland
#
#	Date:     March 30, 2007
#
############################################################################
#
#    Copyright (C) 2007 Dennis J. Darland
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
class Real
  def initialize(val,err)
    @val = val
    @err = err.abs
  end
  def setrconst(c)
    @@rconst = c
  end
  def to_s
    v2 = @val
    e2 = @err
    valout2 = sprintf("%24.16e",v2)
    errout2 = sprintf("%11.2e",e2)
    str = (valout2 + "+/-" + errout2)
    str = elim_b(str)
    return str
  end
  def to_f
    return @val
  end
  def val
    @val
  end
  def err
    @err
  end
  def +(other)
    Real.new((@val+other.val),(@err+other.err).abs)
  end
  def -(other)
    Real.new((@val-other.val),(@err+other.err).abs)
  end
  def *(other)
    Real.new((@val * other.val), (@err * other.val.abs + other.err * @val.abs).abs )
  end
  def /(other)
    Real.new((@val / other.val),(@err / other.val.abs + @val.abs * other.err / (other.val * other.val)).abs)
  end
  def neg
    a = self.clone 
    return Real.new(-a.val,a.err.abs)
  end
  def **(other)
    a = self.clone
    unless other.kind_of?(Real)
      b = @@rconst.one
      if other > 0 then
        other.times do
          b *= a
        end
      elsif other < 0
        (-other).times do
          b *= a
        end
        b = @@rconst.one/b
      end
    else
      b = Real.new((@val ** other.val),(other.val.abs * @val ** (other.val - 1.0) * @err))
    end
    return b
  end  
  def lt(other)
    @val < other.val
  end
  def gt(other)
    @val > other.val
  end
  def le(other)
    @val <= other.val
  end
  def ge(other)
    @val >= other.val
  end
  def eq(other)
    @val == other.val
  end
  def ne(other)
    @val != other.val
  end
  def <(other)
    (@val + @err) < (other.val - other.err)
  end
  def >(other)
    (@val - @err) > (other.val + other.err)
  end
  def <=(other)
    (@val + @err) <= (other.val - other.err)
  end
  def >=(other)
    (@val - @err) >= (other.val + other.err)
  end
  def ==(other)
    (@val >= other.val) && (@val <= other.val)
  end
  def sin
    Real.new(Math.sin(@val),(Math.cos(@val)*@err).abs)
  end
  def cos
    Real.new(Math.cos(@val),(Math.sin(@val)*@err).abs)
  end
  def tan
    self.sin/self.cos
  end
  def exp
    Real.new(Math.exp(@val),(Math.exp(@val)*@err).abs)
  end
  def sqrt
    Real.new(Math.sqrt(@val),(0.5/Math.sqrt(@val)*@err).abs)
  end
  def display_val(str)
    if RAILS_MODE == 0 then
      puts str + " = " + self.to_s
    end
  end
  def log
    if self <= @@rconst.zero then
      if RAILS_MODE == 0 then
        puts "log out of range"
        self.display_val("self")
      end
      return "BAD"
    end
    Real.new(Math.log(@val),(@err/@val).abs)
  end
  def log10
    if self <= @@rconst.zero then
      if RAILS_MODE == 0 then
        puts "log10 out of range"
        self.display_val("self")
      end
      return "BAD"
    end
    Real.new(Math.log10(@val),(@err/@val).abs)
  end
  def about_log10
    self.log10
  end
  def sinh
    Real.new(Math.sinh(@val),(Math.cosh(@val)*@err).abs)
  end
  def cosh
    Real.new(Math.cosh(@val),(Math.sinh(@val)*@err).abs)
  end
  def tanh
    self.sinh/self.cosh
  end
  def asin
    if self.abs > @@rconst.one then
      if RAILS_MODE == 0 then
        puts "asin out of range"
        self.display_val("self")
      end
      return "BAD"
    end
    Real.new(Math.asin(@val),(@err/Math.sqrt(1.0-@val*@val)).abs)
  end
def abs
  a = self.clone
  if a.val < 0.0
    b = a.neg
  else
    b = a
  end
  return b
end


  def abs
    Real.new(@val.abs,err)
  end
  def acos
    if self.abs > @@rconst.one then
      if RAILS_MODE == 0 then
        puts "acos out of range"
        self.display_val("self")
      end
      return "BAD"
    end
    Real.new(Math.acos(@val),(@err/Math.sqrt(1.0-@val*@val)).abs)
  end
  def atan
    Real.new(Math.atan(@val),(@err/(1.0+@val*@val)).abs)
  end
  def trunc
    Real.new((@val.floor),@err)
  end
  def frac
    self - self.trunc
  end
  def erf
    Real.new(Math.erf(@val),(2.0/Math.sqrt(Math::PI)*(Math.exp(@val*@val*(-1.0)))).abs)
  end
end
class RealConst
  def initialize
    if RAILS_MODE == 0 then
      puts "Initializing..."
    end
    @zero = Real.new(0.0,Float::EPSILON)
    @one = Real.new(1.0,Float::EPSILON)
    @two = Real.new(2.0,Float::EPSILON)
    @ten = Real.new(10.0,Float::EPSILON)
    @half = Real.new(0.5,Float::EPSILON)
    @minus_one = Real.new(-1.0,Float::EPSILON)
    @minus_two = Real.new(-2.0,Float::EPSILON)
    if RAILS_MODE == 0 then
      puts "Initialized"
    end
  end #initialize
  def init2
    if RAILS_MODE == 0 then
      puts "Initializing(2)..."
    end
    @PI = Real.new(Math::PI,Float::EPSILON)
    @E = @one.exp
    @LOG_E_10 = @ten.log
    @PI.display_val("PI")
    @E.display_val("E")
    @LOG_E_10.display_val("LOG_E_10")
    if RAILS_MODE == 0 then
      puts "Initialized(2)"
    end
  end
  def zero
    @zero
  end
  def one
    @one
  end
  def minus_one
    @minus_one
  end
  def minus_two
    @minus_two
  end
  def two
    @two
  end
  def pi
    @pi
  end
  def ten
    @ten
  end
  def e
    @e
  end
  def half
    @half
  end
end #realconst

