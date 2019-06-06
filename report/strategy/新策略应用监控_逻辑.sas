/*option compress = yes validvarname = any;*/
/*libname csdata 'E:\guan\原数据\csdata';*/
/*libname approval 'E:\guan\原数据\approval';*/
/*libname account 'E:\guan\原数据\account';*/
/*libname cred "E:\guan\原数据\cred";*/
/*libname mics "E:\guan\中间表\repayfin";*/
/*libname res "E:\guan\原数据\res";*/
/*libname yc 'E:\guan\中间表\yc';*/
/*libname repayfin "E:\guan\中间表\repayfin";*/
/*libname urule odbc datasrc=urule_nf;*/
/*libname appr odbc datasrc=approval_nf;*/
/**/
/*x 'E:\guan\策略监控\新模型—电话邦命中情况.xlsx';*/


data _null_;
format dt first_month yymmdd10.;
dt = today() - 1;
db=intnx('month',dt,0,'b');
nd = dt-db;
first_month=mdy(11,1,2018);
due_month=intck("month",first_month,dt)+11;
call symput("nd", nd);
call symput("dt", dt);
call symput("db", db);
call symput('due_month',due_month);
run;
data date;
format date  yymmdd10. prime_key ;
 n=today()-mdy(11,1,2018);
/* n=intnx("year",&nt.,12,"same")-&start_date.;*/
do i=1 to n;
date=intnx("day",mdy(11,1,2018),i-1);
output;
end;
drop i;
run;
***
B18 工作地
B19 休息地
code是代码，DESC是结果
代码 解释(公里)
01 （0,2]
02  (2,5]
03  (5,10] 
04  10公里以上，但在同一个城市
05  不在同一个城市
99  手机号T-1月前已离网
***;
data apply_identity_match_tq;
set approval.apply_identity_match;
if channel="TQ";
if type="BLACK";
run;
data apply_identity_match;
set approval.apply_identity_match;
if channel="TJ";;
run;
/*data aa;*/
/*set apply_identity_match;*/
/*if value=1;*/
/*run;*/
data apply_refusecancel_history;
set approval.apply_refusecancel_history;
if reason_info_code3='R754';
run;
data early_warning_info;
set appr.early_warning_info;
run;
proc sql;
create table early_warning_info_ as
select * from early_warning_info where SOURCE='urule' and LEVEL='R' and CONTENT like '2%';
quit;
data dianhua_derived_data;
set cred.dianhua_derived_data;
run;
proc sort data=dianhua_derived_data;by descending id;run;
proc sort data=dianhua_derived_data nodupkey;by mobile;run;
/*proc sql;*/
/*create table apply_info as */
/*select a.apply_code,a.CREATED_TIME,b.PHONE1,c.call_tel_total_nums from approval.apply_info as a*/
/*left join approval.apply_base as b on a.apply_code=b.apply_code*/
/*left join cred.dianhua_derived_data as c on b.PHONE1=c.mobile;*/
/*quit;*/
/*data apply_info_;*/
/*set apply_info;*/
/*DATE=datepart(CREATED_TIME);*/
/*run;*/
/*proc sort data=apply_info_;by descending DATE;run;*/
/*proc sort data=apply_info_ out=apply_info;by apply_code;run;*/
*【营业部】;
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
format date yymmdd10.;
date=datepart(CREATED_TIME);
进件月份= put(DATE, yymmn6.);
run;
*【进件】;
/*以首次录入复核完成时间作为进件时间*/
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "录入复核" and action_ = "COMPLETE")); /*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
format DATE YYMMDD10.;
DATE=datepart(create_time_);
进件=1;
进件月份= put(DATE, yymmn6.);
keep bussiness_key_ create_time_ DATE 进件 进件月份;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time nodupkey; by apply_code; run;
data apply_time_;
set apply_time;
if DATE>=mdy(11,1,2018);
run;
*【自有评分】;
data credit_score;
set approval.credit_score;
run;
/*===================================新逻辑Start===========================================*/
data autoVerifyTask_auto_reject;
set approval.apply_refusecancel_history(where=(current_period="autoVerifyTask"));
if type_name="autoRefuse" then do;
		first_refuse_code = reason_info_code;
		second_refuse_code = reason_info_code2;
		third_refuse_code = reason_info_code3;
		third_refuse_desc = remark;
	end;
