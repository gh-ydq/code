option validvarname=any;option compress=yes;
option compress = yes  validvarname = any;
libname approval 'E:\guan\原数据\approval';
libname account 'E:\guan\原数据\account';
libname repayFin "E:\guan\中间表\repayfin";

/*x 'E:\guan\日监控临时报表\日逾期\日逾期报表.xls';*/
/**/
/*proc import datafile="E:\guan\日监控临时报表\配置表1.xls"*/
/*out=branch(where=(营业部^="")) dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\日监控临时报表\日逾期\日逾期报表.xls"*/
/*out=branc(where=(product_name^="")) dbms=excel replace;*/
/*SHEET="产品$";*/
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
if branch_code = "6" then branch_name = "上海福州路营业部";
else if branch_code = "13" then branch_name = "上海福州营业部";
else if branch_code = "16" then branch_name = "广州市林和西路营业部";
else if branch_code = "14" then branch_name = "合肥站前路营业部";
else if branch_code = "15" then branch_name = "福州五四路营业部";
else if branch_code = "17" then branch_name = "成都天府国际营业部";
else if branch_code = "50" then branch_name = "惠州第一营业部";
else if branch_code = "55" then branch_name = "海口市第一营业部";
else if branch_code = "57" then branch_name = "杭州建国北路营业部";
else if branch_code = "56" then branch_name = "厦门市第一营业部";
else if kindex(branch_name,"深圳")  then branch_name="深圳市第一营业部";
else if kindex(branch_name,"江门")  then branch_name="江门市业务中心";
else if kindex(branch_name,"佛山")  then branch_name="佛山市第一营业部";
else if kindex(branch_name,"红河")  then branch_name="红河市第一营业部";
else if kindex(branch_name,"武汉")  then branch_name="武汉市第一营业部";
else if kindex(branch_name,"盐城")  then branch_name="盐城市第一营业部";

rename branch_name = 营业部;
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
/*total _ 每月*/
proc sql;
create table every_month as select month,count(贷款余额_C) as 正常 ,count(贷款余额_M1) as M1,count(贷款余额_M2) as M2,
count(贷款余额_M3) as M3,count(贷款余额_M4) as M4,count(贷款余额_M5) as M5,count(贷款余额_M6) as M6,count(贷款余额_M6_plus) as M6plus,count(*)as 总计,count(*)-count(贷款余额_M6_plus) as 总数
from payment_dept group by month;
quit;
proc sql;
create table every_month as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
every_month;
QUIT;
proc sql;
create table every_month_amount as select month,sum(贷款余额_C) as 正常 ,sum(贷款余额_M1) as M1,sum(贷款余额_M2) as M2,
sum(贷款余额_M3) as M3,sum(贷款余额_M4) as M4,sum(贷款余额_M5) as M5,sum(贷款余额_M6) as M6,sum(贷款余额_M6_plus) as M6plus,sum(贷款余额) as 总计
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
create table every_month_amount as select *,sum(总计 ,- M6plus) as 总数 FROM 
every_month_amount;
quit;
proc sql;
create table every_month_amount as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
every_month_amount;
QUIT;


/*total—每日*/
data payment_daily;
set repayfin.payment_daily(where=(cut_date ^=&lmd.));
if 营业部 ^="APP" and es^=1;
if pre_1m_status not in('09_ES','11_Settled');
format 正常贷款余额 M1_贷款余额 M2_贷款余额 M3_贷款余额 M4_贷款余额 M5_贷款余额 M6_贷款余额 M6plus_贷款余额;
if (od_days=0 and 还款_当日扣款失败合同 ^=1) or od_days=. then 正常贷款余额 = 贷款余额;
else if  1<=od_days<=30 or (od_days=0 and 还款_当日扣款失败合同=1) then M1_贷款余额 =贷款余额;
else if 31<=od_days<=60 then M2_贷款余额 =贷款余额;
else if 61<=od_days<=90 then M3_贷款余额= 贷款余额;
else if 91<=od_days<=120 then M4_贷款余额= 贷款余额;
else if 121<=od_days<=150 then M5_贷款余额= 贷款余额;
else if 151<=od_days<=180 then M6_贷款余额= 贷款余额;
else if 181<=od_days then M6plus_贷款余额= 贷款余额;
run;

