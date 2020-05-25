void omniout_str(int iolevel,char *str)
 { 
//INDENT(1)
if (glob_iolevel >= iolevel) { 
printf("%s\n",str);
}

 INDENT(2)
 } // End Function number1
void omniout_str_noeol(int iolevel,char *str)
 { 
//INDENT(1)
if (glob_iolevel >= iolevel) { 
printf("%s",str);
}

 INDENT(2)
 } // End Function number1
void omniout_labstr(int iolevel,char *label,char *str)
 { 
//INDENT(1)
if (glob_iolevel >= iolevel) {
printf("%s = %s\n",label,str);
}

 INDENT(2)
 } // End Function number1
void omniout_float(int iolevel,char *prelabel,int prelen,double value,int vallen,char *postlabel)
 { 
//INDENT(1)
if (glob_iolevel >= iolevel) { 
if (vallen == 4) {
printf("%-30s = %-42.4g %s \n",prelabel,value, postlabel);
}
else
{
printf("%-30s = %-42.16g %s \n",prelabel,value, postlabel);
}
}

 INDENT(2)
 } // End Function number1
void omniout_int(int iolevel,char *prelabel,int prelen,int value,int vallen,char *postlabel)
 { 
//INDENT(1)
if (glob_iolevel >= iolevel) { 
if (vallen == 5) {
printf("%-30s = %-32d  %s\n",prelabel,value, postlabel);
}
else
{
printf("%-30s = %-32d  %s \n",prelabel,value, postlabel);
}
}

 INDENT(2)
 } // End Function number1
void logitem_time(FILE *fd,double secs_in)
 { 
//INDENT(1)
 int days_int, hours_int, minutes_int, sec_int, years_int,sec_temp;
 double sec_dbl;
fprintf(fd,"<td>");
  if (secs_in >= 0) 
 { /* if number 1*/ 
/* INDENT(1) */
    years_int  =  (int_trunc(secs_in) / glob_sec_in_year);
    sec_temp  =  (int_trunc(secs_in) % glob_sec_in_year);
    days_int  =  (sec_temp / glob_sec_in_day) ;
    sec_temp  =  (sec_temp % glob_sec_in_day) ;
    hours_int  =  (sec_temp / glob_sec_in_hour);
    sec_temp  =  (sec_temp % glob_sec_in_hour);
    minutes_int  = (sec_temp / glob_sec_in_minute);
    sec_int  = (sec_temp % glob_sec_in_minute);
sec_dbl  = secs_in - (double)(years_int * glob_sec_in_year + days_int * glob_sec_in_day + hours_int * glob_sec_in_hour + minutes_int * glob_sec_in_minute);
     
 if  (years_int > 0) 
 { /* if number 2*/ 
/* INDENT(1) */
fprintf(fd,"%d Years %d Days %d Hours %d Minutes %3.1f Seconds",years_int,days_int,hours_int,minutes_int,sec_dbl);
 
} # INDENT(2) 
 } else if 
 (days_int > 0) 
 { /* if number 3*/ 
/* INDENT(1) */
fprintf(fd,"%d Days %d Hours %d Minutes %3.1f Seconds",days_int,hours_int,minutes_int,sec_dbl);
 
} # INDENT(2) 
 } else if 
 (hours_int > 0) 
 { /* if number 4*/ 
/* INDENT(1) */
fprintf(fd,"%d Hours %d Minutes %3.1f Seconds",hours_int,minutes_int,sec_dbl);
 
} # INDENT(2) 
 } else if 
 (minutes_int > 0) 
 { /* if number 5*/ 
/* INDENT(1) */
fprintf(fd,"%d Minutes %3.1f Seconds",minutes_int,sec_dbl);

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
fprintf(fd,"%3.1f Seconds",sec_dbl);

 /* INDENT(2) */
  }/* end if 5*/

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
fprintf(fd,"0.0 Seconds");

 /* INDENT(2) */
  }/* end if 4*/
fprintf(fd,"</td>");

 INDENT(2)
 } // End Function number1
