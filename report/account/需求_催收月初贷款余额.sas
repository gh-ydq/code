*每个月给赵婷燕和琨哥的;
*存在逾期31天的,因为一个月有31天，刚好月初1号是账单日;
*因为后期新增了一个前2个月的M2客户明细，跑7-31的当前C-M2的分子;
*月初跑好新的一个月的payment_daily之后即可跑这个代码;

/*option validvarname=any;*/
/*option compress=yes;*/
/*libname repayFin "E:\guan\中间表\repayfin";*/
/*libname res odbc  datasrc=res_nf;*/
/*libname approval "E:\guan\原数据\approval";*/
/*libname account 'E:\guan\原数据\account';*/

*后面还有导出文件的路径代码;

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

data dept_;
set repayFin.payment_daily(where=(cut_date=&month_begin.));
if 还款_上月底M1=1 and 营业部^="APP";
format apply_code $50.;
apply_code=tranwrd(contract_no,"C","PL");
if 资金渠道^="";
format 资金渠道 资金渠道1 $100.;
if 资金渠道 in ("xyd1","xyd2") then 资金渠道1="小雨点";
else if 资金渠道 in ("bhxt1","bhxt2") then 资金渠道1="渤海信托";
else if 资金渠道 in ("mindai1") then 资金渠道1="民贷";
else if 资金渠道 in ("ynxt1","ynxt2","ynxt3") then 资金渠道1="云南信托";
else if 资金渠道 in ("jrgc1") then 资金渠道1="金融工厂";
else if 资金渠道 in ("irongbei1") then 资金渠道1="融贝";
else if 资金渠道 in ("fotic3","fotic2") then 资金渠道1="单一出借人";
else if 资金渠道 in ("haxt1") then 资金渠道1="华澳信托";
else if 资金渠道 in ("p2p") then 资金渠道1="中科财富";
else if 资金渠道 in ("jsxj1") then 资金渠道1="晋商消费金融";
else if 资金渠道 in ("lanjingjr1") then 资金渠道1="蓝鲸金融";
else if 资金渠道 in ("tsjr1") then 资金渠道1="通善金融";
else if 资金渠道 in ("rx1") then 资金渠道1="容熙";
else if 资金渠道 in ("yjh1","yjh2") then 资金渠道1="益菁汇";
else if 资金渠道 in ("hapx1") then 资金渠道1="华澳鹏欣";
drop 资金渠道;
keep  CONTRACT_NO 营业部 贷款余额_1月前_M1 客户姓名 apply_code od_days  资金渠道1; 
rename 资金渠道1=资金渠道;
run;

proc sql;
create table dept2_1 as
select a.* ,b.CURR_RECEIVE_CAPITAL_AMT+CURR_RECEIVE_INTEREST_AMT as 期供
from dept_(where=(资金渠道 not in ("晋商消费金融"))) as a
left join account.repay_plan as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_1 nodupkey ;by contract_no;run;
/*proc sql;*/
/*create table dept2_2 as*/
/*select a.* ,b.BQ_PRINCIPAL+BQ_INTEREST_FEE as 期供 */
/*from dept_(where=(资金渠道 in ("xyd1"))) as a*/
/*left join repayfin.Tttrepay_plan_xyd as b*/
/*on a.contract_no=b.contract_no;*/
/*quit;*/
/*proc sort data=dept2_2 nodupkey ;by contract_no;run;*/

proc sql;
create table dept2_3 as
select a.* ,b.PSPRCPAMT+PSNORMINTAMT as 期供 
from dept_(where=(资金渠道 in ("晋商消费金融"))) as a
left join repayfin.Tttrepay_plan_js as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_3 nodupkey ;by contract_no;run;

data dept;
set dept2_1  dept2_3;
run;
proc sort data=dept nodupkey out=aa;by contract_no;run;


data province;
set res.optionitem(where = (groupCode = "province"));
keep itemCode itemName_zh;
run;
data city;
set res.optionitem(where = (groupCode = "city"));
keep itemCode itemName_zh;
run;
data region;
set res.optionitem(where = (groupCode = "region"));
keep itemCode itemName_zh;
run;

data apply_base;
set approval.apply_base(keep = apply_code PHONE1 RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_TYPE
							PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION LOCAL_RES_YEARS EDUCATION MARRIAGE GENDER RESIDENCE_ADDRESS PERMANENT_ADDRESS );
/*RESIDENCE-现住址 PERMANENT-户籍地址*/
run;

proc sql;
create table apply_base1 as
select a.*,b.itemName_zh as 居住省, c.itemName_zh as 居住市, d.itemName_zh as 居住区,
			e.itemName_zh as 户籍省, f.itemName_zh as 户籍市, g.itemName_zh as 户籍区
from apply_base as a
left join province as b on a.RESIDENCE_PROVINCE = b.itemCode
left join city as c on a.RESIDENCE_CITY = c.itemCode
left join region as d on a.RESIDENCE_DISTRICT = d.itemCode
left join province as e on a.PERMANENT_ADDR_PROVINCE = e.itemCode
left join city as f on a.PERMANENT_ADDR_CITY = f.itemCode
left join region as g on a.PERMANENT_ADDR_DISTRICT = g.itemCode;
quit;

data apply_emp;
set approval.apply_emp(keep = apply_code COMP_NAME position comp_type COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT START_DATE_4_PRESENT_COMP
							CURRENT_INDUSTRY WORK_YEARS COMP_ADDRESS TITLE);
