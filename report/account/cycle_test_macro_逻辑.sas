*由于excel-vba一些清除格式的需求处理时间较长，一开始就打开excel;
/*x  "E:\guan\日监控临时报表\cycle\Cycle_End_Delinquent.xlsm"; */
/**/
/**/
/*option compress = yes validvarname = any;*/
/*libname ss "E:\guan\中间表\repayfin\历史数据\201903";*新的一月需修改*;*/
/*libname ss1 "E:\guan\中间表\repayfin";*/
/*libname account "E:\guan\原数据\account";*/

*%include不能跑input的数据步，故把其提到前面;
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
/*1	上海福州路营业部*/
/*2	合肥站前路营业部*/
/*3	苏州市第一营业部*/
/*4	盐城市第一营业部*/
/*5	杭州建国北路营业部*/
/*6	福州五四路营业部*/
/*7	厦门市第一营业部*/
/*8	宁波市第一营业部*/
/*9	怀化市第一营业部*/
/*10	邵阳市第一营业部*/
/*11	郑州市第一营业部*/
/*12	广州市林和西路营业部*/
/*13	惠州第一营业部*/
/*14	南宁市第一营业部*/
/*15	深圳市第一营业部*/
/*16	汕头市第一营业部*/
/*17	海口市第一营业部*/
/*18	佛山市第一营业部*/
/*19	湛江市第一营业部*/
/*20	南京市第一营业部*/
/*21	呼和浩特市第一营业部*/
/*22	赤峰市第一营业部*/
/*23	北京市第一营业部*/
/*24	天津市第一营业部*/
/*25	成都天府国际营业部*/
/*26	昆明市第一营业部*/
/*27	武汉市第一营业部*/
/*28	红河市第一营业部*/
/*29	贵阳市第一营业部*/
/*30	乌鲁木齐市第一营业部*/
/*31	银川市第一营业部*/
/*32	伊犁市第一营业部*/
/*33	库尔勒市第一营业部*/
/*34	兰州市第一营业部*/
/*35	重庆市第一营业部*/
/*36	江门市业务中心*/
/*37	南通市业务中心*/
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

%let llastmonth="201908";*新的一月需修改*;
%let lastmonth="201909";*新的一月需修改*;
%let nowmonth="2019010";*新的一月需修改*;
%let nextwmonth="201911";*新的一月需修改*;

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

*song:ss.Payment_daily是上个月月底跑完的payment_daily;
data sdata;
set ss.Payment_daily(where=(cut_date^=&llast_month_end.)) 
    ss1.Payment_daily(where=(cut_date^=&last_month_end.));
if 营业部^="APP";
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

*-------------------------------------由于一些快结清的客户在repay_date上面会出现错位，一些刚放款的没问题，因此加入下面的修正----------------------*;
*快结清的如果不弄，那个lag会用其他客户的合同编号的repay_date的due day;

*去掉提前结清;
proc sort data=account.bill_main out=bill_main ;by contract_no  ID ;run;
proc sort data=bill_main nodupkey ;by contract_no CURR_PERIOD;run;

*找出最后一期账单;
proc sort data=bill_main  ;by contract_no descending CURR_PERIOD;run;
proc sort data=bill_main nodupkey out=bill_last(keep =contract_no CURR_PERIOD)  ;by contract_no;run;

proc sql;
create table aaa1 as 
select contract_no,count(*) as 数量
from repayd 
group by contract_no;
quit;
proc sql;
create table aaa2 as 
select a.*,b.CURR_PERIOD as  期数,c.数量
from repayd as a
left join bill_last as b on a.contract_no=b.contract_no
left join aaa1 as c on a.contract_no=c.contract_no;
quit;


data aaa3 ;
set aaa2;
if 数量<3 and CURR_PERIOD=期数;
run;

*拼一条2次;
data aaa4;
set aaa2;
if 数量=1 and CURR_PERIOD=期数 ;
if 数量=1 and CURR_PERIOD=期数 then REPAY_DATE="";
run;


