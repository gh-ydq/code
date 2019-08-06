/*option validvarname=any;option compress=yes;*/
/*libname repayFin "E:\guan\中间表\repayfin";*/
/*libname account 'E:\guan\原数据\account';*/
/*libname approval 'E:\guan\原数据\approval';*/
/*libname zq 'E:\guan\中间表\zq';*/
/**/
/*x  "E:\guan\日监控临时报表\1-15天逾期数据\营业部1-15天逾期数据.xlsx"; */
/**/
/*proc import datafile="E:\guan\日监控临时报表\营业部DDE.xls"*/
/*out=dept dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

data dept;
set dept;
if 营业部='南京市业务中心' then delete;*南京市业务中心没有正常及180天以内客户;
run;
data _null_;
format dt yymmdd10.;
if year(today()) = 2004 then dt = intnx("year", today() - 1, 13, "same"); else dt = today() - 1;
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
week = weekday(dt);
call symput('week',week);
format l_month_end yymmdd10.;
l_month_end=intnx('month',dt,-1,'e');
call symput('l_month_end',l_month_end);
run;
data payment_daily;
set repayFin.payment_daily;
if contract_no='C2018101613583597025048' then delete;*库热西·马合木提不用催收,剔除分母分子;
if contract_no='C2017121414464569454887' then delete;*蒋楠委外客户不用催收,剔除分母分子;
if contract_no='C2017111716235470079023' and month='201904' then delete;*王丽青4月份做帐太迟，4月份不计算分母分子,剔除分母分子;
run;
*加上提前结清的流失分母;
data bill_main;
set account.bill_main;
if kindex(BILL_CODE,'BLC');
if &last_month_end.-15<=repay_date<=&month_end.-16;
run;
proc sort data=bill_main nodupkey;by contract_no;run;
proc sql;
create table payment_daily_ as 
select a.*,b.repay_date as repay_date_tz from payment_daily as a
left join bill_main as b on a.contract_no=b.contract_no;
quit;
data payment_daily;
set payment_daily_;
if es=1 and es_date>=&last_month_end.-15 and cut_date=intnx('day',repay_date_tz,16) then 还款_当日流入15加合同分母=1;
run;

data cc;
set account.bill_main(where=(repay_date=&nt. and bill_status not in ("0000","0003")));
run;
proc sql;
create table cc1 as
select b.* from cc as a
left join account.Bill_fee_dtl as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table cc2 as 
select contract_no,sum(CURR_RECEIPT_AMT) as 已还本金利息 
from account.Bill_fee_dtl(where=(fee_name in ("本金","利息") and OFFSET_DATE=&nt. )) where contract_no in (select contract_no from cc1)
group by contract_no;quit;
proc sql;
create table cc3(where=(not od_days>0)) as
select a.contract_no,b.已还本金利息,a.CURR_RECEIVE_AMT,c.营业部,d.od_days,d.资金渠道  from cc as a
left join cc2 as b on a.contract_no=b.contract_no
left join zq.Account_info as c on a.contract_no=c.contract_no 
left join payment_daily(where=(cut_date=&dt.)) as d on a.contract_no=d.contract_no ;
quit;
data cc3_1;
set cc3;
if CURR_RECEIVE_AMT>已还本金利息 and sum(CURR_RECEIVE_AMT,-已还本金利息)>1 and 已还本金利息<100;
if 资金渠道 not in ("jsxj1");
run;
*晋商;
data tttrepay_plan_js;
set account.repay_plan_js;
run;
proc sort data = tttrepay_plan_js; by contract_no psperdno descending SETLPRCP; run;
proc sort data = tttrepay_plan_js nodupkey; by contract_no psperdno; run;
data  tttrepay_plan_js;
set tttrepay_plan_js;
format repay_date_js  clear_date_js yymmdd10.;
repay_date_js=mdy(scan(psduedt,2,"-"), scan(psduedt,3,"-"),scan(psduedt,1,"-"));
if SETLPRCP=PSPRCPAMT and SETLNORMINT=PSNORMINTAMT then  clear_date_js=datepart(CREATED_TIME)-1;
if repay_date_js<=mdy(10,25,2016) then clear_date_js=repay_date_js;
run;

data cc3_1_js;*必有;
set tttrepay_plan_js;
if repay_date_js=&nt.;
if SETLPRCP^=PSPRCPAMT or SETLNORMINT^=PSNORMINTAMT;
run;

proc sql;
create table cc3_1_js1 as
select a.contract_no,sum(a.PSPRCPAMT,a.PSNORMINTAMT) as CURR_RECEIVE_AMT,b.营业部 from cc3_1_js as a
left join payment_daily(where=(cut_date=&dt.)) as b on a.contract_no=b.contract_no;
quit;
data cc3_1;
set cc3_1 cc3_1_js1 ;
if 营业部^="APP";
run;
proc sort data=cc3_1 nodupkey;by contract_no;run;

proc sql;
create table cc3_2 as
select 营业部,count(*) as 代扣个数,sum(CURR_RECEIVE_AMT) as 代扣金额 
from cc3_1  group by 营业部;quit;

proc sql;
create table cc4 as
select 营业部,count(*) as 流入,sum(贷款余额) as 流入贷款余额 
from payment_daily(where=(od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date and cut_date=&dt.))
group by 营业部;
quit;
proc sql;
create table cc5 as
select 营业部,count(*) as 滑落,sum(贷款余额) as 滑落贷款余额 
from payment_daily(where=(还款_当日流入15加合同=1 and cut_date=&dt.))
group by 营业部;
quit;
proc sql;
create table cc6 as
select 营业部,count(*) as d1_15,sum(贷款余额) as d1_15贷款余额 
from payment_daily(where=(((od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date ) or 1<=od_days<=15) and cut_date=&dt.))
group by 营业部;
quit;

proc sql;
create table p1(drop=id) as
select a.*,b.代扣个数,b.代扣金额,c.流入,c.流入贷款余额 from dept as a
left join cc3_2 as b on a.营业部=b.营业部
left join cc4 as c on a.营业部=c.营业部
order by id;
quit;
proc sql;
create table p2(drop=id) as
select a.*,b.d1_15,b.d1_15贷款余额,c.滑落,c.滑落贷款余额 from dept as a
left join cc6 as b on a.营业部=b.营业部
left join cc5 as c on a.营业部=c.营业部
order by id;
quit;
data one_seven;
set payment_daily(where=(((od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date ) or 1<=od_days<=15) and cut_date=&dt.));
if 营业部^="APP";
keep contract_no 营业部 客户姓名 repay_date 资金渠道;
run;

data month1day;
set payment_daily(keep=contract_no  od_days cut_date 贷款余额 还款_当日扣款失败合同 REPAY_DATE 营业部);
/*    repayFin.Lastday      (keep=contract_no  od_days cut_date 贷款余额 还款_当日扣款失败合同 REPAY_DATE 营业部);*/
run;
proc sort data=month1day ;by CONTRACT_no  cut_date descending 营业部;run;


