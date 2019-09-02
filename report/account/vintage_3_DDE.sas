/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname approval odbc  datasrc=approval_nf;*/
/*libname repayFin "E:\guan\�м��\repayFin";*/
/*libname repayFna "E:\guan\�м��\repayFin";*/
/*libname ky 'E:\guan\�м��\repayfin';*/
/**/
/*x  "E:\guan\���ձ���\vintage\MonthlyVintage.xlsx"; */
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=adfee dbms=excel replace;*/
/*SHEET="Sheet6";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=periods dbms=excel replace;*/
/*SHEET="Sheet2";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=bigproduct dbms=excel replace;*/
/*SHEET="Sheet3";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

%let month="201908";

data vinDDE;
set repayfin.payment_g;
format �ſ��·�1 yymmdd10.;
�ſ��·�1=intnx("month",loan_date,0,"b");
if not kindex(��ƷС��,"����");
if month^="201909";
run;

proc sql;
create table vinDDE1 as
select a.*,b.�������� from vindde as a
left join repayFna.interest_adjust as b  on a.contract_no=b.contract_no;
quit;

data vinDDE;
set vinDDE1;
if 1.38<��������<1.78 then ��������=1.58;
if mob>0 and contract_no='C2018101613583597025048' then do;
od_days=0;od_periods=0;od_days_ever=0;status='01_C';δ������_m1_plus=.;
end;
if mob>1 and contract_no='C2018101613583597025048' then do;
pre_1m_status='01_C';
end;
run;


*()-Total;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����")) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c5:r288c5";
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
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c6:r288c6";
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c7:r211c56";
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-Total ��Ӫ;
*�ſ�;
data vinDDE_zy;
set vinDDE;
if kindex(Ӫҵ��,'�Ϻ�') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'��³ľ��')
	or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'��ͷ') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'���') or kindex(Ӫҵ��,'�ɶ�') 
	or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'���ͺ���') or kindex(Ӫҵ��,'�人');
run;
proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE_zy(where=(month=&month. and ��Ʒ���� ^="����")) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE_zy(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") )) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE_zy(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE_zy(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�����ŵ�!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-Total �ѹ��ŵ�;
*�ſ�;
data vinDDE_zy;
set vinDDE;
if not (kindex(Ӫҵ��,'�Ϻ�') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'��³ľ��')
	or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'��ͷ') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'���') or kindex(Ӫҵ��,'�ɶ�') 
	or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'����') or kindex(Ӫҵ��,'���ͺ���') or kindex(Ӫҵ��,'�人')) or kindex(Ӫҵ��,'����');
run;
proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE_zy(where=(month=&month. and ��Ʒ���� ^="����")) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE_zy(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") )) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE_zy(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE_zy(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-�ѹ��ŵ�!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-Ӫҵ��;
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
data lable1;
set branch end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro city_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and Ӫҵ��=&&label_&i..)) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and Ӫҵ��=&&label_&i..)) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����" and Ӫҵ��=&&label_&i..)) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����" and Ӫҵ��=&&label_&i..)) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%city_table();

*()-��������;
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=adfee dbms=excel replace;*/
/*SHEET="Sheet6";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
data lable1;
set adfee end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro city_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and ��������=&&label_&i..)) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and ��������=&&label_&i..)) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����" and ��������=&&label_&i..)) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����" and ��������=&&label_&i..)) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
%end;
%mend;
%city_table();

*()-����;
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=periods dbms=excel replace;*/
/*SHEET="Sheet2";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
data lable1;
set periods end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro city_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and PERIOD=&&label_&i..)) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and PERIOD=&&label_&i..)) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� ^="����" and PERIOD=&&label_&i..)) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� ^="����" and PERIOD=&&label_&i..)) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
%end;
%mend;
%city_table();


*()-��Ʒ;
/*proc import datafile="E:\guan\���ձ���\vintage\vintage���ñ�.xls"*/
/*out=bigproduct dbms=excel replace;*/
/*SHEET="Sheet3";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
data lable1;
set bigproduct end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro city_table();
%do i =1 %to &lpn.;
proc sql;
*�ſ�;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from vinDDE(where=(month=&month. and ��Ʒ���� in (&&label_&i..))) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;
proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE(where=(month=&month. and ��Ʒ���� in (&&label_&i..) and status not in ("11_Settled","09_ES") )) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;
*vintage30+����;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE(where=(��Ʒ���� in (&&label_&i..))) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE(where=(��Ʒ���� in (&&label_&i..))) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%city_table();

proc sql;
create table Vindde1 as 
select a.*,b.POSITION  from Vindde as a
left join approval.apply_emp as b on a.apply_code=b.apply_code;
quit;


*()-������Ⱥ;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from Vindde1(where=(month=&month. and ��Ʒ���� ^="����" and POSITION ="297")) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE1(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and POSITION ="297")) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE1(where=(��Ʒ���� ^="����" and POSITION ="297")) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE1(where=(��Ʒ���� ^="����" and POSITION ="297")) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]���ݿ�Ⱥ!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;


*()-�ԹͲ�Ʒ;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from Vindde1(where=(month=&month. and ��Ʒ���� ^="����" and kindex(��Ʒ����,"�Թ�"))) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE1(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and kindex(��Ʒ����,"�Թ�"))) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"�Թ�"))) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"�Թ�"))) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]�ԹͲ�Ʒ!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*()-E΢�ܲ�Ʒ;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from Vindde1(where=(month=&month. and ��Ʒ���� ^="����" and kindex(��Ʒ����,"E΢"))) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE1(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and kindex(��Ʒ����,"E΢"))) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"E΢"))) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"E΢"))) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E΢��!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

***********************************************************************************************************************************************************************************************
*()-E��ͨ�ܲ�Ʒ;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from Vindde1(where=(month=&month. and ��Ʒ���� ^="����" and kindex(��Ʒ����,"E��"))) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE1(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and kindex(��Ʒ����,"E��"))) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"E��"))) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"E��"))) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

********************************************************************************************************************************************************************************************
*()-E��ͨ�ܲ�Ʒ;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from Vindde1(where=(month=&month. and ��Ʒ���� ^="����" and kindex(��Ʒ����,"E��"))) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE1(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and kindex(��Ʒ����,"E��"))) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"E��"))) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"E��"))) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E��ͨ!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

************************************************************************************************************************************************************
*()-Eլͨ�ܲ�Ʒ;
*�ſ�;

proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from Vindde1(where=(month=&month. and ��Ʒ���� ^="����" and kindex(��Ʒ����,"Eլ"))) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from vinDDE1(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES") and kindex(��Ʒ����,"Eլ"))) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"Eլ"))) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from vinDDE1(where=(��Ʒ���� ^="����" and kindex(��Ʒ����,"Eլ"))) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]Eլͨ!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
************************************************************************************************************************************************************
*()-APP;

data payment_daily;
set ky.payment_daily;
run;
data payment_daily_;
set payment_daily;
if Ӫҵ��="APP";
keep contract_no Ӫҵ��;
run;
proc sort data=payment_daily_ nodupkey;by contract_no;run;
proc sql;
create table Vindde2 as 
select a.* from Vindde1 as a where a.contract_no in (select contract_no from payment_daily_);
quit;
*�ſ�;
proc sql;
create table kan_fk as
select �ſ��·�1,sum(��ͬ���) as ��ͬ��� ,count(��ͬ���) as ��ͬ���� 
from Vindde2(where=(month=&month. and ��Ʒ���� ^="����")) group by �ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c3:r211c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c5:r211c5";
data _null_;set kan_fk;file DD;put ��ͬ����;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c3:r288c3";
data _null_;set kan_fk;file DD;put �ſ��·�1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c5:r288c5";
data _null_;set kan_fk;file DD;put ��ͬ���;run;

*ʣ�౾��;

proc sql;
create table kan_sy as
select �ſ��·�1,sum(�������_���𲿷�) as ʣ�౾�� ,count(�������_���𲿷�) as ʣ������ 
from Vindde2(where=(month=&month. and ��Ʒ���� ^="����" and status not in ("11_Settled","09_ES"))) group by �ſ��·�1;
quit;
proc sql;
create table kan_sy1 as
select a.�ſ��·�1,b.ʣ�౾��,b.ʣ������ from kan_fk as a
left join kan_sy as b on a.�ſ��·�1=b.�ſ��·�1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put ʣ������;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put ʣ�౾��;run;

*vintage30+����;

proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,count(δ������_m1_plus) as ftcount  from Vindde2(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
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


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+ʣ�౾��;
proc sql;
create table caca1 as
select �ſ��·�1 as �ſ��·�,mob,sum(δ������_m1_plus) as ftmount  from Vindde2(where=(��Ʒ���� ^="����")) group by �ſ��·�1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
