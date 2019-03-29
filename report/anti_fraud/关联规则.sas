option compress=yes validvarname=any;
libname appRaw odbc  datasrc=approval_nf;
libname approval "D:\share\Datamart\原表\approval";
libname account "D:\share\Datamart\原表\account";
libname his "D:\share\反欺诈数据\更新数据";
libname dta "D:\share\Datamart\中间表\daily";
libname res odbc  datasrc=res_nf;

data apply_info;
set appRaw.apply_info ;
run;
data apply_emp;
set approval.apply_emp;
comp_name = compress(comp_name,"");
run;

data null;
format nt yymmdd10.;
nt=today();
call symput("nt",nt);
call symput("dt",nt-1);
run;
%put &nt.;
/*检查account_info 中是否还存在缺失loan_date 的情况*/
/*data aaa;*/
/*set repayfin.payment_daily;*/
/*if contract_no="C2017071815032083816859";*/
/*run;*/
/*data aaa;*/
/*set account.account_info;*/
/*if contract_no="C2017071815032083816859";*/
/*run;*/


/*配偶、父母子女同为在库*/
data sum_info;
set repayfin.payment_daily(where=(营业部^="APP" and cut_date = &nt.-1 ));
apply_code = tranwrd(contract_no , "C","PL");
format loan_date yymmdd10.;
loan_date = mdy(substr(放款日期,6,2),substr(放款日期,9,2),substr(放款日期,1,4));
if loan_date <intnx("day",&nt.,-14,"b") ;
format 状态$10.;
if es =1 then 状态= "结清";
else if od_days>0 then 状态="逾期";
else if od_days_ever>0 then 状态="历史逾期";
else 状态="正常还款";
run;

data account_info;
set sum_info(where=(营业部^="APP" and cut_date = &nt.-1 and es^=1 and od_days<1  and mdy(8,1,2017)<loan_date <intnx("day",&nt.,-14,"s") ));
apply_code = tranwrd(contract_no , "C","PL");
run;

proc sql; 
create table apply_info1 as select a.*,b.* from apply_info as a left join sum_info as b on a.apply_code =b.apply_code;quit;

data apply_info2;
set apply_info1;
if TASK_PERIOD_DESC ^="结束"  then 状态= TASK_PERIOD_DESC;
run;

proc sql; 
create table apply_info1 as select a.*,b.PHONE1 from apply_info2 as a left join approval.apply_base as b on a.apply_code =b.apply_code ;quit;

data apply_info1;
set apply_info1;
if MOBILE_NO ="" then MOBILE_NO=PHONE1;
drop PHONE1;
run;


/*部分客户填写资料是未勾选直系亲属，缺少标签*/
proc sql;
create table loan_contact_f as select a.*,b.CONTACT_NAME,b.MOBILE_NO,b.relation from account_info as a left join approval.apply_contacts(
where=(relation in ("187","190","191","192","193","MR001"))) as b 
on a.apply_code  = b.apply_code ; quit;

/*data family;*/
/*set approval.apply_contacts(where=(relation in ("187","190","191","192","193") ));*/
/*keep apply_code CONTACT_NAME relation MOBILE_NO;*/
/*run;*/

proc sort data = loan_contact_f nodupkey ;by apply_code MOBILE_NO;run;
/*proc sql;*/
/*create table deceiver as select * from family where CONTACT_NAME in (select NAME from approval.apply_info);quit;*/

proc sql;
create table deceiver_f(where=(关联人^=" " and MOBILE_NO^="") keep = apply_code CONTACT_NAME 关联人 关联人编号 客户姓名    MOBILE_NO TASK_PERIOD_DESC 状态) as  select a.*,
b.name as 关联人,b.apply_code as 关联人编号,b.MOBILE_NO as 电话号码,b.TASK_PERIOD_DESC,b.状态 from loan_contact_f (drop=状态)
as a left join apply_info1 as b 
on  a.MOBILE_NO = b.MOBILE_NO and a.apply_code >b.apply_code;quit;


data deceiver_f;
set deceiver_f;
format 标签 $20.;
标签 ="直系亲属有申请记录";
rename MOBILE_NO=关联因素;
if TASK_PERIOD_DESC ^="结束"  then 状态= TASK_PERIOD_DESC;
drop TASK_PERIOD_DESC;
run;
proc sort data = deceiver_f ;by apply_code 关联人 关联因素 descending 关联人编号;run;
proc sort data = deceiver_f nodupkey;by apply_code 关联人 关联因素 ;run;



/*客户直接联系人在我司有申请记录*/