void omniout_timestr(double secs_in)
 { 
//INDENT(1)
 int days_int, hours_int, minutes_int, sec_int, years_int,sec_temp;
 double sec_dbl;
  if (secs_in >= 0.0) 
 { /* if number 4*/ 
/* INDENT(1) */
    years_int  =  (int_trunc(secs_in) / glob_sec_in_year);
    sec_temp  =  (int_trunc(secs_in) % glob_sec_in_year);
    days_int  =  (sec_temp / glob_sec_in_day) ;
    sec_temp  =  (sec_temp % glob_sec_in_day) ;
    hours_int  =  (sec_temp / glob_sec_in_hour);
    sec_temp  =  (sec_temp % glob_sec_in_hour);
    minutes_int  = (sec_temp / glob_sec_in_minute);
    sec_int  = (sec_temp % glob_sec_in_minute);
sec_dbl  = secs_in - (double)(years_int * glob_sec_in_year + days_int * glob_sec_in_day + hours_int * glob_sec_in_hour + minutes_int * glob_sec_in_minute);
     
 if  (years_int > 0) 
 { /* if number 5*/ 
/* INDENT(1) */
printf(" = %d Years %d Days %d Hours %d Minutes %3.1f Seconds\n",years_int,days_int,hours_int,minutes_int,sec_dbl);
 
} # INDENT(2) 
 } else if 
 (days_int > 0) 
 { /* if number 6*/ 
/* INDENT(1) */
printf(" = %d Days %d Hours %d Minutes %3.1f Seconds\n",days_int,hours_int,minutes_int,sec_dbl);
 
} # INDENT(2) 
 } else if 
 (hours_int > 0) 
 { /* if number 7*/ 
/* INDENT(1) */
printf(" = %d Hours %d Minutes %3.1f Seconds\n",hours_int,minutes_int,sec_dbl);
 
} # INDENT(2) 
 } else if 
 (minutes_int > 0) 
 { /* if number 8*/ 
/* INDENT(1) */
printf(" = %d Minutes %3.1f Seconds\n",minutes_int,sec_dbl);

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
printf(" = %3.1f Seconds\n",sec_dbl);

 /* INDENT(2) */
  }/* end if 8*/

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
printf(" 0.0 Seconds\n");

 /* INDENT(2) */
  }/* end if 7*/

 INDENT(2)
 } // End Function number1
double zero_ats_ar(double *arr_a) 
 { 
//INDENT(1)
 
 
 
 int iii;
 
iii  = 1;
while (iii <= ATS_MAX_TERMS) { /* do number 1*/
/* INDENT(1) */
arr_a [iii] = glob__0;
iii  =  iii + 1;

INDENT(2)
 }/* end do number 1*/
 

 INDENT(2)
 } // End Function number1
double ats(int mmm_ats,double *arr_a,double *arr_b,int jjj_ats) 
 { 
//INDENT(1)
 
 
 
 int iii_ats, lll_ats, ma_ats;
 double   ret_ats;
 
 
  ret_ats  = glob__0;
  if (jjj_ats <=  mmm_ats) 
 { /* if number 7*/ 
/* INDENT(1) */
    ma_ats  =  mmm_ats + 1;
    iii_ats  =  jjj_ats;
    while (iii_ats <= mmm_ats) { /* do number 1*/
/* INDENT(1) */
      lll_ats  =  ma_ats - iii_ats;
if ((lll_ats <= ATS_MAX_TERMS  && (iii_ats <= ATS_MAX_TERMS) )) 
 { /* if number 8*/ 
/* INDENT(1) */
      ret_ats  =  ret_ats + c(arr_a[iii_ats])*c(arr_b[lll_ats]);

 /* INDENT(2) */
  }/* end if 8*/
;
      iii_ats  =  iii_ats + 1;

INDENT(2)
 }/* end do number 1*/

 /* INDENT(2) */
  }/* end if 7*/
;
return ret_ats;
 

 INDENT(2)
 } // End Function number1
