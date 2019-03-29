/*option compress=yes validvarname=any;*/
/*libname approval 'E:\guan\原数据\approval';*/
/*libname credit  'E:\guan\原数据\cred';*/
/*libname res  'E:\guan\原数据\res';*/
/*libname eam  'E:\guan\原数据\account';*/
/*libname cusMid "E:\guan\中间表\repayfin";*/
/*libname repayFin "E:\guan\中间表\repayfin";*/

data _null_;
format dt yymmdd10.;
dt = today() - 1;
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
run;
/*%let dt=mdy(6,30,2017);*/

data apply_info;
set approval.apply_info
(keep = apply_code name id_card_no branch_code branch_name MANAGER_CODE MANAGER_NAME SALES_NAME SOURCE_BUSINESS SOURCE_CHANNEL LOAN_PURPOSE DESIRED_PRODUCT ACQUIRE_CHANNEL);
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

run;

data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "录入复核" and action_ = "COMPLETE")); /*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
input_complete=1;/*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
format 进件日期 yymmdd10.;
进件日期 = datepart(create_time_);
进件月份 = put(datepart(create_time_), yymmn6.);
rename bussiness_key_ = apply_code create_time_ = apply_time;
keep bussiness_key_ create_time_ input_complete 进件日期 进件月份;
run;
proc sort data = apply_time dupout = a nodupkey; by apply_code apply_time; run;
proc sort data = apply_time nodupkey; by apply_code; run;
proc sort data = apply_info nodupkey; by apply_code; run;
data apply_time;
merge apply_time(in = a) apply_info(in = b);
by apply_code;
if b;
if 进件日期<=&dt.;
run;
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
else 当前状态 = "未知";

rename business_key_ = apply_code; 
run;

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

proc sort data=check_result;by apply_code;run;
proc sort data=apply_time;by apply_code;run;
proc sort data=cur_status;by apply_code;run;
*去掉了一些信心，以后要用的话再看;
data approval;
merge check_result(in=a) apply_time(in=b) cur_status(in=c);
by apply_code;
if b;
if 通过=. and 拒绝=. then check_end=0;
else check_end=1;
format approve_产品 $20.;
if 批核产品大类_终审^="" then approve_产品=批核产品大类_终审;
else if  app_prdname_first^="" then approve_产品= app_prdname_first;
else approve_产品=DESIRED_PRODUCT;
年龄=year(check_date)-ksubstr(ID_CARD_NO,7,4);
if approve_产品="Ebaotong" then approve_产品="E保通";
else if approve_产品="Salariat" then approve_产品="E社通";
else if approve_产品="Elite" then approve_产品="U贷通";
else if approve_产品="Eshetong" then approve_产品="E社通";
else if approve_产品="Ewangtong" then approve_产品="E网通";
else if  approve_产品="Efangtong" then approve_产品="E房通";
else if approve_产品="RFElite" then approve_产品="U贷通续贷";
else if approve_产品="RFEbaotong" then approve_产品="E保通续贷";
else if approve_产品="RFEshetong" then approve_产品="E社通续贷";
else if approve_产品="RFSalariat" then approve_产品="E社通续贷";
else if approve_产品="RFEwangtong" then approve_产品="E网通续贷";
else if approve_产品="Ebaotong-zigu" then approve_产品="E保通-自雇";
else if approve_产品="Ezhaitong" then approve_产品="E宅通";
else if approve_产品="Ezhaitong-zigu" then approve_产品="E宅通-自雇";

else if approve_产品="Eweidai" then approve_产品="E微贷";
else if approve_产品="Eweidai-zigu" then approve_产品="E微贷-自雇";
else if approve_产品="Eweidai-NoSecurity" then approve_产品="E微贷-无社保";
else if approve_产品="Easy-ZhiMa" then approve_产品="Easy贷芝麻分";
else if approve_产品="Easy-CreditCard" then approve_产品="Easy贷信用卡";

if kindex(DESIRED_PRODUCT,"RF") and not kindex(approve_产品,"续贷") then pproduct_code=compress(approve_产品||"续贷") ;
if pproduct_code^="" then approve_产品=pproduct_code;

keep APPLY_CODE REFUSE_INFO_NAME REFUSE_INFO_NAME_LEVEL1 REFUSE_INFO_NAME_LEVEL2 REFUSE_INFO2_NAME REFUSE_INFO2_NAME_LEVEL1 
REFUSE_INFO2_NAME_LEVEL2 REFUSE_INFO3_NAME REFUSE_INFO3_NAME_LEVEL1 REFUSE_INFO3_NAME_LEVEL2 BACK_REASON_NAME BACK_INFO CANCEL_INFO_NAME
created_name_first created_time_first 批核期限_终审 批核金额_终审 created_name_final created_time_final 批核状态 check_date 批核月份 批核日期
NAME ID_CARD_NO 营业部 MANAGER_NAME 进件月份 进件日期 当前状态 approve_产品 check_end SALES_NAME 年龄 DESIRED_PRODUCT 批核产品大类_终审; 
run;
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

data apply_base;
set approval.apply_base(keep = apply_code PHONE1 RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_TYPE
							PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION LOCAL_RES_YEARS EDUCATION MARRIAGE GENDER RESIDENCE_ADDRESS PERMANENT_ADDRESS );
/*RESIDENCE-现住址 PERMANENT-户籍地址*/
run;
proc sql;
create table base_info as
select a.*, b.itemName_zh as 居住省, c.itemName_zh as 居住市, d.itemName_zh as 居住区,
			e.itemName_zh as 户籍省, f.itemName_zh as 户籍市, g.itemName_zh as 户籍区,
			h.itemName_zh as 住房性质, i.itemName_zh as 教育程度, j.itemName_zh as 婚姻状况, k.itemName_zh as 性别,l.itemName_zh as 户口性质
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
left join PERMANENT_TYPE as l on a.PERMANENT_TYPE = l.itemCode;
quit;
data apply_assets;
set approval.apply_assets(keep = apply_code HOUSING_PROPERTY);
run;
proc sql;
create table assets_info as
select a.*, b.itemName_zh as 房产性质
from apply_assets as a
left join house_property as b on a.housing_property = b.itemCode
;
quit;
/*---------------------补录的CCOC码 start-------------------------------------*/
proc import out = ccoc datafile = "E:\guan\催收报表\提前结清名单\已补录CCOC码.xls" dbms = excel replace;
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
							CURRENT_INDUSTRY WORK_YEARS COMP_ADDRESS TITLE);
