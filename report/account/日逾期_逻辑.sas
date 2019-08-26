option validvarname=any;option compress=yes;
option compress = yes  validvarname = any;
libname approval 'E:\guan\ԭ����\approval';
libname account 'E:\guan\ԭ����\account';
libname repayFin "E:\guan\�м��\repayfin";

/*x 'E:\guan\�ռ����ʱ����\������\�����ڱ���.xls';*/
/**/
/*proc import datafile="E:\guan\�ռ����ʱ����\���ñ�1.xls"*/
/*out=branch(where=(Ӫҵ��^="")) dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\�ռ����ʱ����\������\�����ڱ���.xls"*/
/*out=branc(where=(product_name^="")) dbms=excel replace;*/
/*SHEET="��Ʒ$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

data _null_;
format dt nt lmd yymmdd10.;
dt = today() - 1;
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
lmd=intnx('month',dt,-1,'e');
call symput("lmd",lmd);
this_mon = substr(compress(put(dt,yymmdd10.),"-"),1,6);
call symput("this_mon",this_mon);
work_mon=substr(compress(put(lmd,yymmdd10.),"-"),1,6);
call symput("work_mon",work_mon);
put lmd work_mon;
run;

data apply_info;
set approval.apply_info
(keep = apply_code name id_card_no branch_code branch_name MANAGER_CODE MANAGER_NAME SOURCE_BUSINESS SOURCE_CHANNEL LOAN_PURPOSE DESIRED_PRODUCT ACQUIRE_CHANNEL);
if branch_code = "6" then branch_name = "�Ϻ�����·Ӫҵ��";
else if branch_code = "13" then branch_name = "�Ϻ�����Ӫҵ��";
else if branch_code = "16" then branch_name = "�������ֺ���·Ӫҵ��";
else if branch_code = "14" then branch_name = "�Ϸ�վǰ·Ӫҵ��";
else if branch_code = "15" then branch_name = "��������·Ӫҵ��";
else if branch_code = "17" then branch_name = "�ɶ��츮����Ӫҵ��";
else if branch_code = "50" then branch_name = "���ݵ�һӪҵ��";
else if branch_code = "55" then branch_name = "�����е�һӪҵ��";
else if branch_code = "57" then branch_name = "���ݽ�����·Ӫҵ��";
else if branch_code = "56" then branch_name = "�����е�һӪҵ��";
else if kindex(branch_name,"����")  then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"����")  then branch_name="������ҵ������";
else if kindex(branch_name,"��ɽ")  then branch_name="��ɽ�е�һӪҵ��";
else if kindex(branch_name,"���")  then branch_name="����е�һӪҵ��";
else if kindex(branch_name,"�人")  then branch_name="�人�е�һӪҵ��";
else if kindex(branch_name,"�γ�")  then branch_name="�γ��е�һӪҵ��";

rename branch_name = Ӫҵ��;
run;
/*total*/

data payment;
set repayFin.payment;
/*if month ^= "&this_mon." ;*/
if BRANCH_CODE ^= 105;
if status not in('09_ES','11_Settled');
run;
proc sort data = apply_info ;by APPLY_CODE;run;
proc sort data = payment ;by APPLY_CODE;run;

%put &this_mon.;
data payment_dept;
merge payment (in = a) apply_info(in =b);
by APPLY_CODE;
if a;
run;
/*total _ ÿ��*/
proc sql;
create table every_month as select month,count(�������_C) as ���� ,count(�������_M1) as M1,count(�������_M2) as M2,
count(�������_M3) as M3,count(�������_M4) as M4,count(�������_M5) as M5,count(�������_M6) as M6,count(�������_M6_plus) as M6plus,count(*)as �ܼ�,count(*)-count(�������_M6_plus) as ����
from payment_dept group by month;
quit;
proc sql;
create table every_month as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
every_month;
QUIT;
proc sql;
create table every_month_amount as select month,sum(�������_C) as ���� ,sum(�������_M1) as M1,sum(�������_M2) as M2,
sum(�������_M3) as M3,sum(�������_M4) as M4,sum(�������_M5) as M5,sum(�������_M6) as M6,sum(�������_M6_plus) as M6plus,sum(�������) as �ܼ�
from payment_dept group by month;
quit;
data every_month_amount;
set every_month_amount;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table every_month_amount as select *,sum(�ܼ� ,- M6plus) as ���� FROM 
every_month_amount;
quit;
proc sql;
create table every_month_amount as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
every_month_amount;
QUIT;