double att(int mmm_att,double *arr_aa,double *arr_bb,int jjj_att) 
 { 
//INDENT(1)
 
 
 
 int al_att, iii_att,lll_att, ma_att;
 double  ret_att;
 
 
  ret_att  = glob__0;
  if (jjj_att < mmm_att) 
 { /* if number 7*/ 
/* INDENT(1) */
    ma_att  =  mmm_att + 2;
    iii_att  =  jjj_att;
    while ((iii_att < mmm_att) && (iii_att <= ATS_MAX_TERMS) )   { /* do number 1*/
/* INDENT(1) */
      lll_att  =  ma_att - iii_att;
      al_att  =  (lll_att - 1);
if ((lll_att <= ATS_MAX_TERMS  && (iii_att <= ATS_MAX_TERMS) )) 
 { /* if number 8*/ 
/* INDENT(1) */
      ret_att  =   ret_att + c(arr_aa[iii_att])*c(arr_bb[lll_att])* c(al_att);

 /* INDENT(2) */
  }/* end if 8*/
;
      iii_att  =  iii_att + 1;

INDENT(2)
 }/* end do number 1*/
;
    ret_att  =  ret_att / c(mmm_att) ;

 /* INDENT(2) */
  }/* end if 7*/
;
return ret_att;
 

 INDENT(2)
 } // End Function number1
void logditto(FILE * file)
 { 
//INDENT(1)
fprintf(file,"<td>");
fprintf(file,"ditto");
fprintf(file,"</td>");

 INDENT(2)
 } // End Function number1
void logitem_integer(FILE * file,int n)
 { 
//INDENT(1)
fprintf(file,"<td>");
fprintf(file,"%d",n);
fprintf(file,"</td>");

 INDENT(2)
 } // End Function number1
void logitem_str(FILE * file,char * str)
 { 
//INDENT(1)
fprintf(file,"<td>");
fprintf(file,str);
fprintf(file,"</td>");

 INDENT(2)
 } // End Function number1
void logitem_good_digits(FILE * file,double rel_error)
 { 
//INDENT(1)
 
 
 
 
 int good_digits;
fprintf(file,"<td>");
fprintf(file,"%d",glob_min_good_digits);
fprintf(file,"</td>");
 

 INDENT(2)
 } // End Function number1
void log_revs(FILE * file,char * revs)
 { 
//INDENT(1)
fprintf(file,revs);

 INDENT(2)
 } // End Function number1
void logitem_float(FILE * file,double x)
 { 
//INDENT(1)
fprintf(file,"<td>");
fprintf(file,"%g",x);
fprintf(file,"</td>");

 INDENT(2)
 } // End Function number1
void logitem_h_reason(FILE * file)
 { 
//INDENT(1)
 
fprintf(file,"<td>");
if (glob_h_reason  == 1)
 { /* if number 7*/ 
/* INDENT(1) */
fprintf(file,"Max H");
 
} # INDENT(2) 
 } else if 
(glob_h_reason == 2)
 { /* if number 8*/ 
/* INDENT(1) */
fprintf(file,"Display Interval");
 
} # INDENT(2) 
 } else if 
(glob_h_reason == 3)
 { /* if number 9*/ 
/* INDENT(1) */
fprintf(file,"Optimal");
 
} # INDENT(2) 
 } else if 
(glob_h_reason == 4)
 { /* if number 10*/ 
/* INDENT(1) */
fprintf(file,"Pole Accuracy");
 
} # INDENT(2) 
 } else if 
(glob_h_reason == 5)
 { /* if number 11*/ 
/* INDENT(1) */
fprintf(file,"Min H (Pole)");
 
} # INDENT(2) 
 } else if 
(glob_h_reason == 6)
 { /* if number 12*/ 
/* INDENT(1) */
fprintf(file,"Pole");
 
} # INDENT(2) 
 } else if 
(glob_h_reason == 7)
 { /* if number 13*/ 
/* INDENT(1) */
fprintf(file,"Opt Iter");

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
fprintf(file,"Impossible");

 /* INDENT(2) */
  }/* end if 13*/
fprintf(file,"</td>");

 INDENT(2)
 } // End Function number1
void logstart(FILE * file)
 { 
//INDENT(1)
fprintf(file,"<tr>");

 INDENT(2)
 } // End Function number1
void logend(FILE * file)
 { 
//INDENT(1)
fprintf(file,"</tr>\n");

 INDENT(2)
 } // End Function number1
