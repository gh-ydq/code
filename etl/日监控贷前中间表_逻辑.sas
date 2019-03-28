/*option validvarname=any;option compress=yes;*/
/*libname approval "E:\guan\原数据\approval";*/
/*libname midapp "E:\guan\中间表\midapp";*/


*日报表;
*【回退】
*approval_check_result中BACK_NODE：finalReturnTask--回退初审
                                   firstVerifyTask-初审(旧版节点名称，但也是回退初审的意思)
                                   verifyReturnTask--回退门店
                                   inputCheckTask--录入符合(旧版节点名称，但也是回退门店的意思);
data macrodate;
format date  start_date  fk_month_begin month_begin  end_date last_month_end last_month_begin month_end yymmdd10.;*定义时间变量格式;
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(12,31,2017);*/
call symput("tabledate",date);*定义一个宏;
start_date = intnx("month",date,-2,"b");
call symput("start_date",start_date);
month_begin=intnx("month",date,0,"b");
call symput("month_begin",month_begin);
month_end=intnx("month",date,1,"b")-1;
call symput("month_end",month_end);
last_month_end=intnx("month",date,0,"b")-1;
call symput("last_month_end",last_month_end);
last_month_begin=intnx("month",date,-1,"b");
call symput("last_month_begin",last_month_begin);
if day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*当月26-下月25的循环;
end_date = mdy(month(date)+1,25,year(date));end;
else do;fk_month_begin = mdy(month(date)-1,26,year(date));
end_date = mdy(month(date),25,year(date));end;
/*加了一个12月底跟新的一年1月初的情况，不然新年或者月底会出现空值*/
if month(date)=12 and day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*当月26-下月25的循环;
end_date = mdy(month(date)-11,25,year(date)+1);end;
else if month(date)=1 and day(date)<=25 then do;fk_month_begin = mdy(month(date)+11,26,year(date)-1);
end_date = mdy(month(date),25,year(date));end;
call symput("fk_month_begin",fk_month_begin);
call symput("end_date",end_date);
run;

/*%let tabledate=mdy(12,31,2016);*/
/*%let nt=mdy(1,1,2005);*/
/*%let start_date=mdy(7,1,2017);*只是为了覆盖近两个月而已;*/
/*%let end_date=mdy(9,25,2017);*本轮周期的结束日期;*/
/*%let month_begin=mdy(8,1,2017);*当月1号;*/
/*%let fk_month_begin=mdy(12,26,2017);*本轮周期的开始日期;*/

data date;
format date  yymmdd10. prime_key ;
 n=today()-&start_date.;
/* n=intnx("year",&nt.,12,"same")-&start_date.;*/
do i=1 to n;
date=intnx("day",&start_date.,i-1);
prime_key=1;
output;
end;
drop i;
run;
*定义数据集存储apply_nfo;
data apply_dept;
set approval.apply_info(keep= apply_code BRANCH_NAME branch_code DESIRED_PRODUCT NAME SOURCE_CHANNEL);
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

prime_key=1;

run;

data apply_dept1;
set apply_dept(where = ( SOURCE_CHANNEL="257"));
BRANCH_NAME = 'APP';
RUN;
data apply_dept;
set apply_dept apply_dept1;
run;
proc sort data=apply_dept(where=(branch_name^="公司渠道")) nodupkey out=dept(keep=branch_name prime_key);by branch_name;run;


proc sql;

create table date_dept as
select a.date,b.branch_name from date as a
left join dept as b on a.prime_key=b.prime_key;
quit;
proc sort data=date_dept;by date branch_name;run;
data back;
set approval.approval_check_result(where=(BACK_NODE in ("verifyReturnTask","inputCheckTask")));
format DATE YYMMDD10.;
DATE=datepart(CREATED_TIME);
回退=1;
keep APPLY_CODE CREATED_TIME PERIOD CHECK_RESULT_TYPE BACK_NODE DATE 回退;
run;
proc sort data=back;by APPLY_CODE CREATED_TIME;run;
proc sort data=back nodupkey;by APPLY_CODE;run;

proc sql;
create table backtodept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME from back as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;
proc sql;
create table backtodapet_static as
select date,BRANCH_NAME,sum(回退) as 回退量 from backtodept group by date,BRANCH_NAME;quit;
*【进件】;
/*以首次录入复核完成时间作为进件时间,E骑贷以首次进入初审时间为进件时间*/
proc sql;
create table apply_t as 
select a.*,b.desired_product from approval.act_opt_log as a
left join approval.apply_info as b on a.bussiness_key_=b.APPLY_CODE;
quit;
data apply_t2;
set apply_t;
if desired_product^='Eqidai' then do;
	if task_Def_Name_ = "录入复核" and action_ = "COMPLETE" then 进件=1;
end;
else do;
	if task_Def_Name_ = "初审" then 进件=1;
end;
run;
data apply_time;
set apply_t2;
if 进件=1;
format DATE YYMMDD10.;
DATE=datepart(create_time_);
进件月份= put(DATE, yymmn6.);
keep bussiness_key_ create_time_ DATE 进件 进件月份;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time; by apply_code DATE; run;
proc sort data = apply_time nodupkey; by apply_code; run;