proc sql;
create table loan_contact_dc as select a.*,b.CONTACT_NAME,b.MOBILE_NO,b.relation from account_info as a 
left join approval.apply_contacts(where=(relation not in ("187","190","191","192","193","MR001") )) as b 
on a.apply_code  = b.apply_code ; quit;

proc sort data = loan_contact_dc nodupkey ;by apply_code CONTACT_NAME;run;
proc sql;
create table deceiver_dc(where=(MOBILE_NO^=" " and 关联人^=客户姓名) keep = apply_code CONTACT_NAME 关联人 客户姓名 关联人编号  LOAN_DATE  MOBILE_NO TASK_PERIOD_DESC 状态) as  select a.*,
b.name as 关联人,b.apply_code as 关联人编号,b.MOBILE_NO as 电话号码,b.TASK_PERIOD_DESC,b.状态 from loan_contact_dc as a inner join apply_info1 as b 
on  a.MOBILE_NO = b.MOBILE_NO and a.apply_code >b.apply_code;quit;

data deceiver_dc;
set deceiver_dc;
format 标签 $20.;
标签 ="直接联系人有申请记录";
rename MOBILE_NO=关联因素;
if TASK_PERIOD_DESC ^="结束"  then 状态= TASK_PERIOD_DESC;
drop TASK_PERIOD_DESC;
run;
proc sort data = deceiver_dc ;by apply_code 关联人 关联因素 descending 关联人编号;run;
proc sort data = deceiver_dc nodupkey;by apply_code 关联人 关联因素 ;run;


/*客户间接联系人在我司有申请记录*/
data relation_type ;
set res.optionitem(where = (groupCode in( "MATERELATION","FAMILYRELATION","OTHERRELATION","JOBRELATION")));
keep itemCode itemName_zh;
run;
proc sql;
create table loan_contact_idc1 as select b.*,a.CONTACT_NAME,a.MOBILE_NO,a.relation ,c.itemName_zh as 与客户关系 from approval.apply_contacts as a right join 
account_info as b on a.apply_code  = b.apply_code  left join relation_type as c on a.relation = c.itemCode
; quit;

proc sort data = loan_contact_idc1 nodupkey ;by CONTACT_NAME apply_code ;run;

proc sql;
create table loan_contact_idc2 as select b.*,a.CONTACT_NAME,a.MOBILE_NO,a.relation,c.itemName_zh as 与关联人关系 from approval.apply_contacts  as a left join 
 apply_info1(drop=MOBILE_NO ) as b 
on a.apply_code  = b.apply_code   left join relation_type as c on a.relation = c.itemCode ; quit;

proc sort data = loan_contact_idc2 nodupkey ;by CONTACT_NAME apply_code ;run;

proc sql;
create table deceiver_idc(where=(CONTACT_NAME not in ("宜信","0","电费","宜人贷","00","11","12","家里固话","家里座机","电费查询","是")
 and MOBILE_NO not in("1","11","13500000000","13600000000","13000000000","13800000000","13700000000") )) as select a.客户姓名,a.apply_code,
a.CONTACT_NAME,a.MOBILE_NO,b.name as 关联人,a.与客户关系,b.与关联人关系,b.apply_code as 关联人编号,b.状态  from loan_contact_idc1 
as a inner  join loan_contact_idc2 as b on  a.MOBILE_NO=b.MOBILE_NO  and a.apply_code>b.apply_code
 and a.客户姓名<>b.name;quit;


  
data deceiver_idc;
set deceiver_idc(where=(MOBILE_NO^=""));
rename MOBILE_NO=关联因素;
format 标签 $20.;
标签 ="客户间接联系人有申请记录";
run;


/*data aaa;*/
/*set approval.apply_contacts;*/
/*if contact_name = "布和";run;*/

data apply_emp_phone;
set approval.apply_emp;
format 单位电话 $25.;
if COMP_TEL ="" or  COMP_TEL ="0" or COMP_TEL_AREA in ("0","0-0") then  delete ;
else if COMP_TEL_AREA="" or find(COMP_TEL,"-") then 单位电话 =compress( COMP_TEL,"-");
else  单位电话 = compress(COMP_TEL_AREA||COMP_TEL );
run;

/*同一单位关联人在我司有申请记录*/
proc sql;
create table comp_name_apply1 as select a.*,b.comp_name,b.单位电话 from account_info as a left join apply_emp_phone as b on a.apply_code = b.apply_code ;quit;

proc sql;
create table comp_name_apply2 as select a.*,b.comp_name,b.单位电话 from apply_info1 as a left join apply_emp_phone as b on a.apply_code = b.apply_code ;quit;