*拼一条1次;
data aaa5;
set aaa2;
if 数量=2 and CURR_PERIOD=期数 ;
if 数量=2 and CURR_PERIOD=期数 then REPAY_DATE="";
run;

data repayd;
set aaa2 aaa4 aaa4 aaa5;
drop 数量 期数;
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
set payment1(keep=contract_no es 放款日期 营业部 客户姓名 month od_periods od_days  status_p 贷款余额 nextmonth_repay_date  nowmonth_repay_date lastmonth_repay_date  cut_date 还款_当日扣款失败合同 还款_当日应扣款合同 repay_date);
due_pd=day(lastmonth_repay_date);
due_nd=day(nowmonth_repay_date);
format loan_date yymmdd10.;
loan_date=mdy(scan(放款日期,2,"-"), scan(放款日期,3,"-"),scan(放款日期,1,"-"));
/*a=intnx("month",loan_date,1,"s");*/
format status $24.;
if es = 1 then status = "09_ES";
else if cut_date<intnx("month",loan_date,1,"s") then status="00_NB";
else if od_days=0 and 还款_当日扣款失败合同^=1  then status="01_C";
else if od_days=0 and 还款_当日扣款失败合同=1  then status="02_M1_1";
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
*M2及以上的状态，直接用刚进入该状态的逾期天数来判断其首次进入该状态，用对应的cut_date作为进入该状态的日期;
if status = "03_M2" and od_days=31 then begin_label=1;
if status = "04_M3" and od_days=61 then begin_label=1;
if status = "05_M4" and od_days=91 then begin_label=1;
if status = "06_M5" and od_days=121 then begin_label=1;
if status = "07_M6" and od_days=151 then begin_label=1;
if due_pd=. then due_pd=day(repay_date);*部分逾期期数超过其剩余应还期数的合同号due_pd会变成空;
if due_nd=. then due_nd=day(repay_date);
if status in ("03_M2","04_M3","05_M4","06_M5","07_M6", "08_M6+") then do;due_pd=day(cut_date);due_nd=day(cut_date);end;
if nextmonth_repay_date=. and nowmonth_repay_date^=. then nextmonth_repay_date=intnx('month',nowmonth_repay_date,1);*nextmonth_repay_date为空时，最后一期逾期1-30的ending得不到数据;
run;

*当上月底是31号周期，将30改成31;
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
call symput("day",day);*定义一个宏，上月账单结束的周期;
call symput("day0",day0);*定义一个宏,上月账单开始的周期;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*定义一个宏,上月账单开始的周期;
call symput("DDE2",COMPRESS(DDE2));*定义一个宏,上月账单开始的周期;
run;

*不含回滚;
%if &i.>4 %then %do;
*M2及以后的数据用上面定义的begin_label作为其首次进入的标志;
proc sql;
create table data_begining as 
select * from payment2 
where begin_label=1 and status in (select status from peizhibiao where id=&i.)  and es^=1 and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
proc sort data=data_begining;by contract_no cut_date;run;
proc sort data=data_begining nodupkey;by contract_no;run;
%end;
%else %do;
*M2以前的数据暂时没发现问题，先保留该逻辑。M2后的数据因为每月天数不一样，粗略的用账单日来套用会出现到该账单日时逾期状态还是同上个月状态;
proc sql;
create table data_begining as 
select * from payment2 
where cut_date=lastmonth_repay_date+&day0. and status in (select status from peizhibiao where id=&i.)  and es^=1 and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
%end;

proc sql;
create table begining_&i. as
select due_pd,count(*) as b个数_&i. from data_begining group by due_pd;
quit;

proc sql;
create table begining_m_&i. as
select due_pd,sum(贷款余额) as b金额_&i. from data_begining group by due_pd;
quit;

