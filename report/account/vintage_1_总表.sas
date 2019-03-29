/*option compress=yes validvarname=any;*/
/*libname approval 'E:\guan\ԭ����\approval';*/
/*libname credit  'E:\guan\ԭ����\cred';*/
/*libname res  'E:\guan\ԭ����\res';*/
/*libname eam  'E:\guan\ԭ����\account';*/
/*libname cusMid "E:\guan\�м��\repayfin";*/
/*libname repayFin "E:\guan\�м��\repayfin";*/

data _null_;
format dt yymmdd10.;
dt = today() - 1;
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
run;
/*%let dt=mdy(6,30,2017);*/

data apply_info;
set approval.apply_info
(keep = apply_code name id_card_no branch_code branch_name MANAGER_CODE MANAGER_NAME SALES_NAME SOURCE_BUSINESS SOURCE_CHANNEL LOAN_PURPOSE DESIRED_PRODUCT ACQUIRE_CHANNEL);
if branch_code = "6" then branch_name = "�Ϻ�����·Ӫҵ��";
else if branch_code = "13" then branch_name = "�Ϻ�����·Ӫҵ��";
else if branch_code = "16" then branch_name = "�������ֺ���·Ӫҵ��";
else if branch_code = "14" then branch_name = "�Ϸ�վǰ·Ӫҵ��";
else if branch_code = "15" then branch_name = "��������·Ӫҵ��";
else if branch_code = "17" then branch_name = "�ɶ��츮����Ӫҵ��";
else if branch_code = "50" then branch_name = "���ݵ�һӪҵ��";
else if branch_code = "55" then branch_name = "�����е�һӪҵ��";
else if branch_code = "57" then branch_name = "���ݽ�����·Ӫҵ��";
else if branch_code = "56" then branch_name = "�����е�һӪҵ��";
else if branch_code = "118" then branch_name = "�����е�һӪҵ��";
else if branch_code = "65" then branch_name = "��³ľ���е�һӪҵ��";
else if branch_code = "63" then branch_name = "����е�һӪҵ��";
else if branch_code = "60" then branch_name = "���ͺ����е�һӪҵ��";
else if branch_code = "93" then branch_name = "Ȫ���е�һӪҵ��";
else if branch_code = "122" then branch_name = "֣���е�һӪҵ��";
else if branch_code = "91" then branch_name = "����е�һӪҵ��";
else if branch_code = "90" then branch_name = "�����е�һӪҵ��";
else if branch_code = "71" then branch_name = "�����е�һӪҵ��";
else if branch_code = "72" then branch_name = "�����е�һӪҵ��";
else if branch_code = "73" then branch_name = "�����е�һӪҵ��";
else if branch_code = "74" then branch_name = "�Ͼ��е�һӪҵ��";
else if branch_code = "75" then branch_name = "�����е�һӪҵ��";
else if branch_code = "89" then branch_name = "�����е�һӪҵ��";
else if branch_code = "50" then branch_name = "�����е�һӪҵ��";
else if branch_code = "117" then branch_name = "�γ���ҵ������";
else if branch_code = "116" then branch_name = "��ͨ��ҵ������";
else if branch_code = "114" then branch_name = "��ɽҵ������";
else if branch_code = "115" then branch_name = "������ҵ������";
else if branch_code = "119" then branch_name = "�人��ҵ������";
else if branch_code = "120" then branch_name = "�����ҵ������";
else if branch_code = "136" then branch_name = "��ɽ�е�һӪҵ��";

if kindex(branch_name,"����")  then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"����") and kindex(branch_name,"ҵ������") then branch_name="������ҵ������";
else if kindex(branch_name,"��ɽ") then branch_name="��ɽ�е�һӪҵ��";
else if kindex(branch_name,"�γ�") then branch_name="�γ��е�һӪҵ��";
else if kindex(branch_name,"տ��") then branch_name="տ���е�һӪҵ��";
else if kindex(branch_name,"�人") then branch_name="�人�е�һӪҵ��";
else if kindex(branch_name,"���") then branch_name="����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"�����") then branch_name="������е�һӪҵ��";
else if kindex(branch_name,"��ͷ") then branch_name="��ͷ�е�һӪҵ��";
else if kindex(branch_name,"���") then branch_name="����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";

rename branch_name = Ӫҵ��;

run;

