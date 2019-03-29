
option compress=yes validvarname=any;
libname approval "D:\share\Datamart\原表\approval";
libname dta "D:\share\Datamart\中间表\daily";
libname appraw odbc  datasrc=approval_nf;
libname res odbc  datasrc=res_nf;
libname credit "D:\share\Datamart\原表\credit";

data macrodate;
format date  start_date  fk_month_begin month_begin  end_date  yymmdd10.;*定义时间变量格式;
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(8,22,2017);*/
call symput("tabledate",date);*定义一个宏;
start_date = intnx("month",date,-1,"b");
call symput("start_date",start_date);
month_begin=intnx("month",date,0,"b");
call symput("month_begin",month_begin);
if day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));
end_date = mdy(month(date)+1,25,year(date));end;
else do;fk_month_begin = mdy(month(date)-1,26,year(date));
end_date = mdy(month(date),25,year(date));end;
call symput("fk_month_begin",fk_month_begin);
call symput("end_date",end_date);
run;

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
run;

data apply_dept;
set apply_dept ;
if branch_name ="公司渠道" then delete;
run;
proc sort data = apply_dept nodupkey;by apply_code ;run;

/*进件数据*/
data apply;
set approval.act_opt_log(where = (task_Def_Name_ = "录入复核" and action_ = "COMPLETE")); /*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
format 进件时间 YYMMDD10.;
进件时间=datepart(create_time_);
进件=1;
keep bussiness_key_ 进件时间 进件;
rename bussiness_key_ = apply_code ;
run;
proc sort data = apply dupout = a nodupkey; by apply_code 进件时间; run;
proc sort data = apply nodupkey; by apply_code; run;

data dta.apply;
set apply;
run;


/*回退数据*/
data back;
set approval.approval_check_result(where=(BACK_NODE in ("verifyReturnTask","inputCheckTask")));
format 回退门店时间 YYMMDD10.;
回退门店时间=datepart(CREATED_TIME);
回退门店=1;
keep APPLY_CODE 回退门店时间 回退门店;
run;
proc sort data=back;by APPLY_CODE 回退门店时间;run;
proc sort data=back nodupkey;by APPLY_CODE;run;

data dta.back;
set back ;
run;

/*每个单子当前状态*/
data act_ru_execution;
set approval.act_ru_execution(keep = business_key_ act_id_);
run;
data act_hi_procinst;
set approval.act_hi_procinst(keep = business_key_ end_act_id_);
run;
proc sort data = act_hi_procinst nodupkey; by business_key_; run;
proc sort data = act_ru_execution nodupkey; by business_key_; run;
data cur_status;
merge act_hi_procinst(in = a) act_ru_execution(in = b);
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
else if act_id_ = "channelConfirmTask" then 当前状态 = "通过";
else 当前状态 = "未知";
rename business_key_ = apply_code; 
/*keep business_key_ 当前状态;*/
run;
data dta.cur_status;
set cur_status;
run;

/*初审最新审批结果*/
data check_result_first;
set approval.approval_check_result(where = (period in( "firstVerifyTask","finalReturnTask")));
drop period CREATED_USER_ID UPDATED_USER_ID opinion;
rename check_result_type = check_result_first approved_product = app_prd_first approved_product_name = app_prdname_first 
		approved_sub_product = app_sub_prd_first approved_sub_product_name = app_sub_prdname_first loan_life = loan_life_first 
		loan_amount = loan_amt_first created_user_name = created_name_first updated_user_name = updated_name_first 
		created_time = created_time_first updated_time = updated_time_first PROPOSE_LIMIT=PROPOSE_LIMIT_first;
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
		created_time = created_time_final updated_time = updated_time_final REFUSE_INFO_NAME=REFUSE_INFO_NAME_final
		REFUSE_INFO_NAME_LEVEL1=REFUSE_INFO_NAME_LEVEL1_final REFUSE_INFO_NAME_LEVEL2=REFUSE_INFO_NAME_LEVEL2_final PROPOSE_LIMIT=PROPOSE_LIMIT_final;
run;
proc sort data = check_result_final nodupkey; by apply_code  id; run;
data check_result_final;
set check_result_final;
retain created_name_final1;
by apply_code;
if first.apply_code then created_name_final1=lag(created_name_final);
if created_name_final ="文杰" then created_name_final =created_name_final1;
drop created_name_final1;
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
if 通过=. and 拒绝=. then check_end=0;
else check_end=1;
rename check_result = 批核状态 app_prdname_final = 批核产品大类_终审 app_sub_prdname_final = 批核产品小类_终审
		loan_amt_final = 批核金额_终审 loan_life_final = 批核期限_终审;
/*产品信息*/
if app_prdname_final^=""  then approve_产品=app_prdname_final;
else if  app_prdname_first^="" then approve_产品= app_prdname_first;
else approve_产品=DESIRED_PRODUCT;
if approve_产品="Ebaotong" then approve_产品="E保通";
else if approve_产品="Salariat" then approve_产品="E社通";
else if approve_产品="Elite" then approve_产品="U贷通";
else if approve_产品="Eshetong" then approve_产品="E社通";
else if approve_产品="Ewangtong" then approve_产品="E网通";
else if  approve_产品="Efangtong" then approve_产品="E房通";
else if approve_产品="Efangtong-NoSecurity" then approve_产品="E房通-无社保";
else if approve_产品="Efangtong-zigu" then approve_产品="E房通-自雇";

else if approve_产品="RFElite" then approve_产品="U贷通续贷";
else if approve_产品="RFEbaotong" then approve_产品="E保通续贷";
else if approve_产品="RFEshetong" then approve_产品="E社通续贷";
else if approve_产品="RFSalariat" then approve_产品="E社通续贷";
else if approve_产品="RFEwangtong" then approve_产品="E网通续贷";
else if approve_产品="Ebaotong-zigu" then approve_产品="E保通-自雇";
else if approve_产品="Ebaotong-NoSecurity" then approve_产品="E保通-无社保";
else if approve_产品="Ezhaitong" then approve_产品="E宅通";
else if approve_产品="Ezhaitong-zigu" then approve_产品="E宅通-自雇";
else if approve_产品="Ezhaitong-NoSecurity" then approve_产品="E宅通-无社保";
else if approve_产品="Eweidai" then approve_产品="E微贷";
else if approve_产品="Eweidai-NoSecurity" then approve_产品="E微贷-无社保";
else if approve_产品="Eweidai-zigu" then approve_产品="E微贷-自雇";

if kindex(approve_产品,"Easy") then approve_产品 ="E易贷";

if kindex(DESIRED_PRODUCT,"RF") and not kindex(approve_产品,"续贷") then pproduct_code=compress(approve_产品||"续贷") ;
if pproduct_code^="" then approve_产品=pproduct_code;

run;

data dta.check_result;
set check_result;
run;

data check_result;
set check_result;
keep apply_code 批核状态 批核产品大类_终审 批核产品小类_终审 批核金额_终审 批核期限_终审
REFUSE_INFO_NAME REFUSE_INFO_NAME_LEVEL1  REFUSE_INFO_NAME_LEVEL2 REFUSE_INFO_NAME_final REFUSE_INFO_NAME_LEVEL1_final
REFUSE_INFO_NAME_LEVEL2_final CANCEL_REMARK FACE_SIGN_REMIND 
 approve_产品 created_name_first created_name_final updated_time_first updated_time_final
check_date 批核月份 通过 拒绝 check_end check_week PROPOSE_LIMIT_first PROPOSE_LIMIT_final;
run;


*【签约】;
data sign_contract;
set approval.contract(keep = apply_no contract_no net_amount contract_amount service_fee_amount documentation_fee sign_date );
rename apply_no = apply_code net_amount = 到手金额 contract_amount = 合同金额 service_fee_amount = 服务费 documentation_fee = 单证费;
format 签约时间   yymmdd10.;
签约时间=mdy(month(sign_date),day(sign_date),year(sign_date));
if 签约时间^=.;
run;
proc sort data=sign_contract nodupkey;by apply_code;run;

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
/*apply_code = tranwrd(contract_no, "C", "PL");*/
放款月份 = put(loan_date, yymmn6.);
format 放款日期  yymmdd10.;
放款日期=mdy(month(loan_date),day(loan_date),year(loan_date));
rename capital_channel_code = 资金渠道;
format apply_code $45.;
apply_code = tranwrd(contract_no,"C","PL");
drop status 放款状态 loan_date contract_no;
run;

proc sort data = loan_info nodupkey;by apply_code;run;
data sign_loan;
merge sign_contract(in =a) loan_info;
by apply_code;
if a ;
run;

data dta.sign_loan;
set sign_loan;
run;

/*自动拒绝*/
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
proc sort data = auto_reject_db nodupkey;by apply_code;
run;


data dta.auto_reject_db;
set auto_reject_db;
run;

data approval;
merge apply_dept(in = a ) apply back cur_status auto_reject_db  check_result sign_loan ; 
by apply_code;
run;

data dta.app_loan_info;
set approval;
run;

/*申请前取消-在录入申请和录入复核环节取消的*/
data cancel_before;
set approval.apply_refusecancel_history;
where current_period in ("inputCheckTask", "inputTask") and type_name="cancel "; 
cancel_before=1;
keep apply_code cancel_before first_root_reason_code first_root_reason_name first_root_reason_code2 first_root_reason_name2;
run;
data dta.cancel_before;
set cancel_before;
run;