void chk_data() 
 { 
//INDENT(1)
 
 
 
 int  errflag;
 
  errflag  =  false;
  
  if (glob_max_iter < 2) 
 { /* if number 13*/ 
/* INDENT(1) */
    omniout_str(ALWAYS,"Illegal max_iter");
    errflag  =  true;

 /* INDENT(2) */
  }/* end if 13*/
;
  if (errflag)  
 { /* if number 13*/ 
/* INDENT(1) */
 
 

 /* INDENT(2) */
  }/* end if 13*/
 

 INDENT(2)
 } // End Function number1
double comp_expect_sec(double t_end2,double t_start2,double t2,double clock_sec2) 
 { 
//INDENT(1)
 
 
 
 double  ms2, rrr, sec_left, sub1, sub2;
 
 ;
ms2 = c(clock_sec2);
sub1 = c(t_end2-t_start2);
sub2 = c(t2-t_start2);
if (sub1 == glob__0) 
 { /* if number 13*/ 
/* INDENT(1) */
sec_left = glob__0;

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
if (sub2 > glob__0) 
 { /* if number 14*/ 
/* INDENT(1) */
rrr = (sub1/sub2);
sec_left  = rrr * c(ms2) - c(ms2);

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
sec_left  = glob__0;

 /* INDENT(2) */
  }/* end if 14*/

 /* INDENT(2) */
  }/* end if 13*/
;
return sec_left;
 

 INDENT(2)
 } // End Function number1
double comp_percent(double t_end2,double t_start2,double  t2) 
 { 
//INDENT(1)
 
 
 
 double  rrr, sub1, sub2;
 
  sub1  =  (t_end2-t_start2);
  sub2  =  (t2-t_start2);
  if (sub2 > glob_small_float) 
 { /* if number 13*/ 
/* INDENT(1) */
    rrr  =  (glob__100*sub2)/sub1;

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
    rrr  =  0.0;

 /* INDENT(2) */
  }/* end if 13*/
;
return   rrr;
 

 INDENT(2)
 } // End Function number1
double comp_rad_from_ratio(double term1,double term2,int last_no) 
 { 
//INDENT(1)
// TOP TWO TERM RADIUS ANALYSIS
 
 
 double  ret;
 
if (float_abs(term2) > glob__0) 
 { /* if number 13*/ 
/* INDENT(1) */
ret =  float_abs(term1 * glob_h / term2);

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
ret = glob_larger_float;

 /* INDENT(2) */
  }/* end if 13*/
;
return   ret;
// BOTTOM TWO TERM RADIUS ANALYSIS

 INDENT(2)
 } // End Function number1
double comp_ord_from_ratio(double term1,double term2,int last_no) 
 { 
//INDENT(1)
// TOP TWO TERM ORDER ANALYSIS
 
 
 double  ret;
 
if (float_abs(term2) > glob__0) 
 { /* if number 13*/ 
/* INDENT(1) */
ret = glob__1 +  float_abs(term2) * c(last_no) * ln(float_abs(term1 * glob_h / term2))/ln(c(last_no));

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
ret = glob_larger_float;

 /* INDENT(2) */
  }/* end if 13*/
;
return   ret;
// BOTTOM TWO TERM ORDER ANALYSIS

 INDENT(2)
 } // End Function number1
double comp_rad_from_three_terms(double term1,double term2,double term3,int last_no) 
 { 
//INDENT(1)
// TOP THREE TERM RADIUS ANALYSIS
 
 
 double  ret,temp;
 
temp = float_abs(term2*term2*c(last_no)+glob__m2*term2*term2-term1*term3*c(last_no)+term1*term3);
if (float_abs(temp) > glob__0) 
 { /* if number 13*/ 
/* INDENT(1) */
ret = float_abs((term2*glob_h*term1)/(temp));

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
ret = glob_larger_float;

 /* INDENT(2) */
  }/* end if 13*/
;
return ret;
// BOTTOM THREE TERM RADIUS ANALYSIS

 INDENT(2)
 } // End Function number1