proc sql;
create table every_day1 as select cut_date,count(正常贷款余额) as 正常 ,count(M1_贷款余额) as M1,count(M2_贷款余额) as M2,
count(M3_贷款余额) as M3,count(M4_贷款余额) as M4,count(M5_贷款余额) as M5,count(M6_贷款余额) as M6,count(M6plus_贷款余额) as M6plus,count(*)as 总计,sum(count(*),-count(M6plus_贷款余额)) as 总数
from payment_daily group by cut_date;
quit;
proc sql;
create table every_day as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
every_day1;
QUIT;

proc sql;
create table every_day_amount1 as select cut_date,sum(正常贷款余额) as 正常 ,sum(M1_贷款余额) as M1,sum(M2_贷款余额) as M2,
sum(M3_贷款余额) as M3,sum(M4_贷款余额) as M4,sum(M5_贷款余额) as M5,sum(M6_贷款余额) as M6,sum(M6plus_贷款余额) as M6plus,sum(贷款余额) as 总计
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
create table every_day_amount3 as select *,sum(总计,-M6plus) as 总数 FROM 
every_day_amount2;
quit;
proc sql;
create table every_day_amount as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
every_day_amount3;
QUIT;
/*按营业部分*/
data payment_daily_yesterday1;
set payment_daily;
if cut_date = &dt.;
run;
data payment_daily_yesterday;
set payment_daily_yesterday1;
IF kindex(营业部,"上海") THEN 营业部 = "上海福州路营业部";
format 区域  $20.;
if 营业部 in ("上海福州路营业部","合肥站前路营业部","盐城市第一营业部","杭州建国北路营业部","宁波市第一营业部","邵阳市第一营业部" ,"广州市林和西路营业部",
"惠州第一营业部","南宁市第一营业部","海口市第一营业部","汕头市第一营业部") then 区域="南区小计";

else if 营业部 in ("呼和浩特市第一营业部","北京市第一营业部","成都天府国际营业部","昆明市第一营业部",
"武汉市第一营业部","贵阳市第一营业部","乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部",
"兰州市第一营业部","天津市第一营业部") then 区域="北区小计";

else if 营业部 in ("江门市业务中心","重庆市第一营业部",'南通市业务中心',"南京市业务中心","红河市第一营业部","赤峰市第一营业部","深圳市第一营业部","郑州市第一营业部","怀化市第一营业部",
"苏州市第一营业部","南京市第一营业部","湛江市第一营业部","福州五四路营业部","厦门市第一营业部","佛山市第一营业部","银川市第一营业部") then 区域="已关门店小计";
run;
proc sql;
create table payment_daily_yesterday_dept1_1 as select 营业部 as 维度, count(正常贷款余额) as 正常 ,count(M1_贷款余额) as M1,count(M2_贷款余额) as M2,
count(M3_贷款余额) as M3,count(M4_贷款余额) as M4,count(M5_贷款余额) as M5,count(M6_贷款余额) as M6,count(M6plus_贷款余额) as M6plus,count(*)as 总计,count(*)-count(M6plus_贷款余额) as 总数 from payment_daily_yesterday group by 营业部;
quit;
proc sql;
create table payment_daily_yesterday_dept1 as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
payment_daily_yesterday_dept1_1;
QUIT;
proc sql;
create table payment_daily_yesterday_dept2_1 as select 区域 as 维度, count(正常贷款余额) as 正常 ,count(M1_贷款余额) as M1,count(M2_贷款余额) as M2,
count(M3_贷款余额) as M3,count(M4_贷款余额) as M4,count(M5_贷款余额) as M5,count(M6_贷款余额) as M6,count(M6plus_贷款余额) as M6plus,count(*)as 总计,count(*)-count(M6plus_贷款余额) as 总数 from payment_daily_yesterday group by 区域;
quit;
proc sql;
create table payment_daily_yesterday_dept2 as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
payment_daily_yesterday_dept2_1;
QUIT;
data payment_daily_yesterday_dept;
set payment_daily_yesterday_dept1 payment_daily_yesterday_dept2;
run;

