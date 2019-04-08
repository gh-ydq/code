/*option compress = yes validvarname = any;*/
/*libname account odbc datasrc=account_nf;*/
/*libname csdata odbc datasrc=csdata_nf;*/
/*libname res  'E:\guan\原数据\res';*/
/*libname approval 'E:\guan\原数据\approval';*/
/*libname mtd 'E:\guan\原数据\account';*/
/**/
/*x  "E:\guan\催收报表\逾期豁免\逾期1-15天应收罚息及豁免情况.xlsx"; */
/*x  "E:\guan\催收报表\逾期豁免\逾期16天以上应收罚息及豁免情况.xlsx"; */
/*x  "E:\guan\催收报表\逾期豁免\逾期应收罚息及豁免情况.xlsx"; */

data null;
format dt yymmdd10.;
dt=today()-1;
call symput("dt", dt);
run;
%let month="201904";*修改为本月月份;

/*小雨点回迁之前的数据在bill_main_xyd中,RECEIPT为已经还款的数据，RECEIVE包括所有已还未还数据*/
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
/*select a.*,b.罚息减免 from bill_main_xyd_a as a*/
/*left join fee_breaks_jm_1 as b on a.contract_no=b.contract_no and a.CURRENT_PERIOD=b.PERIOD;*/
/*quit;*/
/*proc sort data=bill_main_xyd_b;by descending clear_date;run;*/
data bill_main_xyd_c;
set bill_main_xyd_a;
offset_month=put(CLEAR_DATE,yymmn6.);
if RECEIPT>0;
rename RECEIPT=罚息 CURRENT_PERIOD=CURR_PERIOD CLEAR_DATE=offset_date;
keep contract_no CURRENT_PERIOD RECEIPT offset_month OVERDUE_DAYS CLEAR_DATE;
attrib _all_ label="";
run;

/*正常的数据在bill_fee_dtl中,正常和小雨点回迁的有个位数重复，此处直接保留罚息最大值*/
data bill_fee_dtl;
set mtd.bill_fee_dtl;
run;
data bill_fee_jm;
set bill_fee_dtl;
if fee_name in ("逾期违约金","逾期服务费");
if offset_date>0;
if offset_date<=&dt.;
offset_month=put(offset_date,yymmn6.);
if kindex(contract_no,"C");
run;
proc sql;
create table bill_fee_jm_1 as 
select a.contract_no,a.CURR_PERIOD,sum(a.CURR_RECEIPT_AMT) as 罚息,a.offset_month,a.offset_date,b.overdue_days from bill_fee_jm as a
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
proc sort data=bill_fee_jm_3 nodupkey;by contract_no CURR_PERIOD descending 罚息;run;
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

/*fee_breaks_apply_dtl有期款数据，比较好拼接，算明细
fee_breaks_apply_main无期数,ctl_apply_derate只有催收申请减免数据，无财务减免数据
罚息减免有部分数据偏大，有些是已经减免了但是期款却并没有还，有些是罚息表中部分数据异常（bill_fee_dtl没生成那么多罚息，但是此表却计算了）*/
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
/*select a.contract_no,b.PERIOD,sum(a.fee) as 罚息减免 from fee_breaks_jm as a*/
/*left join fee_breaks_apply_dtl_ as b on a.BREAKS_APPLY_CODE=b.BREAKS_APPLY_CODE*/
/*group by a.contract_no,b.PERIOD;*/
/*quit;*/
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
set csdata.ctl_apply_derate;
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

proc sql;
create table fee_breaks_jm_1 as 
select contract_no,PERIOD,sum(BREAKS_AMOUNT) as 罚息减免 from fee_breaks_apply_dtl_ group by contract_no,PERIOD;
quit;
proc sort data=fee_breaks_jm_1 nodupkey;by contract_no PERIOD;run;
proc sql;
create table fee_jm as 
select a.*,b.罚息减免,c.营业部,c.name,d.CREATE_NAME,d.REAMRK from bill_fee_jm_4 as a
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
实收罚息=罚息-罚息减免;
if overdue_days>15 then overdue='(15,+)';else overdue='[1,15]';
if 实收罚息<1 then do; 实收罚息=0;罚息减免=罚息;end;
if offset_month>0;
if offset_month=&month.;
豁免率=罚息减免/罚息;
run;
proc sort data=fee_jm_1 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_1;by descending offset_date;run;