proc sql;
create table backtodept(where=(BRANCH_NAME^="")) as
select a.*,b.BRANCH_NAME from back as a
left join apply_dept(where=(not kindex(DESIRED_PRODUCT,"RF"))) as b on a.apply_code=b.apply_code;
quit;
/*进件*/
proc sql;
create table Partone_apply as select  branch_name,sum(进件) as 进件数
from approval(where=(&tabledate.>=进件时间>=&month_begin.)) group by branch_name ;quit;
/*回退*/
proc sql;
create table Partone_back as select  branch_name,sum(回退门店) as 回退数
from approval(where=(&tabledate.>=回退门店时间>=&month_begin. )) group by branch_name ;quit;
/*通过*/
proc sql;
create table Partone_accept as select  branch_name,sum(通过) as 通过量
from approval(where=(&tabledate.>=check_date>=&fk_month_begin. )) group by branch_name ;quit;
/*放款个数，放款量*/
proc sql;
create table Partone_amount as select  branch_name,sum(合同金额) as 放款量,count(合同金额) as 放款数
from approval(where=(&tabledate.>=放款日期>=&fk_month_begin. )) group by branch_name ;quit;


data Partone_cumulate_end;
merge Partone_apply Partone_back Partone_accept Partone_amount;
by branch_name;
array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run;


/*proc  sql;*/
/*create table cc  as  select sum(合同金额) as 合同金额 from dta.app_loan_info(where=(放款月份^="" and 当前状态="结束")) ;quit;*/




data approval;
set dta.app_loan_info;
run;
proc sort data = approval;by apply_code;run;

libname appro odbc datasrc=approval_nf;

/*申请人信息汇总*/
data province;
set res.optionitem(where = (groupCode = "province"));
keep itemCode itemName_zh;
run;
data city;
set res.optionitem(where = (groupCode = "city"));
keep itemCode itemName_zh;
run;
data region;
set res.optionitem(where = (groupCode = "region"));
keep itemCode itemName_zh;
run;
data education;
set res.optionitem(where = (groupCode = "EDUCATION"));
keep itemCode itemName_zh;
run;
data gender;
set res.optionitem(where = (groupCode = "GENDER"));
keep itemCode itemName_zh;
run;
data marriage;
set res.optionitem(where = (groupCode = "MARRIAGE"));
keep itemCode itemName_zh;
run;
data house_property;
set res.optionitem(where = (groupCode = "PROPERTYTYPE"));
keep itemCode itemName_zh;
run;
data comp_type;
set res.optionitem(where = (groupCode = "COMPTYPE"));
keep itemCode itemName_zh;
run;
data position;
set res.optionitem(where = (groupCode = "POSITION"));
keep itemCode itemName_zh;
run;
data PERMANENT_TYPE;
set res.optionitem(where = (groupCode = "RegisteredType"));
keep itemCode itemName_zh;
run;
data Nation_TYPE;
set appro.sys_config_detail(where=(SYS_CONFIG_HEADER_ID =83));
keep CONFIG_CODE CONFIG_DESC;
run;

data Nation_TYPE;
set appro.sys_config_detail(where=(SYS_CONFIG_HEADER_ID =83));
keep CONFIG_CODE CONFIG_DESC;
run;
data apply_base;
set approval.apply_base(keep = apply_code PHONE1 ID_CARD_NO RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_TYPE
							PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION LOCAL_RES_YEARS EDUCATION MARRIAGE GENDER RESIDENCE_ADDRESS PERMANENT_ADDRESS CHILD_COUNT nation PHONE1);


/*RESIDENCE-现住址 PERMANENT-户籍地址*/
run;
proc sql;
create table base_info(drop= RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_ADDR_DISTRICT
 LOCAL_RESCONDITION EDUCATION MARRIAGE GENDER PERMANENT_TYPE) as
select a.*, b.itemName_zh as 居住省, c.itemName_zh as 居住市, d.itemName_zh as 居住区,
			e.itemName_zh as 户籍省, f.itemName_zh as 户籍市, g.itemName_zh as 户籍区,
			h.itemName_zh as 住房性质, i.itemName_zh as 教育程度, j.itemName_zh as 婚姻状况, k.itemName_zh as 性别,l.itemName_zh as 户口性质,
			m.CONFIG_DESC as 民族
from apply_base as a
left join province as b on a.RESIDENCE_PROVINCE = b.itemCode
left join city as c on a.RESIDENCE_CITY = c.itemCode
left join region as d on a.RESIDENCE_DISTRICT = d.itemCode
left join province as e on a.PERMANENT_ADDR_PROVINCE = e.itemCode
left join city as f on a.PERMANENT_ADDR_CITY = f.itemCode
left join region as g on a.PERMANENT_ADDR_DISTRICT = g.itemCode
left join house_property as h on a.LOCAL_RESCONDITION = h.itemCode
left join education as i on a.EDUCATION = i.itemCode
left join marriage as j on a.MARRIAGE = j.itemCode
left join gender as k on a.GENDER = k.itemCode
left join PERMANENT_TYPE as l on a.PERMANENT_TYPE = l.itemCode
left join Nation_TYPE as m on a.nation=m.CONFIG_CODE
;
quit;
data apply_assets;
set approval.apply_assets;
if IS_HAS_HOURSE ="y" and IS_HAS_CAR="y"  then 财产信息 = "有房有车";
else if IS_HAS_HOURSE ="y" and IS_HAS_CAR="n"  then 财产信息 = "有房无车";
else if IS_HAS_HOURSE ="n" and IS_HAS_CAR="y"  then 财产信息 = "有车无房";
else  财产信息 = "无车无房";

keep APPLY_CODE housing_property IS_HAS_HOURSE IS_HAS_CAR 财产信息 IS_HAS_INSURANCE_POLICY HOURSE_COUNT CAR_COUNT IS_LIVE_WITH_PARENTS HOURSE_MONTHLY_PAYMENT;
run;
data apply_insurance;
set appraw.apply_insurance;
format 缴费方式 $10.;
if INSURANCE_PAY_METHOD="01" then do  ;缴费方式="月缴"; 年缴金额=INSURANCE_PAY_AMT*12;   end;
else if INSURANCE_PAY_METHOD="02" then do; 缴费方式="季缴";年缴金额=INSURANCE_PAY_AMT*4;   end;
else if INSURANCE_PAY_METHOD="03" then do;缴费方式="半年缴";年缴金额=INSURANCE_PAY_AMT*2;   end;
else if INSURANCE_PAY_METHOD="04" then do;缴费方式="年缴";年缴金额=INSURANCE_PAY_AMT;   end;

keep apply_code INSURANCE_COMPANY INSURANCE_PAY_AMT INSURANCE_PAY_METHOD INSURANCE_EFFECTIVE_DATE  缴费方式 年缴金额;
run;

proc sort data = apply_assets;by apply_code;run;
proc sort data = apply_insurance;by apply_code;run;

data apply_insurance;
set apply_insurance ;
retain 总缴费金额 ;
by apply_code;
if first.apply_code then 总缴费金额=年缴金额;
else 总缴费金额=总缴费金额+年缴金额;
run;
proc sort data = apply_insurance;by apply_code descending 总缴费金额;run;
proc sort data = apply_insurance nodupkey;by apply_code ;run;


data apply_assets;
merge apply_assets apply_insurance;
by apply_code;
run;

proc sql;
create table assets_info(drop=housing_property) as
select a.*, b.itemName_zh as 房产性质
from apply_assets as a
left join house_property as b on a.housing_property = b.itemCode
;
quit;
proc import out = ccoc datafile = "D:\share\Datamart\cs\wenjie\已补录CCOC码.xls" dbms = excel replace;
	getnames = yes;
run;

data industry;
set res.optionitem(where = (groupCode = "industry-1"));
keep itemCode itemName_zh;
run;
data CC;
set res.optionitem(where = (groupCode = "industry-2"));
keep itemCode itemName_zh;
run;
data OC;
set res.optionitem(where = (groupCode = "OC"));
keep itemCode itemName_zh;
run;

proc sql;
create table ccoc_info as
select a.apply_code, b.itemName_zh as 类别码, c.itemName_zh as CC码, d.itemName_zh as OC码
from ccoc as a
left join industry as b on a.industry_code = b.itemCode
left join CC as c on a.cc_code = c.itemCode
left join OC as d on a.oc_code = d.itemCode
;
quit;
/*---------------------补录的CCOC码 start-------------------------------------*/

data apply_emp;
set approval.apply_emp(keep = apply_code COMP_NAME position comp_type COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT START_DATE_4_PRESENT_COMP
							CURRENT_INDUSTRY WORK_YEARS COMP_ADDRESS TITLE WORK_CHANGE_TIMES START_DATE_4_PRESENT_COMP);

							format 入职时间 yymmdd10.;
入职时间 = datepart(START_DATE_4_PRESENT_COMP);
							drop START_DATE_4_PRESENT_COMP;
