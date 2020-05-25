# Begin Function number 2
def omniout_str(iolevel,str)
#INDENT(1)
if (glob_iolevel >= iolevel)  then # if number 1
 # INDENT(1)
puts str

 # INDENT(2)
 end# end if 1

 INDENT(2)
 end # End Function number 2
# Begin Function number 3
def omniout_str_noeol(iolevel,str)
#INDENT(1)
if (glob_iolevel >= iolevel) then # if number 1
 # INDENT(1)
printf("%s", str)

 # INDENT(2)
 end# end if 1

 INDENT(2)
 end # End Function number 3
# Begin Function number 4
def omniout_labstr(iolevel,label,str)
#INDENT(1)
if (glob_iolevel >= iolevel)  then # if number 1
 # INDENT(1)
puts label + str

 # INDENT(2)
 end# end if 1

 INDENT(2)
 end # End Function number 4
# Begin Function number 5
def omniout_float(iolevel,prelabel,prelen,value,vallen,postlabel)
#INDENT(1)
if (glob_iolevel >= iolevel)  then # if number 1
 # INDENT(1)
puts prelabel.ljust(30) + value.to_s + postlabel

 # INDENT(2)
 end# end if 1

 INDENT(2)
 end # End Function number 5
# Begin Function number 6
def omniout_int(iolevel,prelabel,prelen,value,vallen,postlabel)
#INDENT(1)
if (glob_iolevel >= iolevel)  then # if number 1
 # INDENT(1)
puts prelabel.ljust(32) + value.to_s + postlabel

 # INDENT(2)
 end# end if 1

 INDENT(2)
 end # End Function number 6
# Begin Function number 7
def dump_series(iolevel,dump_label,series_name,arr_series,numb)
#INDENT(1)
if (glob_iolevel >= iolevel)  then # if number 1
 # INDENT(1)
  i = 1
  while (i <= numb) do 
puts dump_label + series_name  + "[" + i.to_s + "]" + arr_series[i].to_s
    i += 1
end
end

 INDENT(2)
 end # End Function number 7
# Begin Function number 8
def dump_series_2(iolevel,dump_label,series_name2,arr_series2,numb,subnum,arr_x)
#INDENT(1)
if (glob_iolevel >= iolevel)  then # if number 2
 # INDENT(1)
  sub = 1;
  while (sub <= subnum) do 
    i =  1;
  while (i <= numb) do 
puts dump_label + series_name2 + "[" + sub.to_s + "," + i.to_s + "]" + arr_series2[sub,i].to_s

INDENT(2)
 end# end do number 0
sub += 1;

INDENT(2)
 end# end do number -1

 # INDENT(2)
 end# end if 2

 INDENT(2)
 end # End Function number 8
# Begin Function number 9
def cs_info(iolevel,str)
#INDENT(1)
if (glob_iolevel >= iolevel)  then # if number 2
 # INDENT(1)
puts "cs_info " + str  + " glob_correct_start_flag = " , glob_correct_start_flag.to_s + "glob_h := " + glob_h + "glob_reached_optimal_h := "  +  glob_reached_optimal_h

 # INDENT(2)
 end# end if 2

 INDENT(2)
 end # End Function number 9
# Begin Function number 10
def logitem_time(fd,secs_in)
#INDENT(1)
fd.printf("<td>")
  if (secs_in >= 0)  then # if number 2
 # INDENT(1)
    years_int  =  int_trunc(secs_in / glob_sec_in_year)
    sec_temp  =  (secs_in % glob_sec_in_year)
    days_int  =  int_trunc(sec_temp / glob_sec_in_day) 
    sec_temp  =  (sec_temp % glob_sec_in_day) 
    hours_int  =  int_trunc(sec_temp / glob_sec_in_hour)
    sec_temp  =  (sec_temp % glob_sec_in_hour)
    minutes_int  = int_trunc(sec_temp / glob_sec_in_minute)
    sec_int  = (sec_temp % glob_sec_in_minute)
     
if  (years_int > 0)  then # if number 3
 # INDENT(1)