/*total��ÿ��*/
data payment_daily;
set repayfin.payment_daily(where=(cut_date ^=&lmd.));
if Ӫҵ�� ^="APP" and es^=1;
if pre_1m_status not in('09_ES','11_Settled');
format ����������� M1_������� M2_������� M3_������� M4_������� M5_������� M6_������� M6plus_�������;
if (od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ ^=1) or od_days=. then ����������� = �������;
else if  1<=od_days<=30 or (od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1) then M1_������� =�������;
else if 31<=od_days<=60 then M2_������� =�������;
else if 61<=od_days<=90 then M3_�������= �������;
else if 91<=od_days<=120 then M4_�������= �������;
else if 121<=od_days<=150 then M5_�������= �������;
else if 151<=od_days<=180 then M6_�������= �������;
else if 181<=od_days then M6plus_�������= �������;
run;

proc sql;
create table every_day1 as select cut_date,count(�����������) as ���� ,count(M1_�������) as M1,count(M2_�������) as M2,
count(M3_�������) as M3,count(M4_�������) as M4,count(M5_�������) as M5,count(M6_�������) as M6,count(M6plus_�������) as M6plus,count(*)as �ܼ�,sum(count(*),-count(M6plus_�������)) as ����
from payment_daily group by cut_date;
quit;
proc sql;
create table every_day as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
every_day1;
QUIT;

proc sql;
create table every_day_amount1 as select cut_date,sum(�����������) as ���� ,sum(M1_�������) as M1,sum(M2_�������) as M2,
sum(M3_�������) as M3,sum(M4_�������) as M4,sum(M5_�������) as M5,sum(M6_�������) as M6,sum(M6plus_�������) as M6plus,sum(�������) as �ܼ�
from payment_daily group by cut_date;
quit;
data every_day_amount2;
set every_day_amount1;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table every_day_amount3 as select *,sum(�ܼ�,-M6plus) as ���� FROM 
every_day_amount2;
quit;
proc sql;
create table every_day_amount as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
every_day_amount3;
QUIT;
/*��Ӫҵ����*/
data payment_daily_yesterday1;
set payment_daily;
if cut_date = &dt.;
run;
data payment_daily_yesterday;
set payment_daily_yesterday1;
IF kindex(Ӫҵ��,"�Ϻ�") THEN Ӫҵ�� = "�Ϻ�����·Ӫҵ��";
format ����  $20.;
if Ӫҵ�� in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�γ��е�һӪҵ��","���ݽ�����·Ӫҵ��","�����е�һӪҵ��","�����е�һӪҵ��" ,"�������ֺ���·Ӫҵ��",
"���ݵ�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��","��ͷ�е�һӪҵ��") then ����="����С��";

else if Ӫҵ�� in ("���ͺ����е�һӪҵ��","�����е�һӪҵ��","�ɶ��츮����Ӫҵ��","�����е�һӪҵ��",
"�人�е�һӪҵ��","�����е�һӪҵ��","��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��",
"�����е�һӪҵ��","����е�һӪҵ��") then ����="����С��";

