
************
1-16�ŷ���Ŀͻ����Ǹ������µ����һ���ֹ��17-30�ŷ���Ŀͻ���C-M1�Ŀͻ���,��ʱ��17��֮������C-M1�Ŀͻ����¸��¾ͱ����M1-M2��
************;
data aa;
format dt yymmdd10.;

/*if weekday(today())=2 then dt=today()-3;*/
/*else if weekday(today())=1 then dt=today()-2;*/
/*else dt=today()-1;*/

dt=today()-1;
db=intnx("month",dt,0,"b");
dbpe=intnx("month",dt,0,"b")-1;
db1=intnx("month",dt,-1,"b")+16;
db2=intnx("month",dt,0,"e");
if weekday(dt)=1 then do;weekf=intnx('week',dt,-1)+1;end;
	else do; weekf=intnx('week',dt,0)+1;end;
call symput("dt", dt);
call symput("weekf",weekf);
call symput("db", db);
call symput("dbpe", dbpe);
call symput("db1", db1);
call symput("db2", db2);
run;

data payment_daily;
set repayfin.payment_daily(where=(Ӫҵ��^="APP"));
lag_od_days=lag(od_days);
by contract_no cut_date;
if first.contract_no then lag_od_days="";
run;

data mmlist;
set repayfin.test_lr_b;
if username in ("���λ�","�����","������","�δ���","������","����","���ǳ�",'���','��٩','����ɭ','�����','������');
if &dbpe.<=cut_date<=&db2.;
run;
proc sql;
create table mmlist_1_ as 
select a.*,b.od_days,b.lag_od_days,b.�ͻ�����,b.Ӫҵ��,b.�ʽ�����,b.REPAY_DATE,e.od_days as od_days_yd,e.�������,e.REPAY_DATE as REPAY_DATE_yd from mmlist as a
left join payment_daily as b on a.contract_no=b.contract_no and a.cut_date=b.cut_date
left join approval.contract as c on a.contract_no=c.contract_no
left join repayfin.payment as e on a.contract_no=e.contract_no and e.cut_date=&dbpe.;
quit;

data mmlist_1;
set mmlist_1_;
if REPAY_DATE_yd>REPAY_DATE then REPAY_DATE=REPAY_DATE_yd;
run;

data mmlist_2;
set mmlist_1;
/*if username='�ۻԻ�111' then username='�ۻԻ�';*/
/*if username='������111' then username='������';*/
/*if username='�Ż�111' then username='�Ż�';*/
/*if username='�ž�111' then username='�ž�';*/
if �ʽ����� in ("xyd1","xyd2") then �ʽ�����="С���";
	else if �ʽ����� in ("bhxt1","bhxt2") then �ʽ�����="��������";
	else if �ʽ����� in ("mindai1") then �ʽ�����="���";
	else if �ʽ����� in ("ynxt1","ynxt2","ynxt3") then �ʽ�����="��������";
	else if �ʽ����� in ("jrgc1") then �ʽ�����="���ڹ���";
	else if �ʽ����� in ("irongbei1") then �ʽ�����="�ڱ�";
	else if �ʽ����� in ("fotic3","fotic2") then �ʽ�����="��һ������";
	else if �ʽ����� in ("haxt1") then �ʽ�����="��������";
	else if �ʽ����� in ("p2p") then �ʽ�����="�пƲƸ�";
	else if �ʽ����� in ("jsxj1") then �ʽ�����="�������ѽ���";
	else if �ʽ����� in ("lanjingjr1") then �ʽ�����="��������";
	else if �ʽ����� in ("yjh1","yjh2") then �ʽ�����="��ݼ��";
	else if �ʽ����� in ("rx1") then �ʽ�����="����";
	else if �ʽ����� in ("hapx1") then �ʽ�����="��������";
	else if �ʽ����� in ("tsjr1") then �ʽ�����="ͨ�ƽ���";
