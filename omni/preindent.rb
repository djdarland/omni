####################################################################
#
#	File:     preindent.rb
#
#	Subject:  Part of a Ruby program to generate a program ("diffeq.---")
#                  to solve a system of ordinary differential equations
#                  with long Taylor series. Intended to Support
#                  programs with Ruby (native math) Ruby (APFP),
#                  Maple 12, maxima. It indents the output of omnisode.rb
#                  according to directives omnsode.rb embeds. 
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
load 'atsinc.rb'
pad = 0
indent1 = Regexp.new(/INDENT\(/)
indent2 = Regexp.new(/[1-2]+/)
while linein = gets do
# puts "linein = |" + linein + "|"
  linein = linein.chomp.lstrip.rstrip
  if GEN == RUBY or GEN == RUBY_APFP then
    linein2 = linein.gsub(/glob_/,"$glob_")
    linein = linein2.gsub(/array_/,"$array_")
  end
  if GEN == MAXIMA then
    linein2 = linein.gsub(/ALWAYS/,"always")
    linein3 = linein2.gsub(/INFO/,"info")
    linein4 = linein3.gsub(/DEBUGL/,"debugl")
    linein5 = linein4.gsub(/DEBUGMASSIVE/,"debugmassive")
    linein6 = linein5.gsub(/ATS_MAX_TERMS/,"ats_max_terms")
    linein = linein6.gsub(/MAX_UNCHANGED/,"max_unchanged")
  end
  if md = indent1.match(linein) then
    rest = md.post_match 
    if md = indent2.match(rest) then
      val = md[0].to_i
      if val == 1 then
        pad += 4
      elsif val == 2 then 
        pad -= 4
      elsif val == 0 then
        pad = 0
      else
        puts 1/0
      end
      if pad < 0 then
        pad = 0
      end
      # puts "pad = " + pad.to_s
    end
  else
    if linein != "" then
      puts (" " * pad) + linein
    end
  end
end

