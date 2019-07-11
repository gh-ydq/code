/*option validvarname=any;option compress=yes;*/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname zq "E:\guan\�м��\zq";*/
/*libname account 'E:\guan\ԭ����\account';*/

*��β�е����ļ�����������·��������;

data macrodate;
format date  start_date  fk_month_begin month_begin  end_date last_month_end last_month_begin month_end yymmdd10.;*����ʱ�������ʽ;
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(12,31,2017);*/
call symput("tabledate",date);*����һ����;
start_date = intnx("month",date,-2,"b");
call symput("start_date",start_date);
month_begin=intnx("month",date,0,"b");
call symput("month_begin",month_begin);
month_end=intnx("month",date,1,"b")-1;
call symput("month_end",month_end);
last_month_end=intnx("month",date,0,"b")-1;
call symput("last_month_end",last_month_end);
last_month_begin=intnx("month",date,-1,"b");
call symput("last_month_begin",last_month_begin);
if day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*����26-����25��ѭ��;
end_date = mdy(month(date)+1,25,year(date));end;
else do;fk_month_begin = mdy(month(date)-1,26,year(date));
end_date = mdy(month(date),25,year(date));end;
/*����һ��12�µ׸��µ�һ��1�³����������Ȼ��������µ׻���ֿ�ֵ*/
if month(date)=12 and day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*����26-����25��ѭ��;
end_date = mdy(month(date)-11,25,year(date)+1);end;
else if month(date)=1 and day(date)<=25 then do;fk_month_begin = mdy(month(date)+11,26,year(date)-1);
end_date = mdy(month(date),25,year(date));end;
call symput("fk_month_begin",fk_month_begin);
call symput("end_date",end_date);
run;
*-----------------------------------------------------------------ÿ��M1M2��M2M3�ͻ�**��������-------------------------------------------------------------------------------------*;
data aa;
format dt  yymmdd10.;
format dtt  $20. ;
 dt = today() - 1;
 dtt=compress(put(dt,yymmdd10.),"-");
call symput("dtt", dtt);
call symput("dt", dt);
run;

%put &dtt.;
/*%let dtt=mdy(12,31,2017);*/
data payment_daily;
set repayFin.payment_daily;
if contract_no='C2018101613583597025048' then delete;*�����������ľ�᲻�ô���,�޳���ĸ����;
if contract_no='C2017121414464569454887' then delete;*���ί��ͻ����ô���,�޳���ĸ����;
if contract_no='C2017111716235470079023' and month='201904' then delete;*������4�·�����̫�٣�4�·ݲ������ĸ����,�޳���ĸ����;
run;

/*������M1M2�ͻ�����ȫ����*/
data kank_1;
set payment_daily(where=(cut_date=&dt.));
if contract_no="C2017090517364935629487" and month="201809" then delete ;
if ����_���µ�M1=1 and Ӫҵ��^="APP";
keep CONTRACT_NO �ʽ����� �ͻ����� Ӫҵ�� �������_1��ǰ_M1 ;
run;
data kank;
set payment_daily;

if ����_���µ�M1=1;
if ����_M1M2^=1;
keep CONTRACT_NO  ������� cut_date ;
rename  cut_date=��������;
run;
/*clear_date����ë���ģ�����������>30��ʱ���ͻ�Ƿ�����ʣ����˵�һ��֮��repay_date���Զ�������һ���˵��գ�
clear_date����0��Ϊ�˵õ��������ڣ�������_M1M2��1���0��ʱ��cut_date����ڽ�������
�߼��ǣ�����_M1M2^=1,��һ������_M1M2=0�ľ��ǽ������ڣ������ȥ�ؾͿ���*/
proc sort data = kank ;by contract_no  ;run; 
proc sort data = kank out = kank1 nodupkey;by contract_no;run; 
proc sort data = kank1 ;by ��������;run; 

proc sql;
create table kank_ as 
select a.*,b.*
from kank_1 as a
left join kank1 as b
on a.contract_no=b.contract_no;
quit;

proc sort data=kank_;by  descending ��������;run;

