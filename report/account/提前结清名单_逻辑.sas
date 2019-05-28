/*libname approval 'E:\guan\ԭ����\approval';*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname csdata 'E:\guan\ԭ����\csdata';*/
/*libname res  'E:\guan\ԭ����\res';*/
/*libname yc 'E:\guan\�м��\yc';*/
/*libname repayfin 'E:\guan\�м��\repayfin';*/
/*option compress = yes validvarname = any;*/
/**/
/*proc import datafile="E:\guan\���ձ���\��ǰ��������\�����޳�ԭ����.xlsx"*/
/*out=policy dbms=excel replace;*/
/*SHEET="�ſ�ͻ�";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\���ձ���\��ǰ��������\��ǰ��������.xlsx"*/
/*out=pre_list dbms=excel replace;*/
/*SHEET="��ʷ��������";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*x "E:\guan\���ձ���\��ǰ��������\��ǰ��������.xlsx";*/

data null;
format dt yymmdd10.;
dt=today()-1;
call symput("dt", dt);
run;
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


data payment_p;
set repayfin.payment_daily;
run;
data payment_p2;
set payment_p;
if cut_date=&dt.;
if Ӫҵ��^='APP';
apply_code = tranwrd(contract_no , "C","PL");
run;
proc sort data=payment_p2 nodupkey;by contract_no;run;
proc sql;
create table payment_p3 as 
select a.*,c.��6���¸��˲�ѯ�޳�,c.�ڲ����������޳�,c.Ӫҵ�����������޳�,c.�����������޳�,d.MODEL_SCORE as score,d.MODEL_SCORE_LEVEL as �ֵ� from payment_p2 as a
left join policy as c on a.apply_code=c.apply_code
left join repayfin.strategy as d  on a.apply_code=d.apply_code;
quit;
data payment_p4;
set payment_p3;
/*if score>0;*/
if ��6���¸��˲�ѯ�޳�=1 or �ڲ����������޳�=1 or Ӫҵ�����������޳�=1 or �����������޳�=1 then policy_out=1;else policy_out=0;
if �ֵ�="F" then level_out=1;else level_out=0;
if level_out=1 or policy_out=1 then level_policy_out=1;else level_policy_out=0;
run;
data payment_p4_;
set payment_p4;
keep apply_code �ͻ����� policy_out level_out �ֵ� level_policy_out Ӫҵ�� ������� �������_ʣ�౾�𲿷� od_days ;
run;
data payment_p4;
set payment_p4_;
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
array char _character_;
Do Over char;
If char=" " Then char='0';
End;
run;
data payment_p12;
set payment_p4_;
if od_days>0;
run;

************************** curr_period start *************************************;
data aa;
set repayfin.payment_daily(where=(cut_date=&dt. and Ӫҵ��^='APP'));
apply_code = tranwrd(contract_no , "C","PL");
run;
/*��ǰ����*/
data aa2;
set account.bill_main;
if repay_date<=&dt.;
run;
proc sql;
create table aa2_ as
select contract_no,
count(contract_no) as ��ǰ����
from aa2
group by contract_no;
quit;
data aa4;
set repayfin.Tttrepay_plan_js;
if repay_date_js<=&dt.;
run;
proc sql;
create table aa4_ as
select contract_no,
count(contract_no) as ��ǰ����
from aa4
group by contract_no;
quit;
data aa5;
set aa2_ aa4_;
apply_code = tranwrd(contract_no , "C","PL");
run;
proc sql;
create table aa1 as
select a.*,c.��ǰ����
from aa as a
left join aa5 as c on a.apply_code=c.apply_code;
quit;
data lists;
set aa1;
COMPLETE_PERIOD = ��ǰ���� - od_periods;
curr_period=COMPLETE_PERIOD+1;
δ������=��ǰ����+1;
���֤����=substr(���֤����,1,6) || "****" || substr(���֤����,length(���֤����)-3,4);
keep contract_no apply_code ��ǰ���� COMPLETE_PERIOD curr_period od_days �ͻ����� ���֤���� Ӫҵ�� CONTRACT_AMOUNT REPAY_DATE δ������;
run;
************************** curr_period end *************************************;

data servicefee;
set approval.loan_info(keep = contract_no loan_amount service_amount documentation_fee  total_deposit where=(loan_amount>0));
rename loan_amount=��ͬ���
       service_amount=�����
       documentation_fee=��֤��
       total_deposit=��֤��;
