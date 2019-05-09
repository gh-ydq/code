/*option validvarname=any;option compress=yes;*/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname zq "E:\guan\�м��\zq";*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname midapp "E:\guan\�м��\midapp";*/
/*libname approval 'E:\guan\ԭ����\approval';*/
/**/
/*x  "E:\guan\�ռ����ʱ����\Ӫҵ���ռ�ر���.xlsx"; */
/**/
/*proc import datafile="E:\guan\�ռ����ʱ����\Ӫҵ��DDE.xls"*/
/*out=dept dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/**/
/*proc import datafile="E:\guan\�ռ����ʱ����\���ñ�.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

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
data acc;
format dt pde date month_begin month_end yymmdd10.;
if year(today()) = 2004 then dt = intnx("year", today() - 1, 13, "same"); else dt = today() - 1;
pde=intnx("month",dt,-1,"e");
call symput("pde",pde);
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(12,31,2017);*/
last_month_end=intnx("month",date,0,"b")-1;
call symput("last_month_end",last_month_end);
last_month_begin=intnx("month",date,-1,"b");
call symput("last_month_begin",last_month_begin);
run;
data _null_;
format dt nt lmd yymmdd10.;
dt = today() - 1;
call symput("dt", dt);
db=intnx("month",dt,0,"b");
call symput("db",db);
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
data payment_daily;
set repayFin.payment_daily;
if contract_no='C2018101613583597025048' then delete;*�����������ľ�᲻�ô���,�޳���ĸ����;
if contract_no='C2017121414464569454887' then delete;*���ί��ͻ����ô���,�޳���ĸ����;
if contract_no='C2017111716235470079023' and month='201904' then delete;*������4�·�����̫�٣�4�·ݲ������ĸ����,�޳���ĸ����;
run;
*�ۼ�������ϸ;
data new_overdue;
set payment_daily;
if Ӫҵ��^="APP";
if Ӫҵ��^="";*ȥ������;
if od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1  and REPAY_DATE=cut_date;
if &dt.>=cut_date>=&db.;
rename cut_date=��������;
keep cut_date CONTRACT_NO Ӫҵ�� �ͻ����� ���֤����;
run;
proc sort data=new_overdue;by ��������;run;

*�ۼƻ�����ϸ;
data eight_overdue;
set payment_daily;
if Ӫҵ��^="APP";
if Ӫҵ��^="";*ȥ������;
last_oddays=lag(od_days);
if ����_��������15�Ӻ�ͬ=1;
if &dt.>=cut_date>=&db.;
rename cut_date=��������;
keep cut_date CONTRACT_NO Ӫҵ�� �ͻ����� ���֤���� ����_��������15�Ӻ�ͬ last_oddays;
run;
proc sort data=eight_overdue;by ��������;run;

*������;
data month1day;
set payment_daily(keep=contract_no  od_days cut_date ������� ����_���տۿ�ʧ�ܺ�ͬ REPAY_DATE Ӫҵ��);
run;
proc sort data=month1day ;by CONTRACT_no  cut_date descending Ӫҵ��;run;
data  clear_17detail;
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
keep contract_no Ӫҵ�� repay_date ������ ;
run;

*��ĩ��������;
data monday;
set payment_daily;
if Ӫҵ��^="APP";
if Ӫҵ��^="";*ȥ������;
if ����_��������15�Ӻ�ͬ=1;
if cut_date>=&dt.-2;
rename cut_date=��������;
keep cut_date CONTRACT_NO Ӫҵ�� �ͻ����� ���֤���� ����_��������15�Ӻ�ͬ;
run;
proc sort data=monday;by ��������;run;

