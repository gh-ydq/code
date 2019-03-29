option compress = yes validvarname = any;
option missing = 0;
libname csdata odbc  datasrc=csdata_nf;
libname YY odbc  datasrc=res_nf;
libname account odbc datasrc = account_nf;
libname approval "D:\share\Datamart\原表\approval";
libname his "D:\share\反欺诈数据\更新数据";
libname dta "D:\share\Datamart\中间表\daily";
libname repayfin "D:\share\Datamart\中间表\repayAnalysis";

data _null_;
format dt yymmdd10.;
 dt = today() - 1;
 db=intnx("month",dt,0,"b");
 nd = today();
weekf=intnx('week',dt,0);
call symput("nt", nd);
call symput("db",db);
if weekday(dt)=1 then call symput("dt",dt-2);
else call symput("dt",dt);
call symput("weekf",weekf);
run;

data ca_staff;
set yy.ca_staff;
id1=compress(put(id,$20.));
run;

proc sql;
create table cs_table1(where=( kindex(contract_no,"C"))) as
select a.CALL_RESULT_ID,a.CALL_ACTION_ID,a.DIAL_TELEPHONE_NO,a.DIAL_LENGTH,a.CONTACTS_NAME,a.PROMISE_REPAYMENT,a.PROMISE_REPAYMENT_DATE,
       a.CREATE_TIME,a.REMARK,c.userName,d.CONTRACT_NO,d.CUSTOMER_NAME
from csdata.Ctl_call_record as a 
left join csdata.Ctl_task_assign as b on a.TASK_ASSIGN_ID=b.id
left join ca_staff as c on b.emp_id=c.id1
left join csdata.Ctl_loaninstallment as d on a.OVERDUE_LOAN_ID=d.id;
quit;

proc sql;
create table cs_table_ta as
select a.*,b.itemName_zh as RESULT from cs_table1 as a
left join yy.optionitem as b on a.CALL_RESULT_ID=b.itemCode;
quit;
proc sort data=cs_table_ta nodupkey;by CREATE_TIME CONTRACT_NO;run;

data cs_table1_tab;
set cs_table_ta;
format 联系日期 yymmdd10.;
联系日期=datepart(CREATE_TIME);

run;
/*以最后一次联系情况为参考*/
proc sort data = cs_table1_tab  ;by CONTRACT_NO descending 联系日期 ; run;
proc sort data = cs_table1_tab out = cs_table1_tab1(where=(DIAL_TELEPHONE_NO^="" )) nodupkey;by CONTRACT_NO DIAL_TELEPHONE_NO CONTACTS_NAME;run;
/*目前失联的客户*/
data cs_table1_tab2;
set cs_table1_tab1;
if CALL_ACTION_ID ="OUTBOUND" and CONTACTS_NAME=CUSTOMER_NAME and RESULT in ("来电提醒","无人接听","占线关机","无法接通","空号错号","拒接挂线","欠费停机","BSL半失联"
,"NOA无人应答","QSL全失联","失联") then 失联=1;else 失联=0;
if 失联=1;
apply_code = tranwrd(contract_no,"C","PL" );
run;
/*所有客户*/
data payment_daily(keep= contract_no 客户姓名 od_days cut_date apply_code);
set repayfin.payment_daily(where=( cut_date =&dt. and es^=1));
apply_code = tranwrd(contract_no,"C","PL" );

run;

data apply_contract;
set approval.apply_contacts;
run;

data account_info( keep = apply_code ch_name BORROWER_TEL_ONE);
set account.account_info(where=(BRANCH_CODE^="105"));
apply_code=tranwrd(contract_no,"C","PL");
run;

data apply_emp;
set approval.apply_emp;
comp_name = compress(comp_name,"");
format 单位电话 $25.;
if COMP_TEL =""  then 单位电话="无";
else if COMP_TEL_AREA="" or find(COMP_TEL,"-") then 单位电话 = compress(COMP_TEL,"-");
else  单位电话 = compress(COMP_TEL_AREA||COMP_TEL );
format contact_name $45.;
contact_name = "单位";
keep apply_code 单位电话 contact_name;
run;

proc sql;
create table  contact_name as select a.apply_code,a.客户姓名,a.od_days,b.CONTACT_NAME,b.MOBILE_NO  from 
payment_daily as a left join apply_contract as b on a.apply_code = b.apply_code;quit;

proc sql;
create table own_phone as select a.apply_code,a.客户姓名,a.od_days,b.ch_name as CONTACT_NAME,b.BORROWER_TEL_ONE as MOBILE_NO from
payment_daily as a left join account_info as b on a.apply_code = b.apply_code;quit;

proc sql;
create table comp_phone as select a.apply_code,a.客户姓名,a.od_days,b.contact_name ,b.单位电话 as MOBILE_NO from
payment_daily as a left join apply_emp as b on a.apply_code = b.apply_code;quit;


data name_phone;
set contact_name own_phone comp_phone;
run;

proc sort data = name_phone nodupkey ;by apply_code CONTACT_NAME MOBILE_NO; run;
/*正常还款客户*/
data normal_cos_phone ;
set name_phone(where=(od_days<1));
run;
/*逾期客户*/
data od_cos_phone;
set name_phone (where=(od_days>=15 ));
run;
 
/*失联客户*/
proc sql;
create table lc_cos_phone as select  a.* from name_phone as a right join cs_table1_tab2 as b on a.apply_code = b.apply_code;quit;