if REPAY_DATE=. and od_days_yd=0 then REPAY_DATE=intnx('month',REPAY_DATE_yd,1,'s');*δƥ�䵽�������µ�δ���ڣ��ǿ϶��ǵ��¿�ʼ������;
if REPAY_DATE=. then REPAY_DATE=REPAY_DATE_yd;
if 60>=od_days>30 then �׶�="M2-M3";
	else if 30>=od_days>15 and REPAY_DATE<&db. then �׶�="M1-M2";
	else if od_days=30 and od_days_yd=15 then �׶�="M1-M2";*����30��ʱrepay_date�պ�����һ���£����½׶μ������;
	else if 30>=od_days>15 and REPAY_DATE>=&db. then �׶�="C-M1";
	else if 15>=od_days>=0 then �׶�="0-15";
	else if 90>=od_days>60 then �׶�="M3-M4";
	else �׶�="M4+";
if 60>=od_days_yd>30 then �׶�2="M2-M3";
	else if 30>=od_days_yd>1 then �׶�2="M1-M2";
/*	else if od_days_yd=0 then �׶�2="C";*/
	else �׶�2='M4+';
run;
proc sort data=mmlist_2;by contract_no cut_date;run;
data mmlist_3;
set mmlist_2;
by contract_no;

if od_days_yd+day(&dt.)<=15 then delete;*���������µ׼����ڣ����ǵ����춼��û����M1M2,�³�ʱ���׶�����ⲿ������;
if contract_no in ('C2016102516341668488964','C2017101918274169730837','C2017081716382733250955','C2017121116521619518035') then delete;*��ת��ί��;
if username not in ('���λ�','�����') and �׶�^="M1-M2" and �׶�2^="M1-M2" then delete;
if username in ('���λ�','�����') and �׶�^="M2-M3" and �׶�2^="M2-M3" then delete;

if contract_no="C2018030511431804415577" then �׶�="M1-M2";

if first.contract_no then rank=1; *���ֿͻ��ڷ��䵱�켴�߻��������ϯ��������Щ�ͻ��߻����ֽ���C-M1���ⲿ�ֿͻ�ɾ����;
	else if username not in ('���λ�','�����') and �׶�2="M1-M2" and �׶� in ("0-15","C-M1") then delete;

run;
proc sort data=mmlist_3;by contract_no descending cut_date;run;
proc sort data=mmlist_3 out=mmlist_3 nodupkey;by contract_no �׶�;run;

data mmlist_3_;
set mmlist_3;
*����ʱ�䰴bill_main��clear_date���˴��߼��дֲڣ�ֱ����repay_date��contract_noƴ;
if username in ('���λ�','�����') and �׶�="M1-M2" then REPAY_DATE=intnx('month',REPAY_DATE,-1,'s');
if username in ('���λ�','�����') and �׶� in ("M2-M3","C-M1") then REPAY_DATE=intnx('month',REPAY_DATE,-2,'s');*M2M3�Ĳ��֣��߻�һ�ڼ�������ʱ��©��߻ص�һ��;
if username not in ('���λ�','�����') and �׶�="M2-M3" then REPAY_DATE=intnx('month',REPAY_DATE,-1,'s');
if �׶�="M3-M4" then REPAY_DATE=intnx('month',REPAY_DATE,-2,'s');
if username not in ('���λ�','�����') then  �׶�="M1-M2";
if username in ('���λ�','�����') then �׶�="M2-M3";
drop clear_date �׶�2 rank;
run;
proc sort data=mmlist_3_;by contract_no descending cut_date;run;
proc sort data=mmlist_3_ out=mmlist_3 nodupkey;by contract_no �׶�;run;

proc sql;
create table mmlist_3_2 as 
select a.*,b.����Ա from mmlist_3 as a
left join mmlist_3_1_a as b on a.contract_no=b.��ͬ;
/*left join mmlist_3_1_a as c on a.contract_no=c.��ͬ;*/
quit;


data mmlist_3;
set mmlist_3_2;
if �׶�="M2-M3" and ����Ա="" then delete;
/*if �׶�="M1-M2" and ����Ա^="" then userName=����Ա;*/
run;