else if Ӫҵ�� in ("������ҵ������","�����е�һӪҵ��",'��ͨ��ҵ������',"�Ͼ���ҵ������","����е�һӪҵ��","����е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��",
"�����е�һӪҵ��","�Ͼ��е�һӪҵ��","տ���е�һӪҵ��","��������·Ӫҵ��","�����е�һӪҵ��","��ɽ�е�һӪҵ��","�����е�һӪҵ��") then ����="�ѹ��ŵ�С��";
run;
proc sql;
create table payment_daily_yesterday_dept1_1 as select Ӫҵ�� as ά��, count(�����������) as ���� ,count(M1_�������) as M1,count(M2_�������) as M2,
count(M3_�������) as M3,count(M4_�������) as M4,count(M5_�������) as M5,count(M6_�������) as M6,count(M6plus_�������) as M6plus,count(*)as �ܼ�,count(*)-count(M6plus_�������) as ���� from payment_daily_yesterday group by Ӫҵ��;
quit;
proc sql;
create table payment_daily_yesterday_dept1 as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
payment_daily_yesterday_dept1_1;
QUIT;
proc sql;
create table payment_daily_yesterday_dept2_1 as select ���� as ά��, count(�����������) as ���� ,count(M1_�������) as M1,count(M2_�������) as M2,
count(M3_�������) as M3,count(M4_�������) as M4,count(M5_�������) as M5,count(M6_�������) as M6,count(M6plus_�������) as M6plus,count(*)as �ܼ�,count(*)-count(M6plus_�������) as ���� from payment_daily_yesterday group by ����;
quit;
proc sql;
create table payment_daily_yesterday_dept2 as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
payment_daily_yesterday_dept2_1;
QUIT;
data payment_daily_yesterday_dept;
set payment_daily_yesterday_dept1 payment_daily_yesterday_dept2;
run;

proc sql;
create table day_deptamount1_1 as select Ӫҵ�� as ά��,sum(�����������) as ���� ,sum(M1_�������) as M1,sum(M2_�������) as M2,
sum(M3_�������) as M3,sum(M4_�������) as M4,sum(M5_�������) as M5,sum(M6_�������) as M6,sum(M6plus_�������) as M6plus,sum(�������) as �ܼ�
from payment_daily_yesterday group by Ӫҵ�� ;
quit;
data day_deptamount1_2;
set day_deptamount1_1;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table day_deptamount1_3 as select *,sum(�ܼ�, - M6plus) as ���� FROM 
day_deptamount1_2;
quit;
proc sql;
create table day_deptamount1 as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
day_deptamount1_3;
proc sql;
create table day_deptamount2 as select ���� as ά��,sum(�����������) as ���� ,sum(M1_�������) as M1,sum(M2_�������) as M2,
sum(M3_�������) as M3,sum(M4_�������) as M4,sum(M5_�������) as M5,sum(M6_�������) as M6,sum(M6plus_�������) as M6plus,sum(�������) as �ܼ�
from payment_daily_yesterday group by ���� ;
quit;
data day_deptamount2;
set day_deptamount2;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table day_deptamount2 as select *,sum(�ܼ�, - M6plus) as ���� FROM 
day_deptamount2;
quit;
proc sql;
create table day_deptamount2 as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
day_deptamount2;
data day_deptamount;
set day_deptamount1 day_deptamount2;
run;


data branch1;
set branch end=last;
call symput ("dept_"||compress(_n_),compress(Ӫҵ��));
row=_n_+9;
call symput("row_"||compress(_n_),compress(row));
row1=_n_+58;
call symput("row1_"||compress(_n_),compress(row1));
if last then call symput("lpn",compress(_n_));
run;


%macro city_table();
%do i =1 %to &lpn.;