proc sql;
create table apply_time_dept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME,b.DESIRED_PRODUCT from apply_time as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;

proc sql;
create table apply_time_static as
select date,BRANCH_NAME,sum(进件) as 进件量 from apply_time_dept group by date,BRANCH_NAME;quit;
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
批核日期 = put(check_date, yymmdd10.);
check_week = week(check_date); /*批核周，一年当中的第几周*/
if check_result = "ACCEPT" then 通过 = 1;
if check_result = "REFUSE" then 拒绝 = 1;
rename check_result = 批核状态 app_prdname_final = 批核产品大类_终审 app_sub_prdname_final = 批核产品小类_终审
		loan_amt_final = 批核金额_终审 loan_life_final = 批核期限_终审;
run;
data midapp.check_result;
set check_result;
run;
proc sql;
create table check_result_only_approve(where=(BRANCH_NAME^="")) as
select a.APPLY_CODE,a.check_date as date ,a.通过,b.branch_name from check_result(where=(通过=1)) as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b  on a.apply_code=b.apply_code;
quit;
proc sql;
create table check_result_only_approve_static as
select date,BRANCH_NAME,sum(通过) as 通过量 from check_result_only_approve(where=(branch_name^="公司渠道")) group by date,BRANCH_NAME;quit;

*【签约】;
data sign_contract;
set approval.contract(keep = apply_no contract_no net_amount contract_amount service_fee_amount documentation_fee sign_date );
rename apply_no = apply_code net_amount = 到手金额 contract_amount = 合同金额 service_fee_amount = 服务费 documentation_fee = 单证费;
format date  yymmdd10.;
date=mdy(month(sign_date),day(sign_date),year(sign_date));
签约=1;
if date^=.;
run;
proc sort data=sign_contract nodupkey;by apply_code;run;
proc sql;
create table sign_contract_dept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME from sign_contract as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;
data act_ru_execution;
set approval.act_ru_execution(keep = business_key_ act_id_ PROC_INST_ID_ PROC_DEF_ID_ ID_);
run;*无重复值;
proc sql;
create table execution_time as
select a.*,b.end_time_   from act_ru_execution as a
left join approval.Act_hi_taskinst as  b on a.PROC_INST_ID_=b.PROC_INST_ID_;
quit;
proc sort data=execution_time ;by PROC_INST_ID_  descending end_time_;run;
proc sort data=execution_time out=execution_time_ nodupkey;by PROC_INST_ID_;run;
data act_hi_procinst;
set approval.act_hi_procinst(keep = business_key_ end_act_id_ PROC_INST_ID_ ID_ PROC_DEF_ID_ END_TIME_);
run;*无重复值;
*procinst会覆盖execution的business_key_，但没有	execution 里面的 节点状态数据，所以用这种方法拼起来;
proc sort data = act_hi_procinst nodupkey; by business_key_; run;
proc sort data = execution_time_ nodupkey; by business_key_; run;
data cur_status;
merge act_hi_procinst(in = a) execution_time_(in = b);
by business_key_;
if a;
format 当前状态 $10.;
	 if end_act_id_ = "cancleEvent" then 当前状态 = "取消";
else if end_act_id_ = "refuseEvent" or act_id_ = "refuse" then 当前状态 = "拒绝";
else if end_act_id_ = "endEvent" then 当前状态 = "结束";
else if act_id_ = "registerTask" then 当前状态 = "进件中";
else if act_id_ = "checkTask" then 当前状态 = "进件中";
else if act_id_ = "inputTask" then 当前状态 = "进件中";
else if act_id_ = "inputCheckTask" then 当前状态 = "进件中";
else if act_id_ = "firstVerifyTask" then 当前状态 = "审批中";
else if act_id_ = "finalVerifyTask" then 当前状态 = "审批中";
else if act_id_ = "finalReturnTask" then 当前状态 = "审批中";
else if act_id_ = "verifyReturnTask" then 当前状态 = "审批中";
else if act_id_ = "signContractTask" then 当前状态 = "通过";
else if act_id_ = "uploadContractTask" then 当前状态 = "通过";
else if act_id_ = "contractCheckTask" then 当前状态 = "通过";
else if act_id_ = "modifyCardTask" then 当前状态 = "通过";
else if act_id_ = "deductAgainTask" then 当前状态 = "通过";
else if act_id_ = "deductTask" then 当前状态 = "通过";
else if act_id_ = "firstReviewTask" then 当前状态 = "通过";
else if act_id_ = "finalReviewTask" then 当前状态 = "通过";
else if act_id_ = "genFundExcelTask" then 当前状态 = "通过";
else if act_id_ = "loanTask" then 当前状态 = "通过";
else 当前状态 = "未知";
rename business_key_ = apply_code
       END_TIME_=endtime;
run;