%if &i.>4 %then %do;
*M2及以后的状态用了cut_date的日期，故此处要拼begining的日期，否则日期会乱。ending的状态则直接看30天后的状态。;
proc sql;
create table data_ending as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
select due_pd,count(*) as e个数_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table ending_m_&i. as
select due_pd,sum(贷款余额) as e金额_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table cycle_&i. as
select a.due_pd,b.*,c.* from day as a
left join begining_&i. as b on a.due_pd=b.due_pd
left join ending_&i. as c on a.due_pd=c.due_pd;
quit;

data cycle_&i.;
set cycle_&i.;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
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
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_&i.;file DD;put b个数_&i. e个数_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_m_&i.;file DD;put b金额_&i. e金额_&i. ;run;


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
call symput("day_n",day_n);*定义一个宏，上月账单结束的周期;
call symput("day0_n",day0_n);*定义一个宏,上月账单开始的周期;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*定义一个宏,上月账单开始的周期;
call symput("DDE2",COMPRESS(DDE2));*定义一个宏,上月账单开始的周期;
run;


*不含回滚;
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
select due_nd,count(*) as b个数_&i. from data_begining_n group by due_nd;
quit;

proc sql;
create table begining_n_m_&i. as
select due_nd,sum(贷款余额) as b金额_&i. from data_begining_n group by due_nd;
quit;

%if &i.>4 %then %do;
proc sql;
create table data_ending_n as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
*这里对i=3的单独做处理是因为last的流程会走完，但是now的在1号前期的时候cut_date流程没走完到16ending所以i=3的改成8;
proc sql;
create table data_ending_n as
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,贷款余额,
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
select due_nd,count(*) as e个数_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table ending_n_m_&i. as
select due_nd,sum(贷款余额) as e金额_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table cycle_n_&i. as
select a.due_nd,b.*,c.* from day as a
left join begining_n_&i. as b on a.due_nd=b.due_nd
left join ending_n_&i. as c on a.due_nd=c.due_nd;
quit;

data cycle_n_&i.;
set cycle_n_&i.;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
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
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_n_&i.;file DD;put b个数_&i. e个数_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_n_m_&i.;file DD;put b金额_&i. e金额_&i. ;run;


%end;
%mend;
%cycle_n;

*写完以上后，领导要求新增扣款成功率及M1汇总情况，由于M1情况汇总的话status要改，上面的宏不能用，所以将其单独拎出来;
*应老板需求,将当天扣款的贷款余额追溯到上一天待扣款前一天的贷款余额,就是当期期供未扣款的贷款余额;

proc sql;
create table payment2_ as 
select a.*,b.贷款余额 as 上上月底贷款余额
from payment2 as a 
left join ss1.payment_g(where=(month=&llastmonth.)) as b 
on a.contract_no=b.contract_no;
quit;
proc sort data=payment2_;by contract_no cut_date;run;

data payment2_a;
set payment2_;
前一天贷款余额=lag(贷款余额);
by contract_no cut_date;
if first.contract_no then do;前一天贷款余额=上上月底贷款余额;end;
if  还款_当日应扣款合同=1 then 贷款余额=前一天贷款余额;
run;

proc sql;
create table n_repay_l as 
select month,due_pd,sum(还款_当日应扣款合同) as 分母,sum(贷款余额) as 分母1,sum(上上月底贷款余额) as test
from payment2_a
where month=&lastmonth. and due_pd>0  and 还款_当日应扣款合同=1 and es^=1 and status_p not in ("09_ES","11_Settled")
group by month,due_pd;
quit;

data n_repay_l;
set n_repay_l;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r6c3:r36c3";
data _null_;set n_repay_l;file DD;put 分母 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r42c3:r72c3";
data _null_;set n_repay_l;file DD;put 分母1 ;run;

proc sql;
create table n_repay_n as 
select month,due_nd,sum(还款_当日应扣款合同) as 分母,sum(贷款余额) as 分母1
from payment2_a
where month=&nowmonth. and 0<due_nd<=intck("day",&month_begin.,today()) and 还款_当日应扣款合同=1 and es^=1 and status_p not in ("09_ES","11_Settled")
group by month,due_nd;
quit;

