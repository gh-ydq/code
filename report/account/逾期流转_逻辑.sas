/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname repayFin  "E:\guan\�м��\repayfin";*/
/**/
/*x  "E:\guan\�ռ����ʱ����\������ת\��������ת����.xlsx"; */
/*proc import datafile="E:\guan\�ռ����ʱ����\������ת\Ӫҵ��.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\�ռ����ʱ����\������ת\Ӫҵ��.xls"*/
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
set repayFin.payment_daily(keep=contract_no  od_days cut_date ������� ����_���տۿ�ʧ�ܺ�ͬ es Ӫҵ�� repay_date pre_1m_status)	;
run;
proc sort data=month1day ;by CONTRACT_no cut_date;run;
data  cc;
set month1day;
if Ӫҵ��^=""; *������޳�����;
if Ӫҵ��^="APP";
format �ڳ���ǩ ��ĩ��ǩ $30.;
last_oddays=lag(od_days);
last_�������=lag(�������);
last_����_���տۿ�ʧ�ܺ�ͬ=lag(����_���տۿ�ʧ�ܺ�ͬ);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_�������=�������;last_����_���տۿ�ʧ�ܺ�ͬ=����_���տۿ�ʧ�ܺ�ͬ;end;
if cut_date=&dt.;
/*if cut_date=mdy(10,14,2016);*/
if 1<=last_oddays<=6 or (last_oddays=0 and last_����_���տۿ�ʧ�ܺ�ͬ=1)then �ڳ���ǩ="01:1-7";
else if 7<=last_oddays<=14 then �ڳ���ǩ="02:8-15";
else if 15<=last_oddays<=24 then �ڳ���ǩ="03:16-25";
else if 25<=last_oddays<=29 then �ڳ���ǩ="04:26-30";
else if 30<=last_oddays<=59 then �ڳ���ǩ="05:31-60";
else if 60<=last_oddays<=89 then �ڳ���ǩ="06:61-90";
else if 90<=last_oddays<=119 then �ڳ���ǩ="07:91-120";
else if 120<=last_oddays<=179 then �ڳ���ǩ="08:121-180";

if 1<=od_days<=6 or (od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1)then ��ĩ��ǩ="01:1-7";
else if 7<=od_days<=14 then ��ĩ��ǩ="02:8-15";
else if 15<=od_days<=24 then ��ĩ��ǩ="03:16-25";
else if 25<=od_days<=29 then ��ĩ��ǩ="04:26-30";
else if 30<=od_days<=59 then ��ĩ��ǩ="05:31-60";
else if 60<=od_days<=89 then ��ĩ��ǩ="06:61-90";
else if 90<=od_days<=119 then ��ĩ��ǩ="07:91-120";
else if 120<=od_days<=179 then ��ĩ��ǩ="08:121-180";

*����;
if ((od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1) or 
((od_days=7 or od_days=15 or od_days=25 or od_days=30 or od_days=60 or od_days=90 or od_days=120) and last_oddays<od_days))
then  ����=1;else ����=0;
*��ת����;
if (1<=od_days<=6 and last_oddays>6) or 
   (7<=od_days<=14 and last_oddays>14) or
   (15<=od_days<=24 and last_oddays>24)  or
   (25<=od_days<=29 and last_oddays>29) or
   (30<=od_days<=59 and last_oddays>59) or
   (60<=od_days<=89 and last_oddays>89) or
   (90<=od_days<=119 and last_oddays>119) or
   (120<=od_days<=179 and last_oddays>179)  then ��ת����=1;else ��ת����=0;
*��ת����;
if ((1<=last_oddays<=6 or (last_oddays=0 and last_����_���տۿ�ʧ�ܺ�ͬ=1)) and od_days<1) or 
   (7<=last_oddays<=14 and od_days<7) or 
   (15<=last_oddays<=24 and od_days<15)  or
   (25<=last_oddays<=29 and od_days<25) or
   (30<=last_oddays<=59 and od_days<30) or
   (60<=last_oddays<=89 and od_days<60) or
   (90<=last_oddays<=119 and od_days<90) or
   (120<=last_oddays<=189 and od_days<120) then ��ת����=1;else ��ת����=0;
