/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname approval "E:\guan\原数据\approval";*/
/*libname repayFin "E:\guan\中间表\repayfin";*/
/*libname repayFna "E:\guan\中间表\repayfin";*/
/*libname credit 'E:\guan\原数据\cred';*/
/**/
/*x  "E:\guan\催收报表\vintage\MonthlyVintageVar.xlsx"; */
/**/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=var dbms=excel replace;*/
/*SHEET="var";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=newModel dbms=excel replace;*/
/*SHEET="newModel";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=oldModel dbms=excel replace;*/
/*SHEET="oldModel";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=tqfd dbms=excel replace;*/
/*SHEET="天启分档";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
/*out=lsm dbms=excel replace;*/
/*SHEET="近6月";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/


%let month="201904";*报表月;

data vinDDE;
set repayfin.payment_g;
format 放款月份1 yymmdd10.;
放款月份1=intnx("month",loan_date,0,"b");
if not kindex(产品小类,"米粒");
if month^="201905";*当前月;
run;

*【营业部】;
data apply_info;
set approval.apply_info(keep = apply_code name id_card_no branch_code branch_name DESIRED_PRODUCT);
	if branch_code = "6" then branch_name = "上海福州路营业部";
else if branch_code = "13" then branch_name = "上海福州路营业部";
else if branch_code = "16" then branch_name = "广州市林和西路营业部";
else if branch_code = "14" then branch_name = "合肥站前路营业部";
else if branch_code = "15" then branch_name = "福州五四路营业部";
else if branch_code = "17" then branch_name = "成都天府国际营业部";
else if branch_code = "50" then branch_name = "惠州第一营业部";
else if branch_code = "55" then branch_name = "海口市第一营业部";
else if branch_code = "57" then branch_name = "杭州建国北路营业部";
else if branch_code = "56" then branch_name = "厦门市第一营业部";
else if branch_code = "118" then branch_name = "邵阳市第一营业部";
else if branch_code = "65" then branch_name = "乌鲁木齐市第一营业部";
else if branch_code = "63" then branch_name = "赤峰市第一营业部";
else if branch_code = "60" then branch_name = "呼和浩特市第一营业部";
else if branch_code = "93" then branch_name = "泉州市第一营业部";
else if branch_code = "122" then branch_name = "郑州市第一营业部";
else if branch_code = "91" then branch_name = "天津市第一营业部";
else if branch_code = "90" then branch_name = "北京市第一营业部";
else if branch_code = "71" then branch_name = "怀化市第一营业部";
else if branch_code = "72" then branch_name = "昆明市第一营业部";
else if branch_code = "73" then branch_name = "重庆市第一营业部";
else if branch_code = "74" then branch_name = "南京市第一营业部";
else if branch_code = "75" then branch_name = "南宁市第一营业部";
else if branch_code = "89" then branch_name = "银川市第一营业部";
else if branch_code = "50" then branch_name = "惠州市第一营业部";
else if branch_code = "117" then branch_name = "盐城市业务中心";
else if branch_code = "116" then branch_name = "南通市业务中心";
else if branch_code = "114" then branch_name = "佛山业务中心";
else if branch_code = "115" then branch_name = "江门市业务中心";
else if branch_code = "119" then branch_name = "武汉市业务中心";
else if branch_code = "120" then branch_name = "红河市业务中心";
else if branch_code = "136" then branch_name = "佛山市第一营业部";

if kindex(branch_name,"深圳")  then branch_name="深圳市第一营业部";
else if kindex(branch_name,"江门") and kindex(branch_name,"业务中心") then branch_name="江门市业务中心";
else if kindex(branch_name,"佛山") then branch_name="佛山市第一营业部";
else if kindex(branch_name,"盐城") then branch_name="盐城市第一营业部";
else if kindex(branch_name,"湛江") then branch_name="湛江市第一营业部";
else if kindex(branch_name,"武汉") then branch_name="武汉市第一营业部";
else if kindex(branch_name,"红河") then branch_name="红河市第一营业部";
else if kindex(branch_name,"宁波") then branch_name="宁波市第一营业部";
else if kindex(branch_name,"贵阳") then branch_name="贵阳市第一营业部";
else if kindex(branch_name,"库尔勒") then branch_name="库尔勒市第一营业部";
else if kindex(branch_name,"汕头") then branch_name="汕头市第一营业部";
else if kindex(branch_name,"天津") then branch_name="天津市第一营业部";
else if kindex(branch_name,"兰州") then branch_name="兰州市第一营业部";

rename branch_name = 营业部;
format date yymmdd10.;
date=datepart(CREATED_TIME);
进件月份= put(DATE, yymmn6.);
run;
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "录入复核" and action_ = "COMPLETE")); /*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
input_complete=1;/*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
format 进件时间 yymmdd10.;
进件时间=datepart(create_time_);
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
format 征信获取时间 yymmdd10.;
征信获取时间=datepart(created_time);
keep report_number id_card created_time 征信获取时间;
run;
proc sort data=credit_report_ nodupkey;by report_number;run;
proc sql;
create table credit_report_ as 
select a.apply_code,a.进件时间,b.征信获取时间,c.SELF_QUERY_06_MONTH_FREQUENCY from apply_time_ as a
left join credit_report_ as b on a.id_card_no=b.id_card and a.进件时间 >= b.征信获取时间
left join credit_derived_data as c on b.report_number=c.report_number;
quit;
data credit_report_1;
set credit_report_;
/*if 征信获取时间>apply_time then labels=1;else labels=0;*/
run;
/*proc sort data=credit_report_1;by apply_code labels descending 征信获取时间; run;*/
proc sort data=credit_report_1;by apply_code descending 征信获取时间; run;
proc sort data = credit_report_1  nodupkey; by apply_code; run;

