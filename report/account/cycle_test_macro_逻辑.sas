*����excel-vbaһЩ�����ʽ��������ʱ��ϳ���һ��ʼ�ʹ�excel;
/*x  "E:\guan\�ռ����ʱ����\cycle\Cycle_End_Delinquent.xlsm"; */
/**/
/**/
/*option compress = yes validvarname = any;*/
/*libname ss "E:\guan\�м��\repayfin\��ʷ����\201903";*�µ�һ�����޸�*;*/
/*libname ss1 "E:\guan\�м��\repayfin";*/
/*libname account "E:\guan\ԭ����\account";*/

*%include������input�����ݲ����ʰ����ᵽǰ��;
/*data day;*/
/*input due_pd due_nd;*/
/*cards;*/
/*1	1*/
/*2	2*/
/*3	3*/
/*4	4*/
/*5	5*/
/*6	6*/
/*7	7*/
/*8	8*/
/*9	9*/
/*10	10*/
/*11	11*/
/*12	12*/
/*13	13*/
/*14	14*/
/*15	15*/
/*16	16*/
/*17	17*/
/*18	18*/
/*19	19*/
/*20	20*/
/*21	21*/
/*22	22*/
/*23	23*/
/*24	24*/
/*25	25*/
/*26	26*/
/*27	27*/
/*28	28*/
/*29	29*/
/*30	30*/
/*31	31*/
/*;*/
/*run;*/
/**/
/*data yingyebu;*/
/*input zd branch_name $40.;*/
/*cards;*/
/*1	�Ϻ�����·Ӫҵ��*/
/*2	�Ϸ�վǰ·Ӫҵ��*/
/*3	�����е�һӪҵ��*/
/*4	�γ��е�һӪҵ��*/
/*5	���ݽ�����·Ӫҵ��*/
/*6	��������·Ӫҵ��*/
/*7	�����е�һӪҵ��*/
/*8	�����е�һӪҵ��*/
/*9	�����е�һӪҵ��*/
/*10	�����е�һӪҵ��*/
/*11	֣���е�һӪҵ��*/
/*12	�������ֺ���·Ӫҵ��*/
/*13	���ݵ�һӪҵ��*/
/*14	�����е�һӪҵ��*/
/*15	�����е�һӪҵ��*/
/*16	��ͷ�е�һӪҵ��*/
/*17	�����е�һӪҵ��*/
/*18	��ɽ�е�һӪҵ��*/
/*19	տ���е�һӪҵ��*/
/*20	�Ͼ��е�һӪҵ��*/
/*21	���ͺ����е�һӪҵ��*/
/*22	����е�һӪҵ��*/
/*23	�����е�һӪҵ��*/
/*24	����е�һӪҵ��*/
/*25	�ɶ��츮����Ӫҵ��*/
/*26	�����е�һӪҵ��*/
/*27	�人�е�һӪҵ��*/
/*28	����е�һӪҵ��*/
/*29	�����е�һӪҵ��*/
/*30	��³ľ���е�һӪҵ��*/
/*31	�����е�һӪҵ��*/
/*32	�����е�һӪҵ��*/
/*33	������е�һӪҵ��*/
/*34	�����е�һӪҵ��*/
/*35	�����е�һӪҵ��*/
/*36	������ҵ������*/
/*37	��ͨ��ҵ������*/
/*;*/
/*run;*/
/**/
/*data peizhibiao;*/
/*input id day day_n  DD status $20.;*/
/*cards;*/
/*0	0	0	0 09_ES*/
/*1	0	0	0 00_NB*/
/*2	8	8	3 02_M1_1*/
/*3	16	16	6 02_M1_2*/
/*4	30	31	8 02_M1_3*/
/*5	30	31	13 03_M2*/
/*6	30	31	15 04_M3*/
/*7	30	31	17 05_M4*/
/*8	30	31	19 06_M5*/
/*9	30	31	21 07_M6*/
/*10	30	31	0 08_M6+*/
/*;*/
/*run;*/

%let llastmonth="201908";*�µ�һ�����޸�*;
%let lastmonth="201909";*�µ�һ�����޸�*;
%let nowmonth="2019010";*�µ�һ�����޸�*;
%let nextwmonth="201911";*�µ�һ�����޸�*;

data aaa;
format month_begin month_end last_month_begin last_month_end next_month_begin  llast_month_end yymmdd10.;
month_begin=intnx("month",today()-1,0,"b");
month_end=intnx("month",today()-1,1,"b")-1;
llast_month_end=intnx("month",today()-1,-1,"b")-1;
last_month_begin=intnx("month",today()-1,-1,"b");
last_month_end=intnx("month",today()-1,0,"b")-1;
next_month_begin=intnx("month",today()-1,1,"b");
call symput("month_begin",month_begin);
call symput("month_end",month_end);
call symput("last_month_begin",last_month_begin);
call symput("llast_month_end",llast_month_end);
call symput("last_month_end",last_month_end);
call symput("next_month_begin",next_month_begin);
run;

