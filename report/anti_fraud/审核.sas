option compress=yes validvarname=any;
libname appRaw odbc  datasrc=approval_nf;
libname repayfin "D:\share\Datamart\中间表\repayAnalysis";
libname dta "D:\share\Datamart\中间表\daily";
libname approval "D:\share\Datamart\原表\approval";
libname account "D:\share\Datamart\原表\account";

libname his "D:\share\反欺诈数据\更新数据";

/*libname approval "\\data\mili\offline\offlinedata\approval";*/
/*libname account '\\data\mili\offline\offlinedata\account';*/




data _null_;
format nt yymmdd10. dm $7.;
nt=today();
call symput("nt",nt);
dm =substr(compress(put(nt,yymmdd10.),"-"),1,6); 
call symput("month",dm);

run;
%put &nt. &month.;

data apply_info;
set approval.apply_info(where =(branch_name^=""));
keep apply_code SALES_CODE SALES_NAME;
run;
proc sort data = apply_info;by apply_code;run;
/*data approval_check_result;*/
/*set approval.approval_check_result(where=(kindex( FACE_SIGN_REMIND,"签") or kindex(FACE_SIGN_REMIND,"核")));*/
/*run;*/

data account_info;
set account.account_info(where=(mdy(8,1,2017)<loan_date <intnx("day",&nt.,-14,"s") and BRANCH_CODE ^="105"));
apply_code = tranwrd(contract_no , "C","PL");
keep apply_code  loan_date ch_name contract_no;
run;
/*有条件面签*/
/*proc sql;*/
/*create table FACE_SIGN_REM as  select a.apply_code,a.contract_no,a.ch_name,b.FACE_SIGN_REMIND,b.CREATED_TIME from */
/*account_info as a inner join approval_check_result as b on a.apply_code=b.apply_code;*/
/*quit;*/
/**/
/*proc sort data = FACE_SIGN_REM;by contract_no descending CREATED_TIME;run;*/
/*proc sort data = FACE_SIGN_REM nodupkey ;by contract_no ;run;*/
/**/
/*data FACE_SIGN_REM_1;*/
/*set FACE_SIGN_REM;*/
/*format 标签 $20.;*/
/*标签="有条件面签";*/
/*keep apply_code ch_name 标签;*/
/*run;*/

/*外访数据需要和yq联系*/
/*data approval_check_result1;*/
/*set approval.approval_check_result(where=(kindex(APPROVED_PRODUCT,"zigu")));*/
/*run;*/

/*电联结果*/
data phone_check;
set appraw.phone_check_record;
run;

data phone_check1;
set phone_check;
 format 电核日期  yymmdd10. 电核月份 $7.;
电核日期 = datepart(CREATED_TIME);
电核月份 = substr(compress(put(电核日期,yymmdd10.),"-"),1,6);
run;
proc sort data = phone_check1;by apply_code;run;

proc sql;
create table phone_check_result as select a.*,b.* from account_info as a left join  phone_check1 as b on a.apply_code = b.apply_code ;
quit;

/*proc sort data = phone_check_result;by apply_code NAME CALL_NUMBER descending CREATED_TIME;run;*/
/*proc sort data = phone_check_result nodupkey out = phone_check_result1 ; by apply_code NAME CALL_NUMBER;run;*/
/*该不该去掉relation这个标签*/
proc sql;
create table phone_check_result1(where=( CH_NAME ^= name  and CHECK_RESULT_DES ^="免核")) 
as select apply_code ,ch_name,NAME, RELATION ,CALL_NUMBER,CHECK_RESULT_DES,1 as 电核次数 from phone_check_result group by apply_code ,ch_name,NAME, RELATION ,CALL_NUMBER,CHECK_RESULT_DES ;quit;

proc sort data = phone_check_result1 nodupkey;
by apply_code NAME RELATION CALL_NUMBER;run;
/**/
/*proc sql;*/
/*create table once_phone as select apply_code,CHECK_RESULT_DES,count(CHECK_RESULT_DES) as 电核结果*/
/*from phone_check_result1 group by apply_code,CHECK_RESULT_DES;quit;*/

proc transpose data=phone_check_result1(where=(CHECK_RESULT_DES^="")) out=phone_check_result2(drop= _NAME_)  ;
by apply_code ch_name NAME  RELATION CALL_NUMBER;
id CHECK_RESULT_DES;
var 电核次数;
run;
/*虚假联系人*/
data false_contract ;
set phone_check_result2;
if 虚假补充^=.;
format 标签 $20.;
标签="虚假补充";
keep apply_code ch_name NAME  RELATION CALL_NUMBER 标签;
run;
/*第三方*/
data other_contract ;
set phone_check_result2;
if 第三方^=.;
format 标签 $20.;
标签 = "无第三方";
keep apply_code ch_name NAME  RELATION CALL_NUMBER 标签;

run;
/*所有联系人均是一次电核成功或免核 */
/*data once_phone2;*/
/*set once_phone1;*/
/*联系次数 = sum(不配合 ,多次致电 ,无人接听 ,无异常, 一次电核成功 ,有异常 ,免核);*/
/*if 联系次数 = sum(一次电核成功,免核);*/
/*run;*/


