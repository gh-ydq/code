option compress=yes validvarname=any;
libname appRaw odbc  datasrc=approval_nf;
libname approval "D:\share\Datamart\ԭ��\approval";
libname account "D:\share\Datamart\ԭ��\account";
libname his "D:\share\����թ����\��������";
libname dta "D:\share\Datamart\�м��\daily";
libname res odbc  datasrc=res_nf;

data apply_info;
set appRaw.apply_info ;
run;
data apply_emp;
set approval.apply_emp;
comp_name = compress(comp_name,"");
run;

data null;
format nt yymmdd10.;
nt=today();
call symput("nt",nt);
call symput("dt",nt-1);
run;
%put &nt.;
/*���account_info ���Ƿ񻹴���ȱʧloan_date �����*/
/*data aaa;*/
/*set repayfin.payment_daily;*/
/*if contract_no="C2017071815032083816859";*/
/*run;*/
/*data aaa;*/
/*set account.account_info;*/
/*if contract_no="C2017071815032083816859";*/
/*run;*/


/*��ż����ĸ��ŮͬΪ�ڿ�*/
data sum_info;
set repayfin.payment_daily(where=(Ӫҵ��^="APP" and cut_date = &nt.-1 ));
apply_code = tranwrd(contract_no , "C","PL");
format loan_date yymmdd10.;
loan_date = mdy(substr(�ſ�����,6,2),substr(�ſ�����,9,2),substr(�ſ�����,1,4));
if loan_date <intnx("day",&nt.,-14,"b") ;
format ״̬$10.;
if es =1 then ״̬= "����";
else if od_days>0 then ״̬="����";
else if od_days_ever>0 then ״̬="��ʷ����";
else ״̬="��������";
run;

data account_info;
set sum_info(where=(Ӫҵ��^="APP" and cut_date = &nt.-1 and es^=1 and od_days<1  and mdy(8,1,2017)<loan_date <intnx("day",&nt.,-14,"s") ));
apply_code = tranwrd(contract_no , "C","PL");
run;

proc sql; 
create table apply_info1 as select a.*,b.* from apply_info as a left join sum_info as b on a.apply_code =b.apply_code;quit;

data apply_info2;
set apply_info1;
if TASK_PERIOD_DESC ^="����"  then ״̬= TASK_PERIOD_DESC;
run;

proc sql; 
create table apply_info1 as select a.*,b.PHONE1 from apply_info2 as a left join approval.apply_base as b on a.apply_code =b.apply_code ;quit;

data apply_info1;
set apply_info1;
if MOBILE_NO ="" then MOBILE_NO=PHONE1;
drop PHONE1;
run;


/*���ֿͻ���д������δ��ѡֱϵ������ȱ�ٱ�ǩ*/
proc sql;
create table loan_contact_f as select a.*,b.CONTACT_NAME,b.MOBILE_NO,b.relation from account_info as a left join approval.apply_contacts(
where=(relation in ("187","190","191","192","193","MR001"))) as b 
on a.apply_code  = b.apply_code ; quit;

/*data family;*/
/*set approval.apply_contacts(where=(relation in ("187","190","191","192","193") ));*/
/*keep apply_code CONTACT_NAME relation MOBILE_NO;*/
/*run;*/

proc sort data = loan_contact_f nodupkey ;by apply_code MOBILE_NO;run;
/*proc sql;*/
/*create table deceiver as select * from family where CONTACT_NAME in (select NAME from approval.apply_info);quit;*/

proc sql;
create table deceiver_f(where=(������^=" " and MOBILE_NO^="") keep = apply_code CONTACT_NAME ������ �����˱�� �ͻ�����    MOBILE_NO TASK_PERIOD_DESC ״̬) as  select a.*,
b.name as ������,b.apply_code as �����˱��,b.MOBILE_NO as �绰����,b.TASK_PERIOD_DESC,b.״̬ from loan_contact_f (drop=״̬)
as a left join apply_info1 as b 
on  a.MOBILE_NO = b.MOBILE_NO and a.apply_code >b.apply_code;quit;


data deceiver_f;
set deceiver_f;
format ��ǩ $20.;
��ǩ ="ֱϵ�����������¼";
rename MOBILE_NO=��������;
if TASK_PERIOD_DESC ^="����"  then ״̬= TASK_PERIOD_DESC;
drop TASK_PERIOD_DESC;
run;
proc sort data = deceiver_f ;by apply_code ������ �������� descending �����˱��;run;
proc sort data = deceiver_f nodupkey;by apply_code ������ �������� ;run;



/*�ͻ�ֱ����ϵ������˾�������¼*/

