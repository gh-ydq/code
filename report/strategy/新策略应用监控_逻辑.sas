/*option compress = yes validvarname = any;*/
/*libname csdata 'E:\guan\ԭ����\csdata';*/
/*libname approval 'E:\guan\ԭ����\approval';*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname cred "E:\guan\ԭ����\cred";*/
/*libname mics "E:\guan\�м��\repayfin";*/
/*libname res "E:\guan\ԭ����\res";*/
/*libname yc 'E:\guan\�м��\yc';*/
/*libname repayfin "E:\guan\�м��\repayfin";*/
/*libname urule odbc datasrc=urule_nf;*/
/*libname appr odbc datasrc=approval_nf;*/
/**/
/*x 'E:\guan\���Լ��\��ģ�͡��绰���������.xlsx';*/


data _null_;
format dt first_month yymmdd10.;
dt = today() - 1;
db=intnx('month',dt,0,'b');
nd = dt-db;
first_month=mdy(11,1,2018);
due_month=intck("month",first_month,dt)+11;
call symput("nd", nd);
call symput("dt", dt);
call symput("db", db);
call symput('due_month',due_month);
run;
data date;
format date  yymmdd10. prime_key ;
 n=today()-mdy(11,1,2018);
/* n=intnx("year",&nt.,12,"same")-&start_date.;*/
do i=1 to n;
date=intnx("day",mdy(11,1,2018),i-1);
output;
end;
drop i;
run;
***
B18 ������
B19 ��Ϣ��
code�Ǵ��룬DESC�ǽ��
���� ����(����)
01 ��0,2]
02  (2,5]
03  (5,10] 
04  10�������ϣ�����ͬһ������
05  ����ͬһ������
99  �ֻ���T-1��ǰ������
***;
data apply_identity_match_tq;
set approval.apply_identity_match;
if channel="TQ";
if type="BLACK";
run;
data apply_identity_match;
set approval.apply_identity_match;
if channel="TJ";;
run;
/*data aa;*/
/*set apply_identity_match;*/
/*if value=1;*/
/*run;*/
data apply_refusecancel_history;
set approval.apply_refusecancel_history;
if reason_info_code3='R754';
run;
data early_warning_info;
set appr.early_warning_info;
run;
proc sql;
create table early_warning_info_ as
select * from early_warning_info where SOURCE='urule' and LEVEL='R' and CONTENT like '2%';
quit;
data dianhua_derived_data;
set cred.dianhua_derived_data;
run;
proc sort data=dianhua_derived_data;by descending id;run;
proc sort data=dianhua_derived_data nodupkey;by mobile;run;
/*proc sql;*/
/*create table apply_info as */
/*select a.apply_code,a.CREATED_TIME,b.PHONE1,c.call_tel_total_nums from approval.apply_info as a*/
/*left join approval.apply_base as b on a.apply_code=b.apply_code*/
/*left join cred.dianhua_derived_data as c on b.PHONE1=c.mobile;*/
/*quit;*/
/*data apply_info_;*/
/*set apply_info;*/
/*DATE=datepart(CREATED_TIME);*/
/*run;*/
/*proc sort data=apply_info_;by descending DATE;run;*/
/*proc sort data=apply_info_ out=apply_info;by apply_code;run;*/
*��Ӫҵ����;
data apply_info;
set approval.apply_info(keep = apply_code name id_card_no branch_code branch_name DESIRED_PRODUCT);
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
format date yymmdd10.;
date=datepart(CREATED_TIME);
�����·�= put(DATE, yymmn6.);
run;
*��������;
/*���״�¼�븴�����ʱ����Ϊ����ʱ��*/
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE")); /*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
format DATE YYMMDD10.;
DATE=datepart(create_time_);
����=1;
�����·�= put(DATE, yymmn6.);
keep bussiness_key_ create_time_ DATE ���� �����·�;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time nodupkey; by apply_code; run;
data apply_time_;
set apply_time;
if DATE>=mdy(11,1,2018);
run;
*���������֡�;
data credit_score;
set approval.credit_score;
run;
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