proc sql;
create table phone_right_first(where=(电核成功次数=0)) as select apply_code,CH_NAME,sum(count(*),-count(一次电核成功),0) as 电核成功次数 from phone_check_result2 group by apply_code,CH_NAME;quit;

/*------------*/
/*proc sql;*/
/*create table phone_right_first(where=(不配合次数>0)) as select apply_code,CH_NAME,sum(不配合) as 不配合次数 from phone_check_result3 group by apply_code,CH_NAME;quit;*/

/*------------*/

data phone_right_first;
set phone_right_first;
format 标签 $20.;
标签 = "联系人均一次电核成功";
keep apply_code ch_name 标签;
run;

data check_name;
set  false_contract other_contract phone_right_first;
run;
proc sort data = check_name;by apply_code;run;
proc sort data = approval.apply_emp out = apply_emp;by apply_code ;run;
proc sort data = repayfin.payment_daily out = payment_daily;by contract_no ;run;
proc sort data = dta.customer_info out = Customer_info;by apply_code ;run;

data payment_daily;
set payment_daily(where=(cut_date = &nt.-1));
apply_code = tranwrd(contract_no,"C","PL");
run;



data check_name;
merge check_name(in=a) Customer_info apply_info payment_daily(keep = apply_code od_days_ever od_days) apply_emp;
by apply_code;
if a ;
if od_days>0 then 状态="当前逾期";
else if od_days_ever >0 then 状态= "历史逾期";
else 状态= "正常还款";
format 是否退休 $10.;
if kindex( title,"退休") or POSITION ="297" then 是否退休="是";
else 是否退休="否";
format 更新时间 yymmdd10.;
更新时间 = &nt.;
run;

proc sort data = check_name;by 标签;run;

data check_result;
set his.check_result;
if 更新时间^=  &nt.;
标记=1;
run;

data check_name1;
set check_result check_name;
总标签 = "审核";
run;

proc sort data = check_name1 nodupkey;by 标签 apply_code CALL_NUMBER ;run;

data check_name2;
set check_name1 ;
if 标记=1 then delete;
drop 标记;
run;

proc sql ;
create table check_name3 as select a.*,b.标记 from check_name2 as a left join check_result as b on a.apply_code=b.apply_code;quit;


filename DD DDE "EXCEL|[反欺诈数据.xlsx]审批!r2c1:r20000c30" notab;
data _null_;set check_name3;file DD;put  总标签  '09'x branch_name '09'x 标签  '09'x approve_产品 '09'x SALES_CODE '09'x SALES_NAME  '09'x 放款日期 
'09'x apply_code '09'x ID_CARD_NO '09'x ch_name '09'x name '09'x relation '09'x call_number '09'x CREATED_USER_NAME  '09'x UPDATED_USER_NAME
'09'x 外地标签 '09'x age '09'x 教育程度 '09'x 近3个月贷款查询次数
'09'x 近1个月本人查询次数 '09'x 核实收入 '09'x 负债率
'09'x od_days '09'x od_days_ever  '09'x状态
'09'x 是否退休  
  ;run;



data his.check_result;
set check_name1;
drop 标记;
run;


/*已更新数据导入*/
/*累加式更新*/
/*PROC IMPORT OUT= last_data*/
/*            DATAFILE= "C:\Users\ly\Desktop\反欺诈数据10-23.xlsx"*/
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="审批$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/*/**/*/
/*proc sql;*/
/*create table deff as  select * from  last_data(where=(申请编号^="")) as a left join check_name1 as b on a.申请编号 =b.apply_code and a.原由=b.标签;quit;*/
/**/
/**/
/**/
/*x  "C:\Users\ly\Desktop\反欺诈数据10-23.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[反欺诈数据10-23.xlsx]审批!r2c1:r3000c30" notab;
/*data _null_;set deff;file DD;put apply_code '09'x ch_name '09'x 标签 '09'x NAME '09'x ID_CARD_NO '09'x  RELATION '09'x CALL_NUMBER*/
/*'09'x  approve_产品 '09'x 放款日期 '09'x branch_name  '09'x SALES_CODE  '09'x SALES_NAME '09'x updated_name_first '09'x updated_name_final */
/*'09'x od_days'09'x od_days_ever'09'x 状态 '09'x 是否退休 ;run;*/
/*data update_data ;*/
/*set check_name last_data ;*/
/**/
/*run;*/
/*proc sort data = update_data nodupkey; by 标签 apply_code ;run;*/
/**/
/*x  "F:\share\反欺诈数据\反欺诈数据样本.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[反欺诈数据样本.xlsx]审批!r2c1:r10000c7" notab;*/
/*data _null_;set update_data;file DD;put apply_code '09'x ch_name '09'x 标签 '09'x NAME '09'x  RELATION '09'x CALL_NUMBER;run;*/
/*x  "F:\share\反欺诈数据\反欺诈数据.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[反欺诈数据.xlsx]审批!r2c1:r10000c7" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x ch_name '09'x 标签 '09'x NAME '09'x  RELATION '09'x CALL_NUMBER;run;*/