run;
proc sql;
create table emp_info(drop= COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT position comp_type START_DATE_4_PRESENT_COMP) as
select a.*, b.itemName_zh as 单位省, c.itemName_zh as 单位市, d.itemName_zh as 单位区,
			e.itemName_zh as 职级, f.itemName_zh as 单位性质
from apply_emp as a
left join province as b on a.COMP_ADDR_PROVINCE = b.itemCode
left join city as c on a.COMP_ADDR_CITY = c.itemCode
left join region as d on a.COMP_ADDR_DISTRICT = d.itemCode
left join position as e on a.position = e.itemCode
left join comp_type as f on a.comp_type = f.itemCode
;
quit;

data apply_ext_data;
set approval.apply_ext_data(keep = apply_code INDUSTRY_NAME CC_NAME OC_NAME CC_code oc_code);
run;




data apply_balance;
set approval.apply_balance(keep = apply_code yearly_income monthly_salary monthly_other_income monthly_expense PUBLIC_FUNDS_RADICES SOCIAL_SECURITY_RADICES SALARY_PAY_WAY PAY_DAY);
run;

data debt_ratio;
set approval.debt_ratio(keep = apply_no loan_month_return card_used_amt_sum social_security_month fund_month bank_flow_month
							other_income_month liability_month debt_ratio UPDATED_TIME);
rename apply_no = apply_code;
run;

data liability_ratio;
set approval.liability_ratio(keep = apply_no loan_month_return card_used_amt_sum SEMI_CARD_OVERDRAFT_BALANCE verify_income VERIFY_PAYROLL_CREDIT 
								  OTHER_LIABILITIES ratio NEW_RATIO WEI_LI_LOAN_AMT);
rename apply_no = apply_code
       loan_month_return=loan_month_return_new
       card_used_amt_sum=card_used_amt_sum_new
	   WEI_LI_LOAN_AMT = 微粒贷额度;
run;

data salarypayway;
set res.optionitem(where = (groupCode = "SALARYPAYWAY"));
keep itemCode itemName_zh;
run;
proc sql;
create table balance_info(drop=SALARY_PAY_WAY) as select a.*,b.itemName_zh as 薪资发放方式   from  apply_balance as  a left join salarypayway as  b on a.SALARY_PAY_WAY =b.itemCode;quit;

data apply_info;
set approval.apply_info
(keep = apply_code name id_card_no SALES_CODE SALES_NAME MANAGER_CODE MANAGER_NAME    );
run;

data apply_time1;
set approval.act_opt_log(where = (task_Def_Name_ = "录入复核" and action_ = "COMPLETE")); /*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
input_complete=1;/*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
keep bussiness_key_ create_time_ input_complete;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time1 dupout = a nodupkey; by apply_code apply_time; run;
proc sort data = apply_time1 nodupkey; by apply_code; run;
proc sort data = apply_info nodupkey; by apply_code; run;
data apply_time;
merge apply_time1(in = a) apply_info(in = b);
by apply_code;
if b;

run;

proc sort data = credit.credit_report(keep=report_number id_card created_time) out = credit_report nodupkey; by report_number; run;
proc sort data=credit.credit_info_base out=report_date(keep=report_number real_name report_date CREDIT_VALID_ACCT_SUM) nodupkey; by report_number; run;

/*信用卡贷款明细加上报告日期*/
proc sort data=credit.credit_detail out=credit_detail; by report_number; run;

data credit_detail;
merge credit_detail(in=a) report_date(in=b);
by report_number;
if a;
open_month = intck("month", DATE_OPENED, report_date);
update_month = intck("month", LAST_UPDATE_DATE, report_date);
if day(DATE_OPENED) <day(report_date) then open_month=open_month+1;
if day(LAST_UPDATE_DATE) <day(report_date) then update_month=update_month+1;

if DATE_OPENED >= intnx("month", report_date, -6, "same") then in6month = 1; else in6month = 0;
if DATE_OPENED >= intnx("month", report_date, -24, "same") then in24month = 1; else in24month = 0;
if credit_line_amt=. then credit_line_amt=0;
if usedcredit_line_amt=. then usedcredit_line_amt=0;
run;
/*是否白户定义 step 2,3,4*/

data no_credit;
set credit_detail;
if  BUSI_TYPE="CREDIT_CARD" or BUSI_TYPE="LOAN" ;
if update_month>24  and  (ACCT_STATUS="3"  or ACCT_STATUS="14")  then step2=1;
else if ACCT_STATUS="16"  then step3_1=1;
else if BUSI_TYPE="LOAN"  and open_month<=3  then step3_2=1;
else if BUSI_TYPE="CREDIT_CARD" and open_month<=3 and usedcredit_line_amt=0 then step4=1;
run;

proc sql ;
create table no_credit_1 as select a.* ,b.信用卡记录,c.贷款记录,d.* from
(select report_number,count(*) as 信贷记录 from credit_detail group by  report_number ) as a
left join 
(select report_number,count(*) as 信用卡记录 from credit_detail(where=(BUSI_TYPE="CREDIT_CARD")) group by  report_number ) as b on a.report_number=b.report_number
left join 
(select report_number,count(*) as 贷款记录 from credit_detail(where=( BUSI_TYPE="LOAN")) group by  report_number ) as c on a.report_number=c.report_number
left join 
(select report_number,count(step2) as step2,count(step3_1) as step3_1
,count(step3_2) as step3_2,count(step4) as step4 from  no_credit group by report_number) as d  on a.report_number=d.report_number;quit;


data no_credit_2;
set no_credit_1;
if sum(信用卡记录,贷款记录,-step2,-step3_1,-step3_2,-step4) =0 then 白户=1;
run;


/*是否白户定义--- end */

data card_detail;
set credit_detail(where=(SUB_BUSI_TYPE="贷记卡"));
if  intck("month", DATE_OPENED,LAST_UPDATE_DATE ) >= 12  and CREDIT_LINE_AMT>=10000  and CURRENCY_TYPE ="人民币"  then 额度满一年=1;
run;

proc sql;
create table card_pastdue_total as
select report_number, sum(PASTDUE_AMT) as card_pastdue_total
from card_detail
group by report_number
;
quit;


data loan_detail;
set credit_detail(where=(BUSI_TYPE="LOAN"));
if LOAN_BALANCE=. then LOAN_BALANCE=0;
if index(sub_busi_type, "汽车") or index(sub_busi_type, "商用房") or index(sub_busi_type, "住房") then   抵押贷款 = 1;
if not(index(sub_busi_type, "汽车") or index(sub_busi_type, "商用房") or index(sub_busi_type, "住房") 
or index(sub_busi_type, "助学") or index(sub_busi_type, "农户") )then do;
	if index(sub_busi_type,"其他") and  LOAN_BALANCE =CREDIT_LINE_AMT and DATE_OPENED ^=DATE_CLOSED then 无抵押贷款=0;
	else 无抵押贷款=1;

end;

if ACCT_STATUS="1"  and 无抵押贷款=1 then do;
		未结清无抵押贷款=1;
		if kindex(ORG_NAME,"银行") then 银行未结清无抵押贷款=1;
		else if kindex(ORG_NAME,"消费金融") then 消费金融未结清无抵押贷款=1;
		else 其他未结清无抵押贷款=1;
end;

if  ACCT_STATUS="1" then do;
	未结清贷款=1
;未结清月还=MONTHLY_PAYMENT;

end;

/*loan_q=intck("month", DATE_OPENED, date_closed);*/
/*if 12=<loan_q<=48 and credit_line_amt >then */

run;


proc sql;
create table loan_pastdue_sum as
select report_number, sum(pastdue_amt) as loan_pastdue_sum,sum(抵押贷款) as 名下抵押贷款,sum(无抵押贷款) as 无抵押贷款,sum(未结清无抵押贷款) as 未结清无抵押贷款,
sum(未结清贷款) as 未结清贷款,sum(银行未结清无抵押贷款) as 银行未结清无抵押贷款,sum(消费金融未结清无抵押贷款) as 消费金融未结清无抵押贷款,sum(其他未结清无抵押贷款) as 其他未结清无抵押贷款,sum(未结清月还) as 征信月还款总额
from loan_detail
group by report_number
;
quit;

proc sort data=credit.credit_query_record out=credit_query_record; by report_number; run;
data credit_query_record;
merge credit_query_record(in=a) report_date(in=b);
by report_number;
if a;
if query_date >= intnx("month", report_date, -1, "same") then in1month = 1; else in1month = 0;
if query_date >= intnx("month", report_date, -3, "same") then in3month = 1; else in3month = 0;
if query_date >= intnx("month", report_date, -6, "same") then in6month = 1; else in6month = 0;
if query_date >= intnx("month", report_date, -12, "same") then in12month = 1; else in12month = 0;
if query_date >= intnx("month", report_date, -24, "same") then in24month = 1; else in24month = 0;

run;

data loan_query;
set credit_query_record(where = (QUERY_REASON in ("1", "8", "3")));
length 查询机构 $50;
if index(QUERY_ORG, "/") then 查询机构 = scan(QUERY_ORG, 1, "/"); else 查询机构 = QUERY_ORG;
run;
proc sort data = loan_query; by report_number 查询机构 descending query_date; run;


