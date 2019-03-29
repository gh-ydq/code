
option compress=yes validvarname=any;
libname approval "D:\share\Datamart\ԭ��\approval";
libname dta "D:\share\Datamart\�м��\daily";
libname appraw odbc  datasrc=approval_nf;
libname res odbc  datasrc=res_nf;
libname credit "D:\share\Datamart\ԭ��\credit";

data macrodate;
format date  start_date  fk_month_begin month_begin  end_date  yymmdd10.;*����ʱ�������ʽ;
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(8,22,2017);*/
call symput("tabledate",date);*����һ����;
start_date = intnx("month",date,-1,"b");
call symput("start_date",start_date);
month_begin=intnx("month",date,0,"b");
call symput("month_begin",month_begin);
if day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));
end_date = mdy(month(date)+1,25,year(date));end;
else do;fk_month_begin = mdy(month(date)-1,26,year(date));
end_date = mdy(month(date),25,year(date));end;
call symput("fk_month_begin",fk_month_begin);
call symput("end_date",end_date);
run;

data apply_dept;
set approval.apply_info(keep= apply_code BRANCH_NAME branch_code DESIRED_PRODUCT NAME SOURCE_CHANNEL);
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
run;

data apply_dept;
set apply_dept ;
if branch_name ="��˾����" then delete;
run;
proc sort data = apply_dept nodupkey;by apply_code ;run;