data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE")); /*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
input_complete=1;/*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
format �������� yymmdd10.;
�������� = datepart(create_time_);
�����·� = put(datepart(create_time_), yymmn6.);
rename bussiness_key_ = apply_code create_time_ = apply_time;
keep bussiness_key_ create_time_ input_complete �������� �����·�;
run;
proc sort data = apply_time dupout = a nodupkey; by apply_code apply_time; run;
proc sort data = apply_time nodupkey; by apply_code; run;
proc sort data = apply_info nodupkey; by apply_code; run;
data apply_time;
merge apply_time(in = a) apply_info(in = b);
by apply_code;
if b;
if ��������<=&dt.;
run;
data act_ru_execution;
set approval.act_ru_execution(keep = business_key_ act_id_);
run;
data act_hi_procinst;
set approval.act_hi_procinst(keep = business_key_ end_act_id_);
run;
proc sort data = act_hi_procinst nodupkey; by business_key_; run;
proc sort data = act_ru_execution nodupkey; by business_key_; run;
data cur_status;
merge act_hi_procinst(in = a) act_ru_execution(in = b);
by business_key_;
if a;
format ��ǰ״̬ $10.;
	 if end_act_id_ = "cancleEvent" then ��ǰ״̬ = "ȡ��";
else if end_act_id_ = "refuseEvent" or act_id_ = "refuse" then ��ǰ״̬ = "�ܾ�";
else if end_act_id_ = "endEvent" then ��ǰ״̬ = "����";
else if act_id_ = "registerTask" then ��ǰ״̬ = "������";
else if act_id_ = "checkTask" then ��ǰ״̬ = "������";
else if act_id_ = "inputTask" then ��ǰ״̬ = "������";
else if act_id_ = "inputCheckTask" then ��ǰ״̬ = "������";
else if act_id_ = "firstVerifyTask" then ��ǰ״̬ = "������";
else if act_id_ = "finalVerifyTask" then ��ǰ״̬ = "������";
else if act_id_ = "finalReturnTask" then ��ǰ״̬ = "������";
else if act_id_ = "verifyReturnTask" then ��ǰ״̬ = "������";
else if act_id_ = "signContractTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "uploadContractTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "contractCheckTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "modifyCardTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "deductAgainTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "deductTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "firstReviewTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "finalReviewTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "genFundExcelTask" then ��ǰ״̬ = "ͨ��";
else if act_id_ = "loanTask" then ��ǰ״̬ = "ͨ��";
else ��ǰ״̬ = "δ֪";

rename business_key_ = apply_code; 
run;

data check_result_first;
set approval.approval_check_result(where = (period in ("firstVerifyTask","finalReturnTask")));
drop period CREATED_USER_ID UPDATED_USER_ID opinion;
rename check_result_type = check_result_first approved_product = app_prd_first approved_product_name = app_prdname_first 
		approved_sub_product = app_sub_prd_first approved_sub_product_name = app_sub_prdname_first loan_life = loan_life_first 
		loan_amount = loan_amt_first created_user_name = created_name_first updated_user_name = updated_name_first 
		created_time = created_time_first updated_time = updated_time_first;
run;
proc sort data = check_result_first nodupkey; by apply_code descending id; run;
proc sort data = check_result_first(drop = id) nodupkey; by apply_code; run;

/*���������������*/
data check_result_final;
set approval.approval_check_result(where = (period = "finalVerifyTask"));
drop period CREATED_USER_ID UPDATED_USER_ID opinion;
rename check_result_type = check_result_final approved_product = app_prd_final approved_product_name = app_prdname_final 
		approved_sub_product = app_sub_prd_final approved_sub_product_name = app_sub_prdname_final loan_life = loan_life_final
		loan_amount = loan_amt_final created_user_name = created_name_final updated_user_name = updated_name_final
		created_time = created_time_final updated_time = updated_time_final;
run;
proc sort data = check_result_final nodupkey; by apply_code descending id; run;
proc sort data = check_result_final(drop = id) nodupkey; by apply_code; run;

/*�����������*/
data check_result;
merge check_result_first(in = a) check_result_final(in = b);
by apply_code;
if a;
format check_result $10.;
	 if check_result_final = "ACCEPT" then check_result = "ACCEPT";
