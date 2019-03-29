option compress=yes validvarname=any;
libname appRaw odbc  datasrc=approval_nf;
libname repayfin "D:\share\Datamart\�м��\repayAnalysis";
libname dta "D:\share\Datamart\�м��\daily";
libname approval "D:\share\Datamart\ԭ��\approval";
libname account "D:\share\Datamart\ԭ��\account";

libname his "D:\share\����թ����\��������";

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
/*set approval.approval_check_result(where=(kindex( FACE_SIGN_REMIND,"ǩ") or kindex(FACE_SIGN_REMIND,"��")));*/
/*run;*/

data account_info;
set account.account_info(where=(mdy(8,1,2017)<loan_date <intnx("day",&nt.,-14,"s") and BRANCH_CODE ^="105"));
apply_code = tranwrd(contract_no , "C","PL");
keep apply_code  loan_date ch_name contract_no;
run;
/*��������ǩ*/
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
/*format ��ǩ $20.;*/
/*��ǩ="��������ǩ";*/
/*keep apply_code ch_name ��ǩ;*/
/*run;*/

/*���������Ҫ��yq��ϵ*/
/*data approval_check_result1;*/
/*set approval.approval_check_result(where=(kindex(APPROVED_PRODUCT,"zigu")));*/
/*run;*/

/*�������*/
data phone_check;
set appraw.phone_check_record;
run;

data phone_check1;
set phone_check;
 format �������  yymmdd10. ����·� $7.;
������� = datepart(CREATED_TIME);
����·� = substr(compress(put(�������,yymmdd10.),"-"),1,6);
run;
proc sort data = phone_check1;by apply_code;run;

proc sql;
create table phone_check_result as select a.*,b.* from account_info as a left join  phone_check1 as b on a.apply_code = b.apply_code ;
quit;

/*proc sort data = phone_check_result;by apply_code NAME CALL_NUMBER descending CREATED_TIME;run;*/
/*proc sort data = phone_check_result nodupkey out = phone_check_result1 ; by apply_code NAME CALL_NUMBER;run;*/
/*�ò���ȥ��relation�����ǩ*/
proc sql;
create table phone_check_result1(where=( CH_NAME ^= name  and CHECK_RESULT_DES ^="���")) 
as select apply_code ,ch_name,NAME, RELATION ,CALL_NUMBER,CHECK_RESULT_DES,1 as ��˴��� from phone_check_result group by apply_code ,ch_name,NAME, RELATION ,CALL_NUMBER,CHECK_RESULT_DES ;quit;

proc sort data = phone_check_result1 nodupkey;
by apply_code NAME RELATION CALL_NUMBER;run;
/**/
/*proc sql;*/
/*create table once_phone as select apply_code,CHECK_RESULT_DES,count(CHECK_RESULT_DES) as ��˽��*/
/*from phone_check_result1 group by apply_code,CHECK_RESULT_DES;quit;*/

proc transpose data=phone_check_result1(where=(CHECK_RESULT_DES^="")) out=phone_check_result2(drop= _NAME_)  ;
by apply_code ch_name NAME  RELATION CALL_NUMBER;
id CHECK_RESULT_DES;
var ��˴���;
run;
/*�����ϵ��*/
data false_contract ;
set phone_check_result2;
if ��ٲ���^=.;
format ��ǩ $20.;
��ǩ="��ٲ���";
keep apply_code ch_name NAME  RELATION CALL_NUMBER ��ǩ;
run;
/*������*/
data other_contract ;
set phone_check_result2;
if ������^=.;
format ��ǩ $20.;
��ǩ = "�޵�����";
keep apply_code ch_name NAME  RELATION CALL_NUMBER ��ǩ;

run;
/*������ϵ�˾���һ�ε�˳ɹ������ */
/*data once_phone2;*/
/*set once_phone1;*/
/*��ϵ���� = sum(����� ,����µ� ,���˽��� ,���쳣, һ�ε�˳ɹ� ,���쳣 ,���);*/
/*if ��ϵ���� = sum(һ�ε�˳ɹ�,���);*/
/*run;*/


proc sql;
create table phone_right_first(where=(��˳ɹ�����=0)) as select apply_code,CH_NAME,sum(count(*),-count(һ�ε�˳ɹ�),0) as ��˳ɹ����� from phone_check_result2 group by apply_code,CH_NAME;quit;

