/*option validvarname=any;option compress=yes;*/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname approval 'E:\guan\ԭ����\approval';*/
/*libname zq 'E:\guan\�м��\zq';*/
/**/
/*x  "E:\guan\�ռ����ʱ����\1-15����������\Ӫҵ��1-15����������.xlsx"; */
/**/
/*proc import datafile="E:\guan\�ռ����ʱ����\Ӫҵ��DDE.xls"*/
/*out=dept dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

data dept;
set dept;
if Ӫҵ��='�Ͼ���ҵ������' then delete;*�Ͼ���ҵ������û��������180�����ڿͻ�;
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
if contract_no='C2018101613583597025048' then delete;*�����������ľ�᲻�ô���,�޳���ĸ����;
if contract_no='C2017121414464569454887' then delete;*���ί��ͻ����ô���,�޳���ĸ����;
if contract_no='C2017111716235470079023' and month='201904' then delete;*������4�·�����̫�٣�4�·ݲ������ĸ����,�޳���ĸ����;
run;
*������ǰ�������ʧ��ĸ;
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
if es=1 and es_date>=&last_month_end.-15 and cut_date=intnx('day',repay_date_tz,16) then ����_��������15�Ӻ�ͬ��ĸ=1;
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
select contract_no,sum(CURR_RECEIPT_AMT) as �ѻ�������Ϣ 
from account.Bill_fee_dtl(where=(fee_name in ("����","��Ϣ") and OFFSET_DATE=&nt. )) where contract_no in (select contract_no from cc1)
group by contract_no;quit;
proc sql;
create table cc3(where=(not od_days>0)) as
select a.contract_no,b.�ѻ�������Ϣ,a.CURR_RECEIVE_AMT,c.Ӫҵ��,d.od_days,d.�ʽ�����  from cc as a
left join cc2 as b on a.contract_no=b.contract_no
left join zq.Account_info as c on a.contract_no=c.contract_no 
left join payment_daily(where=(cut_date=&dt.)) as d on a.contract_no=d.contract_no ;
quit;
data cc3_1;
set cc3;
if CURR_RECEIVE_AMT>�ѻ�������Ϣ and sum(CURR_RECEIVE_AMT,-�ѻ�������Ϣ)>1 and �ѻ�������Ϣ<100;
if �ʽ����� not in ("jsxj1");
run;
*����;
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

data cc3_1_js;*����;
set tttrepay_plan_js;
if repay_date_js=&nt.;
if SETLPRCP^=PSPRCPAMT or SETLNORMINT^=PSNORMINTAMT;
run;

proc sql;
create table cc3_1_js1 as
select a.contract_no,sum(a.PSPRCPAMT,a.PSNORMINTAMT) as CURR_RECEIVE_AMT,b.Ӫҵ�� from cc3_1_js as a
left join payment_daily(where=(cut_date=&dt.)) as b on a.contract_no=b.contract_no;
quit;
data cc3_1;
set cc3_1 cc3_1_js1 ;
if Ӫҵ��^="APP";
run;
proc sort data=cc3_1 nodupkey;by contract_no;run;

proc sql;
create table cc3_2 as
select Ӫҵ��,count(*) as ���۸���,sum(CURR_RECEIVE_AMT) as ���۽�� 
from cc3_1  group by Ӫҵ��;quit;

proc sql;
create table cc4 as
select Ӫҵ��,count(*) as ����,sum(�������) as ���������� 
from payment_daily(where=(od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date and cut_date=&dt.))
group by Ӫҵ��;
quit;
proc sql;
create table cc5 as
select Ӫҵ��,count(*) as ����,sum(�������) as ���������� 
from payment_daily(where=(����_��������15�Ӻ�ͬ=1 and cut_date=&dt.))
group by Ӫҵ��;
quit;
proc sql;
create table cc6 as
select Ӫҵ��,count(*) as d1_15,sum(�������) as d1_15������� 
from payment_daily(where=(((od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date ) or 1<=od_days<=15) and cut_date=&dt.))
group by Ӫҵ��;
quit;

proc sql;
create table p1(drop=id) as
select a.*,b.���۸���,b.���۽��,c.����,c.���������� from dept as a
left join cc3_2 as b on a.Ӫҵ��=b.Ӫҵ��
left join cc4 as c on a.Ӫҵ��=c.Ӫҵ��
order by id;
quit;
proc sql;
create table p2(drop=id) as
select a.*,b.d1_15,b.d1_15�������,c.����,c.���������� from dept as a
left join cc6 as b on a.Ӫҵ��=b.Ӫҵ��
left join cc5 as c on a.Ӫҵ��=c.Ӫҵ��
order by id;
quit;
data one_seven;
set payment_daily(where=(((od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date ) or 1<=od_days<=15) and cut_date=&dt.));
if Ӫҵ��^="APP";
keep contract_no Ӫҵ�� �ͻ����� repay_date �ʽ�����;
run;

data month1day;
set payment_daily(keep=contract_no  od_days cut_date ������� ����_���տۿ�ʧ�ܺ�ͬ REPAY_DATE Ӫҵ��);
/*    repayFin.Lastday      (keep=contract_no  od_days cut_date ������� ����_���տۿ�ʧ�ܺ�ͬ REPAY_DATE Ӫҵ��);*/
run;
proc sort data=month1day ;by CONTRACT_no  cut_date descending Ӫҵ��;run;


