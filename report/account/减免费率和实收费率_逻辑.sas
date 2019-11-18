/*option compress = yes validvarname = any;*/
/*libname csdata 'E:\guan\原数据\csdata';*/
/*libname approval 'E:\guan\原数据\approval';*/
/*libname account 'E:\guan\原数据\account';*/
/*libname cred "E:\guan\原数据\cred";*/
/*libname mics "E:\guan\中间表\repayfin";*/
/*libname res "E:\guan\原数据\res";*/
/*libname yc 'E:\guan\中间表\yc';*/
/*libname repayfin "E:\guan\中间表\repayfin";*/
/*libname acco odbc datasrc=account_nf;*/
/*libname coll odbc datasrc=csdata_nf;*/
/**/
/*x  "E:\guan\催收报表\逾期豁免\逾期1-15天应收罚息及豁免情况.xlsx"; */
/*x  "E:\guan\催收报表\逾期豁免\逾期16天以上应收罚息及豁免情况.xlsx"; */
/*x  "E:\guan\催收报表\逾期豁免\逾期应收罚息及豁免情况.xlsx"; */

%let month="201911";*修改为本月月份;

data null;
format dt yymmdd10.;
dt=today()-1;
call symput("dt", dt);
run;
data apply_info;
set approval.apply_info(keep = apply_code name id_card_no branch_code branch_name DESIRED_PRODUCT);
	if branch_code = "6" then branch_name = "上海福州路营业部";
else if branch_code = "13" then branch_name = "上海福州路营业部";
else if branch_code = "16" then branch_name = "广州市林和西路营业部";
else if branch_code = "14" then branch_name = "合肥站前路营业部";
else if branch_code = "15" then branch_name = "福州五四路营业部";
else if branch_code = "17" then branch_name = "成都天府国际营业部";
else if branch_code = "50" then branch_name = "惠州第一营业部";
else if branch_code = "55" then branch_name = "海口市第一营业部";
else if branch_code = "57" then branch_name = "杭州建国北路营业部";
else if branch_code = "56" then branch_name = "厦门市第一营业部";
else if branch_code = "118" then branch_name = "邵阳市第一营业部";
else if branch_code = "65" then branch_name = "乌鲁木齐市第一营业部";
else if branch_code = "63" then branch_name = "赤峰市第一营业部";
else if branch_code = "60" then branch_name = "呼和浩特市第一营业部";
else if branch_code = "93" then branch_name = "泉州市第一营业部";
else if branch_code = "122" then branch_name = "郑州市第一营业部";
else if branch_code = "91" then branch_name = "天津市第一营业部";
else if branch_code = "90" then branch_name = "北京市第一营业部";
else if branch_code = "71" then branch_name = "怀化市第一营业部";
else if branch_code = "72" then branch_name = "昆明市第一营业部";
else if branch_code = "73" then branch_name = "重庆市第一营业部";
else if branch_code = "74" then branch_name = "南京市第一营业部";
else if branch_code = "75" then branch_name = "南宁市第一营业部";
else if branch_code = "89" then branch_name = "银川市第一营业部";
else if branch_code = "50" then branch_name = "惠州市第一营业部";
else if branch_code = "117" then branch_name = "盐城市业务中心";
else if branch_code = "116" then branch_name = "南通市业务中心";
else if branch_code = "114" then branch_name = "佛山业务中心";
else if branch_code = "115" then branch_name = "江门市业务中心";
else if branch_code = "119" then branch_name = "武汉市业务中心";
else if branch_code = "120" then branch_name = "红河市业务中心";
else if branch_code = "136" then branch_name = "佛山市第一营业部";

if kindex(branch_name,"深圳")  then branch_name="深圳市第一营业部";
else if kindex(branch_name,"江门") and kindex(branch_name,"业务中心") then branch_name="江门市业务中心";
else if kindex(branch_name,"佛山") then branch_name="佛山市第一营业部";
else if kindex(branch_name,"盐城") then branch_name="盐城市第一营业部";
else if kindex(branch_name,"湛江") then branch_name="湛江市第一营业部";
else if kindex(branch_name,"武汉") then branch_name="武汉市第一营业部";
else if kindex(branch_name,"红河") then branch_name="红河市第一营业部";
else if kindex(branch_name,"宁波") then branch_name="宁波市第一营业部";
else if kindex(branch_name,"贵阳") then branch_name="贵阳市第一营业部";
else if kindex(branch_name,"库尔勒") then branch_name="库尔勒市第一营业部";
else if kindex(branch_name,"汕头") then branch_name="汕头市第一营业部";
else if kindex(branch_name,"天津") then branch_name="天津市第一营业部";
else if kindex(branch_name,"兰州") then branch_name="兰州市第一营业部";

rename branch_name = 营业部;
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