run;
proc sql;
create table repay_plan as 
select a.*,b.PSNORMINTAMT from account.repay_plan as a
left join repayfin.Tttrepay_plan_js as b on a.contract_no=b.contract_no and a.curr_period=b.PSPERDNO;
quit;
proc sort data=repay_plan nodupkey;by contract_no curr_period;run;
data repay_plan_;
set repay_plan;
if CURR_RECEIVE_INTEREST_AMT in (0,.) then CURR_RECEIVE_INTEREST_AMT=PSNORMINTAMT;
run;

proc sql;
create table list_curr_period as
select a.contract_no,c.beginning_capital as �������, c.CURR_RECEIVE_CAPITAL_AMT as ���ڱ���, c.CURR_RECEIVE_INTEREST_AMT as ������Ϣ,c.EARLY_REPAY_SERVICE_FEE_AMT,
	g.EARLY_REPAY_SERVICE_FEE_AMT as EARLY_label ,a.REPAY_DATE, c.RETURN_SERVICE_FEE as �˻������_��ΥԼ��,d.��֤��,f.fund_channel_code
from lists as b
left join repay_plan_ as a on b.contract_no = a.contract_no and b.curr_period = a.curr_period
left join repay_plan_ as c on c.contract_no = b.contract_no and c.curr_period = b.δ������
left join repay_plan_(where=(curr_period = 1)) as g on g.contract_no = b.contract_no
left join servicefee as d on a.contract_no=d.contract_no 
left join approval.contract as f on a.contract_no=f.contract_no;
quit;
proc sql;
create table list_unbilled_interest as
select a.contract_no, sum(a.CURR_RECEIVE_INTEREST_AMT) as δ���˵���Ϣ��
from lists as b
left join repay_plan_ as a on b.contract_no = a.contract_no and b.δ������ <= a.curr_period
group by a.contract_no;
quit;

proc sort data = lists nodupkey; by contract_no; run;
proc sort data = list_curr_period nodupkey; by contract_no; run;
proc sort data = list_unbilled_interest nodupkey; by contract_no; run;
data list_2;
merge lists(in = a) list_curr_period(in = b) list_unbilled_interest(in = c);
by contract_no;
if a;
�ڹ� = ���ڱ��� + ������Ϣ;
if curr_period > 3 then ��ǰ����ΥԼ�� = min(�������*0.03, δ���˵���Ϣ��); else ��ǰ����ΥԼ�� = min(�������*0.05, δ���˵���Ϣ��);
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
array char _character_;
Do Over char;
If char=" " Then char='0';
End;
run;
data list_3;
set list_2;
run;
proc sql;
create table list_4 as 
select a.*,b.��ǰ����ΥԼ��,b.��֤��,b.�˻������_��ΥԼ��,b.contract_no,b.�������,b.���ڱ���,b.������Ϣ,b.�ڹ�,b.fund_channel_code,b.EARLY_REPAY_SERVICE_FEE_AMT,b.EARLY_label
from payment_p12 as a
left join list_3 as b on a.apply_code=b.apply_code;
quit;
data list_5;
set list_4;
Ӷ��3=��ǰ����ΥԼ��*2;
Ӷ��2=��ǰ����ΥԼ��*1.5;
Ӷ��1=��ǰ����ΥԼ��*1;
ϵͳ������="�Ե���ϵͳ������Ϊ׼";
if EARLY_label>1 then do;
	���н�����=�������+������Ϣ+�ڹ�+EARLY_REPAY_SERVICE_FEE_AMT;
	��ͽ�����=�������+������Ϣ+�ڹ�+EARLY_REPAY_SERVICE_FEE_AMT-Ӷ��1;
end;
else if ��֤��>0 and EARLY_label<1 then do;
	���н�����=�������+������Ϣ+�ڹ�-�˻������_��ΥԼ��+Ӷ��1;
	��ͽ�����=�������+������Ϣ+�ڹ�-�˻������_��ΥԼ��;
end;
else if fund_channel_code='jsxj1' then do;
	���н�����=�������+������Ϣ+�ڹ�-�˻������_��ΥԼ��-������Ϣ;
	��ͽ�����=�������+������Ϣ+�ڹ�-�˻������_��ΥԼ��-Ӷ��1-������Ϣ;
