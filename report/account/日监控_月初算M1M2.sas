/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/**/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname yc "E:\guan\�м��\yc";*/
/**/
/*proc import datafile="E:\guan\�ռ����ʱ����\���ñ�.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

proc sort data=repayfin.payment_daily;by CONTRACT_no cut_date;run;
data cs;
set repayfin.payment_daily;
if contract_no='C2018101613583597025048' then delete;*�����������ľ�᲻�ô���,�޳���ĸ����;
if contract_no='C2017121414464569454887' then delete;*���ί��ͻ����ô���,�޳���ĸ����;
if contract_no='C2017111716235470079023' and month='201904' then delete;*������4�·�����̫�٣�4�·ݲ������ĸ����,�޳���ĸ����;
if ����_���տۿ�ʧ�ܺ�ͬ = 1;
last_oddays=lag(od_days);
last_����_���տۿ�ʧ�ܺ�ͬ=lag(����_���տۿ�ʧ�ܺ�ͬ);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_�������=�������;last_����_���տۿ�ʧ�ܺ�ͬ=����_���տۿ�ʧ�ܺ�ͬ;end;
run;

/*%let pde=mdy(12,31,2017);*/
DATA A;
FORMAT A YYMMDD10.;
A=&pde.;
cut_date =intnx("month",today(),-1,"end");
RUN;
data cs_1;
set yc.payment;
if cut_date =intnx("month",today(),-1,"end");
if branch_code ^="105";
if branch_code = "13" then Ӫҵ�� = "�Ϻ�����·Ӫҵ��";
format Ӫҵ��_ $40.;
if kindex(Ӫҵ��,"����")  then Ӫҵ��_="�����е�һӪҵ��";
else if kindex(Ӫҵ��,"����")  then Ӫҵ��_="������ҵ������";
else if kindex(Ӫҵ��,"��ɽ") then Ӫҵ��_="��ɽ�е�һӪҵ��";
else if kindex(Ӫҵ��,"�γ�") then Ӫҵ��_="�γ��е�һӪҵ��";
else if kindex(Ӫҵ��,"տ��") then Ӫҵ��_="տ���е�һӪҵ��";
else if kindex(Ӫҵ��,"�人") then Ӫҵ��_="�人�е�һӪҵ��";
else if kindex(Ӫҵ��,"���") then Ӫҵ��_="����е�һӪҵ��";
else if kindex(Ӫҵ��,"����") then Ӫҵ��_="�����е�һӪҵ��";
else if kindex(Ӫҵ��,"����") then Ӫҵ��_="�����е�һӪҵ��";
else if kindex(Ӫҵ��,"�����") then Ӫҵ��_="������е�һӪҵ��";
else Ӫҵ��_=Ӫҵ��;

format ������ ���� ���� $20.;
if  Ӫҵ�� = "�Ϻ��ڶ�Ӫҵ��" then Ӫҵ�� = "�Ϻ�����·Ӫҵ��";
if Ӫҵ�� in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�γ��е�һӪҵ��") then ������ = "�Ϻ�������";
	else if Ӫҵ�� in ("���ݽ�����·Ӫҵ��","�����е�һӪҵ��","�����е�һӪҵ��") then ������ = "����������";
	else if Ӫҵ�� in ("�������ֺ���·Ӫҵ��","���ݵ�һӪҵ��","�����е�һӪҵ��","��ͷ�е�һӪҵ��","�����е�һӪҵ��") then ������ = "���ݷ�����";
	else if Ӫҵ�� in ("���ͺ����е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��") then ������ = "����������";
	else if Ӫҵ�� in ("�ɶ��츮����Ӫҵ��","�����е�һӪҵ��","�人�е�һӪҵ��","�����е�һӪҵ��") then ������ = "�ɶ�������";
	else if Ӫҵ�� in ("��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��","�����е�һӪҵ��" ) then ������ = "��³ľ�������";
	else if Ӫҵ�� in ("��������·Ӫҵ��","�����е�һӪҵ��","��ɽ�е�һӪҵ��","տ���е�һӪҵ��","�����е�һӪҵ��") then ������ = "�ѹ��ŵ�1";
	else if Ӫҵ�� in ("�����е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��","����е�һӪҵ��","������ҵ������",'��ͨ��ҵ������',
	"�Ͼ��е�һӪҵ��","�����е�һӪҵ��","�Ͼ���ҵ������") then ������ = "�ѹ��ŵ�2";