filename DD DDE "EXCEL|[�����ڱ���.xls]������!r&&row_&i..c4:r&&row_&i..c15";
data _null_;set payment_daily_yesterday_dept(where=( ά�� ="&&dept_&i..")) ;file DD;put ���� M1 M2 M3 M4 M5 M6  �ܼ� DPD DPD3 DPD9 M6plus;run;
filename DD DDE "EXCEL|[�����ڱ���.xls]������!r&&row1_&i..c4:r&&row1_&i..c15";
data _null_;set Day_deptamount(where=( ά�� ="&&dept_&i..")) ;file DD;put ���� M1 M2 M3 M4 M5 M6  �ܼ� DPD DPD3 DPD9 M6plus;run;

%end;
%mend;
%city_table();



/*����Ʒ*/
data account_info;
set account.account_info;
run;
data apply_info;
set approval.apply_info;
apply_code = tranwrd(apply_code,'PL','C');
rename apply_code = contract_no;
run;

proc sort data = apply_info; by contract_no;run;
proc sort data = payment_daily_yesterday; by contract_no;run;
proc sort data = account_info;by contract_no;run;

data payment_account1;
merge apply_info (in=a) account_info(in =b);
by CONTRACT_NO;
if b;
format product_name $40.;
if kindex(product_name,'E��ͨ-�Թ�') then product_name = "E��ͨ-�Թ�";
else if kindex(product_name,'E��ͨ') then product_name = "E��ͨ";
else if kindex(product_name,'E��ͨ') then product_name = "E��ͨ";
else if kindex(product_name,'E��ͨ') then product_name = "E��ͨ";
else if kindex(product_name,'E��ͨ') then product_name = "E��ͨ";
else if kindex(product_name,'E��ͨ') then product_name = "E��ͨ";
else if kindex(product_name,'E΢��') then product_name = "E΢��";
else if kindex(product_name,'U��ͨ') then product_name = "U��ͨ";
else if kindex(product_name,'Eլͨ') then product_name = "Eլͨ";
else if kindex(product_name,'Eլͨ-�Թ�') then product_name = "Eլͨ-�Թ�";
else if kindex(product_name,'Easy�����ÿ�') then product_name = "Easy�����ÿ�";
else if kindex(product_name,'Easy��֥���') then product_name = "Easy��֥���";
else if kindex(product_name,'E΢��-���籣') then product_name = "E΢��-���籣";
else if kindex(product_name,'E΢��-�Թ�') then product_name = "E΢��-�Թ�";
run;
data payment_product;
merge payment (in = a ) payment_account1(in=b);
by contract_no;
if a;
run;

data payment_account;
merge payment_daily_yesterday(in=a) payment_account1(in =b);
by CONTRACT_NO;
if a ;
format ��Ʒ���� $40.;
��Ʒ���� =PRODUCT_NAME;
run;

data payment_daily_yesterday;
set payment_daily_yesterday;
apply_code = tranwrd(contract_no,"C","PL");
run;
proc sort data = payment_daily_yesterday;by apply_code;run;
proc sort data = approval.apply_emp out = apply_emp;by apply_code ;run;

data retire;
merge  payment_daily_yesterday(in = a) apply_emp(in=b);
by apply_code;
if a ;
if kindex( title,"����") or POSITION ="297";
format ��Ʒ���� $40.;
��Ʒ����="���ݴ�";
run;

data payment_account;
set payment_account retire;
run;

proc sql;
create table product_payment as select ��Ʒ����, count(�����������) as ���� ,count(M1_�������) as M1,count(M2_�������) as M2,
count(M3_�������) as M3,count(M4_�������) as M4,count(M5_�������) as M5,count(M6_�������) as M6,count(M6plus_�������) as M6plus,count(*)as �ܼ�,count(*)-count(M6plus_�������) as ���� from payment_account group by ��Ʒ����;quit;
proc sql;
create table product_payment as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
product_payment;
QUIT;
proc sql;
create table product_payment_amount as select ��Ʒ����,sum(�����������) as ���� ,sum(M1_�������) as M1,sum(M2_�������) as M2,
sum(M3_�������) as M3,sum(M4_�������) as M4,sum(M5_�������) as M5,sum(M6_�������) as M6,sum(M6plus_�������) as M6plus,sum(�������) as �ܼ�
from payment_account group by ��Ʒ����;
quit;
data product_payment_amount;
set product_payment_amount;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table product_payment_amount as select *,sum(�ܼ�, - M6plus) as ���� FROM 
product_payment_amount;
quit;
proc sql;
create table product_payment_amount as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM 
product_payment_amount;
quit;