end;
else do;
	���н�����=�������+������Ϣ+�ڹ�-�˻������_��ΥԼ��;
	��ͽ�����=�������+������Ϣ+�ڹ�-�˻������_��ΥԼ��-Ӷ��1;
end;
run;
proc sort data=list_5 ;by od_days;run;
proc sql;
create table list_5_ as 
select contract_no as ��ͬ��,�ͻ�����,Ӫҵ��,od_days as ��������,level_policy_out as �������ֿ��޳�,��֤��,�˻������_��ΥԼ�� as �˻������,Ӷ��3,���н�����,Ӷ��2,��ͽ�����,Ӷ��1
from list_5;
quit;
data list_6;
set list_5;
if weekday(&dt.)=1 then do;
if od_days=3 or od_days=4 or od_days=5;
end;
else do;
if od_days=3;
end;
if level_policy_out=1;
if Ӷ��3>=400;
run;
proc sql;
create table list_7 as 
select contract_no,�ͻ�����,Ӫҵ��,ϵͳ������,Ӷ��3,���н�����,Ӷ��2,��ͽ�����,Ӷ��1
from list_6;
quit;
filename DD DDE "EXCEL|[��ǰ��������.xlsx]��ǰ��������!r2c1:r100c9";
data _null_;set list_7;file DD;put contract_no �ͻ����� Ӫҵ�� ϵͳ������ Ӷ��3 ���н�����  Ӷ��2 ��ͽ����� Ӷ��1;run;
data list_8;
set list_6;
format ���� yymmdd10.;
����=today();
keep ���� contract_no �ͻ����� Ӫҵ�� ϵͳ������ Ӷ��3 ���н����� Ӷ��2 ��ͽ����� Ӷ��1;
rename contract_no=��ͬ��;
run;
data list_9;
set pre_list list_8;
run;
proc sort data=list_9;by ��ͬ�� descending ����;run;
proc sort data=list_9 nodupkey;by ��ͬ��;run;
proc sort data=list_9;by descending ����;run;
filename DD DDE "EXCEL|[��ǰ��������.xlsx]��ʷ��������!r2c1:r10000c10";
data _null_;set list_9;file DD;put ���� ��ͬ�� �ͻ����� Ӫҵ�� ϵͳ������ Ӷ��3 ���н�����  Ӷ��2 ��ͽ����� Ӷ��1;run;

data pre_list_;
set pre_list;
apply_code = tranwrd(��ͬ�� , "C","PL");
run;
data payment_p;
set repayfin.payment_daily;
run;
data payment_p2;
set payment_p;
if cut_date=&dt.;
if Ӫҵ��^='APP';
apply_code = tranwrd(contract_no , "C","PL");
run;
proc sort data=payment_p2 nodupkey;by contract_no;run;
proc sql;
create table pre_list_1 as 
select a.�ͻ�����,a.apply_code,a.Ӫҵ��,a.����,a.��ͬ��,b.od_days,b.es,b.od_days_ever,c.ACCOUNT_STATUS from pre_list_ as a
left join payment_p2 as b on a.apply_code=b.apply_code
left join account.account_info as c on c.contract_no=b.contract_no;
quit; 
proc sort data=pre_list_1;by descending ����;run;
proc sort data=pre_list_1 nodupkey;by  apply_code;run;
data pre_list_2;
set pre_list_1;
if account_status='0003';
contract_no=tranwrd(��ͬ�� , "PL","C");
run;
data bill_main_es;
set account.bill_main;
if kindex(BILL_CODE,"EBL");
run;
proc sort data=bill_main_es;by contract_no descending clear_date;run;
proc sort data=bill_main_es nodupkey;by contract_no;run;

