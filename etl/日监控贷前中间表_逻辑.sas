/*option validvarname=any;option compress=yes;*/
/*libname approval "E:\guan\ԭ����\approval";*/
/*libname midapp "E:\guan\�м��\midapp";*/


*�ձ���;
*�����ˡ�
*approval_check_result��BACK_NODE��finalReturnTask--���˳���
                                   firstVerifyTask-����(�ɰ�ڵ����ƣ���Ҳ�ǻ��˳������˼)
                                   verifyReturnTask--�����ŵ�
                                   inputCheckTask--¼�����(�ɰ�ڵ����ƣ���Ҳ�ǻ����ŵ����˼);
data macrodate;
format date  start_date  fk_month_begin month_begin  end_date last_month_end last_month_begin month_end yymmdd10.;*����ʱ�������ʽ;
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(12,31,2017);*/
call symput("tabledate",date);*����һ����;
start_date = intnx("month",date,-2,"b");
call symput("start_date",start_date);
month_begin=intnx("month",date,0,"b");
call symput("month_begin",month_begin);
month_end=intnx("month",date,1,"b")-1;
call symput("month_end",month_end);
last_month_end=intnx("month",date,0,"b")-1;
call symput("last_month_end",last_month_end);
last_month_begin=intnx("month",date,-1,"b");
call symput("last_month_begin",last_month_begin);
if day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*����26-����25��ѭ��;
end_date = mdy(month(date)+1,25,year(date));end;
else do;fk_month_begin = mdy(month(date)-1,26,year(date));
end_date = mdy(month(date),25,year(date));end;
/*����һ��12�µ׸��µ�һ��1�³����������Ȼ��������µ׻���ֿ�ֵ*/
if month(date)=12 and day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*����26-����25��ѭ��;
end_date = mdy(month(date)-11,25,year(date)+1);end;
else if month(date)=1 and day(date)<=25 then do;fk_month_begin = mdy(month(date)+11,26,year(date)-1);
end_date = mdy(month(date),25,year(date));end;
call symput("fk_month_begin",fk_month_begin);
call symput("end_date",end_date);
run;

/*%let tabledate=mdy(12,31,2016);*/
/*%let nt=mdy(1,1,2005);*/
/*%let start_date=mdy(7,1,2017);*ֻ��Ϊ�˸��ǽ������¶���;*/
/*%let end_date=mdy(9,25,2017);*�������ڵĽ�������;*/
/*%let month_begin=mdy(8,1,2017);*����1��;*/
/*%let fk_month_begin=mdy(12,26,2017);*�������ڵĿ�ʼ����;*/

data date;
format date  yymmdd10. prime_key ;
 n=today()-&start_date.;
/* n=intnx("year",&nt.,12,"same")-&start_date.;*/
do i=1 to n;
date=intnx("day",&start_date.,i-1);
prime_key=1;
output;
end;
drop i;
run;
*�������ݼ��洢apply_nfo;
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

prime_key=1;

run;

data apply_dept1;
set apply_dept(where = ( SOURCE_CHANNEL="257"));
BRANCH_NAME = 'APP';
RUN;
data apply_dept;
set apply_dept apply_dept1;
run;
proc sort data=apply_dept(where=(branch_name^="��˾����")) nodupkey out=dept(keep=branch_name prime_key);by branch_name;run;


proc sql;

create table date_dept as
select a.date,b.branch_name from date as a
left join dept as b on a.prime_key=b.prime_key;
quit;
proc sort data=date_dept;by date branch_name;run;
data back;
set approval.approval_check_result(where=(BACK_NODE in ("verifyReturnTask","inputCheckTask")));
format DATE YYMMDD10.;
DATE=datepart(CREATED_TIME);
����=1;
keep APPLY_CODE CREATED_TIME PERIOD CHECK_RESULT_TYPE BACK_NODE DATE ����;
run;
proc sort data=back;by APPLY_CODE CREATED_TIME;run;
proc sort data=back nodupkey;by APPLY_CODE;run;

proc sql;
create table backtodept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME from back as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;
proc sql;
create table backtodapet_static as
select date,BRANCH_NAME,sum(����) as ������ from backtodept group by date,BRANCH_NAME;quit;
*��������;
/*���״�¼�븴�����ʱ����Ϊ����ʱ��,E������״ν������ʱ��Ϊ����ʱ��*/
proc sql;
create table apply_t as 
select a.*,b.desired_product from approval.act_opt_log as a
left join approval.apply_info as b on a.bussiness_key_=b.APPLY_CODE;
quit;
data apply_t2;
set apply_t;
if desired_product^='Eqidai' then do;
	if task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE" then ����=1;