proc sort data=cur_status(where=(当前状态="拒绝") ) nodupkey out=cac(keep=apply_code);by apply_code;run;
proc sort data=sign_contract_dept;by apply_code;run;
data sign_contract_dept1;
merge sign_contract_dept(in=a) cac(in=b);
by apply_code;
if not b;
run;
proc sql;
create table sign_contract_static as
select date,BRANCH_NAME,sum(签约) as 签约量,sum(合同金额) as 签约合同金额 from sign_contract_dept1 group by date,BRANCH_NAME;quit;
data qyjx;
merge sign_contract_dept(in=a) cac(in=b);
by apply_code;
if a & b;
run;
proc sort data =check_result_only_approve;by apply_code;run;
proc sort data=qyjx;by apply_code;run;
data qyjx2;
merge check_result_only_approve(in=a) qyjx(in=b);
by apply_code;
if not b;
run;
proc sql;
create table check_result_only_approve_qy as
select date,BRANCH_NAME,sum(通过) as 通过量 from qyjx2(where=(branch_name^="公司渠道")) group by date,BRANCH_NAME;quit;
*【放款】;
/*放款信息  loan_info表里loan_amount早期存的是合同金额，后面存的是到手金额，所以金额用contract表*/
data loan_info;
set approval.loan_info(keep = contract_no loan_date capital_channel_code status );
format 放款状态 $10.;
	 if status in ("06", "08", "09", "10") then 放款状态 = "已放款";
else if status = "11" then 放款状态 = "拒绝";
else if status = "12" then 放款状态 = "取消";
else 放款状态 = "放款中";
if 放款状态="已放款";
放款=1;
/*apply_code = tranwrd(contract_no, "C", "PL");*/
放款月份 = put(loan_date, yymmn6.);
format date  yymmdd10.;
date=mdy(month(loan_date),day(loan_date),year(loan_date));
rename capital_channel_code = 资金渠道;
drop status;
run;
proc sql;
create table loan_info_dept(where=(BRANCH_NAME^="")) as
select a.*,b.contract_amount,c.BRANCH_NAME from loan_info as a
left join approval.contract as b on a.contract_no=b.contract_no
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as c on b.apply_no=c.apply_code;
quit;
proc sql;
create table loan_info_static as
select date,BRANCH_NAME,sum(放款) as 放款量,sum(contract_amount) as 放款合同金额 from loan_info_dept group by date,BRANCH_NAME;quit;




proc sql;
create table  Partone as
select a.date,a.BRANCH_NAME,b.回退量,c.进件量,d.签约量,d.签约合同金额,e.放款量,e.放款合同金额,f.通过量,g.通过量 as 签拒通过量 from Date_dept as a
left join backtodapet_static as b on a.date=b.date and a.branch_name=b.BRANCH_NAME
left join Apply_time_static as c on a.date=c.date and a.branch_name=c.BRANCH_NAME
left join Sign_contract_static as d on a.date=d.date and a.branch_name=d.BRANCH_NAME
left join Loan_info_static as e on a.date=e.date and a.branch_name=e.BRANCH_NAME
left join check_result_only_approve_static as f on  a.date=f.date and a.branch_name=f.branch_name
left join check_result_only_approve_qy as g on a.date=g.date and a.branch_name=g.branch_name;
quit;

proc sort data=partone;by BRANCH_NAME date;run;

data Partone_cumulate1;
set Partone(where=(date>=&month_begin.));
retain 累计回退量 累计进件量 累计签约量 累计签约合同金额   累计签拒通过量;
array numr _numeric_;
do over numr;
if numr=. then numr=0;
end;
by BRANCH_NAME date;
if first.BRANCH_NAME then do;
累计回退量=回退量;
累计进件量=进件量	;
累计签约量=签约量;
累计签约合同金额=签约合同金额;

累计签拒通过量=签拒通过量;
end;
else do;
累计回退量=累计回退量+回退量;
累计进件量=累计进件量+进件量;
累计签约量=累计签约量+签约量;
累计签约合同金额=累计签约合同金额+签约合同金额;

累计签拒通过量=累计签拒通过量+签拒通过量;
end;
run;

data Partone_cumulate2;
set Partone(where=(date>=&fk_month_begin.));
retain  累计放款量 累计放款合同金额  累计通过量;
array numr _numeric_;
do over numr;
if numr=. then numr=0;
end;
by BRANCH_NAME date;
if first.BRANCH_NAME then do;
累计放款量=放款量;
累计通过量=通过量;
累计放款合同金额=放款合同金额;
end;
else do;
累计放款量=累计放款量+放款量;
累计通过量=累计通过量+通过量;
累计放款合同金额=累计放款合同金额+放款合同金额;
end;
run;
proc sql;
create table Partone_cumulate_end as
select a.date,a.branch_name,a.累计进件量,a.累计回退量,b.累计通过量,b.累计放款量,b.累计放款合同金额	from Partone_cumulate1 as a
left join Partone_cumulate2 as b on a.date=b.date and a.branch_name=b.branch_name;
quit;

data midapp.Partone_cumulate_end;
set Partone_cumulate_end;
run;
