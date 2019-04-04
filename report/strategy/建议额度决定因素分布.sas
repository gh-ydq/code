/*额度公式*/
option compress = yes validvarname = any;
***********************************************************************************************;
*代码用到及输出的数据位置;
libname dta "\\ts\share\Datamart\中间表\daily";
libname approval "\\ts\share\Datamart\原表\approval";
libname account "\\ts\share\Datamart\原表\account";
libname urule odbc datasrc=urule;

FILENAME export1 "E:\company_file\报表\新审批公式\审批客户.xlsx" ENCODING="utf-8";
FILENAME export2 "E:\company_file\报表\新审批公式\客户建议额度分布情况.xlsx" ENCODING="utf-8";
***********************************************************************************************;

data _null_;
format dt nt yymmdd10.;
dt = today() - 1;
nt = today();
pde=intnx("month",nt,-1,"e");
call symput("nt", dhms(nt,0,0,0));
week = weekday(nt);
call symput('week',week);
run;


/*客户信息*/
data apply_gre;
set dta.customer_info(keep=apply_code 天启分 进件时间 check_end check_date group_Level PROPOSE_LIMIT_first PROPOSE_LIMIT_final approve_产品 
							微粒贷额度 核实收入 进件 通过 批核金额_终审 负债率
					 where=(天启分^='')); /*只保留后面用到的字段和数据，节省时间*/

进件月份=substr(compress(put(进件时间,yymmdd10.),"-"),1,6);
input_week =week(进件时间);

array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run ;  

data model_score;
set urule.rule011param(keep=apply_code created_date model_score_level
					  where=(created_date <&nt.));
run;

proc sort data = model_score ;by apply_code  descending created_date;run;

proc sort data = model_score out = model_score_urule nodupkey;by apply_code;run;


proc sql;
create table model_score_con as select a.*,b.* from 
model_score_urule as a left join apply_gre as b on a.apply_code =b.apply_code;
quit;

proc sort data = model_score_con nodupkey;by apply_code;run;

/*保留审批通过客户，和终审节点处客户评分*/
data test;
set model_score_con;
if check_end=1 ;
if check_date>mdy(11,05,2018);
if model_score_level^='F' and model_score_level^="";

if group_Level="A" and model_score_level="A" then 分组="1A";
	else if model_score_level="A" then 分组="2A";
	else if model_score_level="B" then 分组="3B";
	else if model_score_level="C" then 分组="4C";
	else if model_score_level="D" then 分组="5D";
	else if model_score_level="E" then 分组="6E";

if approve_产品="E微贷-自雇" then approve_产品="E微贷-无社保";

if PROPOSE_LIMIT_first>0  and kindex(approve_产品,"E微贷") then  倍数=PROPOSE_LIMIT_final/微粒贷额度;
else if PROPOSE_LIMIT_first>0  and approve_产品 in("E网通","U贷通") then  倍数=PROPOSE_LIMIT_final/核实收入;

else 倍数=-1;

if approve_产品="U贷通" then do ;
	if 分组="1A" then do; 建议倍数=18;最大金额= 150000; 负债率限制=10 ;end;
	else if 分组="2A" then do; 建议倍数=16;最大金额= 120000; 负债率限制=10 ;end;
	else if 分组="3B" then do; 建议倍数=14;最大金额= 100000; 负债率限制=8 ;end;
	else if 分组="4C" then do; 建议倍数=12;最大金额= 70000; 负债率限制=7 ;end;
	else if 分组="5D" then do; 建议倍数=10;最大金额= 50000; 负债率限制=6 ;end;
	else if 分组="6E" then do; 建议倍数=8;最大金额= 30000; 负债率限制=5 ;end;
end;

else if approve_产品="E网通" then do ;
	if 分组="1A" then do; 建议倍数=16;最大金额= 120000; 负债率限制=10 ;end;
	else if 分组="2A" then do; 建议倍数=14;最大金额= 100000; 负债率限制=10 ;end;
	else if 分组="3B" then do; 建议倍数=12;最大金额= 80000; 负债率限制=8 ;end;
	else if 分组="4C" then do; 建议倍数=10;最大金额= 60000; 负债率限制=6 ;end;
	else if 分组="5D" then do; 建议倍数=8;最大金额= 40000; 负债率限制=4 ;end;
	else if 分组="6E" then do; 建议倍数=6;最大金额= 30000; 负债率限制=3 ;end;