data n_repay_n;
set n_repay_n;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r6c3:r36c3";
data _null_;set n_repay_n;file DD;put 分母 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r42c3:r72c3";
data _null_;set n_repay_n;file DD;put 分母1 ;run;


*做M1汇总情况;
*上月;
proc sql;
create table data_begining1 as 
select * from payment2 
where cut_date=lastmonth_repay_date and status in (select status from peizhibiao where id=2)  and month=&lastmonth. and es^=1;
quit;

proc sql;
create table begining_21 as
select due_pd,count(*) as b个数_2,sum(贷款余额) as b金额_2 from data_begining1 group by due_pd;
quit;

proc sql;
create table data_ending1 as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
select due_pd,count(*) as e个数_2,sum(贷款余额) as e金额_2 from data_ending1_a group by due_pd;
quit;
proc sql;
create table cycle_21 as
select a.due_pd,b.*,c.* from day as a
left join begining_21 as b on a.due_pd=b.due_pd
left join ending_21 as c on a.due_pd=c.due_pd;
quit;

data cycle_21;
set cycle_21;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r6c15:r36c16";
data _null_;set cycle_21;file DD;put b个数_2 e个数_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]last_month_cycle!r42c15:r72c16";
data _null_;set cycle_21;file DD;put b金额_2 e金额_2 ;run;

*本月;
proc sql;
create table data_begining1_n as 
select * from payment2 
where  cut_date=nowmonth_repay_date and status in (select status from peizhibiao where id=2) and month=&nowmonth. and es^=1;
quit;
proc sql;
create table begining_n_21 as
select due_nd,count(*) as b个数_2,sum(贷款余额) as b金额_2 from data_begining1_n group by due_nd;
quit;
proc sql;
create table data_ending1_n as
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,贷款余额,
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
select due_nd,count(*) as e个数_2,sum(贷款余额) as e金额_2 from data_ending1_n_a group by due_nd;
quit;
proc sql;
create table cycle_n_21 as
select a.due_nd,b.*,c.* from day as a
left join begining_n_21 as b on a.due_nd=b.due_nd
left join ending_n_21 as c on a.due_nd=c.due_nd;
quit;

data cycle_n_21;
set cycle_n_21;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r6c15:r36c16";
data _null_;set cycle_n_21;file DD;put b个数_2 e个数_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]now_month_cycle!r42c15:r72c16";
data _null_;set cycle_n_21;file DD;put b金额_2 e金额_2 ;run;

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
call symput("day",day);*定义一个宏，上月账单结束的周期;
call symput("day0",day0);*定义一个宏,上月账单开始的周期;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*定义一个宏,上月账单开始的周期;
call symput("DDE2",COMPRESS(DDE2));*定义一个宏,上月账单开始的周期;
run;

*不含回滚;
%if &i.>4 %then %do;
proc sql;
create table data_begining as 
select * from payment2 
where begin_label=1 and status in (select status from peizhibiao where id=&i.) and 营业部="&branch_name." and es^=1   and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
proc sort data=data_begining;by contract_no cut_date;run;
proc sort data=data_begining nodupkey;by contract_no;run;
%end;
%else %do;
proc sql;
create table data_begining as 
select * from payment2 
where cut_date=lastmonth_repay_date+&day0. and status in (select status from peizhibiao where id=&i.) and 营业部="&branch_name." and es^=1   and &last_month_begin.+&day0.<=cut_date<=&last_month_end.+&day0.;
quit;
%end;

proc sql;
create table begining_&i. as
select due_pd,count(*) as b个数_&i. from data_begining group by due_pd;
quit;

proc sql;
create table begining_m_&i. as
select due_pd,sum(贷款余额) as b金额_&i. from data_begining group by due_pd;
quit;