proc sql;
create table loan_contact_dc as select a.*,b.CONTACT_NAME,b.MOBILE_NO,b.relation from account_info as a 
left join approval.apply_contacts(where=(relation not in ("187","190","191","192","193","MR001") )) as b 
on a.apply_code  = b.apply_code ; quit;

proc sort data = loan_contact_dc nodupkey ;by apply_code CONTACT_NAME;run;
proc sql;
create table deceiver_dc(where=(MOBILE_NO^=" " and ������^=�ͻ�����) keep = apply_code CONTACT_NAME ������ �ͻ����� �����˱��  LOAN_DATE  MOBILE_NO TASK_PERIOD_DESC ״̬) as  select a.*,
b.name as ������,b.apply_code as �����˱��,b.MOBILE_NO as �绰����,b.TASK_PERIOD_DESC,b.״̬ from loan_contact_dc as a inner join apply_info1 as b 
on  a.MOBILE_NO = b.MOBILE_NO and a.apply_code >b.apply_code;quit;

data deceiver_dc;
set deceiver_dc;
format ��ǩ $20.;
��ǩ ="ֱ����ϵ���������¼";
rename MOBILE_NO=��������;
if TASK_PERIOD_DESC ^="����"  then ״̬= TASK_PERIOD_DESC;
drop TASK_PERIOD_DESC;
run;
proc sort data = deceiver_dc ;by apply_code ������ �������� descending �����˱��;run;
proc sort data = deceiver_dc nodupkey;by apply_code ������ �������� ;run;


/*�ͻ������ϵ������˾�������¼*/
data relation_type ;
set res.optionitem(where = (groupCode in( "MATERELATION","FAMILYRELATION","OTHERRELATION","JOBRELATION")));
keep itemCode itemName_zh;
run;
proc sql;
create table loan_contact_idc1 as select b.*,a.CONTACT_NAME,a.MOBILE_NO,a.relation ,c.itemName_zh as ��ͻ���ϵ from approval.apply_contacts as a right join 
account_info as b on a.apply_code  = b.apply_code  left join relation_type as c on a.relation = c.itemCode
; quit;

proc sort data = loan_contact_idc1 nodupkey ;by CONTACT_NAME apply_code ;run;

proc sql;
create table loan_contact_idc2 as select b.*,a.CONTACT_NAME,a.MOBILE_NO,a.relation,c.itemName_zh as ������˹�ϵ from approval.apply_contacts  as a left join 
 apply_info1(drop=MOBILE_NO ) as b 
on a.apply_code  = b.apply_code   left join relation_type as c on a.relation = c.itemCode ; quit;

proc sort data = loan_contact_idc2 nodupkey ;by CONTACT_NAME apply_code ;run;

proc sql;
create table deceiver_idc(where=(CONTACT_NAME not in ("����","0","���","���˴�","00","11","12","����̻�","��������","��Ѳ�ѯ","��")
 and MOBILE_NO not in("1","11","13500000000","13600000000","13000000000","13800000000","13700000000") )) as select a.�ͻ�����,a.apply_code,
a.CONTACT_NAME,a.MOBILE_NO,b.name as ������,a.��ͻ���ϵ,b.������˹�ϵ,b.apply_code as �����˱��,b.״̬  from loan_contact_idc1 
as a inner  join loan_contact_idc2 as b on  a.MOBILE_NO=b.MOBILE_NO  and a.apply_code>b.apply_code
 and a.�ͻ�����<>b.name;quit;


  
data deceiver_idc;
set deceiver_idc(where=(MOBILE_NO^=""));
rename MOBILE_NO=��������;
format ��ǩ $20.;
��ǩ ="�ͻ������ϵ���������¼";
run;


/*data aaa;*/
/*set approval.apply_contacts;*/
/*if contact_name = "����";run;*/

data apply_emp_phone;
set approval.apply_emp;
format ��λ�绰 $25.;
if COMP_TEL ="" or  COMP_TEL ="0" or COMP_TEL_AREA in ("0","0-0") then  delete ;
else if COMP_TEL_AREA="" or find(COMP_TEL,"-") then ��λ�绰 =compress( COMP_TEL,"-");
else  ��λ�绰 = compress(COMP_TEL_AREA||COMP_TEL );
run;

/*ͬһ��λ����������˾�������¼*/
proc sql;
create table comp_name_apply1 as select a.*,b.comp_name,b.��λ�绰 from account_info as a left join apply_emp_phone as b on a.apply_code = b.apply_code ;quit;

proc sql;
create table comp_name_apply2 as select a.*,b.comp_name,b.��λ�绰 from apply_info1 as a left join apply_emp_phone as b on a.apply_code = b.apply_code ;quit;