else if check_result_final = "REFUSE" or check_result_first = "REFUSE" then check_result = "REFUSE";
else if check_result_final = "CANCEL" or check_result_first = "CANCEL" then check_result = "CANCEL";
else if check_result_final = "BACK" or check_result_first = "BACK" then check_result = "BACK";
else check_result = "INDET";

format check_date yymmdd10.;
	 if check_result_final in ("REFUSE", "ACCEPT") then check_date = datepart(created_time_final);
else if check_result_first = "REFUSE" then check_date = datepart(created_time_first); 
�����·�  = put(check_date, yymmn6.);
�������� = put(check_date, yymmdd10.);
check_week = week(check_date); /*�����ܣ�һ�굱�еĵڼ���*/
if check_result = "ACCEPT" then ͨ�� = 1;
if check_result = "REFUSE" then �ܾ� = 1;
rename check_result = ����״̬ app_prdname_final = ���˲�Ʒ����_���� app_sub_prdname_final = ���˲�ƷС��_����
		loan_amt_final = ���˽��_���� loan_life_final = ��������_����;
run;

proc sort data=check_result;by apply_code;run;
proc sort data=apply_time;by apply_code;run;
proc sort data=cur_status;by apply_code;run;
*ȥ����һЩ���ģ��Ժ�Ҫ�õĻ��ٿ�;
data approval;
merge check_result(in=a) apply_time(in=b) cur_status(in=c);
by apply_code;
if b;
if ͨ��=. and �ܾ�=. then check_end=0;
else check_end=1;
format approve_��Ʒ $20.;
if ���˲�Ʒ����_����^="" then approve_��Ʒ=���˲�Ʒ����_����;
else if  app_prdname_first^="" then approve_��Ʒ= app_prdname_first;
else approve_��Ʒ=DESIRED_PRODUCT;
����=year(check_date)-ksubstr(ID_CARD_NO,7,4);
if approve_��Ʒ="Ebaotong" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="Salariat" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="Elite" then approve_��Ʒ="U��ͨ";
else if approve_��Ʒ="Eshetong" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="Ewangtong" then approve_��Ʒ="E��ͨ";
else if  approve_��Ʒ="Efangtong" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="RFElite" then approve_��Ʒ="U��ͨ����";
else if approve_��Ʒ="RFEbaotong" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="RFEshetong" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="RFSalariat" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="RFEwangtong" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="Ebaotong-zigu" then approve_��Ʒ="E��ͨ-�Թ�";
else if approve_��Ʒ="Ezhaitong" then approve_��Ʒ="Eլͨ";
else if approve_��Ʒ="Ezhaitong-zigu" then approve_��Ʒ="Eլͨ-�Թ�";

else if approve_��Ʒ="Eweidai" then approve_��Ʒ="E΢��";
else if approve_��Ʒ="Eweidai-zigu" then approve_��Ʒ="E΢��-�Թ�";
else if approve_��Ʒ="Eweidai-NoSecurity" then approve_��Ʒ="E΢��-���籣";
else if approve_��Ʒ="Easy-ZhiMa" then approve_��Ʒ="Easy��֥���";
else if approve_��Ʒ="Easy-CreditCard" then approve_��Ʒ="Easy�����ÿ�";

if kindex(DESIRED_PRODUCT,"RF") and not kindex(approve_��Ʒ,"����") then pproduct_code=compress(approve_��Ʒ||"����") ;
if pproduct_code^="" then approve_��Ʒ=pproduct_code;

keep APPLY_CODE REFUSE_INFO_NAME REFUSE_INFO_NAME_LEVEL1 REFUSE_INFO_NAME_LEVEL2 REFUSE_INFO2_NAME REFUSE_INFO2_NAME_LEVEL1 
REFUSE_INFO2_NAME_LEVEL2 REFUSE_INFO3_NAME REFUSE_INFO3_NAME_LEVEL1 REFUSE_INFO3_NAME_LEVEL2 BACK_REASON_NAME BACK_INFO CANCEL_INFO_NAME
created_name_first created_time_first ��������_���� ���˽��_���� created_name_final created_time_final ����״̬ check_date �����·� ��������
NAME ID_CARD_NO Ӫҵ�� MANAGER_NAME �����·� �������� ��ǰ״̬ approve_��Ʒ check_end SALES_NAME ���� DESIRED_PRODUCT ���˲�Ʒ����_����; 
run;
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
data education;
set res.optionitem(where = (groupCode = "EDUCATION"));
keep itemCode itemName_zh;
run;
data gender;
set res.optionitem(where = (groupCode = "GENDER"));
keep itemCode itemName_zh;
run;
data marriage;
set res.optionitem(where = (groupCode = "MARRIAGE"));
keep itemCode itemName_zh;
run;
data house_property;
set res.optionitem(where = (groupCode = "PROPERTYTYPE"));
keep itemCode itemName_zh;
run;
data comp_type;
set res.optionitem(where = (groupCode = "COMPTYPE"));
keep itemCode itemName_zh;
run;
data position;
set res.optionitem(where = (groupCode = "POSITION"));
keep itemCode itemName_zh;
run;
data PERMANENT_TYPE;
set res.optionitem(where = (groupCode = "RegisteredType"));
keep itemCode itemName_zh;
run;