*������;
if ((1<=last_oddays<=6 or (last_oddays=0 and last_����_���տۿ�ʧ�ܺ�ͬ=1)) and od_days>6) or 
   (7<=last_oddays<=14 and od_days>14) or
   (15<=last_oddays<=24 and od_days>24)  or
   (25<=last_oddays<=29 and od_days>29) or
   (30<=last_oddays<=59 and od_days>59) or
   (60<=last_oddays<=89 and od_days>89) or
   (90<=last_oddays<=119 and od_days>119) or
   (120<=last_oddays<=179 and od_days>179) then ������=1;else ������=0;
*�߻�;
   if od_days=0 and (last_oddays>0 or last_����_���տۿ�ʧ�ܺ�ͬ=1)  then �߻�=1;else �߻�=0;
run;
proc sql;*�����������ȡ��ʱ��ɸѡ���������������ĩ��ǩ=""������180�����ϵ�;
create table cc1(where=(��ĩ��ǩ^="")) as
select ��ĩ��ǩ,sum(����) as ���� ,sum(��ת����) as ��ת����,count(*) as ��ĩ,sum(�������) as �������  from cc (where=(od_days>0 or (od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1))) group by ��ĩ��ǩ;
quit;

proc sql;*�����������ȡ��ʱ��ɸѡ��������������ڳ���ǩ=""������180�����ϵ�;
create table cc1_1(where=(�ڳ���ǩ^="")) as
select �ڳ���ǩ,sum(��ת����) as ��ת����,sum(������) as ������,count(*) as �ڳ�  from cc (where=(last_oddays>0 or (last_oddays=0 and last_����_���տۿ�ʧ�ܺ�ͬ=1))) group by �ڳ���ǩ;
quit;
proc sql;*�ڳ���ǩ=""����ǰ�����ڣ�����߻ص�;
create table cc1_2(where=(�ڳ���ǩ^="")) as
select �ڳ���ǩ,sum(�߻�) as �߻�   from cc  group by �ڳ���ǩ;
quit;
proc sql;
create table cc2 as
select a.*,b.*,c.�߻� from cc1 as a
left join cc1_1 as b on a.��ĩ��ǩ=b.�ڳ���ǩ
left join cc1_2 as c on a.��ĩ��ǩ=c.�ڳ���ǩ;
quit;
data st1 st2;
set cc2;
if ��ĩ��ǩ in ("01:1-7","02:8-15","03:16-25","04:26-30") then output st1;
else output st2;
run;

filename DD DDE 'EXCEL|[��������ת����.xlsx]Sheet1!r4c5:r7c10';
data _null_;set st1;file DD;put �ڳ� ���� ��ת���� ��ת���� ������ �߻�;run;
filename DD DDE 'EXCEL|[��������ת����.xlsx]Sheet1!r4c12:r7c13';
data _null_;set st1;file DD;put ��ĩ �������;run;

filename DD DDE 'EXCEL|[��������ת����.xlsx]Sheet1!r9c5:r12c10';
data _null_;set st2;file DD;put �ڳ� ���� ��ת���� ��ת���� ������ �߻�;run;
filename DD DDE 'EXCEL|[��������ת����.xlsx]Sheet1!r9c12:r12c13';
data _null_;set st2;file DD;put ��ĩ �������;run;
proc sql;
create table aall as
select count(CONTRACT_NO) as δ�������,sum(�������) as δ���������� from cc(where=(pre_1m_status not in('09_ES','11_Settled')));
quit;
filename DD DDE 'EXCEL|[��������ת����.xlsx]Sheet1!r4c2:r4c3';
data _null_;set aall;file DD;put δ������� δ����������;run;