data kankk_1;
set payment_daily(where=(cut_date=&dt.));
if ����_���µ�M2=1 and Ӫҵ��^="APP";
keep CONTRACT_NO �ʽ����� �ͻ����� Ӫҵ�� �������_1��ǰ_M2_r ;
run;
/*��ͬ�ʽ������ֿ��󻹿�����*/
data kankk__1;
set payment_daily(where=(cut_date=&dt.));
if ����_���µ�M2=1 and Ӫҵ��^="APP";
if ����_M2M3^=1 ;
if �ʽ����� not in ("jsxj1");
keep CONTRACT_NO �ʽ����� ������� ;
run;
/*data kankk__2;*/
/*set repayFin.payment_daily(where=(cut_date=&dt.));*/
/*if ����_���µ�M2=1 and Ӫҵ��^="APP";*/
/*if ����_M2M3^=1 ;*/
/*if �ʽ����� ="xyd1";*/
/*keep CONTRACT_NO �ʽ����� ������� ;*/
/*run;*/
data kankk__3;
set payment_daily(where=(cut_date=&dt.));
if ����_���µ�M2=1 and Ӫҵ��^="APP";
if ����_M2M3^=1 ;
if �ʽ����� ="jsxj1";
keep CONTRACT_NO �ʽ����� ������� ;
run;
data kankk__;
set kankk__1  kankk__3;
run;
/*ȡ��������,ȡdtl�����һ��������Ϊ��������,С���,�����������������*/
proc sql;
create table kankk1 as
select a.*,b.OFFSET_DATE as ��������
from kankk__1  as a
left join zq.bill_fee_dtl(where=(FEE_NAME in ("����","��Ϣ"))) as b
on a. contract_no=b.CONTRACT_NO
where OFFSET_DATE<=&dt.;
quit;
proc sort data=kankk1 ;by contract_no descending ��������;run;
proc sort data=kankk1 nodupkey;by contract_no;run;
/*proc sql;*/
/*create table kankk2 as*/
/*select a.*,b.clear_date as ��������*/
/*from kankk__2  as a*/
/*left join repayfin.Tttrepay_plan_xyd as b*/
/*on a. contract_no=b.CONTRACT_NO;*/
/*quit;*/
/*proc sort data=kankk2 ;by contract_no descending ��������;run;*/
/*proc sort data=kankk2 nodupkey;by contract_no;run;*/
proc sql;
create table kankk3 as
select a.*,b.clear_date_js as ��������
from kankk__3  as a
left join repayfin.Tttrepay_plan_js as b
on a. contract_no=b.CONTRACT_NO;
quit;
proc sort data=kankk3 ;by contract_no descending ��������;run;
proc sort data=kankk3 nodupkey;by contract_no;run;
data kankk;
set kankk1  kankk3;
run;



proc sql;
create table kankk_ as 
select a.* ,b.*,c.��������
from kankk_1 as a 
left join kankk__ as b on a.contract_no=b.contract_no
left join kankk as c on  a.contract_no=c.contract_no;
quit;
proc sort data=kankk_;by  descending ��������;run;

/*data kankk_;*/
/*set kankk_;*/
/*/*�ֶ��޸��Թ��ӳٿͻ�*/*/
/*if contract_no in ("C2017080410211770435844","C2017113013252201372210") then ��������=mdy(5,31,2018);*/
/*run;*/
/*data kankk_;*/
/*set kankk_;*/
/*if ��������<&month_begin. then do;*/
/*��������="";*/
/*�������="";*/
/*end;*/
/*run;*/*/;

data bill_month;
set payment_daily(where=(cut_date=&dt.));
if Ӫҵ��^="APP";
if &month_begin.<=repay_date<=&month_end.;
if clear_date>0;
keep contract_no �ͻ����� REPAY_DATE CLEAR_DATE  ;
run;
/*proc sort data=aa;by  REPAY_DATE CLEAR_DATE  ;run;*/

*�����ļ����������;

/*PROC EXPORT DATA=kank_*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M1M2����ͻ�"; RUN;*/
/*PROC EXPORT DATA=kankk_*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M2M3����ͻ�"; RUN;*/
/*PROC EXPORT DATA=bill_month*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="�����˵�����ͻ��б�"; RUN;*/

*---------------------------------------------------------------����m1��m2����-----------------------------------------------------------------------*;
data mm1;
set payment_daily(where=(cut_date=&dt.));
if ����_M1��ͬ�������>0;
if Ӫҵ��^="APP";
keep   contract_no �ͻ����� Ӫҵ�� �������_ʣ�౾�𲿷� ������� od_days �ʽ�����;
run;