proc sql;
create table comp_name_rele(where=(comp_name^="" and �ͻ����� ^=������ )) as select a.apply_code,a.�ͻ�����,a.comp_name,b.apply_code as �����˱��,b.name as ������,b.״̬
from  comp_name_apply1 as a inner join comp_name_apply2 as b on a.comp_name = b.comp_name  and a.apply_code >b.apply_code ;quit;

proc sort data = comp_name_rele nodupkey;by apply_code ������;run;

proc sort data = dta.Customer_info out =Customer_info;by apply_code;run;

data comp_name_rele;
merge comp_name_rele(in=a) Customer_info(keep=apply_code ��λ����  OC_NAME);
by apply_code;
if a ;
rename comp_name=��������;
format ��ǩ $20.;
��ǩ ="ͬһ��λ�������������¼";
run;

proc sql;
create table comp_name_rele as select a.*,b.OC_NAME as ������ְ�� from comp_name_rele as a left join Customer_info as b on a.�����˱�� =b.apply_code ;quit;

/*ͬһ��λ�绰����������˾�������¼*/

proc sql;
create table comp_phone_rele(where=(��λ�绰 not in("��","") and kindex(��λ�绰,"000000")=0 and kindex(��λ�绰,"888888")=0))
as select a.apply_code,a.�ͻ�����,a.��λ�绰,a.comp_name,b.apply_code as �����˱��,b.name as ������,b.״̬,b.comp_name as �����˵�λ����
from  comp_name_apply1 as a inner join comp_name_apply2 as b on a.��λ�绰 = b.��λ�绰  and a.apply_code >b.apply_code ;quit;

proc sort data = comp_phone_rele nodupkey;by apply_code ������;run;


data comp_phone_rele;
merge comp_phone_rele(in=a) Customer_info(keep=apply_code ��λ����  OC_NAME);
by apply_code;
if a ;
rename ��λ�绰=��������;
format ��ǩ $20.;
��ǩ ="��λ�绰�������м�¼";
run;

/*------------------------*/
data realtion_de ;
set deceiver_f deceiver_dc deceiver_idc comp_name_rele comp_phone_rele;
contract_no = tranwrd(apply_code,"PL","C");
run;
data payment_daily;
set repayfin.payment_daily(where=(cut_date=&dt. and Ӫҵ��^="APP"));
apply_code = tranwrd(contract_no ,"C","PL");
run;
proc sort data = payment_daily;by apply_code;run;

proc sql;
create table realtion_de_all as  select a.*,e.Ӫҵ��,e.���֤���� ,b.od_days,b.od_days_ever,c.�ſ�����,c.approve_��Ʒ,d.SALES_CODE,d.SALES_NAME  
from realtion_de  as a
left join payment_daily as b on a.�����˱�� = b.apply_code 
left join dta.app_loan_info as c on a.apply_code = c.apply_code 
left join apply_info as d on a.apply_code = d.apply_code
left join payment_daily as e on a.apply_code = e.apply_code ;

quit;

data realtion_de_all;
set realtion_de_all;
if  ״̬ in ("����","�ܾ�","�ܾ�����","��ʷ����","ȡ��","ȡ������","����","��������");
���֤����2 = put(���֤����,$20.);
format ����ʱ�� yymmdd10.;
����ʱ��=  &nt.;
run;
proc sort data = realtion_de_all;by ��ǩ;run;

data realtion;
set his.realtion;
���=1;
if ����ʱ��^=  &nt.;
run;
proc sort data = realtion  nodupkey out = realtion_1 ;by apply_code;run;
data realtion_de_all1;
set realtion realtion_de_all;
run;

proc sort data = realtion_de_all1 nodupkey;by ��ǩ apply_code �����˱�� ��������;run;

data realtion_de_all2;
set realtion_de_all1;
if ���^=1 ;
drop ���;
if �ſ�����>&dt.-30;
�ܱ�ǩ="����";
run;
proc sql ;
create table realtion_de_all3 as select a.*,b.���,c.* from realtion_de_all2 as a left join realtion_1 as b on a.apply_code=b.apply_code
left join dta.customer_info as c on a.apply_code=c.apply_code;quit;

proc sort data = realtion_de_all3 ; by ��ǩ;run;
proc sql;
create table realtion_cf  as select b.*  from realtion_de_all3(where=(���=1)) as a left join realtion  as b on a.apply_code = b.apply_code;quit;