data  clear_17detail;
/*set  repayFin.payment_daily(keep=contract_no  od_days cut_date 贷款余额 还款_当日扣款失败合同 REPAY_DATE 营业部);*/
set month1day;
if 营业部^="";*去除米粒;
if 营业部^="APP";
last_oddays=lag(od_days);
last_贷款余额=lag(贷款余额);
last_扣款结果=lag(还款_当日扣款失败合同);
by CONTRACT_no   cut_date;
if first.contract_no then do ;last_oddays=od_days;last_贷款余额=贷款余额;last_扣款结果=还款_当日扣款失败合同;end;
*早上;
if cut_date=&dt.;
*下午;
/*if cut_date=&nt.;*/
/*if (1<=last_oddays<=14 and od_days<1) or (last_扣款结果=1 and od_days<1);*/
if last_oddays>od_days or  (last_扣款结果=1 and od_days<1);
repay_date = &dt.-last_oddays-1;
format 还清日 yymmdd10.;
还清日=&dt.;
keep contract_no 营业部 repay_date  还清日 ;
run;
*累计流入明细;
%macro new_overdue;
proc delete data=new_overdue;run;
data _null_;
n = day(&dt.) - 1;
call symput("n", n);
run;
%do i=0 %to &n.;
data cc(drop=还款_当日扣款失败合同 REPAY_DATE od_days);
set payment_daily(keep=CONTRACT_NO od_days 营业部 客户姓名 cut_date REPAY_DATE 还款_当日扣款失败合同 身份证号码);
if 营业部^="APP";
if 营业部^="";*去除米粒;
if od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date and cut_date=intnx("day",intnx("month",&dt.,0,"b"),&i.);
rename cut_date=流入日期;
run;
proc append data=cc base=new_overdue;run;
%end;
%mend;
%new_overdue;
/*%let dt=mdy(12,31,2017);*/
*累计滑落明细;
proc sql;
create table pay_repay as 
select a.*,b.BEGINNING_CAPITAL,b.CURR_RECEIVE_INTEREST_AMT,b.MONTH_SERVICE_FEE from payment_daily as a 
left join account.repay_plan as b on a.contract_no=b.contract_no and a.repay_date=b.repay_date;
quit;
data pay_repay_;
set pay_repay;
账单日贷款余额15分母=sum(BEGINNING_CAPITAL,CURR_RECEIVE_INTEREST_AMT,MONTH_SERVICE_FEE)*还款_当日流入15加合同分母;
账单日贷款余额15分子=sum(BEGINNING_CAPITAL,CURR_RECEIVE_INTEREST_AMT,MONTH_SERVICE_FEE)*还款_当日流入15加合同;
run;
data flow_Denominator;
set pay_repay_;
if cut_date^=&l_month_end. and 营业部^="APP";
if 还款_当日流入15加合同分母=1;
keep contract_no od_days 营业部 账单日贷款余额15分母  REPAY_DATE cut_date 客户姓名 od_periods;
run;
%macro eight_overdue;
proc delete data=eight_overdue;run;
data _null_;
n = day(&dt.) - 1;
call symput("n", n);
run;
%do i=0 %to &n.;
data cc(drop=还款_当日扣款失败合同 REPAY_DATE od_days);
set pay_repay_(keep=CONTRACT_NO od_days 营业部  还款_当日流入15加合同 客户姓名 cut_date REPAY_DATE 还款_当日扣款失败合同 身份证号码 od_periods 账单日贷款余额15分子);
if 营业部^="APP";
if 营业部^="";*去除米粒;
last_oddays=lag(od_days);
if 还款_当日流入15加合同=1 and cut_date=intnx("day",intnx("month",&dt.,0,"b"),&i.);
rename cut_date=流入日期 账单日贷款余额15分子=贷款余额;
run;
proc append data=cc base=eight_overdue;run;
data eight_overdue;
set eight_overdue;
run;
%end;
%mend;
%eight_overdue;
proc sort data =one_seven ;by repay_date;run;
proc sort data =clear_17detail ;by repay_date;run;
proc sort data =New_overdue ;by 流入日期;run;
proc sort data =Eight_overdue ;by 流入日期;run;
proc sort data =flow_Denominator ;by REPAY_DATE;run;

