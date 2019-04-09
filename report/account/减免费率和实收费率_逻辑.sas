/*option compress = yes validvarname = any;*/
/*libname account odbc datasrc=account_nf;*/
/*libname csdata odbc datasrc=csdata_nf;*/
/*libname res  'E:\guan\ԭ����\res';*/
/*libname approval 'E:\guan\ԭ����\approval';*/
/*libname mtd 'E:\guan\ԭ����\account';*/
/**/
/*x  "E:\guan\���ձ���\���ڻ���\����1-15��Ӧ�շ�Ϣ���������.xlsx"; */
/*x  "E:\guan\���ձ���\���ڻ���\����16������Ӧ�շ�Ϣ���������.xlsx"; */
/*x  "E:\guan\���ձ���\���ڻ���\����Ӧ�շ�Ϣ���������.xlsx"; */

data null;
format dt yymmdd10.;
dt=today()-1;
call symput("dt", dt);
run;
%let month="201904";*�޸�Ϊ�����·�;

/*С����Ǩ֮ǰ��������bill_main_xyd��,RECEIPTΪ�Ѿ���������ݣ�RECEIVE���������ѻ�δ������*/
data bill_main_xyd;
set account.bill_main_xyd;
run;
data bill_main_xyd_a;
set bill_main_xyd;
RECEIPT=RECEIPT_OVERDUE_PENALTY+RECEIPT_OVERDUE_SERVICE_FEE;
RECEIVE=RECEIVE_OVERDUE_PENALTY+RECEIVE_OVERDUE_SERVICE_FEE;
keep contract_no CURRENT_PERIOD RECEIPT RECEIVE CLEAR_DATE OVERDUE_DAYS;
run;
/*proc sql;*/
/*create table bill_main_xyd_b as */
/*select a.*,b.��Ϣ���� from bill_main_xyd_a as a*/
/*left join fee_breaks_jm_1 as b on a.contract_no=b.contract_no and a.CURRENT_PERIOD=b.PERIOD;*/
/*quit;*/
/*proc sort data=bill_main_xyd_b;by descending clear_date;run;*/
data bill_main_xyd_c;
set bill_main_xyd_a;
offset_month=put(CLEAR_DATE,yymmn6.);
if RECEIPT>0;
rename RECEIPT=��Ϣ CURRENT_PERIOD=CURR_PERIOD CLEAR_DATE=offset_date;
keep contract_no CURRENT_PERIOD RECEIPT offset_month OVERDUE_DAYS CLEAR_DATE;
attrib _all_ label="";
run;

/*������������bill_fee_dtl��,������С����Ǩ���и�λ���ظ����˴�ֱ�ӱ�����Ϣ���ֵ*/
data bill_fee_dtl;
set mtd.bill_fee_dtl;
run;
data bill_fee_jm;
set bill_fee_dtl;
if fee_name in ("����ΥԼ��","���ڷ����");
if offset_date>0;
if offset_date<=&dt.;
offset_month=put(offset_date,yymmn6.);
if kindex(contract_no,"C");
run;
proc sql;
create table bill_fee_jm_1 as 
select a.contract_no,a.CURR_PERIOD,sum(a.CURR_RECEIPT_AMT) as ��Ϣ,a.offset_month,a.offset_date,b.overdue_days from bill_fee_jm as a
left join mtd.bill_main as b on a.contract_no=b.contract_no and a.curr_period=b.curr_period 
group by a.contract_no,a.CURR_PERIOD;
quit;
proc sort data=bill_fee_jm_1;by contract_no CURR_PERIOD offset_month;run;
proc sort data=bill_fee_jm_1 out=bill_fee_jm_2 nodupkey;by contract_no CURR_PERIOD;run;
data bill_fee_jm_2;
set bill_fee_jm_2;
if offset_month>0;
run;
data bill_fee_jm_3;
set bill_fee_jm_2 bill_main_xyd_c;
run;
proc sort data=bill_fee_jm_3 nodupkey;by contract_no CURR_PERIOD descending ��Ϣ;run;
proc sort data=bill_fee_jm_3 out=bill_fee_jm_4 nodupkey;by contract_no CURR_PERIOD;run;
/*data fee_breaks_apply_main;*/
/*set account.fee_breaks_apply_main;*/
/*run;*/
/*data fee_breaks_jm;*/
/*set fee_breaks_apply_main;*/
/*if kindex(contract_no,"C");*/
/*format fee_breaks_date yymmdd10.;*/
/*fee_breaks_date=datepart(CREATED_TIME);*/
/*fee_month=put(fee_breaks_date,yymmn6.);*/
/*fee=BREAKS_SERVICE_FEE_AMT+BREAKS_OVERDUE_PENALTY_AMT;*/
/*run;*/