proc sql;
create table fee_jm_1_1 as
select contract_no,sum(罚息减免) as 单合同减免金额 from fee_jm_1 group by contract_no;
quit;
proc sql;
create table fee_jm_1_2 as 
select a.*,b.单合同减免金额 from fee_jm_1 as a
left join fee_jm_1_1 as b on a.contract_no=b.contract_no;
quit;
proc sort data=fee_jm_1_2 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_1_2;by descending 单合同减免金额;run;
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]明细!r2c1:r30000c12';
data _null_;set fee_jm_1_2;file DD;put contract_no name CURR_PERIOD 营业部 罚息 罚息减免 实收罚息 豁免率 overdue_days offset_date CREATE_NAME REAMRK;run;
/*proc sql;*/
/*create table fee_jm_2 as*/
/*select offset_month,sum(罚息) as 罚息,sum(罚息减免) as 罚息减免,sum(实收罚息) as 实收罚息 from fee_jm_1 group by offset_month;*/
/*quit;*/
******************************************************* 1-15天明细及营业部汇总 *************************************************************************************;
data fee_jm_15;
set fee_jm_1;
if overdue='[1,15]';
run;
proc sql;
create table fee_jm_15_1 as
select contract_no,sum(罚息减免) as 单合同减免金额 from fee_jm_15 group by contract_no;
quit;
proc sql;
create table fee_jm_15_2 as 
select a.*,b.单合同减免金额 from fee_jm_15 as a
left join fee_jm_15_1 as b on a.contract_no=b.contract_no;
quit;
proc sort data=fee_jm_15_2 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_15_2;by descending 单合同减免金额;run;
filename DD DDE 'EXCEL|[逾期1-15天应收罚息及豁免情况.xlsx]明细!r2c1:r30000c12';
data _null_;set fee_jm_15_2;file DD;put contract_no name CURR_PERIOD 营业部 罚息 罚息减免 实收罚息 豁免率 overdue_days offset_date CREATE_NAME REAMRK;run;
proc sql;
create table fee_jm_15_3 as
select 营业部,sum(罚息) as 罚息,sum(罚息减免) as 罚息减免,sum(实收罚息) as 实收罚息 from fee_jm_15 group by 营业部;
quit;
proc sort data=fee_jm_15_3;by descending 罚息减免;run;
filename DD DDE 'EXCEL|[逾期1-15天应收罚息及豁免情况.xlsx]汇总!r4c1:r40c4';
data _null_;set fee_jm_15_3;file DD;put 营业部 罚息 罚息减免 实收罚息;run;
******************************************************* 16天以上明细及营业部汇总 *************************************************************************************;
data fee_jm_16;
set fee_jm_1;
if overdue='(15,+)';
run;
proc sql;
create table fee_jm_16_1 as
select contract_no,sum(罚息减免) as 单合同减免金额 from fee_jm_16 group by contract_no;
quit;
proc sql;
create table fee_jm_16_2 as 
select a.*,b.单合同减免金额 from fee_jm_16 as a
left join fee_jm_16_1 as b on a.contract_no=b.contract_no;
quit;
proc sort data=fee_jm_16_2 nodupkey;by contract_no CURR_PERIOD;run;
proc sort data=fee_jm_16_2;by descending 单合同减免金额;run;
filename DD DDE 'EXCEL|[逾期16天以上应收罚息及豁免情况.xlsx]明细!r2c1:r30000c12';
data _null_;set fee_jm_16_2;file DD;put contract_no name CURR_PERIOD 营业部 罚息 罚息减免 实收罚息 豁免率 overdue_days offset_date CREATE_NAME REAMRK;run;
proc sql;
create table fee_jm_16_3 as
select 营业部,sum(罚息) as 罚息,sum(罚息减免) as 罚息减免,sum(实收罚息) as 实收罚息 from fee_jm_16 group by 营业部;
quit;
proc sort data=fee_jm_16_3;by descending 罚息减免;run;
filename DD DDE 'EXCEL|[逾期16天以上应收罚息及豁免情况.xlsx]汇总!r4c1:r40c4';
data _null_;set fee_jm_16_3;file DD;put 营业部 罚息 罚息减免 实收罚息;run;
******************************************************* 营业部汇总 **************************************************************************************************;
proc sql;
create table fee_jm_1_3 as
select 营业部,sum(罚息) as 罚息,sum(罚息减免) as 罚息减免,sum(实收罚息) as 实收罚息 from fee_jm_1 group by 营业部;
quit;
proc sql;
create table fee_jm_1_4 as 
select a.*,b.罚息 as 罚息2,b.罚息减免 as 罚息减免2,b.实收罚息 as 实收罚息2,c.罚息 as 罚息3,c.罚息减免 as 罚息减免3,c.实收罚息 as 实收罚息3 from fee_jm_1_3 as a
left join fee_jm_15_3 as b on a.营业部=b.营业部
left join fee_jm_16_3 as c on a.营业部=c.营业部;
quit;
proc sort data=fee_jm_1_4;by descending 罚息减免;run;
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]汇总!r4c1:r40c4';
data _null_;set fee_jm_1_4;file DD;put 营业部 罚息 罚息减免 实收罚息;run;
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]汇总!r4c6:r40c8';
data _null_;set fee_jm_1_4;file DD;put 罚息2 罚息减免2 实收罚息2;run;
filename DD DDE 'EXCEL|[逾期应收罚息及豁免情况.xlsx]汇总!r4c10:r40c12';
data _null_;set fee_jm_1_4;file DD;put 罚息3 罚息减免3 实收罚息3;run;