end;
else do;
	if task_Def_Name_ = "����" then ����=1;
end;
run;
data apply_time;
set apply_t2;
if ����=1;
format DATE YYMMDD10.;
DATE=datepart(create_time_);
�����·�= put(DATE, yymmn6.);
keep bussiness_key_ create_time_ DATE ���� �����·�;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time; by apply_code DATE; run;
proc sort data = apply_time nodupkey; by apply_code; run;

proc sql;
create table apply_time_dept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME,b.DESIRED_PRODUCT from apply_time as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;

proc sql;
create table apply_time_static as
select date,BRANCH_NAME,sum(����) as ������ from apply_time_dept group by date,BRANCH_NAME;quit;
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
�������� = put(check_date, yymmdd10.);
check_week = week(check_date); /*�����ܣ�һ�굱�еĵڼ���*/
if check_result = "ACCEPT" then ͨ�� = 1;
if check_result = "REFUSE" then �ܾ� = 1;
rename check_result = ����״̬ app_prdname_final = ���˲�Ʒ����_���� app_sub_prdname_final = ���˲�ƷС��_����
		loan_amt_final = ���˽��_���� loan_life_final = ��������_����;
run;
data midapp.check_result;
set check_result;
run;
proc sql;
create table check_result_only_approve(where=(BRANCH_NAME^="")) as
select a.APPLY_CODE,a.check_date as date ,a.ͨ��,b.branch_name from check_result(where=(ͨ��=1)) as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b  on a.apply_code=b.apply_code;
quit;
proc sql;
create table check_result_only_approve_static as
select date,BRANCH_NAME,sum(ͨ��) as ͨ���� from check_result_only_approve(where=(branch_name^="��˾����")) group by date,BRANCH_NAME;quit;

*��ǩԼ��;
data sign_contract;
set approval.contract(keep = apply_no contract_no net_amount contract_amount service_fee_amount documentation_fee sign_date );
rename apply_no = apply_code net_amount = ���ֽ�� contract_amount = ��ͬ��� service_fee_amount = ����� documentation_fee = ��֤��;
format date  yymmdd10.;
date=mdy(month(sign_date),day(sign_date),year(sign_date));
ǩԼ=1;
if date^=.;
run;
proc sort data=sign_contract nodupkey;by apply_code;run;
proc sql;
create table sign_contract_dept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME from sign_contract as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;
data act_ru_execution;
set approval.act_ru_execution(keep = business_key_ act_id_ PROC_INST_ID_ PROC_DEF_ID_ ID_);
run;*���ظ�ֵ;
proc sql;
create table execution_time as
select a.*,b.end_time_   from act_ru_execution as a
left join approval.Act_hi_taskinst as  b on a.PROC_INST_ID_=b.PROC_INST_ID_;
quit;
proc sort data=execution_time ;by PROC_INST_ID_  descending end_time_;run;
proc sort data=execution_time out=execution_time_ nodupkey;by PROC_INST_ID_;run;
data act_hi_procinst;
set approval.act_hi_procinst(keep = business_key_ end_act_id_ PROC_INST_ID_ ID_ PROC_DEF_ID_ END_TIME_);
run;*���ظ�ֵ;
*procinst�Ḳ��execution��business_key_����û��	execution ����� �ڵ�״̬���ݣ����������ַ���ƴ����;
proc sort data = act_hi_procinst nodupkey; by business_key_; run;
proc sort data = execution_time_ nodupkey; by business_key_; run;
data cur_status;
merge act_hi_procinst(in = a) execution_time_(in = b);
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
rename business_key_ = apply_code
       END_TIME_=endtime;
run;