run;
proc sql;
create table emp_info as
select a.*, b.itemName_zh as 工作省, c.itemName_zh as 工作市, d.itemName_zh as 工作区,
			e.itemName_zh as 职级, c.itemName_zh as 单位性质
from apply_emp as a
left join province as b on a.COMP_ADDR_PROVINCE = b.itemCode
left join city as c on a.COMP_ADDR_CITY = c.itemCode
left join region as d on a.COMP_ADDR_DISTRICT = d.itemCode
left join position as e on a.position = e.itemCode
left join comp_type as f on a.comp_type = f.itemCode
;
quit;

data apply_ext_data;
set approval.apply_ext_data(keep = apply_code INDUSTRY_NAME CC_NAME OC_NAME);
run;



data apply_balance;
set approval.apply_balance(keep = apply_code yearly_income monthly_salary monthly_other_income monthly_expense PUBLIC_FUNDS_RADICES SOCIAL_SECURITY_RADICES);
run;

data debt_ratio;
set approval.debt_ratio(keep = apply_no loan_month_return card_used_amt_sum social_security_month fund_month bank_flow_month
							other_income_month liability_month debt_ratio UPDATED_TIME);
rename apply_no = apply_code;
run;

data liability_ratio;
set approval.liability_ratio(keep = apply_no loan_month_return card_used_amt_sum SEMI_CARD_OVERDRAFT_BALANCE verify_income VERIFY_PAYROLL_CREDIT 
								  OTHER_LIABILITIES ratio NEW_RATIO);
rename apply_no = apply_code
       loan_month_return=loan_month_return_new
       card_used_amt_sum=card_used_amt_sum_new;
run;