*song:ss.Payment_daily���ϸ����µ������payment_daily;
data sdata;
set ss.Payment_daily(where=(cut_date^=&llast_month_end.)) 
    ss1.Payment_daily(where=(cut_date^=&last_month_end.));
if Ӫҵ��^="APP";
/*if es=1 and es_date<=&last_month_begin. then delete;*/
run;
proc sort data=sdata;by contract_no cut_date;run;
data repayd;
set account.bill_main(keep=repay_date contract_no ID CURR_PERIOD);
repay_m=put(repay_date,yymmn6.);
if repay_m in (&lastmonth.,&nowmonth.,&nextwmonth.);
drop repay_m;
run;
proc sort data=repayd;by contract_no  ID ;run;
proc sort data=repayd nodupkey ;by contract_no CURR_PERIOD;run;

data repayd1;
set repayd;
by contract_no CURR_PERIOD;
if first.contract_no then id1=0;
retain id1;
id1+1;
run;

data repayd;
set repayd1;
if id1<=3;
run;

*-------------------------------------����һЩ�����Ŀͻ���repay_date�������ִ�λ��һЩ�շſ��û���⣬��˼������������----------------------*;
*�����������Ū���Ǹ�lag���������ͻ��ĺ�ͬ��ŵ�repay_date��due day;

*ȥ����ǰ����;
proc sort data=account.bill_main out=bill_main ;by contract_no  ID ;run;
proc sort data=bill_main nodupkey ;by contract_no CURR_PERIOD;run;

*�ҳ����һ���˵�;
proc sort data=bill_main  ;by contract_no descending CURR_PERIOD;run;
proc sort data=bill_main nodupkey out=bill_last(keep =contract_no CURR_PERIOD)  ;by contract_no;run;

proc sql;
create table aaa1 as 
select contract_no,count(*) as ����
from repayd 
group by contract_no;
quit;
proc sql;
create table aaa2 as 
select a.*,b.CURR_PERIOD as  ����,c.����
from repayd as a
left join bill_last as b on a.contract_no=b.contract_no
left join aaa1 as c on a.contract_no=c.contract_no;
quit;


data aaa3 ;
set aaa2;
if ����<3 and CURR_PERIOD=����;
run;

*ƴһ��2��;
data aaa4;
set aaa2;
if ����=1 and CURR_PERIOD=���� ;
if ����=1 and CURR_PERIOD=���� then REPAY_DATE="";
run;


*ƴһ��1��;
data aaa5;
set aaa2;
if ����=2 and CURR_PERIOD=���� ;
if ����=2 and CURR_PERIOD=���� then REPAY_DATE="";
run;

data repayd;
set aaa2 aaa4 aaa4 aaa5;
drop ���� ����;
run;
proc sort data=repayd;by contract_no CURR_PERIOD descending REPAY_DATE;run;

*----------------------------------------------------------------------------------------------------------------------------------------------*;


data repayd1_;
set repayd;
format nowmonth_repay_date   repay_date yymmdd10.;
nowmonth_repay_date=lag(repay_date);
by contract_no CURR_PERIOD ;
if first.contract_no then nowmonth_repay_date="";
run;

proc sort data=repayd1_;by contract_no CURR_PERIOD ;run;

data repayd1;
set repayd1_;
format lastmonth_repay_date   yymmdd10.;
lastmonth_repay_date=lag(nowmonth_repay_date);
by contract_no CURR_PERIOD ;
if first.contract_no then do; nowmonth_repay_date="";lastmonth_repay_date="";end;
if last.contract_no;
rename repay_date=nextmonth_repay_date;
run;

proc sql;
create table payment1 as
select a.*,a.status as status_p ,b.nextmonth_repay_date ,b.nowmonth_repay_date,b.lastmonth_repay_date  from sdata as a
left join repayd1 as b on a.contract_no=b.contract_no;
quit;
data payment2_1;
set payment1(keep=contract_no es �ſ����� Ӫҵ�� �ͻ����� month od_periods od_days  status_p ������� nextmonth_repay_date  nowmonth_repay_date lastmonth_repay_date  cut_date ����_���տۿ�ʧ�ܺ�ͬ ����_����Ӧ�ۿ��ͬ repay_date);
due_pd=day(lastmonth_repay_date);
due_nd=day(nowmonth_repay_date);
format loan_date yymmdd10.;
loan_date=mdy(scan(�ſ�����,2,"-"), scan(�ſ�����,3,"-"),scan(�ſ�����,1,"-"));
/*a=intnx("month",loan_date,1,"s");*/
format status $24.;
if es = 1 then status = "09_ES";
else if cut_date<intnx("month",loan_date,1,"s") then status="00_NB";
else if od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ^=1  then status="01_C";
else if od_days=0 and ����_���տۿ�ʧ�ܺ�ͬ=1  then status="02_M1_1";
else if 1<=od_days<=7  then status="02_M1_1";
else if 8<=od_days<=15  then status="02_M1_2";
else if 16<=od_days <= 30 then status = "02_M1_3";
else if od_periods < 1 then status = "01_C";
else if 31<=od_days <= 60 then status = "03_M2";
else if 61<=od_days <= 90 then status = "04_M3";
else if 91<=od_days <= 120 then status = "05_M4";
else if 121<=od_days <= 150 then status = "06_M5";
else if 151<=od_days <= 180 then status = "07_M6";
else if od_days > 180 then status = "08_M6+";
else status="";
if status="02_M1_3" and od_days>=30 then status="03_M2";
run;
data payment2;
set payment2_1;
*M2�����ϵ�״̬��ֱ���øս����״̬�������������ж����״ν����״̬���ö�Ӧ��cut_date��Ϊ�����״̬������;
if status = "03_M2" and od_days=31 then begin_label=1;
if status = "04_M3" and od_days=61 then begin_label=1;
if status = "05_M4" and od_days=91 then begin_label=1;
if status = "06_M5" and od_days=121 then begin_label=1;
if status = "07_M6" and od_days=151 then begin_label=1;
if due_pd=. then due_pd=day(repay_date);*������������������ʣ��Ӧ�������ĺ�ͬ��due_pd���ɿ�;
if due_nd=. then due_nd=day(repay_date);
if status in ("03_M2","04_M3","05_M4","06_M5","07_M6", "08_M6+") then do;due_pd=day(cut_date);due_nd=day(cut_date);end;
if nextmonth_repay_date=. and nowmonth_repay_date^=. then nextmonth_repay_date=intnx('month',nowmonth_repay_date,1);*nextmonth_repay_dateΪ��ʱ�����һ������1-30��ending�ò�������;
run;

