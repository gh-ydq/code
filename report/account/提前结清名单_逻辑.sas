/*libname approval 'E:\guan\原数据\approval';*/
/*libname account 'E:\guan\原数据\account';*/
/*libname csdata 'E:\guan\原数据\csdata';*/
/*libname res  'E:\guan\原数据\res';*/
/*libname yc 'E:\guan\中间表\yc';*/
/*libname repayfin 'E:\guan\中间表\repayfin';*/
/*option compress = yes validvarname = any;*/
/**/
/*proc import datafile="E:\guan\催收报表\提前结清名单\政策剔除原数据.xlsx"*/
/*out=policy dbms=excel replace;*/
/*SHEET="放款客户";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*proc import datafile="E:\guan\催收报表\提前结清名单\提前结清名单.xlsx"*/
/*out=pre_list dbms=excel replace;*/
/*SHEET="历史名单汇总";*/
/*scantext=no;*/
/*getnames=yes;*/
/*run;*/
/*x "E:\guan\催收报表\提前结清名单\提前结清名单.xlsx";*/

data null;
format dt yymmdd10.;
dt=today()-1;
call symput("dt", dt);
run;
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


data payment_p;
set repayfin.payment_daily;
run;
data payment_p2;
set payment_p;
if cut_date=&dt.;
if 营业部^='APP';
apply_code = tranwrd(contract_no , "C","PL");
run;
proc sort data=payment_p2 nodupkey;by contract_no;run;
proc sql;
create table payment_p3 as 
select a.*,c.近6个月个人查询剔除,c.内部审批政策剔除,c.营业部特殊限制剔除,c.天启分限制剔除,d.MODEL_SCORE as score,d.MODEL_SCORE_LEVEL as 分档 from payment_p2 as a
left join policy as c on a.apply_code=c.apply_code
left join repayfin.strategy as d  on a.apply_code=d.apply_code;
quit;
data payment_p4;
set payment_p3;
/*if score>0;*/
if 近6个月个人查询剔除=1 or 内部审批政策剔除=1 or 营业部特殊限制剔除=1 or 天启分限制剔除=1 then policy_out=1;else policy_out=0;
if 分档="F" then level_out=1;else level_out=0;
if level_out=1 or policy_out=1 then level_policy_out=1;else level_policy_out=0;
run;
data payment_p4_;
set payment_p4;
keep apply_code 客户姓名 policy_out level_out 分档 level_policy_out 营业部 贷款余额 贷款余额_剩余本金部分 od_days ;
run;
data payment_p4;
set payment_p4_;
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
array char _character_;
Do Over char;
If char=" " Then char='0';
End;
run;
data payment_p12;
set payment_p4_;
if od_days>0;
run;

************************** curr_period start *************************************;
data aa;
set repayfin.payment_daily(where=(cut_date=&dt. and 营业部^='APP'));
apply_code = tranwrd(contract_no , "C","PL");
run;
/*当前期数*/
data aa2;
set account.bill_main;
if repay_date<=&dt.;
run;
proc sql;
create table aa2_ as
select contract_no,
count(contract_no) as 当前期数
from aa2
group by contract_no;
quit;
data aa4;
set repayfin.Tttrepay_plan_js;
if repay_date_js<=&dt.;
run;
proc sql;
create table aa4_ as
select contract_no,
count(contract_no) as 当前期数
from aa4
group by contract_no;
quit;
data aa5;
set aa2_ aa4_;
apply_code = tranwrd(contract_no , "C","PL");
run;
proc sql;
create table aa1 as
select a.*,c.当前期数
from aa as a
left join aa5 as c on a.apply_code=c.apply_code;
quit;
data lists;
set aa1;
COMPLETE_PERIOD = 当前期数 - od_periods;
curr_period=COMPLETE_PERIOD+1;
未还期数=当前期数+1;
身份证号码=substr(身份证号码,1,6) || "****" || substr(身份证号码,length(身份证号码)-3,4);
keep contract_no apply_code 当前期数 COMPLETE_PERIOD curr_period od_days 客户姓名 身份证号码 营业部 CONTRACT_AMOUNT REPAY_DATE 未还期数;
run;
************************** curr_period end *************************************;