data test1_7 ;
set payment_daily;
if 营业部^="APP";
if cut_date=&dt. and repay_date=&dt.  and od_days=0;
run;
proc sql;
create table test1_7kan as
select 营业部,sum(还款_当日扣款失败合同)/count(*) as 流入率 format=percent7.2 from test1_7 group by 营业部;
quit;
proc sql;
create table all1_7 as
select "总计" as 营业部,sum(还款_当日扣款失败合同)/count(*) as 流入率 format=percent7.2 from test1_7 ;
quit;
proc sql;
create table lrl1_7 as
select a.id,a.营业部,b.流入率 from dept as a
left join test1_7kan as b on a.营业部=b.营业部;
quit;
proc sort data=lrl1_7;by id;run;
data lrl1_7_end;
set lrl1_7 all1_7;
run;
%macro monday;
proc delete data=monday;run;
data _null_;
n = 2;
call symput("n", n);
run;
%do i=0 %to &n.;
data cc(drop=还款_当日扣款失败合同 REPAY_DATE od_days);
set repayFin.payment_daily(keep=CONTRACT_NO od_days 营业部 客户姓名 cut_date REPAY_DATE 还款_当日扣款失败合同 贷款余额 还款_当日流入15加合同);
if 营业部^="";*去除米粒;
if 营业部^="APP";
if 还款_当日流入15加合同=1 and cut_date=intnx("day",&dt.-2,&i.);
rename cut_date=流入日期;
run;
proc append data=cc base=monday;run;
%end;
%mend;
%monday;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r4c2:r40c5';
data _null_;set p1;file DD;put 代扣个数 代扣金额 流入 流入贷款余额 ;run;
filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r4c7:r40c10';
data _null_;set p2;file DD;put d1_15 d1_15贷款余额 滑落 滑落贷款余额 ;run;
filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]1_15客户明细!r2c1:r3000c5';
data _null_;set one_seven;file DD;put contract_no 营业部 客户姓名 repay_date 资金渠道 ;run;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r46c1:r1000c4';
data _null_;set clear_17detail;file DD;put contract_no  营业部 repay_date 还清日 ;run;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]本月流入合同明细!r2c1:r10000c4';
data _null_;set New_overdue;file DD;put contract_no 客户姓名 营业部 流入日期  ;run;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]本月滑落合同明细!r2c1:r10000c5';
data _null_;set Eight_overdue;file DD;put contract_no  客户姓名 营业部 流入日期 贷款余额;run;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]本月流失合同分母!r2c1:r10000c5';
data _null_;set flow_Denominator;file DD;put contract_no  客户姓名 营业部 REPAY_DATE 账单日贷款余额15分母;run;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]c_m1客户明细!r2c1:r10000c6';
data _null_;set payment_daily(where=((od_days=0 and 还款_当日扣款失败合同=1 and repay_date=cut_date or 1<=od_days<=30) and cut_date =&dt.));
file DD;put contract_no  客户姓名 营业部 od_days 贷款余额 资金渠道 ;run;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]准m2客户明细数据!r2c1:r10000c6';
data _null_;set payment_daily(where=((还款_上月底M1>0  and 还款_M1M2 =1) and cut_date =&dt.));
file DD;put contract_no  客户姓名 营业部 od_days 贷款余额 资金渠道 ;run;

filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r4c6:r41c6';
data _null_;set Lrl1_7_end;file DD;put 流入率 ;run;
%macro monday_1;
%if &week.=1 %then %do;

proc sql;
create table out1 as 
select 营业部,count(贷款余额)as 滑落个数 ,sum(贷款余额) as 滑落金额 from monday group by 营业部;
quit;

proc sql;
create table out as 
select a.*,b.滑落个数 ,b.滑落金额 from dept as a left join out1 as b on a.营业部 = b.营业部 order by id;  
quit; 

/*proc sql;
create table monday_ru as
select 营业部,count(*) as 流入,sum(贷款余额) as 流入贷款余额 
from repayFin.payment_daily(where=(od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date and cut_date=&dt.))
group by 营业部;
quit;*/
proc sql;
create table monday_ru1 as
select 营业部,贷款余额,CONTRACT_NO from payment_daily(where=(od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date and cut_date=&dt.));
quit;
proc sql;
create table monday_ru2 as 
select 营业部,贷款余额,CONTRACT_NO from payment_daily(where=(od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date and cut_date=&dt. -1));
quit;
proc sql;
create table monday_ru3 as 
select 营业部,贷款余额,CONTRACT_NO from payment_daily(where=(od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date and cut_date=&dt. -2));
quit;
/*proc sql;*/
/*create table monday_ru4 as */
/*select 营业部,贷款余额,CONTRACT_NO from repayFin.payment_daily(where=(od_days=0 and 还款_当日扣款失败合同=1 and REPAY_DATE=cut_date and cut_date=&dt. -3));*/
/*quit;*/