data  clear_17detail;
/*set  repayFin.payment_daily(keep=contract_no  od_days cut_date ������� ����_���տۿ�ʧ�ܺ�ͬ REPAY_DATE Ӫҵ��);*/
set month1day;
if Ӫҵ��^="";*ȥ������;
if Ӫҵ��^="APP";
last_oddays=lag(od_days);
last_�������=lag(�������);
last_�ۿ���=lag(����_���տۿ�ʧ�ܺ�ͬ);
by CONTRACT_no   cut_date;
if first.contract_no then do ;last_oddays=od_days;last_�������=�������;last_�ۿ���=����_���տۿ�ʧ�ܺ�ͬ;end;
*����;
if cut_date=&dt.;
*����;
/*if cut_date=&nt.;*/
/*if (1<=last_oddays<=14 and od_days<1) or (last_�ۿ���=1 and od_days<1);*/
if last_oddays>od_days or  (last_�ۿ���=1 and od_days<1);
repay_date = &dt.-last_oddays-1;
format ������ yymmdd10.;
������=&dt.;
keep contract_no Ӫҵ�� repay_date  ������ ;
run;
*�ۼ�������ϸ;
%macro new_overdue;
proc delete data=new_overdue;run;
data _null_;
n = day(&dt.) - 1;
call symput("n", n);
run;
%do i=0 %to &n.;
data cc(drop=����_���տۿ�ʧ�ܺ�ͬ REPAY_DATE od_days);
set payment_daily(keep=CONTRACT_NO od_days Ӫҵ�� �ͻ����� cut_date REPAY_DATE ����_���տۿ�ʧ�ܺ�ͬ ���֤����);
if Ӫҵ��^="APP";
if Ӫҵ��^="";*ȥ������;
if od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date and cut_date=intnx("day",intnx("month",&dt.,0,"b"),&i.);
rename cut_date=��������;
run;
proc append data=cc base=new_overdue;run;
%end;
%mend;
%new_overdue;
/*%let dt=mdy(12,31,2017);*/
*�ۼƻ�����ϸ;
proc sql;
create table pay_repay as 
select a.*,b.BEGINNING_CAPITAL,b.CURR_RECEIVE_INTEREST_AMT,b.MONTH_SERVICE_FEE from payment_daily as a 
left join account.repay_plan as b on a.contract_no=b.contract_no and a.repay_date=b.repay_date;
quit;
data pay_repay_;
set pay_repay;
�˵��մ������15��ĸ=sum(BEGINNING_CAPITAL,CURR_RECEIVE_INTEREST_AMT,MONTH_SERVICE_FEE)*����_��������15�Ӻ�ͬ��ĸ;
�˵��մ������15����=sum(BEGINNING_CAPITAL,CURR_RECEIVE_INTEREST_AMT,MONTH_SERVICE_FEE)*����_��������15�Ӻ�ͬ;
run;
data flow_Denominator;
set pay_repay_;
if cut_date^=&l_month_end. and Ӫҵ��^="APP";
if ����_��������15�Ӻ�ͬ��ĸ=1;
keep contract_no od_days Ӫҵ�� �˵��մ������15��ĸ  REPAY_DATE cut_date �ͻ����� od_periods;
run;
%macro eight_overdue;
proc delete data=eight_overdue;run;
data _null_;
n = day(&dt.) - 1;
call symput("n", n);
run;
%do i=0 %to &n.;
data cc(drop=����_���տۿ�ʧ�ܺ�ͬ REPAY_DATE od_days);
set pay_repay_(keep=CONTRACT_NO od_days Ӫҵ��  ����_��������15�Ӻ�ͬ �ͻ����� cut_date REPAY_DATE ����_���տۿ�ʧ�ܺ�ͬ ���֤���� od_periods �˵��մ������15����);
if Ӫҵ��^="APP";
if Ӫҵ��^="";*ȥ������;
last_oddays=lag(od_days);
if ����_��������15�Ӻ�ͬ=1 and cut_date=intnx("day",intnx("month",&dt.,0,"b"),&i.);
rename cut_date=�������� �˵��մ������15����=�������;
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
proc sort data =New_overdue ;by ��������;run;
proc sort data =Eight_overdue ;by ��������;run;
proc sort data =flow_Denominator ;by REPAY_DATE;run;

