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

***************************得到外包明细数据******************************************
只要是委外了，之后就算变成正常客户都是正常还款也都算是委外的业绩
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
format 外包开始日期 外包结束日期 yymmdd10.;
/*外包开始日期=datepart(OUTSOURCE_DATE);*/
外包开始日期=datepart(CREATE_TIME);
外包开始月份=put(外包开始日期,yymmn6.);
外包结束日期=datepart(OUTSOURCE_END_DATE);
外包结束月份=put(外包结束日期,yymmn6.);
drop OUTSOURCE_DATE OUTSOURCE_END_DATE;
run;
proc sort data=kan1a;by contract_no descending 外包结束日期;run;
data kan1a_;
set kan1a;
/*if id in ('18050400575128','18050200473056') then 外包结束日期=&dt.;*/
if (外包开始月份=&month. or &month.=外包结束月份 or 外包开始日期<=&dt.<=外包结束日期);
if OUTSOURCE_COMPANY_NAME='淮安云众鑫远信息技术有限公司' then OUTSOURCE_COMPANY_NAME='线下：淮安云众鑫远信息技术有限公司';
run;
proc sort data=kan1a_;by contract_no descending 外包结束日期;run;
proc sort data=kan1a_ nodupkey;by contract_no ;run;

***************************得到月初数据******************************************;
data payment_w;
set yc.payment;
run;
proc sort data=payment_w;by contract_no descending cut_date;run;
proc sort data=payment_w nodupkey;by contract_no;run;
***************************得到最近还款日期**************************************
只有含DR和ZW的才会进到账务系统里面，ZW表示划扣，DR表示对公
********************************************************;
data offset_info;
set account.offset_info;
run;
data offset_info_;
set offset_info;
if &db.<=OFFSET_DATE<=&dt.;
if kindex(OFFSET_SOURCE_NO,"ZW") then 划扣=1;else 划扣=0;
if kindex(OFFSET_SOURCE_NO,"CR") or kindex(OFFSET_SOURCE_NO,"ZW");
run;
proc sql;
create table offset_info_1 as 
select contract_no,sum(OFFSET_AMOUNT) as 对公金额,OFFSET_DATE as 对公日期,max(划扣) as 划扣 from offset_info_ group by contract_no;
quit;
proc sort data=offset_info_1;by contract_no descending 对公日期;run;
proc sort data=offset_info_1 nodupkey;by contract_no ;run;


proc sql;
create table outpayment_ as 
select a.*,b.clear_date,b.od_days,b.贷款余额_剩余本金部分 as REMAIN_CAPITAL,b.客户姓名,b.身份证号码,c.REMAIN_CAPITAL as REMAIN_CAPITAL_yc,c.营业部,d.对公金额,d.对公日期,d.划扣
from kan1a_ as a
left join repayfin.payment_daily(where=(cut_date=&dt.)) as b
on a.contract_no=b.contract_no
left join payment_w as c
on a.contract_no=c.contract_no
left join offset_info_1 as d 
on a.contract_no=d.contract_no;
quit;
**************************************
划扣以ZW开头，对公以DR开头
当剩余本金为0时，还款金额不为0，此时可视为结清
*************************************;
data outpayment;
set outpayment_;
if contract_no='C2018010813234622604169' then do;对公金额=38000;end;
if clear_date>=&db. or clear_date in (.,0) then 队列=1;else 队列=0;
if &db.<=clear_date<=&dt. then 催还=1;else 催还=0;
if REMAIN_CAPITAL_yc<REMAIN_CAPITAL then REMAIN_CAPITAL_yc=REMAIN_CAPITAL;
还款金额=REMAIN_CAPITAL_yc-REMAIN_CAPITAL;
if 还款金额>0 then 还款金额=对公金额; *是否结清通过贷款余额判定，结清金额暂时等于账务系统的还款金额即对公金额;
if REMAIN_CAPITAL>10 then 还款金额=0;
if 对公金额 in (0,.) then do; 对公金额=还款金额;end;
if 划扣=1 then 是否划扣=1;else 是否划扣=0;
if od_days=0 and clear_date not in (0,.) then od_days=OUTSOURCE_OVERDUEDAYS+intck("DAY",外包开始日期,clear_date);
if od_days=0 and clear_date in (0,.) then od_days=OUTSOURCE_OVERDUEDAYS+intck("DAY",外包开始日期,&dt.);
if 队列=1;
run;
**************************
部分对公数据或一些其他不知名数据会导致账务系统和offset_info表不一致，具体技术部怎么操作未知
**************************;
data outpayment;
set outpayment;
if OUTSOURCE_COMPANY_NAME='特殊客户' then delete;
if OUTSOURCE_COMPANY_NAME='委外公司' then OUTSOURCE_COMPANY_NAME='长沙银铠资产管理有限公司';
/*if OUTSOURCE_COMPANY_NAME='外访同事' and contract_no in ('C2016101919122555149104','C2017101218330205233310','C2017062317133256216041') then OUTSOURCE_COMPANY_NAME='长沙银铠资产管理有限公司';*/
if OUTSOURCE_COMPANY_NAME='外访同事' and (kindex(营业部,"广州") or kindex(营业部,"深圳") or kindex(营业部,"湛江") or kindex(营业部,"惠州") or kindex(营业部,"汕头") or kindex(营业部,"佛山"))  then OUTSOURCE_COMPANY_NAME='东莞市锐拓商务服务有限公司';
	else if OUTSOURCE_COMPANY_NAME='外访同事' and (kindex(营业部,"杭州") or kindex(营业部,"上海") or kindex(营业部,"南京") or kindex(营业部,"苏州") or kindex(营业部,"盐城") or kindex(营业部,"宁波"))  then OUTSOURCE_COMPANY_NAME='江苏君杰辉商务咨询有限公司';
	else if OUTSOURCE_COMPANY_NAME='外访同事' then OUTSOURCE_COMPANY_NAME='长沙银铠资产管理有限公司';