*�����µ���31�����ڣ���30�ĳ�31;
data peizhibiao;
set peizhibiao;
if id>3  then do;day=intck("day",&last_month_begin.,&month_begin.);day_n=intck("day",&month_begin.,&next_month_begin.);end;
day0=lag(day);
day0_n=lag(day_n);
by id;
if id=0 then do; day0=0;day0_n=0;day_n=0;end;
if id=4 then do; day_n=0;end;
if id>4 then do; day0=0;day0_n=0;day_n=0;end;
run;

%macro cycle;
data _null_;
n=9;
call symput("n",n);
run;
%do i=2 %to &n.;

data aa_&i.;
set peizhibiao;
if id=&i.;
call symput("day",day);*����һ���꣬�����˵�����������;
call symput("day0",day0);*����һ����,�����˵���ʼ������;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*����һ����,�����˵���ʼ������;
call symput("DDE2",COMPRESS(DDE2));*����һ����,�����˵���ʼ������;
run;

*�����ع�;
%if &i.>4 %then %do;
*M2���Ժ�����������涨���begin_label��Ϊ���״ν���ı�־;
proc sql;
create table data_begining as 
select * from payment2 
where begin_label=1 and status in (select status from peizhibiao where id=&i.)  and es^=1 and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
proc sort data=data_begining;by contract_no cut_date;run;
proc sort data=data_begining nodupkey;by contract_no;run;
%end;
%else %do;
*M2��ǰ��������ʱû�������⣬�ȱ������߼���M2���������Ϊÿ��������һ�������Ե����˵��������û���ֵ����˵���ʱ����״̬����ͬ�ϸ���״̬;
proc sql;
create table data_begining as 
select * from payment2 
where cut_date=lastmonth_repay_date+&day0. and status in (select status from peizhibiao where id=&i.)  and es^=1 and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
%end;

proc sql;
create table begining_&i. as
select due_pd,count(*) as b����_&i. from data_begining group by due_pd;
quit;

proc sql;
create table begining_m_&i. as
select due_pd,sum(�������) as b���_&i. from data_begining group by due_pd;
quit;

%if &i.>4 %then %do;
*M2���Ժ��״̬����cut_date�����ڣ��ʴ˴�Ҫƴbegining�����ڣ��������ڻ��ҡ�ending��״̬��ֱ�ӿ�30����״̬��;
proc sql;
create table data_ending as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
status,od_days from payment2 where contract_no in (select contract_no from data_begining);
quit;
proc sql;
create table data_ending_ as 
select a.*,b.cut_date as nrepay_date,b.due_pd from data_ending as a
left join data_begining as b on a.contract_no=b.contract_no;
quit;
data data_ending_a_;
set data_ending_;
if cut_date<=intnx('day',nrepay_date,30);
run;
proc sort data=data_ending_a_;by contract_no descending cut_date;run;
proc sort data=data_ending_a_ nodupkey;by contract_no;run;
proc sql;
create table data_ending_a as 
select * from data_ending_a_ where status in (select status from peizhibiao where id>=&i.);
quit;
%end;
%else %do;
proc sql;
create table data_ending as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
case when &i.>=4 then nowmonth_repay_date else lastmonth_repay_date+&day. end as nrepay_date ,
status,od_days from payment2 where contract_no in (select contract_no from data_begining) and &last_month_begin.+&day.<=cut_date<=&last_month_end.+&day.;
quit;
proc sort data=data_ending(where=(cut_date<=nrepay_date)) out=data_ending_;by contract_no descending cut_date;run;
proc sort data=data_ending_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending_1 as 
select a.*,b.due_pd from data_ending_ as a
left join data_begining as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending_a as 
select * from data_ending_1 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>=&i.)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=&i.))
or (cut_date=nrepay_date and status in (select status from peizhibiao where id>=&i.)  and  od_days>=30*(&i.-3));
quit;
%end;

