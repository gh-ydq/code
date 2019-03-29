option compress = yes validvarname = any;
option missing = 0;
libname csdata odbc  datasrc=csdata_nf;
libname YY odbc  datasrc=res_nf;
libname account odbc datasrc = account_nf;
libname approval "D:\share\Datamart\ԭ��\approval";
libname his "D:\share\����թ����\��������";
libname dta "D:\share\Datamart\�м��\daily";
libname repayfin "D:\share\Datamart\�м��\repayAnalysis";

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
format ��ϵ���� yymmdd10.;
��ϵ����=datepart(CREATE_TIME);

run;
/*�����һ����ϵ���Ϊ�ο�*/
proc sort data = cs_table1_tab  ;by CONTRACT_NO descending ��ϵ���� ; run;
proc sort data = cs_table1_tab out = cs_table1_tab1(where=(DIAL_TELEPHONE_NO^="" )) nodupkey;by CONTRACT_NO DIAL_TELEPHONE_NO CONTACTS_NAME;run;
/*Ŀǰʧ���Ŀͻ�*/
data cs_table1_tab2;
set cs_table1_tab1;
if CALL_ACTION_ID ="OUTBOUND" and CONTACTS_NAME=CUSTOMER_NAME and RESULT in ("��������","���˽���","ռ�߹ػ�","�޷���ͨ","�պŴ��","�ܽӹ���","Ƿ��ͣ��","BSL��ʧ��"
,"NOA����Ӧ��","QSLȫʧ��","ʧ��") then ʧ��=1;else ʧ��=0;
if ʧ��=1;
apply_code = tranwrd(contract_no,"C","PL" );
run;
/*���пͻ�*/
data payment_daily(keep= contract_no �ͻ����� od_days cut_date apply_code);
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
format ��λ�绰 $25.;
if COMP_TEL =""  then ��λ�绰="��";
else if COMP_TEL_AREA="" or find(COMP_TEL,"-") then ��λ�绰 = compress(COMP_TEL,"-");
else  ��λ�绰 = compress(COMP_TEL_AREA||COMP_TEL );
format contact_name $45.;
contact_name = "��λ";
keep apply_code ��λ�绰 contact_name;
run;

proc sql;
create table  contact_name as select a.apply_code,a.�ͻ�����,a.od_days,b.CONTACT_NAME,b.MOBILE_NO  from 
payment_daily as a left join apply_contract as b on a.apply_code = b.apply_code;quit;

proc sql;
create table own_phone as select a.apply_code,a.�ͻ�����,a.od_days,b.ch_name as CONTACT_NAME,b.BORROWER_TEL_ONE as MOBILE_NO from
payment_daily as a left join account_info as b on a.apply_code = b.apply_code;quit;

proc sql;
create table comp_phone as select a.apply_code,a.�ͻ�����,a.od_days,b.contact_name ,b.��λ�绰 as MOBILE_NO from
payment_daily as a left join apply_emp as b on a.apply_code = b.apply_code;quit;


data name_phone;
set contact_name own_phone comp_phone;
run;

proc sort data = name_phone nodupkey ;by apply_code CONTACT_NAME MOBILE_NO; run;
/*��������ͻ�*/
data normal_cos_phone ;
set name_phone(where=(od_days<1));
run;
/*���ڿͻ�*/
data od_cos_phone;
set name_phone (where=(od_days>=15 ));
run;
 
/*ʧ���ͻ�*/
proc sql;
create table lc_cos_phone as select  a.* from name_phone as a right join cs_table1_tab2 as b on a.apply_code = b.apply_code;quit;


/*proc sql;*/
/*create table cs_kehu(where=(0<od_days and ��ϵ����<=&dt.-3)) as  select a.*,b.od_days,b.cut_date from cs_table1_tab2 as a*/
/*left join payment_daily as b on a.contract_no = b.contract_no and a.CUSTOMER_NAME =b.�ͻ�����;quit;*/
/*data cs_kehu1;*/
/*set cs_kehu;*/
/*apply_code = tranwrd(contract_no,"C","PL" );*/
/*run;*/

/*data cs_table1_tab3;*/
/*set cs_table1_tab2;*/
/*apply_code = tranwrd(contract_no,"C","PL" );*/
/*run;*/
/*�ͻ��� ���е绰��Ϣ*/

/*ʧ���ͻ�����*/
proc sql;
create table Fraud_suspicion_phone(where=(MOBILE_NO not in ("","��","..","4006099600","089800000000","02188888888","087100000000","95598","12333","047695598","00") 
and kindex(MOBILE_NO,"00000") =0  and od>=15
))  as select a.*,b.�ͻ����� as ʧ��������,b.apply_code as �����˱��,b.od_days as od from normal_cos_phone as a inner join lc_cos_phone as b on
a.apply_code >b.apply_code and a.MOBILE_NO = b.MOBILE_NO ;quit;
proc sort data = Fraud_suspicion_phone nodupkey ;by �ͻ����� ʧ��������;run;