/*proc sql;*/
/*create table cs_kehu(where=(0<od_days and 联系日期<=&dt.-3)) as  select a.*,b.od_days,b.cut_date from cs_table1_tab2 as a*/
/*left join payment_daily as b on a.contract_no = b.contract_no and a.CUSTOMER_NAME =b.客户姓名;quit;*/
/*data cs_kehu1;*/
/*set cs_kehu;*/
/*apply_code = tranwrd(contract_no,"C","PL" );*/
/*run;*/

/*data cs_table1_tab3;*/
/*set cs_table1_tab2;*/
/*apply_code = tranwrd(contract_no,"C","PL" );*/
/*run;*/
/*客户的 所有电话信息*/

/*失联客户关联*/
proc sql;
create table Fraud_suspicion_phone(where=(MOBILE_NO not in ("","无","..","4006099600","089800000000","02188888888","087100000000","95598","12333","047695598","00") 
and kindex(MOBILE_NO,"00000") =0  and od>=15
))  as select a.*,b.客户姓名 as 失联人姓名,b.apply_code as 关联人编号,b.od_days as od from normal_cos_phone as a inner join lc_cos_phone as b on
a.apply_code >b.apply_code and a.MOBILE_NO = b.MOBILE_NO ;quit;
proc sort data = Fraud_suspicion_phone nodupkey ;by 客户姓名 失联人姓名;run;

data Fraud_suspicion_phone;
set Fraud_suspicion_phone;
format 标签 $20.;
标签 = "关联失联电话";

drop od_days;
run;


/*逾期客户关联正常客户*/
proc sql ;
create table Fraud_suspicion_phone2(where=(MOBILE_NO not in ("","无","..","4006099600","089800000000","02188888888","087100000000","95598","12333","047695598","00") 
and  kindex(MOBILE_NO,"00000") =0 and CONTACT_NAME not in ("电费","电费查询")))  
as select a.*,b.od_days as od ,b.客户姓名 as 失联人姓名,b.apply_code as 关联人编号
from normal_cos_phone as a inner join  od_cos_phone as b on a.MOBILE_NO =b.MOBILE_NO;quit;
proc sort data = Fraud_suspicion_phone2 nodupkey ;by 客户姓名 contact_name 失联人姓名;run;
data Fraud_suspicion_phone2;
set Fraud_suspicion_phone2;
format 标签 $20.;
标签 = "关联逾期客户";

drop od_days; 
run;

data Fraud_suspicion;
set Fraud_suspicion_phone  Fraud_suspicion_phone2;
format 更新时间 yymmdd10.;
更新时间=  &nt.;
run;
proc sql;
create table Fraud_suspicion as select a.*,c.放款日期 from Fraud_suspicion as a  left join dta.app_loan_info as c on a.apply_code = c.apply_code ;quit;


data Fraud;
set his.Fraud;
标记=1;
if 更新时间^=  &nt.;
run;
proc sort data = Fraud out =Fraud_1 nodupkey;by apply_code ;run;
data Fraud_suspicion1;
set Fraud Fraud_suspicion;
run;

proc sort data = Fraud_suspicion1 nodupkey;by 标签 apply_code 关联人编号 CONTACT_NAME ;run;

data Fraud_suspicion2;
set Fraud_suspicion1;
if 标记=1 
then delete;
催收="催收";
drop 标记;
run;

proc sql ;
create table Fraud_suspicion3 as select a.*,b.标记,c.branch_name,c.approve_产品,c.ID_CARD_NO,c.sales_code,c.SALES_NAME from Fraud_suspicion2 as a left join Fraud_1 as b on a.apply_code=b.apply_code 
 left join dta.customer_info as c on a.apply_code = c.apply_code 

;quit;


filename DD DDE "EXCEL|[反欺诈数据.xlsx]催收!r2c1:r600c30" notab;
data _null_;set Fraud_suspicion3;file DD;put 催收 '09'x branch_name "09"x 标签 '09'x approve_产品  '09'x  sales_code "09"x SALES_NAME '09'x 放款日期
'09'x apply_code  '09'x ID_CARD_NO '09'x 客户姓名 '09'x CONTACT_NAME'09'x MOBILE_NO '09'x 失联人姓名 "09"x关联人编号"09"x od   ;run;

data his.Fraud;
set Fraud_suspicion1;
drop 标记;
run;

/*已更新数据导入*/
/*累加式更新*/
/*PROC IMPORT OUT= last_data*/
/*            DATAFILE= "F:\share\反欺诈数据\反欺诈数据样本.xlsx"*/
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="催收$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/**/
/*proc sql;*/
/*create table deff as  select * from  Fraud_suspicion where apply_code not in (select*/
/*a.apply_code  from Fraud_suspicion as a inner join last_data as b on a.apply_code = b.apply_code and a.标签=b.标签)*/
/*and 标签 not in (select*/
/*a.标签  from Fraud_suspicion as a inner join last_data as b on a.apply_code = b.apply_code and a.标签=b.标签);quit;*/
/**/
/*data update_data ;*/
/*set check_name last_data ;*/
/**/
/*run;*/
/*proc sort data = update_data nodupkey; by 标签 apply_code ;run;*/
/**/
/*x  "F:\share\反欺诈数据\反欺诈数据样本.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[反欺诈数据样本.xlsx]催收!r2c1:r10000c7" notab;*/
/*data _null_;set update_data;file DD;put apply_code '09'x 客户姓名 '09'x CONTACT_NAME '09'x MOBILE_NO '09'x  标签 ;run;*/
/**/
/*x  "F:\share\反欺诈数据\反欺诈数据.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[反欺诈数据.xlsx]催收!r2c1:r10000c7" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x 客户姓名 '09'x CONTACT_NAME '09'x MOBILE_NO '09'x  标签 ;run;*/
/**/






