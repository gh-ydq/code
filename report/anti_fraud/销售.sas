
/*1.�����߲�����:��30����������ڵ��ڽ�30������ƽ����������5��
2.ͻ���߲�����:�����۽�15����������15��Ľ�����֮����ڵ��ڽ�30������ƽ����������2��;*/

option validvarname=any;
option compress=yes;
libname appRaw odbc  datasrc=approval_nf;
libname approval "D:\share\Datamart\ԭ��\approval";
libname account "D:\share\Datamart\ԭ��\account";
libname dta "D:\share\Datamart\�м��\daily";
libname his "D:\share\����թ����\��������";


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


/*��������*/
data problem_sales;
set appRaw.problem_sales;
run;


data apply_info;
set appraw.apply_info(where =(branch_name^=""));
keep apply_code SALES_CODE SALES_NAME;
run;
data contract;
set dta.app_loan_info(keep =apply_code name �ſ�����);
if �ſ�����^=.;
run;


proc sort data =contract nodupkey ;by apply_code;run;
proc sort data =apply_info nodupkey;by apply_code;run;

data apply_contract;
merge contract(in=a) apply_info;
by apply_code;
if a ;
run;

/*��30��ķſ�����*/
proc sql;
create table nearly_thirty(keep= apply_code name  SALES_CODE SALES_NAME �ſ�����)
as select a.*,b.* from apply_contract as a inner join problem_sales as b on a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

proc sort data = nearly_thirty;by SALES_NAME �ſ�����;run;

/*������Ϣ*/
data apply;
set dta.app_loan_info;
if  &std.<=����ʱ��<=&ed.;
if &std.<=����ʱ��<=&ed. then ����ʮ�����=1;
if &md.<=����ʱ��<=&ed. then  ��ʮ�������=1;
if &std.<=����ʱ��<&md. then ��ʮ�������=1;
keep apply_code name ����ʱ�� ����ʮ�����  ��ʮ������� ��ʮ�������;
run;
proc sort data = apply;by apply_code ;run;
data contact;
merge apply(in=a) apply_info;
by apply_code;
if a ;
run;

proc sql;
create table nearly_thirty_ind  as select SALES_CODE,SALES_NAME,sum(����ʮ�����)as ��ʮ�������
,sum(��ʮ�������)as ��ʮ���������,sum(��ʮ�������)as ��ʮ���������
from contact(where=(SALES_CODE^="1")) group by SALES_NAME,SALES_CODE;quit;

proc sql;
create table nearly_thirty_ave  as select SALES_CODE,SALES_NAME,��ʮ�������,��ʮ���������,��ʮ���������,avg(��ʮ�������)as ƽ�������� 
from nearly_thirty_ind ;quit;
/*�����߲�����*/
data sustain_high_sales;
set nearly_thirty_ave(where=(sum(��ʮ�������,-5*ƽ��������)>=0 ));
run;

data sustain_high_sales1;
set sustain_high_sales;
format ��ǩ$20.;
��ǩ="�����߲�����";
keep SALES_CODE SALES_NAME ��ǩ ��ʮ������� ƽ�������� ��ʮ��������� ��ʮ���������;
run;

proc sql;
create table sustain_high_sales_cli(where=(�ſ�����>=&std.)) as select a.*,b.apply_code,b.name,b.�ſ�����
from sustain_high_sales1 as a inner join apply_contract as b on a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

proc sort data= sustain_high_sales_cli;by SALES_NAME;run;
/*ͻ���߲�����*/
data sudden_high_sales;
set nearly_thirty_ave(where=(sum(��ʮ���������,-��ʮ���������,-2*ƽ��������)>=0 ));
run;

data sudden_high_sales1;
set sudden_high_sales;
format ��ǩ$20.;
��ǩ="ͻ���߲�����";
keep SALES_CODE SALES_NAME ��ǩ ��ʮ������� ƽ�������� ��ʮ��������� ��ʮ���������;
run;

proc sql;
create table sudden_high_sales_cli(where=(�ſ�����>=&std.)) as select a.*,b.apply_code,b.name,b.�ſ�����
from sudden_high_sales1 as a inner join apply_contract as b on a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

proc sort data= sudden_high_sales_cli;by SALES_NAME;run;


data problem_sales_cli;
set nearly_thirty;
format ��ǩ$20.;
��ǩ="��������";
run;

/*�Թ�����*/
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
create table nearly_thirty1(keep= apply_code name  SALES_CODE SALES_NAME �ſ�����)
as select a.*,b.* from apply_contract as a inner join company_account as b on 
a.SALES_NAME=b.SALES_NAME and a.SALES_CODE=b.SALES_CODE;quit;

data problem_sales_cli2;
set nearly_thirty1;
format ��ǩ$20.;
��ǩ="���¿ͻ�����Ϊ�Թ�";
run;
proc sort data = problem_sales_cli2; by SALES_NAME;run;
data sals ;
set  problem_sales_cli sudden_high_sales_cli sustain_high_sales_cli problem_sales_cli2;
contract_no = tranwrd(apply_code,"PL","C");
run;

proc sql;
create table sals_all as select  a.*,b.od_days,b.od_days_ever,c.branch_name,c.approve_��Ʒ,b.���֤����  from sals as a
left join repayfin.payment_daily(where=(cut_date=&dt.)) as b on a.contract_no = b.contract_no 
left join dta.app_loan_info as c on a.apply_code = c.apply_code ;quit;
proc sort data = approval.apply_emp out = apply_emp;by apply_code ;run;