data servicefee;
set approval.loan_info(keep = contract_no loan_amount service_amount documentation_fee  total_deposit where=(loan_amount>0));
rename loan_amount=合同金额
       service_amount=服务费
       documentation_fee=单证费
       total_deposit=保证金;
run;
proc sql;
create table repay_plan as 
select a.*,b.PSNORMINTAMT from account.repay_plan as a
left join repayfin.Tttrepay_plan_js as b on a.contract_no=b.contract_no and a.curr_period=b.PSPERDNO;
quit;
proc sort data=repay_plan nodupkey;by contract_no curr_period;run;
data repay_plan_;
set repay_plan;
if CURR_RECEIVE_INTEREST_AMT in (0,.) then CURR_RECEIVE_INTEREST_AMT=PSNORMINTAMT;
run;

proc sql;
create table list_curr_period as
select a.contract_no,c.beginning_capital as 本金余额, c.CURR_RECEIVE_CAPITAL_AMT as 当期本金, c.CURR_RECEIVE_INTEREST_AMT as 当期利息,c.EARLY_REPAY_SERVICE_FEE_AMT,
	g.EARLY_REPAY_SERVICE_FEE_AMT as EARLY_label ,a.REPAY_DATE, c.RETURN_SERVICE_FEE as 退还服务费_收违约金,d.保证金,f.fund_channel_code
from lists as b
left join repay_plan_ as a on b.contract_no = a.contract_no and b.curr_period = a.curr_period
left join repay_plan_ as c on c.contract_no = b.contract_no and c.curr_period = b.未还期数
left join repay_plan_(where=(curr_period = 1)) as g on g.contract_no = b.contract_no
left join servicefee as d on a.contract_no=d.contract_no 
left join approval.contract as f on a.contract_no=f.contract_no;
quit;
proc sql;
create table list_unbilled_interest as
select a.contract_no, sum(a.CURR_RECEIVE_INTEREST_AMT) as 未出账单利息和
from lists as b
left join repay_plan_ as a on b.contract_no = a.contract_no and b.未还期数 <= a.curr_period
group by a.contract_no;
quit;

proc sort data = lists nodupkey; by contract_no; run;
proc sort data = list_curr_period nodupkey; by contract_no; run;
proc sort data = list_unbilled_interest nodupkey; by contract_no; run;
data list_2;
merge lists(in = a) list_curr_period(in = b) list_unbilled_interest(in = c);
by contract_no;
if a;
期供 = 当期本金 + 当期利息;
if curr_period > 3 then 提前还款违约金 = min(本金余额*0.03, 未出账单利息和); else 提前还款违约金 = min(本金余额*0.05, 未出账单利息和);
array num _numeric_;
Do Over num;
If num="." Then num=0;
End;
array char _character_;
Do Over char;
If char=" " Then char='0';
End;
run;
data list_3;
set list_2;
run;
proc sql;
create table list_4 as 
select a.*,b.提前还款违约金,b.保证金,b.退还服务费_收违约金,b.contract_no,b.本金余额,b.当期本金,b.当期利息,b.期供,b.fund_channel_code,b.EARLY_REPAY_SERVICE_FEE_AMT,b.EARLY_label
from payment_p12 as a
left join list_3 as b on a.apply_code=b.apply_code;
quit;
data list_5;
set list_4;
佣金3=提前还款违约金*2;
佣金2=提前还款违约金*1.5;
佣金1=提前还款违约金*1;
系统结清金额="以当天系统结清金额为准";
if EARLY_label>1 then do;
	折中结清金额=本金余额+当期利息+期供+EARLY_REPAY_SERVICE_FEE_AMT;
	最低结清金额=本金余额+当期利息+期供+EARLY_REPAY_SERVICE_FEE_AMT-佣金1;
end;
else if 保证金>0 and EARLY_label<1 then do;
	折中结清金额=本金余额+当期利息+期供-退还服务费_收违约金+佣金1;
	最低结清金额=本金余额+当期利息+期供-退还服务费_收违约金;
end;
else if fund_channel_code='jsxj1' then do;
	折中结清金额=本金余额+当期利息+期供-退还服务费_收违约金-当期利息;
	最低结清金额=本金余额+当期利息+期供-退还服务费_收违约金-佣金1-当期利息;