data test1_7 ;
set payment_daily;
if Ӫҵ��^="APP";
if cut_date=&dt. and repay_date=&dt.  and od_days=0;
run;
proc sql;
create table test1_7kan as
select Ӫҵ��,sum(����_���տۿ�ʧ�ܺ�ͬ)/count(*) as ������ format=percent7.2 from test1_7 group by Ӫҵ��;
quit;
proc sql;
create table all1_7 as
select "�ܼ�" as Ӫҵ��,sum(����_���տۿ�ʧ�ܺ�ͬ)/count(*) as ������ format=percent7.2 from test1_7 ;
quit;
proc sql;
create table lrl1_7 as
select a.id,a.Ӫҵ��,b.������ from dept as a
left join test1_7kan as b on a.Ӫҵ��=b.Ӫҵ��;
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
data cc(drop=����_���տۿ�ʧ�ܺ�ͬ REPAY_DATE od_days);
set repayFin.payment_daily(keep=CONTRACT_NO od_days Ӫҵ�� �ͻ����� cut_date REPAY_DATE ����_���տۿ�ʧ�ܺ�ͬ ������� ����_��������15�Ӻ�ͬ);
if Ӫҵ��^="";*ȥ������;
if Ӫҵ��^="APP";
if ����_��������15�Ӻ�ͬ=1 and cut_date=intnx("day",&dt.-2,&i.);
rename cut_date=��������;
run;
proc append data=cc base=monday;run;
%end;
%mend;
%monday;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r4c2:r40c5';
data _null_;set p1;file DD;put ���۸��� ���۽�� ���� ���������� ;run;
filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r4c7:r40c10';
data _null_;set p2;file DD;put d1_15 d1_15������� ���� ���������� ;run;
filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]1_15�ͻ���ϸ!r2c1:r3000c5';
data _null_;set one_seven;file DD;put contract_no Ӫҵ�� �ͻ����� repay_date �ʽ����� ;run;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r46c1:r1000c4';
data _null_;set clear_17detail;file DD;put contract_no  Ӫҵ�� repay_date ������ ;run;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]���������ͬ��ϸ!r2c1:r10000c4';
data _null_;set New_overdue;file DD;put contract_no �ͻ����� Ӫҵ�� ��������  ;run;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]���»����ͬ��ϸ!r2c1:r10000c5';
data _null_;set Eight_overdue;file DD;put contract_no  �ͻ����� Ӫҵ�� �������� �������;run;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]������ʧ��ͬ��ĸ!r2c1:r10000c5';
data _null_;set flow_Denominator;file DD;put contract_no  �ͻ����� Ӫҵ�� REPAY_DATE �˵��մ������15��ĸ;run;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]c_m1�ͻ���ϸ!r2c1:r10000c6';
data _null_;set payment_daily(where=((od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and repay_date=cut_date or 1<=od_days<=30) and cut_date =&dt.));
file DD;put contract_no  �ͻ����� Ӫҵ�� od_days ������� �ʽ����� ;run;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]׼m2�ͻ���ϸ����!r2c1:r10000c6';
data _null_;set payment_daily(where=((����_���µ�M1>0  and ����_M1M2 =1) and cut_date =&dt.));
file DD;put contract_no  �ͻ����� Ӫҵ�� od_days ������� �ʽ����� ;run;

filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r4c6:r41c6';
data _null_;set Lrl1_7_end;file DD;put ������ ;run;
%macro monday_1;
%if &week.=1 %then %do;

proc sql;
create table out1 as 
select Ӫҵ��,count(�������)as ������� ,sum(�������) as ������ from monday group by Ӫҵ��;
quit;

proc sql;
create table out as 
select a.*,b.������� ,b.������ from dept as a left join out1 as b on a.Ӫҵ�� = b.Ӫҵ�� order by id;  
quit; 

