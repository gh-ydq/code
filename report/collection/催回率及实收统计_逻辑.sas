
************
1-16号分配的客户都是跟进到月底最后一天截止，17-30号分配的客户是C-M1的客户了,有时候17号之后分配的C-M1的客户到下个月就变成了M1-M2了
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
set repayfin.payment_daily(where=(营业部^="APP"));
lag_od_days=lag(od_days);
by contract_no cut_date;
if first.contract_no then lag_od_days="";
run;

data mmlist;
set repayfin.test_lr_b;
if username in ("杜盼辉","洪高悬","张政嘉","廖翠玲","黄丽华","吴振杭","邱智超",'白璐','陈侃','陈天森','陈秀芬','黄晓妮');
if &dbpe.<=cut_date<=&db2.;
run;
proc sql;
create table mmlist_1_ as 
select a.*,b.od_days,b.lag_od_days,b.客户姓名,b.营业部,b.资金渠道,b.REPAY_DATE,e.od_days as od_days_yd,e.贷款余额,e.REPAY_DATE as REPAY_DATE_yd from mmlist as a
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
/*if username='邵辉辉111' then username='邵辉辉';*/
/*if username='赵婷燕111' then username='赵婷燕';*/
/*if username='张慧111' then username='张慧';*/
/*if username='杜娟111' then username='杜娟';*/
if 资金渠道 in ("xyd1","xyd2") then 资金渠道="小雨点";
	else if 资金渠道 in ("bhxt1","bhxt2") then 资金渠道="渤海信托";
	else if 资金渠道 in ("mindai1") then 资金渠道="民贷";
	else if 资金渠道 in ("ynxt1","ynxt2","ynxt3") then 资金渠道="云南信托";
	else if 资金渠道 in ("jrgc1") then 资金渠道="金融工厂";
	else if 资金渠道 in ("irongbei1") then 资金渠道="融贝";
	else if 资金渠道 in ("fotic3","fotic2") then 资金渠道="单一出借人";
	else if 资金渠道 in ("haxt1") then 资金渠道="华澳信托";
	else if 资金渠道 in ("p2p") then 资金渠道="中科财富";
	else if 资金渠道 in ("jsxj1") then 资金渠道="晋商消费金融";
	else if 资金渠道 in ("lanjingjr1") then 资金渠道="蓝鲸金融";
	else if 资金渠道 in ("yjh1","yjh2") then 资金渠道="益菁汇";
	else if 资金渠道 in ("rx1") then 资金渠道="容熙";
	else if 资金渠道 in ("hapx1") then 资金渠道="华澳鹏欣";
	else if 资金渠道 in ("tsjr1") then 资金渠道="通善金融";
if REPAY_DATE=. and od_days_yd=0 then REPAY_DATE=intnx('month',REPAY_DATE_yd,1,'s');*未匹配到数据且月底未逾期，那肯定是当月开始逾期了;
if REPAY_DATE=. then REPAY_DATE=REPAY_DATE_yd;
if 60>=od_days>30 then 阶段="M2-M3";
	else if 30>=od_days>15 and REPAY_DATE<&db. then 阶段="M1-M2";
	else if od_days=30 and od_days_yd=15 then 阶段="M1-M2";*逾期30天时repay_date刚好跳了一个月，导致阶段计算错误;
	else if 30>=od_days>15 and REPAY_DATE>=&db. then 阶段="C-M1";
	else if 15>=od_days>=0 then 阶段="0-15";
	else if 90>=od_days>60 then 阶段="M3-M4";
	else 阶段="M4+";
if 60>=od_days_yd>30 then 阶段2="M2-M3";
	else if 30>=od_days_yd>1 then 阶段2="M1-M2";
/*	else if od_days_yd=0 then 阶段2="C";*/
	else 阶段2='M4+';
run;
proc sort data=mmlist_2;by contract_no cut_date;run;
data mmlist_3;
set mmlist_2;
by contract_no;

if od_days_yd+day(&dt.)<=15 then delete;*部分数据月底即逾期，但是到当天都还没进入M1M2,月初时容易多计算这部分数据;
if contract_no in ('C2016102516341668488964','C2017101918274169730837','C2017081716382733250955','C2017121116521619518035') then delete;*已转给委外;
if username not in ('杜盼辉','洪高悬') and 阶段^="M1-M2" and 阶段2^="M1-M2" then delete;
if username in ('杜盼辉','洪高悬') and 阶段^="M2-M3" and 阶段2^="M2-M3" then delete;