proc sql;
create table day_deptamount1_1 as select 营业部 as 维度,sum(正常贷款余额) as 正常 ,sum(M1_贷款余额) as M1,sum(M2_贷款余额) as M2,
sum(M3_贷款余额) as M3,sum(M4_贷款余额) as M4,sum(M5_贷款余额) as M5,sum(M6_贷款余额) as M6,sum(M6plus_贷款余额) as M6plus,sum(贷款余额) as 总计
from payment_daily_yesterday group by 营业部 ;
quit;
data day_deptamount1_2;
set day_deptamount1_1;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table day_deptamount1_3 as select *,sum(总计, - M6plus) as 总数 FROM 
day_deptamount1_2;
quit;
proc sql;
create table day_deptamount1 as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
day_deptamount1_3;
proc sql;
create table day_deptamount2 as select 区域 as 维度,sum(正常贷款余额) as 正常 ,sum(M1_贷款余额) as M1,sum(M2_贷款余额) as M2,
sum(M3_贷款余额) as M3,sum(M4_贷款余额) as M4,sum(M5_贷款余额) as M5,sum(M6_贷款余额) as M6,sum(M6plus_贷款余额) as M6plus,sum(贷款余额) as 总计
from payment_daily_yesterday group by 区域 ;
quit;
data day_deptamount2;
set day_deptamount2;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table day_deptamount2 as select *,sum(总计, - M6plus) as 总数 FROM 
day_deptamount2;
quit;
proc sql;
create table day_deptamount2 as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
day_deptamount2;
data day_deptamount;
set day_deptamount1 day_deptamount2;
run;


data branch1;
set branch end=last;
call symput ("dept_"||compress(_n_),compress(营业部));
row=_n_+9;
call symput("row_"||compress(_n_),compress(row));
row1=_n_+58;
call symput("row1_"||compress(_n_),compress(row1));
if last then call symput("lpn",compress(_n_));
run;


%macro city_table();
%do i =1 %to &lpn.;

filename DD DDE "EXCEL|[日逾期报表.xls]按分行!r&&row_&i..c4:r&&row_&i..c15";
data _null_;set payment_daily_yesterday_dept(where=( 维度 ="&&dept_&i..")) ;file DD;put 正常 M1 M2 M3 M4 M5 M6  总计 DPD DPD3 DPD9 M6plus;run;
filename DD DDE "EXCEL|[日逾期报表.xls]按分行!r&&row1_&i..c4:r&&row1_&i..c15";
data _null_;set Day_deptamount(where=( 维度 ="&&dept_&i..")) ;file DD;put 正常 M1 M2 M3 M4 M5 M6  总计 DPD DPD3 DPD9 M6plus;run;

%end;
%mend;
%city_table();



