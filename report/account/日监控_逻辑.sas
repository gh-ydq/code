/*option validvarname=any;option compress=yes;*/
/*libname repayFin "E:\guan\中间表\repayfin";*/
/*libname zq "E:\guan\中间表\zq";*/
/*libname account 'E:\guan\原数据\account';*/
/*libname midapp "E:\guan\中间表\midapp";*/
/*libname approval 'E:\guan\原数据\approval';*/
/**/
/*x  "E:\guan\日监控临时报表\营业部日监控报表.xlsx"; */
/**/
/*proc import datafile="E:\guan\日监控临时报表\营业部DDE.xls"*/
/*out=dept dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/**/
/*proc import datafile="E:\guan\日监控临时报表\配置表.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

data macrodate;
format date  start_date  fk_month_begin month_begin  end_date last_month_end last_month_begin month_end yymmdd10.;*定义时间变量格式;
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(12,31,2017);*/
call symput("tabledate",date);*定义一个宏;
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
if day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*当月26-下月25的循环;
end_date = mdy(month(date)+1,25,year(date));end;
else do;fk_month_begin = mdy(month(date)-1,26,year(date));
end_date = mdy(month(date),25,year(date));end;
/*加了一个12月底跟新的一年1月初的情况，不然新年或者月底会出现空值*/
if month(date)=12 and day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*当月26-下月25的循环;
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
if contract_no='C2018101613583597025048' then delete;*库热西·马合木提不用催收,剔除分母分子;
if contract_no='C2017121414464569454887' then delete;*蒋楠委外客户不用催收,剔除分母分子;
if contract_no='C2017111716235470079023' and month='201904' then delete;*王丽青4月份做帐太迟，4月份不计算分母分子,剔除分母分子;
run;
*累计流入明细;
data new_overdue;
set payment_daily;
if 营业部^="APP";
if 营业部^="";*去除米粒;
if od_days=0 and 还款_当日扣款失败合同=1  and REPAY_DATE=cut_date;
if &dt.>=cut_date>=&db.;
rename cut_date=流入日期;
keep cut_date CONTRACT_NO 营业部 客户姓名 身份证号码;
run;
proc sort data=new_overdue;by 流入日期;run;

*累计滑落明细;
data eight_overdue;
set payment_daily;
if 营业部^="APP";
if 营业部^="";*去除米粒;
last_oddays=lag(od_days);
if 还款_当日流入15加合同=1;
if &dt.>=cut_date>=&db.;
rename cut_date=流入日期;
keep cut_date CONTRACT_NO 营业部 客户姓名 身份证号码 还款_当日流入15加合同 last_oddays;
run;
proc sort data=eight_overdue;by 流入日期;run;

*还清日;
data month1day;
set payment_daily(keep=contract_no  od_days cut_date 贷款余额 还款_当日扣款失败合同 REPAY_DATE 营业部);
run;
proc sort data=month1day ;by CONTRACT_no  cut_date descending 营业部;run;
data  clear_17detail;
set month1day;
if 营业部^="";*去除米粒;
if 营业部^="APP";
last_oddays=lag(od_days);
last_贷款余额=lag(贷款余额);
last_扣款结果=lag(还款_当日扣款失败合同);
by CONTRACT_no   cut_date;
if first.contract_no then do ;last_oddays=od_days;last_贷款余额=贷款余额;last_扣款结果=还款_当日扣款失败合同;end;
*早上;
if cut_date=&dt.;
*下午;
/*if cut_date=&nt.;*/
/*if (1<=last_oddays<=14 and od_days<1) or (last_扣款结果=1 and od_days<1);*/
if last_oddays>od_days or  (last_扣款结果=1 and od_days<1);
repay_date = &dt.-last_oddays-1;
format 还清日 yymmdd10.;
还清日=&dt.;
keep contract_no 营业部 repay_date 还清日 ;
run;