if Ӫҵ�� in ("�Ϻ�����·Ӫҵ��","�Ϸ�վǰ·Ӫҵ��","�γ��е�һӪҵ��","���ݽ�����·Ӫҵ��",
	"�����е�һӪҵ��","�����е�һӪҵ��" ,"�������ֺ���·Ӫҵ��","���ݵ�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��","��ͷ�е�һӪҵ��") then ����="����";
	else if Ӫҵ�� in ("���ͺ����е�һӪҵ��","�����е�һӪҵ��","�ɶ��츮����Ӫҵ��","�����е�һӪҵ��",
	"�人�е�һӪҵ��","�����е�һӪҵ��","��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��") then ����="����";
	else if Ӫҵ�� in ("�����е�һӪҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","����е�һӪҵ��","����е�һӪҵ��","������ҵ������",'��ͨ��ҵ������',
	"�Ͼ��е�һӪҵ��","�����е�һӪҵ��","�Ͼ���ҵ������","��������·Ӫҵ��","�����е�һӪҵ��","��ɽ�е�һӪҵ��","տ���е�һӪҵ��","�����е�һӪҵ��") then ����="�ѹ��ŵ����";

if ���� in ("����","����","�ѹ��ŵ����") then ����="ȫ��";
drop Ӫҵ��;
rename Ӫҵ��_=Ӫҵ��;
run;


proc sql ;
create table cm_1 as select Ӫҵ�� as γ��,sum(�������_M1)/sum(�������_1��ǰ_C) as cm1,sum(�������_M1) as �������_M1,sum(�������_1��ǰ_C) as �������_1��ǰ_C from cs_1 group by Ӫҵ��;
quit;
proc sql ;
create table cm_2 as select ���� as γ��,sum(�������_M1)/sum(�������_1��ǰ_C) as cm1,sum(�������_M1) as �������_M1,sum(�������_1��ǰ_C) as �������_1��ǰ_C from cs_1 group by ����;
quit;
proc sql ;
create table cm_3 as select ���� as γ��,sum(�������_M1)/sum(�������_1��ǰ_C)as cm1,sum(�������_M1) as �������_M1,sum(�������_1��ǰ_C) as �������_1��ǰ_C  from cs_1 group by ����;
quit;
proc sql ;
create table cm_4 as select ������ as γ��,sum(�������_M1)/sum(�������_1��ǰ_C)as cm1,sum(�������_M1) as �������_M1,sum(�������_1��ǰ_C) as �������_1��ǰ_C  from cs_1 group by ������;
quit;



data cm_;
set cm_1 cm_2 cm_3 cm_4;
drop �������_M1;
run ;
/*Ϊ���޸����μ���M1����������Դ������_M1 ��payment��Ϊ׼��payment�������µ׵Ĵ������_M1��payment_daily���������µ׵Ĵ������_M1*/
/*����Ĵ���֮����ѡ�Ĵ������_1��ǰ_M1������ѡ����payment_daily��cut_date�����죬cut_dat������Ĵ������_1��ǰ_M1����cut_date�����µ׵������µ׵Ĵ������_M1����������ȷ��*/
proc sql;
create table cm__ as
select a.*,b.�������_1��ǰ_M1 as �������_M1
from cm_ as a
left join zd_hk1 as b
on a.γ��=b.ά��;
quit;

