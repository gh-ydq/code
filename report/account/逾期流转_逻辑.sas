/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname repayFin  "E:\guan\中间表\repayfin";*/
/**/
/*x  "E:\guan\日监控临时报表\逾期流转\日逾期流转报表.xlsx"; */
/*proc import datafile="E:\guan\日监控临时报表\逾期流转\营业部.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\日监控临时报表\逾期流转\营业部.xls"*/
/*out=lable dbms=excel replace;*/
/*SHEET="Sheet2$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

data _null_;
format dt yymmdd10.;
if year(today()) = 2004 then dt = intnx("year", today() - 1, 13, "same"); else dt = today() - 1;
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
run;
/*%let dt=mdy(12,31,2017);*/
data month1day;
set repayFin.payment_daily(keep=contract_no  od_days cut_date 贷款余额 还款_当日扣款失败合同 es 营业部 repay_date pre_1m_status)	;
run;
proc sort data=month1day ;by CONTRACT_no cut_date;run;
data  cc;
set month1day;
if 营业部^=""; *用这个剔除米粒;
if 营业部^="APP";
format 期初标签 期末标签 $30.;
last_oddays=lag(od_days);
last_贷款余额=lag(贷款余额);
last_还款_当日扣款失败合同=lag(还款_当日扣款失败合同);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_贷款余额=贷款余额;last_还款_当日扣款失败合同=还款_当日扣款失败合同;end;
if cut_date=&dt.;
/*if cut_date=mdy(10,14,2016);*/
if 1<=last_oddays<=6 or (last_oddays=0 and last_还款_当日扣款失败合同=1)then 期初标签="01:1-7";
else if 7<=last_oddays<=14 then 期初标签="02:8-15";
else if 15<=last_oddays<=24 then 期初标签="03:16-25";
else if 25<=last_oddays<=29 then 期初标签="04:26-30";
else if 30<=last_oddays<=59 then 期初标签="05:31-60";
else if 60<=last_oddays<=89 then 期初标签="06:61-90";
else if 90<=last_oddays<=119 then 期初标签="07:91-120";
else if 120<=last_oddays<=179 then 期初标签="08:121-180";

if 1<=od_days<=6 or (od_days=0 and 还款_当日扣款失败合同=1)then 期末标签="01:1-7";
else if 7<=od_days<=14 then 期末标签="02:8-15";
else if 15<=od_days<=24 then 期末标签="03:16-25";
else if 25<=od_days<=29 then 期末标签="04:26-30";
else if 30<=od_days<=59 then 期末标签="05:31-60";
else if 60<=od_days<=89 then 期末标签="06:61-90";
else if 90<=od_days<=119 then 期末标签="07:91-120";
else if 120<=od_days<=179 then 期末标签="08:121-180";

*新增;
if ((od_days=0 and 还款_当日扣款失败合同=1) or 
((od_days=7 or od_days=15 or od_days=25 or od_days=30 or od_days=60 or od_days=90 or od_days=120) and last_oddays<od_days))
then  新增=1;else 新增=0;
*好转流入;
if (1<=od_days<=6 and last_oddays>6) or 
   (7<=od_days<=14 and last_oddays>14) or
   (15<=od_days<=24 and last_oddays>24)  or
   (25<=od_days<=29 and last_oddays>29) or
   (30<=od_days<=59 and last_oddays>59) or
   (60<=od_days<=89 and last_oddays>89) or
   (90<=od_days<=119 and last_oddays>119) or
   (120<=od_days<=179 and last_oddays>179)  then 好转流入=1;else 好转流入=0;
*好转流出;
if ((1<=last_oddays<=6 or (last_oddays=0 and last_还款_当日扣款失败合同=1)) and od_days<1) or 
   (7<=last_oddays<=14 and od_days<7) or 
   (15<=last_oddays<=24 and od_days<15)  or
   (25<=last_oddays<=29 and od_days<25) or
   (30<=last_oddays<=59 and od_days<30) or
   (60<=last_oddays<=89 and od_days<60) or
   (90<=last_oddays<=119 and od_days<90) or
   (120<=last_oddays<=189 and od_days<120) then 好转流出=1;else 好转流出=0;