*周末滑落数据;
data monday;
set payment_daily;
if 营业部^="APP";
if 营业部^="";*去除米粒;
if 还款_当日流入15加合同=1;
if cut_date>=&dt.-2;
rename cut_date=流入日期;
keep cut_date CONTRACT_NO 营业部 客户姓名 身份证号码 还款_当日流入15加合同;
run;
proc sort data=monday;by 流入日期;run;

*当日扣款数和当日扣款失败数,得到滑落M1的滑落率;
data test1_7 ;
set payment_daily;
if cut_date=&dt. and repay_date=&dt.  and od_days=0;
run;
proc sql;
create table test1_7kan as
select 营业部,sum(还款_当日扣款失败合同)/count(*) as 流入率 format=percent7.2 from test1_7 group by 营业部;
quit;
proc sql;
create table all1_7 as
select "总计" as 营业部,sum(还款_当日扣款失败合同)/count(*) as 流入率 format=percent7.2 from test1_7 ;
quit;
proc sql;
create table lrl1_7 as
select a.id,a.营业部,b.流入率 from dept as a
left join test1_7kan as b on a.营业部=b.营业部;
quit;
proc sort data=lrl1_7;by id;run;
data lrl1_7_end;
set lrl1_7 all1_7;
run;
*--------------------------------------------------------------5日监控贴数据----------------------------------------------------------------------------------------*;
*得到进件、回退、审批通过率、放款量、放款金额数据;
*tabledate也是昨天;
*dt是昨天;
/*%let tabledate=mdy(4,26,2018);*/
/*%let dt=mdy(12,31,2017);*/
data zd_pr;
set midapp.Partone_cumulate_end(where=(date=&tabledate.));
format 分中心 区域  $15.;
if  branch_name = "上海第二营业部" then branch_name = "上海福州路营业部";
if branch_name in ("上海福州路营业部","合肥站前路营业部","盐城市第一营业部") then 分中心 = "上海分中心";
	else if branch_name in ("杭州建国北路营业部","宁波市第一营业部","邵阳市第一营业部") then 分中心 = "浙闽分中心";
	else if branch_name in ("广州市林和西路营业部","惠州第一营业部","南宁市第一营业部","汕头市第一营业部","海口市第一营业部") then 分中心 = "广州分中心";
	else if branch_name in ("呼和浩特市第一营业部","北京市第一营业部","天津市第一营业部") then 分中心 = "北京分中心";
	else if branch_name in ("成都天府国际营业部","武汉市第一营业部","贵阳市第一营业部") then 分中心 = "成都分中心";
	else if branch_name in ("乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部","兰州市第一营业部" ) then 分中心 = "乌鲁木齐分中心";
	else if branch_name in ("福州五四路营业部","厦门市第一营业部","佛山市第一营业部","湛江市第一营业部","银川市第一营业部") then 分中心 = "已关门店1";
	else if branch_name in ("苏州市第一营业部","怀化市第一营业部","郑州市第一营业部","深圳市第一营业部","赤峰市第一营业部","红河市第一营业部","江门市业务中心",'南通市业务中心',
	"南京市第一营业部","重庆市第一营业部","南京市业务中心","昆明市第一营业部") then 分中心 = "已关门店2";

if BRANCH_NAME in ("上海福州路营业部","合肥站前路营业部","盐城市第一营业部","杭州建国北路营业部",
	"宁波市第一营业部","邵阳市第一营业部" ,"广州市林和西路营业部","惠州第一营业部","南宁市第一营业部","海口市第一营业部","汕头市第一营业部") then 区域="南区";
	else if BRANCH_NAME in ("呼和浩特市第一营业部","北京市第一营业部","成都天府国际营业部",
	"武汉市第一营业部","贵阳市第一营业部","乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部","兰州市第一营业部","天津市第一营业部") then 区域="北区";
	else if BRANCH_NAME in ("苏州市第一营业部","怀化市第一营业部","郑州市第一营业部","深圳市第一营业部","赤峰市第一营业部","红河市第一营业部","江门市业务中心",'南通市业务中心',
	"南京市第一营业部","重庆市第一营业部","南京市业务中心","福州五四路营业部","厦门市第一营业部","佛山市第一营业部","湛江市第一营业部","银川市第一营业部","昆明市第一营业部") then 区域="已关门店汇总";