double comp_ord_from_three_terms(double term1,double term2,double term3,int last_no) 
 { 
//INDENT(1)
// TOP THREE TERM ORDER ANALYSIS
 
 double  ret;
 
ret = float_abs((glob__4*term1*term3*c(last_no)-glob__3*term1*term3-glob__4*term2*term2*c(last_no)+glob__4*term2*term2+term2*term2*c(last_no*last_no)-term1*term3*c(last_no*last_no))/(term2*term2*c(last_no)-glob__2*term2*term2-term1*term3*c(last_no)+term1*term3));
return ret;
// TOP THREE TERM ORDER ANALYSIS

 INDENT(2)
 } // End Function number1
double comp_rad_from_six_terms(double term1,double term2,double term3,double term4,double term5,double term6,int last_no) 
 { 
//INDENT(1)
// TOP SIX TERM RADIUS ANALYSIS
 
 
 double  ret,rm0,rm1,rm2,rm3,rm4,nr1,nr2,dr1,dr2,ds2,rad_c,ord_no,ds1,rcs;
 
if ((term5  != glob__0) && (term4  != glob__0) && (term3  != glob__0) &&  (term2  != glob__0) && (term1  != glob__0))
 { /* if number 13*/ 
/* INDENT(1) */
rm0 = term6/term5;
rm1 = term5/term4;
rm2 = term4/term3;
rm3 = term3/term2;
rm4 = term2/term1;
nr1 =  c(last_no-1)*rm0 - glob__2*c(last_no-2)*rm1 + c(last_no-3)*rm2;
nr2 =  c(last_no-2)*rm1 - glob__2*c(last_no-3)*rm2 + c(last_no-4)*rm3;
dr1 =  glob__m1/rm1 + glob__2/rm2 - glob__1/rm3;
dr2 =  glob__m1/rm2 + glob__2/rm3 - glob__1/rm4;
ds1 =  glob__3/rm1 - glob__8/rm2 + glob__5/rm3;
ds2 =  glob__3/rm2 - glob__8/rm3 + glob__5/rm4;
if ((float_abs(nr1 * dr2 - nr2 * dr1)  ==  glob__0)  ||  (float_abs(dr1) == glob__0)) 
 { /* if number 14*/ 
/* INDENT(1) */
rad_c =  glob_larger_float;
ord_no =  glob_larger_float;

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
if (float_abs(nr1*dr2 - nr2 * dr1) > glob__0) 
 { /* if number 15*/ 
/* INDENT(1) */
rcs =  ((ds1*dr2 - ds2*dr1 +dr1*dr2)/(nr1*dr2 - nr2 * dr1));
// (Manuels)  rcs  =  (ds1*dr2 - ds2*dr1)/(nr1*dr2 - nr2 * dr1)
ord_no =  (rcs*nr1 - ds1)/(glob__2*dr1) -c(last_no)/glob__2;
if (float_abs(rcs)  != glob__0) 
 { /* if number 16*/ 
/* INDENT(1) */
if (rcs > glob__0) 
 { /* if number 17*/ 
/* INDENT(1) */
rad_c  =  sqrt(rcs) * float_abs(glob_h);

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
rad_c  =  glob_larger_float;
ord_no =  glob_larger_float;

 /* INDENT(2) */
  }/* end if 17*/

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
rad_c =  glob_larger_float;
ord_no =  glob_larger_float;

 /* INDENT(2) */
  }/* end if 16*/

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
rad_c =  glob_larger_float;
ord_no =  glob_larger_float;

 /* INDENT(2) */
  }/* end if 15*/

 /* INDENT(2) */
  }/* end if 14*/

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
rad_c =  glob_larger_float;
ord_no =  glob_larger_float;

 /* INDENT(2) */
  }/* end if 13*/
;
glob_six_term_ord_save =  ord_no;
return rad_c;
// BOTTOM SIX TERM RADIUS ANALYSIS

 INDENT(2)
 } // End Function number1
double comp_ord_from_six_terms(double term1,double term2,double term3,double term4,double term5,double term6,int last_no) 
 { 
//INDENT(1)
 
// TOP SIX TERM ORDER ANALYSIS
// TOP SAVED FROM SIX TERM RADIUS ANALYSIS
return glob_six_term_ord_save;
// BOTTOM SIX TERM ORDER ANALYSIS

 INDENT(2)
 } // End Function number1
