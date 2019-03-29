
/*1.持续高产销售:近30天进件量大于等于近30天整体平均进件量的5倍
2.突增高产销售:该销售近15天进件量与次15天的进件量之差大于等于近30天整体平均进件量的2倍;*/

option validvarname=any;
option compress=yes;
libname appRaw odbc  datasrc=approval_nf;
libname approval "D:\share\Datamart\原表\approval";
libname account "D:\share\Datamart\原表\account";
libname dta "D:\share\Datamart\中间表\daily";
libname his "D:\share\反欺诈数据\更新数据";


data macrodate;
format stdate midate eddata  ntd  nt yymmdd10.;
stdate=intnx("month",today(),-1,"b");
midate=intnx("month",today(),-1,"m");
eddata=intnx("month",today(),-1,"e");
ntd =intnx("day",today(),-30,"s");

call symput("ed",eddata);
call symput("std",stdate);;
call symput("md",midate);
call symput("ntd",ntd);
call symput("dt",today()-1);
call symput("dt_mon",intnx("month",today(),-2,"b"));
/*call symput("d_mon",intnx("month",today(),-2,"b"));*/
run;


/*问题销售*/
data problem_sales;
set appRaw.problem_sales;
run;


data apply_info;
set appraw.apply_info(where =(branch_name^=""));
keep apply_code SALES_CODE SALES_NAME;
run;
data contract;
set dta.app_loan_info(keep =apply_code name 放款日期);
if 放款日期^=.;
run;


proc sort data =contract nodupkey ;by apply_code;run;
proc sort data =apply_info nodupkey;by apply_code;run;

data apply_contract;
merge contract(in=a) apply_info;
by apply_code;
if a ;
run;

/*近30天的放款数据*/
proc sql;
create table nearly_thirty(keep= apply_code name  SALES_CODE SALES_NAME 放款日期)
as select a.*,b.* from apply_contract as a inner join problem_sales as b on a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

proc sort data = nearly_thirty;by SALES_NAME 放款日期;run;

/*进件信息*/
data apply;
set dta.app_loan_info;
if  &std.<=进件时间<=&ed.;
if &std.<=进件时间<=&ed. then 近三十天进件=1;
if &md.<=进件时间<=&ed. then  近十五天进件=1;
if &std.<=进件时间<&md. then 次十五天进件=1;
keep apply_code name 进件时间 近三十天进件  近十五天进件 次十五天进件;
run;
proc sort data = apply;by apply_code ;run;
data contact;
merge apply(in=a) apply_info;
by apply_code;
if a ;
run;

proc sql;
create table nearly_thirty_ind  as select SALES_CODE,SALES_NAME,sum(近三十天进件)as 三十天进件数
,sum(近十五天进件)as 近十五天进件数,sum(次十五天进件)as 次十五天进件数
from contact(where=(SALES_CODE^="1")) group by SALES_NAME,SALES_CODE;quit;

proc sql;
create table nearly_thirty_ave  as select SALES_CODE,SALES_NAME,三十天进件数,近十五天进件数,次十五天进件数,avg(三十天进件数)as 平均进件数 
from nearly_thirty_ind ;quit;
/*持续高产销售*/
data sustain_high_sales;
set nearly_thirty_ave(where=(sum(三十天进件数,-5*平均进件数)>=0 ));
run;

data sustain_high_sales1;
set sustain_high_sales;
format 标签$20.;
标签="持续高产销售";
keep SALES_CODE SALES_NAME 标签 三十天进件数 平均进件数 近十五天进件数 次十五天进件数;
run;

proc sql;
create table sustain_high_sales_cli(where=(放款日期>=&std.)) as select a.*,b.apply_code,b.name,b.放款日期
from sustain_high_sales1 as a inner join apply_contract as b on a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

proc sort data= sustain_high_sales_cli;by SALES_NAME;run;
/*突增高产销售*/
data sudden_high_sales;
set nearly_thirty_ave(where=(sum(近十五天进件数,-次十五天进件数,-2*平均进件数)>=0 ));
run;

data sudden_high_sales1;
set sudden_high_sales;
format 标签$20.;
标签="突增高产销售";
keep SALES_CODE SALES_NAME 标签 三十天进件数 平均进件数 近十五天进件数 次十五天进件数;
run;

proc sql;
create table sudden_high_sales_cli(where=(放款日期>=&std.)) as select a.*,b.apply_code,b.name,b.放款日期
from sudden_high_sales1 as a inner join apply_contract as b on a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

proc sort data= sudden_high_sales_cli;by SALES_NAME;run;


data problem_sales_cli;
set nearly_thirty;
format 标签$20.;
标签="问题销售";
run;

/*对公还款*/
data company_account_pay_register;
set account.company_account_pay_register;
if CLEAR_DATE>&ntd.   and kindex(contract_no,"C");
if DATA_SOURCE not in (90,91) ;
apply_code = tranwrd(contract_no , "C","PL");
run;

proc sql;
create table company_account(keep=   SALES_CODE SALES_NAME)
as select a.*,b.* from apply_info as a inner join company_account_pay_register as b on a.apply_code =b.apply_code;quit;

proc sort data = company_account nodupkey;by SALES_CODE SALES_NAME;run;

proc sql;
create table nearly_thirty1(keep= apply_code name  SALES_CODE SALES_NAME 放款日期)
as select a.*,b.* from apply_contract as a inner join company_account as b on 
a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