proc sort data = apply_info nodupkey; by apply_code; run;
proc sort data = base_info nodupkey; by apply_code; run;
proc sort data = emp_info nodupkey; by apply_code; run;
proc sort data = apply_ext_data nodupkey; by apply_code; run;
proc sort data = apply_balance nodupkey; by apply_code; run;
proc sort data = debt_ratio nodupkey; by apply_code descending UPDATED_TIME; run;
proc sort data = debt_ratio(drop = UPDATED_TIME) nodupkey; by apply_code; run;
proc sort data = assets_info nodupkey; by apply_code; run;
proc sort data = ccoc_info nodupkey; by apply_code; run;
proc sort data = liability_ratio nodupkey; by apply_code; run;

data cusMid.customer_info;
merge apply_time(in = a) base_info(in = b) emp_info(in = c) apply_ext_data(in = d) 
apply_balance(in = e) debt_ratio(in = f) assets_info(in = g) ccoc_info(in = h)  liability_ratio(in=i) ;
by apply_code;
if a;
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
if 户籍市="" or 工作市="" then 外地标签="数据缺失";
else if 户籍市^=工作市 then 外地标签="外地";
else 外地标签="本地";
rename loan_month_return = 贷款月还 CARD_USED_AMT_SUM = 信用卡月还 SOCIAL_SECURITY_MONTH = 社保基数 FUND_MONTH = 公积金基数 SEMI_CARD_OVERDRAFT_BALANCE = 准贷记卡月还
		BANK_FLOW_MONTH = 旧银行流水 OTHER_INCOME_MONTH = 旧其他收入 LIABILITY_MONTH = 旧月负债 debt_ratio = 旧月负债率  RATIO = 外部负债率
		VERIFY_INCOME = 核实收入 VERIFY_PAYROLL_CREDIT = 核实代发工资 OTHER_LIABILITIES = 其他负债  NEW_RATIO = 负债率 COMP_NAME=单位名称 TITLE=职位;
drop RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION 
	EDUCATION MARRIAGE GENDER HOUSING_PROPERTY position comp_type COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT 类别码 CC码 OC码;
run;


/*报告日期 近似等于查询日期*/
proc sort data=credit.credit_info_base out=report_date(keep=report_number real_name report_date CREDIT_VALID_ACCT_SUM) nodupkey; by report_number; run;
data report_data;
set report_date;
format report_date_ yymmdd10.;
report_date_=report_date;
run;
/*信用卡贷款明细加上报告日期*/
proc sort data=credit.credit_detail out=credit_detail; by report_number; run;
data credit_detail;
merge credit_detail(in=a) report_date(in=b);
by report_number;
if a;
open_month = intck("month", DATE_OPENED, report_date_);
if DATE_OPENED >= intnx("month", report_date_, -6, "same") then in6month = 1; else in6month = 0;
if DATE_OPENED >= intnx("month", report_date_, -24, "same") then in24month = 1; else in24month = 0;
if credit_line_amt=. then credit_line_amt=0;
if usedcredit_line_amt=. then usedcredit_line_amt=0;
run;

data card_detail;
set credit_detail(where=(SUB_BUSI_TYPE="贷记卡"));
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
if index(sub_busi_type, "汽车") or index(sub_busi_type, "商用房") or index(sub_busi_type, "住房") then 抵押贷款 = 1;else 抵押贷款 =0;
if not(index(sub_busi_type, "汽车") or index(sub_busi_type, "商用房") or index(sub_busi_type, "住房") 
or index(sub_busi_type, "助学") or index(sub_busi_type, "农户") )then do;
  if index(sub_busi_type,"其他") and  LOAN_BALANCE =CREDIT_LINE_AMT and DATE_OPENED ^=DATE_CLOSED then 无抵押贷款=0;
  else 无抵押贷款=1;
end;
run;