rename BRANCH_NAME=维度;
drop date;
run;
proc sql;
create table zd_qy as
select 区域 as 维度,sum(累计进件量) as 累计进件量,
sum(累计回退量) as 累计回退量,
sum(累计通过量) as 累计通过量,
sum(累计放款量) as 累计放款量,
sum(累计放款合同金额) as 累计放款合同金额 from  zd_pr(where=(区域^="")) group by 区域 ;
quit;
proc sql;
create table zd_fzx as
select 分中心 as 维度,sum(累计进件量) as 累计进件量,
sum(累计回退量) as 累计回退量,
sum(累计通过量) as 累计通过量,
sum(累计放款量) as 累计放款量,
sum(累计放款合同金额) as 累计放款合同金额 from  zd_pr(where=(分中心^="")) group by 分中心 ;
quit;
data zd;
set zd_pr(drop=区域 分中心) zd_qy zd_fzx;
run;

data zd_hk_pr;
set payment_daily;
format 分中心 区域 整体 $20.;
if  营业部 = "上海第二营业部" then 营业部 = "上海福州路营业部";
if 营业部 in ("上海福州路营业部","合肥站前路营业部","盐城市第一营业部") then 分中心 = "上海分中心";
	else if 营业部 in ("杭州建国北路营业部","宁波市第一营业部","邵阳市第一营业部") then 分中心 = "浙闽分中心";
	else if 营业部 in ("广州市林和西路营业部","惠州第一营业部","南宁市第一营业部","汕头市第一营业部","海口市第一营业部") then 分中心 = "广州分中心";
	else if 营业部 in ("呼和浩特市第一营业部","北京市第一营业部","天津市第一营业部") then 分中心 = "北京分中心";
	else if 营业部 in ("成都天府国际营业部","武汉市第一营业部","贵阳市第一营业部") then 分中心 = "成都分中心";
	else if 营业部 in ("乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部","兰州市第一营业部" ) then 分中心 = "乌鲁木齐分中心";
	else if 营业部 in ("福州五四路营业部","厦门市第一营业部","佛山市第一营业部","湛江市第一营业部","银川市第一营业部") then 分中心 = "已关门店1";
	else if 营业部 in ("苏州市第一营业部","怀化市第一营业部","郑州市第一营业部","深圳市第一营业部","赤峰市第一营业部","红河市第一营业部","江门市业务中心",'南通市业务中心',
	"南京市第一营业部","重庆市第一营业部","南京市业务中心","昆明市第一营业部") then 分中心 = "已关门店2";

if 营业部 in ("上海福州路营业部","合肥站前路营业部","盐城市第一营业部","杭州建国北路营业部",
	"宁波市第一营业部","邵阳市第一营业部" ,"广州市林和西路营业部","惠州第一营业部","南宁市第一营业部","海口市第一营业部","汕头市第一营业部") then 区域="南区";
	else if 营业部 in ("呼和浩特市第一营业部","北京市第一营业部","成都天府国际营业部",
	"武汉市第一营业部","贵阳市第一营业部","乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部","兰州市第一营业部","天津市第一营业部") then 区域="北区";
	else if 营业部 in ("苏州市第一营业部","怀化市第一营业部","郑州市第一营业部","深圳市第一营业部","赤峰市第一营业部","红河市第一营业部","江门市业务中心",'南通市业务中心',
	"南京市第一营业部","重庆市第一营业部","南京市业务中心","福州五四路营业部","厦门市第一营业部","佛山市第一营业部","湛江市第一营业部","银川市第一营业部","昆明市第一营业部") then 区域="已关门店汇总";