proc sql;
create table comp_name_rele(where=(comp_name^="" and 客户姓名 ^=关联人 )) as select a.apply_code,a.客户姓名,a.comp_name,b.apply_code as 关联人编号,b.name as 关联人,b.状态
from  comp_name_apply1 as a inner join comp_name_apply2 as b on a.comp_name = b.comp_name  and a.apply_code >b.apply_code ;quit;

proc sort data = comp_name_rele nodupkey;by apply_code 关联人;run;

proc sort data = dta.Customer_info out =Customer_info;by apply_code;run;

data comp_name_rele;
merge comp_name_rele(in=a) Customer_info(keep=apply_code 单位性质  OC_NAME);
by apply_code;
if a ;
rename comp_name=关联因素;
format 标签 $20.;
标签 ="同一单位关联人有申请记录";
run;

proc sql;
create table comp_name_rele as select a.*,b.OC_NAME as 关联人职级 from comp_name_rele as a left join Customer_info as b on a.关联人编号 =b.apply_code ;quit;

/*同一单位电话关联人在我司有申请记录*/

proc sql;
create table comp_phone_rele(where=(单位电话 not in("无","") and kindex(单位电话,"000000")=0 and kindex(单位电话,"888888")=0))
as select a.apply_code,a.客户姓名,a.单位电话,a.comp_name,b.apply_code as 关联人编号,b.name as 关联人,b.状态,b.comp_name as 关联人单位名称
from  comp_name_apply1 as a inner join comp_name_apply2 as b on a.单位电话 = b.单位电话  and a.apply_code >b.apply_code ;quit;

proc sort data = comp_phone_rele nodupkey;by apply_code 关联人;run;


data comp_phone_rele;
merge comp_phone_rele(in=a) Customer_info(keep=apply_code 单位性质  OC_NAME);
by apply_code;
if a ;
rename 单位电话=关联因素;
format 标签 $20.;
标签 ="单位电话关联人有记录";
run;

/*------------------------*/
data realtion_de ;
set deceiver_f deceiver_dc deceiver_idc comp_name_rele comp_phone_rele;
contract_no = tranwrd(apply_code,"PL","C");
run;
data payment_daily;
set repayfin.payment_daily(where=(cut_date=&dt. and 营业部^="APP"));
apply_code = tranwrd(contract_no ,"C","PL");
run;
proc sort data = payment_daily;by apply_code;run;

proc sql;
create table realtion_de_all as  select a.*,e.营业部,e.身份证号码 ,b.od_days,b.od_days_ever,c.放款日期,c.approve_产品,d.SALES_CODE,d.SALES_NAME  
from realtion_de  as a
left join payment_daily as b on a.关联人编号 = b.apply_code 
left join dta.app_loan_info as c on a.apply_code = c.apply_code 
left join apply_info as d on a.apply_code = d.apply_code
left join payment_daily as e on a.apply_code = e.apply_code ;

quit;

data realtion_de_all;
set realtion_de_all;
if  状态 in ("结清","拒绝","拒绝结束","历史逾期","取消","取消结束","逾期","正常还款");
身份证号码2 = put(身份证号码,$20.);
format 更新时间 yymmdd10.;
更新时间=  &nt.;
run;
proc sort data = realtion_de_all;by 标签;run;

data realtion;
set his.realtion;
标记=1;
if 更新时间^=  &nt.;
run;
proc sort data = realtion  nodupkey out = realtion_1 ;by apply_code;run;
data realtion_de_all1;
set realtion realtion_de_all;
run;

proc sort data = realtion_de_all1 nodupkey;by 标签 apply_code 关联人编号 关联因素;run;

data realtion_de_all2;
set realtion_de_all1;
if 标记^=1 ;
drop 标记;
if 放款日期>&dt.-30;
总标签="关联";
run;
proc sql ;
create table realtion_de_all3 as select a.*,b.标记,c.* from realtion_de_all2 as a left join realtion_1 as b on a.apply_code=b.apply_code
left join dta.customer_info as c on a.apply_code=c.apply_code;quit;

proc sort data = realtion_de_all3 ; by 标签;run;
proc sql;
create table realtion_cf  as select b.*  from realtion_de_all3(where=(标记=1)) as a left join realtion  as b on a.apply_code = b.apply_code;quit;