proc sql;
create table loan_pastdue_sum as
select report_number, sum(pastdue_amt) as loan_pastdue_sum,sum(无抵押贷款) as 无抵押贷款,sum(抵押贷款) as 抵押贷款
from loan_detail
group by report_number
;
quit;
proc sort data = credit.credit_report(keep=report_number id_card created_time) out = credit_report nodupkey; by report_number; run;
proc sql;
create table  pboc_info_pre as
select a.*,datepart(a.created_time) as 征信获取时间 format=yymmdd10.,
b.card_pastdue_total as 信用卡当前逾期金额,c.loan_pastdue_sum as 贷款当前逾期金额,c.抵押贷款,c.无抵押贷款,
sum(b.card_pastdue_total,c.loan_pastdue_sum) as 当前逾期金额总计 from credit_report as a
left join card_pastdue_total as b on a.report_number=b.report_number
left join loan_pastdue_sum as c on a.report_number=c.report_number;
quit;
proc sql;
create table pboc_info as
select a.apply_code, b.*
from apply_time as a
inner join pboc_info_pre as b on a.id_card_no = b.id_card and datepart(a.apply_time) >= b.征信获取时间
;
quit;
proc sort data = pboc_info nodupkey; by apply_code descending 征信获取时间; run;
proc sort data = pboc_info  nodupkey; by apply_code; run;

data query_in3month;
set credit.credit_derived_data(keep = REPORT_NUMBER SELF_QUERY_03_MONTH_FREQUENCY_SA  CARD_APPLY_03_MONTH_FREQUENCY_SA CARD_60_PASTDUE_FREQUENCY
LOAN_GUARANTEE_QUERY_03_MONTH_FR LOAN_GUARANTEE_QUERY_24_MONTH_FR CARD_APPLY_24_MONTH_FREQUENCY CARD_CREDIT_LINE_AMT_SUM CARD_USEDCREDIT_LINE_AMT_SUM CARD_OVER_100PCT
SELF_QUERY_24_MONTH_FREQUENCY LOAN_GUARANTEE_QUERY_01_MONTH_FR CARD_APPLY_01_MONTH_FREQUENCY_SA SELF_QUERY_01_MONTH_FREQUENCY_SA
CARD_60_PASTDUE_M3_FREQUENCY LOAN_MORTGAGE_60_PASTDUE_FREQUEN LOAN_MORTGAGE_PASTDUE_M3_FREQUEN LOAN_NAMORTGAGE_60_PASTDUE_FREQU LOAN_NAMORTGAGE_PASTDUE_M3_FREQU 
LOAN_OTHER_60_PASTDUE_FREQUENCY LOAN_OTHER_PASTDUE_M3_FREQUENCY SELF_QUERY_06_MONTH_FREQUENCY);
rename  LOAN_GUARANTEE_QUERY_03_MONTH_FR = 近3个月贷款查询次数
		SELF_QUERY_03_MONTH_FREQUENCY_SA = 近3个月本人查询次数
		CARD_APPLY_03_MONTH_FREQUENCY_SA=近3个月信用卡查询次数
		LOAN_GUARANTEE_QUERY_24_MONTH_FR=近2年贷款查询次数
CARD_APPLY_24_MONTH_FREQUENCY=近2年信用卡查询次数
SELF_QUERY_24_MONTH_FREQUENCY=近2年个人查询次数
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
SELF_QUERY_01_MONTH_FREQUENCY_SA=近1个月本人查询次数;
run;

proc sql;
create table pboc_info1 as
select a.*,b.近3个月本人查询次数,b.近3个月贷款查询次数,b.近2年贷款查询次数,b.近2年信用卡查询次数,b.近3个月信用卡查询次数,b.信用卡使用率,b.信用卡总额,b.信用卡透支总额,
b.贷记卡近5年逾期次数,b.贷记卡近5年逾期90以上次数,b.抵押贷款近5年逾期次数,b.抵押贷款近5年逾期90天以上次数,b.无抵押贷款近5年逾期次数,b.无抵押贷款近5年逾期90天以上次数,
b.其他性质贷款近5年逾期次数,b.其他性质贷款近5年逾期90天以上,b.近6个月本人查询次数,
b.近2年个人查询次数,b.近1个月贷款查询次数,b.近1个月信用卡查询次数,b.近1个月本人查询次数 from pboc_info as a
left join query_in3month as b on a.REPORT_NUMBER=b.REPORT_NUMBER;
quit;
proc sort data=pboc_info1 nodupkey;by apply_code;run;


data payment1;
set repayfin.payment1;
run;