data branc1;
set branc end=last;
call symput ("dept_"||compress(_n_),compress(product_name));
row=_n_+10;
call symput("row_"||compress(_n_),compress(row));
row1=_n_+30;
call symput("row1_"||compress(_n_),compress(row1));
if last then call symput("lpn",compress(_n_));
run;

%macro product_table();
%do i =1 %to  &lpn.;

filename DD DDE "EXCEL|[�����ڱ���.xls]����Ʒ!r&&row_&i..c2:r&&row_&i..c13";
data _null_;set product_payment(where=( ��Ʒ����="&&dept_&i..")) ;file DD;put ���� M1 M2 M3 M4 M5 M6  �ܼ� DPD DPD3 DPD9 M6plus;run;
filename DD DDE "EXCEL|[�����ڱ���.xls]����Ʒ!r&&row1_&i..c2:r&&row1_&i..c13";
data _null_;set product_payment_amount(where=(��Ʒ����="&&dept_&i..")) ;file DD;put ���� M1 M2 M3 M4 M5 M6  �ܼ� DPD DPD3 DPD9 M6plus;run;

%end;
%mend;
%product_table();

/*���ݴ�*/
/*data payment_daily_yesterday;*/
/*set payment_daily_yesterday;*/
/*apply_code = tranwrd(contract_no,"C","PL");*/
/*run;*/
/*proc sort data = payment_daily_yesterday;by apply_code;run;*/
/*proc sort data = approval.apply_emp out = apply_emp;by apply_code ;run;*/
/**/
/*data retire;*/
/*set payment_daily_yesterday(in = a)apply_emp(in=b);*/
/*by apply_code;*/
/*if a ;*/
/*if position="������Ա";*/
/*format ��Ʒ���� $10.;*/
/*��Ʒ����="���ݴ�";*/
/*run;*/




filename DD DDE "EXCEL|[�����ڱ���.xls]Total!r82c2:r112c13";
data _null_;set every_day ;file DD;put  ���� M1 M2 M3 M4 M5 M6 M6plus �ܼ� DPD DPD3 DPD9 ;run;
filename DD DDE "EXCEL|[�����ڱ���.xls]Total!r182c2:r215c13";
data _null_;set every_day_amount ;file DD;put ���� M1 M2 M3 M4 M5 M6 M6plus �ܼ� DPD DPD3 DPD9 ;run;
/*ÿ�µ�һ����*/
filename DD DDE "EXCEL|[�����ڱ���.xls]Total!r9c2:r53c13";
data _null_;set every_month ;file DD;put ���� M1 M2 M3 M4 M5 M6 M6plus �ܼ� DPD DPD3 DPD9 ;run;
filename DD DDE "EXCEL|[�����ڱ���.xls]Total!r120c2:r164c13";
data _null_;set every_month_amount ;file DD;put ���� M1 M2 M3 M4 M5 M6 M6plus �ܼ� DPD DPD3 DPD9 ;run;