************************************************** ���� ********************************************************************;
data fee_breaks_apply_dtl;
set acco.fee_breaks_apply_dtl;
run;
data fee_breaks_apply_dtl_;
set fee_breaks_apply_dtl;
if kindex(contract_no,"C");
if FEE_CODE^='7009';
run;
proc sql;
create table fee_breaks_jm_1_a as 
select contract_no,PERIOD,sum(BREAKS_AMOUNT) as ��Ϣ���� from fee_breaks_apply_dtl_ group by contract_no,PERIOD;
quit;
proc sql;
create table fee_breaks_jm_1_b as 
select a.*,b.clear_date from fee_breaks_jm_1_a as a 
left join account.bill_main(where=(substr(bill_code,1,3)="BLC")) as b on a.contract_no=b.contract_no and a.period=b.CURR_PERIOD;
quit;
proc sql;
create table fee_breaks_jm_1 as 
select contract_no,sum(��Ϣ����) as ��Ϣ���� 
from fee_breaks_jm_1_b 
where &dbpe.<=clear_date<=&dt.
group by contract_no;
quit;
************************************************** ���� ********************************************************************;
*���ڴ��ڲ�ͬʱ��߻�����������������㵱��ʵ�ʴ߻ؽ��;

************���³�ɾ��*************;
data account.bill_main;
set account.bill_main;
if ID=297880 THEN clear_date=mdy(02,28,2019);
run;
************���³�ɾ��*************;

proc sql;
create table bill_main_a as 
select a.*,b.userName,b.cut_date 
from account.bill_main as a
left join repayfin.test_lr_b as b on a.contract_no=b.contract_no and a.CLEAR_DATE=b.cut_date;
quit;

proc sql;
create table bill_main_b as 
select contract_no,sum(CURR_RECEIVE_AMT) as CURR_RECEIVE_AMT,max(clear_date) as clear_date
from bill_main_a 
where &dbpe.<=clear_date<=&dt. and userName in ("���λ�","�����","������","������","�δ���","����","���ǳ�",'���','��٩','����ɭ','�����','������',"����Է")
group by contract_no;
quit;