else do;
		first_refuse_code = First_Root_Reason_Code;
		second_refuse_code = Second_Root_Reason_Code;
		third_refuse_code = reason_info_code;
		first_refuse_desc = First_Root_Reason_Name;
		second_refuse_desc = Second_Root_Reason_Name;
		third_refuse_desc = reason_info;
	end;
keep apply_code first_refuse_code second_refuse_code third_refuse_code first_refuse_desc second_refuse_desc third_refuse_desc created_time;
run;
proc sort data = autoVerifyTask_auto_reject nodupkey; by apply_code; run; 
* 删除徐团辉(PL2017121913222404036140)、贾鹏飞(PL2017103010484367829240)两条重复记录;
data otherTask_auto_reject;
set approval.apply_refusecancel_history(where=(current_period^="autoVerifyTask" and type_name="autoRefuse"));
first_refuse_code = reason_info_code;
second_refuse_code = reason_info_code2;
third_refuse_code = reason_info_code3;
third_refuse_desc = remark;
keep apply_code first_refuse_code second_refuse_code third_refuse_code third_refuse_desc created_time;
run;
proc sort data = otherTask_auto_reject; by apply_code third_refuse_code; run;
proc sort data = otherTask_auto_reject nodupkey; by apply_code; run;
* 同时命中天启黑名单(R743)和天启分(R753)拒绝的，保留天启黑名单的拒绝原因;
data auto_reject;
set autoVerifyTask_auto_reject otherTask_auto_reject;
auto_reject = 1;
if length(third_refuse_code)=4 and first_refuse_code = "" then do;
	first_refuse_code = substr(third_refuse_code,1,2);
	second_refuse_code = substr(third_refuse_code,1,3);
end;
rename created_time = auto_reject_time;
run;
proc sort data = auto_reject nodupkey; by apply_code; run;

data auto_reject_reason;
set approval.pbc_report_risk_info;
if type = "1";
/*where type in ("1","6");*/
keep id apply_code FIRST_REFUSE_CODE FIRST_REFUSE_DESC SECOND_REFUSE_CODE SECOND_REFUSE_DESC THIRD_REFUSE_CODE THIRD_REFUSE_DESC;
run;
proc sort data = auto_reject_reason nodupkey; by apply_code id; run;
proc sort data = auto_reject_reason nodupkey; by apply_code; run;
* 貌似id小的，拒绝原因优先级高一些，因此保留;
data auto_reject_db;
merge auto_reject(in=a) auto_reject_reason(in=b);
by apply_code;
if a;
drop id;
attrib _all_ label = "";
run;

*【批核】;
/*初审最新审批结果*/
data check_result_first;
set approval.approval_check_result(where = (period in ("firstVerifyTask","finalReturnTask")));
drop period CREATED_USER_ID UPDATED_USER_ID opinion;
rename check_result_type = check_result_first approved_product = app_prd_first approved_product_name = app_prdname_first 
		approved_sub_product = app_sub_prd_first approved_sub_product_name = app_sub_prdname_first loan_life = loan_life_first 
		loan_amount = loan_amt_first created_user_name = created_name_first updated_user_name = updated_name_first 
		created_time = created_time_first updated_time = updated_time_first;
run;
proc sort data = check_result_first nodupkey; by apply_code descending id; run;
proc sort data = check_result_first(drop = id) nodupkey; by apply_code; run;

