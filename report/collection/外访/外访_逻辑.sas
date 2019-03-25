/*option compress = yes validvarname = any;*/
/*libname acco odbc database=account_nf;*/
/*libname csdata 'E:\guan\原数据\csdata';*/
/*libname approval 'E:\guan\原数据\approval';*/
/*libname account 'E:\guan\原数据\account';*/
/*libname res "E:\guan\原数据\res";*/
/*libname repayfin "E:\guan\中间表\repayfin";*/
/**/
/*x 'E:\guan\催收报表\外访\外访案件分配及催回率.xlsx';*/
/**/
/*proc import datafile="E:\guan\催收报表\MTD\米粒报表配置表.xls"*/
/*out=kanr_visit6 dbms=excel replace;*/
/*SHEET="外访";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/**/
/*%include "E:\guan\催收报表\外访\外访_逻辑.sas";*/

data aa;
format dt yymmdd10.;
 dt = today() - 1;
 if month(dt)=month(dt-2) then 
 db=intnx("month",dt,0,"b");
 else if weekday(dt)=1 then
db=intnx("month",dt-2,0,"b");
else db=intnx("month",dt,0,"b");
dbpe=intnx("month",dt,0,"b")-1;
/*dt=mdy(9,30,2017);*/
/*db=mdy(9,1,2017);*/
 nd = dt-db;
if weekday(dt)=1 then do;weekf=intnx('week',dt,-1)+1;end;
	else do; weekf=intnx('week',dt,0)+1;end;
call symput("dbpe", dbpe);
call symput("nd", nd);
call symput("db",db);
call symput("dt",dt);
call symput("weekf",weekf);
run;

data ca_staff;
set res.ca_staff;
id1=compress(put(id,$20.));
run;
data ctl_apply_visit;
set csdata.ctl_apply_visit;
run;
data ctl_visit_task;
set csdata.ctl_visit_task;
run; 
data ctl_visit;
set csdata.ctl_visit;
run;
data ctl_visit_result;
set csdata.ctl_visit_result;
run;
data bill_main;
set account.bill_main;
if clear_date<=&dbpe. then delete;
run;
proc sort data=bill_main;by contract_no clear_date CURR_PERIOD;run;
proc sort data=bill_main nodupkey;by contract_no clear_date;run;
data ctl_vlist_1;
set ctl_visit;
format 外访开始日期 yymmdd10.;
外访开始日期=datepart(VISIT_START_TIME);
format 外访结束日期 yymmdd10.;
外访结束日期=datepart(VISIT_END_TIME);
format 外访创建日期 yymmdd10.;
外访创建日期=datepart(CREATE_TIME);
run;

/******添加ctl_vlist_1去重hhq********/
proc sort data=ctl_vlist_1;by CONTRACT_NO 外访开始日期;run;
data ctl_vlist_1;
set ctl_vlist_1;
by CONTRACT_NO;
if last.CONTRACT_NO;
run;

****************************************************************

status	含义
-2	流程已经关闭，任务已被调整
-1	这个流程已经关闭
0	未分配
1	每日新案件
2	进行中的任务
3	任务已完成

****************************************************************;
proc sql;
create table kanr_visit as
select a.*,b.userName,c.contract_no  from ctl_visit_task as a
left join ca_staff as b on a.emp_id=b.id1
left join ctl_apply_visit as c on a.VISIT_ID=c.id;
quit;
data kanr_visit1;
set kanr_visit;
format 外访分配日期 yymmdd10.;
format 预计外访开始日期 yymmdd10.;
format 预计外访结束日期 yymmdd10.;
外访分配日期=datepart(ASSIGN_TIME);
预计外访开始日期=datepart(VISIT_START_TIME);
预计外访结束日期=datepart(VISIT_END_TIME);
外访分配月份=put(datepart(VISIT_START_TIME),yymmn6.);
if status=-2 then delete;
if id=18092520121104 then delete;
分配=1;
if &db.<=外访分配日期<=&dt.;
run;

/*************月初注释掉————由于缺少外访记录，需手动添加*********/
/*data kanr_visit1_1;*/
/*contract_no='C152109534097503000004739';*/
/*status='3';*/
/*format 外访分配日期 yymmdd10.;*/
/*format 预计外访开始日期 yymmdd10.;*/
/*format 预计外访结束日期 yymmdd10.;*/
/*外访分配日期=mdy(02,22,2019);*/
/*预计外访开始日期=mdy(02,26,2019);*/
/*预计外访结束日期=mdy(02,26,2019);*/
/*userName="姜浩然";*/
/*分配=1;*/
/*run;*/
/**************月初注释掉********************/

data kanr_visit1;
set kanr_visit1;
pre_外访分配日期=intnx('day',外访分配日期,-1);*分配日期当天催回的部分会导致逾期天数跳转，故用前一天逾期天数做对比;
run;
/*proc sort data=kanr_visit1 nodupkey;by contract_no;run;*/

proc sql;
create table kanr_visit2 as 
select a.*,b.od_days,b.客户姓名,b.营业部,b.repay_date,c.clear_date,c.OVERDUE_DAYS,d.贷款余额,d.od_days as od_days_yd,e.外访开始日期,e.外访创建日期,f.od_days as pre_od_days from kanr_visit1 as a
left join repayfin.payment_daily(where=(营业部^="APP")) as b on a.contract_no=b.contract_no and b.cut_date=a.外访分配日期
left join bill_main as c on a.contract_no=c.contract_no
left join repayfin.payment as d on a.contract_no=d.contract_no and d.cut_date=&dbpe.
left join ctl_vlist_1 as e on a.contract_no=e.contract_no
left join repayfin.payment_daily(where=(营业部^="APP")) as f on a.contract_no=f.contract_no and a.pre_外访分配日期=f.cut_date;
quit;
data kanr_visit3;
set kanr_visit2;