run;
proc sql;
create table apply_emp1 as
select a.*, b.itemName_zh as 工作省, c.itemName_zh as 工作市, d.itemName_zh as 工作区
			
from apply_emp as a
left join province as b on a.COMP_ADDR_PROVINCE = b.itemCode
left join city as c on a.COMP_ADDR_CITY = c.itemCode
left join region as d on a.COMP_ADDR_DISTRICT = d.itemCode;
quit;
proc sql;
create table dept1(drop=apply_code) as 
select a.*,b.居住省,b.居住市,b.居住区,b.RESIDENCE_ADDRESS as 居住详细地址,
b.户籍省,b.户籍市,b.户籍区,b.PERMANENT_ADDRESS as 户籍详细地址,
c.工作省,c.工作市,c.工作区,c.COMP_ADDRESS as 工作详细地址
from dept as a
left join apply_base1 as b on a.apply_code=b.apply_code
left join apply_emp1 as c on a.apply_code=c.apply_code;
quit;
*M1M2结果;
data dept1;
set dept1;
attrib _all_ label="";
run;
*移至最后;
/*PROC EXPORT DATA=dept1 OUTFILE= "E:\guan\日监控临时报表\特殊需求\dept1.xls" DBMS=EXCEL REPLACE;SHEET="Sheet1";run;*/

*每个月给琨哥的;
data dept_k;
set repayFin.payment_daily(where=(cut_date=&month_begin.));
if 还款_上月底M2=1 and 营业部^="APP";
format apply_code $50.;
apply_code=tranwrd(contract_no,"C","PL");
if 资金渠道^="";
format 资金渠道 资金渠道1 $100.;
if 资金渠道 in ("xyd1","xyd2") then 资金渠道1="小雨点";
else if 资金渠道 in ("bhxt1","bhxt2") then 资金渠道1="渤海信托";
else if 资金渠道 in ("mindai1") then 资金渠道1="民贷";
else if 资金渠道 in ("ynxt1","ynxt2","ynxt3") then 资金渠道1="云南信托";
else if 资金渠道 in ("jrgc1") then 资金渠道1="金融工厂";
else if 资金渠道 in ("irongbei1") then 资金渠道1="融贝";
else if 资金渠道 in ("fotic3","fotic2") then 资金渠道1="单一出借人";
else if 资金渠道 in ("haxt1") then 资金渠道1="华澳信托";
else if 资金渠道 in ("p2p") then 资金渠道1="中科财富";
else if 资金渠道 in ("jsxj1") then 资金渠道1="晋商消费金融";
else if 资金渠道 in ("lanjingjr1") then 资金渠道1="蓝鲸金融";
else if 资金渠道 in ("tsjr1") then 资金渠道1="通善金融";
else if 资金渠道 in ("rx1") then 资金渠道1="容熙";
else if 资金渠道 in ("yjh1","yjh2") then 资金渠道1="益菁汇";
else if 资金渠道 in ("hapx1") then 资金渠道1="华澳鹏欣";
drop 资金渠道;
keep  CONTRACT_NO 营业部 贷款余额_1月前_M2_r 客户姓名 apply_code od_days  资金渠道1; 
rename 资金渠道1=资金渠道 贷款余额_1月前_M2_r=贷款余额_1月前_M2;
run;

proc sql;
create table dept2k_1 as
select a.* ,b.CURR_RECEIVE_CAPITAL_AMT+CURR_RECEIVE_INTEREST_AMT as 期供
from dept_k(where=(资金渠道 not in ("晋商消费金融"))) as a
left join account.repay_plan as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2k_1 nodupkey ;by contract_no;run;
/*proc sql;*/
/*create table dept2_2 as*/
/*select a.* ,b.BQ_PRINCIPAL+BQ_INTEREST_FEE as 期供*/
/*from dept_(where=(资金渠道 in ("xyd1"))) as a*/
/*left join repayfin.Tttrepay_plan_xyd as b*/
/*on a.contract_no=b.contract_no;*/
/*quit;*/
/*proc sort data=dept2_2 nodupkey ;by contract_no;run;*/

proc sql;
create table dept2k_3 as
select a.* ,b.PSPRCPAMT+PSNORMINTAMT as 期供
from dept_k(where=(资金渠道 in ("晋商消费金融"))) as a
left join repayfin.Tttrepay_plan_js as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2k_3 nodupkey ;by contract_no;run;

data deptk;
set dept2k_1  dept2k_3;
run;
proc sort data=deptk nodupkey out=aa;by contract_no;run;
proc sql;
create table dept1k(drop=apply_code) as 
select a.*,b.居住省,b.居住市,b.居住区,b.RESIDENCE_ADDRESS as 居住详细地址,
b.户籍省,b.户籍市,b.户籍区,b.PERMANENT_ADDRESS as 户籍详细地址,
c.工作省,c.工作市,c.工作区,c.COMP_ADDRESS as 工作详细地址
from deptk as a
left join apply_base1 as b on a.apply_code=b.apply_code
left join apply_emp1 as c on a.apply_code=c.apply_code;
quit;
*M2M3结果;
data dept1k;
set dept1k;
attrib _all_ label="";
run;

/*PROC EXPORT DATA=dept1 OUTFILE= "E:\guan\日监控临时报表\特殊需求\dept1.xls" DBMS=EXCEL REPLACE;SHEET="Sheet1";run;*/
/*PROC EXPORT DATA=dept1k OUTFILE= "E:\guan\日监控临时报表\特殊需求\dept1.xls" DBMS=EXCEL REPLACE;SHEET="Sheet2";run;*/