/*终审最新审批结果*/
data check_result_final;
set approval.approval_check_result(where = (period = "finalVerifyTask"));
drop period CREATED_USER_ID UPDATED_USER_ID opinion;
rename check_result_type = check_result_final approved_product = app_prd_final approved_product_name = app_prdname_final 
		approved_sub_product = app_sub_prd_final approved_sub_product_name = app_sub_prdname_final loan_life = loan_life_final
		loan_amount = loan_amt_final created_user_name = created_name_final updated_user_name = updated_name_final
		created_time = created_time_final updated_time = updated_time_final;
run;
proc sort data = check_result_final nodupkey; by apply_code descending id; run;
proc sort data = check_result_final(drop = id) nodupkey; by apply_code; run;

/*最新审批结果*/
data check_result;
merge check_result_first(in = a) check_result_final(in = b);
by apply_code;
if a;
format check_result $10.;
	 if check_result_final = "ACCEPT" then check_result = "ACCEPT";
else if check_result_final = "REFUSE" or check_result_first = "REFUSE" then check_result = "REFUSE";
else if check_result_final = "CANCEL" or check_result_first = "CANCEL" then check_result = "CANCEL";
else if check_result_final = "BACK" or check_result_first = "BACK" then check_result = "BACK";
else check_result = "INDET";

format check_date yymmdd10.;
	 if check_result_final in ("REFUSE", "ACCEPT") then check_date = datepart(created_time_final);
else if check_result_first = "REFUSE" then check_date = datepart(created_time_first); 
批核月份  = put(check_date, yymmn6.);
format 批核日期 yymmdd10.;
批核日期 = check_date;
check_week = week(check_date); /*批核周，一年当中的第几周*/
if check_result = "ACCEPT" then 通过 = 1;
if check_result = "REFUSE" then 拒绝 = 1;
rename check_result = 批核状态 app_prdname_final = 批核产品大类_终审 app_sub_prdname_final = 批核产品小类_终审
		loan_amt_final = 批核金额_终审 loan_life_final = 批核期限_终审;
run;
data check_result;
set check_result;
if 批核产品大类_终审^="" then approve_产品=批核产品大类_终审;
else if  app_prdname_first^="" then approve_产品= app_prdname_first;
else approve_产品=DESIRED_PRODUCT;
run;

data new_model_score;
set approval.new_model_score;
run;
proc sort data=new_model_score;by apply_code descending CREATED_TIME;run;
proc sort data=new_model_score out=new_model_score_final nodupkey;by apply_code;run;
proc sort data=new_model_score;by apply_code CREATED_TIME;run;
proc sort data=new_model_score out=new_model_score_first nodupkey;by apply_code;run;
proc sql;
create table test_r_1 as 
select a.*,b.PHONE1,c.call_tel_total_nums,d.营业部,d.NAME,e.model_score_level,e.model_score,e.branch_class,f.group_Level,g.reason_info_code3,
	h.approve_产品,h.批核状态,h.批核日期,h.REFUSE_INFO_NAME,h.REFUSE_INFO_NAME_LEVEL1,h.REFUSE_INFO_NAME_LEVEL2,i.third_refuse_code,i.third_refuse_desc,i.first_refuse_code,
	j.value as rong360,k.value as tq_black,l.model_score_level as model_score_level_first
from apply_time_ as a
left join approval.apply_base as b on a.apply_code=b.apply_code
left join dianhua_derived_data as c on b.PHONE1=c.mobile
left join apply_info as d on a.apply_code=d.apply_code
left join new_model_score_final as e on a.apply_code=e.apply_code
left join credit_score as f on a.apply_code=f.apply_code
left join apply_refusecancel_history as g on a.apply_code=g.apply_code
left join check_result as h on a.apply_code=h.apply_code
left join auto_reject_db as i on a.apply_code=i.apply_code
left join apply_identity_match as j on a.apply_code=j.apply_code
left join apply_identity_match_tq as k on a.apply_code=k.apply_code
left join new_model_score_first as l on a.apply_code=l.apply_code;
quit;
data test_r_2;
set test_r_1;
if 营业部 in ("乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部") then region="第一类";
	else if 营业部 in ("赤峰市第一营业部","上海福州路营业部","福州五四路营业部","怀化市第一营业部","郑州市第一营业部","厦门市第一营业部","深圳市第一营业部","江门市业务中心","盐城市第一营业部"
		,"武汉市第一营业部","红河市第一营业部","南通市业务中心","南京市业务中心","湛江市第一营业部") then region="第三类";
	else region="第二类";