data loan_query;
set loan_query;
by report_number 查询机构;
format query_dt yymmdd10.;
format query_mon yymmn6.;
retain query_dt;
	 if first.查询机构 then query_dt = query_date;
else if intck("day", query_date, query_dt) <= 30 then del = 1;
else query_dt = query_date;
query_mon = intnx("month", query_dt,0, "b");
if kindex(查询机构,"消费金融") and in3month=1 then 消费金融 =1 ;
run;




proc sql;
create table loan_query_in3m as
select report_number,
		sum(in3month) as loan_query_in3m,
		sum(消费金融) as 消费金融,
		sum(sum(in3month) ,- sum(消费金融),0) as quxiao
from loan_query
where del ^= 1 
group by report_number
;
quit;



/*BUG 有些客户没法匹配到征信信息 因为身份证号码带※*/
proc sort data = credit.credit_report(keep=report_number id_card created_time) out = credit_report nodupkey; by report_number; run;
proc sql;
create table  pboc_info_pre as
select a.*,datepart(a.created_time) as 征信获取时间 format=yymmdd10.,b.card_pastdue_total as 信用卡当前逾期金额,c.loan_pastdue_sum as 贷款当前逾期金额,
sum(b.card_pastdue_total,c.loan_pastdue_sum) as 当前逾期金额总计,c.名下抵押贷款,c.无抵押贷款,c.未结清无抵押贷款,c.未结清贷款,c.银行未结清无抵押贷款,
c.消费金融未结清无抵押贷款,c.其他未结清无抵押贷款,c.征信月还款总额,d.消费金融 as 消金查询次数,e.信贷记录 ,e.白户  from credit_report as a
left join card_pastdue_total as b on a.report_number=b.report_number
left join loan_pastdue_sum as c on a.report_number=c.report_number
left join loan_query_in3m as d on a.report_number=d.report_number
left join no_credit_2  as e on a.report_number=e.report_number;
quit;



proc sql;
create table pboc_info as
select a.apply_code, b.*
from apply_time as a
inner join pboc_info_pre as b on a.id_card_no = b.id_card and datepart(a.apply_time) >= datepart(b.created_time)
;
quit;
proc sort data = pboc_info nodupkey; by apply_code descending created_time; run;
proc sort data = pboc_info  nodupkey; by apply_code; run;

data query_in3month;
set credit.credit_derived_data(keep = REPORT_NUMBER SELF_QUERY_03_MONTH_FREQUENCY_SA  CARD_APPLY_03_MONTH_FREQUENCY_SA CARD_60_PASTDUE_FREQUENCY
LOAN_GUARANTEE_QUERY_03_MONTH_FR LOAN_GUARANTEE_QUERY_24_MONTH_FR CARD_APPLY_24_MONTH_FREQUENCY CARD_CREDIT_LINE_AMT_SUM CARD_USEDCREDIT_LINE_AMT_SUM CARD_OVER_100PCT
SELF_QUERY_24_MONTH_FREQUENCY_SA LOAN_GUARANTEE_QUERY_01_MONTH_FR CARD_APPLY_01_MONTH_FREQUENCY_SA SELF_QUERY_01_MONTH_FREQUENCY_SA
CARD_60_PASTDUE_M3_FREQUENCY LOAN_MORTGAGE_60_PASTDUE_FREQUEN LOAN_MORTGAGE_PASTDUE_M3_FREQUEN LOAN_NAMORTGAGE_60_PASTDUE_FREQU LOAN_NAMORTGAGE_PASTDUE_M3_FREQU 
LOAN_OTHER_60_PASTDUE_FREQUENCY LOAN_OTHER_PASTDUE_M3_FREQUENCY SELF_QUERY_06_MONTH_FREQUENCY LOAN_MAX_CREDIT_LINE_AMT CARD_FIRST_OPEN_MONTH CARD_MAX_CREDIT_LINE_AMT LOAN_UNCLEARED_CREDIT_LINE_AMT_S
LOAN_BALANCE_SUM );
rename  LOAN_GUARANTEE_QUERY_03_MONTH_FR = 近3个月贷款查询次数
		SELF_QUERY_03_MONTH_FREQUENCY_SA = 近3个月本人查询次数
		CARD_APPLY_03_MONTH_FREQUENCY_SA=近3个月信用卡查询次数
		LOAN_GUARANTEE_QUERY_24_MONTH_FR=近2年贷款查询次数
CARD_APPLY_24_MONTH_FREQUENCY=近2年信用卡查询次数
SELF_QUERY_24_MONTH_FREQUENCY_SA=近2年个人查询次数
CARD_60_PASTDUE_FREQUENCY=贷记卡近5年逾期次数
CARD_60_PASTDUE_M3_FREQUENCY=贷记卡近5年逾期90以上次数
LOAN_MORTGAGE_60_PASTDUE_FREQUEN=抵押贷款近5年逾期次数
LOAN_MORTGAGE_PASTDUE_M3_FREQUEN=抵押贷款近5年逾期90天以上次数
LOAN_NAMORTGAGE_60_PASTDUE_FREQU=无抵押贷款近5年逾期次数
LOAN_NAMORTGAGE_PASTDUE_M3_FREQU=无抵押贷款近5年逾期90天以上次数
LOAN_OTHER_60_PASTDUE_FREQUENCY=其他性质贷款近5年逾期次数
LOAN_OTHER_PASTDUE_M3_FREQUENCY=其他性质贷款近5年逾期90天以上
LOAN_GUARANTEE_QUERY_01_MONTH_FR=近1个月贷款查询次数
CARD_APPLY_01_MONTH_FREQUENCY_SA=近1个月信用卡查询次数
CARD_OVER_100PCT=信用卡使用率
CARD_CREDIT_LINE_AMT_SUM=信用卡总额
CARD_USEDCREDIT_LINE_AMT_SUM=信用卡透支总额
SELF_QUERY_06_MONTH_FREQUENCY=近6个月本人查询次数
SELF_QUERY_01_MONTH_FREQUENCY_SA=近1个月本人查询次数
LOAN_MAX_CREDIT_LINE_AMT=贷款最大额度
CARD_FIRST_OPEN_MONTH =信用卡最久账户距今时长
CARD_MAX_CREDIT_LINE_AMT=信用卡最大额度
LOAN_UNCLEARED_CREDIT_LINE_AMT_S = 征信贷款总额
LOAN_BALANCE_SUM= 征信使用总额
;
run;

proc sql;
create table pboc_info1 as
select a.*,b.近3个月本人查询次数,b.近3个月贷款查询次数,b.近2年贷款查询次数,b.近2年信用卡查询次数,b.近3个月信用卡查询次数,b.信用卡使用率,b.信用卡总额,b.信用卡透支总额,
b.贷记卡近5年逾期次数,b.贷记卡近5年逾期90以上次数,b.抵押贷款近5年逾期次数,b.抵押贷款近5年逾期90天以上次数,b.无抵押贷款近5年逾期次数,b.无抵押贷款近5年逾期90天以上次数,
b.其他性质贷款近5年逾期次数,b.其他性质贷款近5年逾期90天以上,b.贷款最大额度,b.信用卡最大额度,b.信用卡最久账户距今时长,b.征信贷款总额,b.征信使用总额,
b.近2年个人查询次数,b.近1个月贷款查询次数,b.近1个月信用卡查询次数,b.近1个月本人查询次数,b.近6个月本人查询次数 from pboc_info as a
left join query_in3month as b on a.REPORT_NUMBER=b.REPORT_NUMBER;
quit;


data TQ_score;
set appraw.apply_identity_match;
if type ="FRACTION";
keep apply_code value;
rename value=天启分;
run;

data TQ_score_his;
set  approval.tq_score;

tianqi_score_loan_dt = compress(tianqi_score_loan_dt1);
keep apply_code tianqi_score_loan_dt;
rename tianqi_score_loan_dt=天启分;
run;

data TQ;
set TQ_score TQ_score_his;
run;


/*上海资信数据*/
libname credit odbc datasrc = credit_nf;


data credit_zx_detail;
set credit.credit_zx_detail;
if SUB_BIZ_TYPE="无抵押贷款" then 无抵押贷款 =1;
run;

proc sql;
create table zx_detail as select apply_code ,sum(CREDIT_LINE_AMT) as 资信贷款总额,sum(USEDCREDIT_LINE_AMT) as 资信使用总额
,sum(MONTHLY_PAYMENT) as 资信月还款总额
from credit_zx_detail(where=(ACCT_STATUS^="结清")) group by apply_code;quit;




proc sort data = base_info nodupkey; by apply_code; run;
proc sort data = emp_info nodupkey; by apply_code; run;
proc sort data = apply_ext_data nodupkey; by apply_code; run;
proc sort data = debt_ratio nodupkey; by apply_code ; run;
proc sort data = assets_info nodupkey; by apply_code; run;
proc sort data = ccoc_info nodupkey; by apply_code; run;
proc sort data = liability_ratio nodupkey; by apply_code; run;
proc sort data = balance_info nodupkey ; by apply_code;run;
proc sort data = pboc_info1 nodupkey;by apply_code;run;
proc sort data = apply_info nodupkey;by apply_code;run;
proc sort data = TQ nodupkey;by apply_code;run;
proc sort data = approval.credit_score out =credit_score(keep = group_Level apply_code)
 nodupkey;by apply_code;run;