/*fee_breaks_apply_dtl���ڿ����ݣ��ȽϺ�ƴ�ӣ�����ϸ
fee_breaks_apply_main������,ctl_apply_derateֻ�д�������������ݣ��޲����������
��Ϣ�����в�������ƫ����Щ���Ѿ������˵����ڿ�ȴ��û�л�����Щ�Ƿ�Ϣ���в��������쳣��bill_fee_dtlû������ô�෣Ϣ�����Ǵ˱�ȴ�����ˣ�*/
data fee_breaks_apply_dtl;
set account.fee_breaks_apply_dtl;
run;
data fee_breaks_apply_dtl_;
set fee_breaks_apply_dtl;
if kindex(contract_no,"C");
if FEE_CODE^='7009';
run;
/*proc sort data=fee_breaks_apply_dtl out=fee_breaks_apply_dtl_ nodupkey;by BREAKS_APPLY_CODE;run;*/
/*proc sql;*/
/*create table fee_breaks_jm_1 as */
/*select a.contract_no,b.PERIOD,sum(a.fee) as ��Ϣ���� from fee_breaks_jm as a*/
/*left join fee_breaks_apply_dtl_ as b on a.BREAKS_APPLY_CODE=b.BREAKS_APPLY_CODE*/
/*group by a.contract_no,b.PERIOD;*/
/*quit;*/
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
contract_no=tranwrd(apply_code,"PL","C");
run;

*********************************************************************���������� start****************************************************************;
data ca_staff;
set res.ca_staff;
id1=compress(put(id,$20.));
run;
proc sort data=fee_breaks_apply_dtl out=fee_breaks_apply_dtl_1 nodupkey;by contract_no period;run;
proc sql;
create table fee_breaks_apply_dtl_1_ as 
select a.*,b.userName from fee_breaks_apply_dtl_1 as a
left join ca_staff as b on a.CREATED_USER_ID=b.id1;
quit;
data fee_breaks_apply_dtl_1;
set fee_breaks_apply_dtl_1_;
date=put(datepart(CREATED_TIME),yymmdd10.);
run;
data ctl_apply_derate;
set csdata.ctl_apply_derate;
run;
data ctl_apply_derate_1;
set ctl_apply_derate;
date=put(datepart(CREATE_TIME),yymmdd10.);
run;
*********************************
BR��ͷ�ļ������뵥�ŵ������˺ͼ���ԭ����fee_breaks_apply_dtl,
�����ֵļ������뵥�ŵ������˺�����ԭ����ctl_apply_derate,�˴����뵥�Ų���Ψһ�����ú�ͬ�ź����뵥�ź���������һ��ƴ��
�������뵥�ŵ�ҵ��������ʱ����֪��
*********************************;
proc sql;
create table fee_breaks_apply_dtl_2 as 
select a.contract_no,a.period,a.userName,a.BREAKS_REMARK,a.date,b.CREATE_NAME,b.REAMRK from fee_breaks_apply_dtl_1 as a
left join ctl_apply_derate_1 as b on a.contract_no=b.contract_id and a.BREAKS_APPLY_CODE=b.id and a.date=b.date;
quit;
data fee_breaks_apply_dtl_3;
set fee_breaks_apply_dtl_2;
if CREATE_NAME='' then CREATE_NAME=userName;
if REAMRK='' then REAMRK=BREAKS_REMARK;
run;
*********************************************************************���������� end****************************************************************;