if contract_no="C2018030511431804415577" then 阶段="M1-M2";

if first.contract_no then rank=1; *部分客户在分配当天即催还，算给坐席。后面有些客户催还后又进入C-M1，这部分客户删除。;
	else if username not in ('杜盼辉','洪高悬') and 阶段2="M1-M2" and 阶段 in ("0-15","C-M1") then delete;

run;
proc sort data=mmlist_3;by contract_no descending cut_date;run;
proc sort data=mmlist_3 out=mmlist_3 nodupkey;by contract_no 阶段;run;

data mmlist_3_;
set mmlist_3;
*还款时间按bill_main的clear_date，此处逻辑叫粗糙，直接用repay_date和contract_no拼;
if username in ('杜盼辉','洪高悬') and 阶段="M1-M2" then REPAY_DATE=intnx('month',REPAY_DATE,-1,'s');
if username in ('杜盼辉','洪高悬') and 阶段 in ("M2-M3","C-M1") then REPAY_DATE=intnx('month',REPAY_DATE,-2,'s');*M2M3的部分，催回一期继续逾期时会漏算催回的一期;
if username not in ('杜盼辉','洪高悬') and 阶段="M2-M3" then REPAY_DATE=intnx('month',REPAY_DATE,-1,'s');
if 阶段="M3-M4" then REPAY_DATE=intnx('month',REPAY_DATE,-2,'s');
if username not in ('杜盼辉','洪高悬') then  阶段="M1-M2";
if username in ('杜盼辉','洪高悬') then 阶段="M2-M3";
drop clear_date 阶段2 rank;
run;
proc sort data=mmlist_3_;by contract_no descending cut_date;run;
proc sort data=mmlist_3_ out=mmlist_3 nodupkey;by contract_no 阶段;run;

proc sql;
create table mmlist_3_2 as 
select a.*,b.催收员 from mmlist_3 as a
left join mmlist_3_1_a as b on a.contract_no=b.合同;
/*left join mmlist_3_1_a as c on a.contract_no=c.合同;*/
quit;


data mmlist_3;
set mmlist_3_2;
if 阶段="M2-M3" and 催收员="" then delete;
/*if 阶段="M1-M2" and 催收员^="" then userName=催收员;*/
run;

************************************************** 减免 ********************************************************************;
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
select contract_no,PERIOD,sum(BREAKS_AMOUNT) as 罚息减免 from fee_breaks_apply_dtl_ group by contract_no,PERIOD;
quit;
proc sql;
create table fee_breaks_jm_1_b as 
select a.*,b.clear_date from fee_breaks_jm_1_a as a 
left join account.bill_main(where=(substr(bill_code,1,3)="BLC")) as b on a.contract_no=b.contract_no and a.period=b.CURR_PERIOD;
quit;
proc sql;
create table fee_breaks_jm_1 as 
select contract_no,sum(罚息减免) as 罚息减免 
from fee_breaks_jm_1_b 
where &dbpe.<=clear_date<=&dt.
group by contract_no;
quit;
************************************************** 减免 ********************************************************************;
*由于存在不同时间催回两期这种情况，计算当月实际催回金额;

************下月初删除*************;
data account.bill_main;
set account.bill_main;
if ID=297880 THEN clear_date=mdy(02,28,2019);
run;
************下月初删除*************;

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
where &dbpe.<=clear_date<=&dt. and userName in ("杜盼辉","洪高悬","张政嘉","黄丽华","廖翠玲","吴振杭","邱智超",'白璐','陈侃','陈天森','陈秀芬','黄晓妮',"龙嘉苑")
group by contract_no;
quit;