data branch1;
set branch end=last;
call symput ("dept_"||compress(_n_),compress(Ӫҵ��));

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
create table cc1(where=(��ĩ��ǩ^="")) as
select ��ĩ��ǩ,sum(����) as ���� ,sum(��ת����) as ��ת����,count(*) as ��ĩ,sum(�������) as �������  from cc (where=((od_days>0 or (od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1)) and Ӫҵ��="&&dept_&i")) group by ��ĩ��ǩ;
quit;

proc sql;
create table cc1_1(where=(�ڳ���ǩ^="")) as
select �ڳ���ǩ,sum(��ת����) as ��ת����,sum(������) as ������,count(*) as �ڳ�  from cc (where=((last_oddays>0 or (last_oddays=0 and last_����_���տۿ�ʧ�ܺ�ͬ=1))and Ӫҵ��="&&dept_&i")) group by �ڳ���ǩ;
quit;
proc sql;
create table cc1_2(where=(�ڳ���ǩ^="")) as
select �ڳ���ǩ,sum(�߻�) as �߻�   from cc(where=( Ӫҵ��="&&dept_&i"))  group by �ڳ���ǩ;
quit;
proc sql;
create table cc2 as
select a.��ĩ��ǩ as ��ǩ,b.*,c.*,d.�߻� from lable as a
left join cc1 as b on a.��ĩ��ǩ=b.��ĩ��ǩ
left join cc1_1 as c on a.��ĩ��ǩ=c.�ڳ���ǩ
left join cc1_2 as d on a.��ĩ��ǩ=d.�ڳ���ǩ;
quit;
data st1 st2;
set cc2;
if ��ǩ in ("01:1-7","02:8-15","03:16-25","04:26-30") then output st1;
else output st2;
run;
filename DD DDE "EXCEL|[��������ת����.xlsx]Sheet1!r&&totalb1_row_&i..c5:r&&totale1_row_&i..c10";
data _null_;set st1;file DD;put �ڳ� ���� ��ת���� ��ת���� ������ �߻�;run;
filename DD DDE "EXCEL|[��������ת����.xlsx]Sheet1!r&&totalb1_row_&i..c12:r&&totale1_row_&i..c13";
data _null_;set st1;file DD;put ��ĩ �������;run;

filename DD DDE "EXCEL|[��������ת����.xlsx]Sheet1!r&&totalb2_row_&i..c5:r&&totale2_row_&i..c10";
data _null_;set st2;file DD;put �ڳ� ���� ��ת���� ��ת���� ������ �߻�;run;
filename DD DDE "EXCEL|[��������ת����.xlsx]Sheet1!r&&totalb2_row_&i..c12:r&&totale2_row_&i..c13";
data _null_;set st2;file DD;put ��ĩ �������;run;
proc sql;
create table aall as
select count(CONTRACT_NO) as δ�������,sum(�������) as δ���������� from cc(where=(es=. and Ӫҵ��="&&dept_&i"));
quit;
filename DD DDE "EXCEL|[��������ת����.xlsx]Sheet1!r&&totalb1_row_&i..c2:r&&totalb1_row_&i..c3";
data _null_;set aall;file DD;put δ������� δ����������;run;
%end;
%mend;
%city_table();

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
if od_days=0 and (last_oddays>0 or last_����_���տۿ�ʧ�ܺ�ͬ=1) ;
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
if od_days=0 and (last_oddays>0 or last_����_���տۿ�ʧ�ܺ�ͬ=1) ;
run;

/*data kan2;*/
/*set month1day;*/
/*if Ӫҵ��^=""; */
/*last_oddays=lag(od_days);*/
/*last_����_���տۿ�ʧ�ܺ�ͬ=lag(����_���տۿ�ʧ�ܺ�ͬ);*/
/*by CONTRACT_no cut_date;*/
/*if first.contract_no then do ;last_oddays=od_days;last_�������=�������;last_����_���տۿ�ʧ�ܺ�ͬ=����_���տۿ�ʧ�ܺ�ͬ;end;*/
/*if cut_date=&dt.-3;*/
/*if od_days=0 and (last_oddays>0 or last_����_���տۿ�ʧ�ܺ�ͬ=1) ;*/
/*run;*/
