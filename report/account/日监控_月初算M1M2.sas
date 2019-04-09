/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/**/
/*libname repayFin "E:\guan\中间表\repayfin";*/
/*libname yc "E:\guan\中间表\yc";*/
/**/
/*proc import datafile="E:\guan\日监控临时报表\配置表.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/

proc sort data=repayfin.payment_daily;by CONTRACT_no cut_date;run;
data cs;
set repayfin.payment_daily;
if contract_no='C2018101613583597025048' then delete;*库热西·马合木提不用催收,剔除分母分子;
if contract_no='C2017121414464569454887' then delete;*蒋楠委外客户不用催收,剔除分母分子;
if contract_no='C2017111716235470079023' and month='201904' then delete;*王丽青4月份做帐太迟，4月份不计算分母分子,剔除分母分子;
if 还款_当日扣款失败合同 = 1;
last_oddays=lag(od_days);
last_还款_当日扣款失败合同=lag(还款_当日扣款失败合同);
by CONTRACT_no cut_date;
if first.contract_no then do ;last_oddays=od_days;last_贷款余额=贷款余额;last_还款_当日扣款失败合同=还款_当日扣款失败合同;end;
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
if branch_code = "13" then 营业部 = "上海福州路营业部";
format 营业部_ $40.;
if kindex(营业部,"深圳")  then 营业部_="深圳市第一营业部";
else if kindex(营业部,"江门")  then 营业部_="江门市业务中心";
else if kindex(营业部,"佛山") then 营业部_="佛山市第一营业部";
else if kindex(营业部,"盐城") then 营业部_="盐城市第一营业部";
else if kindex(营业部,"湛江") then 营业部_="湛江市第一营业部";
else if kindex(营业部,"武汉") then 营业部_="武汉市第一营业部";
else if kindex(营业部,"红河") then 营业部_="红河市第一营业部";
else if kindex(营业部,"贵阳") then 营业部_="贵阳市第一营业部";
else if kindex(营业部,"宁波") then 营业部_="宁波市第一营业部";
else if kindex(营业部,"库尔勒") then 营业部_="库尔勒市第一营业部";
else 营业部_=营业部;

format 分中心 区域 整体 $20.;
if  营业部 = "上海第二营业部" then 营业部 = "上海福州路营业部";
if 营业部 in ("上海福州路营业部","合肥站前路营业部","盐城市第一营业部") then 分中心 = "上海分中心";
	else if 营业部 in ("杭州建国北路营业部","宁波市第一营业部","邵阳市第一营业部") then 分中心 = "浙闽分中心";
	else if 营业部 in ("广州市林和西路营业部","惠州第一营业部","南宁市第一营业部","汕头市第一营业部","海口市第一营业部") then 分中心 = "广州分中心";
	else if 营业部 in ("呼和浩特市第一营业部","北京市第一营业部","天津市第一营业部") then 分中心 = "北京分中心";
	else if 营业部 in ("成都天府国际营业部","昆明市第一营业部","武汉市第一营业部","贵阳市第一营业部") then 分中心 = "成都分中心";
	else if 营业部 in ("乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部","兰州市第一营业部" ) then 分中心 = "乌鲁木齐分中心";
	else if 营业部 in ("福州五四路营业部","厦门市第一营业部","佛山市第一营业部","湛江市第一营业部","银川市第一营业部") then 分中心 = "已关门店1";
	else if 营业部 in ("苏州市第一营业部","怀化市第一营业部","郑州市第一营业部","深圳市第一营业部","赤峰市第一营业部","红河市第一营业部","江门市业务中心",'南通市业务中心',
	"南京市第一营业部","重庆市第一营业部","南京市业务中心") then 分中心 = "已关门店2";

if 营业部 in ("上海福州路营业部","合肥站前路营业部","盐城市第一营业部","杭州建国北路营业部",
	"宁波市第一营业部","邵阳市第一营业部" ,"广州市林和西路营业部","惠州第一营业部","南宁市第一营业部","海口市第一营业部","汕头市第一营业部") then 区域="南区";
	else if 营业部 in ("呼和浩特市第一营业部","北京市第一营业部","成都天府国际营业部","昆明市第一营业部",
	"武汉市第一营业部","贵阳市第一营业部","乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部","兰州市第一营业部","天津市第一营业部") then 区域="北区";
	else if 营业部 in ("苏州市第一营业部","怀化市第一营业部","郑州市第一营业部","深圳市第一营业部","赤峰市第一营业部","红河市第一营业部","江门市业务中心",'南通市业务中心',
	"南京市第一营业部","重庆市第一营业部","南京市业务中心","福州五四路营业部","厦门市第一营业部","佛山市第一营业部","湛江市第一营业部","银川市第一营业部") then 区域="已关门店汇总";

if 区域 in ("南区","北区","已关门店汇总") then 整体="全国";
drop 营业部;
rename 营业部_=营业部;
run;


proc sql ;
create table cm_1 as select 营业部 as 纬度,sum(贷款余额_M1)/sum(贷款余额_1月前_C) as cm1,sum(贷款余额_M1) as 贷款余额_M1,sum(贷款余额_1月前_C) as 贷款余额_1月前_C from cs_1 group by 营业部;
quit;
proc sql ;
create table cm_2 as select 区域 as 纬度,sum(贷款余额_M1)/sum(贷款余额_1月前_C) as cm1,sum(贷款余额_M1) as 贷款余额_M1,sum(贷款余额_1月前_C) as 贷款余额_1月前_C from cs_1 group by 区域;
quit;
proc sql ;
create table cm_3 as select 整体 as 纬度,sum(贷款余额_M1)/sum(贷款余额_1月前_C)as cm1,sum(贷款余额_M1) as 贷款余额_M1,sum(贷款余额_1月前_C) as 贷款余额_1月前_C  from cs_1 group by 整体;
quit;
proc sql ;
create table cm_4 as select 分中心 as 纬度,sum(贷款余额_M1)/sum(贷款余额_1月前_C)as cm1,sum(贷款余额_M1) as 贷款余额_M1,sum(贷款余额_1月前_C) as 贷款余额_1月前_C  from cs_1 group by 分中心;
quit;



data cm_;
set cm_1 cm_2 cm_3 cm_4;
drop 贷款余额_M1;
run ;
/*为了修复两次计算M1的情况，所以贷款余额_M1 以payment的为准，payment的是上月底的贷款余额_M1，payment_daily的是上上月底的贷款余额_M1*/
/*下面的代码之所以选的贷款余额_1月前_M1是由于选的是payment_daily的cut_date是昨天，cut_dat是昨天的贷款余额_1月前_M1就是cut_date是上月底的上上月底的贷款余额_M1，含义是正确的*/
proc sql;
create table cm__ as
select a.*,b.贷款余额_1月前_M1 as 贷款余额_M1
from cm_ as a
left join zd_hk1 as b
on a.纬度=b.维度;
quit;

