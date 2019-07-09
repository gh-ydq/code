*本sas专门做婷燕穆卿数据，分成五个sheet,按sheet的顺序，分别导出5个excel，在复制黏贴合并到一个大excel中。

流失分母,两个月前C,一个月前C，上月准M2客户客户明细，两个月前M2客户明细。
注意：两个月前M2客户明细的路径每个月要修改一次;

/*option validvarname=any;*/
/*option compress=yes;*/
/*libname repayFin "E:\guan\中间表\repayfin";*/
/*libname approval "E:\guan\原数据\approval";*/
/*libname account 'E:\guan\原数据\account';*/
/*libname csdata 'E:\guan\原数据\csdata';*/
/*libname appMid "E:\guan\中间表\midapp";*/
/*libname zq "E:\guan\中间表\zq";*/
/*libname aa "E:\guan\中间表\repayfin\历史数据\201903"; *路径需修改为上月历史数据;*/

*后面还有导出文件的路径代码;


*---------------------流失分母---------------------------------------*;
*part1;
data aa;
format dt pde mde l_month_end  month_begin yymmdd10.;
if year(today()) = 2004 then dt = intnx("year", today() - 1, 13, "same"); else dt = today() - 1;
pde=intnx("month",dt,-1,"e");
call symput("pde",pde);
mde=intnx("month",dt,0,"e");
call symput("mde",mde);
month_begin=intnx("month",dt,0,"b");
l_month_end=intnx("month",dt,0,"b")-1;
call symput("month_begin",month_begin);
call symput("l_month_end",l_month_end);*上月月底;
run;
data atest;
set repayfin.payment_daily;
if es^=1;
if contract_no='C2018101613583597025048' then delete;*库热西·马合木提不用催收,剔除分母分子;
if cut_date=&l_month_end.;
if &pde.-15<=repay_date<=&l_month_end.;
if od_days<=&l_month_end.-&pde.+15;
if 营业部 not in ("","APP");
keep contract_no 营业部 repay_date od_days;
run;
*该变量已经放到aa中;
/*%let l_month_end=mdy(3,31,2019);*/
/*%let dt=mdy(2,28,2019);*/
/*%let pde=mdy(9,30,2018);*/
/*%let mde=mdy(10,31,2018);*/

*part2;
/*这里的bill_main不是数据库里的bill_main,是日监控处理之后剔除晋商后的bill_main,*/

data test;
set account.bill_main;
if contract_no='C2018101613583597025048' then delete;*库热西·马合木提不用催收,剔除分母分子;
if bill_status^="0003";
if CLEAR_DATE>=&l_month_end. or CLEAR_DATE="" ;*是为了剔除小雨点结清的;
if &l_month_end.+1<=repay_date<=&mde.-16;
keep contract_no repay_date;
run;
proc sort data=test;by contract_no repay_date;run;
proc sort data=test nodupkey;by contract_no;run;
/**晋商;*/
data test_js;
set repayfin.tttrepay_plan_js;
if &l_month_end.+1<=repay_date_js<=&mde.-16;
keep contract_no repay_date_js;
rename repay_date_js=repay_date;
run;
proc sort data=test_js;by contract_no repay_date;run;
proc sort data=test_js nodupkey;by contract_no;run;
/**小雨点;*/
/*data test_xyd;*/
/*set tttrepay_plan_xyd;*/
/*if &dt.+1<=BQYD_REPAY_DATE<=&mde.-16;*/
/*keep contract_no BQYD_REPAY_DATE;*/
/*rename BQYD_REPAY_DATE=repay_date;*/
/*run;*/
/*proc sort data=test_xyd;by contract_no repay_date;run;*/
/*proc sort data=test_xyd nodupkey;by contract_no;run;*/
data test_all;
set test test_js ;
run;
proc sort data=test_all nodupkey;by contract_no repay_date;run;

proc sql;
create table test1 as
select a.*,b.od_days,b.营业部,b.es from test_all as a
left join repayfin.payment_daily(where=(cut_date=&l_month_end. and 营业部^="APP")) as b  on a.contract_no=b.contract_no;
quit;

data atest1;
set test1;
if es^=1;
if od_days<=15;
*沙振华;
if contract_no ^="PL148178693332002600000066";
if 营业部 not in ("","APP");
keep contract_no 营业部 repay_date  ;
run;

data all;
set atest atest1;
drop od_days;
run;
*如果七上八下原则出来的区间的day(),有重叠，下面就不用去重了，允许存在;
/*proc sort data=all nodupkey;by contract_no ;run;*/

proc sort data=all ;by repay_date;run;
proc sql;
create table all_ as 
select a.*,b.BEGINNING_CAPITAL,b.CURR_RECEIVE_INTEREST_AMT,b.MONTH_SERVICE_FEE from all as a 
left join account.repay_plan as b on a.contract_no=b.contract_no and a.repay_date=b.repay_date;
quit;
data all_1;
set all_;
贷款余额=sum(BEGINNING_CAPITAL,CURR_RECEIVE_INTEREST_AMT,MONTH_SERVICE_FEE);
drop BEGINNING_CAPITAL CURR_RECEIVE_INTEREST_AMT MONTH_SERVICE_FEE;
run;