proc sql;
create table fee_breaks_jm_1 as 
select contract_no,PERIOD,sum(BREAKS_AMOUNT) as ��Ϣ���� from fee_breaks_apply_dtl_ group by contract_no,PERIOD;
quit;
proc sort data=fee_breaks_jm_1 nodupkey;by contract_no PERIOD;run;
proc sql;
create table fee_jm as 
select a.*,b.��Ϣ����,c.Ӫҵ��,c.name,d.CREATE_NAME,d.REAMRK from bill_fee_jm_4 as a
left join fee_breaks_jm_1 as b on a.contract_no=b.contract_no and a.CURR_PERIOD=b.PERIOD
left join apply_info as c on a.contract_no=c.contract_no
left join fee_breaks_apply_dtl_3 as d on a.contract_no=d.contract_no and a.curr_period=d.period;
quit;
data fee_jm_1;
set fee_jm;
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
ʵ�շ�Ϣ=��Ϣ-��Ϣ����;
if overdue_days>15 then overdue='(15,+)';else overdue='[1,15]';
if ʵ�շ�Ϣ<1 then do; ʵ�շ�Ϣ=0;��Ϣ����=��Ϣ;end;
if offset_month>0;
if offset_month=&month.;
������=��Ϣ����/��Ϣ;
run;
proc sort data=fee_jm_1 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_1;by descending offset_date;run;

