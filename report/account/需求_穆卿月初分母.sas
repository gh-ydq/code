*��sasר���������������ݣ��ֳ����sheet,��sheet��˳�򣬷ֱ𵼳�5��excel���ڸ�������ϲ���һ����excel�С�

��ʧ��ĸ,������ǰC,һ����ǰC������׼M2�ͻ��ͻ���ϸ��������ǰM2�ͻ���ϸ��
ע�⣺������ǰM2�ͻ���ϸ��·��ÿ����Ҫ�޸�һ��;

/*option validvarname=any;*/
/*option compress=yes;*/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname approval "E:\guan\ԭ����\approval";*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname csdata 'E:\guan\ԭ����\csdata';*/
/*libname appMid "E:\guan\�м��\midapp";*/
/*libname zq "E:\guan\�м��\zq";*/
/*libname aa "E:\guan\�м��\repayfin\��ʷ����\201903"; *·�����޸�Ϊ������ʷ����;*/

*���滹�е����ļ���·������;


*---------------------��ʧ��ĸ---------------------------------------*;
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
call symput("l_month_end",l_month_end);*�����µ�;
run;
data atest;
set repayfin.payment_daily;
if es^=1;
if contract_no='C2018101613583597025048' then delete;*�����������ľ�᲻�ô���,�޳���ĸ����;
if cut_date=&l_month_end.;
if &pde.-15<=repay_date<=&l_month_end.;
if od_days<=&l_month_end.-&pde.+15;
if Ӫҵ�� not in ("","APP");
keep contract_no Ӫҵ�� repay_date od_days;
run;
*�ñ����Ѿ��ŵ�aa��;
/*%let l_month_end=mdy(3,31,2019);*/
/*%let dt=mdy(2,28,2019);*/
/*%let pde=mdy(9,30,2018);*/
/*%let mde=mdy(10,31,2018);*/

*part2;
/*�����bill_main�������ݿ����bill_main,���ռ�ش���֮���޳����̺��bill_main,*/

data test;
set account.bill_main;
if contract_no='C2018101613583597025048' then delete;*�����������ľ�᲻�ô���,�޳���ĸ����;
if bill_status^="0003";
if CLEAR_DATE>=&l_month_end. or CLEAR_DATE="" ;*��Ϊ���޳�С�������;
if &l_month_end.+1<=repay_date<=&mde.-16;
keep contract_no repay_date;
run;
proc sort data=test;by contract_no repay_date;run;
proc sort data=test nodupkey;by contract_no;run;
/**����;*/
data test_js;
set repayfin.tttrepay_plan_js;
if &l_month_end.+1<=repay_date_js<=&mde.-16;
keep contract_no repay_date_js;
rename repay_date_js=repay_date;
run;
proc sort data=test_js;by contract_no repay_date;run;
proc sort data=test_js nodupkey;by contract_no;run;
/**С���;*/
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
select a.*,b.od_days,b.Ӫҵ��,b.es from test_all as a
left join repayfin.payment_daily(where=(cut_date=&l_month_end. and Ӫҵ��^="APP")) as b  on a.contract_no=b.contract_no;
quit;

data atest1;
set test1;
if es^=1;
if od_days<=15;
*ɳ��;
if contract_no ^="PL148178693332002600000066";
if Ӫҵ�� not in ("","APP");
keep contract_no Ӫҵ�� repay_date  ;
run;

data all;
set atest atest1;
drop od_days;
run;
*������ϰ���ԭ������������day(),���ص�������Ͳ���ȥ���ˣ��������;
/*proc sort data=all nodupkey;by contract_no ;run;*/

proc sort data=all ;by repay_date;run;
proc sql;
create table all_ as 
select a.*,b.BEGINNING_CAPITAL,b.CURR_RECEIVE_INTEREST_AMT,b.MONTH_SERVICE_FEE from all as a 
left join account.repay_plan as b on a.contract_no=b.contract_no and a.repay_date=b.repay_date;
quit;
data all_1;
set all_;
�������=sum(BEGINNING_CAPITAL,CURR_RECEIVE_INTEREST_AMT,MONTH_SERVICE_FEE);
drop BEGINNING_CAPITAL CURR_RECEIVE_INTEREST_AMT MONTH_SERVICE_FEE;
run;


*---------------------������ǰC---------------------------------------*;
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
format �������_1��ǰ_C_���𲿷�   comma8.2;
�������_1��ǰ_C_���𲿷�=lag(�������_���𲿷�);
if first.contract_no then do;�������_1��ǰ_C_���𲿷�=0;end;
end;
if pre_2m_status in ("","01_C","00_NB") then do;
format �������_2��ǰ_C_���𲿷�   comma8.2;
�������_2��ǰ_C_���𲿷�=lag(�������_1��ǰ_C_���𲿷�);
if first.contract_no then do;�������_2��ǰ_C_���𲿷�=0;end;
end;
if month=&this_mon.;
if contract_no='C2018101613583597025048' then delete;*�����������ľ�᲻�ô���,�޳���ĸ����;
keep contract_no Ӫҵ�� �������_���𲿷� �������_1��ǰ_C �������_2��ǰ_C �������_1��ǰ_C_���𲿷� �������_2��ǰ_C_���𲿷� month;
run;