fd.printf(years_int.to_s + " Years " + days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")

 #INDENT(2) 
  elsif 
 (days_int > 0)  then # if number 4
 # INDENT(1)
fd.printf(days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")

 #INDENT(2) 
  elsif 
 (hours_int > 0)  then # if number 5
 # INDENT(1)
fd.printf(hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")

 #INDENT(2) 
  elsif 
 (minutes_int > 0)  then # if number 6
 # INDENT(1)
fd.printf(minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds")

#INDENT(2)
 else 
 #INDENT(1)
 
fd.printf(sec_int.to_s + " Seconds")

 # INDENT(2)
 end# end if 6

#INDENT(2)
 else 
 #INDENT(1)
 
fd.printf(" 0.0 Seconds")

 # INDENT(2)
 end# end if 5
fd.printf("</td>")

 INDENT(2)
 end # End Function number 10
# Begin Function number 11
def omniout_timestr(secs_in)
#INDENT(1)
  if (secs_in >= 0)  then # if number 5
 # INDENT(1)
    years_int  =  int_trunc(secs_in / glob_sec_in_year)
    sec_temp  =  (secs_in % glob_sec_in_year)
    days_int  =  int_trunc(sec_temp / glob_sec_in_day) 
    sec_temp  =  (sec_temp % glob_sec_in_day) 
    hours_int  =  int_trunc(sec_temp / glob_sec_in_hour)
    sec_temp  =  (sec_temp % glob_sec_in_hour)
    minutes_int  = int_trunc(sec_temp / glob_sec_in_minute)
    sec_int  = (sec_temp % glob_sec_in_minute)
     
if  (years_int > 0)  then # if number 6
 # INDENT(1)
puts years_int.to_s + " Years " + days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"

 #INDENT(2) 
  elsif 
 (days_int > 0)  then # if number 7
 # INDENT(1)
puts days_int.to_s + " Days " + hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"

 #INDENT(2) 
  elsif 
 (hours_int > 0)  then # if number 8
 # INDENT(1)
puts hours_int.to_s + " Hours " + minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"

 #INDENT(2) 
  elsif 
 (minutes_int > 0)  then # if number 9
 # INDENT(1)
puts minutes_int.to_s + " Minutes " + sec_int.to_s + " Seconds"

#INDENT(2)
 else 
 #INDENT(1)
 
puts sec_int.to_s + " Seconds"

 # INDENT(2)
 end# end if 9

#INDENT(2)
 else 
 #INDENT(1)
 
puts " 0.0 Seconds"

 # INDENT(2)
 end# end if 8

 INDENT(2)
 end # End Function number 11
# Begin Function number 12
def zero_ats_ar(arr_a) 
#INDENT(1)
 
 
 
 
 
iii  = 1
while (iii <= ATS_MAX_TERMS) do # do number -1
 # INDENT(1)
arr_a [iii] = glob__0
iii  =  iii + 1

INDENT(2)
 end# end do number -1
 

 INDENT(2)
 end # End Function number 12
# Begin Function number 13
def ats(mmm_ats,arr_a,arr_b,jjj_ats) 
#INDENT(1)
 
 
 
 
 
 
 
  ret_ats  = glob__0
  if (jjj_ats <=  mmm_ats)  then # if number 8
 # INDENT(1)
    ma_ats  =  mmm_ats + 1
    iii_ats  =  jjj_ats
    while (iii_ats <= mmm_ats) do # do number -1
 # INDENT(1)
      lll_ats  =  ma_ats - iii_ats
if ((lll_ats <= ATS_MAX_TERMS  and (iii_ats <= ATS_MAX_TERMS) ))  then # if number 9
 # INDENT(1)
      ret_ats  =  ret_ats + c(arr_a[iii_ats])*c(arr_b[lll_ats])

 # INDENT(2)
 end# end if 9
      iii_ats  =  iii_ats + 1

INDENT(2)
 end# end do number -1

 # INDENT(2)
 end# end if 8
 return ( ret_ats)
 

 INDENT(2)
 end # End Function number 13
# Begin Function number 14
def att(mmm_att,arr_aa,arr_bb,jjj_att) 
#INDENT(1)
 
 
 
 
 
 
 
  ret_att  = glob__0
  if (jjj_att < mmm_att)  then # if number 8
 # INDENT(1)
    ma_att  =  mmm_att + 2
    iii_att  =  jjj_att
    while ((iii_att < mmm_att) and (iii_att <= ATS_MAX_TERMS) )   do # do number -1
 # INDENT(1)
      lll_att  =  ma_att - iii_att
      al_att  =  (lll_att - 1)
if ((lll_att <= ATS_MAX_TERMS  and (iii_att <= ATS_MAX_TERMS) ))  then # if number 9
 # INDENT(1)
      ret_att  =   ret_att + c(arr_aa[iii_att])*c(arr_bb[lll_att])* c(al_att)

 # INDENT(2)
 end# end if 9
      iii_att  =  iii_att + 1

INDENT(2)
 end# end do number -1
    ret_att  =  ret_att / c(mmm_att) 

 # INDENT(2)
 end# end if 8
 return ( ret_att)
 

 INDENT(2)
 end # End Function number 14
# Begin Function number 15
def logditto(file)
#INDENT(1)
file.printf("<td>")
file.printf("ditto")
file.printf("</td>")

 INDENT(2)
 end # End Function number 15
# Begin Function number 16
def logitem_integer(file,n)
#INDENT(1)
file.printf("<td>")
file.printf("%d",n)
file.printf("</td>")

 INDENT(2)
 end # End Function number 16
# Begin Function number 17
def logitem_str(file,str)
#INDENT(1)
file.printf("<td>")
file.printf(str.to_s)
file.printf("</td>")

 INDENT(2)
 end # End Function number 17
# Begin Function number 18
def logitem_good_digits(file,rel_error)
#INDENT(1)
 
 
 
 
 
file.printf("<td>")
file.printf("%d",glob_min_good_digits)
file.printf("</td>")
 

 INDENT(2)
 end # End Function number 18
# Begin Function number 19
def log_revs(file,revs)
#INDENT(1)
file.printf(revs.to_s)

 INDENT(2)
 end # End Function number 19
# Begin Function number 20
def logitem_float(file,x)
#INDENT(1)
file.printf("<td>")
file.printf(x.to_s)
file.printf("</td>")

 INDENT(2)
 end # End Function number 20
# Begin Function number 21
def logitem_h_reason(file)
#INDENT(1)
 
file.printf("<td>")
if (glob_h_reason  == 1) then # if number 8
 # INDENT(1)
file.printf("Max H")

 #INDENT(2) 
  elsif 
(glob_h_reason == 2) then # if number 9
 # INDENT(1)
file.printf("Display Interval")

 #INDENT(2) 
  elsif 
(glob_h_reason == 3) then # if number 10
 # INDENT(1)
file.printf("Optimal")

 #INDENT(2) 
  elsif 
(glob_h_reason == 4) then # if number 11
 # INDENT(1)
file.printf("Pole Accuracy")

 #INDENT(2) 
  elsif 
(glob_h_reason == 5) then # if number 12
 # INDENT(1)
file.printf("Min H (Pole)")

 #INDENT(2) 
  elsif 
(glob_h_reason == 6) then # if number 13
 # INDENT(1)
file.printf("Pole")

 #INDENT(2) 
  elsif 
(glob_h_reason == 7) then # if number 14
 # INDENT(1)
file.printf("Opt Iter")

#INDENT(2)
 else 
 #INDENT(1)
 
file.printf("Impossible")

 # INDENT(2)
 end# end if 14
file.printf("</td>")

 INDENT(2)
 end # End Function number 21
# Begin Function number 22
def logstart(file)
#INDENT(1)
file.printf("<tr>")

 INDENT(2)
 end # End Function number 22
# Begin Function number 23
def logend(file)
#INDENT(1)
file.printf("</tr>")

 INDENT(2)
 end # End Function number 23
# Begin Function number 24
def chk_data() 
#INDENT(1)
 
 
 
 
 
  errflag  =  false
  
  if (glob_max_iter < 2)  then # if number 14
 # INDENT(1)
    omniout_str(ALWAYS,"Illegal max_iter")
    errflag  =  true

 # INDENT(2)
 end# end if 14
  if (errflag)   then # if number 14
 # INDENT(1)
 
 

 # INDENT(2)
 end# end if 14
 

 INDENT(2)
 end # End Function number 24
# Begin Function number 25
def comp_expect_sec(t_end2,t_start2,t2,clock_sec2) 
#INDENT(1)
 
 
 
 
 
 
ms2 = c(clock_sec2)
sub1 = c(t_end2-t_start2)
sub2 = c(t2-t_start2)
if (sub1 == glob__0)  then # if number 14
 # INDENT(1)
sec_left = glob__0

#INDENT(2)
 else 
 #INDENT(1)
 
if (sub2 > glob__0)  then # if number 15
 # INDENT(1)
rrr = (sub1/sub2)
sec_left  = rrr * c(ms2) - c(ms2)

#INDENT(2)
 else 
 #INDENT(1)
 
sec_left  = glob__0

 # INDENT(2)
 end# end if 15

 # INDENT(2)
 end# end if 14
 return ( sec_left)
 

 INDENT(2)
 end # End Function number 25
# Begin Function number 26
def comp_percent(t_end2,t_start2, t2) 
#INDENT(1)
 
 
 
 
 
  sub1  =  (t_end2-t_start2)
  sub2  =  (t2-t_start2)
  if (sub2 > glob_small_float)  then # if number 14
 # INDENT(1)
    rrr  =  (glob__100*sub2)/sub1

#INDENT(2)
 else 
 #INDENT(1)
 
    rrr  =  0.0

 # INDENT(2)
 end# end if 14
 return (   rrr)
 

 INDENT(2)
 end # End Function number 26
# Begin Function number 27
def comp_rad_from_ratio(term1,term2,last_no) 
#INDENT(1)
#TOP TWO TERM RADIUS ANALYSIS
 
 
 
 
if (float_abs(term2) > glob__0)  then # if number 14
 # INDENT(1)
ret =  float_abs(term1 * glob_h / term2)

#INDENT(2)
 else 
 #INDENT(1)
 
ret = glob_larger_float

 # INDENT(2)
 end# end if 14
 return (   ret)
#BOTTOM TWO TERM RADIUS ANALYSIS

 INDENT(2)
 end # End Function number 27
# Begin Function number 28
def comp_ord_from_ratio(term1,term2,last_no) 
#INDENT(1)
#TOP TWO TERM ORDER ANALYSIS
 
 
 
 
if (float_abs(term2) > glob__0)  then # if number 14
 # INDENT(1)
ret = glob__1 +  float_abs(term2) * c(last_no) * ln(float_abs(term1 * glob_h / term2))/ln(c(last_no))

#INDENT(2)
 else 
 #INDENT(1)
 
ret = glob_larger_float

 # INDENT(2)
 end# end if 14
 return (   ret)
#BOTTOM TWO TERM ORDER ANALYSIS

 INDENT(2)
 end # End Function number 28
# Begin Function number 29
def c(in_val) 
#INDENT(1)
#To Force Conversion when needed
 
 
 
ret = in_val
 return (   ret)
#End Conversion

 INDENT(2)
 end # End Function number 29
# Begin Function number 30
def comp_rad_from_three_terms(term1,term2,term3,last_no) 
#INDENT(1)
#TOP THREE TERM RADIUS ANALYSIS
 
 
 
 
temp = float_abs(term2*term2*c(last_no)+glob__m2*term2*term2-term1*term3*c(last_no)+term1*term3)
if (float_abs(temp) > glob__0)  then # if number 14
 # INDENT(1)
ret = float_abs((term2*glob_h*term1)/(temp))

#INDENT(2)
 else 
 #INDENT(1)
 
ret = glob_larger_float

 # INDENT(2)
 end# end if 14
 return ( ret)
#BOTTOM THREE TERM RADIUS ANALYSIS

 INDENT(2)
 end # End Function number 30
# Begin Function number 31
def comp_ord_from_three_terms(term1,term2,term3,last_no) 
#INDENT(1)
#TOP THREE TERM ORDER ANALYSIS
 
 
 
ret = float_abs((glob__4*term1*term3*c(last_no)-glob__3*term1*term3-glob__4*term2*term2*c(last_no)+glob__4*term2*term2+term2*term2*c(last_no*last_no)-term1*term3*c(last_no*last_no))/(term2*term2*c(last_no)-glob__2*term2*term2-term1*term3*c(last_no)+term1*term3))
 return ( ret)
#TOP THREE TERM ORDER ANALYSIS

 INDENT(2)
 end # End Function number 31
# Begin Function number 32
def comp_rad_from_six_terms(term1,term2,term3,term4,term5,term6,last_no) 
#INDENT(1)
#TOP SIX TERM RADIUS ANALYSIS
 
 
 
 
if ((term5  != glob__0) and (term4  != glob__0) and (term3  != glob__0) and  (term2  != glob__0) and (term1  != glob__0)) then # if number 14
 # INDENT(1)
rm0 = term6/term5
rm1 = term5/term4
rm2 = term4/term3
rm3 = term3/term2
rm4 = term2/term1
nr1 =  c(last_no-1)*rm0 - glob__2*c(last_no-2)*rm1 + c(last_no-3)*rm2
nr2 =  c(last_no-2)*rm1 - glob__2*c(last_no-3)*rm2 + c(last_no-4)*rm3
dr1 =  glob__m1/rm1 + glob__2/rm2 - glob__1/rm3
dr2 =  glob__m1/rm2 + glob__2/rm3 - glob__1/rm4
ds1 =  glob__3/rm1 - glob__8/rm2 + glob__5/rm3
ds2 =  glob__3/rm2 - glob__8/rm3 + glob__5/rm4
if ((float_abs(nr1 * dr2 - nr2 * dr1)  ==  glob__0)  or  (float_abs(dr1) == glob__0))  then # if number 15
 # INDENT(1)
rad_c =  glob_larger_float
ord_no =  glob_larger_float

#INDENT(2)
 else 
 #INDENT(1)
 
if (float_abs(nr1*dr2 - nr2 * dr1) > glob__0)  then # if number 16
 # INDENT(1)
rcs =  ((ds1*dr2 - ds2*dr1 +dr1*dr2)/(nr1*dr2 - nr2 * dr1))
#(Manuels)  rcs  =  (ds1*dr2 - ds2*dr1)/(nr1*dr2 - nr2 * dr1)
ord_no =  (rcs*nr1 - ds1)/(glob__2*dr1) -c(last_no)/glob__2
if (float_abs(rcs)  != glob__0)  then # if number 17
 # INDENT(1)
if (rcs > glob__0)  then # if number 18
 # INDENT(1)
rad_c  =  sqrt(rcs) * float_abs(glob_h)

#INDENT(2)
 else 
 #INDENT(1)
 
rad_c  =  glob_larger_float
ord_no =  glob_larger_float

 # INDENT(2)
 end# end if 18

#INDENT(2)
 else 
 #INDENT(1)
 
rad_c =  glob_larger_float
ord_no =  glob_larger_float

 # INDENT(2)
 end# end if 17

#INDENT(2)
 else 
 #INDENT(1)
 
rad_c =  glob_larger_float
ord_no =  glob_larger_float

 # INDENT(2)
 end# end if 16

 # INDENT(2)
 end# end if 15

#INDENT(2)
 else 
 #INDENT(1)
 
rad_c =  glob_larger_float
ord_no =  glob_larger_float

 # INDENT(2)
 end# end if 14
glob_six_term_ord_save =  ord_no
 return ( rad_c)
#BOTTOM SIX TERM RADIUS ANALYSIS

 INDENT(2)
 end # End Function number 32
# Begin Function number 33
def comp_ord_from_six_terms(term1,term2,term3,term4,term5,term6,last_no) 
#INDENT(1)
 
#TOP SIX TERM ORDER ANALYSIS
#TOP SAVED FROM SIX TERM RADIUS ANALYSIS
 return ( glob_six_term_ord_save)
#BOTTOM SIX TERM ORDER ANALYSIS

 INDENT(2)
 end # End Function number 33
# Begin Function number 34
def factorial_2(nnn) 
#INDENT(1)
 
 
 
if (nnn > 0)  then # if number 14
 # INDENT(1)
 return ( nnn * factorial_2(nnn - 1))

#INDENT(2)
 else 
 #INDENT(1)
 
 return ( 1.0)

 # INDENT(2)
 end# end if 14

 INDENT(2)
 end # End Function number 34
# Begin Function number 35
def factorial_1(nnn) 
#INDENT(1)
 
 
 
 
 
if (nnn <= ATS_MAX_TERMS) then # if number 14
 # INDENT(1)
if (array_fact_1[nnn] == 0) then # if number 15
 # INDENT(1)
ret = factorial_2(nnn)
array_fact_1[nnn] = ret

#INDENT(2)
 else 
 #INDENT(1)
 
ret = array_fact_1[nnn]

 # INDENT(2)
 end# end if 15

#INDENT(2)
 else 
 #INDENT(1)
 
ret = factorial_2(nnn)

 # INDENT(2)
 end# end if 14
 return ( ret)
 

 INDENT(2)
 end # End Function number 35
# Begin Function number 36
def factorial_3(mmm,nnn) 
#INDENT(1)
 
 
 
 
 
if ((nnn <= ATS_MAX_TERMS)  and  (mmm <= ATS_MAX_TERMS)) then # if number 14
 # INDENT(1)
if (array_fact_2[mmm][nnn] == 0) then # if number 15
 # INDENT(1)
ret = factorial_1(mmm)/factorial_1(nnn)
array_fact_2[mmm][nnn] = ret

#INDENT(2)
 else 
 #INDENT(1)
 
ret = array_fact_2[mmm][nnn]

 # INDENT(2)
 end# end if 15

#INDENT(2)
 else 
 #INDENT(1)
 
ret = factorial_2(mmm)/factorial_2(nnn)

 # INDENT(2)
 end# end if 14
 return ( ret)
 

 INDENT(2)
 end # End Function number 36
# Begin Function number 37
def convfloat(mmm) 
#INDENT(1)
 
 return(mmm.to_f)
 

 INDENT(2)
 end # End Function number 37
# Begin Function number 38
def elapsed_time_seconds()
#INDENT(1)
 
 t = Time.now
 return(t.to_i)
 
 

 INDENT(2)
 end # End Function number 38
# Begin Function number 39
def expt(x,y)
#INDENT(1)
if ((x <= 0.0) and (y < 0.0)) then # if number 14
 # INDENT(1)
puts "expt error x = " + x.to_s + "y = " + y.to_s

 # INDENT(2)
 end# end if 14
return(x**y)

 INDENT(2)
 end # End Function number 39
# Begin Function number 40
def Si(x)
#INDENT(1)
return(0.0)

 INDENT(2)
 end # End Function number 40
# Begin Function number 41
def Ci(x)
#INDENT(1)
return(0.0)

 INDENT(2)
 end # End Function number 41
# Begin Function number 42
def float_abs(x)
#INDENT(1)
return(x.abs)

 INDENT(2)
 end # End Function number 42
# Begin Function number 43
def int_abs(x)
#INDENT(1)
return(x.abs)

 INDENT(2)
 end # End Function number 43
# Begin Function number 44
def exp(x)
#INDENT(1)
return(Math.exp(x))

 INDENT(2)
 end # End Function number 44
# Begin Function number 45
def int_trunc(x)
#INDENT(1)
return(x.to_i)

 INDENT(2)
 end # End Function number 45
# Begin Function number 46
def floor(x)
#INDENT(1)
return(x.floor)

 INDENT(2)
 end # End Function number 46
# Begin Function number 47
def round(x)
#INDENT(1)
return(x.round)

 INDENT(2)
 end # End Function number 47
# Begin Function number 48
def sin(x)
#INDENT(1)
return(Math.sin(x))

 INDENT(2)
 end # End Function number 48
# Begin Function number 49
def neg(x)
#INDENT(1)
return(-x)

 INDENT(2)
 end # End Function number 49
# Begin Function number 50
def cos(x)
#INDENT(1)
return(Math.cos(x))

 INDENT(2)
 end # End Function number 50
# Begin Function number 51
def tan(x)
#INDENT(1)
return(Math.tan(x))

 INDENT(2)
 end # End Function number 51
# Begin Function number 52
def arccos(x)
#INDENT(1)
return(Math.acos(x))

 INDENT(2)
 end # End Function number 52
# Begin Function number 53
def arccosh(x)
#INDENT(1)
return(Math.acosh(x))

 INDENT(2)
 end # End Function number 53
# Begin Function number 54
def arcsin(x)
#INDENT(1)
return(Math.asin(x))

 INDENT(2)
 end # End Function number 54
# Begin Function number 55
def arcsinh(x)
#INDENT(1)
return(Math.asinh(x))

 INDENT(2)
 end # End Function number 55
# Begin Function number 56
def arctan(x)
#INDENT(1)
return(Math.atan(x))

 INDENT(2)
 end # End Function number 56
# Begin Function number 57
def arctanh(x)
#INDENT(1)
return(Math.atanh(x))

 INDENT(2)
 end # End Function number 57
# Begin Function number 58
def cosh(x)
#INDENT(1)
return(Math.cosh(x))

 INDENT(2)
 end # End Function number 58
# Begin Function number 59
def erf(x)
#INDENT(1)
return(Math.erf(x))

 INDENT(2)
 end # End Function number 59
# Begin Function number 60
def log(x)
#INDENT(1)
return(Math.log(x))

 INDENT(2)
 end # End Function number 60
# Begin Function number 61
def ln(x)
#INDENT(1)
return(Math.log(x))

 INDENT(2)
 end # End Function number 61
# Begin Function number 62
def log10(x)
#INDENT(1)
return(Math.log10(x))

 INDENT(2)
 end # End Function number 62
# Begin Function number 63
def sinh(x)
#INDENT(1)
return(Math.sinh(x))

 INDENT(2)
 end # End Function number 63
# Begin Function number 64
def tanh(x)
#INDENT(1)
return(Math.tanh(x))

 INDENT(2)
 end # End Function number 64
# Begin Function number 65
def sqrt(x)
#INDENT(1)
return(Math.sqrt(x))

 INDENT(2)
 end # End Function number 65
# Begin Function number 66
def array2d(op3,op4)
#INDENT(1)
i = 0
x1 = Array.new(op3.to_i + 1)
while i <= op3.to_i + 1  do # do number -1
 # INDENT(1)
x1[i] = Array.new(op4.to_i + 1)
i += 1

INDENT(2)
 end# end do number -1
return x1

 INDENT(2)
 end # End Function number 66
# Begin Function number 67
def estimated_needed_step_error(x_start,x_end,estimated_h,estimated_answer)
#INDENT(1)
 
 
 
 
 
omniout_float(ALWAYS,"glob_desired_digits_correct",32,glob_desired_digits_correct,32,"")
desired_abs_gbl_error = expt(glob__10,c( -glob_desired_digits_correct)) * c(float_abs(c(estimated_answer)))
omniout_float(ALWAYS,"estimated_h",32,estimated_h,32,"")
omniout_float(ALWAYS,"estimated_answer",32,estimated_answer,32,"")
omniout_float(ALWAYS,"desired_abs_gbl_error",32,desired_abs_gbl_error,32,"")
range = (x_end - x_start)
omniout_float(ALWAYS,"range",32,range,32,"")
estimated_steps = range / estimated_h
omniout_float(ALWAYS,"estimated_steps",32,estimated_steps,32,"")
step_error = (c(float_abs(desired_abs_gbl_error) /sqrt(c( estimated_steps))/c(ATS_MAX_TERMS)))
omniout_float(ALWAYS,"step_error",32,step_error,32,"")
 return ( (step_error))
 

 INDENT(2)
 end # End Function number 67
