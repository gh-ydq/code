/*option validvarname=any;*/
/*option compress=yes;*/
/*libname approval "E:\guan\原数据\approval";*/
/*libname account 'E:\guan\原数据\account';*/
/*libname repayFin "E:\guan\中间表\repayfin";*/

*后面有导出路径;
*last_month_end是上月底最后一天;

data aa;
format dt last_month_end yymmdd10.;
dt=today()-1;
last_month_end=intnx('month',dt,0)-1;
call symput("last_month_end",last_month_end);
month=put(dt,yymmn6.);
call symput("month",month);
run;

/*每个月17号跑C-M1分配案件分母*/
data zyp2;
set repayfin.payment_daily(where=(cut_date=REPAY_DATE));
if cut_date^=&last_month_end.;
if 营业部^="APP";
keep 客户姓名 CONTRACT_NO 营业部 贷款余额 REPAY_DATE 资金渠道 od_days;
run;

proc sort data=zyp2;by REPAY_DATE 贷款余额;run;

proc sql;
create table dept2_1 as
select a.* ,b.CURR_RECEIVE_CAPITAL_AMT+CURR_RECEIVE_INTEREST_AMT as 期供
from zyp2(where=(资金渠道 not in ("jsxj1"))) as a
left join account.repay_plan as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_1 nodupkey ;by contract_no;run;

proc sql;
create table dept2_3 as
select a.* ,b.PSPRCPAMT+PSNORMINTAMT as 期供 
from zyp2(where=(资金渠道 in ("jsxj1"))) as a
left join repayfin.Tttrepay_plan_js as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_3 nodupkey ;by contract_no;run;

data dept;
set dept2_1  dept2_3;
rename od_days=逾期天数; 
run;
proc sort data=dept nodupkey out=zyp;by contract_no;run;

/*PROC EXPORT DATA=zyp*/
/*OUTFILE= "E:\guan\日监控临时报表\特殊需求\&month.案件分配分母.xlsx" DBMS=EXCEL REPLACE;SHEET="案件分配分母"; RUN;*/