data apply_base;
set approval.apply_base(keep = apply_code PHONE1 RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_TYPE
							PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION LOCAL_RES_YEARS EDUCATION MARRIAGE GENDER RESIDENCE_ADDRESS PERMANENT_ADDRESS );
/*RESIDENCE-��סַ PERMANENT-������ַ*/
run;
proc sql;
create table base_info as
select a.*, b.itemName_zh as ��סʡ, c.itemName_zh as ��ס��, d.itemName_zh as ��ס��,
			e.itemName_zh as ����ʡ, f.itemName_zh as ������, g.itemName_zh as ������,
			h.itemName_zh as ס������, i.itemName_zh as �����̶�, j.itemName_zh as ����״��, k.itemName_zh as �Ա�,l.itemName_zh as ��������
from apply_base as a
left join province as b on a.RESIDENCE_PROVINCE = b.itemCode
left join city as c on a.RESIDENCE_CITY = c.itemCode
left join region as d on a.RESIDENCE_DISTRICT = d.itemCode
left join province as e on a.PERMANENT_ADDR_PROVINCE = e.itemCode
left join city as f on a.PERMANENT_ADDR_CITY = f.itemCode
left join region as g on a.PERMANENT_ADDR_DISTRICT = g.itemCode
left join house_property as h on a.LOCAL_RESCONDITION = h.itemCode
left join education as i on a.EDUCATION = i.itemCode
left join marriage as j on a.MARRIAGE = j.itemCode
left join gender as k on a.GENDER = k.itemCode
left join PERMANENT_TYPE as l on a.PERMANENT_TYPE = l.itemCode;
quit;
data apply_assets;
set approval.apply_assets(keep = apply_code HOUSING_PROPERTY);
run;
proc sql;
create table assets_info as
select a.*, b.itemName_zh as ��������
from apply_assets as a
left join house_property as b on a.housing_property = b.itemCode
;
quit;
/*---------------------��¼��CCOC�� start-------------------------------------*/
proc import out = ccoc datafile = "E:\guan\���ձ���\��ǰ��������\�Ѳ�¼CCOC��.xls" dbms = excel replace;
	getnames = yes;
run;

data industry;
set res.optionitem(where = (groupCode = "industry-1"));
keep itemCode itemName_zh;
run;
data CC;
set res.optionitem(where = (groupCode = "industry-2"));
keep itemCode itemName_zh;
run;
data OC;
set res.optionitem(where = (groupCode = "OC"));
keep itemCode itemName_zh;
run;

proc sql;
create table ccoc_info as
select a.apply_code, b.itemName_zh as �����, c.itemName_zh as CC��, d.itemName_zh as OC��
from ccoc as a
left join industry as b on a.industry_code = b.itemCode
left join CC as c on a.cc_code = c.itemCode
left join OC as d on a.oc_code = d.itemCode
;
quit;
/*---------------------��¼��CCOC�� start-------------------------------------*/

data apply_emp;
set approval.apply_emp(keep = apply_code COMP_NAME position comp_type COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT START_DATE_4_PRESENT_COMP
							CURRENT_INDUSTRY WORK_YEARS COMP_ADDRESS TITLE);
run;
proc sql;
create table emp_info as
select a.*, b.itemName_zh as ����ʡ, c.itemName_zh as ������, d.itemName_zh as ������,
			e.itemName_zh as ְ��, c.itemName_zh as ��λ����
from apply_emp as a
left join province as b on a.COMP_ADDR_PROVINCE = b.itemCode
left join city as c on a.COMP_ADDR_CITY = c.itemCode
left join region as d on a.COMP_ADDR_DISTRICT = d.itemCode
left join position as e on a.position = e.itemCode
left join comp_type as f on a.comp_type = f.itemCode
;
quit;

data apply_ext_data;
set approval.apply_ext_data(keep = apply_code INDUSTRY_NAME CC_NAME OC_NAME);
run;



data apply_balance;
set approval.apply_balance(keep = apply_code yearly_income monthly_salary monthly_other_income monthly_expense PUBLIC_FUNDS_RADICES SOCIAL_SECURITY_RADICES);
run;

data debt_ratio;
set approval.debt_ratio(keep = apply_no loan_month_return card_used_amt_sum social_security_month fund_month bank_flow_month
							other_income_month liability_month debt_ratio UPDATED_TIME);
rename apply_no = apply_code;
run;

data liability_ratio;
set approval.liability_ratio(keep = apply_no loan_month_return card_used_amt_sum SEMI_CARD_OVERDRAFT_BALANCE verify_income VERIFY_PAYROLL_CREDIT 
								  OTHER_LIABILITIES ratio NEW_RATIO);
rename apply_no = apply_code
       loan_month_return=loan_month_return_new
       card_used_amt_sum=card_used_amt_sum_new;
run;



proc sort data = apply_info nodupkey; by apply_code; run;
proc sort data = base_info nodupkey; by apply_code; run;
proc sort data = emp_info nodupkey; by apply_code; run;
proc sort data = apply_ext_data nodupkey; by apply_code; run;
proc sort data = apply_balance nodupkey; by apply_code; run;
proc sort data = debt_ratio nodupkey; by apply_code descending UPDATED_TIME; run;
proc sort data = debt_ratio(drop = UPDATED_TIME) nodupkey; by apply_code; run;
proc sort data = assets_info nodupkey; by apply_code; run;
proc sort data = ccoc_info nodupkey; by apply_code; run;
proc sort data = liability_ratio nodupkey; by apply_code; run;

data cusMid.customer_info;
merge apply_time(in = a) base_info(in = b) emp_info(in = c) apply_ext_data(in = d) 
apply_balance(in = e) debt_ratio(in = f) assets_info(in = g) ccoc_info(in = h)  liability_ratio(in=i) ;
by apply_code;
if a;
if ס������ = "" then ס������ = ��������;
if INDUSTRY_NAME = "" then INDUSTRY_NAME = �����;
if fund_month=. then fund_month=PUBLIC_FUNDS_RADICES;
if social_security_month=. then social_security_month=SOCIAL_SECURITY_RADICES;
if CC_NAME = "" then CC_NAME = CC��;
if OC_NAME = "" then OC_NAME = OC��;
if loan_month_return_new>0 then loan_month_return=loan_month_return_new;
if card_used_amt_sum_new>0 then card_used_amt_sum=card_used_amt_sum_new;
RATIO = RATIO*100;
NEW_RATIO = NEW_RATIO*100;
�����ܸ�ծ�ܼ� = sum(loan_month_return ,CARD_USED_AMT_SUM ,SEMI_CARD_OVERDRAFT_BALANCE);
format ��ر�ǩ $20.;
if ������="" or ������="" then ��ر�ǩ="����ȱʧ";
else if ������^=������ then ��ر�ǩ="���";
else ��ر�ǩ="����";
rename loan_month_return = �����»� CARD_USED_AMT_SUM = ���ÿ��»� SOCIAL_SECURITY_MONTH = �籣���� FUND_MONTH = ��������� SEMI_CARD_OVERDRAFT_BALANCE = ׼���ǿ��»�
		BANK_FLOW_MONTH = ��������ˮ OTHER_INCOME_MONTH = ���������� LIABILITY_MONTH = ���¸�ծ debt_ratio = ���¸�ծ��  RATIO = �ⲿ��ծ��
		VERIFY_INCOME = ��ʵ���� VERIFY_PAYROLL_CREDIT = ��ʵ�������� OTHER_LIABILITIES = ������ծ  NEW_RATIO = ��ծ�� COMP_NAME=��λ���� TITLE=ְλ;
drop RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION 
	EDUCATION MARRIAGE GENDER HOUSING_PROPERTY position comp_type COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT ����� CC�� OC��;
run;