proc sql;
create table ending_&i. as
select due_pd,count(*) as e����_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table ending_m_&i. as
select due_pd,sum(�������) as e���_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table cycle_&i. as
select a.due_pd,b.*,c.* from day as a
left join begining_&i. as b on a.due_pd=b.due_pd
left join ending_&i. as c on a.due_pd=c.due_pd;
quit;

data cycle_&i.;
set cycle_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

proc sql;
create table cycle_m_&i. as
select a.due_pd,b.*,c.* from day as a
left join begining_m_&i. as b on a.due_pd=b.due_pd
left join ending_m_&i. as c on a.due_pd=c.due_pd;
quit;

data cycle_m_&i.;
set cycle_m_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_&i.;file DD;put b����_&i. e����_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_m_&i.;file DD;put b���_&i. e���_&i. ;run;


%end;
%mend;
%cycle;


%macro cycle_n;
data _null_;
n=9;
call symput("n",n);
run;
%do i=2 %to &n.;

data aa_&i.;
set peizhibiao;
if id=&i.;
call symput("day_n",day_n);*����һ���꣬�����˵�����������;
call symput("day0_n",day0_n);*����һ����,�����˵���ʼ������;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*����һ����,�����˵���ʼ������;
call symput("DDE2",COMPRESS(DDE2));*����һ����,�����˵���ʼ������;
run;


*�����ع�;
%if &i.>4 %then %do;
proc sql;
create table data_begining_n as 
select * from payment2 
where begin_label=1 and status in (select status from peizhibiao where id=&i.)  and es^=1 and &month_begin.+&day0_n.<=cut_date<=&month_end.+&day0_n.;
quit;
proc sort data=data_begining_n;by contract_no cut_date;run;
proc sort data=data_begining_n nodupkey;by contract_no;run;
%end;
%else %do;
proc sql;
create table data_begining_n as 
select * from payment2 
where cut_date=nowmonth_repay_date+&day0_n. and status in (select status from peizhibiao where id=&i.)  and es^=1 and &month_begin.+&day0_n.<=cut_date<=&month_end.+&day0_n.;
quit;
%end;

proc sql;
create table begining_n_&i. as
select due_nd,count(*) as b����_&i. from data_begining_n group by due_nd;
quit;

proc sql;
create table begining_n_m_&i. as
select due_nd,sum(�������) as b���_&i. from data_begining_n group by due_nd;
quit;

%if &i.>4 %then %do;
proc sql;
create table data_ending_n as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
status,od_days from payment2 where contract_no in (select contract_no from data_begining_n);
quit;
proc sql;
create table data_ending_n_ as 
select a.*,b.cut_date as nrepay_date,b.due_nd from data_ending_n as a
left join data_begining_n as b on a.contract_no=b.contract_no;
quit;
data data_ending_n_a_;
set data_ending_n_;
if cut_date<=intnx('day',nrepay_date,30);
run;
proc sort data=data_ending_n_a_;by contract_no descending cut_date;run;
proc sort data=data_ending_n_a_ nodupkey;by contract_no;run;
proc sql;
create table data_ending_n_a as 
select * from data_ending_n_a_ where status in (select status from peizhibiao where id>=&i.);
quit;
%end;
%else %do;
*�����i=3�ĵ�������������Ϊlast�����̻����꣬����now����1��ǰ�ڵ�ʱ��cut_date����û���굽16ending����i=3�ĸĳ�8;
proc sql;
create table data_ending_n as
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,�������,
case when &i.>=4 then nextmonth_repay_date else nowmonth_repay_date+&day_n. end as nrepay_date ,
status,od_days from payment2 
where (&i.=3 and contract_no in (select contract_no from data_begining_n) and &month_begin.+8<=cut_date<=&month_end.) 
or (&i.^=3 and contract_no in (select contract_no from data_begining_n) and &month_begin.+&day_n.<=cut_date<=&month_end.+&day_n.) ;
quit;
proc sort data=data_ending_n(where=(cut_date<=nrepay_date)) out=data_ending_n_;by contract_no descending cut_date;run;
proc sort data=data_ending_n_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending_n_a_ as 
select a.*,b.due_nd from data_ending_n_ as a
left join data_begining_n as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending_n_a as 
select * from data_ending_n_a_ 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>&i.)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=&i.))
or (cut_date=nrepay_date and status in (select status from peizhibiao where id>=&i.)  and  od_days>=30*(&i.-3))
;
quit;
%end;

proc sql;
create table ending_n_&i. as
select due_nd,count(*) as e����_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table ending_n_m_&i. as
select due_nd,sum(�������) as e���_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table cycle_n_&i. as
select a.due_nd,b.*,c.* from day as a
left join begining_n_&i. as b on a.due_nd=b.due_nd
left join ending_n_&i. as c on a.due_nd=c.due_nd;
quit;