data kanr;
set repayfin.kanr;
if 分配日期>=&db.;
run;
proc sql;
create table mmlist_4 as 
select a.*,d.clear_date,d.CURR_RECEIVE_AMT as 实际金额,c.罚息减免,b.ASSIGN_TIME as ASSIGN_TIME_adjust,b.username as user_adjust from mmlist_3 as a
left join bill_main_b as d on a.contract_no=d.contract_no 
left join fee_breaks_jm_1 as c on a.contract_no=c.contract_no
left join kanr as b on a.contract_no=b.contract_no and d.clear_date>=b.分配日期;
quit;
proc sort data=mmlist_4;by contract_no descending clear_date descending ASSIGN_TIME_adjust;run;
proc sort data=mmlist_4 nodupkey;by contract_no;run;
data mmlist_5;
set mmlist_4;
if username^=user_adjust and clear_date>0 and user_adjust in ("张玉萍","朱琨") then delete;
if 罚息减免=. then 罚息减免=0;
实际金额=实际金额-罚息减免;
/*if od_days-lag_od_days^=1 and lag_od_days>30 then clear_date=cut_date;*/
if clear_date>&dt. or clear_date<&db. then do;实际金额=0;clear_date=.;end;
if clear_date=. then 实际金额=.;
run;
proc sort data=mmlist_5;by descending clear_date 阶段 username;run;
*****************************外访 start********************************;
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
format 外访开始时间 yymmdd10.;
format 外访结束时间 yymmdd10.;
外访开始时间=datepart(VISIT_START_TIME);
外访结束时间=datepart(VISIT_END_TIME);
keep contract_no 外访开始时间 username 外访结束时间; 
run;
*****************************外访 end********************************;
****************************************************************************;
*判断是否有外访参与;
proc sql;
create table ctl_visit_mlist as 
select a.*,b.clear_date from ctl_visit as a
left join mmlist_5 as b on a.contract_no=b.contract_no;
quit;
data ctl_visit_mlist_1;
set ctl_visit_mlist;
if 外访开始时间<=clear_date<=外访结束时间 then 外访参与=1;else 外访参与=0;
run;
proc sort data=ctl_visit_mlist_1;by contract_no descending 外访参与;run;
proc sort data=ctl_visit_mlist_1 nodupkey;by contract_no;run;
****************************************************************************;
*案件在客服催回后仍然有可能会被错误的分配给坐席,此处通过客服回款前坐席时候有拨打客服电话判断是否由坐席催回;
data cs_table1_xx;
set repayfin.cs_table1_xx;
format 联系日期 yymmdd10.;
联系日期=datepart(CREATE_TIME);
if 联系日期>=&db.;
run;
proc sql;
create table cs_table_xx2 as 
select a.*,b.clear_date,b.username as 坐席 from cs_table1_xx  as a
left join mmlist_5 as b on a.contract_no=b.contract_no;
quit;
data cs_table_xx3;
set cs_table_xx2;
/*if username='邵辉辉111' then username='邵辉辉';*/
/*if username='赵婷燕111' then username='赵婷燕';*/
/*if username='张慧111' then username='张慧';*/
/*if username='杜娟111' then username='杜娟';*/
if clear_date>0;
if username=坐席 and 联系日期<=clear_date then 坐席催回=1;else 坐席催回=0;
run;
proc sort data=cs_table_xx3;by contract_no descending 坐席催回;run;
proc sort data=cs_table_xx3 nodupkey;by contract_no;run;
****************************************************************************;
proc sql;
create table mmlist_6 as 
select a.*,b.外访参与,c.坐席催回 from mmlist_5 as a
left join ctl_visit_mlist_1 as b on a.contract_no=b.contract_no
left join cs_table_xx3 as c on a.contract_no=c.contract_no;
quit;
proc sort data=mmlist_6;by contract_no username;run;
proc sort data=mmlist_6 nodupkey;by contract_no username;run;
proc sort data=mmlist_6;by descending clear_date 阶段 username;run;

data mmlist_7;
set mmlist_6;
/*if contract_no='C2017081515103764276653' then do;坐席催回=1;clear_date=mdy(10,14,2018);end;*/
/*if contract_no='C2016101815484678549280' then do;clear_date=mdy(10,8,2018);实际金额=2483.61;end;*晋商;*/
/*if contract_no='C2017101415331477390331' then do;clear_date=mdy(10,15,2018);实际金额=6093.91;end;*/
/*if clear_date>=分配日期 and 坐席催回=0 then delete;*/
if 外访参与=. then 外访参与=0;
if clear_date not in (0,.) then 催回余额=贷款余额;
	else if od_days-lag_od_days^=1 and lag_od_days>30 then 催回余额=贷款余额 ;
    else 催回余额=0;
if od_days-lag_od_days^=1 and lag_od_days>30 then clear_date=cut_date;
if 外访参与=1 and clear_date>1 then 催回余额外访=贷款余额/2;
	else if 外访参与=0 and clear_date>1 then 催回余额外访=贷款余额;
	else 催回余额外访=0;
if 外访参与=1 and 实际金额>1 then 实际金额外访=实际金额/2;
	else if 外访参与=0 and 实际金额>1 then 实际金额外访=实际金额;