/*�������� ���Ƶ��ڲ�ѯ����*/
proc sort data=credit.credit_info_base out=report_date(keep=report_number real_name report_date CREDIT_VALID_ACCT_SUM) nodupkey; by report_number; run;
data report_data;
set report_date;
format report_date_ yymmdd10.;
report_date_=report_date;
run;
/*���ÿ�������ϸ���ϱ�������*/
proc sort data=credit.credit_detail out=credit_detail; by report_number; run;
data credit_detail;
merge credit_detail(in=a) report_date(in=b);
by report_number;
if a;
open_month = intck("month", DATE_OPENED, report_date_);
if DATE_OPENED >= intnx("month", report_date_, -6, "same") then in6month = 1; else in6month = 0;
if DATE_OPENED >= intnx("month", report_date_, -24, "same") then in24month = 1; else in24month = 0;
if credit_line_amt=. then credit_line_amt=0;
if usedcredit_line_amt=. then usedcredit_line_amt=0;
run;

data card_detail;
set credit_detail(where=(SUB_BUSI_TYPE="���ǿ�"));
run;

proc sql;
create table card_pastdue_total as
select report_number, sum(PASTDUE_AMT) as card_pastdue_total
from card_detail
group by report_number
;
quit;


data loan_detail;
set credit_detail(where=(BUSI_TYPE="LOAN"));
if LOAN_BALANCE=. then LOAN_BALANCE=0;
if index(sub_busi_type, "����") or index(sub_busi_type, "���÷�") or index(sub_busi_type, "ס��") then ��Ѻ���� = 1;else ��Ѻ���� =0;
if not(index(sub_busi_type, "����") or index(sub_busi_type, "���÷�") or index(sub_busi_type, "ס��") 
or index(sub_busi_type, "��ѧ") or index(sub_busi_type, "ũ��") )then do;
  if index(sub_busi_type,"����") and  LOAN_BALANCE =CREDIT_LINE_AMT and DATE_OPENED ^=DATE_CLOSED then �޵�Ѻ����=0;
  else �޵�Ѻ����=1;
end;
run;

proc sql;
create table loan_pastdue_sum as
select report_number, sum(pastdue_amt) as loan_pastdue_sum,sum(�޵�Ѻ����) as �޵�Ѻ����,sum(��Ѻ����) as ��Ѻ����
from loan_detail
group by report_number
;
quit;
proc sort data = credit.credit_report(keep=report_number id_card created_time) out = credit_report nodupkey; by report_number; run;
proc sql;
create table  pboc_info_pre as
select a.*,datepart(a.created_time) as ���Ż�ȡʱ�� format=yymmdd10.,
b.card_pastdue_total as ���ÿ���ǰ���ڽ��,c.loan_pastdue_sum as ���ǰ���ڽ��,c.��Ѻ����,c.�޵�Ѻ����,
sum(b.card_pastdue_total,c.loan_pastdue_sum) as ��ǰ���ڽ���ܼ� from credit_report as a
left join card_pastdue_total as b on a.report_number=b.report_number
left join loan_pastdue_sum as c on a.report_number=c.report_number;
quit;
proc sql;
create table pboc_info as
select a.apply_code, b.*
from apply_time as a
inner join pboc_info_pre as b on a.id_card_no = b.id_card and datepart(a.apply_time) >= b.���Ż�ȡʱ��
;
quit;
proc sort data = pboc_info nodupkey; by apply_code descending ���Ż�ȡʱ��; run;
proc sort data = pboc_info  nodupkey; by apply_code; run;