*�����ˡ�;
/*���������������*/
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
format �������� yymmdd10.;
�������� = check_date;
check_week = week(check_date); /*�����ܣ�һ�굱�еĵڼ���*/
if check_result = "ACCEPT" then ͨ�� = 1;
if check_result = "REFUSE" then �ܾ� = 1;
rename check_result = ����״̬ app_prdname_final = ���˲�Ʒ����_���� app_sub_prdname_final = ���˲�ƷС��_����
		loan_amt_final = ���˽��_���� loan_life_final = ��������_����;
run;
data check_result;
set check_result;
if ���˲�Ʒ����_����^="" then approve_��Ʒ=���˲�Ʒ����_����;
else if  app_prdname_first^="" then approve_��Ʒ= app_prdname_first;
else approve_��Ʒ=DESIRED_PRODUCT;
run;

data new_model_score;
set approval.new_model_score;
run;
proc sort data=new_model_score;by apply_code descending CREATED_TIME;run;
proc sort data=new_model_score out=new_model_score_final nodupkey;by apply_code;run;
proc sort data=new_model_score;by apply_code CREATED_TIME;run;
proc sort data=new_model_score out=new_model_score_first nodupkey;by apply_code;run;
proc sql;
create table test_r_1 as 
select a.*,b.PHONE1,c.call_tel_total_nums,d.Ӫҵ��,d.NAME,e.model_score_level,e.model_score,e.branch_class,f.group_Level,g.reason_info_code3,
	h.approve_��Ʒ,h.����״̬,h.��������,h.REFUSE_INFO_NAME,h.REFUSE_INFO_NAME_LEVEL1,h.REFUSE_INFO_NAME_LEVEL2,i.third_refuse_code,i.third_refuse_desc,i.first_refuse_code,
	j.value as rong360,k.value as tq_black,l.model_score_level as model_score_level_first
from apply_time_ as a
left join approval.apply_base as b on a.apply_code=b.apply_code
left join dianhua_derived_data as c on b.PHONE1=c.mobile
left join apply_info as d on a.apply_code=d.apply_code
left join new_model_score_final as e on a.apply_code=e.apply_code
left join credit_score as f on a.apply_code=f.apply_code
left join apply_refusecancel_history as g on a.apply_code=g.apply_code
left join check_result as h on a.apply_code=h.apply_code
left join auto_reject_db as i on a.apply_code=i.apply_code
left join apply_identity_match as j on a.apply_code=j.apply_code
left join apply_identity_match_tq as k on a.apply_code=k.apply_code
left join new_model_score_first as l on a.apply_code=l.apply_code;
quit;
data test_r_2;
set test_r_1;
if Ӫҵ�� in ("��³ľ���е�һӪҵ��","�����е�һӪҵ��","������е�һӪҵ��") then region="��һ��";
	else if Ӫҵ�� in ("����е�һӪҵ��","�Ϻ�����·Ӫҵ��","��������·Ӫҵ��","�����е�һӪҵ��","֣���е�һӪҵ��","�����е�һӪҵ��","�����е�һӪҵ��","������ҵ������","�γ��е�һӪҵ��"
		,"�人�е�һӪҵ��","����е�һӪҵ��","��ͨ��ҵ������","�Ͼ���ҵ������","տ���е�һӪҵ��") then region="������";
	else region="�ڶ���";
if region="��һ��" then do;
	if model_score>=585 then �ֵ�="A";
		else if model_score>=525 then �ֵ�="B";
		else if model_score>=500 then �ֵ�="D";
		else if model_score<1 then �ֵ�="Z";
		else �ֵ�="F";
	end;
else if region="������" then do;
	if model_score>=620 then �ֵ�="B";
		else if model_score>=565 then �ֵ�="D";
		else if model_score>=545 then �ֵ�="E";
		else if model_score<1 then �ֵ�="Z";
		else �ֵ�="F";
	end; 
else do;
	if model_score>=630 then �ֵ�="A";
		else if model_score>=605 then �ֵ�="B";
		else if model_score>=570 then �ֵ�="C";
		else if model_score>=555 then �ֵ�="D";
		else if model_score>=515 then �ֵ�="E";
		else if model_score<1 then �ֵ�="Z";
		else �ֵ�="F";
	end; 