/*if 外包开始日期=外包结束日期 then delete;*/
/*if contract_no='C2016102609585327161697' then 对公金额=0;*回购;*/
/*if contract_no='C2017080417574190842814' then 对公金额=10000; */
/*这个委外的为前期委外后提前还款，现在不知道什么原因还算进来了;*/
/*if contract_no='C2017112712485307457620' then delete;*这个委外的不算;*/
/*if contract_no='C2018011816340033024249' then delete;*这个委外的不算;*/
/*if contract_no='C2016120114342357026874' then do; 对公金额=1382.72;对公日期=mdy(6,13,2018);end;*回购;*/
/*if contract_no='C2017032315381526190067' then 对公金额=74300;*回购;*/
run;
proc sort data=outpayment nodupkey;by contract_no;run;
proc sql; 
create table w_dl as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as 累计队列,sum(REMAIN_CAPITAL_yc) as 剩余本金,sum(还款金额) as 回款金额,sum(对公金额) as 对公金额
from outpayment as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl1 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as 累计队列1,sum(REMAIN_CAPITAL_yc) as 剩余本金1,sum(对公金额) as 回款金额1   
from outpayment(where=(0<=od_days<=180)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl2 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as 累计队列2,sum(REMAIN_CAPITAL_yc) as 剩余本金2,sum(对公金额) as 回款金额2     
from outpayment(where=(181<=od_days<=360)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl3 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as 累计队列3,sum(REMAIN_CAPITAL_yc) as 剩余本金3,sum(对公金额) as 回款金额3    
from outpayment(where=(361<=od_days<=720)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
proc sql; 
create table w_dl4 as
select a.OUTSOURCE_COMPANY_NAME,count(contract_no) as 累计队列4,sum(REMAIN_CAPITAL_yc) as 剩余本金4,sum(对公金额) as 回款金额4     
from outpayment(where=(721<=od_days)) as a group by OUTSOURCE_COMPANY_NAME;
quit;
*lableu来源于导入的配置表;
proc sql;
create table w_dl_sum_ as 
select a.*,b.累计队列1,b.剩余本金1,b.回款金额1,c.累计队列2,c.剩余本金2,c.回款金额2,d.累计队列3,d.剩余本金3,d.回款金额3,e.累计队列4,e.剩余本金4,e.回款金额4,f.序号
from w_dl as a
left join w_dl1 as b on a.OUTSOURCE_COMPANY_NAME=b.OUTSOURCE_COMPANY_NAME
left join w_dl2 as c on a.OUTSOURCE_COMPANY_NAME=c.OUTSOURCE_COMPANY_NAME
left join w_dl3 as d on a.OUTSOURCE_COMPANY_NAME=d.OUTSOURCE_COMPANY_NAME
left join w_dl4 as e on a.OUTSOURCE_COMPANY_NAME=e.OUTSOURCE_COMPANY_NAME
left join lableu as f on a.OUTSOURCE_COMPANY_NAME=f.OUTSOURCE_COMPANY_NAME
where a.OUTSOURCE_COMPANY_NAME in (select OUTSOURCE_COMPANY_NAME from lableu);
quit;
proc sort data=w_dl_sum_;by 序号;run;
data w_dl_sum;
set w_dl_sum_;
回款率=对公金额/剩余本金;
回款率1=回款金额1/剩余本金1;
回款率2=回款金额2/剩余本金2;
回款率3=回款金额3/剩余本金3;
回款率4=回款金额4/剩余本金4;
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

filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r4c3:r12c7";
data _null_;set w_dl_sum;file DD;put 累计队列 剩余本金 回款金额 对公金额 回款率;run;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r4c8:r12c11";
data _null_;set w_dl_sum;file DD;put 回款率1 回款率2 回款率3 回款率4;run;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r4c12:r12c15";
data _null_;set w_dl_sum;file DD;put 累计队列1 累计队列2 累计队列3 累计队列4 ;run;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r4c16:r12c19";
data _null_;set w_dl_sum;file DD;put 剩余本金1 剩余本金2 剩余本金3 剩余本金4;run;

proc sql;
create table w_dl_hksum as 
select sum(对公金额)/sum(剩余本金) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r3c7:r3c7";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(回款金额1)/sum(剩余本金1) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r3c8:r3c8";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(回款金额2)/sum(剩余本金2) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r3c9:r3c9";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(回款金额3)/sum(剩余本金3) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r3c10:r3c10";
data _null_;set w_dl_hksum;file DD;put hkl;run;
proc sql;
create table w_dl_hksum as 
select sum(回款金额4)/sum(剩余本金4) as hkl from w_dl_sum;
quit;
filename DD DDE "EXCEL|[委外回款日报.xlsx]委外!r3c11:r3c11";
data _null_;set w_dl_hksum;file DD;put hkl;run;

data w_detail;
set outpayment;
if 对公金额>0;
身份证=substr(身份证号码,1,13) || "****";
if 还款金额>0 then 结清=1;else 结清=0;
run;
filename DD DDE "EXCEL|[委外回款日报.xlsx]回款明细!r2c1:r100c10";
data _null_;set w_detail;file DD;put 外包开始日期 contract_no 身份证 客户姓名 对公日期  对公金额 结清 是否划扣 od_days OUTSOURCE_COMPANY_NAME;run;