data query_in3month;
set credit.credit_derived_data(keep = REPORT_NUMBER SELF_QUERY_03_MONTH_FREQUENCY_SA  CARD_APPLY_03_MONTH_FREQUENCY_SA CARD_60_PASTDUE_FREQUENCY
LOAN_GUARANTEE_QUERY_03_MONTH_FR LOAN_GUARANTEE_QUERY_24_MONTH_FR CARD_APPLY_24_MONTH_FREQUENCY CARD_CREDIT_LINE_AMT_SUM CARD_USEDCREDIT_LINE_AMT_SUM CARD_OVER_100PCT
SELF_QUERY_24_MONTH_FREQUENCY LOAN_GUARANTEE_QUERY_01_MONTH_FR CARD_APPLY_01_MONTH_FREQUENCY_SA SELF_QUERY_01_MONTH_FREQUENCY_SA
CARD_60_PASTDUE_M3_FREQUENCY LOAN_MORTGAGE_60_PASTDUE_FREQUEN LOAN_MORTGAGE_PASTDUE_M3_FREQUEN LOAN_NAMORTGAGE_60_PASTDUE_FREQU LOAN_NAMORTGAGE_PASTDUE_M3_FREQU 
LOAN_OTHER_60_PASTDUE_FREQUENCY LOAN_OTHER_PASTDUE_M3_FREQUENCY SELF_QUERY_06_MONTH_FREQUENCY);
rename  LOAN_GUARANTEE_QUERY_03_MONTH_FR = ��3���´����ѯ����
		SELF_QUERY_03_MONTH_FREQUENCY_SA = ��3���±��˲�ѯ����
		CARD_APPLY_03_MONTH_FREQUENCY_SA=��3�������ÿ���ѯ����
		LOAN_GUARANTEE_QUERY_24_MONTH_FR=��2������ѯ����
CARD_APPLY_24_MONTH_FREQUENCY=��2�����ÿ���ѯ����
SELF_QUERY_24_MONTH_FREQUENCY=��2����˲�ѯ����
CARD_60_PASTDUE_FREQUENCY=���ǿ���5�����ڴ���
CARD_60_PASTDUE_M3_FREQUENCY=���ǿ���5������90���ϴ���
LOAN_MORTGAGE_60_PASTDUE_FREQUEN=��Ѻ�����5�����ڴ���
LOAN_MORTGAGE_PASTDUE_M3_FREQUEN=��Ѻ�����5������90�����ϴ���
LOAN_NAMORTGAGE_60_PASTDUE_FREQU=�޵�Ѻ�����5�����ڴ���
LOAN_NAMORTGAGE_PASTDUE_M3_FREQU=�޵�Ѻ�����5������90�����ϴ���
LOAN_OTHER_60_PASTDUE_FREQUENCY=�������ʴ����5�����ڴ���
LOAN_OTHER_PASTDUE_M3_FREQUENCY=�������ʴ����5������90������
LOAN_GUARANTEE_QUERY_01_MONTH_FR=��1���´����ѯ����
CARD_APPLY_01_MONTH_FREQUENCY_SA=��1�������ÿ���ѯ����
CARD_OVER_100PCT=���ÿ�ʹ����
CARD_CREDIT_LINE_AMT_SUM=���ÿ��ܶ�
CARD_USEDCREDIT_LINE_AMT_SUM=���ÿ�͸֧�ܶ�
SELF_QUERY_06_MONTH_FREQUENCY=��6���±��˲�ѯ����
SELF_QUERY_01_MONTH_FREQUENCY_SA=��1���±��˲�ѯ����;
run;

proc sql;
create table pboc_info1 as
select a.*,b.��3���±��˲�ѯ����,b.��3���´����ѯ����,b.��2������ѯ����,b.��2�����ÿ���ѯ����,b.��3�������ÿ���ѯ����,b.���ÿ�ʹ����,b.���ÿ��ܶ�,b.���ÿ�͸֧�ܶ�,
b.���ǿ���5�����ڴ���,b.���ǿ���5������90���ϴ���,b.��Ѻ�����5�����ڴ���,b.��Ѻ�����5������90�����ϴ���,b.�޵�Ѻ�����5�����ڴ���,b.�޵�Ѻ�����5������90�����ϴ���,
b.�������ʴ����5�����ڴ���,b.�������ʴ����5������90������,b.��6���±��˲�ѯ����,
b.��2����˲�ѯ����,b.��1���´����ѯ����,b.��1�������ÿ���ѯ����,b.��1���±��˲�ѯ���� from pboc_info as a
left join query_in3month as b on a.REPORT_NUMBER=b.REPORT_NUMBER;
quit;
proc sort data=pboc_info1 nodupkey;by apply_code;run;


data payment1;
set repayfin.payment1;
run;