data customer_info;
merge approval(in=a keep = apply_code 进件时间)  base_info(in = b) emp_info(in = c) apply_ext_data(in = d) 
 debt_ratio(in = f) assets_info(in = g) ccoc_info(in = h)  liability_ratio(in=i) balance_info pboc_info1 apply_info TQ credit_score zx_detail;
by apply_code;
if a;
/*年龄计算 ID_CARD_NO 取出生年月日计算-实足年龄*/
format age 10.;
format birthdate yymmdd10.;
birth_year=substr(ID_CARD_NO,7,4)+0;
birth_mon=substr(ID_CARD_NO,11,2)+0;
birth_day=substr(ID_CARD_NO,13,2)+0;
birthdate=mdy(birth_mon,birth_day,birth_year);
age=Intck('year',birthdate,进件时间);
drop birth_mon birth_day birth_year;
if 住房性质 = "" then 住房性质 = 房产性质;
if INDUSTRY_NAME = "" then INDUSTRY_NAME = 类别码;
if fund_month=. then fund_month=PUBLIC_FUNDS_RADICES;
if social_security_month=. then social_security_month=SOCIAL_SECURITY_RADICES;
if CC_NAME = "" then CC_NAME = CC码;
if OC_NAME = "" then OC_NAME = OC码;
if loan_month_return_new>0 then loan_month_return=loan_month_return_new;
if card_used_amt_sum_new>0 then card_used_amt_sum=card_used_amt_sum_new;
RATIO = RATIO*100;
NEW_RATIO = NEW_RATIO*100;
简版汇总负债总计 = sum(loan_month_return ,CARD_USED_AMT_SUM ,SEMI_CARD_OVERDRAFT_BALANCE);
format 外地标签 $20.;
if 户籍市="" or 单位市="" then 外地标签="数据缺失";
else if 户籍市^=单位市 then 外地标签="外地";
else 外地标签="本地";
rename loan_month_return = 贷款月还 CARD_USED_AMT_SUM = 信用卡月还 SOCIAL_SECURITY_MONTH = 社保基数 FUND_MONTH = 公积金基数 SEMI_CARD_OVERDRAFT_BALANCE = 准贷记卡月还
		BANK_FLOW_MONTH = 旧银行流水 OTHER_INCOME_MONTH = 旧其他收入 LIABILITY_MONTH = 旧月负债 debt_ratio = 旧月负债率  RATIO = 外部负债率
		VERIFY_INCOME = 核实收入 VERIFY_PAYROLL_CREDIT = 核实代发工资 OTHER_LIABILITIES = 其他负债  NEW_RATIO = 负债率 COMP_NAME=单位名称 TITLE=职位;
drop  类别码 CC码 OC码 birthdate 进件时间;
run;

data customer_info;
merge approval(in=a) customer_info;
by apply_code;
if a;


近3月贷款加个人次数 = sum(近3个月贷款查询次数,近3个月本人查询次数);

if 近6个月本人查询次数<=1 then  SE6_score=71;
else if 近6个月本人查询次数>=7 then SE6_score=33;
else if 近6个月本人查询次数<=4 then SE6_score=59;
else SE6_score=45;

if 近2年个人查询次数<=3 then  SE24_score=71;
else if 近2年个人查询次数<=9 then SE24_score=56;
else if 近2年个人查询次数<=14 then SE24_score=51;
else SE24_score=39;

if 近3月贷款加个人次数<=1 then  ls3_score=82;
else if 近3月贷款加个人次数<=3 then  ls3_score=58;
else if 近3月贷款加个人次数<=6 then  ls3_score=48;
else ls3_score=33;

if 贷款最大额度<=150000 then  LM_score=49;
else if 贷款最大额度>=300001 then LM_score=73;
else LM_score=60;

if 信用卡最久账户距今时长<=109 then  CFO_score=48;
else if 信用卡最久账户距今时长>=131 then CFO_score=72;
else CFO_score=64;

if 信用卡最大额度<=30000 then  CM_score=42;
else if 信用卡最大额度>=100001 then CM_score=69;
else CM_score=65;


if 性别="男" AND 婚姻状况="已婚" then  GM_score=57;
else if 性别="男" AND 婚姻状况 ^="已婚" then GM_score=37;
else GM_score=63;


if 房产性质 IN ("公积金按揭购房","亲属住房","商业按揭房","无按揭购房","组合按揭") then LR_score=64;
else if 房产性质 IN ("自建房","其他") then LR_score=52;
else LR_score=31;

if 1<天启分<468 then  TQ_score=-22;
else if 天启分<=543 then TQ_score=56;
else if 天启分<=619 then TQ_score=56;
else if 天启分<=714 then TQ_score=80;
else TQ_score=80;

if 外地标签="外地" then  loc_score=43;
else loc_score=57;


SCORE = SUM(SE6_score,SE24_score,ls3_score,loc_score,LR_score,GM_score,CM_score,CFO_score,LM_score,TQ_score);
if 天启分<1 then SCORE=0;

format GROUP $45. GROUP1 GROUP2;
if SCORE<1 then do GROUP ="缺失";GROUP1 =0; end;
else IF 1<SCORE<=480 THEN do GROUP ="-480";GROUP1 =480;end;
ELSE IF SCORE <=500 THEN do GROUP ="481-500";GROUP1 =500;end;
ELSE IF SCORE <= 520 THEN do GROUP ="501-520";GROUP1 =520;end;
ELSE IF SCORE <=540 THEN do GROUP="521-540";GROUP1 =540;end;
ELSE IF SCORE <=560 THEN do GROUP="541-560";GROUP1 =560;end;
ELSE IF SCORE <=580 THEN do  GROUP="561-580";GROUP1 =580;end;
ELSE IF SCORE <=600 THEN do GROUP="581-600";GROUP1 =600;end;
ELSE IF SCORE <=620 THEN do GROUP="601-620";GROUP1 =620;end;
ELSE IF SCORE >=621 THEN do GROUP="621-";GROUP1 =700;end;
ELSE GROUP ="缺失";

if branch_name in ("乌鲁木齐市第一营业部","伊犁市第一营业部","库尔勒市第一营业部")  
	then do
		营业部区域="一类";
		if SCORE<1 then GROUP2=0;
		else if 1<SCORE<480 then GROUP2=6;
		else if  SCORE<565 then GROUP2=2;
		else if  SCORE>=565 then GROUP2=1;
	end;

else if  branch_name in ("北京市第一营业部","赤峰市第一营业部","上海福州路营业部","福州五四路营业部","怀化市第一营业部","郑州市第一营业部","厦门市第一营业部","深圳市第一营业部",
"江门市业务中心","盐城市第一营业部","武汉市第一营业部","红河市第一营业部","南通市业务中心","南京市业务中心") 
	then do  
		营业部区域="三类";
		if SCORE<1 then GROUP2=0;

		else if 1<SCORE<545 then GROUP2=6;
		else if  SCORE<565 then GROUP2=5;
		else if  SCORE<620 then GROUP2=4;
		else if  SCORE>=620 then GROUP2=2;

	end;


else do
		营业部区域="二类";
		if SCORE<1 then GROUP2=0;

		else if 1<SCORE<515 then GROUP2=6;
		else if  SCORE<555 then GROUP2=5;
		else if  SCORE<570 then GROUP2=4;
		else if  SCORE<605 then GROUP2=3;
		else if  SCORE<630 then GROUP2=2;
		else if  SCORE>=630 then GROUP2=1;
	end;

 if GROUP2=6 then model_level="F";
else if   GROUP2=5 then model_level="E" ;
else if  GROUP2=4 then model_level="D";
else if   GROUP2=3 then model_level="C";
else if  GROUP2=2 then model_level="B";
else if  GROUP2=1 then model_level="A";

run;


data dta.customer_info;
set customer_info;
drop apply_time;
run;


data apply_demo;
set customer_info;

/*教育分类*/
if  教育程度="硕士及其以上" then  EDUCATION=0;
if 教育程度="大学本科" then  EDUCATION=1;
if  教育程度="专科" then EDUCATION=2;
if  教育程度="高中" then EDUCATION=3;
if 教育程度="中专" then EDUCATION=4;
if  教育程度="初中" then EDUCATION=5;
if 教育程度="小学" then  EDUCATION=6;
if  教育程度="未知" then  EDUCATION=7;
if 教育程度=" " then  EDUCATION=8;
/*婚姻状况*/
if 婚姻状况="未婚" then  MARRIAGE=0;
if 婚姻状况="已婚" then MARRIAGE=1;
if 婚姻状况="丧偶" then MARRIAGE=2;
if 婚姻状况="离异" then  MARRIAGE=3;
if 婚姻状况=" " then  MARRIAGE=4;
drop  教育程度 婚姻状况;
/*性别*/
if  性别="男" then GENDER1=0 ; 
if 性别="女" then GENDER1=1 ; 
else if 性别="" then GENDER1=2 ;
/*邮件信息*/
/*if EMAIL^="" and EMAIL^="无"  then IS_HAS_Email=1;*/
/*else IS_HAS_Email=0;*/
/*房产信息*/
if IS_HAS_HOURSE="y" then IS_HAS_HOURSE1=1;
else if IS_HAS_HOURSE="n" then IS_HAS_HOURSE1=0;
else IS_HAS_HOURSE1=2;