proc sql;
create table fee_jm_1_1 as
select contract_no,sum(��Ϣ����) as ����ͬ������ from fee_jm_1 group by contract_no;
quit;
proc sql;
create table fee_jm_1_2 as 
select a.*,b.����ͬ������ from fee_jm_1 as a
left join fee_jm_1_1 as b on a.contract_no=b.contract_no;
quit;
proc sort data=fee_jm_1_2 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_1_2;by descending ����ͬ������;run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]��ϸ!r2c1:r30000c12';
data _null_;set fee_jm_1_2;file DD;put contract_no name CURR_PERIOD Ӫҵ�� ��Ϣ ��Ϣ���� ʵ�շ�Ϣ ������ overdue_days offset_date CREATE_NAME REAMRK;run;
/*proc sql;*/
/*create table fee_jm_2 as*/
/*select offset_month,sum(��Ϣ) as ��Ϣ,sum(��Ϣ����) as ��Ϣ����,sum(ʵ�շ�Ϣ) as ʵ�շ�Ϣ from fee_jm_1 group by offset_month;*/
/*quit;*/
******************************************************* 1-15����ϸ��Ӫҵ������ *************************************************************************************;
data fee_jm_15;
set fee_jm_1;
if overdue='[1,15]';
run;
proc sql;
create table fee_jm_15_1 as
select contract_no,sum(��Ϣ����) as ����ͬ������ from fee_jm_15 group by contract_no;
quit;
proc sql;
create table fee_jm_15_2 as 
select a.*,b.����ͬ������ from fee_jm_15 as a
left join fee_jm_15_1 as b on a.contract_no=b.contract_no;
quit;
proc sort data=fee_jm_15_2 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_15_2;by descending ����ͬ������;run;
filename DD DDE 'EXCEL|[����1-15��Ӧ�շ�Ϣ���������.xlsx]��ϸ!r2c1:r30000c12';
data _null_;set fee_jm_15_2;file DD;put contract_no name CURR_PERIOD Ӫҵ�� ��Ϣ ��Ϣ���� ʵ�շ�Ϣ ������ overdue_days offset_date CREATE_NAME REAMRK;run;
proc sql;
create table fee_jm_15_3 as
select Ӫҵ��,sum(��Ϣ) as ��Ϣ,sum(��Ϣ����) as ��Ϣ����,sum(ʵ�շ�Ϣ) as ʵ�շ�Ϣ from fee_jm_15 group by Ӫҵ��;
quit;
proc sort data=fee_jm_15_3;by descending ��Ϣ����;run;
filename DD DDE 'EXCEL|[����1-15��Ӧ�շ�Ϣ���������.xlsx]����!r4c1:r40c4';
data _null_;set fee_jm_15_3;file DD;put Ӫҵ�� ��Ϣ ��Ϣ���� ʵ�շ�Ϣ;run;
******************************************************* 16��������ϸ��Ӫҵ������ *************************************************************************************;
data fee_jm_16;
set fee_jm_1;
if overdue='(15,+)';
run;
proc sql;
create table fee_jm_16_1 as
select contract_no,sum(��Ϣ����) as ����ͬ������ from fee_jm_16 group by contract_no;
quit;
proc sql;
create table fee_jm_16_2 as 
select a.*,b.����ͬ������ from fee_jm_16 as a
left join fee_jm_16_1 as b on a.contract_no=b.contract_no;
quit;
proc sort data=fee_jm_16_2 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_16_2;by descending ����ͬ������;run;
filename DD DDE 'EXCEL|[����16������Ӧ�շ�Ϣ���������.xlsx]��ϸ!r2c1:r30000c12';
data _null_;set fee_jm_16_2;file DD;put contract_no name CURR_PERIOD Ӫҵ�� ��Ϣ ��Ϣ���� ʵ�շ�Ϣ ������ overdue_days offset_date CREATE_NAME REAMRK;run;
proc sql;
create table fee_jm_16_3 as
select Ӫҵ��,sum(��Ϣ) as ��Ϣ,sum(��Ϣ����) as ��Ϣ����,sum(ʵ�շ�Ϣ) as ʵ�շ�Ϣ from fee_jm_16 group by Ӫҵ��;
quit;
proc sort data=fee_jm_16_3;by descending ��Ϣ����;run;
filename DD DDE 'EXCEL|[����16������Ӧ�շ�Ϣ���������.xlsx]����!r4c1:r40c4';
data _null_;set fee_jm_16_3;file DD;put Ӫҵ�� ��Ϣ ��Ϣ���� ʵ�շ�Ϣ;run;
******************************************************* Ӫҵ������ **************************************************************************************************;
proc sql;
create table fee_jm_1_3 as
select Ӫҵ��,sum(��Ϣ) as ��Ϣ,sum(��Ϣ����) as ��Ϣ����,sum(ʵ�շ�Ϣ) as ʵ�շ�Ϣ from fee_jm_1 group by Ӫҵ��;
quit;
proc sql;
create table fee_jm_1_4 as 
select a.*,b.��Ϣ as ��Ϣ2,b.��Ϣ���� as ��Ϣ����2,b.ʵ�շ�Ϣ as ʵ�շ�Ϣ2,c.��Ϣ as ��Ϣ3,c.��Ϣ���� as ��Ϣ����3,c.ʵ�շ�Ϣ as ʵ�շ�Ϣ3 from fee_jm_1_3 as a
left join fee_jm_15_3 as b on a.Ӫҵ��=b.Ӫҵ��
left join fee_jm_16_3 as c on a.Ӫҵ��=c.Ӫҵ��;
quit;
proc sort data=fee_jm_1_4;by descending ��Ϣ����;run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]����!r4c1:r40c4';
data _null_;set fee_jm_1_4;file DD;put Ӫҵ�� ��Ϣ ��Ϣ���� ʵ�շ�Ϣ;run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]����!r4c6:r40c8';
data _null_;set fee_jm_1_4;file DD;put ��Ϣ2 ��Ϣ����2 ʵ�շ�Ϣ2;run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]����!r4c10:r40c12';
data _null_;set fee_jm_1_4;file DD;put ��Ϣ3 ��Ϣ����3 ʵ�շ�Ϣ3;run;