proc sql;
create table cm as
select 
γ��,cm1,�������_M1,�������_1��ǰ_C,
sum(�������_M1)/sum(�������_1��ǰ_C)as cm1_������
from cm__
group by γ��;
quit;

proc sql;
create table cmt_1 as select a.* , b.cm1,b.cm1_������,b.�������_M1 from branch as a left join cm as b on a.Ӫҵ�� = b.γ��;quit;

proc sort data = cmt_1;
by id;run;



proc sql ;
create table cm2_1 as select Ӫҵ�� as γ��,sum(�������_M2)/sum(�������_2��ǰ_C) as cm2 ,sum(�������_M2) as �������_M2 from cs_1 group by Ӫҵ��;
quit;
proc sql ;
create table cm2_2 as select ���� as γ��,sum(�������_M2)/sum(�������_2��ǰ_C) as cm2,sum(�������_M2) as �������_M2 from cs_1 group by ����;
quit;
proc sql ;
create table cm2_3 as select ���� as γ��,sum(�������_M2)/sum(�������_2��ǰ_C) as cm2 ,sum(�������_M2) as �������_M2  from cs_1 group by ����;
quit;
proc sql ;
create table cm2_4 as select ������ as γ��,sum(�������_M2)/sum(�������_2��ǰ_C) as cm2 ,sum(�������_M2) as �������_M2 from cs_1 group by ������;
quit;

data cm2;
set cm2_1 cm2_2 cm2_3 cm2_4;
run ;
proc sql;
create table cmt_2 as select a.* , b.cm2,b.�������_M2 from branch as a left join cm2 as b on a.Ӫҵ�� = b.γ��;

proc sort data = cmt_2;
by id;run;



/*proc freq data = cs_1;*/
/*table  ����;*/
/*run ;*/
/**/
/*data cs_4;*/
/*set cs_1;*/
/*if ����=  " ";*/
/*run ;*/

/*��cmt_1 cmt_2 cm cm2��ȫ��*/


/*��������_2��ǰ_C�����ռ��SHEET3��չʾ*/
/*libname repayFin "F:\A_offline_zky\kangyi\data_download\��ʷ����\�м��201712\repayAnalysis";*/
/*proc sql;*/
/*create table tst2 as select Ӫҵ��, sum(�������_1��ǰ_C) from repayfin.payment_daily(where=(cut_date=mdy(12,31,2017))) group by Ӫҵ�� ;quit;*/
/*proc sql;*/
/*create table tst2 as select Ӫҵ��, sum(�������_2��ǰ_C) from repayfin.payment_daily(where=(cut_date=&dt.)) group by Ӫҵ�� ;quit;*/

/*x  "F:\A_offline_zky\A_offline\daily\�ռ��\Ӫҵ���ռ�ر���.xlsx"; */
/*filename DD DDE "EXCEL|[Ӫҵ���ռ�ر���.xlsx]Sheet3!r6c6:r37c7";*/
/*data _null_;set Tst2;file DD;put Ӫҵ�� _TEMG001;run;*/



/*V���м�Ч��*/
proc sql ;
create table cm_5 as select contract_no ,Ӫҵ��,sum(�������_M1)/sum(�������_1��ǰ_C)as cm1,sum(�������_M1) as �������_M1,sum(�������_1��ǰ_C) as �������_1��ǰ_C  from cs_1 group by contract_no,Ӫҵ��;
quit;

proc sql;
create table cm__1 as
select a.*,b.�������_1��ǰ_M1 as �������_M1
from cm_5 as a
left join repayfin.payment_daily(where=(cut_date=&dt.)) as b
on a.contract_no=b.contract_no and a.Ӫҵ��=b.Ӫҵ��;
quit;

proc sql;
create table cm5_ as
select 
contract_no ,Ӫҵ��,�������_M1,�������_1��ǰ_C,
sum(�������_M1)/sum(�������_1��ǰ_C)as cm1_������
from cm__1
group by contract_no ,Ӫҵ��;
quit;