data cycle_n_&i.;
set cycle_n_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

proc sql;
create table cycle_n_m_&i. as
select a.due_nd,b.*,c.* from day as a
left join begining_n_m_&i. as b on a.due_nd=b.due_nd
left join ending_n_m_&i. as c on a.due_nd=c.due_nd;
quit;

data cycle_n_m_&i.;
set cycle_n_m_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_n_&i.;file DD;put b����_&i. e����_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_n_m_&i.;file DD;put b���_&i. e���_&i. ;run;


%end;
%mend;
%cycle_n;

*д�����Ϻ��쵼Ҫ�������ۿ�ɹ��ʼ�M1�������������M1������ܵĻ�statusҪ�ģ�����ĺ겻���ã����Խ��䵥�������;
*Ӧ�ϰ�����,������ۿ�Ĵ������׷�ݵ���һ����ۿ�ǰһ��Ĵ������,���ǵ����ڹ�δ�ۿ�Ĵ������;

proc sql;
create table payment2_ as 
select a.*,b.������� as �����µ״������
from payment2 as a 
left join ss1.payment_g(where=(month=&llastmonth.)) as b 
on a.contract_no=b.contract_no;
quit;
proc sort data=payment2_;by contract_no cut_date;run;

data payment2_a;
set payment2_;
ǰһ��������=lag(�������);
by contract_no cut_date;
if first.contract_no then do;ǰһ��������=�����µ״������;end;
if  ����_����Ӧ�ۿ��ͬ=1 then �������=ǰһ��������;
run;

proc sql;
create table n_repay_l as 
select month,due_pd,sum(����_����Ӧ�ۿ��ͬ) as ��ĸ,sum(�������) as ��ĸ1,sum(�����µ״������) as test
from payment2_a
where month=&lastmonth. and due_pd>0  and ����_����Ӧ�ۿ��ͬ=1 and es^=1 and status_p not in ("09_ES","11_Settled")
group by month,due_pd;
quit;

data n_repay_l;
set n_repay_l;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r6c3:r36c3";
data _null_;set n_repay_l;file DD;put ��ĸ ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r42c3:r72c3";
data _null_;set n_repay_l;file DD;put ��ĸ1 ;run;

proc sql;
create table n_repay_n as 
select month,due_nd,sum(����_����Ӧ�ۿ��ͬ) as ��ĸ,sum(�������) as ��ĸ1
from payment2_a
where month=&nowmonth. and 0<due_nd<=intck("day",&month_begin.,today()) and ����_����Ӧ�ۿ��ͬ=1 and es^=1 and status_p not in ("09_ES","11_Settled")
group by month,due_nd;
quit;

data n_repay_n;
set n_repay_n;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r6c3:r36c3";
data _null_;set n_repay_n;file DD;put ��ĸ ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r42c3:r72c3";
data _null_;set n_repay_n;file DD;put ��ĸ1 ;run;


*��M1�������;
*����;
proc sql;
create table data_begining1 as 
select * from payment2 
where cut_date=lastmonth_repay_date and status in (select status from peizhibiao where id=2)  and month=&lastmonth. and es^=1;
quit;

proc sql;
create table begining_21 as
select due_pd,count(*) as b����_2,sum(�������) as b���_2 from data_begining1 group by due_pd;
quit;

proc sql;
create table data_ending1 as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
nowmonth_repay_date  as nrepay_date ,
status,od_days from payment2 where contract_no in (select contract_no from data_begining1)   and &last_month_begin.+intck("day",&last_month_begin.,&month_begin.)<=cut_date<=&last_month_end.+intck("day",&last_month_begin.,&month_begin.);
quit;
proc sort data=data_ending1(where=(cut_date<=nrepay_date)) out=data_ending1_;by contract_no descending cut_date;run;
proc sort data=data_ending1_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending1_1 as 
select a.*,b.due_pd from data_ending1_ as a
left join data_begining1 as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending1_a as 
select * from data_ending1_1 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>2)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=2)) 
;
quit;

proc sql;
create table ending_21 as
select due_pd,count(*) as e����_2,sum(�������) as e���_2 from data_ending1_a group by due_pd;
quit;
proc sql;
create table cycle_21 as
select a.due_pd,b.*,c.* from day as a
left join begining_21 as b on a.due_pd=b.due_pd
left join ending_21 as c on a.due_pd=c.due_pd;
quit;

data cycle_21;
set cycle_21;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r6c15:r36c16";
data _null_;set cycle_21;file DD;put b����_2 e����_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r42c15:r72c16";
data _null_;set cycle_21;file DD;put b���_2 e���_2 ;run;

