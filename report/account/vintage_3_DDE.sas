/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname approval odbc  datasrc=approval_nf;*/
/*libname repayFin "E:\guan\中间表\repayFin";*/
/*libname repayFna "E:\guan\中间表\repayFin";*/
/*libname ky 'E:\guan\中间表\repayfin';*/
/**/
/*x  "E:\guan\催收报表\vintage\MonthlyVintage.xlsx"; */
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=adfee dbms=excel replace;*/
/*SHEET="Sheet6";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=periods dbms=excel replace;*/
/*SHEET="Sheet2";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=bigproduct dbms=excel replace;*/
/*SHEET="Sheet3";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

%let month="201908";

data vinDDE;
set repayfin.payment_g;
format 放款月份1 yymmdd10.;
放款月份1=intnx("month",loan_date,0,"b");
if not kindex(产品小类,"米粒");
if month^="201909";
run;

proc sql;
create table vinDDE1 as
select a.*,b.调整费率 from vindde as a
left join repayFna.interest_adjust as b  on a.contract_no=b.contract_no;
quit;

data vinDDE;
set vinDDE1;
if 1.38<调整费率<1.78 then 调整费率=1.58;
if mob>0 and contract_no='C2018101613583597025048' then do;
od_days=0;od_periods=0;od_days_ever=0;status='01_C';未还本金_m1_plus=.;
end;
if mob>1 and contract_no='C2018101613583597025048' then do;
pre_1m_status='01_C';
end;
run;


*()-Total;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷")) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") )) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-Total 自营;
*放款;
data vinDDE_zy;
set vinDDE;
if kindex(营业部,'上海') or kindex(营业部,'杭州') or kindex(营业部,'宁波') or kindex(营业部,'广州') or kindex(营业部,'惠州') or kindex(营业部,'乌鲁木齐')
	or kindex(营业部,'南宁') or kindex(营业部,'汕头') or kindex(营业部,'海口') or kindex(营业部,'北京') or kindex(营业部,'天津') or kindex(营业部,'成都') 
	or kindex(营业部,'兰州') or kindex(营业部,'呼和浩特') or kindex(营业部,'武汉');
run;
proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE_zy(where=(month=&month. and 产品大类 ^="续贷")) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE_zy(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") )) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE_zy(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE_zy(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-现有门店!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-Total 已关门店;
*放款;
data vinDDE_zy;
set vinDDE;
if not (kindex(营业部,'上海') or kindex(营业部,'杭州') or kindex(营业部,'宁波') or kindex(营业部,'广州') or kindex(营业部,'惠州') or kindex(营业部,'乌鲁木齐')
	or kindex(营业部,'南宁') or kindex(营业部,'汕头') or kindex(营业部,'海口') or kindex(营业部,'北京') or kindex(营业部,'天津') or kindex(营业部,'成都') 
	or kindex(营业部,'兰州') or kindex(营业部,'贵阳') or kindex(营业部,'呼和浩特') or kindex(营业部,'武汉')) or kindex(营业部,'贵阳');
run;
proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE_zy(where=(month=&month. and 产品大类 ^="续贷")) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE_zy(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") )) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE_zy(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE_zy(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]TOTAL-已关门店!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-营业部;
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
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
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and 营业部=&&label_&i..)) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and 营业部=&&label_&i..)) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷" and 营业部=&&label_&i..)) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷" and 营业部=&&label_&i..)) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%city_table();

*()-调整费率;
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
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
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and 调整费率=&&label_&i..)) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and 调整费率=&&label_&i..)) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷" and 调整费率=&&label_&i..)) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷" and 调整费率=&&label_&i..)) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
%end;
%mend;
%city_table();

*()-期限;
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
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
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and PERIOD=&&label_&i..)) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and PERIOD=&&label_&i..)) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷" and PERIOD=&&label_&i..)) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷" and PERIOD=&&label_&i..)) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
%end;
%mend;
%city_table();


*()-产品;
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
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
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 in (&&label_&i..))) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 in (&&label_&i..) and status not in ("11_Settled","09_ES") )) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 in (&&label_&i..))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 in (&&label_&i..))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
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


*()-退休人群;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from Vindde1(where=(month=&month. and 产品大类 ^="续贷" and POSITION ="297")) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE1(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and POSITION ="297")) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE1(where=(产品大类 ^="续贷" and POSITION ="297")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE1(where=(产品大类 ^="续贷" and POSITION ="297")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]退休客群!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;


*()-自雇产品;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from Vindde1(where=(month=&month. and 产品大类 ^="续贷" and kindex(产品大类,"自雇"))) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE1(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and kindex(产品大类,"自雇"))) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"自雇"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"自雇"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]自雇产品!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*()-E微总产品;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from Vindde1(where=(month=&month. and 产品大类 ^="续贷" and kindex(产品大类,"E微"))) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE1(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and kindex(产品大类,"E微"))) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E微"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E微"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E微贷!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

***********************************************************************************************************************************************************************************************
*()-E保通总产品;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from Vindde1(where=(month=&month. and 产品大类 ^="续贷" and kindex(产品大类,"E保"))) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE1(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and kindex(产品大类,"E保"))) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E保"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E保"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E保通!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

********************************************************************************************************************************************************************************************
*()-E房通总产品;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from Vindde1(where=(month=&month. and 产品大类 ^="续贷" and kindex(产品大类,"E房"))) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE1(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and kindex(产品大类,"E房"))) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E房"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E房"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E房通!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

************************************************************************************************************************************************************
*()-E宅通总产品;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from Vindde1(where=(month=&month. and 产品大类 ^="续贷" and kindex(产品大类,"E宅"))) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE1(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and kindex(产品大类,"E宅"))) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E宅"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE1(where=(产品大类 ^="续贷" and kindex(产品大类,"E宅"))) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]E宅通!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
************************************************************************************************************************************************************
*()-APP;

data payment_daily;
set ky.payment_daily;
run;
data payment_daily_;
set payment_daily;
if 营业部="APP";
keep contract_no 营业部;
run;
proc sort data=payment_daily_ nodupkey;by contract_no;run;
proc sql;
create table Vindde2 as 
select a.* from Vindde1 as a where a.contract_no in (select contract_no from payment_daily_);
quit;
*放款;
proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from Vindde2(where=(month=&month. and 产品大类 ^="续贷")) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;

proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from Vindde2(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES"))) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;

*vintage30+个数;

proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from Vindde2(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftcount;
run;

proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;


filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from Vindde2(where=(产品大类 ^="续贷")) group by 放款月份1,mob ;
quit;

proc sort data=caca1;by 放款月份 mob;run;
proc transpose data=caca1 out=caca2(drop=_NAME_)  prefix=a_;
by 放款月份;
id mob;
var ftmount;
run;
proc sql;
create table caca2a as
select a.放款月份1 ,b.* from kan_fk as a
left join caca2 as b on a.放款月份1=b.放款月份;
quit;

filename DD DDE "EXCEL|[MonthlyVintage.xlsx]APP!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