data problem_sales_cli2;
set nearly_thirty1;
format 标签$20.;
标签="名下客户还款为对公";
run;
proc sort data = problem_sales_cli2; by SALES_NAME;run;
data sals ;
set  problem_sales_cli sudden_high_sales_cli sustain_high_sales_cli problem_sales_cli2;
contract_no = tranwrd(apply_code,"PL","C");
run;

proc sql;
create table sals_all as select  a.*,b.od_days,b.od_days_ever,c.branch_name,c.approve_产品,b.身份证号码  from sals as a
left join repayfin.payment_daily(where=(cut_date=&dt.)) as b on a.contract_no = b.contract_no 
left join dta.app_loan_info as c on a.apply_code = c.apply_code ;quit;
proc sort data = approval.apply_emp out = apply_emp;by apply_code ;run;

data sals_all;
merge  sals_all(in = a) apply_emp(in=b);
by apply_code;
if a ;
format 是否退休 $10.;
if kindex( title,"退休") or POSITION ="297" then 是否退休="是";
else 是否退休="否";
if od_days>0 then 状态="当前逾期";
else if od_days_ever>0 then 状态="历史逾期";
else 状态="正常还款";
if 放款日期>= &dt_mon.;
if kindex(branch_name,"业务中心") =0;
format 更新时间 yymmdd10.;
更新时间= &std.;
销售="销售";
run;
proc sort data = sals_all;by 标签 SALES_CODE ;run;



 data hissals_all;
 set his.sals_all;
 run;

data sals_all1;
set hissals_all sals_all;
run;

proc sort data = sals_all1 nodupkey;by apply_code 标签;run;

 data his.sals_all;
 set sals_all;
 run;





/*进件月份*/

data problem_sales;
set problem_sales;
问题销售="是";
run;

proc sql;
create table high_slaes_contact as select   SALES_CODE, SALES_NAME,三十天进件数,平均进件数
,近十五天进件数,次十五天进件数,branch_name,标签,count(*) as 放款数  from sals_all(where=(标签 in("持续高产销售","突增高产销售") )) group by SALES_CODE, SALES_NAME,三十天进件数,平均进件数
,近十五天进件数,次十五天进件数,branch_name,标签;quit;


proc sql;
create table high_slaes1 as select  a.*,b.问题销售  from high_slaes_contact as a left join problem_sales as b on a.SALES_CODE = b.SALES_CODE;quit;


/*异常还款客户*/

proc sql;
create table company_account1(where=(放款日期>mdy(8,1,2017))keep = apply_code name  放款日期 CLEAR_DATE REPAY_AMOUNT REMARK )
as select a.*,b.* from contract as a right join company_account_pay_register as b on a.apply_code =b.apply_code;quit;

proc sort data = company_account1  ; by 放款日期;run;

data company_account1;
set company_account1;
format 标签$20.;
标签="异常还款客户";
run;

proc sort data = approval.apply_emp out = apply_emp;by apply_code ;run;
proc sort data = company_account1 ;by apply_code;run;
proc sort data = repayfin.payment_daily(where=(营业部 ^="APP")) out = payment_daily;by contract_no;run;
proc sort data = dta.app_loan_info out = app_loan_info;by apply_code;run;
data payment_daily;
set payment_daily(where=(cut_date=&dt.));
apply_code = tranwrd(contract_no,"C","PL");
drop 放款日期;
run;

data company_account;
merge  company_account1(in = a) apply_emp(in=b) apply_info payment_daily app_loan_info;
by apply_code;
if a ;
format 是否退休 $10.;
if kindex( title,"退休") or POSITION ="297" then 是否退休="是";
else 是否退休="否";
format 更新时间 yymmdd10.;
更新时间  =&dt.+1;
run;
data company;
set his.company_account;
标记=1;
if 更新时间^=  &nt.;
run;

data company_account1;
set company company_account;
run;

proc sort data = company_account1 nodupkey;by 标签 apply_code SALES_CODE;run;

data company_account2;
set company_account1;
if 标记=1 then delete;
异常还款="异常还款";
run;


filename DD DDE "EXCEL|[反欺诈数据.xlsx]异常还款!r2c1:r1000c20" notab;
data _null_;set company_account2;file DD;put 异常还款 '09'x branch_name '09'x 标签  '09'x approve_产品 '09'x SALES_CODE '09'x SALES_NAME 
'09'x 放款日期 '09'x apply_code '09'x 身份证号码 '09'x name  '09'x 是否退休 
  '09'x od_days '09'x od_days_ever '09'x CLEAR_DATE '09'x REPAY_AMOUNT '09'x REMARK;run;


/*异常还款*/
data his.company_account;
set company_account1;
drop 标记;

run;


x  "D:\share\反欺诈数据\反欺诈数据_月报.xlsx"; 

filename DD DDE "EXCEL|[反欺诈数据_月报.xlsx]销售!r2c1:r10000c20" notab;
data _null_;set sals_all;file DD;put 销售 '09'x  branch_name  '09'x  标签  '09'x  approve_产品 '09'x SALES_CODE '09'x SALES_NAME  '09'x 放款日期 
'09'x apply_code '09'x  身份证号码 '09'x NAME 
'09'x od_days '09'x od_days_ever '09'x 状态 '09'x 是否退休;run;

filename DD DDE "EXCEL|[反欺诈数据_月报.xlsx]销售_2!r2c1:r100c20" notab;
data _null_;set high_slaes1;file DD;put SALES_CODE '09'x SALES_NAME '09'x 三十天进件数 '09'x 平均进件数 '09'x 近十五天进件数 
'09'x 次十五天进件数'09'x branch_name '09'x 标签 '09'x 问题销售 '09'x 放款数;run;
