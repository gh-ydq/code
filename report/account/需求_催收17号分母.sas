/*option validvarname=any;*/
/*option compress=yes;*/
/*libname approval "E:\guan\ԭ����\approval";*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname repayFin "E:\guan\�м��\repayfin";*/

*�����е���·��;
*last_month_end�����µ����һ��;

data aa;
format dt last_month_end yymmdd10.;
dt=today()-1;
last_month_end=intnx('month',dt,0)-1;
call symput("last_month_end",last_month_end);
month=put(dt,yymmn6.);
call symput("month",month);
run;

/*ÿ����17����C-M1���䰸����ĸ*/
data zyp2;
set repayfin.payment_daily(where=(cut_date=REPAY_DATE));
if cut_date^=&last_month_end.;
if Ӫҵ��^="APP";
keep �ͻ����� CONTRACT_NO Ӫҵ�� ������� REPAY_DATE �ʽ����� od_days;
run;

proc sort data=zyp2;by REPAY_DATE �������;run;

proc sql;
create table dept2_1 as
select a.* ,b.CURR_RECEIVE_CAPITAL_AMT+CURR_RECEIVE_INTEREST_AMT as �ڹ�
from zyp2(where=(�ʽ����� not in ("jsxj1"))) as a
left join account.repay_plan as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_1 nodupkey ;by contract_no;run;

proc sql;
create table dept2_3 as
select a.* ,b.PSPRCPAMT+PSNORMINTAMT as �ڹ� 
from zyp2(where=(�ʽ����� in ("jsxj1"))) as a
left join repayfin.Tttrepay_plan_js as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_3 nodupkey ;by contract_no;run;

data dept;
set dept2_1  dept2_3;
rename od_days=��������; 
run;
proc sort data=dept nodupkey out=zyp;by contract_no;run;

/*PROC EXPORT DATA=zyp*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\��������\&month.���������ĸ.xlsx" DBMS=EXCEL REPLACE;SHEET="���������ĸ"; RUN;*/