data mm2;
set payment_daily(where=(cut_date=&dt.));
if ����_M2��ͬ�������>0;
if Ӫҵ��^="APP";
keep   contract_no �ͻ����� Ӫҵ�� �������_ʣ�౾�𲿷� ������� od_days �ʽ�����;
run;

*�����ļ����������;
/*PROC EXPORT DATA=mm1*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\��ǰM1��M2�ͻ���ϸ_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M1�ͻ���ϸ"; RUN;*/
/*PROC EXPORT DATA=mm2*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\��ǰM1��M2�ͻ���ϸ_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M2�ͻ���ϸ"; RUN;*/


*����M2������ϸ;
*��Ϊpayment_daily��������ȡ���ǵ�һ�ζԹ�����,�ʲ��ֻ���ͻ�ʵ�ʻ�����m2�����ǶԹ�����Ӱ���ѷ�ĸ�������m1�������ѻ������ָ����;
data payment;
set repayfin.payment;
run;
*�³�����;
data m2_denominator_1;
set payment;
if Ӫҵ��^="APP";
if cut_date=&last_month_end.;
if 30<od_days<60;
keep contract_no cut_date od_days;
run;
*��������;
data m2_denominator_2;
set payment_daily;
if Ӫҵ��^="APP";
if cut_date^=&last_month_end.;
if od_days=31;
keep contract_no cut_date od_days;
run;
data m2_denominator;
set m2_denominator_2 m2_denominator_1;
run;
proc sort data=m2_denominator;by contract_no cut_date;run;
proc sort data=m2_denominator out=aa1 nouniquekey;by contract_no;run;
/*proc sort data=m2_denominator nodupkey;by contract_no;run;*/
proc sql;
create  table m2_denominator_ as 
select a.contract_no,a.cut_date,b.�ʽ�����,b.�ͻ�����,b.Ӫҵ��,b.������� as �������_1��ǰ from m2_denominator as a
left join payment_daily(where=(Ӫҵ��^="APP" and cut_date=&last_month_end.)) as b on a.contract_no=b.contract_no;
quit;
proc sort data=m2_denominator_ nodupkey;by contract_no cut_date;run;
*���»����һ������ڵ���������������״̬��Χ��;
data m2_molecule;
set payment_daily;
if Ӫҵ��^="APP" and cut_date^=&last_month_end.;
/*if clear_date=cut_date;*/
if 30<=last_oddays<60 and last_oddays>od_days;
keep contract_no cut_date od_days last_oddays �������;
run;
proc sql;
create table m2_denominator_e as 
select a.*,b.�������,b.cut_date as �������� from m2_denominator_ as a
left join m2_molecule as b on a.contract_no=b.contract_no and a.cut_date<=b.cut_date;
quit;
proc sort data=m2_denominator_e;by descending �������� cut_date;run;
data m2_denominator_e;
set m2_denominator_e;
attrib _all_ label="";
drop cut_date;
run;

*����M3������ϸ;
data m3_denominator_1;
set payment;
if Ӫҵ��^="APP";
if cut_date=&last_month_end.;
if 60<od_days<90;
keep contract_no cut_date od_days;
run;
data m3_denominator_2;
set payment_daily;
if Ӫҵ��^="APP";
if cut_date^=&last_month_end.;
if od_days=61;
keep contract_no cut_date od_days;
run;
data m3_denominator;
set m3_denominator_2 m3_denominator_1;
run;
proc sort data=m3_denominator;by contract_no cut_date;run;
proc sort data=m3_denominator out=aa1 nouniquekey;by contract_no;run;
/*proc sort data=m2_denominator nodupkey;by contract_no;run;*/
proc sql;
create  table m3_denominator_ as 
select a.contract_no,a.cut_date,b.�ʽ�����,b.�ͻ�����,b.Ӫҵ��,b.������� as �������_1��ǰ from m3_denominator as a
left join payment_daily(where=(Ӫҵ��^="APP" and cut_date=&last_month_end.)) as b on a.contract_no=b.contract_no;
quit;
proc sort data=m3_denominator_ nodupkey;by contract_no cut_date;run;
data m3_molecule;
set payment_daily;
if Ӫҵ��^="APP" and cut_date^=&last_month_end.;
/*if clear_date=cut_date;*/
if 60<=last_oddays<90 and last_oddays>od_days;
keep contract_no cut_date od_days last_oddays �������;
run;
proc sql;
create table m3_denominator_e as 
select a.*,b.�������,b.cut_date as �������� from m3_denominator_ as a
left join m3_molecule as b on a.contract_no=b.contract_no and a.cut_date<=b.cut_date;
quit;
proc sort data=m3_denominator_e;by descending �������� cut_date;run;
data m3_denominator_e;
set m3_denominator_e;
attrib _all_ label="";
drop cut_date;
run;