if 实际金额=. then 实际金额=0;
/*if mdy(10,10,2018)<=clear_date<=mdy(10,14,2018) and 催收员^='' then username=催收员;*/

if contract_no in("C2016032316515183268193","C2016032309512968856213") then username="洪高悬";/*下月初删除*/
if contract_no in ("C2017051216070171982298","C2017121216390512535887") then delete;
if contract_no in("C2017061214022234204033","C2017111318210995171832") then username="黄丽华";/*下月初删除*/
if contract_no in ("C2017072409282969347060") then username= "杜盼辉";
if contract_no in ("C2018101811071864256893","C151374132017502300000965","C2018051113465839528017") then username = "白璐";
if contract_no in ("","C2017111715134926866458","C153959059889403000000112") then username ="陈天森";
if contract_no in ("C2017111418034600639956","C2018051415033324144130","C2017081713261569065078") then username ="陈秀芬";
if contract_no in ("C2018051518213216891040","C2017111613542169383878","C151375540674803000001026") then username ="黄晓妮";
if contract_no in ("C2017051513491486946130","C2017081515493080750126","C2017091216341745005596","C2017092017460743677108","C2016111612014526697963") then username="吴振杭";
if contract_no in ("C2017070511512389986625","C2017121815452362239106") then username = "张政嘉";
run;

proc sort data=mmlist_7;by descending clear_date 阶段 username;run;
proc sql;
create table mmlist_8_1 as 
select username,sum(贷款余额) as 贷款余额,sum(催回余额) as 催回余额,sum(催回余额外访) as 催回余额外访,sum(实际金额) as 实际金额,sum(实际金额外访) as 实际金额外访 from mmlist_7 where 阶段 in ('M1-M2','M2-M3') group by username;
quit;
proc sql;
create table mmlist_8_2 as 
select username,sum(催回余额) as 催回余额day,count(催回余额) as 催回数量day from mmlist_7 where clear_date=&dt. and 阶段 in ('M1-M2','M2-M3') group by username;
quit;
data _null_;
format dt yymmdd10.; 
dt = today() - 1;
call symput("dt", dt);
run;
proc sql;
create table mmlist_8_4 as 
select username,sum(催回余额) as 催回余额week,sum(催回余额外访) as 催回余额外访week from mmlist_7 where &weekf.<=clear_date<=&dt. and 阶段 in ('M1-M2','M2-M3') group by username;
quit;

proc sql;
create table mmlist_9 as 
select a.*,b.*,c.*,d.* from mmlist_8_3 as a
left join mmlist_8_2 as b on a.username=b.username
left join mmlist_8_1 as c on a.username=c.username
left join mmlist_8_4 as d on a.username=d.username;
quit;
proc sort data=mmlist_9;by 序号;run;
data mmlist_10;
set mmlist_9;
/*if username='张慧' then do;催回余额=催回余额-35999.266774;催回余额外访=催回余额外访-35999.266774;实际金额=实际金额-3304.44;实际金额外访=实际金额外访-3304.44;end;*/
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
array char _character_;
Do Over char;
If char=" " Then char='0';
End;
Run;
filename DD DDE "EXCEL|[催回率及实收统计.xlsx]report!r3c5:r14c8";
data _null_;set mmlist_10;file DD;put 催回余额day 催回数量day 贷款余额 催回余额;run;
filename DD DDE "EXCEL|[催回率及实收统计.xlsx]report!r3c10:r14c10";
data _null_;set mmlist_10;file DD;put 催回余额外访;run;
filename DD DDE "EXCEL|[催回率及实收统计.xlsx]report!r3c12:r14c14";
data _null_;set mmlist_10;file DD;put 实际金额 实际金额外访 催回余额week;run;
filename DD DDE "EXCEL|[催回率及实收统计.xlsx]report!r3c16:r14c16";
data _null_;set mmlist_10;file DD;put 催回余额外访week;run;

data aa;
set mmlist_7;
format clear_date yymmdd10.;
keep contract_no 阶段 客户姓名 营业部 资金渠道 贷款余额 username 外访参与 实际金额 clear_date;
run;
filename DD DDE "EXCEL|[催回率及实收统计.xlsx]明细!r2c1:r2000c10";
data _null_;set aa;file DD;put contract_no 阶段 客户姓名 营业部 资金渠道 贷款余额 username 外访参与 实际金额 clear_date;run;