if region="第一类" then do;
	if model_score>=585 then 分档="A";
		else if model_score>=525 then 分档="B";
		else if model_score>=500 then 分档="D";
		else if model_score<1 then 分档="Z";
		else 分档="F";
	end;
else if region="第三类" then do;
	if model_score>=620 then 分档="B";
		else if model_score>=565 then 分档="D";
		else if model_score>=545 then 分档="E";
		else if model_score<1 then 分档="Z";
		else 分档="F";
	end; 
else do;
	if model_score>=630 then 分档="A";
		else if model_score>=605 then 分档="B";
		else if model_score>=570 then 分档="C";
		else if model_score>=555 then 分档="D";
		else if model_score>=515 then 分档="E";
		else if model_score<1 then 分档="Z";
		else 分档="F";
	end; 

if third_refuse_code='R751' then 旧评分=1;else 旧评分=0;
if first_refuse_code='R757' then 新模型=1;else 新模型=0;
if first_refuse_code='R754' then 电话邦=1;else 电话邦=0;
if first_refuse_code='R755' then 融360=1;else 融360=0;
if first_refuse_code='R758' then 汇盾=1;else 汇盾=0;
if first_refuse_code in ('R756',"R743") then 天启黑名单=1;else 天启黑名单=0;
if first_refuse_code^='' then 自动拒绝=1;else 自动拒绝=0;
if 自动拒绝=1 and 旧评分=0 and 天启黑名单=0 and 电话邦=0 and 融360=0 and 新模型=0 and 汇盾=0 then 其他拒绝=1;else 其他拒绝=0;
if apply_code='PL154140087720102300000886' then do;天启黑名单=1;融360=0;end;

if rong360=1 then 融360代码=1;else 融360代码=0;
if call_tel_total_nums>=17 then 电话邦代码=1;else 电话邦代码=0;
if model_score_level="F" then 新模型代码=1;else 新模型代码=0;
if group_Level="F" then 旧评分代码=1;else 旧评分代码=0;
if tq_black=1 then 天启黑名单代码=1;else 天启黑名单代码=0;

if 批核状态 in ('REFUSE','ACCEPT') then 审批数量=1;else 审批数量=0;
if 批核状态='ACCEPT' then 审批通过=1;else 审批通过=0;

if 汇盾=1 and (旧评分=0 and 新模型=0 and 其他拒绝=0) then 汇盾非重=1;else 汇盾非重=0;
if 汇盾=1 and (旧评分=1 or 新模型=1 or 其他拒绝=1) then 汇盾重=1;else 汇盾重=0;
if 天启黑名单代码=1 and (旧评分=0 and 新模型=0 and 其他拒绝=0 and 汇盾=0) then 天启黑名单非重=1;else 天启黑名单非重=0;
if 天启黑名单代码=1 and (旧评分=1 or 新模型=1 or 其他拒绝=1 or 汇盾=1) then 天启黑名单重=1;else 天启黑名单重=0;
if 融360代码=1 and (旧评分=0 and 天启黑名单=0 and 其他拒绝=0  and 新模型=0  and 汇盾=0) then 融360非重=1;else 融360非重=0;
if 融360代码=1 and (旧评分=1 or 天启黑名单=1 or 其他拒绝=1  or 新模型=1 or 汇盾=1) then 融360重=1;else 融360重=0;
if 电话邦代码=1 and (旧评分=0 and 天启黑名单=0 and 其他拒绝=0  and 融360=0  and 汇盾=0) then 电话邦非重=1;else 电话邦非重=0;
if 电话邦代码=1 and (旧评分=1 or 天启黑名单=1 or 其他拒绝=1 or 融360=1 or 汇盾=1) then 电话邦重=1;else 电话邦重=0;