%if &i.>4 %then %do;
proc sql;
create table data_ending as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
select due_pd,count(*) as e个数_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table ending_m_&i. as
select due_pd,sum(贷款余额) as e金额_&i. from data_ending_a group by due_pd;
quit;

proc sql;
create table cycle_&i. as
select a.due_pd,b.*,c.* from day as a
left join begining_&i. as b on a.due_pd=b.due_pd
left join ending_&i. as c on a.due_pd=c.due_pd;
quit;

data cycle_&i.;
set cycle_&i.;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
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
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_&i.;file DD;put b个数_&i. e个数_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_m_&i.;file DD;put b金额_&i. e金额_&i. ;run;


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
call symput("day_n",day_n);*定义一个宏，上月账单结束的周期;
call symput("day0_n",day0_n);*定义一个宏,上月账单开始的周期;
call symput("i",id);
call symput("DD",DD);
run;

data aa_&i._;
set aa_&i.;
DD=&DD.+&i.;
format DDE1 $8. DDE2 $8.;
DDE1=put(&DD.+&i.,$8.);
DDE2=put(&DD.+&i.+1,$8.);
call symput("DDE1",COMPRESS(DDE1));*定义一个宏,上月账单开始的周期;
call symput("DDE2",COMPRESS(DDE2));*定义一个宏,上月账单开始的周期;
run;


*不含回滚;
%if &i.>4 %then %do;
proc sql;
create table data_begining_n as 
select * from payment2 
where begin_label=1 and status in (select status from peizhibiao where id=&i.)  and &month_begin.+&day0_n.<=cut_date<=&month_end.+&day0_n. and 营业部="&branch_name." and es^=1;
quit;
proc sort data=data_begining_n;by contract_no cut_date;run;
proc sort data=data_begining_n nodupkey;by contract_no;run;
%end;
%else %do;
proc sql;
create table data_begining_n as 
select * from payment2 
where cut_date=nowmonth_repay_date+&day0_n. and status in (select status from peizhibiao where id=&i.)  and &month_begin.+&day0_n.<=cut_date<=&month_end.+&day0_n. and 营业部="&branch_name." and es^=1;
quit;
%end;

proc sql;
create table begining_n_&i. as
select due_nd,count(*) as b个数_&i. from data_begining_n group by due_nd;
quit;

proc sql;
create table begining_n_m_&i. as
select due_nd,sum(贷款余额) as b金额_&i. from data_begining_n group by due_nd;
quit;

%if &i.>4 %then %do;
proc sql;
create table data_ending_n as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,贷款余额,
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
select due_nd,count(*) as e个数_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table ending_n_m_&i. as
select due_nd,sum(贷款余额) as e金额_&i. from data_ending_n_a group by due_nd;
quit;

proc sql;
create table cycle_n_&i. as
select a.due_nd,b.*,c.* from day as a
left join begining_n_&i. as b on a.due_nd=b.due_nd
left join ending_n_&i. as c on a.due_nd=c.due_nd;
quit;

data cycle_n_&i.;
set cycle_n_&i.;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
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
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r6c&DDE1.:r36c&DDE2.";
data _null_;set cycle_n_&i.;file DD;put b个数_&i. e个数_&i. ;run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r42c&DDE1.:r72c&DDE2.";
data _null_;set cycle_n_m_&i.;file DD;put b金额_&i. e金额_&i. ;run;


%end;
%mend;
%cycle_n;

*写完以上后，领导要求新增扣款成功率及M1汇总情况，由于M1情况汇总的话status要改，上面的宏不能用，所以将其单独拎出来;
proc sql;
create table n_repay_l as 
select month,due_pd,sum(还款_当日应扣款合同) as 分母,sum(贷款余额) as 分母1
from payment2
where month=&lastmonth. and due_pd>0  and 还款_当日应扣款合同=1 and 营业部="&branch_name." and es^=1
group by month,due_pd;
quit;

