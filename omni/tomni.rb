##################################################################
#
#	File:     tomni.rb
#
#	Subject:  Ruby Program to run Ruby programs (mainly omnisode.rb)
#                  to generate a program and then execute it.
#                  
#	Author:   Dennis J. Darland
#
#       Copyright (C) 2008-2014 Dennis J. Darland
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
def get_temp()
  re_linux = Regexp.new(/linux/)
  re_cygwin = Regexp.new(/cygwin/)
  re_windows = Regexp.new(/w32/)
  if (md = re_linux.match(RUBY_PLATFORM) and Dir.exist?('/media/ramdisk'))
  then $TEMP_DIR = '/media/ramdisk'
  elsif (md = re_linux.match(RUBY_PLATFORM))
  then  $TEMP_DIR = 'TEMP'
  elsif (md = re_cygwin.match(RUBY_PLATFORM) and Dir.exist?('/cygdrive/R/Temp'))
  then  $TEMP_DIR = '/cygdrive/R/Temp'
  elsif (md = re_cygwin.match(RUBY_PLATFORM))
  then  $TEMP_DIR = 'TEMP'
  elsif  (md = re_windows.match(RUBY_PLATFORM) and Dir.exist?('R:\\Temp'))
  then $TEMP_DIR = 'R:\\Temp'
  elsif  (md = re_windows.match(RUBY_PLATFORM))
  else $TEMP_DIR = 'TEMP'
  end
end

def single_test(lang,lang_cmd,odefile,remark,browser,flags1,flags2,mode,os,langsuffix,editor,name,math)
  puts RUBY_PLATFORM
  
  puts "lang       = " + lang
  puts "lang_cmd   = " + lang_cmd
  puts "odefile    = " + odefile
  puts "remark     = " + remark
  puts "browser    = " + browser
  puts "flags1      = " + flags1
  puts "flags2      = " + flags2
  puts "mode       = " + mode
  puts "os         = " + os
  puts "langsuffix = " + langsuffix
  puts "editor     = " + editor

 target = math + "_" + name + "_" + os
  path = File.join("html","omniresults",target)
  $target = path
  ofile = odefile + "." + langsuffix
  puts "ofile =" + ofile
  tempdiffeqpgm = File.join($TEMP_DIR, "diffeq." + ofile)
  puts "tempdiffeqpgm =" + tempdiffeqpgm
  targetdiffeqpgm = File.join($target, "diffeq." + ofile + ".txt")
  puts "targetdiffeqpgm =" + targetdiffeqpgm
  resultsfile = File.join($target, "results." + ofile + ".txt")
  puts "resultsfile =" + resultsfile
  tempdiffeqpgmexe = File.join($TEMP_DIR, "diffeq." + ofile + "_" + os)
  puts "tempdiffeqpgmexe =" + tempdiffeqpgmexe
  if File.exists?(targetdiffeqpgm) then
    puts "would overwrite data and invalidate table - (" + targetdiffeqpgm +")"
    exit(1)
  end
  puts "odefile=" + odefile
  if File.exists?(odefile + ".ode") then
    if not tran( odefile + '.ode' , File.join($target,odefile + '.ode.txt')) then
      puts "error copying " + odefile + '.ode'
      exit(1)
    end
    puts "tran odefile "  + odefile + ".ode"
  else
      puts "error " + odefile + '.ode' + " missing"
    exit(1)
  end
  
  cmd = 'ruby preodein.rb ' + odefile + ' .'
  puts cmd
  if not system(cmd) then
    puts "error in preode in " + odefile
    exit(1)
  end
  # NEEDS TO TEST TOR OS
  if not tran(File.join($TEMP_DIR,"omnisodetst.rb"),  "omnisodetst.rb")
    puts "error in COPY omnisodetst.rb)"
    exit(1)
  end
  puts "running processed omnisode.rb -- omnisodetst.rb"
  cmd = "ruby omnisodetst.rb" + " " + File.join($TEMP_DIR, odefile + "postode") + " " + odefile + " " +  $target + " " +  remark + "  >" + File.join($TEMP_DIR,"mxout1.tmp") + " 2>" + File.join($TEMP_DIR,"mxout2.tmp")
  puts cmd
  if not system(cmd) then
    puts "error running omnisode" + cmd
    exit(1)
  end
  puts "echo running preindent on diffeq" 
  cmd = "ruby preindent.rb <" + File.join($TEMP_DIR,"diffeq.tmp") + "  >" + tempdiffeqpgm + " 2>" + File.join($TEMP_DIR,"djdid2.tmp")
  puts cmd
  if not system(cmd) then
    puts "error running preindent"
    exit(1)
  end

  if not tran(tempdiffeqpgm , targetdiffeqpgm) then
    puts "error transfering " + targetdiffeqpgm
    exit(1)
  end
  if File.exists?(File.join($TEMP_DIR,"djdout.tmp")) then
    File.delete(File.join($TEMP_DIR,"djdout.tmp"))
  end
  if File.exists?(File.join($TEMP_DIR,"djdout2.tmp")) then
    File.delete(File.join($TEMP_DIR,"djdout2.tmp"))
  end
  if lang == "c" or lang == "c++" then
    cmd =  lang_cmd + flags1 + tempdiffeqpgmexe + " " + tempdiffeqpgm + " " + flags2
    puts cmd
    if not system(cmd) then
      puts "error in " + cmd
      exit(1)
    end
    cmd = tempdiffeqpgmexe + " >" + resultsfile + " 2>" + File.join($TEMP_DIR,"djdout2.tmp")
    puts cmd
    if not system(cmd) then
      puts "error in " + cmd
      exit(1)
    end
    puts tempdiffeqpgmexe + " successfull"
  else # ruby, maxima, or cmaple 
    cmd =  lang_cmd + " " + flags1 + tempdiffeqpgm + " >" + resultsfile + " 2>" + File.join($TEMP_DIR,"djdout2.tmp")
    puts cmd
    if not system(cmd) then
      puts "error in " + cmd
      exit(1)
    end
    puts tempdiffeqpgm + " successfull"
  end
  if File.exists?(File.join($target,"body.html")) then
    if not tran(File.join($target,"body.html") , File.join($target,"body.work")) then
      puts "error copying body.html"
      exit(1)
    end
  else # Make body empty
    puts "create empty because doesn't exist"
    bodywork = File.new(File.join($target,"body.work"),"w")
    bodywork.puts " "
    bodywork.close
  end
  if not tran2(File.join($target,"body.work"), "entry.html" ,File.join($target,"body.html")) then
    puts "error concatinating entry"
    exit(1)
  end
  if not tran3(File.join("html","head.html") , File.join($target,"body.html") , File.join("html","tail.html") , File.join($target,"table.html")) then
    puts "error concatinating table"
    exit(1)
  end