/*��������*/
data apply;
set approval.act_opt_log(where = (task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE")); /*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
format ����ʱ�� YYMMDD10.;
����ʱ��=datepart(create_time_);
����=1;
keep bussiness_key_ ����ʱ�� ����;
rename bussiness_key_ = apply_code ;
run;
proc sort data = apply dupout = a nodupkey; by apply_code ����ʱ��; run;
proc sort data = apply nodupkey; by apply_code; run;

data dta.apply;
set apply;
run;


/*��������*/
data back;
set approval.approval_check_result(where=(BACK_NODE in ("verifyReturnTask","inputCheckTask")));
format �����ŵ�ʱ�� YYMMDD10.;
�����ŵ�ʱ��=datepart(CREATED_TIME);
�����ŵ�=1;
keep APPLY_CODE �����ŵ�ʱ�� �����ŵ�;
run;
proc sort data=back;by APPLY_CODE �����ŵ�ʱ��;run;
proc sort data=back nodupkey;by APPLY_CODE;run;

data dta.back;
set back ;
run;

/*ÿ�����ӵ�ǰ״̬*/
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
else if act_id_ = "channelConfirmTask" then ��ǰ״̬ = "ͨ��";
else ��ǰ״̬ = "δ֪";
rename business_key_ = apply_code; 
/*keep business_key_ ��ǰ״̬;*/
run;
data dta.cur_status;
set cur_status;
run;

/*���������������*/
data check_result_first;
set approval.approval_check_result(where = (period in( "firstVerifyTask","finalReturnTask")));
drop period CREATED_USER_ID UPDATED_USER_ID opinion;
rename check_result_type = check_result_first approved_product = app_prd_first approved_product_name = app_prdname_first 
		approved_sub_product = app_sub_prd_first approved_sub_product_name = app_sub_prdname_first loan_life = loan_life_first 
		loan_amount = loan_amt_first created_user_name = created_name_first updated_user_name = updated_name_first 
		created_time = created_time_first updated_time = updated_time_first PROPOSE_LIMIT=PROPOSE_LIMIT_first;
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
		created_time = created_time_final updated_time = updated_time_final REFUSE_INFO_NAME=REFUSE_INFO_NAME_final
		REFUSE_INFO_NAME_LEVEL1=REFUSE_INFO_NAME_LEVEL1_final REFUSE_INFO_NAME_LEVEL2=REFUSE_INFO_NAME_LEVEL2_final PROPOSE_LIMIT=PROPOSE_LIMIT_final;
run;
proc sort data = check_result_final nodupkey; by apply_code  id; run;
data check_result_final;
set check_result_final;
retain created_name_final1;
by apply_code;
if first.apply_code then created_name_final1=lag(created_name_final);
if created_name_final ="�Ľ�" then created_name_final =created_name_final1;
drop created_name_final1;
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
if ͨ��=. and �ܾ�=. then check_end=0;
else check_end=1;
rename check_result = ����״̬ app_prdname_final = ���˲�Ʒ����_���� app_sub_prdname_final = ���˲�ƷС��_����
		loan_amt_final = ���˽��_���� loan_life_final = ��������_����;
/*��Ʒ��Ϣ*/
if app_prdname_final^=""  then approve_��Ʒ=app_prdname_final;
else if  app_prdname_first^="" then approve_��Ʒ= app_prdname_first;
else approve_��Ʒ=DESIRED_PRODUCT;
if approve_��Ʒ="Ebaotong" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="Salariat" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="Elite" then approve_��Ʒ="U��ͨ";
else if approve_��Ʒ="Eshetong" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="Ewangtong" then approve_��Ʒ="E��ͨ";
else if  approve_��Ʒ="Efangtong" then approve_��Ʒ="E��ͨ";
else if approve_��Ʒ="Efangtong-NoSecurity" then approve_��Ʒ="E��ͨ-���籣";
else if approve_��Ʒ="Efangtong-zigu" then approve_��Ʒ="E��ͨ-�Թ�";

else if approve_��Ʒ="RFElite" then approve_��Ʒ="U��ͨ����";
else if approve_��Ʒ="RFEbaotong" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="RFEshetong" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="RFSalariat" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="RFEwangtong" then approve_��Ʒ="E��ͨ����";
else if approve_��Ʒ="Ebaotong-zigu" then approve_��Ʒ="E��ͨ-�Թ�";
else if approve_��Ʒ="Ebaotong-NoSecurity" then approve_��Ʒ="E��ͨ-���籣";
else if approve_��Ʒ="Ezhaitong" then approve_��Ʒ="Eլͨ";
else if approve_��Ʒ="Ezhaitong-zigu" then approve_��Ʒ="Eլͨ-�Թ�";
else if approve_��Ʒ="Ezhaitong-NoSecurity" then approve_��Ʒ="Eլͨ-���籣";
else if approve_��Ʒ="Eweidai" then approve_��Ʒ="E΢��";
else if approve_��Ʒ="Eweidai-NoSecurity" then approve_��Ʒ="E΢��-���籣";
else if approve_��Ʒ="Eweidai-zigu" then approve_��Ʒ="E΢��-�Թ�";

if kindex(approve_��Ʒ,"Easy") then approve_��Ʒ ="E�״�";

if kindex(DESIRED_PRODUCT,"RF") and not kindex(approve_��Ʒ,"����") then pproduct_code=compress(approve_��Ʒ||"����") ;
if pproduct_code^="" then approve_��Ʒ=pproduct_code;

run;

data dta.check_result;
set check_result;
run;

data check_result;
set check_result;
keep apply_code ����״̬ ���˲�Ʒ����_���� ���˲�ƷС��_���� ���˽��_���� ��������_����
REFUSE_INFO_NAME REFUSE_INFO_NAME_LEVEL1  REFUSE_INFO_NAME_LEVEL2 REFUSE_INFO_NAME_final REFUSE_INFO_NAME_LEVEL1_final
REFUSE_INFO_NAME_LEVEL2_final CANCEL_REMARK FACE_SIGN_REMIND 
 approve_��Ʒ created_name_first created_name_final updated_time_first updated_time_final
check_date �����·� ͨ�� �ܾ� check_end check_week PROPOSE_LIMIT_first PROPOSE_LIMIT_final;
run;


*��ǩԼ��;
data sign_contract;
set approval.contract(keep = apply_no contract_no net_amount contract_amount service_fee_amount documentation_fee sign_date );
rename apply_no = apply_code net_amount = ���ֽ�� contract_amount = ��ͬ��� service_fee_amount = ����� documentation_fee = ��֤��;
format ǩԼʱ��   yymmdd10.;
ǩԼʱ��=mdy(month(sign_date),day(sign_date),year(sign_date));
if ǩԼʱ��^=.;
run;
proc sort data=sign_contract nodupkey;by apply_code;run;

*���ſ;
/*�ſ���Ϣ  loan_info����loan_amount���ڴ���Ǻ�ͬ���������ǵ��ֽ����Խ����contract��*/
data loan_info;
set approval.loan_info(keep = contract_no loan_date capital_channel_code status );
format �ſ�״̬ $10.;
	 if status in ("06", "08", "09", "10") then �ſ�״̬ = "�ѷſ�";
else if status = "11" then �ſ�״̬ = "�ܾ�";
else if status = "12" then �ſ�״̬ = "ȡ��";
else �ſ�״̬ = "�ſ���";
if �ſ�״̬="�ѷſ�";
/*apply_code = tranwrd(contract_no, "C", "PL");*/
�ſ��·� = put(loan_date, yymmn6.);
format �ſ�����  yymmdd10.;
�ſ�����=mdy(month(loan_date),day(loan_date),year(loan_date));
rename capital_channel_code = �ʽ�����;
format apply_code $45.;
apply_code = tranwrd(contract_no,"C","PL");
drop status �ſ�״̬ loan_date contract_no;
run;

proc sort data = loan_info nodupkey;by apply_code;run;
data sign_loan;
merge sign_contract(in =a) loan_info;
by apply_code;
if a ;
run;

data dta.sign_loan;
set sign_loan;
run;

/*�Զ��ܾ�*/
/*===================================���߼�Start===========================================*/
data autoVerifyTask_auto_reject;
set approval.apply_refusecancel_history(where=(current_period="autoVerifyTask"));
if type_name="autoRefuse" then do;
		first_refuse_code = reason_info_code;
		second_refuse_code = reason_info_code2;
		third_refuse_code = reason_info_code3;
		third_refuse_desc = remark;
	end;
else do;
		first_refuse_code = First_Root_Reason_Code;
		second_refuse_code = Second_Root_Reason_Code;
		third_refuse_code = reason_info_code;
		first_refuse_desc = First_Root_Reason_Name;
		second_refuse_desc = Second_Root_Reason_Name;
		third_refuse_desc = reason_info;
	end;
keep apply_code first_refuse_code second_refuse_code third_refuse_code first_refuse_desc second_refuse_desc third_refuse_desc created_time;
run;
proc sort data = autoVerifyTask_auto_reject nodupkey; by apply_code; run; 
* ɾ�����Ż�(PL2017121913222404036140)��������(PL2017103010484367829240)�����ظ���¼;
data otherTask_auto_reject;
set approval.apply_refusecancel_history(where=(current_period^="autoVerifyTask" and type_name="autoRefuse"));
first_refuse_code = reason_info_code;
second_refuse_code = reason_info_code2;
third_refuse_code = reason_info_code3;
third_refuse_desc = remark;
keep apply_code first_refuse_code second_refuse_code third_refuse_code third_refuse_desc created_time;
run;
proc sort data = otherTask_auto_reject; by apply_code third_refuse_code; run;
proc sort data = otherTask_auto_reject nodupkey; by apply_code; run;
* ͬʱ��������������(R743)��������(R753)�ܾ��ģ����������������ľܾ�ԭ��;
data auto_reject;
set autoVerifyTask_auto_reject otherTask_auto_reject;
auto_reject = 1;
if length(third_refuse_code)=4 and first_refuse_code = "" then do;
	first_refuse_code = substr(third_refuse_code,1,2);
	second_refuse_code = substr(third_refuse_code,1,3);
end;
rename created_time = auto_reject_time;
run;
proc sort data = auto_reject nodupkey; by apply_code; run;

data auto_reject_reason;
set approval.pbc_report_risk_info;
if type = "1";
/*where type in ("1","6");*/
keep id apply_code FIRST_REFUSE_CODE FIRST_REFUSE_DESC SECOND_REFUSE_CODE SECOND_REFUSE_DESC THIRD_REFUSE_CODE THIRD_REFUSE_DESC;
run;
proc sort data = auto_reject_reason nodupkey; by apply_code id; run;
proc sort data = auto_reject_reason nodupkey; by apply_code; run;
* ò��idС�ģ��ܾ�ԭ�����ȼ���һЩ����˱���;

data auto_reject_db;
merge auto_reject(in=a) auto_reject_reason(in=b);
by apply_code;
if a;
drop id;
attrib _all_ label = "";
run;
proc sort data = auto_reject_db nodupkey;by apply_code;
run;


data dta.auto_reject_db;
set auto_reject_db;
run;

data approval;
merge apply_dept(in = a ) apply back cur_status auto_reject_db  check_result sign_loan ; 
by apply_code;
run;

data dta.app_loan_info;
set approval;
run;

/*����ǰȡ��-��¼�������¼�븴�˻���ȡ����*/
data cancel_before;
set approval.apply_refusecancel_history;
where current_period in ("inputCheckTask", "inputTask") and type_name="cancel "; 
cancel_before=1;
keep apply_code cancel_before first_root_reason_code first_root_reason_name first_root_reason_code2 first_root_reason_name2;
run;
data dta.cancel_before;
set cancel_before;
run;

proc sql;
create table backtodept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME from back as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;
/*����*/
proc sql;
create table Partone_apply as select  branch_name,sum(����) as ������
from approval(where=(&tabledate.>=����ʱ��>=&month_begin.)) group by branch_name ;quit;
/*����*/
proc sql;
create table Partone_back as select  branch_name,sum(�����ŵ�) as ������
from approval(where=(&tabledate.>=�����ŵ�ʱ��>=&month_begin. )) group by branch_name ;quit;
/*ͨ��*/
proc sql;
create table Partone_accept as select  branch_name,sum(ͨ��) as ͨ����
from approval(where=(&tabledate.>=check_date>=&fk_month_begin. )) group by branch_name ;quit;
/*�ſ�������ſ���*/
proc sql;
create table Partone_amount as select  branch_name,sum(��ͬ���) as �ſ���,count(��ͬ���) as �ſ���
from approval(where=(&tabledate.>=�ſ�����>=&fk_month_begin. )) group by branch_name ;quit;


data Partone_cumulate_end;
merge Partone_apply Partone_back Partone_accept Partone_amount;
by branch_name;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;


/*proc  sql;*/
/*create table cc  as  select sum(��ͬ���) as ��ͬ��� from dta.app_loan_info(where=(�ſ��·�^="" and ��ǰ״̬="����")) ;quit;*/




data approval;
set dta.app_loan_info;
run;
proc sort data = approval;by apply_code;run;

libname appro odbc datasrc=approval_nf;

/*��������Ϣ����*/
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
data Nation_TYPE;
set appro.sys_config_detail(where=(SYS_CONFIG_HEADER_ID =83));
keep CONFIG_CODE CONFIG_DESC;
run;

data Nation_TYPE;
set appro.sys_config_detail(where=(SYS_CONFIG_HEADER_ID =83));
keep CONFIG_CODE CONFIG_DESC;
run;
data apply_base;
set approval.apply_base(keep = apply_code PHONE1 ID_CARD_NO RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_TYPE
							PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION LOCAL_RES_YEARS EDUCATION MARRIAGE GENDER RESIDENCE_ADDRESS PERMANENT_ADDRESS CHILD_COUNT nation PHONE1);


/*RESIDENCE-��סַ PERMANENT-������ַ*/
run;
proc sql;
create table base_info(drop= RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_ADDR_DISTRICT
 LOCAL_RESCONDITION EDUCATION MARRIAGE GENDER PERMANENT_TYPE) as
select a.*, b.itemName_zh as ��סʡ, c.itemName_zh as ��ס��, d.itemName_zh as ��ס��,
			e.itemName_zh as ����ʡ, f.itemName_zh as ������, g.itemName_zh as ������,
			h.itemName_zh as ס������, i.itemName_zh as �����̶�, j.itemName_zh as ����״��, k.itemName_zh as �Ա�,l.itemName_zh as ��������,
			m.CONFIG_DESC as ����
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
left join PERMANENT_TYPE as l on a.PERMANENT_TYPE = l.itemCode
left join Nation_TYPE as m on a.nation=m.CONFIG_CODE
;
quit;
data apply_assets;
set approval.apply_assets;
if IS_HAS_HOURSE ="y" and IS_HAS_CAR="y"  then �Ʋ���Ϣ = "�з��г�";
else if IS_HAS_HOURSE ="y" and IS_HAS_CAR="n"  then �Ʋ���Ϣ = "�з��޳�";
else if IS_HAS_HOURSE ="n" and IS_HAS_CAR="y"  then �Ʋ���Ϣ = "�г��޷�";
else  �Ʋ���Ϣ = "�޳��޷�";

keep APPLY_CODE housing_property IS_HAS_HOURSE IS_HAS_CAR �Ʋ���Ϣ IS_HAS_INSURANCE_POLICY HOURSE_COUNT CAR_COUNT IS_LIVE_WITH_PARENTS HOURSE_MONTHLY_PAYMENT;
run;
data apply_insurance;
set appraw.apply_insurance;
format �ɷѷ�ʽ $10.;
if INSURANCE_PAY_METHOD="01" then do  ;�ɷѷ�ʽ="�½�"; ��ɽ��=INSURANCE_PAY_AMT*12;   end;
else if INSURANCE_PAY_METHOD="02" then do; �ɷѷ�ʽ="����";��ɽ��=INSURANCE_PAY_AMT*4;   end;
else if INSURANCE_PAY_METHOD="03" then do;�ɷѷ�ʽ="�����";��ɽ��=INSURANCE_PAY_AMT*2;   end;
else if INSURANCE_PAY_METHOD="04" then do;�ɷѷ�ʽ="���";��ɽ��=INSURANCE_PAY_AMT;   end;

keep apply_code INSURANCE_COMPANY INSURANCE_PAY_AMT INSURANCE_PAY_METHOD INSURANCE_EFFECTIVE_DATE  �ɷѷ�ʽ ��ɽ��;
run;

proc sort data = apply_assets;by apply_code;run;
proc sort data = apply_insurance;by apply_code;run;

data apply_insurance;
set apply_insurance ;
retain �ܽɷѽ�� ;
by apply_code;
if first.apply_code then �ܽɷѽ��=��ɽ��;
else �ܽɷѽ��=�ܽɷѽ��+��ɽ��;
run;
proc sort data = apply_insurance;by apply_code descending �ܽɷѽ��;run;
proc sort data = apply_insurance nodupkey;by apply_code ;run;


data apply_assets;
merge apply_assets apply_insurance;
by apply_code;
run;

proc sql;
create table assets_info(drop=housing_property) as
select a.*, b.itemName_zh as ��������
from apply_assets as a
left join house_property as b on a.housing_property = b.itemCode
;
quit;
proc import out = ccoc datafile = "D:\share\Datamart\cs\wenjie\�Ѳ�¼CCOC��.xls" dbms = excel replace;
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
							CURRENT_INDUSTRY WORK_YEARS COMP_ADDRESS TITLE WORK_CHANGE_TIMES START_DATE_4_PRESENT_COMP);

							format ��ְʱ�� yymmdd10.;
��ְʱ�� = datepart(START_DATE_4_PRESENT_COMP);
							drop START_DATE_4_PRESENT_COMP;
run;
proc sql;
create table emp_info(drop= COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT position comp_type START_DATE_4_PRESENT_COMP) as
select a.*, b.itemName_zh as ��λʡ, c.itemName_zh as ��λ��, d.itemName_zh as ��λ��,
			e.itemName_zh as ְ��, f.itemName_zh as ��λ����
from apply_emp as a
left join province as b on a.COMP_ADDR_PROVINCE = b.itemCode
left join city as c on a.COMP_ADDR_CITY = c.itemCode
left join region as d on a.COMP_ADDR_DISTRICT = d.itemCode
left join position as e on a.position = e.itemCode
left join comp_type as f on a.comp_type = f.itemCode
;
quit;

data apply_ext_data;
set approval.apply_ext_data(keep = apply_code INDUSTRY_NAME CC_NAME OC_NAME CC_code oc_code);
run;




data apply_balance;
set approval.apply_balance(keep = apply_code yearly_income monthly_salary monthly_other_income monthly_expense PUBLIC_FUNDS_RADICES SOCIAL_SECURITY_RADICES SALARY_PAY_WAY PAY_DAY);
run;

data debt_ratio;
set approval.debt_ratio(keep = apply_no loan_month_return card_used_amt_sum social_security_month fund_month bank_flow_month
							other_income_month liability_month debt_ratio UPDATED_TIME);
rename apply_no = apply_code;
run;

data liability_ratio;
set approval.liability_ratio(keep = apply_no loan_month_return card_used_amt_sum SEMI_CARD_OVERDRAFT_BALANCE verify_income VERIFY_PAYROLL_CREDIT 
								  OTHER_LIABILITIES ratio NEW_RATIO WEI_LI_LOAN_AMT);
rename apply_no = apply_code
       loan_month_return=loan_month_return_new
       card_used_amt_sum=card_used_amt_sum_new
	   WEI_LI_LOAN_AMT = ΢�������;
run;

data salarypayway;
set res.optionitem(where = (groupCode = "SALARYPAYWAY"));
keep itemCode itemName_zh;
run;
proc sql;
create table balance_info(drop=SALARY_PAY_WAY) as select a.*,b.itemName_zh as н�ʷ��ŷ�ʽ   from  apply_balance as  a left join salarypayway as  b on a.SALARY_PAY_WAY =b.itemCode;quit;

data apply_info;
set approval.apply_info
(keep = apply_code name id_card_no SALES_CODE SALES_NAME MANAGER_CODE MANAGER_NAME    );
run;

data apply_time1;
set approval.act_opt_log(where = (task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE")); /*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
input_complete=1;/*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
keep bussiness_key_ create_time_ input_complete;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time1 dupout = a nodupkey; by apply_code apply_time; run;
proc sort data = apply_time1 nodupkey; by apply_code; run;
proc sort data = apply_info nodupkey; by apply_code; run;
data apply_time;
merge apply_time1(in = a) apply_info(in = b);
by apply_code;
if b;

run;

proc sort data = credit.credit_report(keep=report_number id_card created_time) out = credit_report nodupkey; by report_number; run;
proc sort data=credit.credit_info_base out=report_date(keep=report_number real_name report_date CREDIT_VALID_ACCT_SUM) nodupkey; by report_number; run;

/*���ÿ�������ϸ���ϱ�������*/
proc sort data=credit.credit_detail out=credit_detail; by report_number; run;

data credit_detail;
merge credit_detail(in=a) report_date(in=b);
by report_number;
if a;
open_month = intck("month", DATE_OPENED, report_date);
update_month = intck("month", LAST_UPDATE_DATE, report_date);
if day(DATE_OPENED) <day(report_date) then open_month=open_month+1;
if day(LAST_UPDATE_DATE) <day(report_date) then update_month=update_month+1;

if DATE_OPENED >= intnx("month", report_date, -6, "same") then in6month = 1; else in6month = 0;
if DATE_OPENED >= intnx("month", report_date, -24, "same") then in24month = 1; else in24month = 0;
if credit_line_amt=. then credit_line_amt=0;
if usedcredit_line_amt=. then usedcredit_line_amt=0;
run;
/*�Ƿ�׻����� step 2,3,4*/

data no_credit;
set credit_detail;
if  BUSI_TYPE="CREDIT_CARD" or BUSI_TYPE="LOAN" ;
if update_month>24  and  (ACCT_STATUS="3"  or ACCT_STATUS="14")  then step2=1;
else if ACCT_STATUS="16"  then step3_1=1;
else if BUSI_TYPE="LOAN"  and open_month<=3  then step3_2=1;
else if BUSI_TYPE="CREDIT_CARD" and open_month<=3 and usedcredit_line_amt=0 then step4=1;
run;

proc sql ;
create table no_credit_1 as select a.* ,b.���ÿ���¼,c.�����¼,d.* from
(select report_number,count(*) as �Ŵ���¼ from credit_detail group by  report_number ) as a
left join 
(select report_number,count(*) as ���ÿ���¼ from credit_detail(where=(BUSI_TYPE="CREDIT_CARD")) group by  report_number ) as b on a.report_number=b.report_number
left join 
(select report_number,count(*) as �����¼ from credit_detail(where=( BUSI_TYPE="LOAN")) group by  report_number ) as c on a.report_number=c.report_number
left join 
(select report_number,count(step2) as step2,count(step3_1) as step3_1
,count(step3_2) as step3_2,count(step4) as step4 from  no_credit group by report_number) as d  on a.report_number=d.report_number;quit;


data no_credit_2;
set no_credit_1;
if sum(���ÿ���¼,�����¼,-step2,-step3_1,-step3_2,-step4) =0 then �׻�=1;
run;


/*�Ƿ�׻�����--- end */

data card_detail;
set credit_detail(where=(SUB_BUSI_TYPE="���ǿ�"));
if  intck("month", DATE_OPENED,LAST_UPDATE_DATE ) >= 12  and CREDIT_LINE_AMT>=10000  and CURRENCY_TYPE ="�����"  then �����һ��=1;
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
if index(sub_busi_type, "����") or index(sub_busi_type, "���÷�") or index(sub_busi_type, "ס��") then   ��Ѻ���� = 1;
if not(index(sub_busi_type, "����") or index(sub_busi_type, "���÷�") or index(sub_busi_type, "ס��") 
or index(sub_busi_type, "��ѧ") or index(sub_busi_type, "ũ��") )then do;
	if index(sub_busi_type,"����") and  LOAN_BALANCE =CREDIT_LINE_AMT and DATE_OPENED ^=DATE_CLOSED then �޵�Ѻ����=0;
	else �޵�Ѻ����=1;

end;

if ACCT_STATUS="1"  and �޵�Ѻ����=1 then do;
		δ�����޵�Ѻ����=1;
		if kindex(ORG_NAME,"����") then ����δ�����޵�Ѻ����=1;
		else if kindex(ORG_NAME,"���ѽ���") then ���ѽ���δ�����޵�Ѻ����=1;
		else ����δ�����޵�Ѻ����=1;
end;

if  ACCT_STATUS="1" then do;
	δ�������=1
;δ�����»�=MONTHLY_PAYMENT;

end;

/*loan_q=intck("month", DATE_OPENED, date_closed);*/
/*if 12=<loan_q<=48 and credit_line_amt >then */

run;


proc sql;
create table loan_pastdue_sum as
select report_number, sum(pastdue_amt) as loan_pastdue_sum,sum(��Ѻ����) as ���µ�Ѻ����,sum(�޵�Ѻ����) as �޵�Ѻ����,sum(δ�����޵�Ѻ����) as δ�����޵�Ѻ����,
sum(δ�������) as δ�������,sum(����δ�����޵�Ѻ����) as ����δ�����޵�Ѻ����,sum(���ѽ���δ�����޵�Ѻ����) as ���ѽ���δ�����޵�Ѻ����,sum(����δ�����޵�Ѻ����) as ����δ�����޵�Ѻ����,sum(δ�����»�) as �����»����ܶ�
from loan_detail
group by report_number
;
quit;

proc sort data=credit.credit_query_record out=credit_query_record; by report_number; run;
data credit_query_record;
merge credit_query_record(in=a) report_date(in=b);
by report_number;
if a;
if query_date >= intnx("month", report_date, -1, "same") then in1month = 1; else in1month = 0;
if query_date >= intnx("month", report_date, -3, "same") then in3month = 1; else in3month = 0;
if query_date >= intnx("month", report_date, -6, "same") then in6month = 1; else in6month = 0;
if query_date >= intnx("month", report_date, -12, "same") then in12month = 1; else in12month = 0;
if query_date >= intnx("month", report_date, -24, "same") then in24month = 1; else in24month = 0;

run;

data loan_query;
set credit_query_record(where = (QUERY_REASON in ("1", "8", "3")));
length ��ѯ���� $50;
if index(QUERY_ORG, "/") then ��ѯ���� = scan(QUERY_ORG, 1, "/"); else ��ѯ���� = QUERY_ORG;
run;
proc sort data = loan_query; by report_number ��ѯ���� descending query_date; run;


data loan_query;
set loan_query;
by report_number ��ѯ����;
format query_dt yymmdd10.;
format query_mon yymmn6.;
retain query_dt;
	 if first.��ѯ���� then query_dt = query_date;
else if intck("day", query_date, query_dt) <= 30 then del = 1;
else query_dt = query_date;
query_mon = intnx("month", query_dt,0, "b");
if kindex(��ѯ����,"���ѽ���") and in3month=1 then ���ѽ��� =1 ;
run;




proc sql;
create table loan_query_in3m as
select report_number,
		sum(in3month) as loan_query_in3m,
		sum(���ѽ���) as ���ѽ���,
		sum(sum(in3month) ,- sum(���ѽ���),0) as quxiao
from loan_query
where del ^= 1 
group by report_number
;
quit;



/*BUG ��Щ�ͻ�û��ƥ�䵽������Ϣ ��Ϊ���֤�������*/
proc sort data = credit.credit_report(keep=report_number id_card created_time) out = credit_report nodupkey; by report_number; run;
proc sql;
create table  pboc_info_pre as
select a.*,datepart(a.created_time) as ���Ż�ȡʱ�� format=yymmdd10.,b.card_pastdue_total as ���ÿ���ǰ���ڽ��,c.loan_pastdue_sum as ���ǰ���ڽ��,
sum(b.card_pastdue_total,c.loan_pastdue_sum) as ��ǰ���ڽ���ܼ�,c.���µ�Ѻ����,c.�޵�Ѻ����,c.δ�����޵�Ѻ����,c.δ�������,c.����δ�����޵�Ѻ����,
c.���ѽ���δ�����޵�Ѻ����,c.����δ�����޵�Ѻ����,c.�����»����ܶ�,d.���ѽ��� as �����ѯ����,e.�Ŵ���¼ ,e.�׻�  from credit_report as a
left join card_pastdue_total as b on a.report_number=b.report_number
left join loan_pastdue_sum as c on a.report_number=c.report_number
left join loan_query_in3m as d on a.report_number=d.report_number
left join no_credit_2  as e on a.report_number=e.report_number;
quit;



proc sql;
create table pboc_info as
select a.apply_code, b.*
from apply_time as a
inner join pboc_info_pre as b on a.id_card_no = b.id_card and datepart(a.apply_time) >= datepart(b.created_time)
;
quit;
proc sort data = pboc_info nodupkey; by apply_code descending created_time; run;
proc sort data = pboc_info  nodupkey; by apply_code; run;

data query_in3month;
set credit.credit_derived_data(keep = REPORT_NUMBER SELF_QUERY_03_MONTH_FREQUENCY_SA  CARD_APPLY_03_MONTH_FREQUENCY_SA CARD_60_PASTDUE_FREQUENCY
LOAN_GUARANTEE_QUERY_03_MONTH_FR LOAN_GUARANTEE_QUERY_24_MONTH_FR CARD_APPLY_24_MONTH_FREQUENCY CARD_CREDIT_LINE_AMT_SUM CARD_USEDCREDIT_LINE_AMT_SUM CARD_OVER_100PCT
SELF_QUERY_24_MONTH_FREQUENCY_SA LOAN_GUARANTEE_QUERY_01_MONTH_FR CARD_APPLY_01_MONTH_FREQUENCY_SA SELF_QUERY_01_MONTH_FREQUENCY_SA
CARD_60_PASTDUE_M3_FREQUENCY LOAN_MORTGAGE_60_PASTDUE_FREQUEN LOAN_MORTGAGE_PASTDUE_M3_FREQUEN LOAN_NAMORTGAGE_60_PASTDUE_FREQU LOAN_NAMORTGAGE_PASTDUE_M3_FREQU 
LOAN_OTHER_60_PASTDUE_FREQUENCY LOAN_OTHER_PASTDUE_M3_FREQUENCY SELF_QUERY_06_MONTH_FREQUENCY LOAN_MAX_CREDIT_LINE_AMT CARD_FIRST_OPEN_MONTH CARD_MAX_CREDIT_LINE_AMT LOAN_UNCLEARED_CREDIT_LINE_AMT_S
LOAN_BALANCE_SUM );
rename  LOAN_GUARANTEE_QUERY_03_MONTH_FR = ��3���´����ѯ����
		SELF_QUERY_03_MONTH_FREQUENCY_SA = ��3���±��˲�ѯ����
		CARD_APPLY_03_MONTH_FREQUENCY_SA=��3�������ÿ���ѯ����
		LOAN_GUARANTEE_QUERY_24_MONTH_FR=��2������ѯ����
CARD_APPLY_24_MONTH_FREQUENCY=��2�����ÿ���ѯ����
SELF_QUERY_24_MONTH_FREQUENCY_SA=��2����˲�ѯ����
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
SELF_QUERY_01_MONTH_FREQUENCY_SA=��1���±��˲�ѯ����
LOAN_MAX_CREDIT_LINE_AMT=���������
CARD_FIRST_OPEN_MONTH =���ÿ�����˻����ʱ��
CARD_MAX_CREDIT_LINE_AMT=���ÿ������
LOAN_UNCLEARED_CREDIT_LINE_AMT_S = ���Ŵ����ܶ�
LOAN_BALANCE_SUM= ����ʹ���ܶ�
;
run;

proc sql;
create table pboc_info1 as
select a.*,b.��3���±��˲�ѯ����,b.��3���´����ѯ����,b.��2������ѯ����,b.��2�����ÿ���ѯ����,b.��3�������ÿ���ѯ����,b.���ÿ�ʹ����,b.���ÿ��ܶ�,b.���ÿ�͸֧�ܶ�,
b.���ǿ���5�����ڴ���,b.���ǿ���5������90���ϴ���,b.��Ѻ�����5�����ڴ���,b.��Ѻ�����5������90�����ϴ���,b.�޵�Ѻ�����5�����ڴ���,b.�޵�Ѻ�����5������90�����ϴ���,
b.�������ʴ����5�����ڴ���,b.�������ʴ����5������90������,b.���������,b.���ÿ������,b.���ÿ�����˻����ʱ��,b.���Ŵ����ܶ�,b.����ʹ���ܶ�,
b.��2����˲�ѯ����,b.��1���´����ѯ����,b.��1�������ÿ���ѯ����,b.��1���±��˲�ѯ����,b.��6���±��˲�ѯ���� from pboc_info as a
left join query_in3month as b on a.REPORT_NUMBER=b.REPORT_NUMBER;
quit;


data TQ_score;
set appraw.apply_identity_match;
if type ="FRACTION";
keep apply_code value;
rename value=������;
run;

data TQ_score_his;
set  approval.tq_score;

tianqi_score_loan_dt = compress(tianqi_score_loan_dt1);
keep apply_code tianqi_score_loan_dt;
rename tianqi_score_loan_dt=������;
run;

data TQ;
set TQ_score TQ_score_his;
run;


/*�Ϻ���������*/
libname credit odbc datasrc = credit_nf;


data credit_zx_detail;
set credit.credit_zx_detail;
if SUB_BIZ_TYPE="�޵�Ѻ����" then �޵�Ѻ���� =1;
run;

proc sql;
create table zx_detail as select apply_code ,sum(CREDIT_LINE_AMT) as ���Ŵ����ܶ�,sum(USEDCREDIT_LINE_AMT) as ����ʹ���ܶ�
,sum(MONTHLY_PAYMENT) as �����»����ܶ�
from credit_zx_detail(where=(ACCT_STATUS^="����")) group by apply_code;quit;




proc sort data = base_info nodupkey; by apply_code; run;
proc sort data = emp_info nodupkey; by apply_code; run;
proc sort data = apply_ext_data nodupkey; by apply_code; run;
proc sort data = debt_ratio nodupkey; by apply_code ; run;
proc sort data = assets_info nodupkey; by apply_code; run;
proc sort data = ccoc_info nodupkey; by apply_code; run;
proc sort data = liability_ratio nodupkey; by apply_code; run;
proc sort data = balance_info nodupkey ; by apply_code;run;
proc sort data = pboc_info1 nodupkey;by apply_code;run;
proc sort data = apply_info nodupkey;by apply_code;run;
proc sort data = TQ nodupkey;by apply_code;run;
proc sort data = approval.credit_score out =credit_score(keep = group_Level apply_code)
 nodupkey;by apply_code;run;
data customer_info;
merge approval(in=a keep = apply_code ����ʱ��)  base_info(in = b) emp_info(in = c) apply_ext_data(in = d) 
 debt_ratio(in = f) assets_info(in = g) ccoc_info(in = h)  liability_ratio(in=i) balance_info pboc_info1 apply_info TQ credit_score zx_detail;
by apply_code;
if a;
/*������� ID_CARD_NO ȡ���������ռ���-ʵ������*/
format age 10.;
format birthdate yymmdd10.;
birth_year=substr(ID_CARD_NO,7,4)+0;
birth_mon=substr(ID_CARD_NO,11,2)+0;
birth_day=substr(ID_CARD_NO,13,2)+0;
birthdate=mdy(birth_mon,birth_day,birth_year);
age=Intck('year',birthdate,����ʱ��);
drop birth_mon birth_day birth_year;
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
if ������="" or ��λ��="" then ��ر�ǩ="����ȱʧ";
else if ������^=��λ�� then ��ر�ǩ="���";
else ��ر�ǩ="����";
rename loan_month_return = �����»� CARD_USED_AMT_SUM = ���ÿ��»� SOCIAL_SECURITY_MONTH = �籣���� FUND_MONTH = ��������� SEMI_CARD_OVERDRAFT_BALANCE = ׼���ǿ��»�
		BANK_FLOW_MONTH = ��������ˮ OTHER_INCOME_MONTH = ���������� LIABILITY_MONTH = ���¸�ծ debt_ratio = ���¸�ծ��  RATIO = �ⲿ��ծ��
		VERIFY_INCOME = ��ʵ���� VERIFY_PAYROLL_CREDIT = ��ʵ�������� OTHER_LIABILITIES = ������ծ  NEW_RATIO = ��ծ�� COMP_NAME=��λ���� TITLE=ְλ;
drop  ����� CC�� OC�� birthdate ����ʱ��;
run;

data customer_info;
merge approval(in=a) customer_info;
by apply_code;
if a;


��3�´���Ӹ��˴��� = sum(��3���´����ѯ����,��3���±��˲�ѯ����);

if ��6���±��˲�ѯ����<=1 then  SE6_score=71;
else if ��6���±��˲�ѯ����>=7 then SE6_score=33;
else if ��6���±��˲�ѯ����<=4 then SE6_score=59;
else SE6_score=45;

if ��2����˲�ѯ����<=3 then  SE24_score=71;
else if ��2����˲�ѯ����<=9 then SE24_score=56;
else if ��2����˲�ѯ����<=14 then SE24_score=51;
else SE24_score=39;

if ��3�´���Ӹ��˴���<=1 then  ls3_score=82;
else if ��3�´���Ӹ��˴���<=3 then  ls3_score=58;
else if ��3�´���Ӹ��˴���<=6 then  ls3_score=48;
else ls3_score=33;

if ���������<=150000 then  LM_score=49;
else if ���������>=300001 then LM_score=73;
else LM_score=60;

if ���ÿ�����˻����ʱ��<=109 then  CFO_score=48;
else if ���ÿ�����˻����ʱ��>=131 then CFO_score=72;
else CFO_score=64;

if ���ÿ������<=30000 then  CM_score=42;
else if ���ÿ������>=100001 then CM_score=69;
else CM_score=65;


if �Ա�="��" AND ����״��="�ѻ�" then  GM_score=57;
else if �Ա�="��" AND ����״�� ^="�ѻ�" then GM_score=37;
else GM_score=63;


if �������� IN ("�����𰴽ҹ���","����ס��","��ҵ���ҷ�","�ް��ҹ���","��ϰ���") then LR_score=64;
else if �������� IN ("�Խ���","����") then LR_score=52;
else LR_score=31;

if 1<������<468 then  TQ_score=-22;
else if ������<=543 then TQ_score=56;
else if ������<=619 then TQ_score=56;
else if ������<=714 then TQ_score=80;
else TQ_score=80;

if ��ر�ǩ="���" then  loc_score=43;
else loc_score=57;


SCORE = SUM(SE6_score,SE24_score,ls3_score,loc_score,LR_score,GM_score,CM_score,CFO_score,LM_score,TQ_score);
if ������<1 then SCORE=0;

format GROUP $45. GROUP1 GROUP2;
if SCORE<1 then do GROUP ="ȱʧ";GROUP1 =0; end;
else IF 1<SCORE<=480 THEN do GROUP ="-480";GROUP1 =480;end;
ELSE IF SCORE <=500 THEN do GROUP ="481-500";GROUP1 =500;end;
ELSE IF SCORE <= 520 THEN do GROUP ="501-520";GROUP1 =520;end;
ELSE IF SCORE <=540 THEN do GROUP="521-540";GROUP1 =540;end;
ELSE IF SCORE <=560 THEN do GROUP="541-560";GROUP1 =560;end;
ELSE IF SCORE <=580 THEN do  GROUP="561-580";GROUP1 =580;end;
ELSE IF SCORE <=600 THEN do GROUP="581-600";GROUP1 =600;end;
ELSE IF SCORE <=620 THEN do GROUP="601-620";GROUP1 =620;end;
ELSE IF SCORE >=621 THEN do GROUP="621-";GROUP1 =700;end;
ELSE GROUP ="ȱʧ";

if branch_name in ("��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��")  
	then do
		Ӫҵ������="һ��";
		if SCORE<1 then GROUP2=0;
		else if 1<SCORE<480 then GROUP2=6;
		else if  SCORE<565 then GROUP2=2;
		else if  SCORE>=565 then GROUP2=1;
	end;

else if  branch_name in ("�����е�һӪҵ��","����е�һӪҵ��","�Ϻ�����·Ӫҵ��","��������·Ӫҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��",
"������ҵ������","�γ��е�һӪҵ��","�人�е�һӪҵ��","����е�һӪҵ��","��ͨ��ҵ������","�Ͼ���ҵ������") 
	then do  
		Ӫҵ������="����";
		if SCORE<1 then GROUP2=0;

		else if 1<SCORE<545 then GROUP2=6;
		else if  SCORE<565 then GROUP2=5;
		else if  SCORE<620 then GROUP2=4;
		else if  SCORE>=620 then GROUP2=2;

	end;


else do
		Ӫҵ������="����";
		if SCORE<1 then GROUP2=0;

		else if 1<SCORE<515 then GROUP2=6;
		else if  SCORE<555 then GROUP2=5;
		else if  SCORE<570 then GROUP2=4;
		else if  SCORE<605 then GROUP2=3;
		else if  SCORE<630 then GROUP2=2;
		else if  SCORE>=630 then GROUP2=1;
	end;

 if GROUP2=6 then model_level="F";
else if   GROUP2=5 then model_level="E" ;
else if  GROUP2=4 then model_level="D";
else if   GROUP2=3 then model_level="C";
else if  GROUP2=2 then model_level="B";
else if  GROUP2=1 then model_level="A";

run;


data dta.customer_info;
set customer_info;
drop apply_time;
run;


data apply_demo;
set customer_info;

/*��������*/
if  �����̶�="˶ʿ��������" then  EDUCATION=0;
if �����̶�="��ѧ����" then  EDUCATION=1;
if  �����̶�="ר��" then EDUCATION=2;
if  �����̶�="����" then EDUCATION=3;
if �����̶�="��ר" then EDUCATION=4;
if  �����̶�="����" then EDUCATION=5;
if �����̶�="Сѧ" then  EDUCATION=6;
if  �����̶�="δ֪" then  EDUCATION=7;
if �����̶�=" " then  EDUCATION=8;
/*����״��*/
if ����״��="δ��" then  MARRIAGE=0;
if ����״��="�ѻ�" then MARRIAGE=1;
if ����״��="ɥż" then MARRIAGE=2;
if ����״��="����" then  MARRIAGE=3;
if ����״��=" " then  MARRIAGE=4;
drop  �����̶� ����״��;
/*�Ա�*/
if  �Ա�="��" then GENDER1=0 ; 
if �Ա�="Ů" then GENDER1=1 ; 
else if �Ա�="" then GENDER1=2 ;
/*�ʼ���Ϣ*/
/*if EMAIL^="" and EMAIL^="��"  then IS_HAS_Email=1;*/
/*else IS_HAS_Email=0;*/
/*������Ϣ*/
if IS_HAS_HOURSE="y" then IS_HAS_HOURSE1=1;
else if IS_HAS_HOURSE="n" then IS_HAS_HOURSE1=0;
else IS_HAS_HOURSE1=2;

if IS_HAS_CAR="y" then IS_HAS_CAR1=1;
else if IS_HAS_CAR="n" then IS_HAS_CAR1=0;
else IS_HAS_CAR1=2;

if IS_LIVE_WITH_PARENTS="y"  then IS_LIVE_WITH_PARENTS1=1;
else if IS_LIVE_WITH_PARENTS="n" then IS_LIVE_WITH_PARENTS1=0;
else IS_LIVE_WITH_PARENTS1=2;

if IS_HAS_INSURANCE_POLICY="y" then IS_HAS_INSUR=1;
else IS_HAS_INSUR=0;
drop �Ա�  IS_HAS_HOURSE IS_LIVE_WITH_PARENTS IS_HAS_INSURANCE_POLICY IS_HAS_CAR;
/*��ס��ַ*/

/*if ��סʡ in ("") then ;*/


/*���� age*/
format age_g $20.;
if age<18 then age_g=0;
else if age>=18 and age<=25 then age_g=1;
else if age>25 and age<=30 then age_g=2;
else if age>30 and age<=35 then age_g=3;
else if age>35 and age<=40 then age_g=4;
else if age>40 and age<=45 then age_g=5;
else if age>45 and age<=55 then age_g=6;
else if age>55 and age<=60 then age_g=7;
else if age>60  then age_g=8;

/*��Ů���� CHILD_COUNT*/
if CHILD_COUNT=0 or CHILD_COUNT=. then CHILD_COUNT_G=0;
else if CHILD_COUNT=1 then CHILD_COUNT_G=1;
else if CHILD_COUNT=2 then CHILD_COUNT_G=2;
else if CHILD_COUNT>2 then CHILD_COUNT_G=3;
/*��������ʱ�� LOCAL_RES_YEARS*/
if LOCAL_RES_YEARS>=0 and LOCAL_RES_YEARS<1 then LOCAL_RES_YEARS_G=0;
else if LOCAL_RES_YEARS>=1 and LOCAL_RES_YEARS<3 then LOCAL_RES_YEARS_G=1;
else if LOCAL_RES_YEARS>=3 and LOCAL_RES_YEARS<5 then LOCAL_RES_YEARS_G=2;
else if LOCAL_RES_YEARS>=5 and LOCAL_RES_YEARS<10 then LOCAL_RES_YEARS_G=3;
else if LOCAL_RES_YEARS>=10 and LOCAL_RES_YEARS<20 then LOCAL_RES_YEARS_G=4;
else if LOCAL_RES_YEARS>=20 then LOCAL_RES_YEARS_G=5;
/*�����䶯���� WORK_CHANGE_TIMES*/
if WORK_CHANGE_TIMES=0 then WORK_CHANGE_TIMES_G=0;
else if WORK_CHANGE_TIMES=1 then WORK_CHANGE_TIMES_G=1;
else if WORK_CHANGE_TIMES=2 then WORK_CHANGE_TIMES_G=2;
else if WORK_CHANGE_TIMES>=3 then WORK_CHANGE_TIMES_G=3;


/*�������� work_years*/
format work_years_g $20.;
if work_years=0  then work_years_g=0;
else if work_years<1 then work_years_g=1;
else if work_years<3 then work_years_g=2;
else if work_years<5 then work_years_g=3;
else if work_years<10 then work_years_g=4;
else if work_years<20 then work_years_g=5;
else if work_years>=20 then work_years_g=6;
/*�������� HOURSE_COUNT*/
/*���ڿ�ֵ*/
if HOURSE_COUNT=0 then HOURSE_COUNT_G=0;
else if HOURSE_COUNT=1 then HOURSE_COUNT_G=1;
else if HOURSE_COUNT=2 then HOURSE_COUNT_G=2;
else if HOURSE_COUNT>=3 then HOURSE_COUNT_G=3;
else  HOURSE_COUNT_G=4;
/*�������� CAR_COUNT*/
/*���ڿ�ֵ*/

if CAR_COUNT=0 then CAR_COUNT_G=0;
else if CAR_COUNT=. then CAR_COUNT_G=3;
else if CAR_COUNT=1 then CAR_COUNT_G=1;
else if CAR_COUNT>=2 then CAR_COUNT_G=2;

/*�ܱ��� INSURANCE_INSURED_PRICE*/
/*format INSURANCE_INSURED_PRICE_G $20.;*/
/*if INSURANCE_INSURED_PRICE=0 or INSURANCE_INSURED_PRICE=. then INSURANCE_INSURED_PRICE_G=0;*/
/*else if INSURANCE_INSURED_PRICE<=50000 then INSURANCE_INSURED_PRICE_G="1.�ܱ���1-5��";*/
/*else if INSURANCE_INSURED_PRICE<=100000 then INSURANCE_INSURED_PRICE_G="2.�ܱ���6-10��";*/
/*else if INSURANCE_INSURED_PRICE<=500000 then INSURANCE_INSURED_PRICE_G="3.�ܱ���11-50��";*/
/*else if INSURANCE_INSURED_PRICE<=1000000 then INSURANCE_INSURED_PRICE_G="4.�ܱ���51-100��";*/
/*else if INSURANCE_INSURED_PRICE<=2000000 then INSURANCE_INSURED_PRICE_G="5.�ܱ���101-200��";*/
/*else if INSURANCE_INSURED_PRICE<=5000000 then INSURANCE_INSURED_PRICE_G="6.�ܱ���201-500��";*/
/*else if INSURANCE_INSURED_PRICE>5000000 then INSURANCE_INSURED_PRICE_G="7.�ܱ���>500��";*/
/*���� VERIFY_INCOME*/

if ��ʵ����<=0 or ��ʵ����=. then VERIFY_INCOME_G=0;
else if ��ʵ����<3000 then VERIFY_INCOME_G=1;
else if ��ʵ����<5000 then VERIFY_INCOME_G=2;
else if ��ʵ����<8000 then VERIFY_INCOME_G=3;
else if ��ʵ����<10000 then VERIFY_INCOME_G=4;
else if ��ʵ����<20000 then VERIFY_INCOME_G=5;
else if ��ʵ����<30000 then VERIFY_INCOME_G=6;
else if ��ʵ����<50000 then VERIFY_INCOME_G=7;
else if ��ʵ����<100000 then VERIFY_INCOME_G=8;
else if ��ʵ����>=100000 then VERIFY_INCOME_G=9;
/*��ծ�� RATIO*/
/*format RATIO_G $20.;*/
/*if RATIO=. THEN RATIO=debt_ratio/100;*/
/*if RATIO=0 then RATIO_G="DSR=0";*/
/*else if RATIO<0.1 then RATIO_G="DSR 0-<10%";*/
/*else if RATIO<0.3 then RATIO_G="DSR 10-<30%";*/
/*else if RATIO<0.5 then RATIO_G="DSR 30-<50%";*/
/*else if RATIO<0.6 then RATIO_G="DSR 50-<60%";*/
/*else if RATIO<0.7 then RATIO_G="DSR 60-<70%";*/
/*else if RATIO<0.8 then RATIO_G="DSR 70-<80%";*/
/*else if RATIO<0.9 then RATIO_G="DSR 80-<90%";*/
/*else if RATIO<1 then RATIO_G="DSR 90-<100%";*/
/*else if RATIO<2 then RATIO_G="DSR 100-<200%";*/
/*else if RATIO<3 then RATIO_G="DSR 200-<300%";*/
/*else if RATIO<4 then RATIO_G="DSR 300-<400%";*/
/*else if RATIO<5 then RATIO_G="DSR 400-<500%";*/
/*else if RATIO>=5 then RATIO_G="DSR >=500%";*/

/*��ס���뻧����ϵ*/

if ��ס��="" then Res_Type=2;
else if ��ס��=������ then Res_Type=0;
else  Res_Type=1;


/*��������*/
if ��������="���س���" then do; PERMANENT_TYPE1=0;;end;
if ��������="����ũ��"  then do; PERMANENT_TYPE1=1;;end;
if ��������="��س���" then do; PERMANENT_TYPE1=2;;end;
if ��������="���ũ��" then do; PERMANENT_TYPE1=3;;end;

/*���ʷ���·��*/
if н�ʷ��ŷ�ʽ="�ֽ�" then SALARY_PAY_WAY1=0;
if н�ʷ��ŷ�ʽ="��" then SALARY_PAY_WAY1=1;
if н�ʷ��ŷ�ʽ="���д���" then SALARY_PAY_WAY1=2;
if н�ʷ��ŷ�ʽ="����" then SALARY_PAY_WAY1=3;
if н�ʷ��ŷ�ʽ="����" then SALARY_PAY_WAY1=4;
drop н�ʷ��ŷ�ʽ;
/*��������*/

/*��������*/
if ��������="�����𰴽ҹ���"  then LOCAL_RESCONDITION_G =0;
else if ��������="��˾����"  then LOCAL_RESCONDITION_G =1;
else if ��������="����ס��"  then LOCAL_RESCONDITION_G =2;
else if ��������="��ҵ���ҷ�"  then LOCAL_RESCONDITION_G =3;
else if ��������="�ް��ҹ���"  then LOCAL_RESCONDITION_G =4;
else if ��������="�Խ���"  then LOCAL_RESCONDITION_G =5;
else if ��������="����"  then LOCAL_RESCONDITION_G =6;
else if ��������="����"  then LOCAL_RESCONDITION_G =7;

/*ְ��*/
if ְ��= "����ʽԱ��" then position_G =0;
else if ְ��= "������" then position_G =1;
else if ְ��= "�߼�������Ա" then position_G =2;
else if ְ��= "��ǲԱ��" then position_G =3;
else if ְ��= "һ�������Ա" then position_G =4;
else if ְ��= "һ����ʽԱ��" then position_G =5;
else if ְ��= "�м�������Ա" then position_G =6;
/*��λ����*/
if ��λ���� ="����" then comp_type=0;
else if ��λ���� ="���йɷ�" then comp_type=1;
else if ��λ���� ="������ҵ" then comp_type=2;
else if ��λ���� ="������ҵ��λ" then comp_type=3;
else if ��λ���� ="��Ӫ��ҵ" then comp_type=4;
else if ��λ���� ="�������" then comp_type=5;
else if ��λ���� ="˽Ӫ��ҵ" then comp_type=6;
else if ��λ���� ="������ҵ" then comp_type=7;



if SOCIAL_SECURITY_RADICES>=PUBLIC_FUNDS_RADICES then SOCIAL_PUBLIC_RADICES=SOCIAL_SECURITY_RADICES;
else SOCIAL_PUBLIC_RADICES=PUBLIC_FUNDS_RADICES;

/*��˾����*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*�»�*/
if loan_month_return_new >�����»� then �����»� = loan_month_return_new;
if  card_used_amt_sum_new>���ÿ��»� then ���ÿ��»� = card_used_amt_sum_new;
if ���¸�ծ��>��ծ��   then ��ծ��=���¸�ծ��;
if �籣���� >���������  then ����=�籣����;
else ����=���������;
/*��ر�ǩ*/
if  ��ر�ǩ="���"  then  nonlocal=0;
else if ��ر�ǩ="����"  then  nonlocal=1;
else nonlocal=2;
/*�Ʋ���Ϣ*/
if �Ʋ���Ϣ = "�з��г�" then asset = 0;
else if �Ʋ���Ϣ = "�з��޳�" then asset =1;
else if �Ʋ���Ϣ = "�޷��г�" then asset = 2;
else if �Ʋ���Ϣ = "�޷��޳�" then asset = 3;

rename �����ܸ�ծ�ܼ�= all  ����=basenumber;
drop  ��ر�ǩ ��λ���� ְ�� �������� н�ʷ��ŷ�ʽ ��������  ����ʱ�� ID_CARD_NO RESIDENCE_ADDRESS PERMANENT_ADDRESS PHONE1 ��סʡ ��ס�� ��ס�� ����ʡ ������ ������
 ס������ �����̶� ��λ����  ְλ COMP_ADDRESS  CURRENT_INDUSTRY ����ʡ ������ ������ INDUSTRY_NAME cc_name oc_name ��������  ;
rename ����=od;
run;


data dta.apply_demo;
set apply_demo;
drop 	NAME BRANCH_CODE BRANCH_NAME	SOURCE_CHANNEL	DESIRED_PRODUCT
����	�����ŵ�ʱ��	�����ŵ�	END_ACT_ID_	ACT_ID_	��ǰ״̬	auto_reject_time	auto_reject	ID	FIRST_REFUSE_CODE
FIRST_REFUSE_DESC	SECOND_REFUSE_CODE	SECOND_REFUSE_DESC	THIRD_REFUSE_CODE	THIRD_REFUSE_DESC	REFUSE_INFO_NAME
REFUSE_INFO_NAME_LEVEL1	REFUSE_INFO_NAME_LEVEL2	CANCEL_REMARK	FACE_SIGN_REMIND	CREATED_USER_NAME	UPDATED_TIME	
APPROVED_PRODUCT_NAME	APPROVED_SUB_PRODUCT_NAME	LOAN_LIFE	LOAN_AMOUNT	REFUSE_INFO_NAME	REFUSE_INFO_NAME_LEVEL1
REFUSE_INFO_NAME_LEVEL2	CREATED_USER_NAME	UPDATED_TIME	����״̬	check_date	�����·�	check_week	ͨ��	�ܾ�	check_end	
approve_��Ʒ	contract_no	net_amount	contract_amount	service_fee_amount	documentation_fee	sign_date	ǩԼʱ��	capital_channel_code	
�ſ��·�	�ſ����� created_name_first  updated_name_first created_time_first  updated_time_first ���˲�Ʒ����_����  ���˲�ƷС��_����
REFUSE_INFO_NAME_final REFUSE_INFO_NAME_LEVEL1_final REFUSE_INFO_NAME_LEVEL2_final created_name_final  updated_time_final INSURANCE_COMPANY �ɷѷ�ʽ CREATED_TIME
sales_name  sales_code �Ʋ���Ϣ ��ְʱ��; 

run;


/**/
/*libname appRaw odbc  datasrc=approval_nf;*/
/**/
/**/
/*/*����֤����*/*/
/*data apply_contacts;*/
/*set approval.apply_contacts;*/
/*if relation ="201" ;*/
/*run;
proc  freq data = dta.customer_info;
table approve_��Ʒ;
run;


data test;
set dta.customer_info;
rename age=���� branch_name=Ӫҵ�� group_level=��Ⱥ;
run;


data cc;
set test;
if ����ʱ��>mdy(05,31,2018) ;
��1�����в�ѯ���� = sum(��1���´����ѯ����,��1�������ÿ���ѯ����,��1���±��˲�ѯ����);
��3�����в�ѯ���� = sum(��3���´����ѯ����,��3�������ÿ���ѯ����,��3���±��˲�ѯ����);
���������в�ѯ���� = sum(��2������ѯ����,��2�����ÿ���ѯ����,��2����˲�ѯ����);

��1�´���Ӹ��˴��� = sum(��1���´����ѯ����,��1���±��˲�ѯ����);
��3�´���Ӹ��˴��� = sum(��3���´����ѯ����,��3���±��˲�ѯ����);

/*��6���¸��˲�ѯ�޳�*/
if  approve_��Ʒ = "E�״�-�Թ�"   and  ��6���±��˲�ѯ���� >4 then ��6���¸��˲�ѯ�޳�=1 ;
else if approve_��Ʒ = "E�״�-���籣" and  ��6���±��˲�ѯ���� >4 then ��6���¸��˲�ѯ�޳�=1 ;
else if  ��6���±��˲�ѯ���� >5 then ��6���¸��˲�ѯ�޳�=1 ;

/*��3���´����ѯ�޳�*/
if ( kindex(approve_��Ʒ,"U��ͨ") or kindex(approve_��Ʒ,"E��ͨ")) and ��3�´���Ӹ��˴��� >11 then ��3���´����ѯ�޳�=1 ;
else if  kindex(approve_��Ʒ,"���籣")  and ��3�´���Ӹ��˴��� >3 then ��3���´����ѯ�޳�=1 ;
else if  kindex(approve_��Ʒ,"E�״�-�Թ�")  and ��3�´���Ӹ��˴��� >3 then ��3���´����ѯ�޳�=1 ;
else if  ��3�´���Ӹ��˴��� >7 then ��3���´����ѯ�޳�=1 ;

/*���������Ⱥ�޳�*/

/*if CC_name  in ("����/�ִ�/����","��ͨ����/�ִ�/���� ������ͨ���䡢�ִ�������")  and   INDUSTRY_NAME="��ͨ����/�ִ�/����" then do ;*/
/*if (not ( kindex(��Ʒ����,"U��ͨ")) or kindex(��Ʒ����,"E��ͨ"))  and ��ر�ǩ ="���" then ���������Ⱥ�޳�=1 ;*/
/*if ��ر�ǩ ="����"  and ���������<=3000 and  (not ( kindex(��Ʒ����,"U��ͨ") or kindex(��Ʒ����,"E��ͨ")) ) and ��ʵ��������<=3000 and �籣���� <=3000    then ���������Ⱥ�޳�=1 ;*/
/*end;*/
/**/
/*if   kindex(INDUSTRY_NAME,"����ҵ") and kindex(CC_name ,"����ҵ") then do ;*/
/*if (not ( kindex(��Ʒ����,"U��ͨ")) or kindex(��Ʒ����,"E��ͨ"))  and ��ر�ǩ ="���" then ���������Ⱥ�޳�=1 ;*/
/*if ��ر�ǩ ="����"  and ���������<=3000 and  (not ( kindex(��Ʒ����,"U��ͨ") or kindex(��Ʒ����,"E��ͨ")) ) and ��ʵ��������<=3000 and �籣���� <=3000    then ���������Ⱥ�޳�=1 ;*/
/*end;*/

/*if (not ( kindex(��Ʒ����,"U��ͨ") or kindex(��Ʒ����,"E��ͨ"))) */
/*and  Ӫҵ�� in ("��������·Ӫҵ��","���ݵ�һӪҵ��","�Ϻ�����·Ӫҵ��","�����е�һӪҵ��")  */
/*and ((CC_name  in ("����/�ִ�/����","��ͨ����/�ִ�/���� ������ͨ���䡢�ִ�������")  and   INDUSTRY_NAME="��ͨ����/�ִ�/����" )*/
/*or ( kindex(INDUSTRY_NAME,"����ҵ") and kindex(CC_name ,"����ҵ")))then ���������Ⱥ�޳�=1 ;*/

if  kindex(��λ����,"ú̿") or kindex(��λ����,"úҵ") or kindex(��λ����,"ú��")  then ���������Ⱥ�޳�=1; 


/*�ڲ����������޳�*/

if kindex(Ӫҵ��,"����")  and sum(��2������ѯ����,��2�����ÿ���ѯ����,��2����˲�ѯ����) >=48  then �ڲ����������޳�=1;

if kindex(Ӫҵ��,"���ͺ���")  and ��λ�� ="������"  and �ⲿ��ծ��>=300  then �ڲ����������޳�=1;

if kindex(Ӫҵ��,"����") and ְ��="������Ա"  and ( kindex(INDUSTRY_NAME,"����ҵ") and kindex(CC_name ,"����ҵ"))  then �ڲ����������޳�=1  ;

if kindex(Ӫҵ��,"����") and INDUSTRY_NAME ="����/����"  and CC_name ^="���л���"  and ���������в�ѯ����>=32  then �ڲ����������޳�=1  ;

if kindex(Ӫҵ��,"֣��")  and ���������в�ѯ����>=40  then �ڲ����������޳�=1 ;

if ( kindex(Ӫҵ��,"����") or   kindex(Ӫҵ��,"�γ�")or  kindex(Ӫҵ��,"���")or  kindex(Ӫҵ��,"�人")) and ���������в�ѯ����>=32  then �ڲ����������޳�=1 ;

if ( kindex(Ӫҵ��,"֣��") or   kindex(Ӫҵ��,"����")) and (kindex(��λ����,"������") or kindex(��λ����,"������")or kindex(��λ����,"�侯")or kindex(��λ����,"��Ժ")or kindex(��λ����,"���Ժ")
or kindex(��λ����,"����")or kindex(��λ����,"����")or kindex(��λ����,"�䶾")or kindex(��λ����,"��װ��")or kindex(��λ����,"�ܽ�")
or kindex(��λ����,"�ɳ���")or kindex(��λ����,"��ͨ����")or kindex(��λ����,"����") ) and ��Ⱥ^="A" then  �ڲ����������޳�=1 ;

if kindex(Ӫҵ��,"���") and ��Ⱥ in ("D","E") and (not ( kindex(approve_��Ʒ,"U��ͨ")) or (kindex(approve_��Ʒ,"E��ͨ")))  and ס������ ="����" then �ڲ����������޳�=1  ;



if kindex(approve_��Ʒ,"E��ͨ") then do;
	if kindex(Ӫҵ��,"�Ϻ�") and ��Ⱥ in ("D","E") and  ����״�� ^="�ѻ�"  and IS_HAS_HOURSE^="y" then �ڲ����������޳�=1  ;
	if kindex(Ӫҵ��,"����")  and ��Ⱥ ="E"  then �ڲ����������޳�=1 ;
	if kindex(Ӫҵ��,"����") or kindex(Ӫҵ��,"����")   then do ;
		if ��Ⱥ in ("D","C","E") and ��ر�ǩ="���" and IS_HAS_HOURSE^="y"    then  �ڲ����������޳�=1 ;
	end;
end;

if ( kindex(approve_��Ʒ,"U��ͨ") or kindex(approve_��Ʒ,"E��ͨ")) then do;
	if kindex(Ӫҵ��,"�Ϸ�")  and ����״��="����" and �ⲿ��ծ��>=300  then �ڲ����������޳�=1;
end;

if kindex(approve_��Ʒ,"E��ͨ")  then do;
	if kindex(Ӫҵ��,"�Ϻ�")  and (not kindex(approve_��Ʒ,"�Թ�")) and ��Ⱥ in ("D","C","E") and ��ر�ǩ="���" and IS_HAS_HOURSE^="y"   then �ڲ����������޳�=1;

	end;

if CC_CODE in ("CC04","CC05") AND ��Ⱥ in ("C","D","E","F") and (kindex(Ӫҵ��,"֣��") or kindex(Ӫҵ��,"����"))  THEN �ڲ����������޳�=1;

/*Ӫҵ�����������޳�*/

if kindex(Ӫҵ��,"�Ϻ�") and ����>=50 then  Ӫҵ�����������޳�=1; 

if kindex(Ӫҵ��,"�Ϻ�") and ְ��="������Ա"  and kindex(approve_��Ʒ,"E��ͨ") then Ӫҵ�����������޳�=1; 

if kindex(Ӫҵ��,"����") and (not ( kindex(approve_��Ʒ,"U��ͨ") or kindex(approve_��Ʒ,"E��ͨ")))   and ��λ��= "ƽ̶��" then Ӫҵ�����������޳�=1; 

if kindex(Ӫҵ��,"�ɶ�") and kindex(��λ��,"üɽ��")  then Ӫҵ�����������޳�=1 ;
if (kindex(Ӫҵ��,"���") or kindex(Ӫҵ��,"�ɶ�")or kindex(Ӫҵ��,"�人")or kindex(Ӫҵ��,"�γ�") ) and INDUSTRY_NAME ="����/����" and CC_name ^="���л���"   then Ӫҵ�����������޳�=1; 

if kindex(Ӫҵ��,"�Ϸ�") and kindex(��λ����,"���")  then Ӫҵ�����������޳�=1 ;

if kindex(approve_��Ʒ,"E��ͨ")  
then do;
	if kindex(Ӫҵ��,"����")  or kindex(Ӫҵ��,"����")  
	then do;
		if �ɷѷ�ʽ="�½�" and INSURANCE_PAY_AMT<600   then  Ӫҵ�����������޳�=1;
	end;
end;

if kindex(Ӫҵ��,"֣��") and (kindex(��λ��,"����") or kindex(��λ����,"�����")) then Ӫҵ�����������޳�=1 ;

if kindex(Ӫҵ��,"����") and (kindex(��λ����,"ˮ") or kindex(��λ����,"�����")) then Ӫҵ�����������޳�=1 ;
if kindex(Ӫҵ��,"����") and (not ( kindex(approve_��Ʒ,"U��ͨ") or kindex(approve_��Ʒ,"E��ͨ")))  and  CC_name ="����ҵ" then Ӫҵ�����������޳�=1 ;

if kindex(Ӫҵ��,"����") then do ;
	if kindex( ��λ��,"����")  or kindex(��λ��,"�»�")  or kindex(��λ��,"����") then do  ; 
		if INDUSTRY_NAME ="����/����"  then Ӫҵ�����������޳�=1;
	end;
	else if   ( kindex(��λ����,"ˮ") or  kindex(��λ����,"��·")) then Ӫҵ�����������޳�=1;
	else if  kindex(��λ����,"��") and not(kindex(��λ����,"���ҵ���") and (���������>=8000  or �籣����>=8000)) then Ӫҵ�����������޳�=1;
	else if kindex(��λ��,"������")  then Ӫҵ�����������޳� =1;
	else if kindex(INDUSTRY_NAME,"ҽԺ")  then Ӫҵ�����������޳� =1;
end ;

if kindex(Ӫҵ��,"����") and ְ��="������Ա"  and ��ס�� ^="������"  and ��ס�� ^="������"  then Ӫҵ�����������޳�=1  ;

if kindex(Ӫҵ��,"����") and  INDUSTRY_NAME ="����ҵ"  then Ӫҵ�����������޳�=1 ;

if kindex(Ӫҵ��,"����") and ��λ�� in ("ʯ������������","������") then Ӫҵ�����������޳�=1;

if kindex(Ӫҵ��,"���ͺ���") and (kindex(��λ����,"������") or kindex(��λ����,"������")or kindex(��λ����,"�侯")or kindex(��λ����,"��Ժ")
or kindex(��λ����,"���Ժ") or  kindex(��λ����,"��ͨ��·")
or kindex(��λ����,"����")or kindex(��λ����,"����")or kindex(��λ����,"�䶾")or kindex(��λ����,"��װ��")or kindex(��λ����,"�ܽ�")
or kindex(��λ����,"�ɳ���")or kindex(��λ����,"��ͨ����")or kindex(��λ����,"����"))  then Ӫҵ�����������޳�=1;

if kindex(Ӫҵ��,"��³ľ��") and  kindex(��λ����,"����̨") then Ӫҵ�����������޳�=1 ;

if kindex(Ӫҵ��,"���") and ( ��λ�� ="��������"  or ��λ�� ="��³�ƶ�����"  or kindex(��λ����,"��·") 
or kindex(��λ����,"������") or kindex(��λ����,"������")or kindex(��λ����,"�侯")or kindex(��λ����,"��Ժ")or kindex(��λ����,"���Ժ")
or kindex(��λ����,"����")or kindex(��λ����,"����")or kindex(��λ����,"�䶾")or kindex(��λ����,"��װ��")or kindex(��λ����,"�ܽ�")
or kindex(��λ����,"�ɳ���")or kindex(��λ����,"��ͨ����")or kindex(��λ����,"����") or  kindex(��λ����,"��ͨ��·") ) then Ӫҵ�����������޳�=1;

if kindex(Ӫҵ��,"����") and ( ��λ�� ="ʯ������������"  or ��λ�� ="������"  )then Ӫҵ�����������޳�=1;

if kindex(Ӫҵ��,"����") then do;
	if  kindex(��λ��,"����") or  kindex(��ס��,"����") then Ӫҵ�����������޳� =1;
	if  kindex(����ʡ,"����")  then Ӫҵ�����������޳� =1;
	if  kindex(����ʡ,"����") then Ӫҵ�����������޳� =1;
	if  kindex(������,"�γ�")  then Ӫҵ�����������޳� =1;

	end;

if kindex(Ӫҵ��,"����") and ְ��="������Ա"   then Ӫҵ�����������޳�=1;
if kindex(Ӫҵ��,"����")  and (��λ�� ="������" or ��ס��="������")  then  Ӫҵ�����������޳�=1; 

if kindex(Ӫҵ��,"����") and ְ��="������Ա"   then Ӫҵ�����������޳�=1  ;

if kindex(Ӫҵ��,"���")  and ����>=50 then  Ӫҵ�����������޳�=1; 


/*�����־ܾ�*/
if 0<������<468  and ��Ⱥ^="A" AND ��Ⱥ^="B" THEN �����������޳�=1;
;
run;





/*proc sort data = cc out =cc3;by ����ʱ�� ;run;*/
/**/
/**/
/*data cc1;*/
/*set cc;*/
/*if auto_reject^=1 and ������<1;*/
/*run;*/
/*data cc3;*/
/*set cc;*/
/*if mdy(07,12,2018)<����ʱ��<mdy(07,17,2018)  and  auto_reject^=1 ;*/
/*run;*/
/**/
/*data cc2;*/
/*set tq_score;*/
/*if apply_code ="PL2018071217343162783196";*/
/*run;*/
/**/
/*data cc2;*/
/*set appraw.apply_identity_match;*/
/*if apply_code ="PL2018071217343162783196";*/
/*run;*/