if third_refuse_code='R751' then ������=1;else ������=0;
if first_refuse_code='R757' then ��ģ��=1;else ��ģ��=0;
if first_refuse_code='R754' then �绰��=1;else �绰��=0;
if first_refuse_code='R755' then ��360=1;else ��360=0;
if first_refuse_code='R758' then ���=1;else ���=0;
if first_refuse_code in ('R756',"R743") then ����������=1;else ����������=0;
if first_refuse_code^='' then �Զ��ܾ�=1;else �Զ��ܾ�=0;
if �Զ��ܾ�=1 and ������=0 and ����������=0 and �绰��=0 and ��360=0 and ��ģ��=0 and ���=0 then �����ܾ�=1;else �����ܾ�=0;
if apply_code='PL154140087720102300000886' then do;����������=1;��360=0;end;

if rong360=1 then ��360����=1;else ��360����=0;
if call_tel_total_nums>=17 then �绰�����=1;else �绰�����=0;
if model_score_level="F" then ��ģ�ʹ���=1;else ��ģ�ʹ���=0;
if group_Level="F" then �����ִ���=1;else �����ִ���=0;
if tq_black=1 then ��������������=1;else ��������������=0;

if ����״̬ in ('REFUSE','ACCEPT') then ��������=1;else ��������=0;
if ����״̬='ACCEPT' then ����ͨ��=1;else ����ͨ��=0;

if ���=1 and (������=0 and ��ģ��=0 and �����ܾ�=0) then ��ܷ���=1;else ��ܷ���=0;
if ���=1 and (������=1 or ��ģ��=1 or �����ܾ�=1) then �����=1;else �����=0;
if ��������������=1 and (������=0 and ��ģ��=0 and �����ܾ�=0 and ���=0) then ��������������=1;else ��������������=0;
if ��������������=1 and (������=1 or ��ģ��=1 or �����ܾ�=1 or ���=1) then ������������=1;else ������������=0;
if ��360����=1 and (������=0 and ����������=0 and �����ܾ�=0  and ��ģ��=0  and ���=0) then ��360����=1;else ��360����=0;
if ��360����=1 and (������=1 or ����������=1 or �����ܾ�=1  or ��ģ��=1 or ���=1) then ��360��=1;else ��360��=0;
if �绰�����=1 and (������=0 and ����������=0 and �����ܾ�=0  and ��360=0  and ���=0) then �绰�����=1;else �绰�����=0;
if �绰�����=1 and (������=1 or ����������=1 or �����ܾ�=1 or ��360=1 or ���=1) then �绰����=1;else �绰����=0;

if region^=branch_class and branch_class^='' then Ӫҵ���������=1;else Ӫҵ���������=0;
if model_score_level^=�ֵ� and model_score_level^='' then �ֵ�����=1;else �ֵ�����=0;
if ��ģ�ʹ���^=��ģ�� then ��ģ�ʹ���=1;else ��ģ�ʹ���=0;
if �����ִ���^=������ then �����ִ���=1;else �����ִ���=0;
if �绰�����^=�绰�� then �绰�����=1;else �绰�����=0;
if ��360����^=��360 then ��360����=1;else ��360����=0;
if ��������������^=���������� then ��������������=1;else ��������������=0;
if �绰�����=1 or ��360����=1 or Ӫҵ���������=1 or �ֵ�����=1 or ��ģ�ʹ���=1 or �����ִ���=1 or ��������������=1 then ����=1;else ����=0;

if model_score_level_first=model_score_level then �����䶯=0;else �����䶯=1;
if model_score_level_first^='F' and model_score_level='F' then ���Զ��ܾ����Զ��ܾ�=1;else ���Զ��ܾ����Զ��ܾ�=0;
if model_score_level_first='F' and model_score_level^='F' then �Զ��ܾ�����Զ��ܾ�=1;else �Զ��ܾ�����Զ��ܾ�=0;

array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
run;
proc sort data=test_r_2;by apply_code;run;
proc sort data=test_r_2 nodupkey;by apply_code;run;
proc sql;
create table test_r_3 as
select Date,count(apply_code) as ������,sum(�����ܾ�) as ���ŵȾܾ���,sum(������) as �����־ܾ���,sum(��ģ��) as ��ģ��,sum(���) as ���,sum(��ܷ���) as ��ܷ���,sum(�����) as �����,sum(����������) as ����������,
	sum(������������) as ������������,sum(��������������) as ��������������,sum(��360) as ��360,sum(��360��) as ��360��,sum(�Զ��ܾ�) as �Զ��ܾ�,
	sum(��360����) as ��360����,sum(�绰��) as �绰��,sum(�绰����) as �绰����,sum(�绰�����) as �绰�����,sum(����ͨ��) as ����ͨ����,sum(��������) as ��������,
	max(����) as ����,sum(�����ִ���) as �����ִ���,sum(��ģ�ʹ���) as ��ģ�ʹ���,sum(��������������) as ��������������,sum(��360����) as ��360����,sum(�绰�����) as �绰�����,
	sum(�����䶯) as �����䶯,sum(���Զ��ܾ����Զ��ܾ�) as ���Զ��ܾ����Զ��ܾ�,sum(�Զ��ܾ�����Զ��ܾ�) as �Զ��ܾ�����Զ��ܾ�
	from test_r_2 group by Date;
