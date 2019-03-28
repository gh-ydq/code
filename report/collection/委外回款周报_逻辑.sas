************************

************************;
data _null_;
format dt yymmdd10.;
 dt = today() - 1;
 if month(dt)=month(dt-2) then 
 db=intnx("month",dt,0,"b");
 else if weekday(dt)=1 then
db=intnx("month",dt-2,0,"b");
else db=intnx("month",dt,0,"b");
/*dt=mdy(9,30,2017);*/
/*db=mdy(9,1,2017);*/
 nd = dt-db;
weekf=intnx('week',dt,0);
call symput("nd", nd);
call symput("db",db);
call symput("dt",dt);
call symput("weekf",weekf);
month='201901';
call symput("month",month);
run;

***************************�õ������ϸ����******************************************
ֻҪ��ί���ˣ�֮������������ͻ�������������Ҳ������ί���ҵ��
*********************************;
data ctl_outsource_contract;
set csdata.ctl_outsource_contract;
run;
data ctl_outsource_pack;
set csdata.ctl_outsource_pack;
run;
data ctl_outsourcers;
set csdata.ctl_outsourcers;
run;
proc sql;
create table kan1 as
select a.ID,a.CONTRACT_NO,a.CREATE_TIME,a.OUTSOURCE_OVERDUEDAYS,a.OUTSOURCE_SUM_TOTAL,b.STATUS,b.OUTSOURCE_TYPE,
b.OUTSOURCE_DATE,b.OUTSOURCE_END_DATE,b.OUTSOURCE_COMPANY_NAME,c.REMARK 
from ctl_outsource_contract as a
left join ctl_outsource_pack as b on a.OUTSOURCE_PACK_ID=b.id
left join ctl_outsourcers as c on b.COMMISSION_RATIO=c.COMMISSION_RATIO and b.OUTSOURCE_COMPANY_CODE=c.OUTSOURCERS_CODE;
quit;
data kan1a;
set kan1;
if kindex(contract_no,"C") ;
format �����ʼ���� ����������� yymmdd10.;
/*�����ʼ����=datepart(OUTSOURCE_DATE);*/
�����ʼ����=datepart(CREATE_TIME);
�����ʼ�·�=put(�����ʼ����,yymmn6.);
�����������=datepart(OUTSOURCE_END_DATE);
��������·�=put(�����������,yymmn6.);
drop OUTSOURCE_DATE OUTSOURCE_END_DATE;
run;
proc sort data=kan1a;by contract_no descending �����������;run;
data kan1a_;
set kan1a;
/*if id in ('18050400575128','18050200473056') then �����������=&dt.;*/
if (�����ʼ�·�=&month. or &month.=��������·� or �����ʼ����<=&dt.<=�����������);
if OUTSOURCE_COMPANY_NAME='����������Զ��Ϣ�������޹�˾' then OUTSOURCE_COMPANY_NAME='���£�����������Զ��Ϣ�������޹�˾';
run;
proc sort data=kan1a_;by contract_no descending �����������;run;
proc sort data=kan1a_ nodupkey;by contract_no ;run;

***************************�õ��³�����******************************************;
data payment_w;
set yc.payment;
run;
proc sort data=payment_w;by contract_no descending cut_date;run;
proc sort data=payment_w nodupkey;by contract_no;run;
***************************�õ������������**************************************
ֻ�к�DR��ZW�ĲŻ��������ϵͳ���棬ZW��ʾ���ۣ�DR��ʾ�Թ�
********************************************************;
data offset_info;
set account.offset_info;
run;
data offset_info_;
set offset_info;
if &db.<=OFFSET_DATE<=&dt.;
if kindex(OFFSET_SOURCE_NO,"ZW") then ����=1;else ����=0;
if kindex(OFFSET_SOURCE_NO,"CR") or kindex(OFFSET_SOURCE_NO,"ZW");
run;
proc sql;
create table offset_info_1 as 
select contract_no,sum(OFFSET_AMOUNT) as �Թ����,OFFSET_DATE as �Թ�����,max(����) as ���� from offset_info_ group by contract_no;
quit;
proc sort data=offset_info_1;by contract_no descending �Թ�����;run;
proc sort data=offset_info_1 nodupkey;by contract_no ;run;