*恶化流出;
if ((1<=last_oddays<=6 or (last_oddays=0 and last_还款_当日扣款失败合同=1)) and od_days>6) or 
   (7<=last_oddays<=14 and od_days>14) or
   (15<=last_oddays<=24 and od_days>24)  or
   (25<=last_oddays<=29 and od_days>29) or
   (30<=last_oddays<=59 and od_days>59) or
   (60<=last_oddays<=89 and od_days>89) or
   (90<=last_oddays<=119 and od_days>119) or
   (120<=last_oddays<=179 and od_days>179) then 恶化流出=1;else 恶化流出=0;
*催回;
   if od_days=0 and (last_oddays>0 or last_还款_当日扣款失败合同=1)  then 催回=1;else 催回=0;
run;
proc sql;*由于下面代码取数时的筛选条件，结果表中期末标签=""是逾期180天以上的;
create table cc1(where=(期末标签^="")) as
select 期末标签,sum(新增) as 新增 ,sum(好转流入) as 好转流入,count(*) as 期末,sum(贷款余额) as 贷款余额  from cc (where=(od_days>0 or (od_days=0 and 还款_当日扣款失败合同=1))) group by 期末标签;
quit;

proc sql;*由于下面代码取数时的筛选条件，结果表中期初标签=""是逾期180天以上的;
create table cc1_1(where=(期初标签^="")) as
select 期初标签,sum(好转流出) as 好转流出,sum(恶化流出) as 恶化流出,count(*) as 期初  from cc (where=(last_oddays>0 or (last_oddays=0 and last_还款_当日扣款失败合同=1))) group by 期初标签;
quit;
proc sql;*期初标签=""的是前天逾期，昨天催回的;
create table cc1_2(where=(期初标签^="")) as
select 期初标签,sum(催回) as 催回   from cc  group by 期初标签;
quit;
proc sql;
create table cc2 as
select a.*,b.*,c.催回 from cc1 as a
left join cc1_1 as b on a.期末标签=b.期初标签
left join cc1_2 as c on a.期末标签=c.期初标签;
quit;
data st1 st2;
set cc2;
if 期末标签 in ("01:1-7","02:8-15","03:16-25","04:26-30") then output st1;
else output st2;
run;

filename DD DDE 'EXCEL|[日逾期流转报表.xlsx]Sheet1!r4c5:r7c10';
data _null_;set st1;file DD;put 期初 新增 好转流入 好转流出 恶化流出 催回;run;
filename DD DDE 'EXCEL|[日逾期流转报表.xlsx]Sheet1!r4c12:r7c13';
data _null_;set st1;file DD;put 期末 贷款余额;run;

filename DD DDE 'EXCEL|[日逾期流转报表.xlsx]Sheet1!r9c5:r12c10';
data _null_;set st2;file DD;put 期初 新增 好转流入 好转流出 恶化流出 催回;run;
filename DD DDE 'EXCEL|[日逾期流转报表.xlsx]Sheet1!r9c12:r12c13';
data _null_;set st2;file DD;put 期末 贷款余额;run;
proc sql;
create table aall as
select count(CONTRACT_NO) as 未结清笔数,sum(贷款余额) as 未结清贷款余额 from cc(where=(pre_1m_status not in('09_ES','11_Settled')));
quit;
filename DD DDE 'EXCEL|[日逾期流转报表.xlsx]Sheet1!r4c2:r4c3';
data _null_;set aall;file DD;put 未结清笔数 未结清贷款余额;run;

data branch1;
set branch end=last;
call symput ("dept_"||compress(_n_),compress(营业部));

*TOTAL_TAT & Disb_Successful_TAT;
TOTAL_TAT_b1=4+_n_*12;
TOTAL_TAT_b2=9+_n_*12;
TOTAL_TAT_e1=7+_n_*12;
TOTAL_TAT_e2=12+_n_*12;
call symput ("totalb1_row_"||compress(_n_),compress(TOTAL_TAT_b1));
call symput ("totalb2_row_"||compress(_n_),compress(TOTAL_TAT_b2));
call symput("totale1_row_"||compress(_n_),compress(TOTAL_TAT_e1));
call symput("totale2_row_"||compress(_n_),compress(TOTAL_TAT_e2));

if last then call symput("lpn",compress(_n_));
run;


%macro city_table();
%do i =1 %to &lpn.;
proc sql;
create table cc1(where=(期末标签^="")) as
select 期末标签,sum(新增) as 新增 ,sum(好转流入) as 好转流入,count(*) as 期末,sum(贷款余额) as 贷款余额  from cc (where=((od_days>0 or (od_days=0 and 还款_当日扣款失败合同=1)) and 营业部="&&dept_&i")) group by 期末标签;
quit;