data payment_wj;
set payment1(where = (cut_date =&dt. and 营业部^="APP")
					  keep = contract_no apply_code 客户姓名 cut_date 
LOAN_DATE PERIOD  COMPLETE_PERIOD od_days_ever mob  outstanding 身份证号码 od_days 产品小类 产品大类 营业部 es od_periods);
if od_days_ever < od_days then od_days_ever = od_days;
放款月份=put(LOAN_DATE,yymmn6.);
format status $24.;
if es = 1 then status = "09_ES";
else if mob = 0 then status = "00_NB";
else if od_periods < 1 then status = "01_C";
else if od_days <= 30 then status = "02_M1";
else if od_days <= 60 then status = "03_M2";
else if od_days <= 90 then status = "04_M3";
else if od_days <= 120 then status = "05_M4";
else if od_days <= 150 then status = "06_M5";
else if od_days <= 180 then status = "07_M6";
else if od_days > 180 then status = "08_M6+";

rename loan_date = 放款日期 outstanding=贷款余额 PERIOD=期数 COMPLETE_PERIOD=已还期数  LOAN_DATE=放款日期 
od_days=当前逾期天数 od_days_ever=曾经逾期天数;
run;
proc sort data=payment_wj nodupkey;by contract_no;run;
*approval cusMid.customer_info pboc_info 
*拒绝的;
proc sql;
create table repayfin.big_table as
select b.contract_no,b.产品小类,a.NAME as 客户姓名,b.期数,b.已还期数,b.放款日期,a.apply_code,a.营业部,b.产品大类,b.mob,b.status,a.批核日期,a.进件日期 as 进件时间,a.批核产品大类_终审,
b.当前逾期天数,b.曾经逾期天数,b.放款月份,e.group_level as 分群 ,e.risk_level as 风险等级,a.年龄,c.RESIDENCE_ADDRESS as 居住详细地址,c.PERMANENT_ADDRESS as 户籍详细地址,
c.居住省,c.居住市,c.居住区,c.户籍省,c.户籍市,c.户籍区,c.住房性质,c.教育程度,c.婚姻状况,c.性别,c.单位名称,c.COMP_ADDRESS as 单位详细地址,c.外地标签,
c.工作省 as 单位省,c.工作市 as 单位市,c.工作区 as 单位区,c.职位,c.职级,c.INDUSTRY_NAME,c.cc_name,c.oc_name,c.贷款月还,c.信用卡月还,c.社保基数,c.公积金基数,
c.旧银行流水,c.旧其他收入,c.旧月负债,c.旧月负债率,c.准贷记卡月还,c.核实收入,c.核实代发工资,c.其他负债,c.外部负债率,c.负债率,c.简版汇总负债总计,c.户口性质,
d.近3个月贷款查询次数,d.近3个月本人查询次数,d.信用卡当前逾期金额,d.贷款当前逾期金额,d.当前逾期金额总计,a.created_name_first as 初审,d.近6个月本人查询次数,
a.created_time_first as 初审时间,a.批核金额_终审 as 审批金额,a.created_name_final as 终审,a.created_time_final as 终审时间,a.MANAGER_NAME as 团队长,
a.SALES_NAME as 客户经理,a.批核状态,a.进件月份,a.REFUSE_INFO_NAME,a.REFUSE_INFO_NAME_LEVEL1,a.REFUSE_INFO_NAME_LEVEL2,a.approve_产品,a.DESIRED_PRODUCT,a.ID_CARD_NO,
d.近2年贷款查询次数,d.近2年信用卡查询次数,d.近2年个人查询次数,d.近1个月贷款查询次数,d.近1个月信用卡查询次数,d.近1个月本人查询次数,d.近3个月信用卡查询次数,d.抵押贷款,d.无抵押贷款,
d.信用卡使用率,d.信用卡总额,d.信用卡透支总额,d.贷记卡近5年逾期次数,d.贷记卡近5年逾期90以上次数,d.抵押贷款近5年逾期次数,d.抵押贷款近5年逾期90天以上次数,
d.无抵押贷款近5年逾期次数,d.无抵押贷款近5年逾期90天以上次数,d.其他性质贷款近5年逾期次数,d.其他性质贷款近5年逾期90天以上
from approval as a
left join payment_wj as b on a.apply_code=b.apply_code
left join cusmid.Customer_info as c on a.apply_code=c.apply_code
left join pboc_info1 as d on a.apply_code=d.apply_code
left join approval.credit_score as e on a.apply_code=e.apply_code;
quit;