data monday_ru;
set monday_ru1 monday_ru2 monday_ru3;
run;
proc sql;
create table monday_liuru as 
select 营业部,count(*) as 流入,sum(贷款余额) as 流入贷款余额 
from monday_ru group by 营业部;
quit;
proc sql;
create table in_1 as 
select a.*,b.流入 ,b.流入贷款余额 from dept as a left join monday_liuru as b on a.营业部 = b.营业部 order by id;  
quit; 
*计算流入率;
data liurulv_1 ;
set payment_daily;
if cut_date=&dt. and repay_date=&dt.  and od_days=0;
run;
data liurulv_2 ;
set payment_daily;
if cut_date=&dt.-1 and repay_date=&dt.-1  and od_days=0;
run;

data liurulv_3 ;
set payment_daily;
if cut_date=&dt.-2 and repay_date=&dt.-2  and od_days=0;
run;
/*data liurulv_4 ;*/
/*set repayfin.payment_daily;*/
/*if cut_date=&dt.-3 and repay_date=&dt.-3  and od_days=0;*/
/*run;*/

data liurulv_ex;
set liurulv_1 liurulv_2 liurulv_3 ;
run;
proc sql;
create table liurulv_kan1 as
select 营业部,sum(还款_当日扣款失败合同)/count(*) as 流入率 format=percent7.2 ,count(*) as 总量 from liurulv_ex group by 营业部;
quit;
proc sql;
create table liurulv_kan2 as
select "总计" as 营业部,sum(还款_当日扣款失败合同)/count(*) as 流入率 format=percent7.2 ,count(*) as 总量 from liurulv_ex ;
quit;

proc sql;
create table liurulv_ex2 as 
select a.*,b.流入率 ,b.总量 from in_1 as a left join liurulv_kan1 as b on a.营业部 = b.营业部 order by id;  
quit; 
data liurulv;
set liurulv_ex2 liurulv_kan2;
run;
*clear_17detail;
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
if last_oddays>od_days or  (last_扣款结果=1 and od_days<1);
repay_date = &dt.-last_oddays-1;
format 还清日 yymmdd10.;
还清日=&dt.-1;
keep contract_no 营业部 repay_date  还清日 ;
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
if last_oddays>od_days or  (last_扣款结果=1 and od_days<1);
repay_date = &dt.-last_oddays-1;
format 还清日 yymmdd10.;
还清日=&dt.-2;
keep contract_no 营业部 repay_date  还清日 ;
run;
/*data kan2_1;*/
/*set kan2(where =( last_oddays <6));*/
/*keep CONTRACT_NO 营业部 REPAY_DATE cut_date;*/
/*rename cut_date =  还清日;*/
run;
data monday_repay_1;
set clear_17detail kan kan1 ;
run;

	filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r4c9:r40c10';
	data _null_;set out; file DD; put 滑落个数 滑落金额 ; run ;
	filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r4c4:r40c5';
	data _null_;set in_1 ; file DD; put 流入 流入贷款余额 ; run ;
	filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r4c6:r41c6';
	data _null_;set liurulv;file DD;put 流入率 ;run;
	filename DD DDE 'EXCEL|[营业部1-15天逾期数据.xlsx]Sheet1!r46c1:r1000c4';
	data _null_;set monday_repay_1;file DD;put contract_no  营业部 repay_date 还清日 ;run;

	%end;
	%mend;
%monday_1;