/*按产品*/
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
if kindex(product_name,'E保通-自雇') then product_name = "E保通-自雇";
else if kindex(product_name,'E保通') then product_name = "E保通";
else if kindex(product_name,'E贷通') then product_name = "E贷通";
else if kindex(product_name,'E房通') then product_name = "E房通";
else if kindex(product_name,'E社通') then product_name = "E社通";
else if kindex(product_name,'E网通') then product_name = "E网通";
else if kindex(product_name,'E微贷') then product_name = "E微贷";
else if kindex(product_name,'U贷通') then product_name = "U贷通";
else if kindex(product_name,'E宅通') then product_name = "E宅通";
else if kindex(product_name,'E宅通-自雇') then product_name = "E宅通-自雇";
else if kindex(product_name,'Easy贷信用卡') then product_name = "Easy贷信用卡";
else if kindex(product_name,'Easy贷芝麻分') then product_name = "Easy贷芝麻分";
else if kindex(product_name,'E微贷-无社保') then product_name = "E微贷-无社保";
else if kindex(product_name,'E微贷-自雇') then product_name = "E微贷-自雇";
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
format 产品名称 $40.;
产品名称 =PRODUCT_NAME;
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
if kindex( title,"退休") or POSITION ="297";
format 产品名称 $40.;
产品名称="退休贷";
run;

data payment_account;
set payment_account retire;
run;

proc sql;
create table product_payment as select 产品名称, count(正常贷款余额) as 正常 ,count(M1_贷款余额) as M1,count(M2_贷款余额) as M2,
count(M3_贷款余额) as M3,count(M4_贷款余额) as M4,count(M5_贷款余额) as M5,count(M6_贷款余额) as M6,count(M6plus_贷款余额) as M6plus,count(*)as 总计,count(*)-count(M6plus_贷款余额) as 总数 from payment_account group by 产品名称;quit;
proc sql;
create table product_payment as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
product_payment;
QUIT;
proc sql;
create table product_payment_amount as select 产品名称,sum(正常贷款余额) as 正常 ,sum(M1_贷款余额) as M1,sum(M2_贷款余额) as M2,
sum(M3_贷款余额) as M3,sum(M4_贷款余额) as M4,sum(M5_贷款余额) as M5,sum(M6_贷款余额) as M6,sum(M6plus_贷款余额) as M6plus,sum(贷款余额) as 总计
from payment_account group by 产品名称;
quit;
data product_payment_amount;
set product_payment_amount;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;
proc sql;
create table product_payment_amount as select *,sum(总计, - M6plus) as 总数 FROM 
product_payment_amount;
quit;
proc sql;
create table product_payment_amount as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM 
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

filename DD DDE "EXCEL|[日逾期报表.xls]按产品!r&&row_&i..c2:r&&row_&i..c13";
data _null_;set product_payment(where=( 产品名称="&&dept_&i..")) ;file DD;put 正常 M1 M2 M3 M4 M5 M6  总计 DPD DPD3 DPD9 M6plus;run;
filename DD DDE "EXCEL|[日逾期报表.xls]按产品!r&&row1_&i..c2:r&&row1_&i..c13";
data _null_;set product_payment_amount(where=(产品名称="&&dept_&i..")) ;file DD;put 正常 M1 M2 M3 M4 M5 M6  总计 DPD DPD3 DPD9 M6plus;run;

%end;
%mend;
%product_table();

/*退休贷*/
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
/*if position="退休人员";*/
/*format 产品名称 $10.;*/
/*产品名称="退休贷";*/
/*run;*/




filename DD DDE "EXCEL|[日逾期报表.xls]Total!r82c2:r112c13";
data _null_;set every_day ;file DD;put  正常 M1 M2 M3 M4 M5 M6 M6plus 总计 DPD DPD3 DPD9 ;run;
filename DD DDE "EXCEL|[日逾期报表.xls]Total!r182c2:r215c13";
data _null_;set every_day_amount ;file DD;put 正常 M1 M2 M3 M4 M5 M6 M6plus 总计 DPD DPD3 DPD9 ;run;
/*每月第一天用*/
filename DD DDE "EXCEL|[日逾期报表.xls]Total!r9c2:r53c13";
data _null_;set every_month ;file DD;put 正常 M1 M2 M3 M4 M5 M6 M6plus 总计 DPD DPD3 DPD9 ;run;
filename DD DDE "EXCEL|[日逾期报表.xls]Total!r120c2:r164c13";
data _null_;set every_month_amount ;file DD;put 正常 M1 M2 M3 M4 M5 M6 M6plus 总计 DPD DPD3 DPD9 ;run;