proc sql;
create table outpayment_ as 
select a.*,b.clear_date,b.od_days,b.�������_ʣ�౾�𲿷� as REMAIN_CAPITAL,b.�ͻ�����,b.���֤����,c.REMAIN_CAPITAL as REMAIN_CAPITAL_yc,c.Ӫҵ��,d.�Թ����,d.�Թ�����,d.����
from kan1a_ as a
left join repayfin.payment_daily(where=(cut_date=&dt.)) as b
on a.contract_no=b.contract_no
left join payment_w as c
on a.contract_no=c.contract_no
left join offset_info_1 as d 
on a.contract_no=d.contract_no;
quit;
**************************************
������ZW��ͷ���Թ���DR��ͷ
��ʣ�౾��Ϊ0ʱ�������Ϊ0����ʱ����Ϊ����
*************************************;
data outpayment;
set outpayment_;
if contract_no='C2018010813234622604169' then do;�Թ����=38000;end;
if clear_date>=&db. or clear_date in (.,0) then ����=1;else ����=0;
if &db.<=clear_date<=&dt. then �߻�=1;else �߻�=0;
if REMAIN_CAPITAL_yc<REMAIN_CAPITAL then REMAIN_CAPITAL_yc=REMAIN_CAPITAL;
������=REMAIN_CAPITAL_yc-REMAIN_CAPITAL;
if ������>0 then ������=�Թ����; *�Ƿ����ͨ����������ж�����������ʱ��������ϵͳ�Ļ�����Թ����;
if REMAIN_CAPITAL>10 then ������=0;
if �Թ���� in (0,.) then do; �Թ����=������;end;
if ����=1 then �Ƿ񻮿�=1;else �Ƿ񻮿�=0;
if od_days=0 and clear_date not in (0,.) then od_days=OUTSOURCE_OVERDUEDAYS+intck("DAY",�����ʼ����,clear_date);
if od_days=0 and clear_date in (0,.) then od_days=OUTSOURCE_OVERDUEDAYS+intck("DAY",�����ʼ����,&dt.);
if ����=1;
run;
**************************
���ֶԹ����ݻ�һЩ������֪�����ݻᵼ������ϵͳ��offset_info��һ�£����弼������ô����δ֪
**************************;
data outpayment;
set outpayment;
if OUTSOURCE_COMPANY_NAME='����ͻ�' then delete;
if OUTSOURCE_COMPANY_NAME='ί�⹫˾' then OUTSOURCE_COMPANY_NAME='��ɳ�����ʲ��������޹�˾';
/*if OUTSOURCE_COMPANY_NAME='���ͬ��' and contract_no in ('C2016101919122555149104','C2017101218330205233310','C2017062317133256216041') then OUTSOURCE_COMPANY_NAME='��ɳ�����ʲ��������޹�˾';*/
if OUTSOURCE_COMPANY_NAME='���ͬ��' and (kindex(Ӫҵ��,"����") or kindex(Ӫҵ��,"����") or kindex(Ӫҵ��,"տ��") or kindex(Ӫҵ��,"����") or kindex(Ӫҵ��,"��ͷ") or kindex(Ӫҵ��,"��ɽ"))  then OUTSOURCE_COMPANY_NAME='��ݸ����������������޹�˾';
	else if OUTSOURCE_COMPANY_NAME='���ͬ��' and (kindex(Ӫҵ��,"����") or kindex(Ӫҵ��,"�Ϻ�") or kindex(Ӫҵ��,"�Ͼ�") or kindex(Ӫҵ��,"����") or kindex(Ӫҵ��,"�γ�") or kindex(Ӫҵ��,"����"))  then OUTSOURCE_COMPANY_NAME='���վ��ܻ�������ѯ���޹�˾';
	else if OUTSOURCE_COMPANY_NAME='���ͬ��' then OUTSOURCE_COMPANY_NAME='��ɳ�����ʲ��������޹�˾';