data kanr;
set repayfin.kanr;
if ��������>=&db.;
run;
proc sql;
create table mmlist_4 as 
select a.*,d.clear_date,d.CURR_RECEIVE_AMT as ʵ�ʽ��,c.��Ϣ����,b.ASSIGN_TIME as ASSIGN_TIME_adjust,b.username as user_adjust from mmlist_3 as a
left join bill_main_b as d on a.contract_no=d.contract_no 
left join fee_breaks_jm_1 as c on a.contract_no=c.contract_no
left join kanr as b on a.contract_no=b.contract_no and d.clear_date>=b.��������;
quit;
proc sort data=mmlist_4;by contract_no descending clear_date descending ASSIGN_TIME_adjust;run;
proc sort data=mmlist_4 nodupkey;by contract_no;run;
data mmlist_5;
set mmlist_4;
if username^=user_adjust and clear_date>0 and user_adjust in ("����Ƽ","����") then delete;
if ��Ϣ����=. then ��Ϣ����=0;
ʵ�ʽ��=ʵ�ʽ��-��Ϣ����;
/*if od_days-lag_od_days^=1 and lag_od_days>30 then clear_date=cut_date;*/
if clear_date>&dt. or clear_date<&db. then do;ʵ�ʽ��=0;clear_date=.;end;
if clear_date=. then ʵ�ʽ��=.;
run;
proc sort data=mmlist_5;by descending clear_date �׶� username;run;
*****************************��� start********************************;
data ca_staff;
set res.ca_staff;
id1=compress(put(id,$20.));
run;
proc sql;
create table ctl_visit_ as
select a.*,b.userName
from csdata.ctl_visit as a 
left join ca_staff as b on a.emp_id=b.id1;
quit;
data ctl_visit;
set ctl_visit_;
format ��ÿ�ʼʱ�� yymmdd10.;
format ��ý���ʱ�� yymmdd10.;
��ÿ�ʼʱ��=datepart(VISIT_START_TIME);
��ý���ʱ��=datepart(VISIT_END_TIME);
keep contract_no ��ÿ�ʼʱ�� username ��ý���ʱ��; 
run;
*****************************��� end********************************;
****************************************************************************;
*�ж��Ƿ�����ò���;
proc sql;
create table ctl_visit_mlist as 
select a.*,b.clear_date from ctl_visit as a
left join mmlist_5 as b on a.contract_no=b.contract_no;
quit;
data ctl_visit_mlist_1;
set ctl_visit_mlist;
if ��ÿ�ʼʱ��<=clear_date<=��ý���ʱ�� then ��ò���=1;else ��ò���=0;
run;
proc sort data=ctl_visit_mlist_1;by contract_no descending ��ò���;run;
proc sort data=ctl_visit_mlist_1 nodupkey;by contract_no;run;
****************************************************************************;
*�����ڿͷ��߻غ���Ȼ�п��ܻᱻ����ķ������ϯ,�˴�ͨ���ͷ��ؿ�ǰ��ϯʱ���в���ͷ��绰�ж��Ƿ�����ϯ�߻�;
data cs_table1_xx;
set repayfin.cs_table1_xx;
format ��ϵ���� yymmdd10.;
��ϵ����=datepart(CREATE_TIME);
if ��ϵ����>=&db.;
run;
proc sql;
create table cs_table_xx2 as 
select a.*,b.clear_date,b.username as ��ϯ from cs_table1_xx  as a
left join mmlist_5 as b on a.contract_no=b.contract_no;
quit;
data cs_table_xx3;
set cs_table_xx2;
/*if username='�ۻԻ�111' then username='�ۻԻ�';*/
/*if username='������111' then username='������';*/
/*if username='�Ż�111' then username='�Ż�';*/
/*if username='�ž�111' then username='�ž�';*/
if clear_date>0;
if username=��ϯ and ��ϵ����<=clear_date then ��ϯ�߻�=1;else ��ϯ�߻�=0;
run;
proc sort data=cs_table_xx3;by contract_no descending ��ϯ�߻�;run;
proc sort data=cs_table_xx3 nodupkey;by contract_no;run;
****************************************************************************;
proc sql;
create table mmlist_6 as 
select a.*,b.��ò���,c.��ϯ�߻� from mmlist_5 as a
left join ctl_visit_mlist_1 as b on a.contract_no=b.contract_no
left join cs_table_xx3 as c on a.contract_no=c.contract_no;
quit;
proc sort data=mmlist_6;by contract_no username;run;
proc sort data=mmlist_6 nodupkey;by contract_no username;run;
proc sort data=mmlist_6;by descending clear_date �׶� username;run;

data mmlist_7;
set mmlist_6;
/*if contract_no='C2017081515103764276653' then do;��ϯ�߻�=1;clear_date=mdy(10,14,2018);end;*/
/*if contract_no='C2016101815484678549280' then do;clear_date=mdy(10,8,2018);ʵ�ʽ��=2483.61;end;*����;*/
/*if contract_no='C2017101415331477390331' then do;clear_date=mdy(10,15,2018);ʵ�ʽ��=6093.91;end;*/
/*if clear_date>=�������� and ��ϯ�߻�=0 then delete;*/
if ��ò���=. then ��ò���=0;
if clear_date not in (0,.) then �߻����=�������;
	else if od_days-lag_od_days^=1 and lag_od_days>30 then �߻����=������� ;
    else �߻����=0;
if od_days-lag_od_days^=1 and lag_od_days>30 then clear_date=cut_date;
if ��ò���=1 and clear_date>1 then �߻�������=�������/2;
	else if ��ò���=0 and clear_date>1 then �߻�������=�������;
	else �߻�������=0;
if ��ò���=1 and ʵ�ʽ��>1 then ʵ�ʽ�����=ʵ�ʽ��/2;
	else if ��ò���=0 and ʵ�ʽ��>1 then ʵ�ʽ�����=ʵ�ʽ��;
if ʵ�ʽ��=. then ʵ�ʽ��=0;
/*if mdy(10,10,2018)<=clear_date<=mdy(10,14,2018) and ����Ա^='' then username=����Ա;*/