data payment_wj;
set payment1(where = (cut_date =&dt. and Ӫҵ��^="APP")
					  keep = contract_no apply_code �ͻ����� cut_date 
LOAN_DATE PERIOD  COMPLETE_PERIOD od_days_ever mob  outstanding ���֤���� od_days ��ƷС�� ��Ʒ���� Ӫҵ�� es od_periods);
if od_days_ever < od_days then od_days_ever = od_days;
�ſ��·�=put(LOAN_DATE,yymmn6.);
format status $24.;
if es = 1 then status = "09_ES";
else if mob = 0 then status = "00_NB";
else if od_periods < 1 then status = "01_C";
else if od_days <= 30 then status = "02_M1";
else if od_days <= 60 then status = "03_M2";
else if od_days <= 90 then status = "04_M3";
else if od_days <= 120 then status = "05_M4";
else if od_days <= 150 then status = "06_M5";
else if od_days <= 180 then status = "07_M6";
else if od_days > 180 then status = "08_M6+";

rename loan_date = �ſ����� outstanding=������� PERIOD=���� COMPLETE_PERIOD=�ѻ�����  LOAN_DATE=�ſ����� 
od_days=��ǰ�������� od_days_ever=������������;
run;
proc sort data=payment_wj nodupkey;by contract_no;run;
*approval cusMid.customer_info pboc_info 
*�ܾ���;
proc sql;
create table repayfin.big_table as
select b.contract_no,b.��ƷС��,a.NAME as �ͻ�����,b.����,b.�ѻ�����,b.�ſ�����,a.apply_code,a.Ӫҵ��,b.��Ʒ����,b.mob,b.status,a.��������,a.�������� as ����ʱ��,a.���˲�Ʒ����_����,
b.��ǰ��������,b.������������,b.�ſ��·�,e.group_level as ��Ⱥ ,e.risk_level as ���յȼ�,a.����,c.RESIDENCE_ADDRESS as ��ס��ϸ��ַ,c.PERMANENT_ADDRESS as ������ϸ��ַ,
c.��סʡ,c.��ס��,c.��ס��,c.����ʡ,c.������,c.������,c.ס������,c.�����̶�,c.����״��,c.�Ա�,c.��λ����,c.COMP_ADDRESS as ��λ��ϸ��ַ,c.��ر�ǩ,
c.����ʡ as ��λʡ,c.������ as ��λ��,c.������ as ��λ��,c.ְλ,c.ְ��,c.INDUSTRY_NAME,c.cc_name,c.oc_name,c.�����»�,c.���ÿ��»�,c.�籣����,c.���������,
c.��������ˮ,c.����������,c.���¸�ծ,c.���¸�ծ��,c.׼���ǿ��»�,c.��ʵ����,c.��ʵ��������,c.������ծ,c.�ⲿ��ծ��,c.��ծ��,c.�����ܸ�ծ�ܼ�,c.��������,
d.��3���´����ѯ����,d.��3���±��˲�ѯ����,d.���ÿ���ǰ���ڽ��,d.���ǰ���ڽ��,d.��ǰ���ڽ���ܼ�,a.created_name_first as ����,d.��6���±��˲�ѯ����,
a.created_time_first as ����ʱ��,a.���˽��_���� as �������,a.created_name_final as ����,a.created_time_final as ����ʱ��,a.MANAGER_NAME as �Ŷӳ�,
a.SALES_NAME as �ͻ�����,a.����״̬,a.�����·�,a.REFUSE_INFO_NAME,a.REFUSE_INFO_NAME_LEVEL1,a.REFUSE_INFO_NAME_LEVEL2,a.approve_��Ʒ,a.DESIRED_PRODUCT,a.ID_CARD_NO,
d.��2������ѯ����,d.��2�����ÿ���ѯ����,d.��2����˲�ѯ����,d.��1���´����ѯ����,d.��1�������ÿ���ѯ����,d.��1���±��˲�ѯ����,d.��3�������ÿ���ѯ����,d.��Ѻ����,d.�޵�Ѻ����,
d.���ÿ�ʹ����,d.���ÿ��ܶ�,d.���ÿ�͸֧�ܶ�,d.���ǿ���5�����ڴ���,d.���ǿ���5������90���ϴ���,d.��Ѻ�����5�����ڴ���,d.��Ѻ�����5������90�����ϴ���,
d.�޵�Ѻ�����5�����ڴ���,d.�޵�Ѻ�����5������90�����ϴ���,d.�������ʴ����5�����ڴ���,d.�������ʴ����5������90������
from approval as a
left join payment_wj as b on a.apply_code=b.apply_code
left join cusmid.Customer_info as c on a.apply_code=c.apply_code
left join pboc_info1 as d on a.apply_code=d.apply_code
left join approval.credit_score as e on a.apply_code=e.apply_code;
quit;