*����;
proc sql;
create table data_begining1_n as 
select * from payment2 
where  cut_date=nowmonth_repay_date and status in (select status from peizhibiao where id=2) and month=&nowmonth. and es^=1;
quit;
proc sql;
create table begining_n_21 as
select due_nd,count(*) as b����_2,sum(�������) as b���_2 from data_begining1_n group by due_nd;
quit;
proc sql;
create table data_ending1_n as
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,�������,
nextmonth_repay_date as nrepay_date ,
status,od_days from payment2 where contract_no in (select contract_no from data_begining1_n) and month=&nowmonth.;
quit;
proc sort data=data_ending1_n(where=(cut_date<=nrepay_date)) out=data_ending1_n_;by contract_no descending cut_date;run;
proc sort data=data_ending1_n_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending1_n_1 as 
select a.*,b.due_nd from data_ending1_n_ as a
left join data_begining1_n as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending1_n_a as 
select * from data_ending1_n_1 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>2)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=2)) 
;
quit;

proc sql;
create table ending_n_21 as
select due_nd,count(*) as e����_2,sum(�������) as e���_2 from data_ending1_n_a group by due_nd;
quit;
proc sql;
create table cycle_n_21 as
select a.due_nd,b.*,c.* from day as a
left join begining_n_21 as b on a.due_nd=b.due_nd
left join ending_n_21 as c on a.due_nd=c.due_nd;
quit;

data cycle_n_21;
set cycle_n_21;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r6c15:r36c16";
data _null_;set cycle_n_21;file DD;put b����_2 e����_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r42c15:r72c16";
data _null_;set cycle_n_21;file DD;put b���_2 e���_2 ;run;

%macro yingyebu;
data _null_;
a=34;
call symput("a",a);
run;
%do z=1 %to &a.;
data branch_&z.;
set yingyebu;
if zd=&z.;
call symput("branch_name",branch_name);
run;


%macro cycle;
data _null_;
n=9;
call symput("n",n);
run;
%do i=2 %to &n.;

data aa_&i.;
set peizhibiao;
if id=&i.;
call symput("day",day);*����һ���꣬�����˵�����������;
call symput("day0",day0);*����һ����,�����˵���ʼ������;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*����һ����,�����˵���ʼ������;
call symput("DDE2",COMPRESS(DDE2));*����һ����,�����˵���ʼ������;
run;

*�����ع�;
%if &i.>4 %then %do;
proc sql;
create table data_begining as 
select * from payment2 
where begin_label=1 and status in (select status from peizhibiao where id=&i.) and Ӫҵ��="&branch_name." and es^=1   and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
proc sort data=data_begining;by contract_no cut_date;run;
proc sort data=data_begining nodupkey;by contract_no;run;
%end;
%else %do;
proc sql;
create table data_begining as 
select * from payment2 
where cut_date=lastmonth_repay_date+&day0. and status in (select status from peizhibiao where id=&i.) and Ӫҵ��="&branch_name." and es^=1   and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
%end;

proc sql;
create table begining_&i. as
select due_pd,count(*) as b����_&i. from data_begining group by due_pd;
quit;

proc sql;
create table begining_m_&i. as
select due_pd,sum(�������) as b���_&i. from data_begining group by due_pd;
quit;

%if &i.>4 %then %do;
proc sql;
create table data_ending as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
status,od_days from payment2 where contract_no in (select contract_no from data_begining);
quit;
proc sql;
create table data_ending_ as 
select a.*,b.cut_date as nrepay_date,b.due_pd from data_ending as a
left join data_begining as b on a.contract_no=b.contract_no;
quit;
data data_ending_a_;
set data_ending_;
if cut_date<=intnx('day',nrepay_date,30);
run;
proc sort data=data_ending_a_;by contract_no descending cut_date;run;
proc sort data=data_ending_a_ nodupkey;by contract_no;run;
proc sql;
create table data_ending_a as 
select * from data_ending_a_ where status in (select status from peizhibiao where id>=&i.);
quit;
%end;
%else %do;
proc sql;
create table data_ending as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
case when &i.>=4 then nowmonth_repay_date else lastmonth_repay_date+&day. end as nrepay_date ,
status,od_days from payment2 where contract_no in (select contract_no from data_begining)   and &last_month_begin.+&day.<=cut_date<=&last_month_end.+&day.;
quit;
proc sort data=data_ending(where=(cut_date<=nrepay_date)) out=data_ending_;by contract_no descending cut_date;run;
proc sort data=data_ending_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending_1 as 
select a.*,b.due_pd from data_ending_ as a
left join data_begining as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending_a as 
select * from data_ending_1 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>&i.)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=&i.))
or (cut_date=nrepay_date and status in (select status from peizhibiao where id>=&i.)  and  od_days>=30*(&i.-3));
quit;
%end;

proc sql;
create table ending_&i. as
select due_pd,count(*) as e����_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table ending_m_&i. as
select due_pd,sum(�������) as e���_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table cycle_&i. as
select a.due_pd,b.*,c.* from day as a
left join begining_&i. as b on a.due_pd=b.due_pd
left join ending_&i. as c on a.due_pd=c.due_pd;
quit;

data cycle_&i.;
set cycle_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

proc sql;
create table cycle_m_&i. as
select a.due_pd,b.*,c.* from day as a
left join begining_m_&i. as b on a.due_pd=b.due_pd
left join ending_m_&i. as c on a.due_pd=c.due_pd;
quit;

data cycle_m_&i.;
set cycle_m_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_&i.;file DD;put b����_&i. e����_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_m_&i.;file DD;put b���_&i. e���_&i. ;run;