if region^=branch_class and branch_class^='' then 营业部分类错误=1;else 营业部分类错误=0;
if model_score_level^=分档 and model_score_level^='' then 分档错误=1;else 分档错误=0;
if 新模型代码^=新模型 then 新模型错误=1;else 新模型错误=0;
if 旧评分代码^=旧评分 then 旧评分错误=1;else 旧评分错误=0;
if 电话邦代码^=电话邦 then 电话邦错误=1;else 电话邦错误=0;
if 融360代码^=融360 then 融360错误=1;else 融360错误=0;
if 天启黑名单代码^=天启黑名单 then 天启黑名单错误=1;else 天启黑名单错误=0;
if 电话邦错误=1 or 融360错误=1 or 营业部分类错误=1 or 分档错误=1 or 新模型错误=1 or 旧评分错误=1 or 天启黑名单错误=1 then 错误=1;else 错误=0;

if model_score_level_first=model_score_level then 分数变动=0;else 分数变动=1;
if model_score_level_first^='F' and model_score_level='F' then 非自动拒绝变自动拒绝=1;else 非自动拒绝变自动拒绝=0;
if model_score_level_first='F' and model_score_level^='F' then 自动拒绝变非自动拒绝=1;else 自动拒绝变非自动拒绝=0;

array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
run;
proc sort data=test_r_2;by apply_code;run;
proc sort data=test_r_2 nodupkey;by apply_code;run;
proc sql;
create table test_r_3 as
select Date,count(apply_code) as 进件量,sum(其他拒绝) as 征信等拒绝量,sum(旧评分) as 旧评分拒绝量,sum(新模型) as 新模型,sum(汇盾) as 汇盾,sum(汇盾非重) as 汇盾非重,sum(汇盾重) as 汇盾重,sum(天启黑名单) as 天启黑名单,
	sum(天启黑名单重) as 天启黑名单重,sum(天启黑名单非重) as 天启黑名单非重,sum(融360) as 融360,sum(融360重) as 融360重,sum(自动拒绝) as 自动拒绝,
	sum(融360非重) as 融360非重,sum(电话邦) as 电话邦,sum(电话邦重) as 电话邦重,sum(电话邦非重) as 电话邦非重,sum(审批通过) as 审批通过量,sum(审批数量) as 审批数量,
	max(错误) as 错误,sum(旧评分代码) as 旧评分代码,sum(新模型代码) as 新模型代码,sum(天启黑名单代码) as 天启黑名单代码,sum(融360代码) as 融360代码,sum(电话邦代码) as 电话邦代码,
	sum(分数变动) as 分数变动,sum(非自动拒绝变自动拒绝) as 非自动拒绝变自动拒绝,sum(自动拒绝变非自动拒绝) as 自动拒绝变非自动拒绝
	from test_r_2 group by Date;
quit;
proc sql;
create table test_r_4 as 
select a.date,b.* from date as a
left join test_r_3 as b on a.date=b.Date;
quit;
proc sort data=test_r_4;by Date;run;
data test_r_5;
set test_r_4;
if Date>=&db.;
run;
filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]Sheet2!r5c3:r35c12";
data _null_;set test_r_5;file DD;put 进件量 征信等拒绝量 旧评分拒绝量 新模型 汇盾 天启黑名单非重 天启黑名单 融360重 融360非重 融360;run;

filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]Sheet2!r5c13:r35c26";
data _null_;set test_r_5;file DD;put 电话邦重 电话邦非重 电话邦 审批通过量 审批数量 错误 自动拒绝 旧评分代码 新模型代码 天启黑名单代码 融360代码 电话邦代码 分数变动 非自动拒绝变自动拒绝;run;

*各分档情况的通过率;
proc sql;
create table test_r_3_ as
select Date,model_score_level,sum(审批数量) as 审批数量,sum(审批通过) as 审批通过量
	from test_r_2 group by Date,model_score_level;