proc sql;
create table cm as
select 
纬度,cm1,贷款余额_M1,贷款余额_1月前_C,
sum(贷款余额_M1)/sum(贷款余额_1月前_C)as cm1_调整后
from cm__
group by 纬度;
quit;

proc sql;
create table cmt_1 as select a.* , b.cm1,b.cm1_调整后,b.贷款余额_M1 from branch as a left join cm as b on a.营业部 = b.纬度;quit;

proc sort data = cmt_1;
by id;run;



proc sql ;
create table cm2_1 as select 营业部 as 纬度,sum(贷款余额_M2)/sum(贷款余额_2月前_C) as cm2 ,sum(贷款余额_M2) as 贷款余额_M2 from cs_1 group by 营业部;
quit;
proc sql ;
create table cm2_2 as select 区域 as 纬度,sum(贷款余额_M2)/sum(贷款余额_2月前_C) as cm2,sum(贷款余额_M2) as 贷款余额_M2 from cs_1 group by 区域;
quit;
proc sql ;
create table cm2_3 as select 整体 as 纬度,sum(贷款余额_M2)/sum(贷款余额_2月前_C) as cm2 ,sum(贷款余额_M2) as 贷款余额_M2  from cs_1 group by 整体;
quit;
proc sql ;
create table cm2_4 as select 分中心 as 纬度,sum(贷款余额_M2)/sum(贷款余额_2月前_C) as cm2 ,sum(贷款余额_M2) as 贷款余额_M2 from cs_1 group by 分中心;
quit;

data cm2;
set cm2_1 cm2_2 cm2_3 cm2_4;
run ;
proc sql;
create table cmt_2 as select a.* , b.cm2,b.贷款余额_M2 from branch as a left join cm2 as b on a.营业部 = b.纬度;

proc sort data = cmt_2;
by id;run;



/*proc freq data = cs_1;*/
/*table  区域;*/
/*run ;*/
/**/
/*data cs_4;*/
/*set cs_1;*/
/*if 区域=  " ";*/
/*run ;*/

/*看cmt_1 cmt_2 cm cm2看全国*/


/*算贷款余额_2月前_C，在日监控SHEET3里展示*/
/*libname repayFin "F:\A_offline_zky\kangyi\data_download\历史数据\中间表201712\repayAnalysis";*/
/*proc sql;*/
/*create table tst2 as select 营业部, sum(贷款余额_1月前_C) from repayfin.payment_daily(where=(cut_date=mdy(12,31,2017))) group by 营业部 ;quit;*/
/*proc sql;*/
/*create table tst2 as select 营业部, sum(贷款余额_2月前_C) from repayfin.payment_daily(where=(cut_date=&dt.)) group by 营业部 ;quit;*/

/*x  "F:\A_offline_zky\A_offline\daily\日监控\营业部日监控报表.xlsx"; */
/*filename DD DDE "EXCEL|[营业部日监控报表.xlsx]Sheet3!r6c6:r37c7";*/
/*data _null_;set Tst2;file DD;put 营业部 _TEMG001;run;*/



/*V分行绩效用*/
proc sql ;
create table cm_5 as select contract_no ,营业部,sum(贷款余额_M1)/sum(贷款余额_1月前_C)as cm1,sum(贷款余额_M1) as 贷款余额_M1,sum(贷款余额_1月前_C) as 贷款余额_1月前_C  from cs_1 group by contract_no,营业部;
quit;

proc sql;
create table cm__1 as
select a.*,b.贷款余额_1月前_M1 as 贷款余额_M1
from cm_5 as a
left join repayfin.payment_daily(where=(cut_date=&dt.)) as b
on a.contract_no=b.contract_no and a.营业部=b.营业部;
quit;

proc sql;
create table cm5_ as
select 
contract_no ,营业部,贷款余额_M1,贷款余额_1月前_C,
sum(贷款余额_M1)/sum(贷款余额_1月前_C)as cm1_调整后
from cm__1
group by contract_no ,营业部;
quit;