if 区域 in ("南区","北区","已关门店汇总") then 整体="全国";
run;
proc sql;
create table zd_hk_yyb as
select 营业部 as 维度,
sum(还款_当日应扣款合同) as 还款_当日应扣款合同,
sum(还款_当日扣款失败合同) as 还款_当日扣款失败合同,
sum(贷款余额_1月前_C) as 贷款余额_1月前_C ,
sum(还款_M1合同贷款余额)/sum(贷款余额_1月前_C) as c_m1 format=percent8.2,
sum(还款_从未逾期新增M1合同贷款余额)/sum(贷款余额_1月前_C) as 新增c_m1 format=percent7.2,
sum(贷款余额_1月前_M1) as 贷款余额_1月前_M1,
sum(还款_M1M2贷款余额) as 还款_M1M2贷款余额,
sum(还款_M2合同贷款余额)/sum(贷款余额_2月前_C) as c_m2 format=percent7.2,
sum(贷款余额_1月前_M2_r) as 贷款余额_1月前_M2,
sum(还款_M2M3贷款余额) as 还款_M2M3贷款余额
from zd_hk_pr(where=(cut_date=&dt.))
group by 营业部;quit;
proc sql;
create table zd_hk_fzx as
select 分中心 as 维度,
sum(还款_当日应扣款合同) as 还款_当日应扣款合同,
sum(还款_当日扣款失败合同) as 还款_当日扣款失败合同,
sum(还款_M1合同贷款余额)/sum(贷款余额_1月前_C) as c_m1 format=percent8.2,
sum(还款_从未逾期新增M1合同贷款余额)/sum(贷款余额_1月前_C) as 新增c_m1 format=percent7.2,
sum(贷款余额_1月前_M1) as 贷款余额_1月前_M1,
sum(还款_M1M2贷款余额) as 还款_M1M2贷款余额,
sum(还款_M2合同贷款余额)/sum(贷款余额_2月前_C) as c_m2 format=percent7.2,
sum(贷款余额_1月前_M2_r) as 贷款余额_1月前_M2,
sum(还款_M2M3贷款余额) as 还款_M2M3贷款余额
from zd_hk_pr(where=(cut_date=&dt.))
group by 分中心;quit;
proc sql;
create table zd_hk_qy as
select 区域 as 维度,
sum(还款_当日应扣款合同) as 还款_当日应扣款合同,
sum(还款_当日扣款失败合同) as 还款_当日扣款失败合同,
sum(还款_M1合同贷款余额)/sum(贷款余额_1月前_C) as c_m1 format=percent8.2,
sum(还款_从未逾期新增M1合同贷款余额)/sum(贷款余额_1月前_C) as 新增c_m1 format=percent7.2,
sum(贷款余额_1月前_M1) as 贷款余额_1月前_M1,
sum(还款_M1M2贷款余额) as 还款_M1M2贷款余额,
sum(还款_M2合同贷款余额)/sum(贷款余额_2月前_C) as c_m2 format=percent7.2,
sum(贷款余额_1月前_M2_r) as 贷款余额_1月前_M2,
sum(还款_M2M3贷款余额) as 还款_M2M3贷款余额
from zd_hk_pr(where=(cut_date=&dt.))
group by 区域;quit;
proc sql;
create table zd_hk_qg as
select 整体 as 维度,
sum(还款_当日应扣款合同) as 还款_当日应扣款合同,
sum(还款_当日扣款失败合同) as 还款_当日扣款失败合同,
sum(还款_M1合同贷款余额)/sum(贷款余额_1月前_C) as c_m1 format=percent8.2,
sum(还款_从未逾期新增M1合同贷款余额)/sum(贷款余额_1月前_C) as 新增c_m1 format=percent7.2,
sum(贷款余额_1月前_M1) as 贷款余额_1月前_M1,
sum(还款_M1M2贷款余额) as 还款_M1M2贷款余额,
sum(还款_M2合同贷款余额)/sum(贷款余额_2月前_C) as c_m2 format=percent7.2,
sum(贷款余额_1月前_M2_r) as 贷款余额_1月前_M2,
sum(还款_M2M3贷款余额) as 还款_M2M3贷款余额
from zd_hk_pr(where=(cut_date=&dt.))
group by 整体;quit;
data zd_hk1;
set zd_hk_yyb zd_hk_qy zd_hk_qg zd_hk_fzx;
run;
proc sql;
create table zd_lsl_yyb as
select 营业部 as 维度,
sum(还款_当日流入15加合同分母) as 流失合同分母,
sum(还款_当日流入15加合同) as 流失合同分子
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 营业部;quit;
proc sql;
create table zd_lsl_qy as
select 区域 as 维度,
sum(还款_当日流入15加合同分母) as 流失合同分母,
sum(还款_当日流入15加合同) as 流失合同分子
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 区域;quit;
proc sql;
create table zd_lsl_fzx as
select 分中心 as 维度,
sum(还款_当日流入15加合同分母) as 流失合同分母,
sum(还款_当日流入15加合同) as 流失合同分子
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 分中心;quit;
proc sql;
create table zd_lsl_qg as
select 整体 as 维度,
sum(还款_当日流入15加合同分母) as 流失合同分母,
sum(还款_当日流入15加合同) as 流失合同分子
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 整体;quit;
data zd_hk2;
set zd_lsl_yyb zd_lsl_qy zd_lsl_qg zd_lsl_fzx;
run;
proc sql;
create table zd_lsl7_yyb as
select 营业部 as 维度,
sum(还款_当日流入7加合同分母) as 流失合同分母_,
sum(还款_当日流入7加合同) as 流失合同分子_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 营业部;quit;
proc sql;
create table zd_lsl7_qy as
select 区域 as 维度,
sum(还款_当日流入7加合同分母) as 流失合同分母_,
sum(还款_当日流入7加合同) as 流失合同分子_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 区域;quit;
proc sql;
create table zd_lsl7_fzx as
select 分中心 as 维度,
sum(还款_当日流入7加合同分母) as 流失合同分母_,
sum(还款_当日流入7加合同) as 流失合同分子_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 分中心;quit;
proc sql;
create table zd_lsl7_qg as
select 整体 as 维度,
sum(还款_当日流入7加合同分母) as 流失合同分母_,
sum(还款_当日流入7加合同) as 流失合同分子_
from zd_hk_pr(where=(cut_date^=&pde. and cut_date<=&dt.))
group by 整体;quit;
data zd_hk3;
set zd_lsl7_yyb zd_lsl7_qy zd_lsl7_qg zd_lsl7_fzx;
run;
proc sql;
create table zd_hk as
select a.*,b.流失合同分母_,b.流失合同分子_,c.流失合同分母,c.流失合同分子,d.累计进件量,d.累计回退量,d.维度 as 维度c,
d.累计通过量,d.累计放款量,d.累计放款合同金额 from zd_hk1 as a
left join zd_hk3 as b on a.维度=b.维度
left join zd_hk2 as c on a.维度=c.维度
full join zd as d on a.维度=d.维度;
quit;
data zd_hk;
set zd_hk;
if 维度C^="" and 维度="" then 维度=维度C;
array nums _numeric_;
do over nums;
if nums=. then nums=0;
end;
run;