quit;
data test_r_4_1;
set test_r_3_;
if model_score_level^="";
drop 审批数量;
run;
proc transpose data=test_r_4_1 out=test_r_5_1 prefix=tg_;
	ID MODEL_SCORE_LEVEL;
	BY Date;
	var 审批通过量;
run;
proc sql;
create table test_r_6_1 as 
select a.date,b.* from date as a
left join test_r_5_1 as b on a.date=b.date;
quit;
data test_r_7_1;
set test_r_6_1;
if date>=&db.;
run;
filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]Sheet2!r5c27:r34c31";
data _null_;set test_r_7_1;file DD;put tg_A tg_B tg_C tg_D tg_E;run;

data test_r_4_2;
set test_r_3_;
if model_score_level^="";
drop 审批通过量;
run;
proc transpose data=test_r_4_2 out=test_r_5_2 prefix=tg_;
	ID MODEL_SCORE_LEVEL;
	BY Date;
	var 审批数量;
run;
proc sql;
create table test_r_6_2 as 
select a.date,b.* from date as a
left join test_r_5_2 as b on a.date=b.date;
quit;
data test_r_7_2;
set test_r_6_2;
if date>=&db.;
run;
filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]Sheet2!r5c32:r34c36";
data _null_;set test_r_7_2;file DD;put tg_A tg_B tg_C tg_D tg_E;run;

*月度漏斗情况;
data test_r_5_;
set test_r_4;
month=put(Date,yymmn6.);
/*if date>mdy(11,5,2018);*/
array num _numeric_;
do over num;
If num="." Then num=0;
end;
run;
proc sql;
create table test_r_6 as 
select month,sum(进件量) as a01_进件量,sum(征信等拒绝量) as a02_征信等拒绝量,sum(旧评分拒绝量) as a03_旧评分拒绝量,sum(新模型) as a04_新模型,sum(汇盾) as a05_汇盾,sum(天启黑名单非重) as a06_天启黑名单非重,
	sum(天启黑名单) as a07_天启黑名单,sum(融360重) as a08_融360重,sum(融360非重) as a09_融360非重,sum(融360) as a10_融360,sum(电话邦重) as a11_电话邦重,sum(电话邦非重) as a12_电话邦非重,sum(电话邦) as a13_电话邦,
	sum(审批通过量) as a17_审批通过量,sum(审批数量) as a18_审批数量,sum(自动拒绝) as a14_自动拒绝,sum(分数变动) as a15_分数变动,sum(非自动拒绝变自动拒绝) as a16_非自动拒绝变自动拒绝
from test_r_5_ group by month;
quit;
proc transpose data=test_r_6 out=test_r_7 prefix=month_;
	var a01_进件量 a02_征信等拒绝量 a03_旧评分拒绝量 a04_新模型 a05_汇盾 a06_天启黑名单非重 a07_天启黑名单 a08_融360重 a09_融360非重 a10_融360 a11_电话邦重 a12_电话邦非重 a13_电话邦
		a14_自动拒绝 a15_分数变动 a16_非自动拒绝变自动拒绝 a17_审批通过量 a18_审批数量;
	ID month;
run;
%macro jinjian();
	%do i = 11 %to &due_month.;
		data _null_;
		format col_ja $2.;*列数为1位数或3位数时不再适用;
		col_ja=3+(&i.-11)*4;
		call symput('col_ja',col_ja);
		format month help_date yymmdd10.;
		help_date=mdy(12,1,2017);
		month=intnx('month',help_date,&i.);
		str_month='month_' || put(month,yymmn6.);
		call symput('str_month',str_month);
		run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r4c&col_ja.:r21c&col_ja.";
		data _null_;set test_r_7;file DD;put &str_month.;run;
	%end;
%mend;
	