if contract_no in("C2016032316515183268193","C2016032309512968856213") then username="�����";/*���³�ɾ��*/
if contract_no in ("C2017051216070171982298","C2017121216390512535887") then delete;
if contract_no in("C2017061214022234204033","C2017111318210995171832") then username="������";/*���³�ɾ��*/
if contract_no in ("C2017072409282969347060") then username= "���λ�";
if contract_no in ("C2018101811071864256893","C151374132017502300000965","C2018051113465839528017") then username = "���";
if contract_no in ("","C2017111715134926866458","C153959059889403000000112") then username ="����ɭ";
if contract_no in ("C2017111418034600639956","C2018051415033324144130","C2017081713261569065078") then username ="�����";
if contract_no in ("C2018051518213216891040","C2017111613542169383878","C151375540674803000001026") then username ="������";
if contract_no in ("C2017051513491486946130","C2017081515493080750126","C2017091216341745005596","C2017092017460743677108","C2016111612014526697963") then username="����";
if contract_no in ("C2017070511512389986625","C2017121815452362239106") then username = "������";
run;

proc sort data=mmlist_7;by descending clear_date �׶� username;run;
proc sql;
create table mmlist_8_1 as 
select username,sum(�������) as �������,sum(�߻����) as �߻����,sum(�߻�������) as �߻�������,sum(ʵ�ʽ��) as ʵ�ʽ��,sum(ʵ�ʽ�����) as ʵ�ʽ����� from mmlist_7 where �׶� in ('M1-M2','M2-M3') group by username;
quit;
proc sql;
create table mmlist_8_2 as 
select username,sum(�߻����) as �߻����day,count(�߻����) as �߻�����day from mmlist_7 where clear_date=&dt. and �׶� in ('M1-M2','M2-M3') group by username;
quit;
data _null_;
format dt yymmdd10.; 
dt = today() - 1;
call symput("dt", dt);
run;
proc sql;
create table mmlist_8_4 as 
select username,sum(�߻����) as �߻����week,sum(�߻�������) as �߻�������week from mmlist_7 where &weekf.<=clear_date<=&dt. and �׶� in ('M1-M2','M2-M3') group by username;
quit;

proc sql;
create table mmlist_9 as 
select a.*,b.*,c.*,d.* from mmlist_8_3 as a
left join mmlist_8_2 as b on a.username=b.username
left join mmlist_8_1 as c on a.username=c.username
left join mmlist_8_4 as d on a.username=d.username;
quit;
proc sort data=mmlist_9;by ���;run;
data mmlist_10;
set mmlist_9;
/*if username='�Ż�' then do;�߻����=�߻����-35999.266774;�߻�������=�߻�������-35999.266774;ʵ�ʽ��=ʵ�ʽ��-3304.44;ʵ�ʽ�����=ʵ�ʽ�����-3304.44;end;*/
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
array char _character_;
Do Over char;
If char=" " Then char='0';
End;
Run;
filename DD DDE "EXCEL|[�߻��ʼ�ʵ��ͳ��.xlsx]report!r3c5:r14c8";
data _null_;set mmlist_10;file DD;put �߻����day �߻�����day ������� �߻����;run;
filename DD DDE "EXCEL|[�߻��ʼ�ʵ��ͳ��.xlsx]report!r3c10:r14c10";
data _null_;set mmlist_10;file DD;put �߻�������;run;
filename DD DDE "EXCEL|[�߻��ʼ�ʵ��ͳ��.xlsx]report!r3c12:r14c14";
data _null_;set mmlist_10;file DD;put ʵ�ʽ�� ʵ�ʽ����� �߻����week;run;
filename DD DDE "EXCEL|[�߻��ʼ�ʵ��ͳ��.xlsx]report!r3c16:r14c16";
data _null_;set mmlist_10;file DD;put �߻�������week;run;

data aa;
set mmlist_7;
format clear_date yymmdd10.;
keep contract_no �׶� �ͻ����� Ӫҵ�� �ʽ����� ������� username ��ò��� ʵ�ʽ�� clear_date;
run;
filename DD DDE "EXCEL|[�߻��ʼ�ʵ��ͳ��.xlsx]��ϸ!r2c1:r2000c10";
data _null_;set aa;file DD;put contract_no �׶� �ͻ����� Ӫҵ�� �ʽ����� ������� username ��ò��� ʵ�ʽ�� clear_date;run;