*���տۿ����͵��տۿ�ʧ����,�õ�����M1�Ļ�����;
data test1_7 ;
set payment_daily;
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
*--------------------------------------------------------------5�ռ��������----------------------------------------------------------------------------------------*;
*�õ����������ˡ�����ͨ���ʡ��ſ������ſ�������;
*tabledateҲ������;
*dt������;
/*%let tabledate=mdy(4,26,2018);*/
/*%let dt=mdy(12,31,2017);*/
data zd_pr;
set midapp.Partone_cumulate_end(where=(date=&tabledate.));
format ������ ����  $15.;
if  branch_name = "�Ϻ��ڶ�Ӫҵ��" then branch_name = "�Ϻ�����·Ӫҵ��";
if branch_name in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�γ��е�һӪҵ��") then ������ = "�Ϻ�������";
	else if branch_name in ("���ݽ�����·Ӫҵ��","�����е�һӪҵ��","�����е�һӪҵ��") then ������ = "����������";
	else if branch_name in ("�������ֺ���·Ӫҵ��","���ݵ�һӪҵ��","�����е�һӪҵ��","��ͷ�е�һӪҵ��","�����е�һӪҵ��") then ������ = "���ݷ�����";
	else if branch_name in ("���ͺ����е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��") then ������ = "����������";
	else if branch_name in ("�ɶ��츮����Ӫҵ��","�人�е�һӪҵ��","�����е�һӪҵ��") then ������ = "�ɶ�������";
	else if branch_name in ("��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��","�����е�һӪҵ��" ) then ������ = "��³ľ�������";
	else if branch_name in ("��������·Ӫҵ��","�����е�һӪҵ��","��ɽ�е�һӪҵ��","տ���е�һӪҵ��","�����е�һӪҵ��") then ������ = "�ѹ��ŵ�1";
	else if branch_name in ("�����е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��","����е�һӪҵ��","������ҵ������",'��ͨ��ҵ������',
	"�Ͼ��е�һӪҵ��","�����е�һӪҵ��","�Ͼ���ҵ������","�����е�һӪҵ��") then ������ = "�ѹ��ŵ�2";

if BRANCH_NAME in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�γ��е�һӪҵ��","���ݽ�����·Ӫҵ��",
	"�����е�һӪҵ��","�����е�һӪҵ��" ,"�������ֺ���·Ӫҵ��","���ݵ�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��","��ͷ�е�һӪҵ��") then ����="����";
	else if BRANCH_NAME in ("���ͺ����е�һӪҵ��","�����е�һӪҵ��","�ɶ��츮����Ӫҵ��",
	"�人�е�һӪҵ��","�����е�һӪҵ��","��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��") then ����="����";
	else if BRANCH_NAME in ("�����е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��","����е�һӪҵ��","������ҵ������",'��ͨ��ҵ������',
	"�Ͼ��е�һӪҵ��","�����е�һӪҵ��","�Ͼ���ҵ������","��������·Ӫҵ��","�����е�һӪҵ��","��ɽ�е�һӪҵ��","տ���е�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��") then ����="�ѹ��ŵ����";

rename BRANCH_NAME=ά��;
drop date;
run;
proc sql;
create table zd_qy as
select ���� as ά��,sum(�ۼƽ�����) as �ۼƽ�����,
sum(�ۼƻ�����) as �ۼƻ�����,
sum(�ۼ�ͨ����) as �ۼ�ͨ����,
sum(�ۼƷſ���) as �ۼƷſ���,
sum(�ۼƷſ��ͬ���) as �ۼƷſ��ͬ��� from  zd_pr(where=(����^="")) group by ���� ;
quit;
proc sql;
create table zd_fzx as
select ������ as ά��,sum(�ۼƽ�����) as �ۼƽ�����,
sum(�ۼƻ�����) as �ۼƻ�����,
sum(�ۼ�ͨ����) as �ۼ�ͨ����,
sum(�ۼƷſ���) as �ۼƷſ���,
sum(�ۼƷſ��ͬ���) as �ۼƷſ��ͬ��� from  zd_pr(where=(������^="")) group by ������ ;
quit;
data zd;
set zd_pr(drop=���� ������) zd_qy zd_fzx;
run;