/**/
/*/*������ת�ձ�  od_days �������*/*/
/*data payment_daily_2;*/
/*set repayfin.payment_daily(where=(cut_date ^=&lmd.));*/
/*if pre_1m_status not in('09_ES','11_Settled');*/
/*format ����������� M1_������� M2_������� M3_������� M4_������� M5_������� M6_������� M6plus_�������;*/
/*if (od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ ^=1) or od_days=. then ����������� = �������;*/
/*else if  1<=od_days<=29 or (od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1)then M1_������� =�������;*/
/*else if 30<=od_days<=59 then M2_������� =�������;*/
/*else if 60<=od_days<=89 then M3_�������= �������;*/
/*else if 90<=od_days<=119 then M4_�������= �������;*/
/*else if 120<=od_days<=149 then M5_�������= �������;*/
/*else if 150<=od_days<=179 then M6_�������= �������;*/
/*else if 180<=od_days then M6plus_�������= �������;*/
/*run;*/
/*data daily_product1;*/
/*set payment_daily_2;*/
/*if cut_date = &dt.;*/
/*run;*/
/*data daily_product;*/
/*set daily_product1;*/
/*format ���� ���� $20.;*/
/*if Ӫҵ�� in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�������ֺ���·Ӫҵ��",*/
/*"��������·Ӫҵ��","���ݽ�����·Ӫҵ��","���ݵ�һӪҵ��","�����е�һӪҵ��",*/
/*"�����е�һӪҵ��","�����е�һӪҵ��","�Ͼ��е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��") then ����="����С��";*/
/*else if Ӫҵ�� in ("�ɶ��츮����Ӫҵ��","���ͺ����е�һӪҵ��","��³ľ���е�һӪҵ��",*/
/*"����е�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��") then ����="����С��";*/
/*else if Ӫҵ�� in ("����ҵ������","����ҵ������","��ɽҵ������","�γ���ҵ������",'��ͨ��ҵ������','�人��ҵ������*/
/*',"�����ҵ������","�Ͼ���ҵ������") then ����="����С��";*/
/*run;*/
/*data payment_account;*/
/*merge daily_product(in=a) payment_account1(in =b);*/
/*by CONTRACT_NO;*/
/*if a ;*/
/*format ��Ʒ���� $10.;*/
/*��Ʒ���� =PRODUCT_NAME;*/
/*run;*/
/**/
/**/
/**/
/*proc import datafile="F:\share\������ת����\Ӫҵ��_1.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*data branch1;*/
/*set branch end=last;*/
/*call symput ('dept_'||compress(_n_),compress(Ӫҵ��));*/
/**/
/**TOTAL_TAT & Disb_Successful_TAT;*/
/*TOTAL_TAT_b1=-1+_n_*12;*/
/*TOTAL_TAT_b2=9+_n_*12;*/
/*TOTAL_TAT_e1=7+_n_*12;*/
/*TOTAL_TAT_e2=12+_n_*12;*/
/*call symput ("totalb1_row_"||compress(_n_),compress(TOTAL_TAT_b1));*/
/*call symput ("totalb2_row_"||compress(_n_),compress(TOTAL_TAT_b2));*/
/*call symput("totale1_row_"||compress(_n_),compress(TOTAL_TAT_e1));*/
/*call symput("totale2_row_"||compress(_n_),compress(TOTAL_TAT_e2));*/
/**/
/*if last then call symput("lpn",compress(_n_));*/
/*run;*/
/*x  "F:\share\������ת����\��������ת����.xlsx"; */
/*%macro city_product();*/
/*%do i =1 %to &lpn.;*/
/**/
/*proc sql;*/
/*create table product_payment_city1 as select ��Ʒ����, count(�����������) as ���� ,count(M1_�������) as M1,count(M2_�������) as M2,*/
/*count(M3_�������) as M3,count(M4_�������) as M4,count(M5_�������) as M5,count(M6_�������) as M6,count(M6plus_�������) as M6plus,count(*)as �ܼ�,count(*)-count(M6plus_�������) as ���� from payment_account(where=(Ӫҵ��="&&dept_&i")) group by ��Ʒ����;quit;*/
/*proc sql;*/
/*create table product_payment_city1 as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM */
/*product_payment_city1;*/
/*QUIT;*/
/*proc sql;*/
/*create table city_amount as select ��Ʒ����,sum(�����������) as ���� ,sum(M1_�������) as M1,sum(M2_�������) as M2,*/
/*sum(M3_�������) as M3,sum(M4_�������) as M4,sum(M5_�������) as M5,sum(M6_�������) as M6,sum(M6plus_�������) as M6plus,sum(�������) as �ܼ�*/
/*from payment_account(where=(Ӫҵ��="&&dept_&i"))  group by ��Ʒ����;*/
/*quit;*/
/*data city_amount;*/
/*set city_amount;*/
/*array xx _numeric_;*/
/*do over xx;*/
/*if xx=. then xx=0;*/
/*end;*/
/*run;*/
/*proc sql;*/
/*create table city_amount as select *, sum(�ܼ�, - M6plus) as ���� FROM */
/*city_amount;*/
/*quit;*/
/**/
/*proc sql;*/
/*create table city_amount as select *,M1/���� as DPD,sum(M2,M3,M4,M5,M6)/���� as DPD3,sum(M4,M5,M6)/���� as DPD9 FROM */
/*city_amount;*/
/**/
/*quit;*/
/*filename DD DDE "EXCEL|[��������ת����.xlsx]������ϸ_����!r&&totalb1_row_&i..c2:r&&totalb2_row_&i..c14";
/*data _null_;set product_payment_city1 ;file DD;put ��Ʒ���� ���� M1 M2 M3 M4 M5 M6  �ܼ� DPD DPD3 DPD9 M6plus;run;*/
/*filename DD DDE "EXCEL|[��������ת����.xlsx]������ϸ_���!r&&totalb1_row_&i..c2:r&&totalb2_row_&i..c14";*/
/*data _null_;set city_amount;file DD;put ��Ʒ���� ���� M1 M2 M3 M4 M5 M6 �ܼ� DPD DPD3 DPD9 M6plus;run;
/*%end;*/
/*%mend;*/
/**/
/*%city_product;*/