end

def get_answer(lang)
  answer = 'u'
  while (answer != 'n' and answer != 'y') do
    puts 'Do you want to test ' + lang + '? (y/n)'
    answer = gets.rstrip
  end
  if answer == 'y'
    return true
  else
    return false
  end
end
def get_os()
  re_linux = Regexp.new(/linux/)
  re_cygwin = Regexp.new(/cygwin/)
  re_windows = Regexp.new(/w32/)
  if md = re_linux.match(RUBY_PLATFORM)
    answer = 'linux'
  elsif  md = re_cygwin.match(RUBY_PLATFORM)
    answer = 'cygwin'
  elsif  md = re_windows.match(RUBY_PLATFORM)
    answer = 'windows'
  end
  while (answer != 'linux' and answer != 'cygwin' and answer != 'windows')  do
    puts 'Enter OS '
    puts 'linux, cygwin or windows'
    answer = gets.rstrip
  end
  return answer
end

def getode()
  odere = Regexp.new(/^\w*/)
  if md = odere.match($linein) then
    ode = md[0]
    $linein = md.post_match
    $linein = $linein.lstrip.rstrip
  end
  return ode
end

def get_target(os,name,math)
  target = math + "_" + name + "_" + os
  path = File.join("html","omniresults",target)
  puts "target=" + target
  puts "path=" + path
  while File.exists?(path) do
    puts "Target directory " + path + " exists"
    line = 'u'
    while line != 'y' and line != 'd' do 
      puts "Select new directory name (y)?"
      puts "or Delete eisting directory  (d)?"
      puts "or exit (x)?"
      line = gets.chomp.lstrip.rstrip
      if line == 'x' then
        exit(1)
      elsif line == 'd' then
        if os == 'windows' then
          path2 = 'html\\omniresults\\' + target
          cmd = 'rmdir /s /q ' + path2
          puts cmd
          if not system(cmd) then
            puts 'cannot delete ' + path2
            exit(1)
          end
        else # os == linux or cygwin
          cmd = 'rm -r  ' + path
          puts cmd
          if not system(cmd) then
            puts 'cannot delete ' + path
            exit(1)
          end
        end
      elsif line == 'y' then
        puts "Enter name"
        name = gets.chomp.rstrip.lstrip
        target = math + "_" + name + "_" + os
        path = File.join("html","omniresults",target)
      else
        puts 'invalid response'
      end
    end
  end
  return path
end