proc sort data=cur_status(where=(��ǰ״̬="�ܾ�") ) nodupkey out=cac(keep=apply_code);by apply_code;run;
proc sort data=sign_contract_dept;by apply_code;run;
data sign_contract_dept1;
merge sign_contract_dept(in=a) cac(in=b);
by apply_code;
if not b;
run;
proc sql;
create table sign_contract_static as
select date,BRANCH_NAME,sum(ǩԼ) as ǩԼ��,sum(��ͬ���) as ǩԼ��ͬ��� from sign_contract_dept1 group by date,BRANCH_NAME;quit;
data qyjx;
merge sign_contract_dept(in=a) cac(in=b);
by apply_code;
if a & b;
run;
proc sort data =check_result_only_approve;by apply_code;run;
proc sort data=qyjx;by apply_code;run;
data qyjx2;
merge check_result_only_approve(in=a) qyjx(in=b);
by apply_code;
if not b;
run;
proc sql;
create table check_result_only_approve_qy as
select date,BRANCH_NAME,sum(ͨ��) as ͨ���� from qyjx2(where=(branch_name^="��˾����")) group by date,BRANCH_NAME;quit;
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
�ſ�=1;
/*apply_code = tranwrd(contract_no, "C", "PL");*/
�ſ��·� = put(loan_date, yymmn6.);
format date  yymmdd10.;
date=mdy(month(loan_date),day(loan_date),year(loan_date));
rename capital_channel_code = �ʽ�����;
drop status;
run;
proc sql;
create table loan_info_dept(where=(BRANCH_NAME^="")) as
select a.*,b.contract_amount,c.BRANCH_NAME from loan_info as a
left join approval.contract as b on a.contract_no=b.contract_no
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as c on b.apply_no=c.apply_code;
quit;
proc sql;
create table loan_info_static as
select date,BRANCH_NAME,sum(�ſ�) as �ſ���,sum(contract_amount) as �ſ��ͬ��� from loan_info_dept group by date,BRANCH_NAME;quit;




proc sql;
create table  Partone as
select a.date,a.BRANCH_NAME,b.������,c.������,d.ǩԼ��,d.ǩԼ��ͬ���,e.�ſ���,e.�ſ��ͬ���,f.ͨ����,g.ͨ���� as ǩ��ͨ���� from Date_dept as a
left join backtodapet_static as b on a.date=b.date and a.branch_name=b.BRANCH_NAME
left join Apply_time_static as c on a.date=c.date and a.branch_name=c.BRANCH_NAME
left join Sign_contract_static as d on a.date=d.date and a.branch_name=d.BRANCH_NAME
left join Loan_info_static as e on a.date=e.date and a.branch_name=e.BRANCH_NAME
left join check_result_only_approve_static as f on  a.date=f.date and a.branch_name=f.branch_name
left join check_result_only_approve_qy as g on a.date=g.date and a.branch_name=g.branch_name;
quit;

proc sort data=partone;by BRANCH_NAME date;run;

data Partone_cumulate1;
set Partone(where=(date>=&month_begin.));
retain �ۼƻ����� �ۼƽ����� �ۼ�ǩԼ�� �ۼ�ǩԼ��ͬ���   �ۼ�ǩ��ͨ����;
array numr _numeric_;
do over numr;
if numr=. then numr=0;
end;
by BRANCH_NAME date;
if first.BRANCH_NAME then do;
�ۼƻ�����=������;
�ۼƽ�����=������	;
�ۼ�ǩԼ��=ǩԼ��;
�ۼ�ǩԼ��ͬ���=ǩԼ��ͬ���;

�ۼ�ǩ��ͨ����=ǩ��ͨ����;
end;
else do;
�ۼƻ�����=�ۼƻ�����+������;
�ۼƽ�����=�ۼƽ�����+������;
�ۼ�ǩԼ��=�ۼ�ǩԼ��+ǩԼ��;
�ۼ�ǩԼ��ͬ���=�ۼ�ǩԼ��ͬ���+ǩԼ��ͬ���;

�ۼ�ǩ��ͨ����=�ۼ�ǩ��ͨ����+ǩ��ͨ����;
end;
run;

data Partone_cumulate2;
set Partone(where=(date>=&fk_month_begin.));
retain  �ۼƷſ��� �ۼƷſ��ͬ���  �ۼ�ͨ����;
array numr _numeric_;
do over numr;
if numr=. then numr=0;
end;
by BRANCH_NAME date;
if first.BRANCH_NAME then do;
�ۼƷſ���=�ſ���;
�ۼ�ͨ����=ͨ����;
�ۼƷſ��ͬ���=�ſ��ͬ���;
end;
else do;
�ۼƷſ���=�ۼƷſ���+�ſ���;
�ۼ�ͨ����=�ۼ�ͨ����+ͨ����;
�ۼƷſ��ͬ���=�ۼƷſ��ͬ���+�ſ��ͬ���;
end;
run;
proc sql;
create table Partone_cumulate_end as
select a.date,a.branch_name,a.�ۼƽ�����,a.�ۼƻ�����,b.�ۼ�ͨ����,b.�ۼƷſ���,b.�ۼƷſ��ͬ���	from Partone_cumulate1 as a
left join Partone_cumulate2 as b on a.date=b.date and a.branch_name=b.branch_name;
quit;

data midapp.Partone_cumulate_end;
set Partone_cumulate_end;
run;
