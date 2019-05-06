/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname approval "E:\guan\ԭ����\approval";*/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname repayFna "E:\guan\�м��\repayfin";*/
/*libname credit 'E:\guan\ԭ����\cred';*/
/**/
/*x  "E:\guan\���ձ���\vintage\MonthlyVintageVar.xlsx"; */
/**/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=var dbms=excel replace;*/
/*SHEET="var";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=newModel dbms=excel replace;*/
/*SHEET="newModel";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=oldModel dbms=excel replace;*/
/*SHEET="oldModel";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=tqfd dbms=excel replace;*/
/*SHEET="�����ֵ�";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=lsm dbms=excel replace;*/
/*SHEET="��6��";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/


%let month="201904";*������;

data vinDDE;
set repayfin.payment_g;
format �ſ��·�1 yymmdd10.;
�ſ��·�1=intnx("month",loan_date,0,"b");
if not kindex(��ƷС��,"����");
if month^="201905";*��ǰ��;
run;

*��Ӫҵ����;
data apply_info;
set approval.apply_info(keep = apply_code name id_card_no branch_code branch_name DESIRED_PRODUCT);
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

rename branch_name = Ӫҵ��;
format date yymmdd10.;
date=datepart(CREATED_TIME);
�����·�= put(DATE, yymmn6.);
run;
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE")); /*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
input_complete=1;/*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
format ����ʱ�� yymmdd10.;
����ʱ��=datepart(create_time_);
/*keep bussiness_key_ create_time_ input_complete;*/
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time dupout = a nodupkey; by apply_code apply_time; run;
proc sort data = apply_time nodupkey; by apply_code; run;
proc sql;
create table apply_time_ as 
select a.*,b.ID_CARD_NO from apply_time as a
left join approval.apply_info as b on a.apply_code=b.apply_code;
quit;
proc sort data = apply_time_ nodupkey; by apply_code; run;
data credit_derived_data;
set credit.credit_derived_data;
run;
data credit_report;
set credit.credit_report;
run;
data credit_report_;
set credit_report;
format ���Ż�ȡʱ�� yymmdd10.;
���Ż�ȡʱ��=datepart(created_time);
keep report_number id_card created_time ���Ż�ȡʱ��;
run;
proc sort data=credit_report_ nodupkey;by report_number;run;
proc sql;
create table credit_report_ as 
select a.apply_code,a.����ʱ��,b.���Ż�ȡʱ��,c.SELF_QUERY_06_MONTH_FREQUENCY from apply_time_ as a
left join credit_report_ as b on a.id_card_no=b.id_card and a.����ʱ�� >= b.���Ż�ȡʱ��
left join credit_derived_data as c on b.report_number=c.report_number;
quit;
data credit_report_1;
set credit_report_;
/*if ���Ż�ȡʱ��>apply_time then labels=1;else labels=0;*/
run;
/*proc sort data=credit_report_1;by apply_code labels descending ���Ż�ȡʱ��; run;*/
proc sort data=credit_report_1;by apply_code descending ���Ż�ȡʱ��; run;
proc sort data = credit_report_1  nodupkey; by apply_code; run;

proc sql;
create table vinDDE1 as
select a.*,b.��������,d.MODEL_SCORE_LEVEL,d.group_Level,d.�����ֵ�,e.SELF_QUERY_06_MONTH_FREQUENCY as ��6���±��˲�ѯ���� from vindde as a
left join repayFna.interest_adjust as b  on a.contract_no=b.contract_no
left join repayFin.strategy as d on a.contract_no=d.contract_no
left join credit_report_1 as e on a.apply_code=e.apply_code;
quit;
data vinDDE;
set vinDDE1;
/*if 1.38<��������<1.78 then ��������=1.58;*/
if mob>0 and contract_no='C2018101613583597025048' then do;
od_days=0;od_periods=0;od_days_ever=0;status='01_C';δ������_m1_plus=.;
end;
if mob>1 and contract_no='C2018101613583597025048' then do;
pre_1m_status='01_C';
end;
if LOAN_DATE<=mdy(1,1,2017) then do;MODEL_SCORE_LEVEL='';�����ֵ�='';end;
if 0<=��6���±��˲�ѯ����<=2 then ��6��="A";
	else if 3<=��6���±��˲�ѯ����<=4 then ��6��="B";
	else if 5<=��6���±��˲�ѯ����<=6 then ��6��="C";
	else if 7<=��6���±��˲�ѯ���� then ��6��="D";
run;

*()�ſ�-����ռ��;
proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����")) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") )) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=var dbms=excel replace;*/
/*SHEET="var";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
data lable1;
set var end=last;
call symput ("varname_"||compress(_n_),compress(varname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;
data aa;
i=1;
run;
%macro Var();
%do i =1 %to &lpn.;
	%if &i.>3 %then %do;
		data _null_;
		format j $2.;
		j=6+&i.;
		call symput('j',j);
		run;
	%end;
	%else %do;
		data _null_;
		format j $1.;
		j=6+&i.;
		call symput('j',j);
		run;
	%end;
	proc sql;
		create table kan_fk0 as
		select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
		from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and &&varname_&i..=&&label_&i..)) group by �ſ��·�1;
	quit;
	proc sql;
		create table kan_fk1 as
		select a.�ſ��·�1,b.��ͬ���,b.��ͬ����
		from kan_fk as a left join kan_fk0 as b on a.�ſ��·�1=b.�ſ��·�1;
	quit;
	filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r162c&j.:r211c&j.";
	data _null_;set kan_fk1;file DD;put ��ͬ����;run;

	filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]�ſ�ռ��!r239c&j.:r288c&j.";
	data _null_;set kan_fk1;file DD;put ��ͬ���;run;
%end;
%mend;
%Var();

*()-Total;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����")) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") )) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;


filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-��ģ��;
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=newModel dbms=excel replace;*/
/*SHEET="newModel";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
data lable1;
set newModel end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro newModel_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and MODEL_SCORE_LEVEL=&&label_&i..)) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and MODEL_SCORE_LEVEL=&&label_&i..)) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����" and MODEL_SCORE_LEVEL=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����" and MODEL_SCORE_LEVEL=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%newModel_table();

*()-��ģ��;
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=oldModel dbms=excel replace;*/
/*SHEET="oldModel";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
data lable1;
set oldModel end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro oldModel_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and group_Level=&&label_&i..)) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and group_Level=&&label_&i..)) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����" and group_Level=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����" and group_Level=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%oldModel_table();

*()-�����ֵ�;

data lable1;
set tqfd end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro tqModel_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and �����ֵ�=&&label_&i..)) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and �����ֵ�=&&label_&i..)) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����" and �����ֵ�=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����" and �����ֵ�=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%tqModel_table();

*()-��6��;
data lable1;
set lsm end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro jlyModel_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and ��6��=&&label_&i..)) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and ��6��=&&label_&i..)) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����" and ��6��=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����" and ��6��=&&label_&i..)) group by �ſ��·�1,mob ;
quit;

proc sort data=caca1;by �ſ��·� mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by �ſ��·�;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.�ſ��·�1 ,b.* from kan_fk as a
left join caca2 as b on a.�ſ��·�1=b.�ſ��·�;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%jlyModel_table();