def getremark()
  if not $linein.nil? then
    if $linein != "" then
      remark = $linein
    else
      remark = '"No Comment"'
    end
  else
    remark = '"No Comment"'
  end
  return remark
end

class Lang_info
  def initialize(lang,cmd,suffix,to_test,flags1,flags2,target,math)
    @lang = lang
    @cmd = cmd
    @suffix = suffix
    @to_test = to_test
    @flags1 = flags1
    @flags2 = flags2
    @target = target
    @math = math
  end
  
  def lang=(other)
    @lang = other
  end
  def cmd=(other)
    @cmd = other
  end
  def suffix=(other)
    @suffix = other
  end
  def to_test=(other)
    @to_test = other
  end
  def flags1=(other)
    @flags1 = other
  end
  def flags2=(other)
    @flags2 = other
  end
  def target=(other)
    @target = other
  end
  def lang
    @lang
  end
  def cmd
    @cmd
  end
  def suffix
    @suffix
  end
  def to_test
    @to_test
  end
  def flags1
    @flags1
  end
  def flags2
    @flags2
  end
  def target
    @target
  end
  def math
    @math
  end

end # lang_info

class Os_info
  def initialize(os,browser,editor)
    @os = os
    @browser = browser
    @editor = editor
  end
  def os=(other)
    @os = other
  end
  def browser=(other)
    @browser = other
  end
  def editor=(other)
    @editor = other
  end
  def os
    @os
  end
  def browser
    @browser
  end
  def editor
    @editor
  end
end # lang_info




def run_tests(os,name)
  puts "Have you turned off SpiderOak or any other unneeded background programs? (y/n)"
  answer = gets.chomp.rstrip.lstrip
  if (answer == 'y') then
    puts "Omnisode tests for " + os
    puts "Queue tests"
    
    oss_tbl = Hash.new(0)
    lang_tbl = Hash.new(0)
    oss_tbl["linux"] = Os_info.new("linux",'/usr/bin/firefox','/usr/bin/emacs-x11')
    oss_tbl["cygwin"] = Os_info.new("cygwin","","/cygdrive/c/users/dennis/bin/emacs/emacs")
    oss_tbl["windows"] = Os_info.new("windows",'"c:\\Program Files (x86)\\Mozilla Firefox\\firefox"',"/cygdrive/c/users/dennis/bin/emacs/emacs")
    lang_tbl["c"] = Lang_info.new("c","gcc","c","u"," -Wno-write-strings -Wno-format-security -o ", "-lm ","dir","gcc")
    lang_tbl["c++"] = Lang_info.new("c++","g++","cpp","u"," -Wno-write-strings -Wno-format-security -o", " -lm ","dir","cpp")
    lang_tbl["ruby"] = Lang_info.new("ruby","ruby","rb","u"," ", " ","dir","ruby")
    lang_tbl["ruby_apfp"] = Lang_info.new("ruby","ruby","rapfp.rb","u"," "," ", "dir","ruby_apfp")
    lang_tbl["maxima"] = Lang_info.new("maxima","maxima","max","u"," -q --batch="," ","dir","maxima")
    lang_tbl["cmaple (Windows)"] = Lang_info.new("maple","cmaple","mxt","u"," "," ","dir","maple")
    lang_tbl["maple (Linux)"] = Lang_info.new("maple","maple","mxt","u"," "," ","dir","maple")
    
    
    # (lang,cmd,suffix,to_test,flags1,flags2,target)
    lang_tbl.each_key {|id|
      lang_tbl[id].to_test = get_answer(id)
    }
    lang_tbl.each_key{|id|
      if lang_tbl[id].to_test  then
        lang_tbl[id].target = get_target(os,name,lang_tbl[id].math)
      end
    }
    name_1 = name
    name = name + ".odes"
    # tested queued - Run selected
    
    oss_tbl.each_key{|os_key|
      if os == os_key then
        lang_tbl.each_key{|lang_key|
          if lang_tbl[lang_key].to_test then
            lang = lang_tbl[lang_key].lang
            puts 'testing ' + lang_tbl[lang_key].lang + ' with ' + oss_tbl[os_key].os
            if not tran(lang_tbl[lang_key].math + 'inc.rb' , File.join($TEMP_DIR, 'langinc.rb')) then
              puts "error copying include file 1"
              exit(1)
            end
            if not tran(lang_tbl[lang_key].math + 'inc.rb' , 'langinc.rb') then
              puts "error copying include file 2"
              exit(1)
            end
            tdir = File.join("html","omniresults", lang_tbl[lang_key].math + "_" + name_1 + "_" + os_key)
            puts "tdir CHECK " + tdir
            if not File.exists?(tdir) then
              puts "tdir MAKE " + tdir
              Dir.mkdir(tdir)
            end
            if File.exists?("ode.over") then
              if not tran('ode.over',File.join(tdir,"ode.over.txt")) then
                puts 'error copying ode.over'
                exit(1)
              end
            elsif not tran('ode.over.null', File.join(tdir,"ode.over.txt")) then
              puts 'error copying ode.null'
              exit(1)
            end
            
            puts 'running djdpre on atsgen.rb'
            cmd = 'ruby djdpre.rb <atsgen.rb' + ' >' + File.join($TEMP_DIR,'atsgentst.rb') 
            puts cmd
            if not system(cmd) then
              puts "error running djdpre on atsgen"
              exit(1)
            end
            puts 'running processed atsgen.rb  -- atsgentst.rb'
            cmd = 'ruby ' + File.join($TEMP_DIR, 'atsgentst.rb ') + '>' + File.join($TEMP_DIR,'mxout3.tmp') + ' 2>' + File.join($TEMP_DIR,'mxout4.tmp')
            puts cmd
            if not system(cmd) then
              puts "error running atsgen"
              exit(1)
            end

            puts "running djdpre on omnisode.rb"
            cmd = "ruby djdpre.rb <omnisode.rb >" + File.join($TEMP_DIR,"omnisodetst.rb")
            puts cmd
            if not system(cmd) then
              puts "error running djdpre on omnisode"
              exit(1)
            end
            
            fd = File.new(name,"r")
            
            while $linein = fd.gets do
              if not $linein.nil? then
                $linein = $linein.chomp.rstrip.lstrip
                odefile = getode()
#                puts "odefile sss = " + odefile
                if File.exists?(odefile + ".ode") then
                  remark = getremark()
                  single_test(lang_key,lang_tbl[lang_key].cmd,odefile,remark,oss_tbl[os_key].browser,lang_tbl[lang_key].flags1,lang_tbl[lang_key].flags2,"single",os,lang_tbl[lang_key].suffix,oss_tbl[os_key].editor,name_1,lang_tbl[lang_key].math)
                end
              end 
            end
            fd.close
          end
        }
        lang_tbl.each_key{|id|
          if lang_tbl[id].to_test  then
            browser = oss_tbl[os_key].browser
            if browser != "" then
              puts 'output in file:' + File.expand_path(File.join(lang_tbl[id].target, "table.html"))
              
#              cmd = browser + " " + "file:/" + File.expand_path(File.join("html","omniresults", lang_tbl[id].target, "table.html"))
#              puts 'execute ' +  cmd + ' (y/n)?'
#              ans = gets
#              if ans == 'y' then
#                system(cmd)
#              end
            end
          end
        }
      end
    }
  end # Spideroak