if 营业部='北京市第一营业部' and username='李超' then username='李超1';
if 预计外访开始日期<=外访创建日期 then 外访=1;else 外访=0;
/*if status=3 or (status^=3 and 预计外访开始日期<=外访开始日期<=预计外访结束日期) then 外访=1;else 外访=0;*/
/*if (预计外访开始日期<=外访开始日期<=预计外访结束日期) then 外访=1;else 外访=0;*/
if 预计外访开始日期<=clear_date<=预计外访结束日期 then 催回=1;else 催回=0;

if 催回=1 then do;贷款余额_催回=贷款余额;外访=1;end;else do; 贷款余额_催回=0;clear_date=.;end;
/*if od_days=31 and day(repay_date)=day(外访分配日期) then od_days=30;*/
if od_days<=15 then od_days=od_days_yd+day(外访分配日期);
/*if pre_od_days-od_days>0 then od_days=pre_od_days;*/
if clear_date=外访分配日期 then od_days=OVERDUE_DAYS;
if 30>=od_days>15 then 阶段="M1";
	else if 90>=od_days>30 then 阶段="M2";
keep ID contract_no 外访开始日期 预计外访开始日期 预计外访结束日期 外访分配月份 od_days 贷款余额 od_days_yd 阶段 userName status 催回 clear_date 外访分配日期 客户姓名 营业部 外访 贷款余额_催回;
run;
proc sort data=kanr_visit3;by contract_no descending 外访 descending 催回 descending 外访分配日期;run;
proc sort data=kanr_visit3 out=kanr_visit4 nodupkey;by contract_no 阶段;run;
proc sql;
create table kanr_visit5 as 
select username,阶段,count(contract_no) as nums,sum(外访) as 外访,sum(贷款余额) as 贷款余额,sum(催回) as 催回,sum(贷款余额_催回) as 贷款余额_催回 from kanr_visit4 group by username,阶段;
quit;
proc sql;
create table kanr_visit5_ as 
select username,阶段,sum(催回) as 催回_week,sum(贷款余额_催回) as 贷款余额_催回_week from kanr_visit4 where &weekf.<=clear_date<=&dt. group by username,阶段;
quit;

proc sql;
create table kanr_visit7 as 
select a.*,b.*,c.* from kanr_visit6 as a
left join kanr_visit5 as b on a.username=b.username 
left join kanr_visit5_ as c on  a.username=c.username and b.阶段=c.阶段;
quit;
proc sort data=kanr_visit7;by 编号;run;
proc sql;
create table kanr_visit7_1 as 
select a.*,b.* from kanr_visit6 as a
left join kanr_visit7 as b on a.username=b.username and b.阶段="M1";
quit;
proc sort data=kanr_visit7_1;by 编号;run;
proc sql;
create table kanr_visit7_2 as 
select a.*,b.* from kanr_visit6 as a
left join kanr_visit7 as b on a.username=b.username and b.阶段="M2";
quit;
proc sort data=kanr_visit7_2;by 编号;run;
data kanr_visit8_1;
set kanr_visit7_1;
if 编号<=8;
run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r3c3:r10c6";
data _null_;set kanr_visit8_1;file DD;put nums 外访 贷款余额 催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r3c8:r10c8";
data _null_;set kanr_visit8_1;file DD;put 贷款余额_催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r3c10:r10c11";
data _null_;set kanr_visit8_1;file DD;put 催回_week 贷款余额_催回_week;run;

data kanr_visit8_2;
set kanr_visit7_2;
if 编号<=8;
run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r3c12:r10c15";
data _null_;set kanr_visit8_2;file DD;put nums 外访 贷款余额 催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r3c17:r10c17";
data _null_;set kanr_visit8_2;file DD;put 贷款余额_催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r3c19:r10c20";
data _null_;set kanr_visit8_2;file DD;put 催回_week 贷款余额_催回_week;run;

data kanr_visit8_3;
set kanr_visit7_1;
if 编号>=9;
run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r13c3:r22c6";
data _null_;set kanr_visit8_3;file DD;put nums 外访 贷款余额 催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r13c8:r22c8";
data _null_;set kanr_visit8_3;file DD;put 贷款余额_催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r13c10:r22c11";
data _null_;set kanr_visit8_3;file DD;put 催回_week 贷款余额_催回_week;run;

data kanr_visit8_4;
set kanr_visit7_2;
if 编号>=9;
run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r13c12:r22c15";
data _null_;set kanr_visit8_4;file DD;put nums 外访 贷款余额 催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r13c17:r22c17";
data _null_;set kanr_visit8_4;file DD;put 贷款余额_催回;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]回款占比!r13c19:r22c20";
data _null_;set kanr_visit8_4;file DD;put 催回_week 贷款余额_催回_week;run;

data kanr_visit4;
set kanr_visit4;
if 催回=0 then clear_date=.;
run;
proc sort data=kanr_visit4;by descending 催回 descending 外访 descending CLEAR_DATE 外访分配日期;run;
filename DD DDE "EXCEL|[外访案件分配及催回率.xlsx]明细!r2c1:r500c10";
data _null_;set kanr_visit4;file DD;put contract_no 客户姓名 营业部 阶段 贷款余额 username 外访分配日期 外访 催回 CLEAR_DATE;run;