if IS_HAS_CAR="y" then IS_HAS_CAR1=1;
else if IS_HAS_CAR="n" then IS_HAS_CAR1=0;
else IS_HAS_CAR1=2;

if IS_LIVE_WITH_PARENTS="y"  then IS_LIVE_WITH_PARENTS1=1;
else if IS_LIVE_WITH_PARENTS="n" then IS_LIVE_WITH_PARENTS1=0;
else IS_LIVE_WITH_PARENTS1=2;

if IS_HAS_INSURANCE_POLICY="y" then IS_HAS_INSUR=1;
else IS_HAS_INSUR=0;
drop 性别  IS_HAS_HOURSE IS_LIVE_WITH_PARENTS IS_HAS_INSURANCE_POLICY IS_HAS_CAR;
/*居住地址*/

/*if 居住省 in ("") then ;*/


/*年龄 age*/
format age_g $20.;
if age<18 then age_g=0;
else if age>=18 and age<=25 then age_g=1;
else if age>25 and age<=30 then age_g=2;
else if age>30 and age<=35 then age_g=3;
else if age>35 and age<=40 then age_g=4;
else if age>40 and age<=45 then age_g=5;
else if age>45 and age<=55 then age_g=6;
else if age>55 and age<=60 then age_g=7;
else if age>60  then age_g=8;

/*子女个数 CHILD_COUNT*/
if CHILD_COUNT=0 or CHILD_COUNT=. then CHILD_COUNT_G=0;
else if CHILD_COUNT=1 then CHILD_COUNT_G=1;
else if CHILD_COUNT=2 then CHILD_COUNT_G=2;
else if CHILD_COUNT>2 then CHILD_COUNT_G=3;
/*本市生活时长 LOCAL_RES_YEARS*/
if LOCAL_RES_YEARS>=0 and LOCAL_RES_YEARS<1 then LOCAL_RES_YEARS_G=0;
else if LOCAL_RES_YEARS>=1 and LOCAL_RES_YEARS<3 then LOCAL_RES_YEARS_G=1;
else if LOCAL_RES_YEARS>=3 and LOCAL_RES_YEARS<5 then LOCAL_RES_YEARS_G=2;
else if LOCAL_RES_YEARS>=5 and LOCAL_RES_YEARS<10 then LOCAL_RES_YEARS_G=3;
else if LOCAL_RES_YEARS>=10 and LOCAL_RES_YEARS<20 then LOCAL_RES_YEARS_G=4;
else if LOCAL_RES_YEARS>=20 then LOCAL_RES_YEARS_G=5;
/*工作变动次数 WORK_CHANGE_TIMES*/
if WORK_CHANGE_TIMES=0 then WORK_CHANGE_TIMES_G=0;
else if WORK_CHANGE_TIMES=1 then WORK_CHANGE_TIMES_G=1;
else if WORK_CHANGE_TIMES=2 then WORK_CHANGE_TIMES_G=2;
else if WORK_CHANGE_TIMES>=3 then WORK_CHANGE_TIMES_G=3;


/*工作年限 work_years*/
format work_years_g $20.;
if work_years=0  then work_years_g=0;
else if work_years<1 then work_years_g=1;
else if work_years<3 then work_years_g=2;
else if work_years<5 then work_years_g=3;
else if work_years<10 then work_years_g=4;
else if work_years<20 then work_years_g=5;
else if work_years>=20 then work_years_g=6;
/*房产套数 HOURSE_COUNT*/
/*存在空值*/
if HOURSE_COUNT=0 then HOURSE_COUNT_G=0;
else if HOURSE_COUNT=1 then HOURSE_COUNT_G=1;
else if HOURSE_COUNT=2 then HOURSE_COUNT_G=2;
else if HOURSE_COUNT>=3 then HOURSE_COUNT_G=3;
else  HOURSE_COUNT_G=4;
/*汽车数量 CAR_COUNT*/
/*存在空值*/

if CAR_COUNT=0 then CAR_COUNT_G=0;
else if CAR_COUNT=. then CAR_COUNT_G=3;
else if CAR_COUNT=1 then CAR_COUNT_G=1;
else if CAR_COUNT>=2 then CAR_COUNT_G=2;

/*总保额 INSURANCE_INSURED_PRICE*/
/*format INSURANCE_INSURED_PRICE_G $20.;*/
/*if INSURANCE_INSURED_PRICE=0 or INSURANCE_INSURED_PRICE=. then INSURANCE_INSURED_PRICE_G=0;*/
/*else if INSURANCE_INSURED_PRICE<=50000 then INSURANCE_INSURED_PRICE_G="1.总保额1-5万";*/
/*else if INSURANCE_INSURED_PRICE<=100000 then INSURANCE_INSURED_PRICE_G="2.总保额6-10万";*/
/*else if INSURANCE_INSURED_PRICE<=500000 then INSURANCE_INSURED_PRICE_G="3.总保额11-50万";*/
/*else if INSURANCE_INSURED_PRICE<=1000000 then INSURANCE_INSURED_PRICE_G="4.总保额51-100万";*/
/*else if INSURANCE_INSURED_PRICE<=2000000 then INSURANCE_INSURED_PRICE_G="5.总保额101-200万";*/
/*else if INSURANCE_INSURED_PRICE<=5000000 then INSURANCE_INSURED_PRICE_G="6.总保额201-500万";*/
/*else if INSURANCE_INSURED_PRICE>5000000 then INSURANCE_INSURED_PRICE_G="7.总保额>500万";*/
/*收入 VERIFY_INCOME*/

if 核实收入<=0 or 核实收入=. then VERIFY_INCOME_G=0;
else if 核实收入<3000 then VERIFY_INCOME_G=1;
else if 核实收入<5000 then VERIFY_INCOME_G=2;
else if 核实收入<8000 then VERIFY_INCOME_G=3;
else if 核实收入<10000 then VERIFY_INCOME_G=4;
else if 核实收入<20000 then VERIFY_INCOME_G=5;
else if 核实收入<30000 then VERIFY_INCOME_G=6;
else if 核实收入<50000 then VERIFY_INCOME_G=7;
else if 核实收入<100000 then VERIFY_INCOME_G=8;
else if 核实收入>=100000 then VERIFY_INCOME_G=9;
/*负债率 RATIO*/
/*format RATIO_G $20.;*/
/*if RATIO=. THEN RATIO=debt_ratio/100;*/
/*if RATIO=0 then RATIO_G="DSR=0";*/
/*else if RATIO<0.1 then RATIO_G="DSR 0-<10%";*/
/*else if RATIO<0.3 then RATIO_G="DSR 10-<30%";*/
/*else if RATIO<0.5 then RATIO_G="DSR 30-<50%";*/
/*else if RATIO<0.6 then RATIO_G="DSR 50-<60%";*/
/*else if RATIO<0.7 then RATIO_G="DSR 60-<70%";*/
/*else if RATIO<0.8 then RATIO_G="DSR 70-<80%";*/
/*else if RATIO<0.9 then RATIO_G="DSR 80-<90%";*/
/*else if RATIO<1 then RATIO_G="DSR 90-<100%";*/
/*else if RATIO<2 then RATIO_G="DSR 100-<200%";*/
/*else if RATIO<3 then RATIO_G="DSR 200-<300%";*/
/*else if RATIO<4 then RATIO_G="DSR 300-<400%";*/
/*else if RATIO<5 then RATIO_G="DSR 400-<500%";*/
/*else if RATIO>=5 then RATIO_G="DSR >=500%";*/

/*居住地与户籍关系*/

if 居住市="" then Res_Type=2;
else if 居住市=户籍市 then Res_Type=0;
else  Res_Type=1;


/*户口类型*/
if 户口性质="本地城镇" then do; PERMANENT_TYPE1=0;;end;
if 户口性质="本地农村"  then do; PERMANENT_TYPE1=1;;end;
if 户口性质="外地城镇" then do; PERMANENT_TYPE1=2;;end;
if 户口性质="外地农村" then do; PERMANENT_TYPE1=3;;end;

/*工资发放路径*/
if 薪资发放方式="现金" then SALARY_PAY_WAY1=0;
if 薪资发放方式="打卡" then SALARY_PAY_WAY1=1;
if 薪资发放方式="银行代发" then SALARY_PAY_WAY1=2;
if 薪资发放方式="其他" then SALARY_PAY_WAY1=3;
if 薪资发放方式="均有" then SALARY_PAY_WAY1=4;
drop 薪资发放方式;
/*供养人数*/

/*房产性质*/
if 房产性质="公积金按揭购房"  then LOCAL_RESCONDITION_G =0;
else if 房产性质="公司宿舍"  then LOCAL_RESCONDITION_G =1;
else if 房产性质="亲属住房"  then LOCAL_RESCONDITION_G =2;
else if 房产性质="商业按揭房"  then LOCAL_RESCONDITION_G =3;
else if 房产性质="无按揭购房"  then LOCAL_RESCONDITION_G =4;
else if 房产性质="自建房"  then LOCAL_RESCONDITION_G =5;
else if 房产性质="租用"  then LOCAL_RESCONDITION_G =6;
else if 房产性质="其他"  then LOCAL_RESCONDITION_G =7;