quit;
proc sql;
create table test_r_4 as 
select a.date,b.* from date as a
left join test_r_3 as b on a.date=b.Date;
quit;
proc sort data=test_r_4;by Date;run;
data test_r_5;
set test_r_4;
if Date>=&db.;
run;
filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]Sheet2!r5c3:r35c12";
data _null_;set test_r_5;file DD;put ������ ���ŵȾܾ��� �����־ܾ��� ��ģ�� ��� �������������� ���������� ��360�� ��360���� ��360;run;

filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]Sheet2!r5c13:r35c26";
data _null_;set test_r_5;file DD;put �绰���� �绰����� �绰�� ����ͨ���� �������� ���� �Զ��ܾ� �����ִ��� ��ģ�ʹ��� �������������� ��360���� �绰����� �����䶯 ���Զ��ܾ����Զ��ܾ�;run;

*���ֵ������ͨ����;
proc sql;
create table test_r_3_ as
select Date,model_score_level,sum(��������) as ��������,sum(����ͨ��) as ����ͨ����
	from test_r_2 group by Date,model_score_level;
quit;
data test_r_4_1;
set test_r_3_;
if model_score_level^="";
drop ��������;
run;
proc transpose data=test_r_4_1 out=test_r_5_1 prefix=tg_;
	ID MODEL_SCORE_LEVEL;
	BY Date;
	var ����ͨ����;
run;
proc sql;
create table test_r_6_1 as 
select a.date,b.* from date as a
left join test_r_5_1 as b on a.date=b.date;
quit;
data test_r_7_1;
set test_r_6_1;
if date>=&db.;
run;
filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]Sheet2!r5c27:r34c31";
data _null_;set test_r_7_1;file DD;put tg_A tg_B tg_C tg_D tg_E;run;

data test_r_4_2;
set test_r_3_;
if model_score_level^="";
drop ����ͨ����;
run;
proc transpose data=test_r_4_2 out=test_r_5_2 prefix=tg_;
	ID MODEL_SCORE_LEVEL;
	BY Date;
	var ��������;
run;
proc sql;
create table test_r_6_2 as 
select a.date,b.* from date as a
left join test_r_5_2 as b on a.date=b.date;
quit;
data test_r_7_2;
set test_r_6_2;
if date>=&db.;
run;
filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]Sheet2!r5c32:r34c36";
data _null_;set test_r_7_2;file DD;put tg_A tg_B tg_C tg_D tg_E;run;

*�¶�©�����;
data test_r_5_;
set test_r_4;
month=put(Date,yymmn6.);
/*if date>mdy(11,5,2018);*/
array num _numeric_;
do over num;
If num="." Then num=0;
end;
run;
proc sql;
create table test_r_6 as 
select month,sum(������) as a01_������,sum(���ŵȾܾ���) as a02_���ŵȾܾ���,sum(�����־ܾ���) as a03_�����־ܾ���,sum(��ģ��) as a04_��ģ��,sum(���) as a05_���,sum(��������������) as a06_��������������,
	sum(����������) as a07_����������,sum(��360��) as a08_��360��,sum(��360����) as a09_��360����,sum(��360) as a10_��360,sum(�绰����) as a11_�绰����,sum(�绰�����) as a12_�绰�����,sum(�绰��) as a13_�绰��,
	sum(����ͨ����) as a17_����ͨ����,sum(��������) as a18_��������,sum(�Զ��ܾ�) as a14_�Զ��ܾ�,sum(�����䶯) as a15_�����䶯,sum(���Զ��ܾ����Զ��ܾ�) as a16_���Զ��ܾ����Զ��ܾ�
from test_r_5_ group by month;
quit;
proc transpose data=test_r_6 out=test_r_7 prefix=month_;
	var a01_������ a02_���ŵȾܾ��� a03_�����־ܾ��� a04_��ģ�� a05_��� a06_�������������� a07_���������� a08_��360�� a09_��360���� a10_��360 a11_�绰���� a12_�绰����� a13_�绰��
		a14_�Զ��ܾ� a15_�����䶯 a16_���Զ��ܾ����Զ��ܾ� a17_����ͨ���� a18_��������;
	ID month;
run;
%macro jinjian();
	%do i = 11 %to &due_month.;
		data _null_;
		format col_ja $2.;*����Ϊ1λ����3λ��ʱ��������;
		col_ja=3+(&i.-11)*4;
		call symput('col_ja',col_ja);
		format month help_date yymmdd10.;
		help_date=mdy(12,1,2017);
		month=intnx('month',help_date,&i.);
		str_month='month_' || put(month,yymmn6.);
		call symput('str_month',str_month);
		run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r4c&col_ja.:r21c&col_ja.";
		data _null_;set test_r_7;file DD;put &str_month.;run;
	%end;
%mend;
	
%jinjian();
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r4c3:r21c3";*/
/*data _null_;set test_r_7;file DD;put month_11;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r4c7:r21c7";*/
/*data _null_;set test_r_7;file DD;put month_12;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r4c11:r21c11";*/
/*data _null_;set test_r_7;file DD;put month_1;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r4c15:r21c15";*/
/*data _null_;set test_r_7;file DD;put month_2;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r4c19:r21c19";*/
/*data _null_;set test_r_7;file DD;put month_3;run;*/

*�¶ȸ��ֵ���ͨ����;
data test_r_3_a;
set test_r_3_;
month=month(Date);
array num _numeric_;
do over num;
If num="." Then num=0;
end;
run;
data test_r_3_b;
set test_r_3_a;
if model_score_level^="" and model_score_level^="F";
run;
proc sql;
create table test_r_3_c as 
select month,model_score_level,sum(��������) as ��������,sum(����ͨ����) as ����ͨ���� from test_r_3_b group by month,model_score_level;
quit;
data test_r_3_d;
set test_r_3_c;
����ͨ����=����ͨ����/��������;
run;
data test_r_3_d_1;
set test_r_3_d;
drop ����ͨ���� ��������;
run;
proc sort data=test_r_3_d_1;by MODEL_SCORE_LEVEL;run;
proc transpose data=test_r_3_d_1 out=test_r_3_e_1 prefix=month_;
	var ����ͨ����;
	ID month;
	by MODEL_SCORE_LEVEL;
run;
data test_r_3_e_1;
set test_r_3_e_1;
MODEL_SCORE_LEVEL_=1;
/*keep MODEL_SCORE_LEVEL month_11 month_12 month_1 month_2 month_3 MODEL_SCORE_LEVEL_;*/
run;
data test_r_3_d_2;
set test_r_3_d;
drop ����ͨ���� ��������;
run;
proc sort data=test_r_3_d_2;by MODEL_SCORE_LEVEL;run;
proc transpose data=test_r_3_d_2 out=test_r_3_e_2 prefix=month_;
	var ����ͨ����;
	ID month;
	by MODEL_SCORE_LEVEL;
run;
data test_r_3_e_2;
set test_r_3_e_2;
MODEL_SCORE_LEVEL_=3;
/*keep MODEL_SCORE_LEVEL month_11 month_12 month_1 month_2 month_3 MODEL_SCORE_LEVEL_;*/
run;
data test_r_3_d_3;
set test_r_3_d;
drop ����ͨ���� ����ͨ����;
run;
proc sort data=test_r_3_d_3;by MODEL_SCORE_LEVEL;run;
proc transpose data=test_r_3_d_3 out=test_r_3_e_3 prefix=month_;
	var ��������;
	ID month;
	by MODEL_SCORE_LEVEL;
run;
data test_r_3_e_3;
set test_r_3_e_3;
MODEL_SCORE_LEVEL_=2;
/*keep MODEL_SCORE_LEVEL month_11 month_12 month_1 month_2 month_3 MODEL_SCORE_LEVEL_;*/
run;
data test_r_3_f;
set test_r_3_e_1 test_r_3_e_2 test_r_3_e_3;
run;
proc sort data=test_r_3_f;by MODEL_SCORE_LEVEL MODEL_SCORE_LEVEL_;run;