filename DD DDE "EXCEL|[反欺诈数据.xlsx]关联!r2c1:r20000c31" notab;
data _null_;set realtion_de_all3;file DD;put  总标签  '09'x 营业部 '09'x 标签  '09'x approve_产品 '09'x SALES_CODE '09'x SALES_NAME  '09'x 放款日期 
'09'x apply_code '09'x身份证号码2 '09'x 客户姓名 '09'x CONTACT_NAME '09'x 关联因素 '09'x 关联人 '09'x 关联人编号  '09'x comp_name '09'x关联人单位名称
'09'x 单位性质 '09'x OC_NAME '09'x 关联人职级 '09'x 与客户关系 '09'x 与关联人关系  '09'x 外地标签 '09'x age '09'x 教育程度 '09'x 近3个月贷款查询次数
'09'x 近1个月本人查询次数 '09'x 核实收入 '09'x 负债率'09'x od_days '09'x od_days_ever  '09'x 状态  
  ;run;

data his.realtion;
set realtion_de_all1;
keep apply_code 标签 更新时间  放款日期 关联人编号 关联因素;
run;

/*proc sql;*/
/*create table   aaaac as select a.F26,b.状态  from last_data as a inner join realtion_de_all1 as b on a.关联人编号=b.关联人编号  ;quit;*/
/**/
/*proc sort  data = aaaac nodupkey ; by F26;run;*/


/*已更新数据导入*/
/*累加式更新*/
/*PROC IMPORT OUT= last_data*/
/*            DATAFILE= "F:\share\反欺诈数据\历史数据\反欺诈数据12-07.xlsx"*/
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="关联$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/**/
/*proc sql;*/
/*create table deff as  select * from  last_data as a left join realtion_de_all as b   on a.申请编号 = b.apply_code and a.标签=b.标签 and a.关联人编号=b.关联人编号 ;quit;*/
/**/
/*proc sort data =deff ;by 标签;run;*/
/*x  "F:\share\反欺诈数据\历史数据\反欺诈数据10-25.xlsx"; */
/*filename DD DDE "EXCEL|[反欺诈数据10-25.xlsx]关联!r2c1:r20000c20" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x 客户姓名 '09'x CONTACT_NAME '09'x 关联因素 '09'x 关联人 '09'x 关联人编号 '09'x 标签 '09'x comp_name '09'x关联人单位名称*/
/*'09'x 单位性质 '09'x OC_NAME '09'x 关联人职级 '09'x 营业部 '09'x 身份证号码2 '09'x od_days '09'x od_days_ever  '09'x 状态 '09'x approve_产品 '09'x SALES_CODE '09'x SALES_NAME */
/*  ;run;*/
/*data update_data ;*/
/*set collective last_data ;*/
/**/
/*run;*/
/*proc sort data = update_data nodupkey; by 标签 关联因素 apply_code ;run;*/
/**/
/*x  "F:\share\反欺诈数据\反欺诈数据样本.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[反欺诈数据样本.xlsx]关联!r2c1:r10000c7" notab;*/
/*data _null_;set update_data;file DD;put apply_code '09'x 客户姓名 '09'x 关联人 '09'x 关联人编号 '09'x 状态 '09'x CONTACT_NAME '09'x MOBILE_NO  '09'x  关联因素 '09'x 标签;run;*/
/*x  "F:\share\反欺诈数据\反欺诈数据.xlsx"; */
/**/
/*filename DD DDE "EXCEL|[反欺诈数据.xlsx]关联!r2c1:r10000c7" notab;*/
/*data _null_;set deff;file DD;put apply_code '09'x 客户姓名 '09'x 关联人 '09'x 关联人编号 '09'x 状态 '09'x CONTACT_NAME '09'x MOBILE_NO  '09'x  关联因素 '09'x 标签;run;*/
/**/
/*data   cca;*/
/*set realtion_de_all2;*/
/*if 标签 in ("直接联系人有申请记录","客户间接联系人有申请","直系亲属有申请记录");*/
/*run;*/
/**/
/**/
/*proc sql;*/
/*create table  aac as select a.*,b.标签 as 标签1 from   cca  as a inner join his.check_result as b on a.apply_code =b.apply_code;quit;*/
/*x  "F:\share\反欺诈数据\反欺诈偷懒表.xlsx"; */
/*filename DD DDE "EXCEL|[反欺诈偷懒表.xlsx]关联+审核!r2c1:r20000c21" notab;*/
/*data _null_;set aac;file DD;put apply_code '09'x 客户姓名  '09'x 放款日期 '09'x 标签  '09'x 标签1*/
/*  ;run;*/
/**/
/*proc sort data = aac  out =aac1 nodupkey;by apply_code ;run;*/
/**/
/*filename DD DDE "EXCEL|[反欺诈偷懒表.xlsx]关联+审核_去重!r2c1:r20000c21" notab;*/
/*data _null_;set aac1;file DD;put apply_code '09'x 客户姓名  '09'x 放款日期 '09'x 标签  '09'x 标签1*/
/*  ;run;*/