/*职级*/
if 职级= "非正式员工" then position_G =0;
else if 职级= "负责人" then position_G =1;
else if 职级= "高级管理人员" then position_G =2;
else if 职级= "派遣员工" then position_G =3;
else if 职级= "一般管理人员" then position_G =4;
else if 职级= "一般正式员工" then position_G =5;
else if 职级= "中级管理人员" then position_G =6;
/*单位性质*/
if 单位性质 ="个体" then comp_type=0;
else if 单位性质 ="国有股份" then comp_type=1;
else if 单位性质 ="合资企业" then comp_type=2;
else if 单位性质 ="机关事业单位" then comp_type=3;
else if 单位性质 ="民营企业" then comp_type=4;
else if 单位性质 ="社会团体" then comp_type=5;
else if 单位性质 ="私营企业" then comp_type=6;
else if 单位性质 ="外资企业" then comp_type=7;



if SOCIAL_SECURITY_RADICES>=PUBLIC_FUNDS_RADICES then SOCIAL_PUBLIC_RADICES=SOCIAL_SECURITY_RADICES;
else SOCIAL_PUBLIC_RADICES=PUBLIC_FUNDS_RADICES;

/*公司性质*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*if INDUSTRY_CODE="C01"  then INDUSTRY_CODE=0;*/
/*月还*/
if loan_month_return_new >贷款月还 then 贷款月还 = loan_month_return_new;
if  card_used_amt_sum_new>信用卡月还 then 信用卡月还 = card_used_amt_sum_new;
if 旧月负债率>负债率   then 负债率=旧月负债率;
if 社保基数 >公积金基数  then 基数=社保基数;
else 基数=公积金基数;
/*外地标签*/
if  外地标签="外地"  then  nonlocal=0;
else if 外地标签="本地"  then  nonlocal=1;
else nonlocal=2;
/*财产信息*/
if 财产信息 = "有房有车" then asset = 0;
else if 财产信息 = "有房无车" then asset =1;
else if 财产信息 = "无房有车" then asset = 2;
else if 财产信息 = "无房无车" then asset = 3;

rename 简版汇总负债总计= all  基数=basenumber;
drop  外地标签 单位性质 职级 房产性质 薪资发放方式 房产性质  进件时间 ID_CARD_NO RESIDENCE_ADDRESS PERMANENT_ADDRESS PHONE1 居住省 居住市 居住区 户籍省 户籍市 户籍区
 住房性质 教育程度 单位名称  职位 COMP_ADDRESS  CURRENT_INDUSTRY 工作省 工作市 工作区 INDUSTRY_NAME cc_name oc_name 户口性质  ;
rename 逾期=od;
run;


data dta.apply_demo;
set apply_demo;
drop 	NAME BRANCH_CODE BRANCH_NAME	SOURCE_CHANNEL	DESIRED_PRODUCT
进件	回退门店时间	回退门店	END_ACT_ID_	ACT_ID_	当前状态	auto_reject_time	auto_reject	ID	FIRST_REFUSE_CODE
FIRST_REFUSE_DESC	SECOND_REFUSE_CODE	SECOND_REFUSE_DESC	THIRD_REFUSE_CODE	THIRD_REFUSE_DESC	REFUSE_INFO_NAME
REFUSE_INFO_NAME_LEVEL1	REFUSE_INFO_NAME_LEVEL2	CANCEL_REMARK	FACE_SIGN_REMIND	CREATED_USER_NAME	UPDATED_TIME	
APPROVED_PRODUCT_NAME	APPROVED_SUB_PRODUCT_NAME	LOAN_LIFE	LOAN_AMOUNT	REFUSE_INFO_NAME	REFUSE_INFO_NAME_LEVEL1
REFUSE_INFO_NAME_LEVEL2	CREATED_USER_NAME	UPDATED_TIME	批核状态	check_date	批核月份	check_week	通过	拒绝	check_end	
approve_产品	contract_no	net_amount	contract_amount	service_fee_amount	documentation_fee	sign_date	签约时间	capital_channel_code	
放款月份	放款日期 created_name_first  updated_name_first created_time_first  updated_time_first 批核产品大类_终审  批核产品小类_终审
REFUSE_INFO_NAME_final REFUSE_INFO_NAME_LEVEL1_final REFUSE_INFO_NAME_LEVEL2_final created_name_final  updated_time_final INSURANCE_COMPANY 缴费方式 CREATED_TIME
sales_name  sales_code 财产信息 入职时间; 

run;


/**/
/*libname appRaw odbc  datasrc=approval_nf;*/
/**/
/**/
/*/*工作证明人*/*/
/*data apply_contacts;*/
/*set approval.apply_contacts;*/
/*if relation ="201" ;*/
/*run;
proc  freq data = dta.customer_info;
table approve_产品;
run;


data test;
set dta.customer_info;
rename age=年龄 branch_name=营业部 group_level=分群;
run;


data cc;
set test;
if 进件时间>mdy(05,31,2018) ;
近1月所有查询次数 = sum(近1个月贷款查询次数,近1个月信用卡查询次数,近1个月本人查询次数);
近3月所有查询次数 = sum(近3个月贷款查询次数,近3个月信用卡查询次数,近3个月本人查询次数);
近两年所有查询次数 = sum(近2年贷款查询次数,近2年信用卡查询次数,近2年个人查询次数);

近1月贷款加个人次数 = sum(近1个月贷款查询次数,近1个月本人查询次数);
近3月贷款加个人次数 = sum(近3个月贷款查询次数,近3个月本人查询次数);

/*近6个月个人查询剔除*/
if  approve_产品 = "E易贷-自雇"   and  近6个月本人查询次数 >4 then 近6个月个人查询剔除=1 ;
else if approve_产品 = "E易贷-无社保" and  近6个月本人查询次数 >4 then 近6个月个人查询剔除=1 ;
else if  近6个月本人查询次数 >5 then 近6个月个人查询剔除=1 ;

/*近3个月贷款查询剔除*/
if ( kindex(approve_产品,"U贷通") or kindex(approve_产品,"E贷通")) and 近3月贷款加个人次数 >11 then 近3个月贷款查询剔除=1 ;
else if  kindex(approve_产品,"无社保")  and 近3月贷款加个人次数 >3 then 近3个月贷款查询剔除=1 ;
else if  kindex(approve_产品,"E易贷-自雇")  and 近3月贷款加个人次数 >3 then 近3个月贷款查询剔除=1 ;
else if  近3月贷款加个人次数 >7 then 近3个月贷款查询剔除=1 ;

/*大纲限制人群剔除*/

/*if CC_name  in ("运输/仓储/物流","交通运输/仓储/物流 公共交通运输、仓储、物流")  and   INDUSTRY_NAME="交通运输/仓储/物流" then do ;*/
/*if (not ( kindex(产品大类,"U贷通")) or kindex(产品大类,"E贷通"))  and 外地标签 ="外地" then 大纲限制人群剔除=1 ;*/
/*if 外地标签 ="本地"  and 公积金基数<=3000 and  (not ( kindex(产品大类,"U贷通") or kindex(产品大类,"E贷通")) ) and 核实代发工资<=3000 and 社保基数 <=3000    then 大纲限制人群剔除=1 ;*/
/*end;*/
/**/
/*if   kindex(INDUSTRY_NAME,"制造业") and kindex(CC_name ,"制造业") then do ;*/
/*if (not ( kindex(产品大类,"U贷通")) or kindex(产品大类,"E贷通"))  and 外地标签 ="外地" then 大纲限制人群剔除=1 ;*/
/*if 外地标签 ="本地"  and 公积金基数<=3000 and  (not ( kindex(产品大类,"U贷通") or kindex(产品大类,"E贷通")) ) and 核实代发工资<=3000 and 社保基数 <=3000    then 大纲限制人群剔除=1 ;*/
/*end;*/

/*if (not ( kindex(产品大类,"U贷通") or kindex(产品大类,"E贷通"))) */
/*and  营业部 in ("福州五四路营业部","惠州第一营业部","上海福州路营业部","厦门市第一营业部")  */
/*and ((CC_name  in ("运输/仓储/物流","交通运输/仓储/物流 公共交通运输、仓储、物流")  and   INDUSTRY_NAME="交通运输/仓储/物流" )*/
/*or ( kindex(INDUSTRY_NAME,"制造业") and kindex(CC_name ,"制造业")))then 大纲限制人群剔除=1 ;*/

if  kindex(单位名称,"煤炭") or kindex(单位名称,"煤业") or kindex(单位名称,"煤矿")  then 大纲限制人群剔除=1; 


/*内部审批政策剔除*/

if kindex(营业部,"昆明")  and sum(近2年贷款查询次数,近2年信用卡查询次数,近2年个人查询次数) >=48  then 内部审批政策剔除=1;

if kindex(营业部,"呼和浩特")  and 单位区 ="赛罕区"  and 外部负债率>=300  then 内部审批政策剔除=1;

if kindex(营业部,"杭州") and 职级="退休人员"  and ( kindex(INDUSTRY_NAME,"制造业") and kindex(CC_name ,"制造业"))  then 内部审批政策剔除=1  ;