data zd_hk_pr;
set payment_daily;
format ������ ���� ���� $20.;
if  Ӫҵ�� = "�Ϻ��ڶ�Ӫҵ��" then Ӫҵ�� = "�Ϻ�����·Ӫҵ��";
if Ӫҵ�� in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�γ��е�һӪҵ��") then ������ = "�Ϻ�������";
	else if Ӫҵ�� in ("���ݽ�����·Ӫҵ��","�����е�һӪҵ��","�����е�һӪҵ��") then ������ = "����������";
	else if Ӫҵ�� in ("�������ֺ���·Ӫҵ��","���ݵ�һӪҵ��","�����е�һӪҵ��","��ͷ�е�һӪҵ��","�����е�һӪҵ��") then ������ = "���ݷ�����";
	else if Ӫҵ�� in ("���ͺ����е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��") then ������ = "����������";
	else if Ӫҵ�� in ("�ɶ��츮����Ӫҵ��","�人�е�һӪҵ��","�����е�һӪҵ��") then ������ = "�ɶ�������";
	else if Ӫҵ�� in ("��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��","�����е�һӪҵ��" ) then ������ = "��³ľ�������";
	else if Ӫҵ�� in ("��������·Ӫҵ��","�����е�һӪҵ��","��ɽ�е�һӪҵ��","տ���е�һӪҵ��","�����е�һӪҵ��") then ������ = "�ѹ��ŵ�1";
	else if Ӫҵ�� in ("�����е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��","����е�һӪҵ��","������ҵ������",'��ͨ��ҵ������',
	"�Ͼ��е�һӪҵ��","�����е�һӪҵ��","�Ͼ���ҵ������","�����е�һӪҵ��") then ������ = "�ѹ��ŵ�2";

if Ӫҵ�� in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�γ��е�һӪҵ��","���ݽ�����·Ӫҵ��",
	"�����е�һӪҵ��","�����е�һӪҵ��" ,"�������ֺ���·Ӫҵ��","���ݵ�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��","��ͷ�е�һӪҵ��") then ����="����";
	else if Ӫҵ�� in ("���ͺ����е�һӪҵ��","�����е�һӪҵ��","�ɶ��츮����Ӫҵ��",
	"�人�е�һӪҵ��","�����е�һӪҵ��","��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��") then ����="����";
	else if Ӫҵ�� in ("�����е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��","����е�һӪҵ��","������ҵ������",'��ͨ��ҵ������',
	"�Ͼ��е�һӪҵ��","�����е�һӪҵ��","�Ͼ���ҵ������","��������·Ӫҵ��","�����е�һӪҵ��","��ɽ�е�һӪҵ��","տ���е�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��") then ����="�ѹ��ŵ����";