end;
else do;
	折中结清金额=本金余额+当期利息+期供-退还服务费_收违约金;
	最低结清金额=本金余额+当期利息+期供-退还服务费_收违约金-佣金1;
end;
run;
proc sort data=list_5 ;by od_days;run;
proc sql;
create table list_5_ as 
select contract_no as 合同号,客户姓名,营业部,od_days as 逾期天数,level_policy_out as 政策评分卡剔除,保证金,退还服务费_收违约金 as 退还服务费,佣金3,折中结清金额,佣金2,最低结清金额,佣金1
from list_5;
quit;
data list_6;
set list_5;
if weekday(&dt.)=1 then do;
if od_days=3 or od_days=4 or od_days=5;
end;
else do;
if od_days=3;
end;
if level_policy_out=1;
if 佣金3>=400;
run;
proc sql;
create table list_7 as 
select contract_no,客户姓名,营业部,系统结清金额,佣金3,折中结清金额,佣金2,最低结清金额,佣金1
from list_6;
quit;
filename DD DDE "EXCEL|[提前结清名单.xlsx]提前结清名单!r2c1:r100c9";
data _null_;set list_7;file DD;put contract_no 客户姓名 营业部 系统结清金额 佣金3 折中结清金额  佣金2 最低结清金额 佣金1;run;
data list_8;
set list_6;
format 日期 yymmdd10.;
日期=today();
keep 日期 contract_no 客户姓名 营业部 系统结清金额 佣金3 折中结清金额 佣金2 最低结清金额 佣金1;
rename contract_no=合同号;
run;
data list_9;
set pre_list list_8;
run;
proc sort data=list_9;by 合同号 descending 日期;run;
proc sort data=list_9 nodupkey;by 合同号;run;
proc sort data=list_9;by descending 日期;run;
filename DD DDE "EXCEL|[提前结清名单.xlsx]历史名单汇总!r2c1:r10000c10";
data _null_;set list_9;file DD;put 日期 合同号 客户姓名 营业部 系统结清金额 佣金3 折中结清金额  佣金2 最低结清金额 佣金1;run;

data pre_list_;
set pre_list;
apply_code = tranwrd(合同号 , "C","PL");
run;
data payment_p;
set repayfin.payment_daily;
run;
data payment_p2;
set payment_p;
if cut_date=&dt.;
if 营业部^='APP';
apply_code = tranwrd(contract_no , "C","PL");
run;
proc sort data=payment_p2 nodupkey;by contract_no;run;
proc sql;
create table pre_list_1 as 
select a.客户姓名,a.apply_code,a.营业部,a.日期,a.合同号,b.od_days,b.es,b.od_days_ever,c.ACCOUNT_STATUS from pre_list_ as a
left join payment_p2 as b on a.apply_code=b.apply_code
left join account.account_info as c on c.contract_no=b.contract_no;
quit; 
proc sort data=pre_list_1;by descending 日期;run;
proc sort data=pre_list_1 nodupkey;by  apply_code;run;
data pre_list_2;
set pre_list_1;
if account_status='0003';
contract_no=tranwrd(合同号 , "PL","C");
run;
data bill_main_es;
set account.bill_main;
if kindex(BILL_CODE,"EBL");
run;
proc sort data=bill_main_es;by contract_no descending clear_date;run;
proc sort data=bill_main_es nodupkey;by contract_no;run;