%jinjian();
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r4c3:r21c3";*/
/*data _null_;set test_r_7;file DD;put month_11;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r4c7:r21c7";*/
/*data _null_;set test_r_7;file DD;put month_12;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r4c11:r21c11";*/
/*data _null_;set test_r_7;file DD;put month_1;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r4c15:r21c15";*/
/*data _null_;set test_r_7;file DD;put month_2;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r4c19:r21c19";*/
/*data _null_;set test_r_7;file DD;put month_3;run;*/

*月度各分档的通过率;
data test_r_3_a;
set test_r_3_;
month=month(Date);
array num _numeric_;
do over num;
If num="." Then num=0;
end;
run;
data test_r_3_b;
set test_r_3_a;
if model_score_level^="" and model_score_level^="F";
run;
proc sql;
create table test_r_3_c as 
select month,model_score_level,sum(审批数量) as 审批数量,sum(审批通过量) as 审批通过量 from test_r_3_b group by month,model_score_level;
quit;
data test_r_3_d;
set test_r_3_c;
审批通过率=审批通过量/审批数量;
run;
data test_r_3_d_1;
set test_r_3_d;
drop 审批通过率 审批数量;
run;
proc sort data=test_r_3_d_1;by MODEL_SCORE_LEVEL;run;
proc transpose data=test_r_3_d_1 out=test_r_3_e_1 prefix=month_;
	var 审批通过量;
	ID month;
	by MODEL_SCORE_LEVEL;
run;
data test_r_3_e_1;
set test_r_3_e_1;
MODEL_SCORE_LEVEL_=1;
/*keep MODEL_SCORE_LEVEL month_11 month_12 month_1 month_2 month_3 MODEL_SCORE_LEVEL_;*/
run;
data test_r_3_d_2;
set test_r_3_d;
drop 审批通过量 审批数量;
run;
proc sort data=test_r_3_d_2;by MODEL_SCORE_LEVEL;run;
proc transpose data=test_r_3_d_2 out=test_r_3_e_2 prefix=month_;
	var 审批通过率;
	ID month;
	by MODEL_SCORE_LEVEL;
run;
data test_r_3_e_2;
set test_r_3_e_2;
MODEL_SCORE_LEVEL_=3;
/*keep MODEL_SCORE_LEVEL month_11 month_12 month_1 month_2 month_3 MODEL_SCORE_LEVEL_;*/
run;
data test_r_3_d_3;
set test_r_3_d;
drop 审批通过率 审批通过量;
run;
proc sort data=test_r_3_d_3;by MODEL_SCORE_LEVEL;run;
proc transpose data=test_r_3_d_3 out=test_r_3_e_3 prefix=month_;
	var 审批数量;
	ID month;
	by MODEL_SCORE_LEVEL;
run;
data test_r_3_e_3;
set test_r_3_e_3;
MODEL_SCORE_LEVEL_=2;
/*keep MODEL_SCORE_LEVEL month_11 month_12 month_1 month_2 month_3 MODEL_SCORE_LEVEL_;*/
run;
data test_r_3_f;
set test_r_3_e_1 test_r_3_e_2 test_r_3_e_3;
run;
proc sort data=test_r_3_f;by MODEL_SCORE_LEVEL MODEL_SCORE_LEVEL_;run;

%macro jinjian2();
	%do i = 11 %to &due_month.;
		data _null_;
		format col_ja $2.;*列数为1位数或3位数时不再适用;
		col_ja=3+(&i.-11)*4;
		call symput('col_ja',col_ja);
		format month help_date yymmdd10.;
		help_date=mdy(12,1,2017);
		month=intnx('month',help_date,&i.);
		str_month='month_' || put(month,yymmn6.);
		call symput('str_month',str_month);
		run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r23c&col_ja.:r37c&col_ja.";
		data _null_;set test_r_7;file DD;put &str_month.;run;
	%end;
%mend;
	