if ���� in ("����","����","�ѹ��ŵ����") then ����="ȫ��";
run;
proc sql;
create table zd_hk_yyb as
select Ӫҵ�� as ά��,
sum(����_����Ӧ�ۿ��ͬ) as ����_����Ӧ�ۿ��ͬ,
sum(����_���տۿ�ʧ�ܺ�ͬ) as ����_���տۿ�ʧ�ܺ�ͬ,
sum(�������_1��ǰ_C) as �������_1��ǰ_C ,
sum(����_M1��ͬ�������)/sum(�������_1��ǰ_C) as c_m1 format=percent8.2,
sum(����_��δ��������M1��ͬ�������)/sum(�������_1��ǰ_C) as ����c_m1 format=percent7.2,
sum(�������_1��ǰ_M1) as �������_1��ǰ_M1,
sum(����_M1M2�������) as ����_M1M2�������,
sum(����_M2��ͬ�������)/sum(�������_2��ǰ_C) as c_m2 format=percent7.2,
sum(�������_1��ǰ_M2_r) as �������_1��ǰ_M2,
sum(����_M2M3�������) as ����_M2M3�������
from zd_hk_pr(where=(cut_date=&dt.))
group by Ӫҵ��;quit;
proc sql;
create table zd_hk_fzx as
select ������ as ά��,
sum(����_����Ӧ�ۿ��ͬ) as ����_����Ӧ�ۿ��ͬ,
sum(����_���տۿ�ʧ�ܺ�ͬ) as ����_���տۿ�ʧ�ܺ�ͬ,
sum(����_M1��ͬ�������)/sum(�������_1��ǰ_C) as c_m1 format=percent8.2,
sum(����_��δ��������M1��ͬ�������)/sum(�������_1��ǰ_C) as ����c_m1 format=percent7.2,
sum(�������_1��ǰ_M1) as �������_1��ǰ_M1,
sum(����_M1M2�������) as ����_M1M2�������,
sum(����_M2��ͬ�������)/sum(�������_2��ǰ_C) as c_m2 format=percent7.2,
sum(�������_1��ǰ_M2_r) as �������_1��ǰ_M2,
sum(����_M2M3�������) as ����_M2M3�������
from zd_hk_pr(where=(cut_date=&dt.))
group by ������;quit;
proc sql;
create table zd_hk_qy as
select ���� as ά��,
sum(����_����Ӧ�ۿ��ͬ) as ����_����Ӧ�ۿ��ͬ,
sum(����_���տۿ�ʧ�ܺ�ͬ) as ����_���տۿ�ʧ�ܺ�ͬ,
sum(����_M1��ͬ�������)/sum(�������_1��ǰ_C) as c_m1 format=percent8.2,
sum(����_��δ��������M1��ͬ�������)/sum(�������_1��ǰ_C) as ����c_m1 format=percent7.2,
sum(�������_1��ǰ_M1) as �������_1��ǰ_M1,
sum(����_M1M2�������) as ����_M1M2�������,
sum(����_M2��ͬ�������)/sum(�������_2��ǰ_C) as c_m2 format=percent7.2,
sum(�������_1��ǰ_M2_r) as �������_1��ǰ_M2,
sum(����_M2M3�������) as ����_M2M3�������
from zd_hk_pr(where=(cut_date=&dt.))
group by ����;quit;
proc sql;
create table zd_hk_qg as
select ���� as ά��,
sum(����_����Ӧ�ۿ��ͬ) as ����_����Ӧ�ۿ��ͬ,
sum(����_���տۿ�ʧ�ܺ�ͬ) as ����_���տۿ�ʧ�ܺ�ͬ,
sum(����_M1��ͬ�������)/sum(�������_1��ǰ_C) as c_m1 format=percent8.2,
sum(����_��δ��������M1��ͬ�������)/sum(�������_1��ǰ_C) as ����c_m1 format=percent7.2,
sum(�������_1��ǰ_M1) as �������_1��ǰ_M1,
sum(����_M1M2�������) as ����_M1M2�������,
sum(����_M2��ͬ�������)/sum(�������_2��ǰ_C) as c_m2 format=percent7.2,
sum(�������_1��ǰ_M2_r) as �������_1��ǰ_M2,
sum(����_M2M3�������) as ����_M2M3�������
from zd_hk_pr(where=(cut_date=&dt.))
group by ����;quit;
data zd_hk1;
set zd_hk_yyb zd_hk_qy zd_hk_qg zd_hk_fzx;
run;
proc sql;
create table zd_lsl_yyb as
select Ӫҵ�� as ά��,
sum(����_��������15�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ,
sum(����_��������15�Ӻ�ͬ) as ��ʧ��ͬ����
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by Ӫҵ��;quit;
proc sql;
create table zd_lsl_qy as
select ���� as ά��,
sum(����_��������15�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ,
sum(����_��������15�Ӻ�ͬ) as ��ʧ��ͬ����
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by ����;quit;
proc sql;
create table zd_lsl_fzx as
select ������ as ά��,
sum(����_��������15�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ,
sum(����_��������15�Ӻ�ͬ) as ��ʧ��ͬ����
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by ������;quit;
proc sql;
create table zd_lsl_qg as
select ���� as ά��,
sum(����_��������15�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ,
sum(����_��������15�Ӻ�ͬ) as ��ʧ��ͬ����
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by ����;quit;
data zd_hk2;
set zd_lsl_yyb zd_lsl_qy zd_lsl_qg zd_lsl_fzx;
run;
proc sql;
create table zd_lsl7_yyb as
select Ӫҵ�� as ά��,
sum(����_��������7�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ_,
sum(����_��������7�Ӻ�ͬ) as ��ʧ��ͬ����_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by Ӫҵ��;quit;
proc sql;
create table zd_lsl7_qy as
select ���� as ά��,
sum(����_��������7�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ_,
sum(����_��������7�Ӻ�ͬ) as ��ʧ��ͬ����_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by ����;quit;
proc sql;
create table zd_lsl7_fzx as
select ������ as ά��,
sum(����_��������7�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ_,
sum(����_��������7�Ӻ�ͬ) as ��ʧ��ͬ����_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by ������;quit;
proc sql;
create table zd_lsl7_qg as
select ���� as ά��,
sum(����_��������7�Ӻ�ͬ��ĸ) as ��ʧ��ͬ��ĸ_,
sum(����_��������7�Ӻ�ͬ) as ��ʧ��ͬ����_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by ����;quit;
data zd_hk3;
set zd_lsl7_yyb zd_lsl7_qy zd_lsl7_qg zd_lsl7_fzx;
run;
proc sql;
create table zd_hk as
select a.*,b.��ʧ��ͬ��ĸ_,b.��ʧ��ͬ����_,c.��ʧ��ͬ��ĸ,c.��ʧ��ͬ����,d.�ۼƽ�����,d.�ۼƻ�����,d.ά�� as ά��c,
d.�ۼ�ͨ����,d.�ۼƷſ���,d.�ۼƷſ��ͬ��� from zd_hk1 as a
left join zd_hk3 as b on a.ά��=b.ά��
left join zd_hk2 as c on a.ά��=c.ά��
full join zd as d on a.ά��=d.ά��;
quit;
data zd_hk;
set zd_hk;
if ά��C^="" and ά��="" then ά��=ά��C;
array nums _numeric_;
do over nums;
if nums=. then nums=0;
end;
run;

data branch1;
set branch end=last;
call symput ("dept_"||compress(_n_),compress(Ӫҵ��));
row=_n_+7;
call symput("row_"||compress(_n_),compress(row));
if last then call symput("lpn",compress(_n_));
run;
%macro city_table();
%do i =1 %to &lpn.;

filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c6:r&&row_&i..c7";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put �ۼƽ����� �ۼƻ�����;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c12:r&&row_&i..c13";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put �ۼ�ͨ���� �ۼƷſ���;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c15:r&&row_&i..c15";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put �ۼƷſ��ͬ���;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c18:r&&row_&i..c19";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put ����_����Ӧ�ۿ��ͬ ����_���տۿ�ʧ�ܺ�ͬ;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c21:r&&row_&i..c22";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put ��ʧ��ͬ��ĸ_ ��ʧ��ͬ����_;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c24:r&&row_&i..c25";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put ��ʧ��ͬ��ĸ ��ʧ��ͬ����;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c30:r&&row_&i..c31";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put C_M1 ����c_m1;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c33:r&&row_&i..c34";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put �������_1��ǰ_M1 ����_M1M2������� ;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c39:r&&row_&i..c39";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put C_M2 ;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r&&row_&i..c42:r&&row_&i..c43";
data _null_;set zd_hk(where=(ά��="&&dept_&i"));file DD;put �������_1��ǰ_M2 ����_M2M3������� ;run;
%end;
%mend;
%city_table();
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r58c30:r58c31";
data _null_;set zd_hk(where=(ά��="ȫ��"));file DD;put C_M1 ����c_m1;run;
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r58c39:r58c39";
data _null_;set zd_hk(where=(ά��="ȫ��"));file DD;put C_M2 ;run;

data _null_;
format dt yymmdd10.;
if year(today()) = 2004 then dt = intnx("year", today() - 1, 13, "same"); else dt = today() - 1;
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
week = weekday(dt);
call symput('week',week);
run;
data check_result;
set midapp.check_result;
run;
data apply_dept;
set approval.apply_info(keep= apply_code BRANCH_NAME branch_code DESIRED_PRODUCT NAME SOURCE_CHANNEL);
	 if branch_code = "6" then branch_name = "�Ϻ�����·Ӫҵ��";
else if branch_code = "13" then branch_name = "�Ϻ�����·Ӫҵ��";
else if branch_code = "16" then branch_name = "�������ֺ���·Ӫҵ��";
else if branch_code = "14" then branch_name = "�Ϸ�վǰ·Ӫҵ��";
else if branch_code = "15" then branch_name = "��������·Ӫҵ��";
else if branch_code = "17" then branch_name = "�ɶ��츮����Ӫҵ��";
else if branch_code = "50" then branch_name = "���ݵ�һӪҵ��";
else if branch_code = "55" then branch_name = "�����е�һӪҵ��";
else if branch_code = "57" then branch_name = "���ݽ�����·Ӫҵ��";
else if branch_code = "56" then branch_name = "�����е�һӪҵ��";
else if branch_code = "118" then branch_name = "�����е�һӪҵ��";
else if branch_code = "65" then branch_name = "��³ľ���е�һӪҵ��";
else if branch_code = "63" then branch_name = "����е�һӪҵ��";
else if branch_code = "60" then branch_name = "���ͺ����е�һӪҵ��";
else if branch_code = "93" then branch_name = "Ȫ���е�һӪҵ��";
else if branch_code = "122" then branch_name = "֣���е�һӪҵ��";
else if branch_code = "91" then branch_name = "����е�һӪҵ��";
else if branch_code = "90" then branch_name = "�����е�һӪҵ��";
else if branch_code = "71" then branch_name = "�����е�һӪҵ��";
else if branch_code = "72" then branch_name = "�����е�һӪҵ��";
else if branch_code = "73" then branch_name = "�����е�һӪҵ��";
else if branch_code = "74" then branch_name = "�Ͼ��е�һӪҵ��";
else if branch_code = "75" then branch_name = "�����е�һӪҵ��";
else if branch_code = "89" then branch_name = "�����е�һӪҵ��";
else if branch_code = "50" then branch_name = "�����е�һӪҵ��";
else if branch_code = "117" then branch_name = "�γ���ҵ������";
else if branch_code = "116" then branch_name = "��ͨ��ҵ������";
else if branch_code = "114" then branch_name = "��ɽҵ������";
else if branch_code = "115" then branch_name = "������ҵ������";
else if branch_code = "119" then branch_name = "�人��ҵ������";
else if branch_code = "120" then branch_name = "�����ҵ������";
else if branch_code = "136" then branch_name = "��ɽ�е�һӪҵ��";

if kindex(branch_name,"����")  then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"����") and kindex(branch_name,"ҵ������") then branch_name="������ҵ������";
else if kindex(branch_name,"��ɽ") then branch_name="��ɽ�е�һӪҵ��";
else if kindex(branch_name,"�γ�") then branch_name="�γ��е�һӪҵ��";
else if kindex(branch_name,"տ��") then branch_name="տ���е�һӪҵ��";
else if kindex(branch_name,"�人") then branch_name="�人�е�һӪҵ��";
else if kindex(branch_name,"���") then branch_name="����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"�����") then branch_name="������е�һӪҵ��";
else if kindex(branch_name,"��ͷ") then branch_name="��ͷ�е�һӪҵ��";
else if kindex(branch_name,"���") then branch_name="����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";

prime_key=1;

run;
*-----------------------------------------------------------------ÿ��һ�Ĺ�������ͨ����-------------------------------------------------------------------------------------*;

%macro gjs_monday_1;
%if &week.=1  %then %do;

data daata;
set  check_result(where=(����״̬ in ("ACCEPT","REFUSE"))keep=apply_code �ܾ� ͨ�� check_date ����״̬);
if &dt.-6<=check_date<=&dt.;
run;
proc sql;
create table daata1(where=(not kindex(DESIRED_PRODUCT,"RF"))) as
select a.*,b.branch_name,b.DESIRED_PRODUCT from daata as a
left join apply_dept as b on a.apply_code=b.apply_code;
quit;
proc sql;
create table  daata2 as
select branch_name,count(*) as ������,sum(ͨ��) as ͨ����,calculated ͨ����/calculated ������ as ͨ���� format=percent7.2 from daata1 
group by branch_name ;
quit;

proc sql;
create table daata3 as select a.*,b.* from daata2 as a right join branch as b on a.branch_name = b.Ӫҵ�� ;quit;
/*proc sort data = daata3 (drop = branch_name);by id ; run;*/




/*%macro gjs_monday_jx;*/
/*%if   &dt.-6<=&end_date.<=&dt. %then %do;*/
/**/
/*data daata;*/
/*set  check_result(where=(����״̬ in ("ACCEPT","REFUSE"))keep=apply_code �ܾ� ͨ�� check_date ����״̬);*/
/*/*��Ч������������Ч�µ�*/*/
/*if &fk_month_begin.<=check_date<=&end_date.;*/
/*run;*/
/*proc sql;*/
/*create table daata1(where=(not kindex(DESIRED_PRODUCT,"RF"))) as*/
/*select a.*,b.branch_name,b.DESIRED_PRODUCT from daata as a*/
/*left join apply_dept as b on a.apply_code=b.apply_code;*/
/*quit;*/
/*proc sql;*/
/*create table  daata2 as*/
/*select branch_name,count(*) as ������,sum(ͨ��) as ͨ����,calculated ͨ����/calculated ������ as ͨ���� format=percent7.2 from daata1 */
/*group by branch_name ;*/
/*quit;*/
/**/
/*proc sql;*/
/*/*/*create table daata3 as select a.*,b.* from daata2 as a right join branch as b on a.branch_name = b.Ӫҵ�� ;
/*quit;*/*/*/*/
/*proc sort data = daata3 (drop = branch_name);
/*by id ; run;*/*/
/**/
/*%end;*/
/*%mend;*/
/*%gjs_monday_jx;*/;

data daata;
set  check_result(where=(����״̬ in ("ACCEPT","REFUSE"))keep=apply_code �ܾ� ͨ�� check_date ����״̬);
if &dt.-6<=check_date<=&dt.;
run;
proc sql;
create table daata1(where=(not kindex(DESIRED_PRODUCT,"RF"))) as
select a.*,b.branch_name,b.DESIRED_PRODUCT from daata as a
left join apply_dept as b on a.apply_code=b.apply_code;
quit;
proc sql;
create table  daata2 as
select branch_name,count(*) as ������,sum(ͨ��) as ͨ����,calculated ͨ����/calculated ������ as ͨ���� format=percent7.2 from daata1 
group by branch_name ;
quit;

proc sql;
create table daata3 as select a.*,b.* from daata2 as a right join branch as b on a.branch_name = b.Ӫҵ�� ;quit;
/*proc sort data = daata3 (drop = branch_name);by id ; run;*/


/*x  "F:\A_offline_zky\A_offline\daily\�ռ��\Ӫҵ���ռ�ر���.xlsx"; */
filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet1!r64c21:r110c24";
data _null_;set daata2;file DD;put BRANCH_NAME  ������ ͨ���� ͨ���� ;run;

%end;
%mend;
%gjs_monday_1;
