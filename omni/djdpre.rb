####################################################################
#
#	File:     djdpre.rb
#
#	Subject:  Part of a Ruby program to generate a program ("diffeq.---")
#                  to solve a system of ordinary differential equations
#                  with long Taylor series. Intended to Support
#                  programs with Ruby (native math) Ruby (APFP),
#                  Maple 12, maxima.
#                 It permits one to comment out blocks of code  between
#                    #DJDSTOP and #DJDSTART in a Ruby program.
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

copy = 1
line_no = 0
in_cnt = 0
out_cnt = 0
line = $stdin.gets
while line
  line = line.chomp.rstrip
  line_no += 1
  if copy == 1 then
    puts line
    in_cnt += 1
    if line == "#DJDSTOP" then
      copy = 0
      $stderr.puts "STOPPED line = #{line_no}"
    end
    if line == "#DJDSTART"
      $stderr.puts "ALREADY STARTED line = #{line_no}"
    end
  else
    puts "# #{line}"
    out_cnt += 1
    if line == "#DJDSTART" then
      $stderr.puts "RESTARTED line = #{line_no}"
      copy = 1
    end
    if line == "#DJDSTOP" then
      $stderr.puts "ALREADY STOPPED line = #{line_no}"
    end
  end
  line = $stdin.gets
end
total = in_cnt + out_cnt
percent = in_cnt*100/total
$stderr.puts "Total in  = #{in_cnt}"
$stderr.puts "Total out = #{out_cnt}"
$stderr.puts "Total lines = #{total}"
$stderr.puts "#{percent}% completed"