data branch1;
set branch end=last;
call symput ("dept_"||compress(_n_),compress(营业部));
row=_n_+7;
call symput("row_"||compress(_n_),compress(row));
if last then call symput("lpn",compress(_n_));
run;
%macro city_table();
%do i =1 %to &lpn.;

filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c6:r&&row_&i..c7";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 累计进件量 累计回退量;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c12:r&&row_&i..c13";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 累计通过量 累计放款量;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c15:r&&row_&i..c15";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 累计放款合同金额;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c18:r&&row_&i..c19";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 还款_当日应扣款合同 还款_当日扣款失败合同;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c21:r&&row_&i..c22";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 流失合同分母_ 流失合同分子_;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c24:r&&row_&i..c25";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 流失合同分母 流失合同分子;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c30:r&&row_&i..c31";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put C_M1 新增c_m1;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c33:r&&row_&i..c34";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 贷款余额_1月前_M1 还款_M1M2贷款余额 ;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c39:r&&row_&i..c39";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put C_M2 ;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r&&row_&i..c42:r&&row_&i..c43";
data _null_;set zd_hk(where=(维度="&&dept_&i"));file DD;put 贷款余额_1月前_M2 还款_M2M3贷款余额 ;run;
%end;
%mend;
%city_table();
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r58c30:r58c31";
data _null_;set zd_hk(where=(维度="全国"));file DD;put C_M1 新增c_m1;run;
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r58c39:r58c39";
data _null_;set zd_hk(where=(维度="全国"));file DD;put C_M2 ;run;

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

