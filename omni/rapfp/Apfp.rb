##################################################################### ###
#
#	File:     Apfp.rb
#
#	Subject:  Class for arbitrary precision floating point.
#
#	Author:   Dennis J. Darland
#
#	Date:     April 3, 2007
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
class Apfp
  public
  #
  #  @mant is mantissa except as a whole number - 
  #  @expt is exponent (of 10)(negative to produce fractions) -
  #  @errmant is mantissa of esimated error (always positive) - 
  #  @errexpt is exponent (of 10) of estimated error -
  #  word.
  def initialize(mant,expt,errmant,errexpt)
    
    @mant = mant
    @expt = expt
    @errmant = errmant.abs
    @errexpt = errexpt
    @error_flag = false
  end #initialize
  
  def errmant=(other)
    @errmant = other.abs
  end
  
  def errexpt=(other)
    @errexpt = other
  end
  def error_flag
    @error_flag
  end
  
  
  def setrconst(c)
    @@rconst = c
  end
  
  
  def set_error_flag(str)
    @error_flag = true
    if RAILS_MODE == 0 then
      display_val("offending value")
    end
    do_error_report(str)
  end
  
  def to_s
    if self.error_flag then
      return "BAD"
    end
    b = self.clone.norm
    if b.mant < 0 then 
      mant = -b.mant
      sign = "-";
      s1 = b.mant.to_s.size - 1
    else
      mant = b.mant
      sign = ""
      s1 = b.mant.to_s.size
    end
    if b.errmant < 0 then 
      errmant = -b.errmant
      errsign = "-";
      s2 = b.errmant.to_s.size - 1
    else
      errmant = b.errmant 
      errsign = ""
      s2 = b.errmant.to_s.size
    end
    
    sign  + "0." + mant.to_s + "e" +(b.expt+s1).to_s + "+/-" + errsign + "0." + errmant.to_s + "e" + (b.errexpt+s2).to_s
  end # to_s
  
  def to_s_main
    b = self.clone.norm
    if b.mant < 0 then 
      mant = -b.mant
      sign = "-";
      s1 = b.mant.to_s.size - 1
    else
      mant = b.mant
      sign = ""
      s1 = b.mant.to_s.size
    end
    if b.errmant < 0 then 
      errmant = -b.errmant
      errsign = "-";
      s2 = b.errmant.to_s.size - 1
    else
      errmant = b.errmant 
      errsign = ""
      s2 = b.errmant.to_s.size
    end
    
    sign  + "0." + mant.to_s + "e" +(b.expt+s1).to_s
  end # to_s_main
  
  def to_s_err
    b = self.clone.norm
    if b.mant < 0 then 
      mant = -b.mant
      sign = "-";
      s1 = b.mant.to_s.size - 1
    else
      mant = b.mant
      sign = ""
      s1 = b.mant.to_s.size
    end
    if b.errmant < 0 then 
      errmant = -b.errmant
      errsign = "-";
      s2 = b.errmant.to_s.size - 1
    else
      errmant = b.errmant 
      errsign = ""
      s2 = b.errmant.to_s.size
    end
    
    "0." + errmant.to_s + "e" + (b.errexpt+s2).to_s
  end # to_s_err
  
  def to_f
    (self.mant * (10 ** self.expt)).to_f
  end # to_f
  
  def mant
    @mant
  end
  def expt
    @expt
  end
  def errmant
    @errmant
  end
  def errexpt
    @errexpt
  end
  def est_good_digits(val)
    return(val.expt - val.errexpt)
  end
  
  def norm
    if @mant == 0 then return Apfp.new(0,-1,@errmant,@errexpt) end 
    mant = @mant.to_s
    errmant = @errmant.to_s
    expt = @expt
    errexpt = @errexpt
    rmant = mant.reverse
    sz = rmant.size
    if sz > NUM_DIGITS then 
      trim = sz - NUM_DIGITS
      mre = Regexp.new("^([0-9]){" + trim.to_s + "}")
      if rmant =~ mre then
        rmant = "#{$'}"
        m_cnt = "#{$&}".size
      else 
        m_cnt = 0
      end
    else
      m_cnt = 0
    end
    
    lz_re = Regexp.new("^0+")
    if rmant =~ lz_re then
      rmant = "#{$'}"
      lz_cnt = "#{$&}".size
    else 
      lz_cnt = 0
    end
    mant = rmant.reverse.to_i
    expt += (lz_cnt + m_cnt)
    # now process error
    rerrmant = errmant.reverse
    sz = rerrmant.size
    if sz > NUM_ERR_DIGITS then 
      trim = sz - NUM_ERR_DIGITS
      mre = Regexp.new("^([0-9]){" + trim.to_s + "}")
      if rerrmant =~ mre then
        rerrmant = "#{$'}"
        m_cnt = "#{$&}".size
      else 
        m_cnt = 0
      end
      lz_re = Regexp.new("^0+")
      if rerrmant =~ lz_re then
        rerrmant = "#{$'}"
        lz_cnt = "#{$&}".size
      else 
        lz_cnt = 0
      end
      errmant = rerrmant.reverse.to_i
      errexpt += (lz_cnt + m_cnt)
    else
      errmant = errmant.to_i
    end
    Apfp.new(mant,expt,errmant,errexpt)
  end # norm
  
  def manttimes10!
    @mant *= 10
    self
  end
  def errmanttimes10!
    @errmant *= 10
    self
  end
  
  def exptadd!(other)
    @expt += other
    self
  end
  
  def errexptadd!(other)
    @errexpt += other
    self
  end
  def display_val(label)
    if RAILS_MODE == 0 then
      puts label + " = " + self.to_s
    end
  end
  
  def display_val_old(label)
    if @mant < 0 then 
      mant = -@mant
      sign = "-";
      s1 = @mant.to_s.size - 1
    else
      mant = @mant
      sign = ""
      s1 = @mant.to_s.size
    end
    if @errmant < 0 then 
      errmant = -@errmant
      errsign = "-";
      s2 = @errmant.to_s.size - 1
    else
      errmant = @errmant 
      errsign = ""
      s2 = @errmant.to_s.size
    end
    if RAILS_MODE == 0 then
      puts "#{label} = #{sign}0.#{mant.to_s}e#{(@expt+s1).to_s}+/-#{errsign}0.#{errmant.to_s}e#{(@errexpt+s2).to_s}"
    end
  end
  
  def neg
    if self.error_flag then
      do_error_report("BAD in neg")
    end
    mant = -1*@mant
    Apfp.new(mant,@expt,@errmant.abs,@errexpt)
  end #neg
  
  def +(other) 
    if self.error_flag || other.error_flag then
      do_error_report("BAD in +")
    end
    a = self.clone
    b = other.clone
    if a.mant == 0 then return b end
    if b.mant == 0 then return a end
    shift = a.expt - b.expt
    if (shift > 0) then
      if shift > NUM_DIGITS*2 then
        return a
      end
      shift.times do 
        a = a.manttimes10! 
      end
      a = a.exptadd!(-shift)
    elsif (shift < 0) then
      if shift < -NUM_DIGITS*2 then
        return b
      end
      (-shift).times do 
        b = b.manttimes10!
      end
      b = b.exptadd!(shift)
    end
    
    shift2 = a.errexpt - b.errexpt
    if (shift2 > 0) then
      a.errmant *= (10 ** shift2)
      a.errexpt -= shift2
    elsif (shift2 < 0) then
      b.errmant *= (10 ** (-shift2))
      b.errexpt += shift2
    end
    
    Apfp.new(a.mant+b.mant,a.expt,a.errmant.abs+b.errmant.abs,a.errexpt).norm
    
  end # +
  
  def -(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in -")
    end
    (self+other.neg)
  end # -
  
  def *(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in *")
    end
    
    a = self.clone.norm
    b = other.clone.norm
    cexpt = a.expt + b.expt
    
    if b.abs >= b.makerr then
      errmant1 = a.errmant * b.mant.abs
      be = b.expt
    else
      errmant1 = a.errmant * b.errmant
      be = b.errexpt
    end
    if a.abs >= a.makerr then
      errmant2 = b.errmant * a.mant.abs
      ae = a.expt
    else
      errmant2 = b.errmant * a.errmant
      ae = a.errexpt
    end
    if a.abs < a.makerr && b.abs < b.makerr
      errmant1 = a.errmant * b.errmant
      errmant2 = b.errmant * a.errmant
      be = b.errexpt
      ae = a.errexpt
    end
    errexpt1 = a.errexpt + be
    errexpt2 = b.errexpt + ae
    
    errshift = errexpt1 - errexpt2
    
    if errshift > 0 then
      errmant1 *= (10 ** errshift)
      errexpt1 -= errshift
    elsif errshift < 0
      errmant2 *= (10 ** (-errshift))
      errexpt2 += errshift
    end
    
    #    em =  cexpt - (a.mant*b.mant).to_s.size - NUM_DIGITS 
    #    if errexpt1 < em
    #      errexpt1 = em
    #    end
    
    Apfp.new(a.mant*b.mant,cexpt,errmant1.abs + errmant2.abs,errexpt1).norm
    
  end
  
  
  def makerr
    if self.error_flag then
      do_error_report("BAD in makerr")
    end
    Apfp.new(@errmant.abs,@errexpt,50,-NUM_DIGITS).norm
  end
  
  def seterr!(limit)
    if self.error_flag then
      do_error_report("BAD in seterr!")
    end
    @errmant = limit.mant.abs
    @errexpt = limit.expt
    self.norm
  end
  def not_zero
    self.abs>self.makerr
  end
  def maybe_zero
    self.abs < self.makerr or self.mant == 0
  end
  
  def not_zero_bad
    self.abs>self.makerr
  end
  def maybe_zero_bad
    self.abs<self.makerr
  end
  
  def /(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in *")
    end
    
    a = self.clone.norm
    b = other.clone.norm
    be = b.abs - b.makerr
    if b.maybe_zero then
      b.set_error_flag("BAD in /: division near zero")
      return b
    end
    amant = a.mant
    aexpt = a.expt
    (2*NUM_DIGITS).times do amant *= 10 end
    aexpt -= 2*NUM_DIGITS
    da = a.makerr
    db = b.makerr
    (2*NUM_DIGITS).times do da.manttimes10! end
    da.exptadd!(-2*NUM_DIGITS)
    ame = da.mant.abs
    aee = da.expt
    dc1 = Apfp.new(ame/be.mant.abs,aee - be.expt,50,-NUM_DIGITS)
    if a.abs <= a.makerr then
      dc2 = (a.makerr * db).abs
    else
      dc2 = (a*db).abs
    end
    (2*NUM_DIGITS).times do dc2 = dc2.manttimes10! end
    dc2.exptadd!(-2*NUM_DIGITS)
    dc3 = Apfp.new(dc2.mant/be.mant.abs,dc2.expt - be.expt, 50, -NUM_DIGITS)
    (2*NUM_DIGITS).times do dc3 = dc3.manttimes10! end
    dc3.exptadd!(-2*NUM_DIGITS)
    dc4 = Apfp.new(dc3.mant.abs/be.mant.abs,dc3.expt - be.expt, 50, -NUM_DIGITS)
    dc = dc1 + dc4
    Apfp.new(amant/b.mant,aexpt - b.expt,dc.mant,dc.expt).norm
    
  end #/
  
  #definitely less than  
  def <(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in <")
    end
    
    #    $stderr.puts '< (self) = ' + (self).to_s
    #    $stderr.puts '< (other) = ' + (other).to_s
    #    $stderr.puts '< (self-other) = ' + (self-other).to_s
    #    $stderr.puts '< (self.makerr) = ' + (self.makerr).to_s
    #    $stderr.puts '< (other.makerr) = ' + (other.makerr).to_s
    #    $stderr.puts '< (self.maker+other.makerr).neg = ' + (self.makerr+other.makerr).neg.to_s
    ret = (self - other).lt((self.makerr + other.makerr).neg)
    #    $stderr.puts '< ret = ' +  ret.to_s
    return ret
  end
  #definitely greater than  
  def >(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in >")
    end
    
    other < self
    
  end
  
  
  # equal within possible error
  def ==(other)
    if self.error_flag || other.error_flag then
      do_error_report('BAD in ==')
    end
    
    if (self.mant == 0) && (other.mant == 0) then
      return (true)
    end
    return !(self > other) && !(other > self)
  end
  
  # greater or equal within error (could be less than within error)
  def >=(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in >=")
    end
    
    !(self < (other))
    
  end
  # less or equal within error (could be greater than within error)
  def <=(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in <=")
    end
    
    !(self > (other))
    
  end
  
  def lt(other)
    # less than ignoring error
    if self.error_flag || other.error_flag then
      do_error_report("BAD in lt")
    end
    #    $stderr.puts "lt self=" + self.to_s
    #    $stderr.puts "lt other=" + other.to_s
    if (other.mant == 0 and self.mant == 0) then
      $stderr.puts "lt false0001A both zero"
      return false
    end
    if (other.mant == 0 and self.mant < 0) then
      #      $stderr.puts "lt true0001B other zero self < zero"
      return true
    end
    if (other.mant < 0 and self.mant == 0) then
      #      $stderr.puts "lt false0001C other < 0 self zero"
      return false
    end
    if (other.mant == 0 and self.mant > 0) then
      #      $stderr.puts "lt false0001C other == 0 self > 0"
      return false
    end
    if (other.mant > 0 and self.mant == 0) then
      #      $stderr.puts "lt true0001C other > 0 self zero"
      return true
    end
    if (other.mant > 0 and self.mant < 0) then
      #     $stderr.puts "lt true0002 self neg other pos"
      return true
    elsif (self.mant > 0 and other.mant < 0) then
      #      $stderr.puts "lt false0003 other neg self pos"
      return false      
    end
    #    $stderr.puts 'est_expt(other)= ' + est_expt(other).to_s
    #    $stderr.puts 'est_expt(self)= ' + est_expt(self).to_s
    
    sgn = est_expt(other) - est_expt(self)
    #    $stderr.puts "sgn = " + sgn.to_s
    if (sgn > 0) then
      if (other.mant > 0)
      then
        #        $stderr.puts "lt true0004A both pos other expt > self expt"
        return true
      else
        #        $stderr.puts "lt false0005A both neg other expt > self expt"
        return false
      end
    elsif (sgn < 0)
      if (other.mant> 0)
      then
        #        $stderr.puts "lt false0004B both pos self expt > other expt "
        return false
      else
        #        $stderr.puts "lt true0005B both neg self expt > other expt" 
        return true
      end
      
    end
    #    $stderr.puts "lt same sign same expt compare mantisas" 
    
    sz = other.mant.to_s.size - self.mant.to_s.size
    #    $stderr.puts "sz = " + sz.to_s
    if sz > 0 then
      pad = "0" * sz
    elsif sz < 0
      pad = "0" * (-sz)
    else
      pad = ""
    end
    if (sz > 0) then
      sf = self.mant.to_s + pad
      ot = other.mant
    else
      sf = self.mant
      ot = other.mant.to_s + pad
    end
    #    $stderr.puts "lt 0006A ot" + ot.to_s
    #    $stderr.puts "lt 0006B sf" + sf.to_s
    ret = ((ot.to_i - sf.to_i) > 0)
    #    $stderr.puts "lt ret0006 " + ret.to_s
    return ret
  end # lt
  
  def gt(other)
    other.lt(self)
  end
  
  
  #  equal ignoring error
  def eq(other)
    !(self.gt(other)) and !(self.lt(other))
  end
  
  def trunc
    if self.error_flag then
      do_error_report("BAD in trunc")
    end
    if self > @@rconst.zero then
      a = self.norm
      sign = 1
    else
      a = self.clone.norm.neg
      sign = -1
    end
    amant = a.mant
    if amant == 0 then 
      return self 
    end
    sz = amant.to_s.size + a.expt
    if amant < 0 then 
      sz_m = sz -1 
    else 
      sz_m = sz 
    end
    if sz_m <= 0 then 
      return @@rconst.zero 
    end
    sz2 = amant.size
    
    if sz > sz2 then 
      (sz - sz2).times do 
        amant *= 10 
      end 
    else 
      amant = (amant.to_s[0,sz]).to_i 
    end
    if amant.to_s.size == 0 then 
      amant = 0 
    end
    
    #    Apfp.new(amant,amant.abs.size,@errmant,@errexpt).norm
    s = Apfp.new(amant*sign,0,@errmant,@errexpt).norm
    s.norm
  end #trunc
  
  def to_i
    if self.error_flag then
      do_error_report("BAD in to_i")
    end
    if self > @@rconst.zero then
      a = self.norm
      sign = 1
    else
      a = self.clone.norm.neg
      sign = -1
    end
    amant = a.mant.to_i
    if amant == 0 then 
      return 0 
    end
    
    sz = amant.to_s.size + a.expt
    if amant < 0 then 
      sz_m = sz -1 
    else 
      sz_m = sz 
    end
    if sz_m <= 0 then 
      return 0 
    end
    sz2 = amant.to_s.size
    amant = amant.to_i
    if sz > sz2 then 
      (sz - sz2).times do 
        amant *= 10 
      end 
    else 
      amant = (amant.to_s[0..sz-1]).to_i 
    end
    if amant.to_s.size == 0 then 
      amant = 0 
    end
    #    puts "sign|" + sign.to_s + "|amant|" + amant.to_s + "|sz|" + sz.to_s +  
    return (sign * amant).to_i
  end #to_i
  
  def frac
    if self.error_flag then
      do_error_report("BAD in frac")
    end
    
    (self - self.trunc).norm
    
  end
  
  def abs
    if self.error_flag then
      do_error_report("BAD in abs")
    end
    
    a = self.clone
    if a.mant < 0
      b = a.neg.norm
    else
      b = a.norm
    end
    return b
  end
  
  def period(per,phase1,phase2)
    if self.error_flag then
      do_error_report("BAD in period")
    end

    a = self.clone
    c = a/per
    #  if (c < (@@rconst.zero)) 
    #  then 
    #    c += per
    #  end
    
    d = c.frac
    
    d2 = d * per
    e = d2 + phase2
    return e
  end
  
  

  
  def sin
    if self.error_flag then
      do_error_report("BAD in sin")
    end
    a = self.clone.norm
    s = ApfpSeriesConst.new("sin",a,@@rconst)
    s.compute
  end
  
  def cos
    if self.error_flag then
      do_error_report("BAD in cos")
    end
    
    a = self.clone.norm
    s = ApfpSeriesConst.new("cos",a,@@rconst)
    s.compute
  end
  def sin_err
    if self.error_flag then
      do_error_report("BAD in sin_err")
    end
    a = self.clone.norm
    s = ApfpSeriesConst.new("sin_err",a,@@rconst)
    s.compute
  end
  
  def cos_err
    if self.error_flag then
      do_error_report("BAD in cos_err")
    end
    a = self.clone.norm
    s = ApfpSeriesConst.new("cos_err",a,@@rconst)
    s.compute
  end
  
  def cosh_err
    if self.error_flag then
      do_error_report("BAD in cosh_err")
    end
    a = self.clone.norm
    s = ApfpSeriesConst.new("cosh_err",a,@@rconst)
    s.compute
  end
  
  def exp
    if self.error_flag then
      do_error_report("BAD in cosh_err")
    end
    if self.mant == 0
      return Apfp.new(1,0,self.errmant,self.errexpt).norm
    end
    
    if self > @@rconst.zero then
      a_int = self.to_i
      a_frac = self.frac
      e_a_int = @@rconst.one
      j = 1
      while j <= a_int do
        e_a_int = e_a_int.clone * @@rconst.e
        j += 1
      end
      a = a_frac.norm
      s = e_a_int * a.exp_2 
      return s
    else
      b = self.clone.neg
      a_int = b.to_i
      a_frac = b.frac
      e_a_int = @@rconst.one
      j = 1
      while j <= a_int do
        e_a_int = e_a_int.clone / @@rconst.e
        j += 1
      end
      a = a_frac.norm
      s = e_a_int / a.exp_2 
      return s
    end
  end
  
  def exp_2
    if self.error_flag then
      do_error_report("BAD in exp2")
    end
    
    # commented to preserve error
    #    if self.mant == 0
    #      return Apfp.new(1,0,self.errmant,self.errexpt).norm
    #    end
    a = self.clone.norm
    #    if a.maybe_zero
    #      r = @@rconst.one
    #    else
    if not a.lt(@@rconst.zero) then
      s = ApfpSeriesConst.new("exp",a,@@rconst)
      r = s.compute
    else
      b = a.neg
      b = b.norm
      s = ApfpSeriesConst.new("exp",b,@@rconst)
      r2 = s.compute
      r2 = r2.norm
      if r2.maybe_zero then 
        r = ap_int(-999)   ### ??? HERE
      else
        r = @@rconst.one/r2
      end
    end
    r
  end
  def exp_err
    if self.error_flag then
      do_error_report("BAD in exp_err")
    end
    if self.maybe_zero
      return Apfp.new(1,0,5,-NUM_DIGITS+3).norm
    end
    a = self.clone.norm
    s = ApfpSeriesConst.new("exp_err",a,@@rconst)
    s.compute
  end
  def asin
    if self.error_flag then
      do_error_report("BAD in asin")
    end
    a = self.clone.norm
    # if a.maybe_zero then # commented to preserve error
    #  return @@rconst.zero
    #end
    if (a.abs > @@rconst.one) then
      a.set_error_flag("BAD in asin: out of domain")
      return a
    end
    #    if a.lt(@@rconst.eight_tenths) and a.neg.gt(@@rconst.eight_tenths) then
    #  if (a.mant > 0) and (a * a - @@rconst.one).maybe_zero then
    #    return @@rconst.pi/@@rconst.two
    #  end
    #  if (a.mant < 0) and (a * a - @@rconst.one).maybe_zero  then
    #    return @@rconst.pi/@@rconst.minus_two
    #  end
    s = ApfpSeriesConst.new("asin",a,@@rconst)
    b = s.compute
    #    $stderr.puts "asin(" + a.to_s + ") = " + b.to_s  
    #  puts "asin(" + a.to_s +  ") = " + b.to_s
    return b
    #   elsif a.mant > 0 then
    #     b = (@@rconst.one - a*a).sqrt
    #     c = b.acos
    #     return c
    #   else
    #     b = (@@rconst.one - a*a).sqrt
    #     c = b.acos
    #     return c.neg
    #   end
  end
  def asin_basic
    if self.error_flag then
      do_error_report("BAD in asin_basic")
    end
    a = self.clone.norm
    if (a.abs > @@rconst.one) then
      a.set_error_flag("BAD in asin_basic: out of domain")
      return a
    end
    s = ApfpSeriesConst.new("asin_basic",a,@@rconst)
    s.compute
  end
  
  def acos
    if self.error_flag then
      do_error_report("BAD in acos")
      return self
    end
    a = self.clone.norm
    #    if a.mant >= 0 and a.lt(@@rconst.eight_tenths) then
    b =@@rconst.half_pi - a.asin
    #    $stderr.puts "acos(" + a.to_s + ") = " + c.to_s  
    #
    #      return c
    #    elsif a.neg.lt(@@rconst.eight_tenths)
    #      b = self.clone.norm
    #      c =(@@rconst.half_pi) - b.asin
    #      $stderr.puts "cos(" + a.to_s + ") = " + b.to_s  
    #      return c
    #    elsif (a.mant > 0)
    #      b = (@@rconst.one-a*a).sqrt
    #      c = @@rconst.pi.neg + b.asin
    #      $stderr.puts "acos(" + a.to_s + ") = " + b.to_s  
    #      return c
    #    else
    #      b = (@@rconst.one-a*a).sqrt
    #      c = @@rconst.pi - b.asin
    #      $stderr.puts "acos(" + a.to_s + ") = " + b.to_s  
    #      return c
    return b
  end

  
  def erf
    if self.error_flag then
      do_error_report("BAD in erf")
    end

    a = self.clone.norm
    s = ApfpSeriesConst.new("erf",a,@@rconst)
    s.compute
  end
  
  def acos_old
    if self.error_flag then
      do_error_report("BAD in acos")
    end

    a = self.clone.norm
    if (a.abs > @@rconst.one) then
      a.set_error_flag("BAD in acos: out of domain")
      return a
    end
    b =(@@rconst.half_pi) - a.asin
    #  puts "acos(" + a.to_s +  ") = " + b.to_s
    return b
  end
  
  def atan
    if self.error_flag then
      do_error_report("BAD in atan")
    end
    a = self.clone
    #    puts " x atan2(" + a.to_s +  ") "
    if false # commented because would lose estimate of error
      if a.maybe_zero then
        return @@rconst.zero
      elsif (a - @@rconst.one).maybe_zero then
        return @@rconst.half_pi
      elsif (a - @@rconst.minus_one).maybe_zero then
        return @@rconst.minus_half_pi
      end
    end
    
    if a > @@rconst.zero && (a*a) <  @@rconst.one
      how = 1
    elsif a < @@rconst.zero && (a*a) <  @@rconst.one
      how = 2
    elsif a > @@rconst.zero
      a = @@rconst.one/a
      how = 3
    else
      a = @@rconst.one/a
      how = 4
    end
    #    puts " xx atan2(" + a.to_s +  ") "
    b = a.atan2
    #   puts " xxx atan2(" + a.to_s +  ") = " + b.to_s + " how = " + how.to_s
    case how
    when 1,2
      return b
    when 3
      return @@rconst.half_pi - b
    when 4
      return @@rconst.minus_half_pi - b
    end
  end
  
  def atan2
    if self.error_flag then
      do_error_report("BAD in atan2")
    end
    
    a = self.clone.norm
    if a.lt(@@rconst.minus_one) || a.gt(@@rconst.one) then
      a.set_error_flag("BAD in atan2: out of domain")
      return a
    end
    s = ApfpSeriesConst.new("atan",a,@@rconst)
    s.compute
  end
  # log base e of value betwween 0.1 and one
  def log_basic
    if self.error_flag then
      do_error_report("BAD in log_basic")
    end
    a = self.clone.norm
    if a.lt(@@rconst.one_tenth)  || a.gt(@@rconst.one) || a.eq(@@rconst.one) then
      a.set_error_flag("BAD in log_basic: out of domain")
      return a
    end
    #  puts "log basic of " + a.to_s
    s = ApfpSeriesConst.new("log",a,@@rconst)
    return s.compute
  end
  
  # log base e of value beteen 0.1 and 1 for purposes of error calc
  def log_basic_err
    if self.error_flag then
      do_error_report("BAD in log_basic_err")
    end
    a = self.clone.norm
#    $stderr.puts "log basic err a =" + a.to_s
    if a.lt(@@rconst.zero)  || a.gt(@@rconst.one) || a.eq(@@rconst.one) then
      a.set_error_flag("BAD in log_basic_err: out of domain")
      return a
    end
    s = ApfpSeriesConst.new("log_err",a,@@rconst)
    return s.compute
  end
  
  # log base e for purpose of calculating log_e_10 in initialize
  def log_basic_init
    if self.error_flag then
      do_error_report("BAD in log_basic_init")
    end
    a = self.clone.norm
    if (a < @@rconst.zero) || a.mant == 0 then
      a.set_error_flag("BAD in log_basic_init: out of domain")
      return a
    end
    s = ApfpSeriesConst.new("log_init",a,@@rconst)
    return s.compute
  end
  
  # very rough & fast
  def about_log10
    if self.error_flag then
      do_error_report("BAD in about_log10")
    end
    b = self.clone.norm
    return ap_int(b.expt + b.mant.to_s.size)
  end     
  
  #log base 10 of positive value
  def log10
    if self.error_flag then
      do_error_report("BAD in log10")
    end
    b = self.clone
    if (b < @@rconst.zero) or b.mant == 0 then
      b.set_error_flag("BAD in asin: out of domain")
      return b
    end
    
    lg10 = b.log/@@rconst.log_e_10
    return lg10.norm
  end
  
  #log base e of any positive value
  def log
    if self.error_flag then
      do_error_report("BAD in log")
    end
    b = self.clone
    #  puts "log e of " + b.to_s
    if b.mant == 0 then
      b.set_error_flag("BAD in log: out of domain")
      return b
    end

    x = b.norm
    y = Apfp.new(x.expt + x.mant.to_s.size,0,50,-NUM_DIGITS).norm
    d = Apfp.new(x.mant,-x.mant.to_s.size,x.errmant,x.errexpt)
    c = d.log_basic + y * @@rconst.log_e_10
    return c 
    
  end
  
  #log base e of positive value for purpose of error
  def log_err
    if self.error_flag then
      do_error_report("BAD in log_err")
    end
    b = self.clone
    #  puts "log e of " + b.to_s
    if b.mant == 0 then
      b.set_error_flag("BAD in log_err: out of domain")
      return b
    end
    x = b.norm
    y = Apfp.new(x.expt + x.mant.to_s.size,0,50,-NUM_DIGITS).norm
    d = Apfp.new(x.mant,-x.mant.to_s.size,x.errmant,x.errexpt)
    c = d.log_basic_err + y * Apfp.new(2302585093,-9,50,-9) 
#    c.display_val("log_err")
    c
  end
  
  def tan
    if self.error_flag then
      do_error_report("BAD in tan")
    end
    
    self.sin/self.cos
    
  end
  
  def **(other)
    if self.error_flag || other.error_flag then
      do_error_report("BAD in **")
    end

    a = self.clone
    d = other
    if d.kind_of?(Integer) || d.kind_of?(Fixnum)
      if d == 0 then
        return @@rconst.one
      end
        
      b = @@rconst.one
      if d > 0 then
        d.times do
          b = a * b
        end
        return b
      elsif d < 0 then
        (-d).times do
          b = a * b
        end
        b = @@rconst.one/b
        return b
      end
      return b # @@rconst.one
    end
    if d.mant  == 0 then 
      return Apfp.new(1,0,d.errmant,d.errexpt) 
    end
    if d == @@rconst.one then 
      return a 
    end
    if a.mant == 0 then 
      return Apfp.new(0,-1,a.errmant,a.errexpt) 
    end
    return (a.log*d).exp
  end
  
  def sqrt_err
    if self.error_flag then
      do_error_report("BAD in sqrt_err")
    end
    a = self.clone
    if a.mant == 0 then
      return Apfp.new(0,-1,a.errmant,a.errexpt) 
    end
    
    (@@rconst.half * a.log_err).exp_err 
  end
  
  def sqrt
    if self.error_flag then
      do_error_report("BAD in sqrt")
    end
    a = self.clone
    if a.mant == 0 then
      return Apfp.new(0,-1,a.errmant,a.errexpt) 
    end
    return (a.log * @@rconst.half).exp
  end
  
  def sinh
    if self.error_flag then
      do_error_report("BAD in sinh")
    end
    a = self.clone.norm
    if a.abs < @@rconst.one then
      s = ApfpSeriesConst.new("sinh",a,@@rconst)
      b = s.compute
      return b
    else
      y1 = a.exp
      y2 = a.neg.exp
      b = (y1-y2) / @@rconst.two
      return b 
    end
  end

  def cosh
    if self.error_flag then
      do_error_report("BAD in cosh")
    end
    
    y1 = self.exp
    y2 = self.neg.exp
    (y1+y2) / @@rconst.two
  end
  
  def tanh
    if self.error_flag then
      do_error_report("BAD in tanh")
    end
    
    self.sinh/self.cosh
    
  end
  
  
end #class Apfp


class ApfpConst
  
  def initialize()
    if RAILS_MODE == 0 then
      puts "Initializing..."
    end
    @ZERO = ap_int(0)
    @ONE = ap_int(1)
    @TWO = ap_int(2)
    @FOUR = ap_int(4)
    @SIX = ap_int(6)
    @TEN = ap_int(10)
    @TWENTY = ap_int(20)
    @HALF = Apfp.new(5,-1,50,-NUM_DIGITS).norm
    @ONE_TENTH = Apfp.new(1,-1,50,-NUM_DIGITS).norm
    @EIGHT_TENTHS = Apfp.new(8,-1,50,-NUM_DIGITS).norm
    @MINUS_ONE = ap_int(-1)
    @MINUS_TWO = ap_int(-2)
    @SMALL_FLOAT = ap_in("0.1e-100")
    @LARGE_FLOAT = ap_in("0.1e+100")
    if RAILS_MODE == 0 then
      puts "Initialized"
    end
    
  end
  def init2
    if RAILS_MODE == 0 then
      puts "Initializing(2)..."
    end
    @E = @ONE.exp_2
    @LOG_E_10 = @TEN.log_basic_init
    @PI = ((@HALF.asin_basic)*@SIX)
    @PI.display_val("PI")
    @E.display_val("E")
    @LOG_E_10.display_val("LOG_E_10")
    @TWO_PI = @PI*@TWO
    @HALF_PI = @PI/@TWO
    @MINUS_TWO_PI = @MINUS_ONE * @TWO_PI
    @MINUS_HALF_PI = @MINUS_ONE * @HALF_PI
    @MINUS_PI = @MINUS_ONE * @PI
    if RAILS_MODE == 0 then
      puts "Initialized(2)"
    end
  end
  

  def zero
    
    @ZERO
    
  end
  def one
    @ONE
  end
  def one_tenth
    @ONE_TENTH
  end
  def eight_tenths
    @EIGHT_TENTHS
  end
  def minus_one
    @MINUS_ONE
  end
  def minus_two
    @MINUS_TWO
  end
  def small_float
    @SMALL_FLOAT
    end
  def large_float
    @LARGE_FLOAT
    end
  def two
    @TWO
  end
  def four
    @FOUR
  end
  def six
    @SIX
  end
  def ten
    @TEN
  end
  def twenty
    @TWENTY
  end
  def half
    @HALF
  end
  def two_pi
    @TWO_PI
  end
  def minus_two_pi
    @MINUS_TWO_PI
  end
  def half_pi
    @HALF_PI
  end
  def minus_half_pi
    @MINUS_HALF_PI
  end
  def minus_pi
    @MINUS_PI
  end
  def pi
    @PI
  end
  
  def e
    @E
  end
  
  def log_e_10
    @LOG_E_10 
  end
  
end #class ApfpConst

class ApfpSeries
  
  def initialize(series_name,x,term,cnt,incr,maxloop,rconst)
    @series_name = series_name
    @x = x
    @sum = c(0)
    @term = term
    @cnt = cnt
    @incr = incr
    @maxloop = maxloop
    @@rconst = rconst
  end
  def adj_tb(tb,term,i)
    j = 2
    while j <= 5 && j <= i do
#      puts "adj tb i = " + i.to_s + " j = " + j.to_s + " tb[i] = " + tb[i].to_s
      tb[j-1] = tb[j].abs
      j += 1
    end
    tb[5] = term
  end

  def adj_max(tb)
    return tb[1].abs + tb[2].abs+ tb[3].abs+ tb[4].abs+ tb[5].abs
  end

  def compute
    @lim = self.limit.abs
    @li = @lim*c0(0.001)
    if @lim > Apfp.new(50,-NUM_DIGITS,50,-2*NUM_DIGITS).norm then
      @li = Apfp.new(50,-NUM_DIGITS,50,-2*NUM_DIGITS).norm 
    end
    @term.errmant = 5 # start clean
    @term.errexpt = @term.expt-NUM_DIGITS+@term.mant.abs.to_s.size
    @sum = @term
    tb = Array.new(5)
    tb[1] = @@rconst.zero
    tb[2] = @@rconst.zero
    tb[3] = @@rconst.zero
    tb[4] = @@rconst.zero
    tb[5] = @@rconst.zero
    tb_adj = @@rconst.zero
    a = @@rconst.one # doesn't really matter because of loop condition
    i = 1

    while (a > @li  && @cnt < @maxloop) || i < MAX_TERMS do
      @term *= self.fctr
      @sum = @term + @sum
      @cnt += @incr
      adj_tb(tb,@term,i)
      i += 1
      a = adj_max(tb)
      #    puts @series_name
      #    puts @cnt
      #    @term.display_val("@term")
    end
#    puts "exited compute @li = " + @li.to_s + " a = " + a.to_s + " f = " + @series_name + " x = " + @x.to_s + " @sum = " + @sum.to_s + " @cnt = " + @cnt.to_s
#    $stderr.puts "exited compute @li = " + @li.to_s + " a = " + a.to_s + " f = " + @series_name + " x = " + @x.to_s + " @sum = " + @sum.to_s + " @cnt = " + @cnt.to_s
    if @sum.makerr < @term.abs then 
      @sum.errmant = @term.abs.mant   # = @sum.seterr!@term) 
      @sum.errexpt = @term.expt   # = @sum.seterr!(@term) 
    end
    if @sum.makerr < @lim.abs then 
      @sum.errmant = @lim.abs.mant   # = @sum.seterr!@term) 
      @sum.errexpt = @lim.expt   # = @sum.seterr!(@term) 
    end
    @sum = @sum.norm
#    em =  @sum.expt - @sum.mant.to_s.size - NUM_DIGITS 
#    if @sum.errexpt < em
#      @sum = Apfp.new(@sum.mant,@sum.expt,50,em)
#    end
    return @sum
  end #compute



  def limit
    case "#{@series_name}"
    when "sin"
      a = @x
      b = @x.cos_err
      s = ApfpSeriesConst.new("cos_err",a,@@rconst) # deriv of sin is cos
      l = s.compute.abs
      return l * a.makerr
    when "sinh"
      a = @x
      b = @x.cosh_err
      s = ApfpSeriesConst.new("cosh_err",a,@@rconst) # deriv of sin is cos
      l = s.compute.abs
      return l * a.makerr
    when "cos_err"
      return Apfp.new(1,-NUM_DIGITS+3,50,-NUM_DIGITS).norm
    when "cos"
      a = @x
      b = @x.sin_err
      s = ApfpSeriesConst.new("sin_err",a,@@rconst) # deriv of cos is sin
      l = s.compute.abs
      return l * a.makerr
    when "sin_err"
      return Apfp.new(1,-NUM_DIGITS+3,50,-NUM_DIGITS).norm
    when "exp"
      a = @x
      b = a.exp_err
      s = ApfpSeriesConst.new("exp_err",a,@@rconst) # deriv of exp is exp
      l = s.compute.abs
      return l * a.makerr
    when "exp_err","cosh_err"
      return Apfp.new(1,-NUM_DIGITS+3,50,-NUM_DIGITS).norm
#      return @x.makerr
    when "erf"
      return @@rconst.twenty*((@x*@x).neg.exp_err)*@x.makerr
    when "asin"
      return Apfp.new(1,-NUM_DIGITS+3,50,-NUM_DIGITS).norm
      tmp = (@@rconst.one - @x*@x)
      if  tmp.maybe_zero then 
        tmp.set_error_flag("asin near +/-1")
        return tmp
      else
        #      return @x.makerr / (@@rconst.one-@x*@x).sqrt_err
      end
    when "asin_basic"
      tmp = (@@rconst.one - @x*@x)
      if  tmp.maybe_zero then 
        tmp.set_error_flag("asin near +/-1")
        return tmp
      else
        return @x.makerr / (@@rconst.one-@x*@x).sqrt_err
      end
    when "atan"
      return @x.makerr / (@@rconst.one+@x*@x)
    when "log","log_init","log_err"
      a = @x
      if @x.not_zero
        return (@x.makerr * @@rconst.ten)/@x.abs
      else
        a.set_error_flag("BAD in limit: division near zero")
        return a
      end

    end
  end #limit
  
  
  def fctr
    
    case "#{@series_name}"
    when "sin","sin_err"
      return @x*@x/ap_int(-@cnt*@cnt - 3 * @cnt - 2)
    when "sinh"
      return @x*@x/ap_int(@cnt*@cnt + 3 * @cnt + 2)
    when "cos","cos_err"
      return @x*@x/ap_int(-@cnt*@cnt - 3 * @cnt - 2) 
    when "cosh_err"
      return @x*@x/ap_int(@cnt*@cnt + 3 * @cnt + 2) 
    when "exp","exp_err"
#      $stderr.puts "exp - experr @cnt = " + @cnt.to_s
#      $stderr.puts "exp - experr ap_int(@cnt+1) = " + ap_int(@cnt+1).to_s
      
#      if (@cnt+1) > 0 then
        return @x/ap_int(@cnt+1)
#      else
#        return ap_int(0)
#HERE      end
    when "asin"
      if @cnt == 3 then
        return @x*@x/ap_int(@cnt*@cnt-@cnt)
      else
        return @x*@x*ap_int(@cnt*@cnt - 4*@cnt + 4)/ap_int(@cnt*@cnt - @cnt)
      end
    when "asin_basic"
      if @cnt == 3 then
        return @x*@x/ap_int(@cnt*@cnt-@cnt)
      else
        return @x*@x*ap_int(@cnt*@cnt - 4*@cnt + 4)/ap_int(@cnt*@cnt - @cnt)
      end
    when "erf"
      if @cnt == 3 then 
        @cnt2 = 1
      else
        @cnt2 +=  1
      end
      return @x*@x*ap_int(2-@cnt)/(ap_int(@cnt*@cnt2))
    when "atan"
      return @x*@x*ap_int(2-@cnt)/ap_int(@cnt)
    when "log","log_err"
      return (@x-@@rconst.one)*ap_int(1-@cnt)/ap_int(@cnt)
    when "log_init"
      tmp = (@x-@@rconst.one)/(@x+@@rconst.one)
      return tmp*tmp*ap_int(@cnt)/ap_int(@cnt+2)
    end
  end #fctr




end  # #ApfpSeries

class ApfpSeriesConst

  def initialize(func_name,x,rconst)
    @@rconst = rconst
    @func_name = func_name
    @x = x
    case func_name
    when "sin"
      per = @@rconst.pi*@@rconst.two
      phase1 = @@rconst.zero
      phase2 = @@rconst.zero
      @x = x.period(per,phase1,phase2)
      cnt = 1
      @s = ApfpSeries.new("sin",@x,@x,cnt,2,MAX_LOOP,@@rconst)
      return @s
    when "sin_err"
      per = @@rconst.pi*@@rconst.two
      phase1 = @@rconst.zero
      phase2 = @@rconst.zero
      @x = x.period(per,phase1,phase2)
      cnt = 1
      t = @@rconst.one
      @s = ApfpSeries.new("sin_err",@x,@x,cnt,2,100,@@rconst)
      return @s 
    when "cos"
      per = @@rconst.pi*@@rconst.two
      phase1 = @@rconst.zero
      phase2 = @@rconst.zero
      @x = x.period(per,phase1,phase2)
      cnt = 0
      t = @@rconst.one
      @s = ApfpSeries.new("cos",@x,t,cnt,2,MAX_LOOP,@@rconst)
      return @s
    when "cos_err"
      per = @@rconst.pi*@@rconst.two
      phase1 = @@rconst.zero
      phase2 = @@rconst.zero
      @x = x.period(per,phase1,phase2)
      cnt = 0
      t = @@rconst.one
      @s = ApfpSeries.new("cos_err",@x,t,cnt,2,100,@@rconst)
      return @s
    when "exp"
      @x = x
      cnt = 0
      t = @@rconst.one
      @s = ApfpSeries.new("exp",@x,t,cnt,1,MAX_LOOP,@@rconst)
      return @s
    when "sinh"
      @x = x
      cnt = 1
      @s = ApfpSeries.new("sinh",@x,@x,cnt,2,MAX_LOOP,@@rconst)
      return @s
    when "cosh_err"
      @x = x
      cnt = 0
      t = @@rconst.one
      @s = ApfpSeries.new("cosh_err",@x,t,cnt,2,MAX_LOOP,@@rconst)
      return @s
    when "exp_err"
      @x = x
      cnt = 0
      t = @@rconst.one
      @s = ApfpSeries.new("exp_err",@x,t,cnt,1,MAX_LOOP,@@rconst)
      return @s
    when "asin"
      @x = x
      cnt = 3
      @s = ApfpSeries.new("asin",@x,@x,cnt,2,MAX_LOOP,@@rconst)
      return @s
      
    when "asin_basic"
      @x = x
      cnt = 3
      return @s = ApfpSeries.new("asin_basic",@x,@x,cnt,2,MAX_LOOP,@@rconst)
    when "erf"
      @x = x
      cnt = 3
      tmp = @@rconst.two/@@rconst.pi.sqrt*@x
      return @s = ApfpSeries.new("erf",@x,tmp,cnt,2,MAX_LOOP,@@rconst)
    when "atan"
      @x = x
      cnt = 3
      return @s = ApfpSeries.new("atan",@x,@x,cnt,2,MAX_LOOP,@@rconst)
    when "log"
      @x = x
      cnt = 2
      tmp = @x-@@rconst.one
      @s = ApfpSeries.new("log",@x,tmp,cnt,1,MAX_LOOP,@@rconst)
      return @s
    when "log_err"
      @x = x
      cnt = 2
      tmp = @x-@@rconst.one
      @s = ApfpSeries.new("log_err",@x,tmp,cnt,1,MAX_LOOP,@@rconst)
      return @s 
    when "log_init"
      @x = x
      cnt = 1
      tmp = @@rconst.two*(@x-@@rconst.one)/(@x+@@rconst.one)
      @s = ApfpSeries.new("log_init",@x,tmp,cnt,2,MAX_LOOP,@@rconst)
      return @s
    end
  end
  
  def compute
    @s.compute
  end
  
end # ApfpSeriesConst

  

    