proc sql;
create table C2 as
select 
Ӫҵ��,
sum(�������_2��ǰ_C_���𲿷�) as c�������,
sum(�������_2��ǰ_C) as c�������1
from aa 
group by Ӫҵ��;
quit;
data C2_mx;
set aa;
if �������_2��ǰ_C>0;
run;


*---------------------һ����ǰC---------------------------------------*;

proc sql;
create table C1 as
select 
Ӫҵ��,
sum(�������_1��ǰ_C_���𲿷�) as c�������,
sum(�������_1��ǰ_C) as c�������1
from aa 
group by Ӫҵ��;
quit;
data C1_mx;
set aa;
if �������_1��ǰ_C>0;
run;

*---------------------����׼M2�ͻ��ͻ���ϸ---------------------------------------*;

data dept_;
set repayFin.payment_daily(where=(cut_date=&month_begin.));
if ����_���µ�M1=1 and Ӫҵ��^="APP";
keep  CONTRACT_NO Ӫҵ�� �������_1��ǰ_M1  �ͻ����� ; 
run;
*song:1�ž�����;
/*data dept_;*/
/*set repayFin.payment_daily(where=(cut_date=mdy(12,31,2018)));*/
/*if ����_M1��ͬ=1 and Ӫҵ��^="APP";*/
/*keep  CONTRACT_NO Ӫҵ�� �������  �ͻ����� �������_ʣ�౾�𲿷� ; */
/*run;*/



*��������Ҫ׼M2�ͻ��Ĵ������_1��ǰ_M1_ʣ�౾�𲿷�;
*������dept1����������׼M2�ͻ�֮�󣬱��������ֶΣ�ƴ���µ׵Ĵ������ʣ�±��𲿷־��Ǵ������_1��ǰ_M1_ʣ�౾�𲿷�;
proc sql;
create table dept1_m as 
select a.contract_no,a.�ͻ�����,a.Ӫҵ��,a.�������_1��ǰ_M1,b.�������_ʣ�౾�𲿷� as �������_1��ǰ_M1_ʣ�౾�𲿷�
from dept_ as a
left join repayfin.payment_daily(where=(cut_date=&month_begin.-1)) as b on a.contract_no=b.contract_no and a.Ӫҵ��=b.Ӫҵ��;
quit;

*---------------------������ǰM2�ͻ���ϸ---------------------------------------*;

*��������ǰM2�ͻ���ϸ��Ҫ����ʷ���ݱ�������Ҫ�ñ���payment_daily��cut_date=���µ׵ı��������󣬱��磺"C2017080815403414972975",����11�£�
�ÿͻ�11��2�Ż����payment_daily_201810��cut_date=mdy(10,31,2018)��M2�ģ�������payment_daily_201811�µ�cut_date=mdy(10,31,2018)��M1��,
ʵ��Ӧ����M2�ģ����Ի�������ʷ���ݣ���ʷ����ÿ��Ҫ�ֶ���һ�£�����2018��11�£�·������ʷ���ݵ�2018��10�µ�;

data aaa;
set aa.payment_daily(where=(cut_date=&l_month_end.));
if ����_M2��ͬ�������>0;
if Ӫҵ��^="APP";
keep contract_no �ͻ����� Ӫҵ�� ����_M2��ͬ�������   �������_ʣ�౾�𲿷�;
rename �������_ʣ�౾�𲿷�=����_M2��ͬ�������_ʣ�౾�𲿷�;
run;

/*PROC EXPORT DATA=all_1 OUTFILE= "E:\guan\�ռ����ʱ����\��������\����\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="��ʧ��ĸ";run;*/
/*PROC EXPORT DATA=C1 OUTFILE= "E:\guan\�ռ����ʱ����\��������\����\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="1����ǰ��C";run;*/
/*PROC EXPORT DATA=C2 OUTFILE= "E:\guan\�ռ����ʱ����\��������\����\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="2����ǰ��C";run;*/
/*PROC EXPORT DATA=dept1_m OUTFILE= "E:\guan\�ռ����ʱ����\��������\����\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="1����ǰ׼M2�ͻ���ϸ";run;*/
/*PROC EXPORT DATA=aaa OUTFILE= "E:\guan\�ռ����ʱ����\��������\����\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="2����ǰ׼M2�ͻ���ϸ";run;*/
/*PROC EXPORT DATA=C1_mx OUTFILE= "E:\guan\�ռ����ʱ����\��������\����\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="1����ǰ��C��ϸ";run;*/
/*PROC EXPORT DATA=C2_mx OUTFILE= "E:\guan\�ռ����ʱ����\��������\����\dept.xlsx" DBMS=EXCEL REPLACE;SHEET="2����ǰ��C��ϸ";run;*/