filename DD DDE "EXCEL|[����թ����.xlsx]����!r2c1:r20000c31" notab;
data _null_;set realtion_de_all3;file DD;put  �ܱ�ǩ  '09'x Ӫҵ�� '09'x ��ǩ  '09'x approve_��Ʒ '09'x SALES_CODE '09'x SALES_NAME  '09'x �ſ����� 
'09'x apply_code '09'x���֤����2 '09'x �ͻ����� '09'x CONTACT_NAME '09'x �������� '09'x ������ '09'x �����˱��  '09'x comp_name '09'x�����˵�λ����
'09'x ��λ���� '09'x OC_NAME '09'x ������ְ�� '09'x ��ͻ���ϵ '09'x ������˹�ϵ  '09'x ��ر�ǩ '09'x age '09'x �����̶� '09'x ��3���´����ѯ����
'09'x ��1���±��˲�ѯ���� '09'x ��ʵ���� '09'x ��ծ��'09'x od_days '09'x od_days_ever  '09'x ״̬  
  ;run;

data his.realtion;
set realtion_de_all1;
keep apply_code ��ǩ ����ʱ��  �ſ����� �����˱�� ��������;
run;

/*proc sql;*/
/*create table   aaaac as select a.F26,b.״̬  from last_data as a inner join realtion_de_all1 as b on a.�����˱��=b.�����˱��  ;quit;*/
/**/
/*proc sort  data = aaaac nodupkey ; by F26;run;*/


/*�Ѹ������ݵ���*/
/*�ۼ�ʽ����*/
/*PROC IMPORT OUT= last_data*/
/*            DATAFILE= "F:\share\����թ����\��ʷ����\����թ����12-07.xlsx"*/
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
/*create table deff as  select * from  last_data as a left join realtion_de_all as b   on a.������ = b.apply_code and a.��ǩ=b.��ǩ and a.�����˱��=b.�����˱�� ;quit;*/
/**/
/*proc sort data =deff ;by ��ǩ;run;*/
/*x  "F:\share\����թ����\��ʷ����\����թ����10-25.xlsx"; */
/*filename DD DDE "EXCEL|[����թ����10-25.xlsx]����!r2c1:r20000c20" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x �ͻ����� '09'x CONTACT_NAME '09'x �������� '09'x ������ '09'x �����˱�� '09'x ��ǩ '09'x comp_name '09'x�����˵�λ����*/
/*'09'x ��λ���� '09'x OC_NAME '09'x ������ְ�� '09'x Ӫҵ�� '09'x ���֤����2 '09'x od_days '09'x od_days_ever  '09'x ״̬ '09'x approve_��Ʒ '09'x SALES_CODE '09'x SALES_NAME */
/*  ;run;*/
/*data update_data ;*/
/*set collective last_data ;*/
/**/
/*run;*/
/*proc sort data = update_data nodupkey; by ��ǩ �������� apply_code ;run;*/
/**/
/*x  "F:\share\����թ����\����թ��������.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[����թ��������.xlsx]����!r2c1:r10000c7" notab;*/
/*data _null_;set update_data;file DD;put apply_code '09'x �ͻ����� '09'x ������ '09'x �����˱�� '09'x ״̬ '09'x CONTACT_NAME '09'x MOBILE_NO  '09'x  �������� '09'x ��ǩ;run;*/
/*x  "F:\share\����թ����\����թ����.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[����թ����.xlsx]����!r2c1:r10000c7" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x �ͻ����� '09'x ������ '09'x �����˱�� '09'x ״̬ '09'x CONTACT_NAME '09'x MOBILE_NO  '09'x  �������� '09'x ��ǩ;run;*/
/**/
/*data   cca;*/
/*set realtion_de_all2;*/
/*if ��ǩ in ("ֱ����ϵ���������¼","�ͻ������ϵ��������","ֱϵ�����������¼");*/
/*run;*/
/**/
/**/
/*proc sql;*/
/*create table  aac as select a.*,b.��ǩ as ��ǩ1 from   cca  as a inner join his.check_result as b on a.apply_code =b.apply_code;quit;*/
/*x  "F:\share\����թ����\����թ͵����.xlsx"; */
/*filename DD DDE "EXCEL|[����թ͵����.xlsx]����+���!r2c1:r20000c21" notab;*/
/*data _null_;set aac;file DD;put apply_code '09'x �ͻ�����  '09'x �ſ����� '09'x ��ǩ  '09'x ��ǩ1*/
/*  ;run;*/
/**/
/*proc sort data = aac  out =aac1 nodupkey;by apply_code ;run;*/
/**/
/*filename DD DDE "EXCEL|[����թ͵����.xlsx]����+���_ȥ��!r2c1:r20000c21" notab;*/
/*data _null_;set aac1;file DD;put apply_code '09'x �ͻ�����  '09'x �ſ����� '09'x ��ǩ  '09'x ��ǩ1*/
/*  ;run;*/