proc sql;
create table vinDDE1 as
select a.*,b.调整费率,d.MODEL_SCORE_LEVEL,d.group_Level,d.天启分档,e.SELF_QUERY_06_MONTH_FREQUENCY as 近6个月本人查询次数 from vindde as a
left join repayFna.interest_adjust as b  on a.contract_no=b.contract_no
left join repayFin.strategy as d on a.contract_no=d.contract_no
left join credit_report_1 as e on a.apply_code=e.apply_code;
quit;
data vinDDE;
set vinDDE1;
/*if 1.38<调整费率<1.78 then 调整费率=1.58;*/
if mob>0 and contract_no='C2018101613583597025048' then do;
od_days=0;od_periods=0;od_days_ever=0;status='01_C';未还本金_m1_plus=.;
end;
if mob>1 and contract_no='C2018101613583597025048' then do;
pre_1m_status='01_C';
end;
if LOAN_DATE<=mdy(1,1,2017) then do;MODEL_SCORE_LEVEL='';天启分档='';end;
if 0<=近6个月本人查询次数<=2 then 近6月="A";
	else if 3<=近6个月本人查询次数<=4 then 近6月="B";
	else if 5<=近6个月本人查询次数<=6 then 近6月="C";
	else if 7<=近6个月本人查询次数 then 近6月="D";
run;

*()放款-变量占比;
proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷")) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r239c5:r288c5";
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
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
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
		select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
		from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and &&varname_&i..=&&label_&i..)) group by 放款月份1;
	quit;
	proc sql;
		create table kan_fk1 as
		select a.放款月份1,b.合同金额,b.合同数量
		from kan_fk as a left join kan_fk0 as b on a.放款月份1=b.放款月份1;
	quit;
	filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r162c&j.:r211c&j.";
	data _null_;set kan_fk1;file DD;put 合同数量;run;

	filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]放款占比!r239c&j.:r288c&j.";
	data _null_;set kan_fk1;file DD;put 合同金额;run;
%end;
%mend;
%Var();

*()-Total;
*放款;

proc sql;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷")) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c3:r211c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c5:r288c5";
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
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c6:r288c6";
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


filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r162c7:r211c56";
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]TOTAL!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

*()-新模型;
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
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
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and MODEL_SCORE_LEVEL=&&label_&i..)) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and MODEL_SCORE_LEVEL=&&label_&i..)) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷" and MODEL_SCORE_LEVEL=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷" and MODEL_SCORE_LEVEL=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%newModel_table();

*()-旧模型;
/*proc import datafile="E:\guan\催收报表\vintage\vintage配置表.xls"*/
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
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and group_Level=&&label_&i..)) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and group_Level=&&label_&i..)) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷" and group_Level=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷" and group_Level=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%oldModel_table();

*()-天启分档;

data lable1;
set tqfd end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro tqModel_table();
%do i =1 %to &lpn.;
proc sql;
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and 天启分档=&&label_&i..)) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and 天启分档=&&label_&i..)) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷" and 天启分档=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷" and 天启分档=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%tqModel_table();

*()-近6月;
data lable1;
set lsm end=last;
call symput ("sheetname_"||compress(_n_),compress(sheetname));
call symput("label_"||compress(_n_),compress(label));
if last then call symput("lpn",compress(_n_));
run;

%macro jlyModel_table();
%do i =1 %to &lpn.;
proc sql;
*放款;
create table kan_fk as
select 放款月份1,sum(合同金额) as 合同金额 ,count(合同金额) as 合同数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and 近6月=&&label_&i..)) group by 放款月份1;
quit;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c3:r211c3";;
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c5:r211c5";
data _null_;set kan_fk;file DD;put 合同数量;run;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c3:r288c3";
data _null_;set kan_fk;file DD;put 放款月份1;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c5:r288c5";
data _null_;set kan_fk;file DD;put 合同金额;run;

*剩余本金;
proc sql;
create table kan_sy as
select 放款月份1,sum(贷款余额_本金部分) as 剩余本金 ,count(贷款余额_本金部分) as 剩余数量 
from vinDDE(where=(month=&month. and 产品大类 ^="续贷" and status not in ("11_Settled","09_ES") and 近6月=&&label_&i..)) group by 放款月份1;
quit;
proc sql;
create table kan_sy1 as
select a.放款月份1,b.剩余本金,b.剩余数量 from kan_fk as a
left join kan_sy as b on a.放款月份1=b.放款月份1;
quit;

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c6:r211c6";
data _null_;set kan_sy1;file DD;put 剩余数量;run;
filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c6:r288c6";
data _null_;set kan_sy1;file DD;put 剩余本金;run;
*vintage30+个数;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,count(未还本金_m1_plus) as ftcount  from vinDDE(where=(产品大类 ^="续贷" and 近6月=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r162c7:r211c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;
*vintage30+剩余本金;
proc sql;
create table caca1 as
select 放款月份1 as 放款月份,mob,sum(未还本金_m1_plus) as ftmount  from vinDDE(where=(产品大类 ^="续贷" and 近6月=&&label_&i..)) group by 放款月份1,mob ;
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

filename DD DDE "EXCEL|[MonthlyVintageVar.xlsx]&&sheetname_&i..!r239c7:r288c56";
data _null_;set caca2a;file DD;put a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 a_9 a_10 a_11 a_12 a_13 a_14 a_15 a_16 a_17 a_18 a_19 a_20 a_21 a_22 a_23 a_24 a_25 a_26 a_27 a_28 a_29 a_30 a_31 a_32 a_33 a_34 a_35 a_36
									a_37 a_38 a_39 a_40 a_41 a_42 a_43 a_44 a_45 a_46 a_47 a_48 a_49 a_50;run;

%end;
%mend;
%jlyModel_table();