if kindex(营业部,"杭州") and INDUSTRY_NAME ="教育/科研"  and CC_name ^="科研机构"  and 近两年所有查询次数>=32  then 内部审批政策剔除=1  ;

if kindex(营业部,"郑州")  and 近两年所有查询次数>=40  then 内部审批政策剔除=1 ;

if ( kindex(营业部,"深圳") or   kindex(营业部,"盐城")or  kindex(营业部,"红河")or  kindex(营业部,"武汉")) and 近两年所有查询次数>=32  then 内部审批政策剔除=1 ;

if ( kindex(营业部,"郑州") or   kindex(营业部,"海口")) and (kindex(单位名称,"公安厅") or kindex(单位名称,"公安局")or kindex(单位名称,"武警")or kindex(单位名称,"法院")or kindex(单位名称,"检察院")
or kindex(单位名称,"监狱")or kindex(单位名称,"看守")or kindex(单位名称,"戒毒")or kindex(单位名称,"武装部")or kindex(单位名称,"管教")
or kindex(单位名称,"派出所")or kindex(单位名称,"交通警察")or kindex(单位名称,"消防") ) and 分群^="A" then  内部审批政策剔除=1 ;

if kindex(营业部,"赤峰") and 分群 in ("D","E") and (not ( kindex(approve_产品,"U贷通")) or (kindex(approve_产品,"E贷通")))  and 住房性质 ="租用" then 内部审批政策剔除=1  ;



if kindex(approve_产品,"E网通") then do;
	if kindex(营业部,"上海") and 分群 in ("D","E") and  婚姻状况 ^="已婚"  and IS_HAS_HOURSE^="y" then 内部审批政策剔除=1  ;
	if kindex(营业部,"福州")  and 分群 ="E"  then 内部审批政策剔除=1 ;
	if kindex(营业部,"惠州") or kindex(营业部,"厦门")   then do ;
		if 分群 in ("D","C","E") and 外地标签="外地" and IS_HAS_HOURSE^="y"    then  内部审批政策剔除=1 ;
	end;
end;

if ( kindex(approve_产品,"U贷通") or kindex(approve_产品,"E贷通")) then do;
	if kindex(营业部,"合肥")  and 婚姻状况="离异" and 外部负债率>=300  then 内部审批政策剔除=1;
end;

if kindex(approve_产品,"E保通")  then do;
	if kindex(营业部,"上海")  and (not kindex(approve_产品,"自雇")) and 分群 in ("D","C","E") and 外地标签="外地" and IS_HAS_HOURSE^="y"   then 内部审批政策剔除=1;

	end;

if CC_CODE in ("CC04","CC05") AND 分群 in ("C","D","E","F") and (kindex(营业部,"郑州") or kindex(营业部,"海口"))  THEN 内部审批政策剔除=1;

/*营业部特殊限制剔除*/

if kindex(营业部,"上海") and 年龄>=50 then  营业部特殊限制剔除=1; 

if kindex(营业部,"上海") and 职级="退休人员"  and kindex(approve_产品,"E网通") then 营业部特殊限制剔除=1; 

if kindex(营业部,"福州") and (not ( kindex(approve_产品,"U贷通") or kindex(approve_产品,"E贷通")))   and 单位区= "平潭县" then 营业部特殊限制剔除=1; 

if kindex(营业部,"成都") and kindex(单位市,"眉山市")  then 营业部特殊限制剔除=1 ;
if (kindex(营业部,"赤峰") or kindex(营业部,"成都")or kindex(营业部,"武汉")or kindex(营业部,"盐城") ) and INDUSTRY_NAME ="教育/科研" and CC_name ^="科研机构"   then 营业部特殊限制剔除=1; 

if kindex(营业部,"合肥") and kindex(单位名称,"马钢")  then 营业部特殊限制剔除=1 ;

if kindex(approve_产品,"E保通")  
then do;
	if kindex(营业部,"杭州")  or kindex(营业部,"厦门")  
	then do;
		if 缴费方式="月缴" and INSURANCE_PAY_AMT<600   then  营业部特殊限制剔除=1;
	end;
end;

if kindex(营业部,"郑州") and (kindex(单位区,"新密") or kindex(单位名称,"机务段")) then 营业部特殊限制剔除=1 ;

if kindex(营业部,"邵阳") and (kindex(单位名称,"水") or kindex(单位名称,"机务段")) then 营业部特殊限制剔除=1 ;
if kindex(营业部,"邵阳") and (not ( kindex(approve_产品,"U贷通") or kindex(approve_产品,"E贷通")))  and  CC_name ="电力业" then 营业部特殊限制剔除=1 ;

if kindex(营业部,"怀化") then do ;
	if kindex( 单位区,"靖州")  or kindex(单位区,"新晃")  or kindex(单位区,"麻阳") then do  ; 
		if INDUSTRY_NAME ="教育/科研"  then 营业部特殊限制剔除=1;
	end;
	else if   ( kindex(单位名称,"水") or  kindex(单位名称,"铁路")) then 营业部特殊限制剔除=1;
	else if  kindex(单位名称,"电") and not(kindex(单位名称,"国家电网") and (公积金基数>=8000  or 社保基数>=8000)) then 营业部特殊限制剔除=1;
	else if kindex(单位区,"溆浦县")  then 营业部特殊限制剔除 =1;
	else if kindex(INDUSTRY_NAME,"医院")  then 营业部特殊限制剔除 =1;
end ;

if kindex(营业部,"海口") and 职级="退休人员"  and 居住市 ^="海口市"  and 居住市 ^="三亚市"  then 营业部特殊限制剔除=1  ;

if kindex(营业部,"厦门") and  INDUSTRY_NAME ="建筑业"  then 营业部特殊限制剔除=1 ;

if kindex(营业部,"昆明") and 单位区 in ("石林彝族自治县","富民县") then 营业部特殊限制剔除=1;

if kindex(营业部,"呼和浩特") and (kindex(单位名称,"公安厅") or kindex(单位名称,"公安局")or kindex(单位名称,"武警")or kindex(单位名称,"法院")
or kindex(单位名称,"检察院") or  kindex(单位名称,"集通铁路")
or kindex(单位名称,"监狱")or kindex(单位名称,"看守")or kindex(单位名称,"戒毒")or kindex(单位名称,"武装部")or kindex(单位名称,"管教")
or kindex(单位名称,"派出所")or kindex(单位名称,"交通警察")or kindex(单位名称,"消防"))  then 营业部特殊限制剔除=1;

if kindex(营业部,"乌鲁木齐") and  kindex(单位名称,"电视台") then 营业部特殊限制剔除=1 ;

if kindex(营业部,"赤峰") and ( 单位区 ="巴林右旗"  or 单位区 ="阿鲁科尔沁旗"  or kindex(单位名称,"铁路") 
or kindex(单位名称,"公安厅") or kindex(单位名称,"公安局")or kindex(单位名称,"武警")or kindex(单位名称,"法院")or kindex(单位名称,"检察院")
or kindex(单位名称,"监狱")or kindex(单位名称,"看守")or kindex(单位名称,"戒毒")or kindex(单位名称,"武装部")or kindex(单位名称,"管教")
or kindex(单位名称,"派出所")or kindex(单位名称,"交通警察")or kindex(单位名称,"消防") or  kindex(单位名称,"集通铁路") ) then 营业部特殊限制剔除=1;

if kindex(营业部,"昆明") and ( 单位区 ="石林彝族自治县"  or 单位区 ="富民县"  )then 营业部特殊限制剔除=1;

if kindex(营业部,"南宁") then do;
	if  kindex(单位市,"崇左") or  kindex(居住市,"崇左") then 营业部特殊限制剔除 =1;
	if  kindex(户籍省,"博白")  then 营业部特殊限制剔除 =1;
	if  kindex(户籍省,"福建") then 营业部特殊限制剔除 =1;
	if  kindex(户籍市,"盐城")  then 营业部特殊限制剔除 =1;

	end;

if kindex(营业部,"银川") and 职级="退休人员"   then 营业部特殊限制剔除=1;
if kindex(营业部,"银川")  and (单位市 ="吴忠市" or 居住市="吴忠市")  then  营业部特殊限制剔除=1; 

if kindex(营业部,"北京") and 职级="退休人员"   then 营业部特殊限制剔除=1  ;

if kindex(营业部,"红河")  and 年龄>=50 then  营业部特殊限制剔除=1; 


/*天启分拒绝*/
if 0<天启分<468  and 分群^="A" AND 分群^="B" THEN 天启分限制剔除=1;
;
run;





/*proc sort data = cc out =cc3;by 进件时间 ;run;*/
/**/
/**/
/*data cc1;*/
/*set cc;*/
/*if auto_reject^=1 and 天启分<1;*/
/*run;*/
/*data cc3;*/
/*set cc;*/
/*if mdy(07,12,2018)<进件时间<mdy(07,17,2018)  and  auto_reject^=1 ;*/
/*run;*/
/**/
/*data cc2;*/
/*set tq_score;*/
/*if apply_code ="PL2018071217343162783196";*/
/*run;*/
/**/
/*data cc2;*/
/*set appraw.apply_identity_match;*/
/*if apply_code ="PL2018071217343162783196";*/
/*run;*/