/**/
/*/*逾期流转日报  od_days 规则更改*/*/
/*data payment_daily_2;*/
/*set repayfin.payment_daily(where=(cut_date ^=&lmd.));*/
/*if pre_1m_status not in('09_ES','11_Settled');*/
/*format 正常贷款余额 M1_贷款余额 M2_贷款余额 M3_贷款余额 M4_贷款余额 M5_贷款余额 M6_贷款余额 M6plus_贷款余额;*/
/*if (od_days=0 and 还款_当日扣款失败合同 ^=1) or od_days=. then 正常贷款余额 = 贷款余额;*/
/*else if  1<=od_days<=29 or (od_days=0 and 还款_当日扣款失败合同=1)then M1_贷款余额 =贷款余额;*/
/*else if 30<=od_days<=59 then M2_贷款余额 =贷款余额;*/
/*else if 60<=od_days<=89 then M3_贷款余额= 贷款余额;*/
/*else if 90<=od_days<=119 then M4_贷款余额= 贷款余额;*/
/*else if 120<=od_days<=149 then M5_贷款余额= 贷款余额;*/
/*else if 150<=od_days<=179 then M6_贷款余额= 贷款余额;*/
/*else if 180<=od_days then M6plus_贷款余额= 贷款余额;*/
/*run;*/
/*data daily_product1;*/
/*set payment_daily_2;*/
/*if cut_date = &dt.;*/
/*run;*/
/*data daily_product;*/
/*set daily_product1;*/
/*format 区域 整体 $20.;*/
/*if 营业部 in ("上海福州路营业部","合肥站前路营业部","广州市林和西路营业部",*/
/*"福州五四路营业部","杭州建国北路营业部","惠州第一营业部","怀化市第一营业部",*/
/*"海口市第一营业部","厦门市第一营业部","南京市第一营业部","南宁市第一营业部","郑州市第一营业部") then 区域="南区小计";*/
/*else if 营业部 in ("成都天府国际营业部","呼和浩特市第一营业部","乌鲁木齐市第一营业部",*/
/*"赤峰市第一营业部","重庆市第一营业部","昆明市第一营业部") then 区域="北区小计";*/
/*else if 营业部 in ("深圳业务中心","江门业务中心","佛山业务中心","盐城市业务中心",'南通市业务中心','武汉市业务中心*/
/*',"红河市业务中心","南京市业务中心") then 区域="渠道小计";*/
/*run;*/
/*data payment_account;*/
/*merge daily_product(in=a) payment_account1(in =b);*/
/*by CONTRACT_NO;*/
/*if a ;*/
/*format 产品名称 $10.;*/
/*产品名称 =PRODUCT_NAME;*/
/*run;*/
/**/
/**/
/**/
/*proc import datafile="F:\share\逾期流转代码\营业部_1.xls"*/
/*out=branch dbms=excel replace;*/
/*SHEET="Sheet1$";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*data branch1;*/
/*set branch end=last;*/
/*call symput ('dept_'||compress(_n_),compress(营业部));*/
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
/*x  "F:\share\逾期流转代码\日逾期流转报表.xlsx"; */
/*%macro city_product();*/
/*%do i =1 %to &lpn.;*/
/**/
/*proc sql;*/
/*create table product_payment_city1 as select 产品名称, count(正常贷款余额) as 正常 ,count(M1_贷款余额) as M1,count(M2_贷款余额) as M2,*/
/*count(M3_贷款余额) as M3,count(M4_贷款余额) as M4,count(M5_贷款余额) as M5,count(M6_贷款余额) as M6,count(M6plus_贷款余额) as M6plus,count(*)as 总计,count(*)-count(M6plus_贷款余额) as 总数 from payment_account(where=(营业部="&&dept_&i")) group by 产品名称;quit;*/
/*proc sql;*/
/*create table product_payment_city1 as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM */
/*product_payment_city1;*/
/*QUIT;*/
/*proc sql;*/
/*create table city_amount as select 产品名称,sum(正常贷款余额) as 正常 ,sum(M1_贷款余额) as M1,sum(M2_贷款余额) as M2,*/
/*sum(M3_贷款余额) as M3,sum(M4_贷款余额) as M4,sum(M5_贷款余额) as M5,sum(M6_贷款余额) as M6,sum(M6plus_贷款余额) as M6plus,sum(贷款余额) as 总计*/
/*from payment_account(where=(营业部="&&dept_&i"))  group by 产品名称;*/
/*quit;*/
/*data city_amount;*/
/*set city_amount;*/
/*array xx _numeric_;*/
/*do over xx;*/
/*if xx=. then xx=0;*/
/*end;*/
/*run;*/
/*proc sql;*/
/*create table city_amount as select *, sum(总计, - M6plus) as 总数 FROM */
/*city_amount;*/
/*quit;*/
/**/
/*proc sql;*/
/*create table city_amount as select *,M1/总数 as DPD,sum(M2,M3,M4,M5,M6)/总数 as DPD3,sum(M4,M5,M6)/总数 as DPD9 FROM */
/*city_amount;*/
/**/
/*quit;*/
/*filename DD DDE "EXCEL|[日逾期流转报表.xlsx]逾期明细_笔数!r&&totalb1_row_&i..c2:r&&totalb2_row_&i..c14";
/*data _null_;set product_payment_city1 ;file DD;put 产品名称 正常 M1 M2 M3 M4 M5 M6  总计 DPD DPD3 DPD9 M6plus;run;*/
/*filename DD DDE "EXCEL|[日逾期流转报表.xlsx]逾期明细_金额!r&&totalb1_row_&i..c2:r&&totalb2_row_&i..c14";*/
/*data _null_;set city_amount;file DD;put 产品名称 正常 M1 M2 M3 M4 M5 M6 总计 DPD DPD3 DPD9 M6plus;run;
/*%end;*/
/*%mend;*/
/**/
/*%city_product;*/