end # run tests

def tran(infile,outfile)
  puts "tran |" + infile + "| + |" + outfile + "|"

  fd1 = File.new(infile,"r")
  fd2 = File.new(outfile,"w")
  puts "tran " + infile + " " +  outfile
  while linein = fd1.gets do
    fd2.puts linein
  end
  fd2.flush
  fd1.close
  fd2.close
  return true
end

def tran2(infile1,infile2,outfile)
  fd1 = File.new(infile1,"r")
  fd2 = File.new(infile2,"r")
  fd3 = File.new(outfile,"w")
  puts "tran2 " + infile1 + " " + infile2 + " " +  outfile
  while linein = fd1.gets do
    fd3.puts linein
  end
  while linein = fd2.gets do
    fd3.puts linein
  end
  fd3.flush
  fd1.close
  fd2.close
  fd3.close
  return true
end

def tran3(infile1,infile2,infile3,outfile)
  fd1 = File.new(infile1,"r")
  fd2 = File.new(infile2,"r")
  fd3 = File.new(infile3,"r")
  fd4 = File.new(outfile,"w")
  puts "tran3 " + infile1 + " " + infile2 + " " + infile3 + " " +  outfile
  while linein = fd1.gets do
    fd4.puts linein
  end
  while linein = fd2.gets do
    fd4.puts linein
  end
  while linein = fd3.gets do
    fd4.puts linein
  end
  fd4.flush
  fd1.close
  fd2.close
  fd3.close
  fd4.close
  return true
end

def get_odes_list()
  name = 'no'
  while not File.exists?(name + ".odes")
    puts "Enter odes list file list name"
    name=gets.chomp.rstrip.lstrip
  end
  return(name)
end

def main
  get_temp()
  os = get_os()
  odes_list = get_odes_list()
  run_tests(os,odes_list)
end
main()

 
 