*---------------------两个月前C---------------------------------------*;
data aa;
format dt yymmdd10.;
dt = today() - 1;
call symput("dt", dt);
this_mon = substr(compress(put(dt,yymmdd10.),"-"),1,6);
call symput("this_mon",this_mon);
run;

data aa;
set repayfin.payment;
by contract_no month;
if pre_1m_status in ("","01_C","00_NB") then do;
format 贷款余额_1月前_C_本金部分   comma8.2;
贷款余额_1月前_C_本金部分=lag(贷款余额_本金部分);
if first.contract_no then do;贷款余额_1月前_C_本金部分=0;end;
end;
if pre_2m_status in ("","01_C","00_NB") then do;
format 贷款余额_2月前_C_本金部分   comma8.2;
贷款余额_2月前_C_本金部分=lag(贷款余额_1月前_C_本金部分);
if first.contract_no then do;贷款余额_2月前_C_本金部分=0;end;
end;
if month=&this_mon.;
if contract_no='C2018101613583597025048' then delete;*库热西·马合木提不用催收,剔除分母分子;
keep contract_no 营业部 贷款余额_本金部分 贷款余额_1月前_C 贷款余额_2月前_C 贷款余额_1月前_C_本金部分 贷款余额_2月前_C_本金部分 month;
run;

proc sql;
create table C2 as
select 
营业部,
sum(贷款余额_2月前_C_本金部分) as c贷款余额,
sum(贷款余额_2月前_C) as c贷款余额1
from aa 
group by 营业部;
quit;
data C2_mx;
set aa;
if 贷款余额_2月前_C>0;
run;


*---------------------一个月前C---------------------------------------*;

proc sql;
create table C1 as
select 
营业部,
sum(贷款余额_1月前_C_本金部分) as c贷款余额,
sum(贷款余额_1月前_C) as c贷款余额1
from aa 
group by 营业部;
quit;
data C1_mx;
set aa;
if 贷款余额_1月前_C>0;
run;

*---------------------上月准M2客户客户明细---------------------------------------*;

data dept_;
set repayFin.payment_daily(where=(cut_date=&month_begin.));
if 还款_上月底M1=1 and 营业部^="APP";
keep  CONTRACT_NO 营业部 贷款余额_1月前_M1  客户姓名 ; 
run;
*song:1号就能用;
/*data dept_;*/
/*set repayFin.payment_daily(where=(cut_date=mdy(12,31,2018)));*/
/*if 还款_M1合同=1 and 营业部^="APP";*/
/*keep  CONTRACT_NO 营业部 贷款余额  客户姓名 贷款余额_剩余本金部分 ; */
/*run;*/



*由于穆卿要准M2客户的贷款余额_1月前_M1_剩余本金部分;
*将上面dept1保留下来的准M2客户之后，保存所需字段，拼接月底的贷款余额剩下本金部分就是贷款余额_1月前_M1_剩余本金部分;
proc sql;
create table dept1_m as 
select a.contract_no,a.客户姓名,a.营业部,a.贷款余额_1月前_M1,b.贷款余额_剩余本金部分 as 贷款余额_1月前_M1_剩余本金部分
from dept_ as a
left join repayfin.payment_daily(where=(cut_date=&month_begin.-1)) as b on a.contract_no=b.contract_no and a.营业部=b.营业部;
quit;

*---------------------两个月前M2客户明细---------------------------------------*;

*跑两个月前M2客户明细，要用历史数据表，尽量不要用本月payment_daily的cut_date=上月底的表，数据有误，比如："C2017080815403414972975",本月11月，
该客户11月2才还款，在payment_daily_201810的cut_date=mdy(10,31,2018)是M2的，但是在payment_daily_201811月的cut_date=mdy(10,31,2018)是M1的,
实际应该是M2的，所以还是用历史数据，历史数据每次要手动改一下，本月2018年11月，路径用历史数据的2018年10月的;

data aaa;
set aa.payment_daily(where=(cut_date=&l_month_end.));
if 还款_M2合同贷款余额>0;
if 营业部^="APP";
keep contract_no 客户姓名 营业部 还款_M2合同贷款余额   贷款余额_剩余本金部分;
rename 贷款余额_剩余本金部分=还款_M2合同贷款余额_剩余本金部分;
run;

/*PROC EXPORT DATA=all_1 OUTFILE= "E:\guan\日监控临时报表\特殊需求\穆卿\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="流失分母";run;*/
/*PROC EXPORT DATA=C1 OUTFILE= "E:\guan\日监控临时报表\特殊需求\穆卿\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="1个月前的C";run;*/
/*PROC EXPORT DATA=C2 OUTFILE= "E:\guan\日监控临时报表\特殊需求\穆卿\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="2个月前的C";run;*/
/*PROC EXPORT DATA=dept1_m OUTFILE= "E:\guan\日监控临时报表\特殊需求\穆卿\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="1个月前准M2客户明细";run;*/
/*PROC EXPORT DATA=aaa OUTFILE= "E:\guan\日监控临时报表\特殊需求\穆卿\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="2个月前准M2客户明细";run;*/
/*PROC EXPORT DATA=C1_mx OUTFILE= "E:\guan\日监控临时报表\特殊需求\穆卿\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="1个月前的C明细";run;*/
/*PROC EXPORT DATA=C2_mx OUTFILE= "E:\guan\日监控临时报表\特殊需求\穆卿\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="2个月前的C明细";run;*/
