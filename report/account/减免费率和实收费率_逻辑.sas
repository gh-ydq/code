/*option compress = yes validvarname = any;*/
/*libname csdata 'E:\guan\ԭ����\csdata';*/
/*libname approval 'E:\guan\ԭ����\approval';*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname cred "E:\guan\ԭ����\cred";*/
/*libname mics "E:\guan\�м��\repayfin";*/
/*libname res "E:\guan\ԭ����\res";*/
/*libname yc 'E:\guan\�м��\yc';*/
/*libname repayfin "E:\guan\�м��\repayfin";*/
/*libname acco odbc datasrc=account_nf;*/
/*libname coll odbc datasrc=csdata_nf;*/
/**/
/*x  "E:\guan\���ձ���\���ڻ���\����1-15��Ӧ�շ�Ϣ���������.xlsx"; */
/*x  "E:\guan\���ձ���\���ڻ���\����16������Ӧ�շ�Ϣ���������.xlsx"; */
/*x  "E:\guan\���ձ���\���ڻ���\����Ӧ�շ�Ϣ���������.xlsx"; */

%let month="201911";*�޸�Ϊ�����·�;

data null;
format dt yymmdd10.;
dt=today()-1;
call symput("dt", dt);
run;
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

data bill_hm;
set account.bill_main;
if mdy(12,1,2018)<=clear_date<=&dt.;
if not kindex(BILL_CODE,'EBL');
if kindex(contract_no,"C");
month=put(clear_date, yymmn6.);
/*if OVERDUE_DAYS>0;*/
keep contract_no repay_date clear_date CURR_PERIOD OVERDUE_DAYS CURR_RECEIPT_AMT month;
run;
data repay_plan;
set account.repay_plan;
qigong=sum(CURR_RECEIVE_INTEREST_AMT,CURR_RECEIVE_SERVICE_FEE_AMT,CURR_RECEIVE_CAPITAL_AMT,PARTNER_SERVICE_FEE_AMT,MANAGEMENT_SERVICE_FEE_AMT);
run;
proc sort data=repay_plan;by qigong;run;
/*data aa1;*/
/*set repay_plan;*/
/*if qigong<1000;*/
/*run;*/
data fee_breaks_apply_dtl;
set acco.fee_breaks_apply_dtl;
if kindex(contract_no,"C");
if FEE_CODE^='7009';
run;
proc sql;
create table fee_b2 as 
select contract_no,PERIOD,sum(BREAKS_AMOUNT) as BREAKS_AMOUNT from fee_breaks_apply_dtl group by contract_no,PERIOD;
quit;

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
set coll.ctl_apply_derate;
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
data payment_daily;
set repayfin.payment_daily;
if Ӫҵ��^="APP";
run;
proc sql;
create table bill_hm2 as 
select a.*,b.qigong,c.BREAKS_AMOUNT as amount,d.CREATE_NAME,d.REAMRK,f.Ӫҵ��,f.�ͻ����� as name,f.es
from bill_hm as a
left join repay_plan as b on a.contract_no=b.contract_no and a.CURR_PERIOD=b.CURR_PERIOD
left join fee_b2 as c on a.contract_no=c.contract_no and a.CURR_PERIOD=c.PERIOD
left join fee_breaks_apply_dtl_3 as d on a.contract_no=d.contract_no and a.CURR_PERIOD=d.PERIOD