data sals_all;
merge  sals_all(in = a) apply_emp(in=b);
by apply_code;
if a ;
format �Ƿ����� $10.;
if kindex( title,"����") or POSITION ="297" then �Ƿ�����="��";
else �Ƿ�����="��";
if od_days>0 then ״̬="��ǰ����";
else if od_days_ever>0 then ״̬="��ʷ����";
else ״̬="��������";
if �ſ�����>= &dt_mon.;
if kindex(branch_name,"ҵ������") =0;
format ����ʱ�� yymmdd10.;
����ʱ��= &std.;
����="����";
run;
proc sort data = sals_all;by ��ǩ SALES_CODE ;run;



 data hissals_all;
 set his.sals_all;
 run;

data sals_all1;
set hissals_all sals_all;
run;

proc sort data = sals_all1 nodupkey;by apply_code ��ǩ;run;

 data his.sals_all;
 set sals_all;
 run;





/*�����·�*/

data problem_sales;
set problem_sales;
��������="��";
run;

proc sql;
create table high_slaes_contact as select   SALES_CODE, SALES_NAME,��ʮ�������,ƽ��������
,��ʮ���������,��ʮ���������,branch_name,��ǩ,count(*) as �ſ���  from sals_all(where=(��ǩ in("�����߲�����","ͻ���߲�����") )) group by SALES_CODE, SALES_NAME,��ʮ�������,ƽ��������
,��ʮ���������,��ʮ���������,branch_name,��ǩ;quit;


proc sql;
create table high_slaes1 as select  a.*,b.��������  from high_slaes_contact as a left join problem_sales as b on a.SALES_CODE = b.SALES_CODE;quit;


/*�쳣����ͻ�*/

proc sql;
create table company_account1(where=(�ſ�����>mdy(8,1,2017))keep = apply_code name  �ſ����� CLEAR_DATE REPAY_AMOUNT REMARK )
as select a.*,b.* from contract as a right join company_account_pay_register as b on a.apply_code =b.apply_code;quit;

proc sort data = company_account1  ; by �ſ�����;run;

data company_account1;
set company_account1;
format ��ǩ$20.;
��ǩ="�쳣����ͻ�";
run;

proc sort data = approval.apply_emp out = apply_emp;by apply_code ;run;
proc sort data = company_account1 ;by apply_code;run;
proc sort data = repayfin.payment_daily(where=(Ӫҵ�� ^="APP")) out = payment_daily;by contract_no;run;
proc sort data = dta.app_loan_info out = app_loan_info;by apply_code;run;
data payment_daily;
set payment_daily(where=(cut_date=&dt.));
apply_code = tranwrd(contract_no,"C","PL");
drop �ſ�����;
run;

data company_account;
merge  company_account1(in = a) apply_emp(in=b) apply_info payment_daily app_loan_info;
by apply_code;
if a ;
format �Ƿ����� $10.;
if kindex( title,"����") or POSITION ="297" then �Ƿ�����="��";
else �Ƿ�����="��";
format ����ʱ�� yymmdd10.;
����ʱ��  =&dt.+1;
run;
data company;
set his.company_account;
���=1;
if ����ʱ��^=  &nt.;
run;

data company_account1;
set company company_account;
run;

proc sort data = company_account1 nodupkey;by ��ǩ apply_code SALES_CODE;run;

data company_account2;
set company_account1;
if ���=1 then delete;
�쳣����="�쳣����";
run;


filename DD DDE "EXCEL|[����թ����.xlsx]�쳣����!r2c1:r1000c20" notab;
data _null_;set company_account2;file DD;put �쳣���� '09'x branch_name '09'x ��ǩ  '09'x approve_��Ʒ '09'x SALES_CODE '09'x SALES_NAME 
'09'x �ſ����� '09'x apply_code '09'x ���֤���� '09'x name  '09'x �Ƿ����� 
  '09'x od_days '09'x od_days_ever '09'x CLEAR_DATE '09'x REPAY_AMOUNT '09'x REMARK;run;


/*�쳣����*/
data his.company_account;
set company_account1;
drop ���;

run;


x  "D:\share\����թ����\����թ����_�±�.xlsx"; 

filename DD DDE "EXCEL|[����թ����_�±�.xlsx]����!r2c1:r10000c20" notab;
data _null_;set sals_all;file DD;put ���� '09'x  branch_name  '09'x  ��ǩ  '09'x  approve_��Ʒ '09'x SALES_CODE '09'x SALES_NAME  '09'x �ſ����� 
'09'x apply_code '09'x  ���֤���� '09'x NAME 
'09'x od_days '09'x od_days_ever '09'x ״̬ '09'x �Ƿ�����;run;

filename DD DDE "EXCEL|[����թ����_�±�.xlsx]����_2!r2c1:r100c20" notab;
data _null_;set high_slaes1;file DD;put SALES_CODE '09'x SALES_NAME '09'x ��ʮ������� '09'x ƽ�������� '09'x ��ʮ��������� 
'09'x ��ʮ���������'09'x branch_name '09'x ��ǩ '09'x �������� '09'x �ſ���;run;