%end;
%mend;
%cycle;


%macro cycle_n;
data _null_;
n=9;
call symput("n",n);
run;
%do i=2 %to &n.;

data aa_&i.;
set peizhibiao;
if id=&i.;
call symput("day_n",day_n);*����һ���꣬�����˵�����������;
call symput("day0_n",day0_n);*����һ����,�����˵���ʼ������;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*����һ����,�����˵���ʼ������;
call symput("DDE2",COMPRESS(DDE2));*����һ����,�����˵���ʼ������;
run;


*�����ع�;
%if &i.>4 %then %do;
proc sql;
create table data_begining_n as 
select * from payment2 
where begin_label=1 and status in (select status from peizhibiao where id=&i.)  and &month_begin.+&day0_n.<=cut_date<=&month_end.+&day0_n. and Ӫҵ��="&branch_name." and es^=1;
quit;
proc sort data=data_begining_n;by contract_no cut_date;run;
proc sort data=data_begining_n nodupkey;by contract_no;run;
%end;
%else %do;
proc sql;
create table data_begining_n as 
select * from payment2 
where cut_date=nowmonth_repay_date+&day0_n. and status in (select status from peizhibiao where id=&i.)  and &month_begin.+&day0_n.<=cut_date<=&month_end.+&day0_n. and Ӫҵ��="&branch_name." and es^=1;
quit;
%end;

proc sql;
create table begining_n_&i. as
select due_nd,count(*) as b����_&i. from data_begining_n group by due_nd;
quit;

proc sql;
create table begining_n_m_&i. as
select due_nd,sum(�������) as b���_&i. from data_begining_n group by due_nd;
quit;

%if &i.>4 %then %do;
proc sql;
create table data_ending_n as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
status,od_days from payment2 where contract_no in (select contract_no from data_begining_n);
quit;
proc sql;
create table data_ending_n_ as 
select a.*,b.cut_date as nrepay_date,b.due_nd from data_ending_n as a
left join data_begining_n as b on a.contract_no=b.contract_no;
quit;
data data_ending_n_a_;
set data_ending_n_;
if cut_date<=intnx('day',nrepay_date,30);
run;
proc sort data=data_ending_n_a_;by contract_no descending cut_date;run;
proc sort data=data_ending_n_a_ nodupkey;by contract_no;run;
proc sql;
create table data_ending_n_a as 
select * from data_ending_n_a_ where status in (select status from peizhibiao where id>=&i.);
quit;
%end;
%else %do;
proc sql;
create table data_ending_n as
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,�������,
case when &i.>=4 then nextmonth_repay_date else nowmonth_repay_date+&day_n. end as nrepay_date ,
status,od_days from payment2 
where (&i.=3 and contract_no in (select contract_no from data_begining_n) and &month_begin.+8<=cut_date<=&month_end.) 
or (&i.^=3 and contract_no in (select contract_no from data_begining_n) and &month_begin.+&day_n.<=cut_date<=&month_end.+&day_n.) ;
quit;
proc sort data=data_ending_n(where=(cut_date<=nrepay_date)) out=data_ending_n_;by contract_no descending cut_date;run;
proc sort data=data_ending_n_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending_n_a_ as 
select a.*,b.due_nd from data_ending_n_ as a
left join data_begining_n as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending_n_a as 
select * from data_ending_n_a_ 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>&i.)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=&i.));
quit;
%end;

proc sql;
create table ending_n_&i. as
select due_nd,count(*) as e����_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table ending_n_m_&i. as
select due_nd,sum(�������) as e���_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table cycle_n_&i. as
select a.due_nd,b.*,c.* from day as a
left join begining_n_&i. as b on a.due_nd=b.due_nd
left join ending_n_&i. as c on a.due_nd=c.due_nd;
quit;

data cycle_n_&i.;
set cycle_n_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

proc sql;
create table cycle_n_m_&i. as
select a.due_nd,b.*,c.* from day as a
left join begining_n_m_&i. as b on a.due_nd=b.due_nd
left join ending_n_m_&i. as c on a.due_nd=c.due_nd;
quit;

data cycle_n_m_&i.;
set cycle_n_m_&i.;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_n_&i.;file DD;put b����_&i. e����_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_n_m_&i.;file DD;put b���_&i. e���_&i. ;run;


%end;
%mend;
%cycle_n;

*д�����Ϻ��쵼Ҫ�������ۿ�ɹ��ʼ�M1�������������M1������ܵĻ�statusҪ�ģ�����ĺ겻���ã����Խ��䵥�������;
proc sql;
create table n_repay_l as 
select month,due_pd,sum(����_����Ӧ�ۿ��ͬ) as ��ĸ,sum(�������) as ��ĸ1
from payment2
where month=&lastmonth. and due_pd>0  and ����_����Ӧ�ۿ��ͬ=1 and Ӫҵ��="&branch_name." and es^=1
group by month,due_pd;
quit;