*********************************************************************申请人姓名 start****************************************************************;
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
BR开头的减免申请单号的申请人和减免原因在fee_breaks_apply_dtl,
纯数字的减免申请单号的申请人和申请原因在ctl_apply_derate,此处申请单号并不唯一，故用合同号和申请单号和申请日期一起拼表
两种申请单号的业务区别暂时还不知道
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
*********************************************************************申请人姓名 end****************************************************************;
data payment_daily;
set repayfin.payment_daily;
if 营业部^="APP";
run;
proc sql;
create table bill_hm2 as 
select a.*,b.qigong,c.BREAKS_AMOUNT as amount,d.CREATE_NAME,d.REAMRK,f.营业部,f.客户姓名 as name,f.es
from bill_hm as a
left join repay_plan as b on a.contract_no=b.contract_no and a.CURR_PERIOD=b.CURR_PERIOD
left join fee_b2 as c on a.contract_no=c.contract_no and a.CURR_PERIOD=c.PERIOD
left join fee_breaks_apply_dtl_3 as d on a.contract_no=d.contract_no and a.CURR_PERIOD=d.PERIOD

left join payment_daily as f on a.contract_no=f.contract_no and cut_date=&dt.;
quit;
data bill_hm3;
set bill_hm2;
应收罚息=sum(CURR_RECEIPT_AMT,-qigong);
if es=1 then 应收罚息=amount;
if contract_no='C2017072016580644447297' then 应收罚息=amount;*提前结清金额会集中在还款当期，导致应收罚息计算太大;
if contract_no='C2018051415033324144130' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2017042115553351588604' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2016092617500740464740' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2017091514090396143858' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2017102711541825148769' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2017103117570387927819' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2018031917184999132507' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2016092211595980471090' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2016090611544346609938' then delete;*超长逾期客户，直接在某期结清;
if contract_no='C2018032313294342732282' then delete;*超长逾期客户，直接在某期结清;
if 应收罚息>1;
实收罚息=sum(应收罚息,-amount);
if 实收罚息<0.01 then 实收罚息=0;
豁免率=amount/罚息;
if month=&month.;
if OVERDUE_DAYS<=15 then 阶段='[1,15]';else 阶段='[16,+)';
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
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]明细!r2c1:r30000c12';
data _null_;set bill_hm3;file DD;put contract_no name CURR_PERIOD 营业部 应收罚息 amount 实收罚息 豁免率 阶段 clear_date CREATE_NAME REAMRK;run;
data bill_hm3_1;
set bill_hm3;
if 阶段='[1,15]';
run;
filename DD DDE 'EXCEL|[逾期1-15天应收罚息及豁免情况.xlsx]明细!r2c1:r30000c12';
data _null_;set bill_hm3_1;file DD;put contract_no name CURR_PERIOD 营业部 应收罚息 amount 实收罚息 豁免率 阶段 clear_date CREATE_NAME REAMRK;run;
data bill_hm3_2;
set bill_hm3;
if 阶段='[16,+)';
run;
filename DD DDE 'EXCEL|[逾期16天以上应收罚息及豁免情况.xlsx]明细!r2c1:r30000c12';
data _null_;set bill_hm3_2;file DD;put contract_no name CURR_PERIOD 营业部 应收罚息 amount 实收罚息 豁免率 阶段 clear_date CREATE_NAME REAMRK;run;

proc sql;
create table bill_hm4 as 
select 营业部,阶段,sum(应收罚息) as 应收罚息,sum(实收罚息) as 实收罚息,sum(amount) as 减免罚息 from bill_hm3 group by 营业部,阶段;
quit;
data bill_hm5_1;
set bill_hm4;
if 阶段='[1,15]';
run;
proc sort data=bill_hm5_1;by descending 应收罚息;run;
filename DD DDE 'EXCEL|[逾期1-15天应收罚息及豁免情况.xlsx]汇总!r4c1:r50c4';
data _null_;set bill_hm5_1;file DD;put 营业部 应收罚息 减免罚息 实收罚息;run;
data bill_hm5_2;
set bill_hm4;
if 阶段='[16,+)';
run;
proc sort data=bill_hm5_2;by descending 应收罚息;run;
filename DD DDE 'EXCEL|[逾期16天以上应收罚息及豁免情况.xlsx]汇总!r4c1:r50c4';
data _null_;set bill_hm5_2;file DD;put 营业部 应收罚息 减免罚息 实收罚息;run;
proc sql;
create table bill_hm5_0 as 
select 营业部,sum(应收罚息) as 应收罚息,sum(实收罚息) as 实收罚息,sum(amount) as 减免罚息 from bill_hm3 group by 营业部;
quit;
proc sql;
create table bill_hm5 as 
select a.*,b.应收罚息 as 应收罚息_A1,b.实收罚息 as 实收罚息_A1,b.减免罚息 as 减免罚息_A1,c.应收罚息 as 应收罚息_A2,c.实收罚息 as 实收罚息_A2,c.减免罚息 as 减免罚息_A2 from bill_hm5_0 as a
left join bill_hm5_1 as b on a.营业部=b.营业部
left join bill_hm5_2 as c on a.营业部=c.营业部;
quit;
proc sort data=bill_hm5;by descending 应收罚息;run;
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]汇总!r4c1:r50c4';
data _null_;set bill_hm5;file DD;put 营业部 应收罚息 减免罚息 实收罚息;run;
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]汇总!r4c6:r50c8';
data _null_;set bill_hm5;file DD;put 应收罚息_A1 减免罚息_A1 实收罚息_A1;run;
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]汇总!r4c10:r50c12';
data _null_;set bill_hm5;file DD;put 应收罚息_A2 减免罚息_A2 实收罚息_A2;run;