proc sql;
create table pre_list_3 as 
select a.*,b.CURR_PERIOD,b.CURR_RECEIPT_AMT,b.clear_date from pre_list_2 as a
left join bill_main_es as b on a.contract_no=b.contract_no;
quit;
proc sql;
create table pre_list_4 as 
select a.*,b.CURR_PERIOD as CURR_PERIOD_es,b.CURR_RECEIPT_AMT as CURR_RECEIPT_AMT_es,b.营业部,b.客户姓名 from account.repay_plan as a
left join pre_list_3 as b on a.contract_no=b.contract_no;
quit;
data pre_list_4_;
set pre_list_4;
if CURR_PERIOD_es>0;
run;
proc sql;
create table pre_list_5 as
select a.contract_no,sum(a.CURR_RECEIVE_INTEREST_AMT) as 未出账单利息和
from pre_list_4_ as a where a.curr_period>CURR_PERIOD_es
group by a.contract_no;
quit;
proc sql;
create table pre_list_5_2 as
select contract_no,beginning_capital as 本金余额,CURR_PERIOD_es
from pre_list_4_ where curr_period=CURR_PERIOD_es;
quit;
proc sql;
create table pre_list_6 as 
select a.*,b.本金余额,b.CURR_PERIOD_es from pre_list_5 as a
left join pre_list_5_2 as b on a.contract_no=b.contract_no;
quit;
data pre_list_7;
set pre_list_6;
if CURR_PERIOD_es > 3 then 提前还款违约金 = min(本金余额*0.03, 未出账单利息和); else 提前还款违约金 = min(本金余额*0.05, 未出账单利息和);
run;
proc sql;
create table pre_list_8 as 
select a.*,b.营业部,b.客户姓名,b.CURR_RECEIPT_AMT,b.clear_date from pre_list_7 as a
left join pre_list_3 as b on a.contract_no=b.contract_no;
quit;
data pre_list_8;
set pre_list_8;
佣金=提前还款违约金*1.5;
if contract_no in ('C2017091214165415037622','C2017092116242511247031','C2017071215142043171242','C2017033017190011763012','C2018051711594971854092','C2017112218403870825073','C2018011917511864766167',
	'C2017071317492121677636','C2017041016022323795289','C2017101218330205233310','C2017092910075570251562','C152351871429902300009203','C152628149701302300001164','C2017103118460228898745',
	'C2017081619220936692714','C2017030812555383107555','C2017060513101838574944','C2018011716551953741377','C2017112220060363321605','C2017061416562876370328','C2017062817224777633427'
	'C2017091215271102540946','C2018011816081556790184','C2017032216161794243972','C2017111409162842184843','C151997132161203000003121','C2018060813274523353942','C2018010813234622604169',
	'C2017090415015812717808','C2017082214111518506440','C2017060214524739873688','C2017032012260104557106','C2017081115015764624142','C2017120515554920777022','C2018031616505224241160',
	'C2017102314043465787656','C2017042615383569763712','C152687653472702300001243','C2017072617364924076951','C2017072417584449009225','C2017041314481257712194','C2017080910454542145365',
	'C2017102417512945120834','C2017051216070171982298','C2017091515454347308731','C152698030555803000000216','C2017063011143891137961','C2017072517421313005856','C2017092211295208349340',
	'C2017092218030277297782','C2017071011182562875373') then delete;
if contract_no='C2018050810452702044342' then CURR_RECEIPT_AMT=17995.92;
if contract_no='C2018051711594971854092' then do;CURR_RECEIPT_AMT=47612;佣金=1276.2864;end;
if contract_no='C2017033116445931791007' then do;CURR_RECEIPT_AMT=22288.69;佣金=653.9088;end;
if contract_no='C2017112416441748704059' then do;CURR_RECEIPT_AMT=76345.9;佣金=3531.61;end;
if contract_no='C2016060215530799443602' then do;CURR_RECEIPT_AMT=9588.56;佣金=558.5454;end;
if contract_no='C2017070615201064320527' then do;CURR_RECEIPT_AMT=12480.6;佣金=647.4096;end;
if contract_no='C152463981193603000000638' then do;CURR_RECEIPT_AMT=36770.44;佣金=1522.59;end;
if contract_no='C2017091316163328413127' then do;CURR_RECEIPT_AMT=21359.73;佣金=1083.1671;end;
if contract_no='C2017090515274353580507' then do;CURR_RECEIPT_AMT=15674.99;佣金=847.51335;end;
if contract_no='C2018010212460084876364' then do;CURR_RECEIPT_AMT=27255.88;佣金=1262.93;end;
run;
proc sort data=pre_list_8;by descending clear_date;run;
/*filename DD DDE "EXCEL|[提前结清名单.xlsx]已结清明细!r2c1:r100c5";*/
/*data _null_;set pre_list_8;file DD;put contract_no 客户姓名 营业部 CURR_RECEIPT_AMT 佣金 clear_date;run;*/