/*------------*/
/*proc sql;*/
/*create table phone_right_first(where=(����ϴ���>0)) as select apply_code,CH_NAME,sum(�����) as ����ϴ��� from phone_check_result3 group by apply_code,CH_NAME;quit;*/

/*------------*/

data phone_right_first;
set phone_right_first;
format ��ǩ $20.;
��ǩ = "��ϵ�˾�һ�ε�˳ɹ�";
keep apply_code ch_name ��ǩ;
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
if od_days>0 then ״̬="��ǰ����";
else if od_days_ever >0 then ״̬= "��ʷ����";
else ״̬= "��������";
format �Ƿ����� $10.;
if kindex( title,"����") or POSITION ="297" then �Ƿ�����="��";
else �Ƿ�����="��";
format ����ʱ�� yymmdd10.;
����ʱ�� = &nt.;
run;

proc sort data = check_name;by ��ǩ;run;

data check_result;
set his.check_result;
if ����ʱ��^=  &nt.;
���=1;
run;

data check_name1;
set check_result check_name;
�ܱ�ǩ = "���";
run;

proc sort data = check_name1 nodupkey;by ��ǩ apply_code CALL_NUMBER ;run;

data check_name2;
set check_name1 ;
if ���=1 then delete;
drop ���;
run;

proc sql ;
create table check_name3 as select a.*,b.��� from check_name2 as a left join check_result as b on a.apply_code=b.apply_code;quit;


filename DD DDE "EXCEL|[����թ����.xlsx]����!r2c1:r20000c30" notab;
data _null_;set check_name3;file DD;put  �ܱ�ǩ  '09'x branch_name '09'x ��ǩ  '09'x approve_��Ʒ '09'x SALES_CODE '09'x SALES_NAME  '09'x �ſ����� 
'09'x apply_code '09'x ID_CARD_NO '09'x ch_name '09'x name '09'x relation '09'x call_number '09'x CREATED_USER_NAME  '09'x UPDATED_USER_NAME
'09'x ��ر�ǩ '09'x age '09'x �����̶� '09'x ��3���´����ѯ����
'09'x ��1���±��˲�ѯ���� '09'x ��ʵ���� '09'x ��ծ��
'09'x od_days '09'x od_days_ever  '09'x״̬
'09'x �Ƿ�����  
  ;run;



data his.check_result;
set check_name1;
drop ���;
run;


/*�Ѹ������ݵ���*/
/*�ۼ�ʽ����*/
/*PROC IMPORT OUT= last_data*/
/*            DATAFILE= "C:\Users\ly\Desktop\����թ����10-23.xlsx"*/
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="����$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/*/**/*/
/*proc sql;*/
/*create table deff as  select * from  last_data(where=(������^="")) as a left join check_name1 as b on a.������ =b.apply_code and a.ԭ��=b.��ǩ;quit;*/
/**/
/**/
/**/
/*x  "C:\Users\ly\Desktop\����թ����10-23.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[����թ����10-23.xlsx]����!r2c1:r3000c30" notab;
/*data _null_;set deff;file DD;put apply_code '09'x ch_name '09'x ��ǩ '09'x NAME '09'x ID_CARD_NO '09'x  RELATION '09'x CALL_NUMBER*/
/*'09'x  approve_��Ʒ '09'x �ſ����� '09'x branch_name  '09'x SALES_CODE  '09'x SALES_NAME '09'x updated_name_first '09'x updated_name_final */
/*'09'x od_days'09'x od_days_ever'09'x ״̬ '09'x �Ƿ����� ;run;*/
/*data update_data ;*/
/*set check_name last_data ;*/
/**/
/*run;*/
/*proc sort data = update_data nodupkey; by ��ǩ apply_code ;run;*/
/**/
/*x  "F:\share\����թ����\����թ��������.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[����թ��������.xlsx]����!r2c1:r10000c7" notab;*/
/*data _null_;set update_data;file DD;put apply_code '09'x ch_name '09'x ��ǩ '09'x NAME '09'x  RELATION '09'x CALL_NUMBER;run;*/
/*x  "F:\share\����թ����\����թ����.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[����թ����.xlsx]����!r2c1:r10000c7" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x ch_name '09'x ��ǩ '09'x NAME '09'x  RELATION '09'x CALL_NUMBER;run;*/