data Fraud_suspicion_phone;
set Fraud_suspicion_phone;
format ��ǩ $20.;
��ǩ = "����ʧ���绰";

drop od_days;
run;


/*���ڿͻ����������ͻ�*/
proc sql ;
create table Fraud_suspicion_phone2(where=(MOBILE_NO not in ("","��","..","4006099600","089800000000","02188888888","087100000000","95598","12333","047695598","00") 
and  kindex(MOBILE_NO,"00000") =0 and CONTACT_NAME not in ("���","��Ѳ�ѯ")))  
as select a.*,b.od_days as od ,b.�ͻ����� as ʧ��������,b.apply_code as �����˱��
from normal_cos_phone as a inner join  od_cos_phone as b on a.MOBILE_NO =b.MOBILE_NO;quit;
proc sort data = Fraud_suspicion_phone2 nodupkey ;by �ͻ����� contact_name ʧ��������;run;
data Fraud_suspicion_phone2;
set Fraud_suspicion_phone2;
format ��ǩ $20.;
��ǩ = "�������ڿͻ�";

drop od_days; 
run;

data Fraud_suspicion;
set Fraud_suspicion_phone  Fraud_suspicion_phone2;
format ����ʱ�� yymmdd10.;
����ʱ��=  &nt.;
run;
proc sql;
create table Fraud_suspicion as select a.*,c.�ſ����� from Fraud_suspicion as a  left join dta.app_loan_info as c on a.apply_code = c.apply_code ;quit;


data Fraud;
set his.Fraud;
���=1;
if ����ʱ��^=  &nt.;
run;
proc sort data = Fraud out =Fraud_1 nodupkey;by apply_code ;run;
data Fraud_suspicion1;
set Fraud Fraud_suspicion;
run;

proc sort data = Fraud_suspicion1 nodupkey;by ��ǩ apply_code �����˱�� CONTACT_NAME ;run;

data Fraud_suspicion2;
set Fraud_suspicion1;
if ���=1 
then delete;
����="����";
drop ���;
run;

proc sql ;
create table Fraud_suspicion3 as select a.*,b.���,c.branch_name,c.approve_��Ʒ,c.ID_CARD_NO,c.sales_code,c.SALES_NAME from Fraud_suspicion2 as a left join Fraud_1 as b on a.apply_code=b.apply_code 
 left join dta.customer_info as c on a.apply_code = c.apply_code 

;quit;


filename DD DDE "EXCEL|[����թ����.xlsx]����!r2c1:r600c30" notab;
data _null_;set Fraud_suspicion3;file DD;put ���� '09'x branch_name "09"x ��ǩ '09'x approve_��Ʒ  '09'x  sales_code "09"x SALES_NAME '09'x �ſ�����
'09'x apply_code  '09'x ID_CARD_NO '09'x �ͻ����� '09'x CONTACT_NAME'09'x MOBILE_NO '09'x ʧ�������� "09"x�����˱��"09"x od   ;run;

data his.Fraud;
set Fraud_suspicion1;
drop ���;
run;

/*�Ѹ������ݵ���*/
/*�ۼ�ʽ����*/
/*PROC IMPORT OUT= last_data*/
/*            DATAFILE= "F:\share\����թ����\����թ��������.xlsx"*/
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="����$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/**/
/*proc sql;*/
/*create table deff as  select * from  Fraud_suspicion where apply_code not in (select*/
/*a.apply_code  from Fraud_suspicion as a inner join last_data as b on a.apply_code = b.apply_code and a.��ǩ=b.��ǩ)*/
/*and ��ǩ not in (select*/
/*a.��ǩ  from Fraud_suspicion as a inner join last_data as b on a.apply_code = b.apply_code and a.��ǩ=b.��ǩ);quit;*/
/**/
/*data update_data ;*/
/*set check_name last_data ;*/
/**/
/*run;*/
/*proc sort data = update_data nodupkey; by ��ǩ apply_code ;run;*/
/**/
/*x  "F:\share\����թ����\����թ��������.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[����թ��������.xlsx]����!r2c1:r10000c7" notab;*/
/*data _null_;set update_data;file DD;put apply_code '09'x �ͻ����� '09'x CONTACT_NAME '09'x MOBILE_NO '09'x  ��ǩ ;run;*/
/**/
/*x  "F:\share\����թ����\����թ����.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[����թ����.xlsx]����!r2c1:r10000c7" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x �ͻ����� '09'x CONTACT_NAME '09'x MOBILE_NO '09'x  ��ǩ ;run;*/
/**/






