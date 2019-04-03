options compress =yes validvarname = any ;

libname credit odbc datasrc = credit;
libname approval  odbc datasrc =approval;

data a;
format last_date month_begin  yymmdd10.;
last_date = today()-1;
month_begin = intnx('month',last_date,0);
call symput("dt",last_date);
call symput("mb",month_begin);
run;
%put &dt. &mb.;

/*这里写的目的是获取进件时间和进件数量*/
/*以首次录入复核完成的时间作为进件时间*/
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "录入复核" and action_ = "COMPLETE")); /*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
input_complete=1;/*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
keep bussiness_key_ create_time_ input_complete;
rename bussiness_key_ = apply_code create_time_ = apply_time;
if APPLY_CODE in("PL2017080710404340041165" "PL2017080711092188055701" "PL2017080817340444920689" ) then delete;
/*2017年8月重复续贷信息要删除*/
run;
proc sort data = apply_time dupout = a nodupkey; by apply_code apply_time; run;
proc sort data = approval.apply_info nodupkey out =apply_info; by apply_code; run;
data apply_time1(keep = apply_code 进件月份 进件时间 进件数);
merge apply_time(in = a) apply_info(in = b);
by apply_code;
format 进件时间 yymmdd10.;
进件月份 = put(datepart(apply_time), yymmn6.);
进件时间 = datepart(apply_time);
进件数 =1;
run;

data apply_time2;
set apply_time1;
if input("20180501",yymmdd9.)<=进件时间<=&dt.;
run;
proc sort  data=apply_time2;by 进件月份;run;



/*规则命中的拼接*/
data early_warning_info(keep = apply_no content  level  hit_id_new);
set approval.early_warning_info;
if SOURCE ="urule";
/*表示从字串content中以|为分隔符提取第2个字串。*/
hit_id = scan(content,2,"|");
if length(hit_id) =5 then hit_id_new = compress(substr(hit_id,1,2)|| substr(hit_id,4,2));
else if level="R" and length(hit_id) >4 then hit_id_new=substr(hit_id,3,4); 
else if kindex(content,"SPTS") then hit_id_new = compress(substr(hit_id,1,2)|| substr(hit_id,5,2));
/*获取SP的字段类型*/
else if kindex(content,"SP") then hit_id_new =substr(hit_id,1,4);
else if hit_id ="TS" then do;
	if kindex(content,"合肥") then hit_id_new= "SP03";
	if kindex(content,"郑州") then hit_id_new="RJ01";
	if kindex(content,"武汉") then hit_id_new="RJ04";
	if kindex(content,"乌鲁木齐") then hit_id_new="SP05";
	if kindex(content,"昆明") then hit_id_new="RJ02";
	end;
else if kindex(content,"R743") then hit_id_new ="R743";
else if kindex(content,"R753") then hit_id_new ="R753";
else if kindex(content,"R754") then hit_id_new ="R754";
else if kindex(content,"R755") then hit_id_new="R755";
else if kindex(content,"R756") then hit_id_new ="R756";
else if kindex(content,"R757") then hit_id_new ="R757";
else hit_id_new=hit_id;
run;
/*拼接进件时间*/
proc sql noprint;
create table result as
select a.*,b.进件时间
from early_warning_info as a 
left join apply_time1 as b on a.apply_no = b.apply_code;
quit;

data result1;
set result;
month = substr(compress(put(进件时间,yymmdd10.),"-"),1,6);
where input("20180501",yymmdd9.)<=进件时间 <=&dt.;
辅助=1;
run;



/*---------------写进件数量 按照月和天数来写--------------*/
/*进件数的分布*/
/*按照月份来*/
proc tabulate data = apply_time2 out= apply_month(drop= _TYPE_  _TABLE_  _PAGE_  N);
class 进件月份;
var 进件数;
table 进件月份*进件数(N);
run;
proc transpose data = apply_month out=apply_month1;
id 进件月份;
var 进件数_SUM;
run;
/*按照天数来写*/
data apply_daily;
set apply_time2;
where &mb. <= 进件时间 <= &dt.;
run;
proc tabulate data = apply_daily out= apply_daily1(drop= _TYPE_  _TABLE_  _PAGE_  N);
class  进件时间;
var 进件数;
table 进件时间*进件数*(N);
run;
proc transpose data = apply_daily1 out=apply_daily2;
id 进件时间;
var 进件数_N;
run;
/*---------------------------------The End---------------------------------*/

/*-------------------------写命中规则数量 按照月和天数来写-------------------*/
/*月份分布情况*/
proc sql noprint;
create table rule_month as 
select month,hit_id_new,辅助 from result1 order by hit_id_new;
run;
proc tabulate data = rule_month out= rule_month1(drop= _TYPE_  _TABLE_  _PAGE_  N);
class month hit_id_new;
var 辅助;
table hit_id_new,month*辅助*(n);
run;
proc transpose data=rule_month1 out=rule_month2;
by hit_id_new;
id month;
var 辅助_N;
run;

/*按照天数来进行分布其对应的规则的命中数*/
data rule_daily;
set result1;
where &mb. <= 进件时间<=&dt.;
run;
proc sql noprint;
create table rule_daily2 as 
select 进件时间,hit_id_new,辅助 from rule_daily order by hit_id_new;
run;

proc tabulate data = rule_daily2 out= rule_daily3(drop= drop= _TYPE_  _TABLE_  _PAGE_  N);
class 进件时间 hit_id_new;
var 辅助;
table hit_id_new,进件时间*辅助*(n);
run;
proc transpose data=rule_daily3 out=daily4;
by hit_id_new;
id 进件时间;
var 辅助_N;
run;

/*--------------------------The End----------------------------------------*/
/*进行拼接 首先是月份的数据拼接在一起*/
data reasult_month(drop=_NAME_);
set  apply_month1  rule_month2;
run;

/*再接着是按照天数来拼接在一起*/
data reasult_daily(drop =_NAME_);
set apply_daily2 daily4;
run;

/*处理缺失值*/

data reasult_month;
set reasult_month;
array num{*} _numeric_;
do i  =1 to dim(num);
if missing(num{i}) then num{i} =0;
end;
run;


data reasult_daily;
set reasult_daily;
array num{*} _numeric_;
do i  =1 to dim(num);
if missing(num{i}) then num{i} =0;
end;
run;


/*将文档保存到*/
FILENAME export "e:\company_file\报表\规则命中\month.xlsx" ENCODING="utf-8";
PROC EXPORT DATA= reasult_month
            OUTFILE= export
            DBMS=xlsx label REPLACE;
RUN;

FILENAME export "e:\company_file\报表\规则命中\daily.xlsx" ENCODING="utf-8";
PROC EXPORT DATA= reasult_daily
            OUTFILE= export
            DBMS=xlsx  label REPLACE;
RUN;