prime_key=1;

run;
*-----------------------------------------------------------------每周一的过件数和通过率-------------------------------------------------------------------------------------*;

%macro gjs_monday_1;
%if &week.=1  %then %do;

data daata;
set  check_result(where=(批核状态 in ("ACCEPT","REFUSE"))keep=apply_code 拒绝 通过 check_date 批核状态);
if &dt.-6<=check_date<=&dt.;
run;
proc sql;
create table daata1(where=(not kindex(DESIRED_PRODUCT,"RF"))) as
select a.*,b.branch_name,b.DESIRED_PRODUCT from daata as a
left join apply_dept as b on a.apply_code=b.apply_code;
quit;
proc sql;
create table  daata2 as
select branch_name,count(*) as 过件数,sum(通过) as 通过数,calculated 通过数/calculated 过件数 as 通过率 format=percent7.2 from daata1 
group by branch_name ;
quit;

proc sql;
create table daata3 as select a.*,b.* from daata2 as a right join branch as b on a.branch_name = b.营业部 ;quit;
/*proc sort data = daata3 (drop = branch_name);by id ; run;*/




/*%macro gjs_monday_jx;*/
/*%if   &dt.-6<=&end_date.<=&dt. %then %do;*/
/**/
/*data daata;*/
/*set  check_result(where=(批核状态 in ("ACCEPT","REFUSE"))keep=apply_code 拒绝 通过 check_date 批核状态);*/
/*/*绩效月再跑整个绩效月的*/*/
/*if &fk_month_begin.<=check_date<=&end_date.;*/
/*run;*/
/*proc sql;*/
/*create table daata1(where=(not kindex(DESIRED_PRODUCT,"RF"))) as*/
/*select a.*,b.branch_name,b.DESIRED_PRODUCT from daata as a*/
/*left join apply_dept as b on a.apply_code=b.apply_code;*/
/*quit;*/
/*proc sql;*/
/*create table  daata2 as*/
/*select branch_name,count(*) as 过件数,sum(通过) as 通过数,calculated 通过数/calculated 过件数 as 通过率 format=percent7.2 from daata1 */
/*group by branch_name ;*/
/*quit;*/
/**/
/*proc sql;*/
/*/*/*create table daata3 as select a.*,b.* from daata2 as a right join branch as b on a.branch_name = b.营业部 ;
/*quit;*/*/*/*/
/*proc sort data = daata3 (drop = branch_name);
/*by id ; run;*/*/
/**/
/*%end;*/
/*%mend;*/
/*%gjs_monday_jx;*/;

data daata;
set  check_result(where=(批核状态 in ("ACCEPT","REFUSE"))keep=apply_code 拒绝 通过 check_date 批核状态);
if &dt.-6<=check_date<=&dt.;
run;
proc sql;
create table daata1(where=(not kindex(DESIRED_PRODUCT,"RF"))) as
select a.*,b.branch_name,b.DESIRED_PRODUCT from daata as a
left join apply_dept as b on a.apply_code=b.apply_code;
quit;
proc sql;
create table  daata2 as
select branch_name,count(*) as 过件数,sum(通过) as 通过数,calculated 通过数/calculated 过件数 as 通过率 format=percent7.2 from daata1 
group by branch_name ;
quit;

proc sql;
create table daata3 as select a.*,b.* from daata2 as a right join branch as b on a.branch_name = b.营业部 ;quit;
/*proc sort data = daata3 (drop = branch_name);by id ; run;*/


/*x  "F:\A_offline_zky\A_offline\daily\日监控\营业部日监控报表.xlsx"; */
filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet1!r64c21:r110c24";
data _null_;set daata2;file DD;put BRANCH_NAME  过件数 通过数 通过率 ;run;

%end;
%mend;
%gjs_monday_1;