/*proc sql;
create table monday_ru as
select Ӫҵ��,count(*) as ����,sum(�������) as ���������� 
from repayFin.payment_daily(where=(od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date and cut_date=&dt.))
group by Ӫҵ��;
quit;*/
proc sql;
create table monday_ru1 as
select Ӫҵ��,�������,CONTRACT_NO from payment_daily(where=(od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date and cut_date=&dt.));
quit;
proc sql;
create table monday_ru2 as 
select Ӫҵ��,�������,CONTRACT_NO from payment_daily(where=(od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date and cut_date=&dt. -1));
quit;
proc sql;
create table monday_ru3 as 
select Ӫҵ��,�������,CONTRACT_NO from payment_daily(where=(od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date and cut_date=&dt. -2));
quit;
/*proc sql;*/
/*create table monday_ru4 as */
/*select Ӫҵ��,�������,CONTRACT_NO from repayFin.payment_daily(where=(od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1 and REPAY_DATE=cut_date and cut_date=&dt. -3));*/
/*quit;*/


data monday_ru;
set monday_ru1 monday_ru2 monday_ru3;
run;
proc sql;
create table monday_liuru as 
select Ӫҵ��,count(*) as ����,sum(�������) as ���������� 
from monday_ru group by Ӫҵ��;
quit;
proc sql;
create table in_1 as 
select a.*,b.���� ,b.���������� from dept as a left join monday_liuru as b on a.Ӫҵ�� = b.Ӫҵ�� order by id;  
quit; 
*����������;
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
select Ӫҵ��,sum(����_���տۿ�ʧ�ܺ�ͬ)/count(*) as ������ format=percent7.2 ,count(*) as ���� from liurulv_ex group by Ӫҵ��;
quit;
proc sql;
create table liurulv_kan2 as
select "�ܼ�" as Ӫҵ��,sum(����_���տۿ�ʧ�ܺ�ͬ)/count(*) as ������ format=percent7.2 ,count(*) as ���� from liurulv_ex ;
quit;

proc sql;
create table liurulv_ex2 as 
select a.*,b.������ ,b.���� from in_1 as a left join liurulv_kan1 as b on a.Ӫҵ�� = b.Ӫҵ�� order by id;  
quit; 
data liurulv;
set liurulv_ex2 liurulv_kan2;
run;
*clear_17detail;
*��һ������;
data kan;
set month1day;
if Ӫҵ��^="";
if Ӫҵ��^="APP"; 
last_oddays=lag(od_days);
last_����_���տۿ�ʧ�ܺ�ͬ=lag(����_���տۿ�ʧ�ܺ�ͬ);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_�������=�������;last_����_���տۿ�ʧ�ܺ�ͬ=����_���տۿ�ʧ�ܺ�ͬ;end;/*2017-07-03*/
if cut_date=&dt.-1;
if last_oddays>od_days or  (last_�ۿ���=1 and od_days<1);
repay_date = &dt.-last_oddays-1;
format ������ yymmdd10.;
������=&dt.-1;
keep contract_no Ӫҵ�� repay_date  ������ ;
run;
/*2017-07-03*/
data kan1;
set month1day;
if Ӫҵ��^=""; 
if Ӫҵ��^="APP";
last_oddays=lag(od_days);
last_����_���տۿ�ʧ�ܺ�ͬ=lag(����_���տۿ�ʧ�ܺ�ͬ);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_�������=�������;last_����_���տۿ�ʧ�ܺ�ͬ=����_���տۿ�ʧ�ܺ�ͬ;end;/*2017-07-03*/
if cut_date=&dt.-2;
if last_oddays>od_days or  (last_�ۿ���=1 and od_days<1);
repay_date = &dt.-last_oddays-1;
format ������ yymmdd10.;
������=&dt.-2;
keep contract_no Ӫҵ�� repay_date  ������ ;
run;
/*data kan2_1;*/
/*set kan2(where =( last_oddays <6));*/
/*keep CONTRACT_NO Ӫҵ�� REPAY_DATE cut_date;*/
/*rename cut_date =  ������;*/
run;
data monday_repay_1;
set clear_17detail kan kan1 ;
run;

	filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r4c9:r40c10';
	data _null_;set out; file DD; put ������� ������ ; run ;
	filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r4c4:r40c5';
	data _null_;set in_1 ; file DD; put ���� ���������� ; run ;
	filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r4c6:r41c6';
	data _null_;set liurulv;file DD;put ������ ;run;
	filename DD DDE 'EXCEL|[Ӫҵ��1-15����������.xlsx]Sheet1!r46c1:r1000c4';
	data _null_;set monday_repay_1;file DD;put contract_no  Ӫҵ�� repay_date ������ ;run;

	%end;
	%mend;
%monday_1;