proc sql;
create table pre_list_3 as 
select a.*,b.CURR_PERIOD,b.CURR_RECEIPT_AMT,b.clear_date from pre_list_2 as a
left join bill_main_es as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table pre_list_4 as 
select a.*,b.CURR_PERIOD as CURR_PERIOD_es,b.CURR_RECEIPT_AMT as CURR_RECEIPT_AMT_es,b.Ӫҵ��,b.�ͻ����� from account.repay_plan as a
left join pre_list_3 as b on a.contract_no=b.contract_no;
quit;
data pre_list_4_;
set pre_list_4;
if CURR_PERIOD_es>0;
run;
proc sql;
create table pre_list_5 as
select a.contract_no,sum(a.CURR_RECEIVE_INTEREST_AMT) as δ���˵���Ϣ��
from pre_list_4_ as a where a.curr_period>CURR_PERIOD_es
group by a.contract_no;
quit;
proc sql;
create table pre_list_5_2 as
select contract_no,beginning_capital as �������,CURR_PERIOD_es
from pre_list_4_ where curr_period=CURR_PERIOD_es;
quit;
proc sql;
create table pre_list_6 as 
select a.*,b.�������,b.CURR_PERIOD_es from pre_list_5 as a
left join pre_list_5_2 as b on a.contract_no=b.contract_no;
quit;
data pre_list_7;
set pre_list_6;
if CURR_PERIOD_es > 3 then ��ǰ����ΥԼ�� = min(�������*0.03, δ���˵���Ϣ��); else ��ǰ����ΥԼ�� = min(�������*0.05, δ���˵���Ϣ��);
run;
proc sql;
create table pre_list_8 as 
select a.*,b.Ӫҵ��,b.�ͻ�����,b.CURR_RECEIPT_AMT,b.clear_date from pre_list_7 as a
left join pre_list_3 as b on a.contract_no=b.contract_no;
quit;
data pre_list_8;
set pre_list_8;
Ӷ��=��ǰ����ΥԼ��*1.5;
if contract_no in ('C2017091214165415037622','C2017092116242511247031','C2017071215142043171242','C2017033017190011763012','C2018051711594971854092','C2017112218403870825073','C2018011917511864766167',
	'C2017071317492121677636','C2017041016022323795289','C2017101218330205233310','C2017092910075570251562','C152351871429902300009203','C152628149701302300001164','C2017103118460228898745',
	'C2017081619220936692714','C2017030812555383107555','C2017060513101838574944','C2018011716551953741377','C2017112220060363321605','C2017061416562876370328','C2017062817224777633427'
	'C2017091215271102540946','C2018011816081556790184','C2017032216161794243972','C2017111409162842184843','C151997132161203000003121','C2018060813274523353942','C2018010813234622604169',
	'C2017090415015812717808','C2017082214111518506440','C2017060214524739873688','C2017032012260104557106','C2017081115015764624142','C2017120515554920777022','C2018031616505224241160',
	'C2017102314043465787656','C2017042615383569763712','C152687653472702300001243','C2017072617364924076951','C2017072417584449009225','C2017041314481257712194','C2017080910454542145365',
	'C2017102417512945120834','C2017051216070171982298','C2017091515454347308731','C152698030555803000000216','C2017063011143891137961','C2017072517421313005856','C2017092211295208349340',
	'C2017092218030277297782','C2017071011182562875373') then delete;
if contract_no='C2018050810452702044342' then CURR_RECEIPT_AMT=17995.92;
if contract_no='C2018051711594971854092' then do;CURR_RECEIPT_AMT=47612;Ӷ��=1276.2864;end;
if contract_no='C2017033116445931791007' then do;CURR_RECEIPT_AMT=22288.69;Ӷ��=653.9088;end;
if contract_no='C2017112416441748704059' then do;CURR_RECEIPT_AMT=76345.9;Ӷ��=3531.61;end;
if contract_no='C2016060215530799443602' then do;CURR_RECEIPT_AMT=9588.56;Ӷ��=558.5454;end;
if contract_no='C2017070615201064320527' then do;CURR_RECEIPT_AMT=12480.6;Ӷ��=647.4096;end;
if contract_no='C152463981193603000000638' then do;CURR_RECEIPT_AMT=36770.44;Ӷ��=1522.59;end;
if contract_no='C2017091316163328413127' then do;CURR_RECEIPT_AMT=21359.73;Ӷ��=1083.1671;end;
if contract_no='C2017090515274353580507' then do;CURR_RECEIPT_AMT=15674.99;Ӷ��=847.51335;end;
if contract_no='C2018010212460084876364' then do;CURR_RECEIPT_AMT=27255.88;Ӷ��=1262.93;end;
run;
proc sort data=pre_list_8;by descending clear_date;run;
/*filename DD DDE "EXCEL|[��ǰ��������.xlsx]�ѽ�����ϸ!r2c1:r100c5";*/
/*data _null_;set pre_list_8;file DD;put contract_no �ͻ����� Ӫҵ�� CURR_RECEIPT_AMT Ӷ�� clear_date;run;*/