end;

else if approve_产品="E微贷" then do ;
	if 分组="1A" then do; 建议倍数=10;最大金额= 120000; 负债率限制=8 ;end;
	else if 分组="2A" then do; 建议倍数=8;最大金额= 100000; 负债率限制=8 ;end;
	else if 分组="3B" then do; 建议倍数=6;最大金额= 80000; 负债率限制=6 ;end;
	else if 分组="4C" then do; 建议倍数=5;最大金额= 60000; 负债率限制=5 ;end;
	else if 分组="5D" then do; 建议倍数=4;最大金额= 40000; 负债率限制=4 ;end;
	else if 分组="6E" then do; 建议倍数=3;最大金额= 30000; 负债率限制=3 ;end;
end;

else if approve_产品="E微贷-无社保" then do ;
	if 分组="1A" then do; 建议倍数=10;最大金额= 100000; 负债率限制=8 ;end;
	else if 分组="2A" then do; 建议倍数=8;最大金额= 80000; 负债率限制=8 ;end;
	else if 分组="3B" then do; 建议倍数=6;最大金额= 70000; 负债率限制=6 ;end;
	else if 分组="4C" then do; 建议倍数=5;最大金额= 50000; 负债率限制=5 ;end;
	else if 分组="5D" then do; 建议倍数=4;最大金额= 30000; 负债率限制=4 ;end;
	else if 分组="6E" then do; 建议倍数=3;最大金额= 20000; 负债率限制=3 ;end;
end;
if 最大金额=PROPOSE_LIMIT_final  then 决定因素="最大金额";
else if 倍数>=建议倍数 then 决定因素="倍数";
else 决定因素='负债率';
/*if 核实收入>80000 then delete;*/
run;

/*-----------------------------------建议额度决定因素分布情况----------------------------------*/
proc tabulate data = test(where=(进件时间>=mdy(11,06,2018) and approve_产品 in("E网通","U贷通","E微贷" ,"E微贷-无社保"))) out=table1_1;
class approve_产品 分组 进件月份 决定因素;
var 进件;
table (approve_产品 ALL)*(分组 ALL), (进件月份 ALL)*(决定因素 ALL)*进件*(sum*f=8. pctn<分组 ALL>)/misstext='0' box="产品分组分布";
run;

proc sql ;
create table table1 as select  approve_产品,分组,进件月份,决定因素,count(*) as 个数 
from test(where=(进件时间>=mdy(11,06,2018) and approve_产品 in("E网通","U贷通","E微贷" ,"E微贷-无社保") and 通过=1)) group by
approve_产品,分组,进件月份,决定因素;quit;

proc sql;
create table table2 as select approve_产品,分组,进件月份,count(*) as 人数,mean(批核金额_终审) as 件均 ,mean(PROPOSE_LIMIT_final) as 平均建议额度
,mean(倍数) as 平均倍数,mean(核实收入) as 平均收入,mean(微粒贷额度)as 平均微粒贷额度 ,mean(负债率) as 平均负债率
from test(where=(进件时间>=mdy(11,06,2018) and approve_产品 in("E网通","U贷通","E微贷" ,"E微贷-无社保")and 通过=1)) group by
approve_产品,分组,进件月份;quit;

proc transpose data =table1 out=table1_1(drop=_name_);
by approve_产品 分组 进件月份;
id 决定因素;
run;

/*通过客户建议额度分布情况*/
data table_;
merge table1_1 table2;
by approve_产品 分组 进件月份;
run;

/*数据导出*/
proc export  data=test(where=(进件时间>=mdy(11,06,2018) and approve_产品 in("E网通","U贷通","E微贷" ,"E微贷-无社保")))
OUTFILE= export1 DBMS=EXCEL REPLACE;SHEET="客户"; run;

proc export data = table_
outfile = export2
dbms = xlsx replace;
run;