%macro jinjian2();
	%do i = 11 %to &due_month.;
		data _null_;
		format col_ja $2.;*����Ϊ1λ����3λ��ʱ��������;
		col_ja=3+(&i.-11)*4;
		call symput('col_ja',col_ja);
		format month help_date yymmdd10.;
		help_date=mdy(12,1,2017);
		month=intnx('month',help_date,&i.);
		str_month='month_' || put(month,yymmn6.);
		call symput('str_month',str_month);
		run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r23c&col_ja.:r37c&col_ja.";
		data _null_;set test_r_7;file DD;put &str_month.;run;
	%end;
%mend;
	
%jinjian2();
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r23c3:r37c3";*/
/*data _null_;set test_r_3_f;file DD;put month_11;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r23c7:r37c7";*/
/*data _null_;set test_r_3_f;file DD;put month_12;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r23c11:r37c11";*/
/*data _null_;set test_r_3_f;file DD;put month_1;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r23c15:r37c15";*/
/*data _null_;set test_r_3_f;file DD;put month_2;run;*/
/*filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r23c19:r37c19";*/
/*data _null_;set test_r_3_f;file DD;put month_3;run;*/

*���˽�����;
proc sql;
create table test_m_1 as 
select a.apply_code,a.���˽��_����,a.approve_��Ʒ,a.��������,a.ͨ��,b.group_Level,c.model_score_level
from check_result as a
left join credit_score as b on a.apply_code=b.apply_code
left join new_model_score_final as c on a.apply_code=c.apply_code;
quit;
data test_m_2;
set test_m_1;
if ͨ��=1;
if model_score_level^='';
if model_score_level^='F';
if group_Level="A" and model_score_level="A" then ����="1A";
	else if model_score_level="A" then ����="2A";
	else if model_score_level="B" then ����="3B";
	else if model_score_level="C" then ����="4C";
	else if model_score_level="D" then ����="5D";
	else if model_score_level="E" then ����="6E";
run;
/*proc sql;*/
/*create table aa as */
/*select a.*,b.ID_CARD_NO from test_m_2 as a*/
/*left join apply_info as b on a.apply_code=b.apply_code;*/
/*quit;*/
proc sql;
create table test_m_3 as 
select approve_��Ʒ,��������,����,count(apply_code) as nums,sum(���˽��_����) as ���˽�� from test_m_2 group by approve_��Ʒ,��������,����;
quit;
/*proc sort data=test_m_3;by ��������;run;*/
data group;
input groups $3.;
cards;
1A
2A
3B
4C
5D
6E
;
run;
%macro ph();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_��Ʒ='U��ͨ';
		if ��������=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]���˼���!r3c&colb.:r8c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%ph();
%macro ph_e1();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_��Ʒ='E��ͨ';
		if ��������=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]���˼���!r12c&colb.:r17c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%ph_e1();
%macro ph_e2();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_��Ʒ='E΢��';
		if ��������=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]���˼���!r21c&colb.:r26c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%ph_e2();
%macro ph_e3();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_��Ʒ='E΢��-���籣';
		if ��������=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]���˼���!r30c&colb.:r35c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%ph_e3();

*�¶����˽�����;
data test_m_3_;
set test_m_3;
month= month(��������);
run;
proc sql;
create table test_m_3_1 as 
select approve_��Ʒ,����,month,sum(nums) as nums,sum(���˽��) as ���˽�� from test_m_3_ group by approve_��Ʒ,����,month;
quit;
%macro phm();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_��Ʒ='U��ͨ';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r42c&colb.:r47c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%phm();

%macro phme1();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_��Ʒ='E��ͨ';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r52c&colb.:r57c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%phme1();

%macro phme2();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_��Ʒ='E΢��';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r62c&colb.:r67c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%phme2();

%macro phme3();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_��Ʒ='E΢��-���籣';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.���˽�� from group as a
		left join test_m_4 as b on a.groups=b.����;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[��ģ�͡��绰���������.xlsx]�¶����!r72c&colb.:r77c&cole.";
		data _null_;set test_m_5;file DD;put ���˽�� nums;run;
	%end;
%mend;
	
%phme3();