data n_repay_l;
set n_repay_l;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r6c3:r36c3";
data _null_;set n_repay_l;file DD;put ��ĸ ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r42c3:r72c3";
data _null_;set n_repay_l;file DD;put ��ĸ1 ;run;

proc sql;
create table n_repay_n as 
select month,due_nd,sum(����_����Ӧ�ۿ��ͬ) as ��ĸ,sum(�������) as ��ĸ1
from payment2
where month=&nowmonth. and 0<due_nd<=intck("day",&month_begin.,today()) and ����_����Ӧ�ۿ��ͬ=1 and Ӫҵ��="&branch_name." and es^=1
group by month,due_nd;
quit;

data n_repay_n;
set n_repay_n;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r6c3:r36c3";
data _null_;set n_repay_n;file DD;put ��ĸ ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r42c3:r72c3";
data _null_;set n_repay_n;file DD;put ��ĸ1 ;run;


*��M1�������;
*����;
proc sql;
create table data_begining1 as 
select * from payment2 
where cut_date=lastmonth_repay_date and status in (select status from peizhibiao where id=2) and Ӫҵ��="&branch_name." and es^=1   and  month=&lastmonth. ;
quit;

proc sql;
create table begining_21 as
select due_pd,count(*) as b����_2,sum(�������) as b���_2 from data_begining1 group by due_pd;
quit;

proc sql;
create table data_ending1 as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,�������,
nowmonth_repay_date  as nrepay_date ,
status,od_days from payment2 where contract_no in (select contract_no from data_begining1)  and &last_month_begin.+intck("day",&last_month_begin.,&month_begin.)<=cut_date<=&last_month_end.+intck("day",&last_month_begin.,&month_begin.) ;
quit;
proc sort data=data_ending1(where=(cut_date<=nrepay_date)) out=data_ending1_;by contract_no descending cut_date;run;
proc sort data=data_ending1_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending1_1 as 
select a.*,b.due_pd from data_ending1_ as a
left join data_begining1 as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending1_a as 
select * from data_ending1_1 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>2)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=2)) 
;
quit;

proc sql;
create table ending_21 as
select due_pd,count(*) as e����_2,sum(�������) as e���_2 from data_ending1_a group by due_pd;
quit;
proc sql;
create table cycle_21 as
select a.due_pd,b.*,c.* from day as a
left join begining_21 as b on a.due_pd=b.due_pd
left join ending_21 as c on a.due_pd=c.due_pd;
quit;

data cycle_21;
set cycle_21;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r6c15:r36c16";
data _null_;set cycle_21;file DD;put b����_2 e����_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r42c15:r72c16";
data _null_;set cycle_21;file DD;put b���_2 e���_2 ;run;

*����;
proc sql;
create table data_begining1_n as 
select * from payment2 
where  cut_date=nowmonth_repay_date and status in (select status from peizhibiao where id=2) and  month=&nowmonth.  and Ӫҵ��="&branch_name." and es^=1;
quit;
proc sql;
create table begining_n_21 as
select due_nd,count(*) as b����_2,sum(�������) as b���_2 from data_begining1_n group by due_nd;
quit;
proc sql;
create table data_ending1_n as
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,�������,
nextmonth_repay_date as nrepay_date ,
status,od_days from payment2 where contract_no in (select contract_no from data_begining1_n) and month=&nowmonth.;
quit;
proc sort data=data_ending1_n(where=(cut_date<=nrepay_date)) out=data_ending1_n_;by contract_no descending cut_date;run;
proc sort data=data_ending1_n_ nodupkey ;by contract_no;run;
proc sql;
create table data_ending1_n_1 as 
select a.*,b.due_nd from data_ending1_n_ as a
left join data_begining1_n as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table data_ending1_n_a as 
select * from data_ending1_n_1 
where (cut_date=nrepay_date and  status in (select status from peizhibiao where id>2)) or (cut_date<nrepay_date and  status in (select status from peizhibiao where id>=2)) 
;
quit;

proc sql;
create table ending_n_21 as
select due_nd,count(*) as e����_2,sum(�������) as e���_2 from data_ending1_n_a group by due_nd;
quit;
proc sql;
create table cycle_n_21 as
select a.due_nd,b.*,c.* from day as a
left join begining_n_21 as b on a.due_nd=b.due_nd
left join ending_n_21 as c on a.due_nd=c.due_nd;
quit;

data cycle_n_21;
set cycle_n_21;
array xx _numeric_;/**�����еı������б����xx��*/
do over xx;/**����xx*/
if xx=. then xx=0;/**���xx�к���.��ֵ����.���0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r6c15:r36c16";
data _null_;set cycle_n_21;file DD;put b����_2 e����_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r42c15:r72c16";
data _null_;set cycle_n_21;file DD;put b���_2 e���_2 ;run;

%let n = 0; /* initialize counter */ *ѭ����ʼʱ�����������;
/* Loop start */ 
%let clear = %sysfunc(mod(&n,100)); /* clear log every 100th occurrence*/ 
%if &clear = 0 %then %do; dm 'clear log'; dm 'clear output';%end; /* if you also want to clear output*/
/* Loop end */

%end;
%mend;
%yingyebu;