proc sql;
create table cc1_1(where=(期初标签^="")) as
select 期初标签,sum(好转流出) as 好转流出,sum(恶化流出) as 恶化流出,count(*) as 期初  from cc (where=((last_oddays>0 or (last_oddays=0 and last_还款_当日扣款失败合同=1))and 营业部="&&dept_&i")) group by 期初标签;
quit;
proc sql;
create table cc1_2(where=(期初标签^="")) as
select 期初标签,sum(催回) as 催回   from cc(where=( 营业部="&&dept_&i"))  group by 期初标签;
quit;
proc sql;
create table cc2 as
select a.期末标签 as 标签,b.*,c.*,d.催回 from lable as a
left join cc1 as b on a.期末标签=b.期末标签
left join cc1_1 as c on a.期末标签=c.期初标签
left join cc1_2 as d on a.期末标签=d.期初标签;
quit;
data st1 st2;
set cc2;
if 标签 in ("01:1-7","02:8-15","03:16-25","04:26-30") then output st1;
else output st2;
run;
filename DD DDE "EXCEL|[日逾期流转报表.xlsx]Sheet1!r&&totalb1_row_&i..c5:r&&totale1_row_&i..c10";
data _null_;set st1;file DD;put 期初 新增 好转流入 好转流出 恶化流出 催回;run;
filename DD DDE "EXCEL|[日逾期流转报表.xlsx]Sheet1!r&&totalb1_row_&i..c12:r&&totale1_row_&i..c13";
data _null_;set st1;file DD;put 期末 贷款余额;run;

filename DD DDE "EXCEL|[日逾期流转报表.xlsx]Sheet1!r&&totalb2_row_&i..c5:r&&totale2_row_&i..c10";
data _null_;set st2;file DD;put 期初 新增 好转流入 好转流出 恶化流出 催回;run;
filename DD DDE "EXCEL|[日逾期流转报表.xlsx]Sheet1!r&&totalb2_row_&i..c12:r&&totale2_row_&i..c13";
data _null_;set st2;file DD;put 期末 贷款余额;run;
proc sql;
create table aall as
select count(CONTRACT_NO) as 未结清笔数,sum(贷款余额) as 未结清贷款余额 from cc(where=(es=. and 营业部="&&dept_&i"));
quit;
filename DD DDE "EXCEL|[日逾期流转报表.xlsx]Sheet1!r&&totalb1_row_&i..c2:r&&totalb1_row_&i..c3";
data _null_;set aall;file DD;put 未结清笔数 未结清贷款余额;run;
%end;
%mend;
%city_table();

*周一报表用;
data kan;
set month1day;
if 营业部^="";
if 营业部^="APP"; 
last_oddays=lag(od_days);
last_还款_当日扣款失败合同=lag(还款_当日扣款失败合同);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_贷款余额=贷款余额;last_还款_当日扣款失败合同=还款_当日扣款失败合同;end;/*2017-07-03*/

if cut_date=&dt.-1;
if od_days=0 and (last_oddays>0 or last_还款_当日扣款失败合同=1) ;
run;
/*2017-07-03*/
data kan1;
set month1day;
if 营业部^=""; 
if 营业部^="APP";
last_oddays=lag(od_days);
last_还款_当日扣款失败合同=lag(还款_当日扣款失败合同);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_贷款余额=贷款余额;last_还款_当日扣款失败合同=还款_当日扣款失败合同;end;/*2017-07-03*/
if cut_date=&dt.-2;
if od_days=0 and (last_oddays>0 or last_还款_当日扣款失败合同=1) ;
run;

/*data kan2;*/
/*set month1day;*/
/*if 营业部^=""; */
/*last_oddays=lag(od_days);*/
/*last_还款_当日扣款失败合同=lag(还款_当日扣款失败合同);*/
/*by CONTRACT_no cut_date;*/
/*if first.contract_no then do ;last_oddays=od_days;last_贷款余额=贷款余额;last_还款_当日扣款失败合同=还款_当日扣款失败合同;end;*/
/*if cut_date=&dt.-3;*/
/*if od_days=0 and (last_oddays>0 or last_还款_当日扣款失败合同=1) ;*/
/*run;*/