%jinjian2();
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r23c3:r37c3";*/
/*data _null_;set test_r_3_f;file DD;put month_11;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r23c7:r37c7";*/
/*data _null_;set test_r_3_f;file DD;put month_12;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r23c11:r37c11";*/
/*data _null_;set test_r_3_f;file DD;put month_1;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r23c15:r37c15";*/
/*data _null_;set test_r_3_f;file DD;put month_2;run;*/
/*filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r23c19:r37c19";*/
/*data _null_;set test_r_3_f;file DD;put month_3;run;*/

*批核金额件均;
proc sql;
create table test_m_1 as 
select a.apply_code,a.批核金额_终审,a.approve_产品,a.批核日期,a.通过,b.group_Level,c.model_score_level
from check_result as a
left join credit_score as b on a.apply_code=b.apply_code
left join new_model_score_final as c on a.apply_code=c.apply_code;
quit;
data test_m_2;
set test_m_1;
if 通过=1;
if model_score_level^='';
if model_score_level^='F';
if group_Level="A" and model_score_level="A" then 分组="1A";
	else if model_score_level="A" then 分组="2A";
	else if model_score_level="B" then 分组="3B";
	else if model_score_level="C" then 分组="4C";
	else if model_score_level="D" then 分组="5D";
	else if model_score_level="E" then 分组="6E";
run;
/*proc sql;*/
/*create table aa as */
/*select a.*,b.ID_CARD_NO from test_m_2 as a*/
/*left join apply_info as b on a.apply_code=b.apply_code;*/
/*quit;*/
proc sql;
create table test_m_3 as 
select approve_产品,批核日期,分组,count(apply_code) as nums,sum(批核金额_终审) as 批核金额 from test_m_2 group by approve_产品,批核日期,分组;
quit;
/*proc sort data=test_m_3;by 批核日期;run;*/
data group;
input groups $3.;
cards;
1A
2A
3B
4C
5D
6E
;
run;
%macro ph();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_产品='U贷通';
		if 批核日期=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]批核件均!r3c&colb.:r8c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%ph();
%macro ph_e1();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_产品='E网通';
		if 批核日期=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]批核件均!r12c&colb.:r17c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%ph_e1();
%macro ph_e2();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_产品='E微贷';
		if 批核日期=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]批核件均!r21c&colb.:r26c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%ph_e2();
%macro ph_e3();
	%do i = 0 %to &nd.;
		data _null_;
		cut_dt = intnx("day", &db., &i.);
		call symput("cut_dt", cut_dt);
		colb=3*(&i.)+10;
		cole=3*(&i.)+11;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3;
		if approve_产品='E微贷-无社保';
		if 批核日期=&cut_dt.;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]批核件均!r30c&colb.:r35c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%ph_e3();

*月度批核金额件均;
data test_m_3_;
set test_m_3;
month= month(批核日期);
run;
proc sql;
create table test_m_3_1 as 
select approve_产品,分组,month,sum(nums) as nums,sum(批核金额) as 批核金额 from test_m_3_ group by approve_产品,分组,month;
quit;
%macro phm();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_产品='U贷通';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r42c&colb.:r47c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%phm();

%macro phme1();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_产品='E网通';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r52c&colb.:r57c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%phme1();

%macro phme2();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_产品='E微贷';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r62c&colb.:r67c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%phme2();

%macro phme3();
	%do i = 11 %to &due_month.;
		data _null_;
		colb=3*(&i.-11)+4;
		cole=3*(&i.-11)+5;
		call symput("colb",compress(colb));
		call symput("cole",compress(cole));
		run;
		data test_m_4;
		set test_m_3_1;
		if approve_产品='E微贷-无社保';
		if month=&i. or month=&i.-12;
		run;
		proc sql;
		create table test_m_5 as 
		select a.*,b.nums,b.批核金额 from group as a
		left join test_m_4 as b on a.groups=b.分组;
		quit;
		proc sort data=test_m_5;by groups;run;
		filename DD DDE "EXCEL|[新模型—电话邦命中情况.xlsx]月度情况!r72c&colb.:r77c&cole.";
		data _null_;set test_m_5;file DD;put 批核金额 nums;run;
	%end;
%mend;
	
%phme3();