data n_repay_l;
set n_repay_l;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r6c3:r36c3";
data _null_;set n_repay_l;file DD;put 分母 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r42c3:r72c3";
data _null_;set n_repay_l;file DD;put 分母1 ;run;

proc sql;
create table n_repay_n as 
select month,due_nd,sum(还款_当日应扣款合同) as 分母,sum(贷款余额) as 分母1
from payment2
where month=&nowmonth. and 0<due_nd<=intck("day",&month_begin.,today()) and 还款_当日应扣款合同=1 and 营业部="&branch_name." and es^=1
group by month,due_nd;
quit;

data n_repay_n;
set n_repay_n;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r6c3:r36c3";
data _null_;set n_repay_n;file DD;put 分母 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r42c3:r72c3";
data _null_;set n_repay_n;file DD;put 分母1 ;run;


*做M1汇总情况;
*上月;
proc sql;
create table data_begining1 as 
select * from payment2 
where cut_date=lastmonth_repay_date and status in (select status from peizhibiao where id=2) and 营业部="&branch_name." and es^=1   and  month=&lastmonth. ;
quit;

proc sql;
create table begining_21 as
select due_pd,count(*) as b个数_2,sum(贷款余额) as b金额_2 from data_begining1 group by due_pd;
quit;

proc sql;
create table data_ending1 as
select contract_no,cut_date,nowmonth_repay_date,lastmonth_repay_date,贷款余额,
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
select due_pd,count(*) as e个数_2,sum(贷款余额) as e金额_2 from data_ending1_a group by due_pd;
quit;
proc sql;
create table cycle_21 as
select a.due_pd,b.*,c.* from day as a
left join begining_21 as b on a.due_pd=b.due_pd
left join ending_21 as c on a.due_pd=c.due_pd;
quit;

data cycle_21;
set cycle_21;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r6c15:r36c16";
data _null_;set cycle_21;file DD;put b个数_2 e个数_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_last&branch_name.!r42c15:r72c16";
data _null_;set cycle_21;file DD;put b金额_2 e金额_2 ;run;

*本月;
proc sql;
create table data_begining1_n as 
select * from payment2 
where  cut_date=nowmonth_repay_date and status in (select status from peizhibiao where id=2) and  month=&nowmonth.  and 营业部="&branch_name." and es^=1;
quit;
proc sql;
create table begining_n_21 as
select due_nd,count(*) as b个数_2,sum(贷款余额) as b金额_2 from data_begining1_n group by due_nd;
quit;
proc sql;
create table data_ending1_n as
select contract_no,cut_date,nowmonth_repay_date,nextmonth_repay_date,贷款余额,
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
select due_nd,count(*) as e个数_2,sum(贷款余额) as e金额_2 from data_ending1_n_a group by due_nd;
quit;
proc sql;
create table cycle_n_21 as
select a.due_nd,b.*,c.* from day as a
left join begining_n_21 as b on a.due_nd=b.due_nd
left join ending_n_21 as c on a.due_nd=c.due_nd;
quit;

data cycle_n_21;
set cycle_n_21;
array xx _numeric_;/**把所有的变量名列表放入xx中*/
do over xx;/**遍历xx*/
if xx=. then xx=0;/**如果xx中含有.的值，把.变成0*/
end;
run;

filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r6c15:r36c16";
data _null_;set cycle_n_21;file DD;put b个数_2 e个数_2 ;run;
filename DD DDE "EXCEL|[Cycle_End_Delinquent.xlsm]_now&branch_name.!r42c15:r72c16";
data _null_;set cycle_n_21;file DD;put b金额_2 e金额_2 ;run;

%let n = 0; /* initialize counter */ *循环开始时加上下面代码;
/* Loop start */ 
%let clear = %sysfunc(mod(&n,100)); /* clear log every 100th occurrence*/ 
%if &clear = 0 %then %do; dm 'clear log'; dm 'clear output';%end; /* if you also want to clear output*/
/* Loop end */

%end;
%mend;
%yingyebu;