/*data payment_product;*/
/*merge payment (in = a ) payment_account1(in=b);*/
/*by contract_no;*/
/*if a;*/
/*run;*/
/*/*上月产品金额总账 坏账*/*/
/*data kan ;*/
/*set payment_daily;*/
/*if cut_date = &dt.-1;*/
/*run;*/
/**/
/**/
/*proc sql;*/
/*create table test1 as select 营业部 , sum(贷款余额) as 总计 , sum(M6plus_贷款余额) as M6plus from kan group by 营业部;*/
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
/*/*上月分行*/*/
/*data payment_befor;*/
/*set payment_daily;*/
/*if cut_date = &dt.-1;*/
/*run;*/
/*data kan2;*/
/*merge payment_befor(in=a) payment_account1(in =b);*/
/*by CONTRACT_NO;*/
/*if a ;*/
/*format 产品名称 $10.;*/
/*产品名称 =PRODUCT_NAME;*/
/*run;*/
/**/
/*proc sql;*/
/*create table test2 as select 产品名称 ,  sum(M6plus_贷款余额) as M6plus from kan2 group by 产品名称;*/
/*quit;*/
/**/
/*data test2;*/
/*set test2;*/
/*array xx _numeric_;*/
/*do over xx;*/
/*if xx=. then xx=0;*/
/*end;*/
/*/*run;*/*/


filename DD DDE "EXCEL|[日逾期报表.xls]按分行!r38c22:r57c24";*/
data _null_;
/*set test1 ;file DD;put 营业部 总计 M6plus;run;*/
/*filename DD DDE "EXCEL|[日逾期报表.xls]按产品!r28c22:r38c23";*/
/*data _null_;set test2;file DD;put 产品名称 M6plus;  run;*/