double factorial_2(int nnn) 
 { 
//INDENT(1)
 double  ret;
 
 
if (nnn > 0) 
 { /* if number 13*/ 
/* INDENT(1) */
return nnn * factorial_2(nnn - 1);

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
return 1.0;

 /* INDENT(2) */
  }/* end if 13*/

 INDENT(2)
 } // End Function number1
double factorial_1(int nnn) 
 { 
//INDENT(1)
 
 
 
 double  ret;
 
if (nnn <= ATS_MAX_TERMS)
 { /* if number 13*/ 
/* INDENT(1) */
if (array_fact_1[nnn] == 0)
 { /* if number 14*/ 
/* INDENT(1) */
ret = factorial_2(nnn);
array_fact_1[nnn] = ret;

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
ret = array_fact_1[nnn];

 /* INDENT(2) */
  }/* end if 14*/
;

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
ret = factorial_2(nnn);

 /* INDENT(2) */
  }/* end if 13*/
;
return ret;
 

 INDENT(2)
 } // End Function number1
double factorial_3(int mmm,int nnn) 
 { 
//INDENT(1)
 
 
 
 double  ret;
 
if ((nnn <= ATS_MAX_TERMS)  &&  (mmm <= ATS_MAX_TERMS))
 { /* if number 13*/ 
/* INDENT(1) */
if (array_fact_2[mmm][nnn] == 0)
 { /* if number 14*/ 
/* INDENT(1) */
ret = factorial_1(mmm)/factorial_1(nnn);
array_fact_2[mmm][nnn] = ret;

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
ret = array_fact_2[mmm][nnn];

 /* INDENT(2) */
  }/* end if 14*/
;

 #INDENT(2) 
 } else { 
 # INDENT(1)
 
ret = factorial_2(mmm)/factorial_2(nnn);

 /* INDENT(2) */
  }/* end if 13*/
;
return ret;
 

 INDENT(2)
 } // End Function number1
double neg(double in)
 { 
//INDENT(1)
 
 
 
 double out;
 out = -in;
 return(out);

 INDENT(2)
 } // End Function number1
double frac(double in)
 { 
//INDENT(1)
 
 
 
 double out;
 out = in - trunc(in);
 return(out);

 INDENT(2)
 } // End Function number1
int int_trunc(double in)
 { 
//INDENT(1)
 
 
 
 int out;
 out = (int)trunc(in);
 return(out);

 INDENT(2)
 } // End Function number1
long elapsed_time_seconds()
 { 
//INDENT(1)
 
 
 
 struct timeval t;
 struct timezone tz;
 gettimeofday(&t,&tz);
 
 return (t.tv_sec);

 INDENT(2)
 } // End Function number1
double estimated_needed_step_error(double x_start,double x_end,double estimated_h,double estimated_answer)
 { 
//INDENT(1)
 
 double desired_abs_gbl_error,range,estimated_steps,step_error;
 
 
 
omniout_float(ALWAYS,"glob_desired_digits_correct",32,glob_desired_digits_correct,32,"");
desired_abs_gbl_error = expt(glob__10,c( -glob_desired_digits_correct)) * c(float_abs(c(estimated_answer)));
omniout_float(ALWAYS,"estimated_h",32,estimated_h,32,"");
omniout_float(ALWAYS,"estimated_answer",32,estimated_answer,32,"");
omniout_float(ALWAYS,"desired_abs_gbl_error",32,desired_abs_gbl_error,32,"");
range = (x_end - x_start);
omniout_float(ALWAYS,"range",32,range,32,"");
estimated_steps = range / estimated_h;
omniout_float(ALWAYS,"estimated_steps",32,estimated_steps,32,"");
step_error = (c(float_abs(desired_abs_gbl_error) /sqrt(c( estimated_steps))/c(ATS_MAX_TERMS)));
omniout_float(ALWAYS,"step_error",32,step_error,32,"");
return (step_error);;
 

 INDENT(2)
 } // End Function number1