/*data payment_product;*/
/*merge payment (in = a ) payment_account1(in=b);*/
/*by contract_no;*/
/*if a;*/
/*run;*/
/*/*���²�Ʒ������� ����*/*/
/*data kan ;*/
/*set payment_daily;*/
/*if cut_date = &dt.-1;*/
/*run;*/
/**/
/**/
/*proc sql;*/
/*create table test1 as select Ӫҵ�� , sum(�������) as �ܼ� , sum(M6plus_�������) as M6plus from kan group by Ӫҵ��;*/
/*quit;*/
/**/
/*data test1;*/
/*set test1;*/
/*array xx _numeric_;*/
/*do over xx;*/
/*if xx=. then xx=0;*/
/*end;*/
/*run;*/
/**/
/**/
/**/
/*/*���·���*/*/
/*data payment_befor;*/
/*set payment_daily;*/
/*if cut_date = &dt.-1;*/
/*run;*/
/*data kan2;*/
/*merge payment_befor(in=a) payment_account1(in =b);*/
/*by CONTRACT_NO;*/
/*if a ;*/
/*format ��Ʒ���� $10.;*/
/*��Ʒ���� =PRODUCT_NAME;*/
/*run;*/
/**/
/*proc sql;*/
/*create table test2 as select ��Ʒ���� ,  sum(M6plus_�������) as M6plus from kan2 group by ��Ʒ����;*/
/*quit;*/
/**/
/*data test2;*/
/*set test2;*/
/*array xx _numeric_;*/
/*do over xx;*/
/*if xx=. then xx=0;*/
/*end;*/
/*/*run;*/*/


filename DD DDE "EXCEL|[�����ڱ���.xls]������!r38c22:r57c24";*/
data _null_;
/*set test1 ;file DD;put Ӫҵ�� �ܼ� M6plus;run;*/
/*filename DD DDE "EXCEL|[�����ڱ���.xls]����Ʒ!r28c22:r38c23";*/
/*data _null_;set test2;file DD;put ��Ʒ���� M6plus;  run;*/