left join payment_daily as f on a.contract_no=f.contract_no and cut_date=&dt.;
quit;
data bill_hm3;
set bill_hm2;
Ӧ�շ�Ϣ=sum(CURR_RECEIPT_AMT,-qigong);
if es=1 then Ӧ�շ�Ϣ=amount;
if contract_no='C2017072016580644447297' then Ӧ�շ�Ϣ=amount;*��ǰ������Ἧ���ڻ���ڣ�����Ӧ�շ�Ϣ����̫��;
if contract_no='C2018051415033324144130' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2017042115553351588604' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2016092617500740464740' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2017091514090396143858' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2017102711541825148769' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2017103117570387927819' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2018031917184999132507' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2016092211595980471090' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2016090611544346609938' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if contract_no='C2018032313294342732282' then delete;*�������ڿͻ���ֱ����ĳ�ڽ���;
if Ӧ�շ�Ϣ>1;
ʵ�շ�Ϣ=sum(Ӧ�շ�Ϣ,-amount);
if ʵ�շ�Ϣ<0.01 then ʵ�շ�Ϣ=0;
������=amount/��Ϣ;
if month=&month.;
if OVERDUE_DAYS<=15 then �׶�='[1,15]';else �׶�='[16,+)';
REAMRK=tranwrd(REAMRK,'0a'x,'');
REAMRK=compress(REAMRK);
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
run;
data aa;
set bill_hm3;
if contract_no='C2017102313235936064960';
run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]��ϸ!r2c1:r30000c12';
data _null_;set bill_hm3;file DD;put contract_no name CURR_PERIOD Ӫҵ�� Ӧ�շ�Ϣ amount ʵ�շ�Ϣ ������ �׶� clear_date CREATE_NAME REAMRK;run;
data bill_hm3_1;
set bill_hm3;
if �׶�='[1,15]';
run;
filename DD DDE 'EXCEL|[����1-15��Ӧ�շ�Ϣ���������.xlsx]��ϸ!r2c1:r30000c12';
data _null_;set bill_hm3_1;file DD;put contract_no name CURR_PERIOD Ӫҵ�� Ӧ�շ�Ϣ amount ʵ�շ�Ϣ ������ �׶� clear_date CREATE_NAME REAMRK;run;
data bill_hm3_2;
set bill_hm3;
if �׶�='[16,+)';
run;
filename DD DDE 'EXCEL|[����16������Ӧ�շ�Ϣ���������.xlsx]��ϸ!r2c1:r30000c12';
data _null_;set bill_hm3_2;file DD;put contract_no name CURR_PERIOD Ӫҵ�� Ӧ�շ�Ϣ amount ʵ�շ�Ϣ ������ �׶� clear_date CREATE_NAME REAMRK;run;

proc sql;
create table bill_hm4 as 
select Ӫҵ��,�׶�,sum(Ӧ�շ�Ϣ) as Ӧ�շ�Ϣ,sum(ʵ�շ�Ϣ) as ʵ�շ�Ϣ,sum(amount) as ���ⷣϢ from bill_hm3 group by Ӫҵ��,�׶�;
quit;
data bill_hm5_1;
set bill_hm4;
if �׶�='[1,15]';
run;
proc sort data=bill_hm5_1;by descending Ӧ�շ�Ϣ;run;
filename DD DDE 'EXCEL|[����1-15��Ӧ�շ�Ϣ���������.xlsx]����!r4c1:r50c4';
data _null_;set bill_hm5_1;file DD;put Ӫҵ�� Ӧ�շ�Ϣ ���ⷣϢ ʵ�շ�Ϣ;run;
data bill_hm5_2;
set bill_hm4;
if �׶�='[16,+)';
run;
proc sort data=bill_hm5_2;by descending Ӧ�շ�Ϣ;run;
filename DD DDE 'EXCEL|[����16������Ӧ�շ�Ϣ���������.xlsx]����!r4c1:r50c4';
data _null_;set bill_hm5_2;file DD;put Ӫҵ�� Ӧ�շ�Ϣ ���ⷣϢ ʵ�շ�Ϣ;run;
proc sql;
create table bill_hm5_0 as 
select Ӫҵ��,sum(Ӧ�շ�Ϣ) as Ӧ�շ�Ϣ,sum(ʵ�շ�Ϣ) as ʵ�շ�Ϣ,sum(amount) as ���ⷣϢ from bill_hm3 group by Ӫҵ��;
quit;
proc sql;
create table bill_hm5 as 
select a.*,b.Ӧ�շ�Ϣ as Ӧ�շ�Ϣ_A1,b.ʵ�շ�Ϣ as ʵ�շ�Ϣ_A1,b.���ⷣϢ as ���ⷣϢ_A1,c.Ӧ�շ�Ϣ as Ӧ�շ�Ϣ_A2,c.ʵ�շ�Ϣ as ʵ�շ�Ϣ_A2,c.���ⷣϢ as ���ⷣϢ_A2 from bill_hm5_0 as a
left join bill_hm5_1 as b on a.Ӫҵ��=b.Ӫҵ��
left join bill_hm5_2 as c on a.Ӫҵ��=c.Ӫҵ��;
quit;
proc sort data=bill_hm5;by descending Ӧ�շ�Ϣ;run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]����!r4c1:r50c4';
data _null_;set bill_hm5;file DD;put Ӫҵ�� Ӧ�շ�Ϣ ���ⷣϢ ʵ�շ�Ϣ;run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]����!r4c6:r50c8';
data _null_;set bill_hm5;file DD;put Ӧ�շ�Ϣ_A1 ���ⷣϢ_A1 ʵ�շ�Ϣ_A1;run;
filename DD DDE 'EXCEL|[����Ӧ�շ�Ϣ���������.xlsx]����!r4c10:r50c12';
data _null_;set bill_hm5;file DD;put Ӧ�շ�Ϣ_A2 ���ⷣϢ_A2 ʵ�շ�Ϣ_A2;run;