*---------------------------------------------------------------���ֻ���ͻ�-----------------------------------------------------------------------*;
data part_payment_1;
set payment_daily(where=(cut_date=&dt.));
if Ӫҵ��^="APP";
if ����_M2��ͬ�������>0;
run;
*����M3״̬�Ŀͻ�;
proc sql;
create table part_payment_2 as 
select * from payment_daily where cut_date=&dt. and Ӫҵ��^="APP" and od_days>61 and contract_no in 
(select contract_no from m3_denominator);
quit;
data aa;
set part_payment_1 part_payment_2;
run;
proc sort data=aa nodupkey;by contract_no;run;

*�ҳ����ڽ��̵Ŀͻ�;
data aa1;
set aa;
if �ʽ�����="jsxj1";
run;
*�ҳ����̸��µ��»�;
data aaa1;
set repayfin.Tttrepay_plan_js;
if &last_month_begin.<=repay_date_js<=&month_end.;
�ѻ���Ϣ=SETLPRCP+SETLNORMINT;
run;
proc sql;
create table aaa1_ as
select contract_no,sum(�ѻ���Ϣ) as �ѻ���Ϣ
from aaa1
group by contract_no;
quit;
proc sort data=aaa1_ nodupkey ;by contract_no;run;
proc sql;
create table aa_js as 
select a.*,b.�ѻ���Ϣ 
from aa1 as a
left join aaa1_ as b
on a.contract_no=b.contract_no;
quit;
*�ҳ���������Ŀͻ�;
data aa2;
set aa;
if �ʽ�����^="jsxj1";
run;
*�ҳ���������Ŀͻ��»�;
proc sql;
create table aaa2 as 
select a.*,b.REPAY_DATE
from account.bill_fee_dtl as a 
left join account.repay_plan as b
on a.contract_no=b.contract_no and a.CURR_PERIOD=b.CURR_PERIOD;
quit;

proc sql;
create table aaa2_ as 
select contract_no ,sum(curr_receipt_amt) as �ѻ���Ϣ
from aaa2
where   &last_month_begin.<=REPAY_DATE<=&month_end.
group by contract_no;
quit;
proc sql;
create table aa_qita as
select a.*,b.�ѻ���Ϣ
from aa2 as a
left join aaa2_ as b 
on a.contract_no=b.contract_no;
quit;

data aa_;
set aa_js aa_qita;
if �ѻ���Ϣ>0;
keep contract_no �ͻ����� �ѻ���Ϣ;
run;


/*PROC EXPORT DATA=kank_*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M1M2����ͻ�"; RUN;*/
/*PROC EXPORT DATA=kankk_*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M2M3����ͻ�"; RUN;*/
/*PROC EXPORT DATA=m2_denominator_e*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="31-60�컹��ͻ�"; RUN;*/
/*PROC EXPORT DATA=m3_denominator_e*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="61-90�컹��ͻ�"; RUN;*/
/*PROC EXPORT DATA=bill_month*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="�����˵�����ͻ��б�"; RUN;*/
/**/
/*PROC EXPORT DATA=mm1*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\��ǰM1��M2�ͻ���ϸ_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M1�ͻ���ϸ"; RUN;*/
/*PROC EXPORT DATA=mm2*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\��ǰM1��M2�ͻ���ϸ_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="M2�ͻ���ϸ"; RUN;*/
/**/
/*PROC EXPORT DATA=aa_*/
/*OUTFILE= "E:\guan\�ռ����ʱ����\M1M2M3\����\M1M2-M2M3_&dtt..xls" DBMS=EXCEL REPLACE;SHEET="���ֻ���ͻ�����"; RUN;*/