/*if �����ʼ����=����������� then delete;*/
/*if contract_no='C2016102609585327161697' then �Թ����=0;*�ع�;*/
/*if contract_no='C2017080417574190842814' then �Թ����=10000; */
/*���ί���Ϊǰ��ί�����ǰ������ڲ�֪��ʲôԭ���������;*/
/*if contract_no='C2017112712485307457620' then delete;*���ί��Ĳ���;*/
/*if contract_no='C2018011816340033024249' then delete;*���ί��Ĳ���;*/
/*if contract_no='C2016120114342357026874' then do; �Թ����=1382.72;�Թ�����=mdy(6,13,2018);end;*�ع�;*/
/*if contract_no='C2017032315381526190067' then �Թ����=74300;*�ع�;*/
run;
proc sort data=outpayment nodupkey;by contract_no;run;
proc sql; 
create table w_dl as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as �ۼƶ���,sum(REMAIN_CAPITAL_yc) as ʣ�౾��,sum(������) as �ؿ���,sum(�Թ����) as �Թ����
from outpayment as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl1 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as �ۼƶ���1,sum(REMAIN_CAPITAL_yc) as ʣ�౾��1,sum(�Թ����) as �ؿ���1   
from outpayment(where=(0<=od_days<=180)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl2 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as �ۼƶ���2,sum(REMAIN_CAPITAL_yc) as ʣ�౾��2,sum(�Թ����) as �ؿ���2     
from outpayment(where=(181<=od_days<=360)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl3 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as �ۼƶ���3,sum(REMAIN_CAPITAL_yc) as ʣ�౾��3,sum(�Թ����) as �ؿ���3    
from outpayment(where=(361<=od_days<=720)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl4 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as �ۼƶ���4,sum(REMAIN_CAPITAL_yc) as ʣ�౾��4,sum(�Թ����) as �ؿ���4     
from outpayment(where=(721<=od_days)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
*lableu��Դ�ڵ�������ñ�;
proc sql;
create table w_dl_sum_ as 
select a.*,b.�ۼƶ���1,b.ʣ�౾��1,b.�ؿ���1,c.�ۼƶ���2,c.ʣ�౾��2,c.�ؿ���2,d.�ۼƶ���3,d.ʣ�౾��3,d.�ؿ���3,e.�ۼƶ���4,e.ʣ�౾��4,e.�ؿ���4,f.���
from w_dl as a
left join w_dl1 as b on a.OUTSOURCE_COMPANY_NAME=b.OUTSOURCE_COMPANY_NAME
left join w_dl2 as c on a.OUTSOURCE_COMPANY_NAME=c.OUTSOURCE_COMPANY_NAME
left join w_dl3 as d on a.OUTSOURCE_COMPANY_NAME=d.OUTSOURCE_COMPANY_NAME
left join w_dl4 as e on a.OUTSOURCE_COMPANY_NAME=e.OUTSOURCE_COMPANY_NAME
left join lableu as f on a.OUTSOURCE_COMPANY_NAME=f.OUTSOURCE_COMPANY_NAME
where a.OUTSOURCE_COMPANY_NAME in (select OUTSOURCE_COMPANY_NAME from lableu);
quit;
proc sort data=w_dl_sum_;by ���;run;
data w_dl_sum;
set w_dl_sum_;
�ؿ���=�Թ����/ʣ�౾��;
�ؿ���1=�ؿ���1/ʣ�౾��1;
�ؿ���2=�ؿ���2/ʣ�౾��2;
�ؿ���3=�ؿ���3/ʣ�౾��3;
�ؿ���4=�ؿ���4/ʣ�౾��4;
run;
Data w_dl_sum;
Set w_dl_sum;
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
array char _character_;
Do Over char;
If char=" " Then char='0';
End;
Run;

filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r4c3:r12c7";
data _null_;set w_dl_sum;file DD;put �ۼƶ��� ʣ�౾�� �ؿ��� �Թ���� �ؿ���;run;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r4c8:r12c11";
data _null_;set w_dl_sum;file DD;put �ؿ���1 �ؿ���2 �ؿ���3 �ؿ���4;run;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r4c12:r12c15";
data _null_;set w_dl_sum;file DD;put �ۼƶ���1 �ۼƶ���2 �ۼƶ���3 �ۼƶ���4 ;run;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r4c16:r12c19";
data _null_;set w_dl_sum;file DD;put ʣ�౾��1 ʣ�౾��2 ʣ�౾��3 ʣ�౾��4;run;

proc sql;
create table w_dl_hksum as 
select sum(�Թ����)/sum(ʣ�౾��) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r3c7:r3c7";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(�ؿ���1)/sum(ʣ�౾��1) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r3c8:r3c8";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(�ؿ���2)/sum(ʣ�౾��2) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r3c9:r3c9";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(�ؿ���3)/sum(ʣ�౾��3) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r3c10:r3c10";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(�ؿ���4)/sum(ʣ�౾��4) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]ί��!r3c11:r3c11";
data _null_;set w_dl_hksum;file DD;put hkl;run;

data w_detail;
set outpayment;
if �Թ����>0;
���֤=substr(���֤����,1,13) || "****";
if ������>0 then ����=1;else ����=0;
run;
filename DD DDE "EXCEL|[ί��ؿ��ձ�.xlsx]�ؿ���ϸ!r2c1:r100c10";
data _null_;set w_detail;file DD;put �����ʼ���� contract_no ���֤ �ͻ����� �Թ�����  �Թ���� ���� �Ƿ񻮿� od_days OUTSOURCE_COMPANY_NAME;run;
