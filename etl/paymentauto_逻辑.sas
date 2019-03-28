data apply_info;
set approval.apply_info(keep = apply_code name id_card_no branch_code branch_name DESIRED_PRODUCT SOURCE_CHANNEL);
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

rename branch_name = 营业部;
run;
data apply_info1;
set apply_info(where = ( SOURCE_CHANNEL="257"));
营业部 = 'APP';
RUN;
data apply_info;
set apply_info apply_info1;
run;

proc sql;
create table apply_infoa as
select a.*,b.hire,c.SOCIAL_SECURITY from apply_info as a
left join approval.apply_emp as b on a.apply_code=b.apply_code
left join approval.apply_balance as c on a.apply_code=c.apply_code;
quit;
data apply_info;
set apply_infoa;
run;


/*以首次录入复核完成时间作为进件时间*/
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "录入复核" and action_ = "COMPLETE")); /*action_必须是COMPLETE的才是进入审批的，JUMP的是复核时取消或拒绝*/
keep bussiness_key_ create_time_;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time nodupkey; by apply_code; run;
proc sort data=apply_info(where=(营业部^="公司渠道")) nodupkey ;by apply_code 营业部;run;
data appMid.apply_time;
merge apply_time(in = a) apply_info(in = b);
by apply_code;
if a;
进件月份 = put(datepart(apply_time), yymmn6.);
进件日期 = put(datepart(apply_time), yymmdd10.);
apply_week = week(datepart(apply_time)); /*进件周，一年当中的第几周*/
run;

data acc;
format dt pde date last_month_begin last_month_end yymmdd10.;
if year(today()) = 2004 then dt = intnx("year", today() - 1, 13, "same"); else dt = today() - 1;
pde=intnx("month",dt,-1,"e");
call symput("pde",pde);
call symput("dt", dt);
nt=intnx("day",dt,1);
call symput("nt", nt);
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(9,30,2018);*/
last_month_end=intnx("month",date,0,"b")-1;
call symput("last_month_end",last_month_end);
last_month_begin=intnx("month",date,-1,"b");
call symput("last_month_begin",last_month_begin);


run;
/*%put &dt.;*/
/*%let dt=mdy(9,30,2018);*/
/*%let pde=mdy(8,31,2018);*/
/*%let nt=mdy(10,1,2018);*/
/*%let last_month_begin=mdy(8,1,2018);*/
/*%let last_month_end=mdy(8,31,2018);*/




/*找出回购的 订单号*/
proc sql;
create table test1 as select 
a.* , b.FUND_CHANNEL_CODE as 资金渠道 from approval.contract as a left join account.account_info as b on a.contract_no = b.contract_no;
quit;

data ss;
set test1 (where=((资金渠道 = 'tsjr1' and fund_channel_code = 'jsxj1')));
回购 =1;
run;


*晋商;
data tttrepay_plan_js;
set account.repay_plan_js;
if PSPERDNO^=0;
run;

proc sort data = tttrepay_plan_js; by contract_no psperdno descending SETLPRCP; run;
proc sort data = tttrepay_plan_js nodupkey; by contract_no psperdno; run;

data  tttrepay_plan_js_cs;
set tttrepay_plan_js;
format repay_date_js   yymmdd10.;
repay_date_js=mdy(scan(psduedt,2,"-"), scan(psduedt,3,"-"),scan(psduedt,1,"-"));
/*if SETLPRCP=PSPRCPAMT and SETLNORMINT=PSNORMINTAMT then  clear_date_js=repay_date_js;*/
*因为技术部的神奇设计，晋商客户暂不保留具体逾期天数
if repay_date_js<=mdy(10,25,2016) then clear_date_js=repay_date_js;
run;
data ctl_loaninstallment;
set csdata.ctl_loaninstallment(keep=BQYD_REPAYMENT_DATE contract_no SETTLEMENT_DATE);
format repay_date clear_date_js yymmdd10.;
repay_date=datepart(BQYD_REPAYMENT_DATE);
clear_date_js=datepart(SETTLEMENT_DATE);
keep CONTRACT_NO clear_date_js repay_date ;
run;
/* 剔除回购的合同  js*/
proc sql;
create table tttrepay_plan_js as
select a.*,b.clear_date_js from tttrepay_plan_js_cs  as a
left join ctl_loaninstallment as b  on a.contract_no=b.contract_no and a.repay_date_js=b.repay_date where a.contract_no not in (select contract_no from ss) ;
quit;



data tttrepay_plan_js;
set tttrepay_plan_js;
if contract_no="C2016091917511272699276" and PSPERDNO>=13  then do;clear_date_js=.;SETLPRCP=0 ;SETLNORMINT=0;end;
if contract_no="C2016100909460959537153" and PSPERDNO>=13 then do;clear_date_js=.;SETLPRCP=0 ;SETLNORMINT=0;end;
if contract_no="C2016120110081535875200" and PSPERDNO>=10 then do;clear_date_js=.;SETLPRCP=0 ;SETLNORMINT=0;end;
if contract_no="C2016120919060584392071" and PSPERDNO>=11 then do;clear_date_js=.;SETLPRCP=0 ;SETLNORMINT=0;end;
if contract_no="C2016121213424187356545" and PSPERDNO>=11 then do;clear_date_js=.;SETLPRCP=0 ;SETLNORMINT=0;end;
if contract_no="C2016110318322980045633" and PSPERDNO>=13 then do;clear_date_js=.;SETLPRCP=0 ;SETLNORMINT=0;end;
if contract_no="C2016112515202590098145" and PSPERDNO>=10 then do;clear_date_js=.;SETLPRCP=0 ;SETLNORMINT=0;end;
run;
proc sort data=tttrepay_plan_js;by contract_no PSPERDNO;run;
data repayfin.tttrepay_plan_js;
set tttrepay_plan_js;
run;
*小雨点;
/*2017-06-19*/
/*proc sql;*/
/*create table tttrepay_plan_xyd_1 as select a.*,b.回购 from account.repay_plan_xyd as a left join test3 as b on a.contract_no = b.contract_no; quit;*/
/**/
/*proc sql;*/
/*create table ss as*/
/*select * from test3 where contract_no not in (select contract_no from tttrepay_plan_xyd_1);*/
/*quit;*/
/* 剔除回购的合同  xyd 07-25*/
/*proc sql;*/
/*create table tttrepay_plan_xyd_1 as*/
/*select * from account.repay_plan_xyd  where contract_no not in (select contract_no from ss) ;*/
/*quit;*/
/*proc sort data = tttrepay_plan_xyd_1; by contract_no CURRENT_PERIOD descending ID; run;*/
/*proc sort data =  tttrepay_plan_xyd_1 nodupkey; by contract_no CURRENT_PERIOD; run;*/
/**/
/*data tttrepay_plan_xyd;*/
/*set tttrepay_plan_xyd_1 ;*/
/*if sum(BQYH_PRINCIPAL,BQYH_INTEREST_FEE)<sum(BQ_PRINCIPAL,BQ_INTEREST_FEE) then CLEAR_DATE=.;*/
/*if sum(BQYH_PRINCIPAL,BQYH_INTEREST_FEE)>=sum(BQ_PRINCIPAL,BQ_INTEREST_FEE) and OVERDUE_DAYS=0 then CLEAR_DATE=BQYD_REPAY_DATE;*/
/*else if sum(BQYH_PRINCIPAL,BQYH_INTEREST_FEE)>=sum(BQ_PRINCIPAL,BQ_INTEREST_FEE) and OVERDUE_DAYS>0 then CLEAR_DATE=intnx("day",BQYD_REPAY_DATE,OVERDUE_DAYS);*/
/*run;*/
/**/
/*PROC IMPORT OUT= xyd_hg */
/*            DATAFILE= "F:\A_offline_zky\A_offline\daily\日监控\历史数据\小雨点回购数据\小雨点回购数据.xlsx" */
/*            DBMS=EXCEL REPLACE;*/
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/*proc sql;*/
/*create table tttrepay_plan_xyd_ as*/
/*select a.*,b.逾期期数,b.备注*/
/*from tttrepay_plan_xyd as a*/
/*left join xyd_hg as b*/
/*on a.contract_no=b.合同号;*/
/*quit;*/
/*data tttrepay_plan_xyd;*/
/*set tttrepay_plan_xyd_;*/
/*if contract_no="C2017051515441319223399" and CURRENT_PERIOD>=2 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017030915524020647155" and CURRENT_PERIOD>=4 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2016120810505668447754" and CURRENT_PERIOD>=7 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2016121916103570537081" and CURRENT_PERIOD>=7 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2016122613314533249559" and CURRENT_PERIOD>=7 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017041412473619812801" and CURRENT_PERIOD>=3 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017041817142720563885" and CURRENT_PERIOD>=3 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017052414130485209275" and CURRENT_PERIOD>=2 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2016120812554397241884" and CURRENT_PERIOD>=8 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017010316504307243169" and CURRENT_PERIOD>=7 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017040714405118910057" and CURRENT_PERIOD>=4 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017010415511039575208" and CURRENT_PERIOD>=7 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2016120818053436269057" and CURRENT_PERIOD>=8 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2016122017521990890994" and CURRENT_PERIOD>=8 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017021711275448518008" and CURRENT_PERIOD>=6 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017041017172862299649" and CURRENT_PERIOD>=4 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017051111012119033440" and CURRENT_PERIOD>=3 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017051114395058179826" and CURRENT_PERIOD>=3 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017061617312703055807" and CURRENT_PERIOD>=2 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2016112818221601474214" and CURRENT_PERIOD>=9 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017053112023081325018" and CURRENT_PERIOD>=3 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no="C2017060713262691875311" and CURRENT_PERIOD>=3 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*if contract_no ="C2017060515221962120988" and CURRENT_PERIOD=5 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=52;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(12,30,2017);end;*/
/*else if contract_no ="C2017070316462091896879" and CURRENT_PERIOD=4 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=55;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(12,30,2017);end;*/
/*else if contract_no ="C2017073116061832944880" and CURRENT_PERIOD=3 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=57;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(12,30,2017);end;*/
/*else if contract_no="C2017081817264095454684" and CURRENT_PERIOD=2 and CLEAR_DATE=. then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*else if contract_no ="C2017061411260038416976" and CURRENT_PERIOD=6 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=47;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(1,31,2018);end;*/
/*else if contract_no ="C2017093015555113150651" and CURRENT_PERIOD=3 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=46;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(2,28,2018);end;*/
/*else if contract_no ="C2017111311475088668962" and CURRENT_PERIOD=2 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=44;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(2,28,2018);end;*/
/*else if contract_no ="C2017080909284970463060" and CURRENT_PERIOD=4 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=60;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(2,28,2018);end;*/
/*else if contract_no ="C2017080913595187112881" and CURRENT_PERIOD=4 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=60;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(2,28,2018);end;*/
/*else if contract_no ="C2016122215043544334572" and CURRENT_PERIOD=12 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=60;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(2,28,2018);end;*/
/**/
/*else if contract_no ="C2017082515122130782282" and CURRENT_PERIOD=6 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=61;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(4,30,2018);end;*/
/*else if contract_no ="C2017111510141391598755" and CURRENT_PERIOD=3 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=68;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(4,30,2018);end;*/
/*else if contract_no ="C2017031611023067109632" and CURRENT_PERIOD=12 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=36;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(4,25,2018);end;*/
/*else if contract_no ="C2017060511234028463371" and CURRENT_PERIOD=9 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=47;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(4,28,2018);end;*/
/*else if contract_no ="C2017060809371573609478" and CURRENT_PERIOD=9 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=45;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(4,28,2018);end;*/
/*else if contract_no ="C2017092012041375724745" and CURRENT_PERIOD=6 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=34;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(4,30,2018);end;*/
/*else if contract_no ="C2017092014142272260580" and CURRENT_PERIOD=6 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=37;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(5,1,2018);end;*/
/*else if contract_no ="C2017102313160578845316" and CURRENT_PERIOD=5 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=37;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(4,30,2018);end;*/
/**/
/*if contract_no ="C2017080410211770435844" and CURRENT_PERIOD=8 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=53;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(5,31,2018);end;*/
/*else if contract_no ="C2017080410211770435844" and CURRENT_PERIOD=9 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=23;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(5,31,2018);end;*/
/*else if contract_no ="C2017080410211770435844" and CURRENT_PERIOD>9 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=0;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(5,31,2018);end;*/
/**/
/**/
/*if contract_no ="C2017113013252201372210" and CURRENT_PERIOD=4 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=57;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(5,31,2018);end;*/
/*else if contract_no ="C2017113013252201372210" and CURRENT_PERIOD=5 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=27;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(5,31,2018);end;*/
/*else if contract_no ="C2017113013252201372210" and CURRENT_PERIOD>5 then do;BQYH_PRINCIPAL=BQ_PRINCIPAL;OVERDUE_DAYS=0;*/
/*BQYH_INTEREST_FEE=BQ_INTEREST_FEE;CLEAR_DATE=mdy(5,31,2018);end;*/
/**/
/*else if 备注="回购中" and CURRENT_PERIOD>=逾期期数 then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
/*run;*/
/*proc sql;*/
/*create table xyd1 as select a.*,b.CURR_RECEIVE_INTEREST_AMT from*/
/*tttrepay_plan_xyd as a left join account.repay_plan as b on a.contract_no = b.contract_no and a.CURRENT_PERIOD=b.CURR_PERIOD;quit;*/
/*data tttrepay_plan_xyd;*/
/*set xyd1;*/
/*if CURR_RECEIVE_INTEREST_AMT>0 and BQ_INTEREST_FEE<1  then BQ_INTEREST_FEE=CURR_RECEIVE_INTEREST_AMT;*/
/*drop CURR_RECEIVE_INTEREST_AMT;*/
/*run;*/
/*data repayfin.tttrepay_plan_xyd;*/
/*set tttrepay_plan_xyd;*/
/*run;*/
/*/*检查是否出现回购*/*/
/*data aa;*/
/*set tttrepay_plan_xyd;*/
/*if BQ_INTEREST_FEE =0;*/
/*run;*/;


/*proc sort data = tttrepay_plan_xyd ; by contract_no descending CURRENT_PERIOD;run;*/
/**/
/*data tttrepay_plan_xyd;*/
/*set tttrepay_plan_xyd ;*/
/*by CONTRACT_NO;*/
/*format pre_repay_date yymmdd10.;*/
/*retain pre_rd;*/
/*if first.CONTRACT_NO then pre_rd = CLEAR_DATE;*/
/*else do; pre_repay_date = pre_rd; pre_rd = CLEAR_DATE; end;*/
/*run;*/
/**/
/*data tttrepay_plan_xyd;*/
/*set tttrepay_plan_xyd; */
/*if clear_date = pre_repay_date then CLEAR_DATE=. ;*/
/*drop pre_rd;*/
/*run;*/
/*proc sql;*/
/*create table tttrepay_plan_xyd(where=(资金渠道 ^="tsjr1")) as */
/*select a.*,b.资金渠道 from tttrepay_plan_xyd as a*/
/*left join account as b on a.contract_no=b.contract_no;*/
/*quit;*/


data apply_time;
set appMid.apply_time(keep = apply_code apply_time 营业部 DESIRED_PRODUCT 进件日期 hire SOCIAL_SECURITY);
if kindex(营业部,"上海第二") then 营业部="上海福州路营业部";
run;

data account_info;
set account.account_info(keep = contract_no ch_name branch_code fund_channel_code product_name id_number account_status contract_amount remain_capital  
							period complete_period curr_period loan_date LAST_REPAY_DATE TEAM_MANAGER CUSTOMER_MANAGER BORROWER_TEL_ONE);
apply_code = tranwrd(contract_no, "C", "PL");
run;
proc sort data = account_info nodupkey; by apply_code ; run;
proc sort data = apply_time ; by apply_code 营业部; run;
data account_info1;
merge account_info(in = a) apply_time(in = b);
by apply_code;
if a;
format 产品大类 $10.;
	 if index(product_name, "E贷通") then 产品大类 = "E贷通";
else if index(product_name, "U贷通") & datepart(apply_time) < mdy(5, 8, 2016) then 产品大类 = "U贷通";
else if index(product_name, "U贷通") then 产品大类 = "新U贷通";
else if product_name = "E保通-自雇" then 产品大类 = "E保通-自雇";
else if index(product_name,"E微贷-无社保") then 产品大类="E微贷-无社保";
else if index(product_name,"E微贷-自雇") then 产品大类="E微贷-自雇";
else if index(product_name,"E宅通-自雇") then 产品大类="E宅通-自雇";
else if index(product_name,"Easy贷信用卡") then 产品大类="Easy贷信用卡";
else if index(product_name,"Easy贷芝麻分") then 产品大类="Easy贷芝麻分";
else 产品大类 = ksubstr(product_name, 1, 3);

if apply_time>=mdy(3,1,2018) then do;
if hire=1 then do;
if 产品大类="E保通" then 产品大类1="E保通-自雇";
else if 产品大类="E房通" then 产品大类1="E房通-自雇";
else if 产品大类="E社通" then 产品大类1="E社通-自雇";
else if 产品大类 in ("E微贷","") then 产品大类1="E微贷-自雇";
else if 产品大类="E宅通" then 产品大类1="E宅通-自雇";
end;
else if SOCIAL_SECURITY=0 then do;
if 产品大类="E保通" then 产品大类1="E保通-无社保";
else if 产品大类="E房通" then 产品大类1="E房通-无社保";
else if 产品大类="E社通" then 产品大类1="E社通-无社保";
else if 产品大类="E微贷" then 产品大类1="E微贷-无社保";
else if 产品大类="E宅通" then 产品大类1="E宅通-无社保";
end;
end;
if 产品大类1^="" then 产品大类=产品大类1;
drop 产品大类1;


/*if not kindex(product_name,"RF");*/
/*if not kindex(DESIRED_PRODUCT,"RF");*/
rename fund_channel_code = 资金渠道 product_name = 产品小类 ch_name = 客户姓名 id_number = 身份证号码;
run;
proc sort data=account_info1;by contract_no;run;


data repay_plan;
set account.repay_plan(keep = contract_no CURR_PERIOD CURR_RECEIVE_CAPITAL_AMT CURR_RECEIVE_INTEREST_AMT REPAY_DATE);
run;

data company_account_pay_register;
set account.company_account_pay_register;
run;


/*7/25*/
data bill_main;
set account.bill_main(keep = contract_no bill_code curr_period repay_date clear_date bill_status OVERDUE_DAYS curr_receive_amt CURR_RECEIPT_AMT );
run;

proc sql;
create table bill_main_ac as
select a.*,b.FUND_CHANNEL_CODE from bill_main as a
left join account_info as b on a.contract_no=b.contract_no;
quit;

/*/*因为6月小雨点提前结清出现问题，暂时修复clear_date为上周五,此处只是为了找出合同号，clear_date为几号没关系，后面的clear_date有修复*/*/
/*data bill_main_zs;*/
/*set bill_main_ac;*/
/*if BILL_STATUS="0000" and clear_date<=0 then  do;
/*clear_date=mdy(6,22,2018);CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;*/*/
/*run;*/;

*transfer_info含有小雨点提前结清挂账的日期，用挂账的日期视为提前结清的日期;
data transfer_info_xyd;
set account.transfer_info;
/*if TRANSFER_TYPE="17" and TRANSFER_STATUS="2";*/
if TRANSFER_TYPE="17" or TRANSFER_STATUS="2" ;
run;
proc sort data=transfer_info_xyd  ;by APPLY_CODE descending TRANSFER_DATE   ;run;
proc sort data=transfer_info_xyd nodupkey ;by APPLY_CODE  ;run;

proc sql;
create table bill_main_gz as
select a.*,b.TRANSFER_DATE from 
bill_main_ac as a 
left join transfer_info_xyd as b
on a.contract_no=b.APPLY_CODE;
quit;


data bill_main_zs;
set bill_main_gz;
if TRANSFER_DATE>0 and BILL_STATUS="0000" and clear_date<=0 then  do;clear_date=TRANSFER_DATE;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end; 
run;

data bill_main_ac1;
set bill_main_zs;
*30是粗算法，意义是至少存在一期提前30天还款的客户基本就是提前还款了;
if kindex(FUND_CHANNEL_CODE,"xyd") and sum(repay_date,-clear_date)>30 and clear_date>0  and BILL_STATUS="0000";
run;
proc sort data=bill_main_ac1 nodupkey;by contract_no;run;

proc sql;
create table account_info2 as
select a.*,b.contract_no as contract_noxydjq from account_info1 as a
left join bill_main_ac1 as b on a.contract_no=b.contract_no;
quit;
data account_info;
set account_info2;
if contract_noxydjq^="" and ACCOUNT_STATUS="0000" then ACCOUNT_STATUS="0003";
run;

data excessive_pay_info;
set account.excessive_pay_info;
run;

data offset_info;
set account.offset_info;
run;
/*对公入账延迟，用对公日期作为清算日期*/
proc sql;
create table test as
select a.*,b.EXCESSIVE_CODE  from company_account_pay_register as a
left join excessive_pay_info as b on a.REGISTER_CODE=b.SOURCE_NO;
quit;

data test1;
set test;
if EXCESSIVE_CODE="" then EXCESSIVE_CODE=REGISTER_CODE;
run;
proc sort data=test1 nodupkey;by EXCESSIVE_CODE;run;
proc sql;
create table  test2 as 
select a.*,b.BILL_CODE from test1 as a
left join offset_info as b on a.EXCESSIVE_CODE=b.OFFSET_SOURCE_NO;
quit;
proc sort data=test2 nodupkey;by EXCESSIVE_CODE  BILL_CODE;run;
proc sql;
create table test3 as
select a.*,b.clear_date as 清算日期,c.fund_channel_code as 资金渠道  from bill_main as a
left join test2 as b on a.bill_code=b.bill_code
left join approval.contract as c on a.contract_no=c.contract_no;
quit;
data test4;
set test3;
format dat1 yymmdd10.;
if REPAY_DATE<=清算日期<=CLEAR_DATE and  清算日期- REPAY_DATE+15>OVERDUE_DAYS then do; CLEAR_DATE=清算日期; dat1=清算日期;end;
/*if  清算日期>0 and  REPAY_DATE<=清算日期  and  清算日期- REPAY_DATE+15>OVERDUE_DAYS then do; CLEAR_DATE=清算日期; dat1=清算日期;end;*/
run;
/*2017-06-19*/
proc sql;
create table test_1 as
select * from test4 where contract_no  in (select contract_no from ss);
quit;
data test_1;
set test_1;
资金渠道 = 'tsjr1';
run;

proc sql;
create table test_2 as
select * from test4 where contract_no not in (select contract_no from ss);
quit;
data test4;
set test_1 test_2;
run;
/*2017-06-19*/
proc sort data=test4 ;by contract_no bill_code descending dat1;run;
proc sort data=test4 out=test4_1 nodupkey ;by contract_no bill_code;run;
data test4_1a;
set test4_1;
if kindex(BILL_CODE,"SKB") and clear_date>0;
rename repay_date=repay_date2 clear_date=clear_date2;
/*keep contract_no repay_date clear_date;*/
run;

data test4_1_1;
set test4_1;
if OVERDUE_DAYS=180  and bill_status="0003" ;
rename REPAY_DATE=REPAY_DATE1;
keep contract_no REPAY_DATE;
run;

data test4_1_2;
merge test4_1(in =a ) test4_1_1 test4_1a;
by contract_no;
if a;
attrib _all_ label="";
run;
proc sort data = test4_1_2  ;by contract_no CURR_PERIOD descending clear_date;run;
proc sort data = test4_1_2 nodupkey ;by contract_no CURR_PERIOD ;run;

data test4_1;
set test4_1_2;

if REPAY_DATE1>0 then do;
if &dt.>=REPAY_DATE>=REPAY_DATE1 then do;BILL_STATUS="0002";OVERDUE_DAYS=sum(&dt.,-repay_date);end;
if REPAY_DATE>&dt. then do;BILL_STATUS="0001";OVERDUE_DAYS=0;end;end;

if clear_date2>0 then do;
if REPAY_DATE=repay_date2 then BILL_STATUS="0000";
if REPAY_DATE>repay_date2 then delete;end;
drop REPAY_DATE1 repay_date2 clear_date2;
run;

data bill_main_zs;
set test4_1;
if bill_status not in ("0003","0004","0005");	/*排除挂起(0003)与取消(0005)的账单*/
/*if clear_date ^= . then clear_date = intnx("day", repay_date, overdue_days);*/
/*第三方扣款失败或对公还款的clear_date可能不准，用overdue_days来修正*/
if bill_status="0001" and repay_date>&dt. then clear_date=repay_date;
if contract_no='C2018101613583597025048' then clear_date=repay_date;*特殊客户，不用催收;
if 资金渠道 ="tsjr1" and BILL_STATUS="0000" then clear_date=intnx("day",REPAY_DATE,OVERDUE_DAYS);
/*if contract_no in ('C2016112914505881780538','C2016110918392520434310','C2016121615345621583310','C2016122113013749889988') then 资金渠道 = 'tsjr1';*/
if 资金渠道 not in ("jsxj1");*剔除小雨点 晋商的;
*手动收拾技术部的摊子;
if bill_code="BLC20161021153655608956435" then do; CLEAR_DATE=mdy(4,2,2017);OVERDUE_DAYS=7;end;
if bill_code="BLC20161219170953737344595" then do; CLEAR_DATE=mdy(5,26,2017);OVERDUE_DAYS=0;end;
if bill_code="BLC201605231432475885489518" then do;CLEAR_DATE=mdy(12,31,2017);OVERDUE_DAYS=36;BILL_STATUS="0000";end;
if bill_code="BLC201605120946046282533018" then do;CLEAR_DATE=mdy(12,31,2017);OVERDUE_DAYS=42;BILL_STATUS="0000";end;
if bill_code="BLC20170410172950753328068" then do;CLEAR_DATE=mdy(1,25,2018);end;
if bill_code ="BLC20170719164438322925906" then do;CLEAR_DATE=mdy(2,28,2018);OVERDUE_DAYS=35;BILL_STATUS="0000";end;
if bill_code ="BLC20170512194850977843048" then do;CLEAR_DATE=mdy(2,28,2018);OVERDUE_DAYS=37;BILL_STATUS="0000";end;
if bill_code ="BLC20170622172008559359628" then do;CLEAR_DATE=mdy(4,30,2018);OVERDUE_DAYS=61;BILL_STATUS="0000";end;
if bill_code ="BLC20171106154104464315803" then do;CLEAR_DATE=mdy(4,30,2018);OVERDUE_DAYS=76;BILL_STATUS="0000";end;
if bill_code ="BLC20180118163400330242492" then do;CLEAR_DATE=mdy(5,31,2018);OVERDUE_DAYS=69;BILL_STATUS="0000";end;
if bill_code ="BLC20170714182619230109198" then do;CLEAR_DATE=mdy(5,31,2018);OVERDUE_DAYS=74;BILL_STATUS="0000";end;
if bill_code ="BLC201708291745377093813010" then do;CLEAR_DATE=mdy(8,31,2018);OVERDUE_DAYS=56;BILL_STATUS="0000";end;
if bill_code ="BLC20171124093625494642108" then do;CLEAR_DATE=mdy(8,31,2018);OVERDUE_DAYS=33;BILL_STATUS="0000";end;
if bill_code ="BLC201706271153030538796712" then do;CLEAR_DATE=mdy(8,31,2018);OVERDUE_DAYS=55;BILL_STATUS="0000";end;
if bill_code ="BLC201710231726093966534810" then do;CLEAR_DATE=mdy(10,31,2018);OVERDUE_DAYS=59;BILL_STATUS="0000";end;
if bill_code ="BLC201610281207424731236724" then do;CLEAR_DATE=mdy(12,31,2018);OVERDUE_DAYS=54;BILL_STATUS="0000";end;
if bill_code ="BLC201709221113116478754314" then do;CLEAR_DATE=mdy(12,31,2018);OVERDUE_DAYS=36;BILL_STATUS="0000";end;
if bill_code ="BLC201711240936254946421012" then do;CLEAR_DATE=mdy(12,31,2018);OVERDUE_DAYS=32;BILL_STATUS="0000";end;
if bill_code ="BLC201708021745066848390916" then do;CLEAR_DATE=mdy(1,31,2019);OVERDUE_DAYS=50;BILL_STATUS="0000";end;
if bill_code ="BLC201708021745066848390917" then do;CLEAR_DATE=mdy(2,28,2019);OVERDUE_DAYS=47;BILL_STATUS="0000";end;
if bill_code ="BLC201704261733437061984021" then do;CLEAR_DATE=mdy(3,1,2019);OVERDUE_DAYS=25;BILL_STATUS="0000";end;

*月底提前结清的客户;
if contract_no="C2017080410211770435844" and CURR_PERIOD<8 then do ;CLEAR_DATE=REPAY_DATE;end;
if contract_no="C2017080410211770435844" and CURR_PERIOD>=8 then do ;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;CLEAR_DATE=mdy(5,31,2018);BILL_STATUS="0000";end;
if contract_no="C2017113013252201372210" and CURR_PERIOD<4 then do ;CLEAR_DATE=REPAY_DATE;end;
if contract_no="C2017113013252201372210" and CURR_PERIOD>=4 then do ;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;CLEAR_DATE=mdy(5,31,2018);BILL_STATUS="0000";end;
run;

data transfer_info_xyd;
set account.transfer_info;
if TRANSFER_TYPE="17" or TRANSFER_STATUS="2";
run;
proc sort data=transfer_info_xyd  ;by APPLY_CODE descending TRANSFER_DATE   ;run;
proc sort data=transfer_info_xyd nodupkey ;by APPLY_CODE  ;run;
proc sql;
create table bill_main_gz as
select a.*,b.TRANSFER_DATE from 
bill_main_zs as a 
left join transfer_info_xyd as b
on a.contract_no=b.APPLY_CODE;
quit;


data bill_main;
set bill_main_gz;
if TRANSFER_DATE>0 and BILL_STATUS="0000" and clear_date<=0 then  do;clear_date=TRANSFER_DATE;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end; 
run;
/*/*因为6月小雨点提前结清出现问题，暂时修复clear_date为上周五*/*/
/*data bill_main;*/
/*set bill_main_zs;*/
/*if BILL_STATUS="0000" and clear_date<=0 then  do;
/*clear_date=TRANSFER_DATE;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;*/*/
/*run;*/



********************************************** 回购逻辑 start ********************************************************;
/*对于bill_main没被修改的数据，第一期肯定就是他的回购日期*/
/*对于5月23日后的小雨点回购数据，bill_main正常，offset_date异常的数据由回迁逻辑进行修改*/

proc sql;
create table turn_back as 
select a.contract_no,a.fund_channel_code , b.FUND_CHANNEL_CODE as 资金渠道 from approval.contract(keep=contract_no fund_channel_code) as a
left join account.account_info(keep=contract_no FUND_CHANNEL_CODE) as b on a.contract_no = b.contract_no;
quit;
data turn_back_1;
set turn_back;
if 资金渠道="tsjr1" and (kindex(fund_channel_code,"xyd") or fund_channel_code = 'jsxj1');
run;
proc sql;
create table bill_main_tb as 
select a.* from account.bill_main as a
where a.contract_no in (select contract_no from turn_back_1);
quit;
proc sort data=bill_main_tb;by contract_no CURR_PERIOD;run;
proc sort data=bill_main_tb out=bill_main_tb_ nodupkey;by contract_no;run;

********************************************** 回购逻辑 end ********************************************************;

********************************************************************** 回迁逻辑 start ***************************************************************************************;
/*找出小雨点第一期offset_date日期,如果第一期的时间有多次本金还款，那基本可以确定此时间为回迁时间，剩下少部分提前还款把clear_date拼过来并不影响结果*/
/*第一期即逾期，后一次还两期的合同应该比较少，且这种情况影响的金额很少时间很短*/

proc sql;
create table huiqian_dt as
select contract_no,FEE_DATE,OFFSET_DATE,CURR_PERIOD
from account.bill_fee_dtl where FEE_NAME='本金' and contract_no in (select contract_no from approval.contract where fund_channel_code in ('xyd1','xyd2'));
quit;
proc sort data=huiqian_dt;by contract_no CURR_PERIOD;run;
proc sort data=huiqian_dt out=huiqian_dto nodupkey;by contract_no;run;

proc freq data=huiqian_dt(where=(OFFSET_DATE>0)) noprint;
table contract_no*OFFSET_DATE/out=huiqian_dt_;
run;
proc sql;
create table huiqian_dt_1 as 
select a.*,b.offset_date as offset_one from huiqian_dt_ as a
left join huiqian_dto as b on a.contract_no=b.contract_no;
quit;
data huiqian_dt_2;
set huiqian_dt_1;
if offset_date=offset_one;
if COUNT>1;
if offset_date>mdy(5,22,2018);
run;
proc sort data=huiqian_dt_2;by contract_no descending COUNT;run;
proc sort data=huiqian_dt_2 nodupkey out=huiqian_dt_3;by contract_no;run;
proc sort data=huiqian_dt_3;by descending offset_date;run;
************************************************************************* 回迁逻辑 end ************************************************************************************;



data bill_fee_dtl;
set account.bill_fee_dtl(keep = contract_no fee_name curr_receive_amt curr_receipt_amt offset_date FEE_DATE bill_code);
if kindex(contract_no,"C");
run;

proc sql;
create table bill_fee_dtl_ac as
select a.*,b.clear_date,c.fund_channel_code as 资金渠道,d.clear_date as clear_date_hg,e.offset_date as clear_date_hq from bill_fee_dtl as a
left join bill_main as b on a.contract_no=b.contract_no and a.BILL_CODE=b.BILL_CODE
left join approval.contract as c on a.contract_no=c.contract_no
left join bill_main_tb_ as d on a.contract_no=d.contract_no
left join huiqian_dt_3 as e on a.contract_no=e.contract_no;
quit;
*搞定;
data bill_fee_dtl;
set bill_fee_dtl_ac;
*对于offset_date等于回购日期部分进行修改;
if clear_date_hg=offset_date and clear_date>0 then do;offset_date=clear_date;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;
*对于offset_date等于回迁日期部分进行修改;
if kindex(资金渠道,"xyd") and clear_date_hq=offset_date and clear_date>0 then do;offset_date=clear_date;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;
*这里主要是有些小雨点已经结清的数据offset_date未更新;
if kindex(资金渠道,"xyd") and  clear_date>0 and offset_date<1 then do;offset_date=clear_date;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;
if bill_code="EBL2018011209071809" then delete;
if bill_code="EBL2016081614292303" then delete;
run;
proc sort data=bill_fee_dtl;by contract_no FEE_DATE;run;


/*proc sql;*/
/*create table bill_fee_dtl_1_ as*/
/*select a.*,b.逾期期数,b.备注,b.挂账日期*/
/*from bill_fee_dtl as a*/
/*left join xyd_hg as b*/
/*on a.contract_no=b.合同号;*/
/*quit;*/
/**/
/*data bill_fee_dtl;*/
/*set bill_fee_dtl_1_;*/
/*if 逾期期数>0 and 备注="回购中" and CURR_PERIOD<逾期期数 then do; CURR_RECEIPT_AMT=CURR_RECEIVE_AMT ; OFFSET_DATE=挂账日期;end;*/
/*run;*/
/*proc sort data=bill_fee_dtl nodupkey ;by contract_no bill_code fee_name;run;*/


/*提前结清*/
/*/*原逻辑，修改后，将小雨点上下拼接过来修复缺少的提前结清账户*/*/
/*data early_repay;*/
/*set account_info(where = (account_status = "0003") keep = contract_no account_status); /*提前结清账户*/*/
/*keep contract_no;*/
/*run;*/;
data early_repay;
set account_info(where = (account_status = "0003") keep = contract_no account_status ); /*除小雨点在5.23前外，提前结清账户*/
keep contract_no ;
run;

/*此处的Bill_main是前面做了修复的小雨点的，原本小雨点搬迁之前已结清的在bill_main显示的就是0001，修复代码在前面，现在是已经修复成0000，再在此处使用*/
data early_bill;
set bill_main(where = (bill_status = "0000") keep = contract_no bill_status curr_period clear_date); /*结清账单*/
run;
proc sort data = early_bill nodupkey; by contract_no decending curr_period; run; 
proc sort data = early_bill nodupkey; by contract_no; run; /*最后结清的账单*/
proc sort data = early_repay nodupkey; by contract_no; run;
data early_repay;
merge early_repay(in = a) early_bill(in = b rename = (clear_date = es_date));
by contract_no;
if a;
keep contract_no es_date; /*提前结清账户最后结清的账单结清时间即账户结清时间 es_date-提前结清时间*/
run;
proc sort data = early_repay nodupkey; by contract_no; run;

/*首期违约*/
data default_1st_period;
set account.bill_main(where = (CURR_PERIOD = 1 & bill_status ^= "0003" & (clear_date = . or (clear_date > repay_date and overdue_days > 0)))); /*第三方扣款失败或对公还款的clear_date可能不准，是否逾期以overdue_days来判断*/
if repay_date < &dt.;
default_1st_period = 1;
month = put(repay_date, yymmn6.);
run;
proc sort data=default_1st_period nodupkey out=aaa;by contract_no ;run;
/*proc freq data = default_1st_period;*/
/*table month;*/
/*run;*/
/*前两期连续违约*/
data default_top2_period;
set account.bill_main(where = (curr_period = 1 & bill_status ^= "0003"));
/*if clear_date = . or clear_date > intnx("month", repay_date, 1, "same");*/
if overdue_days > intck("day", repay_date, intnx("month", repay_date, 1, "same"));
if intnx("month", repay_date, 1, "same") < &dt.;
default_top2_period = 1;
month = put(intnx("month", repay_date, 1, "same"), yymmn6.);
run;
proc sort data=default_top2_period nodupkey out=aaa;by contract_no ;run;
/*proc freq data = default_top2_period;*/
/*table month;*/
/*run;*/

proc delete data=payment;run;
%macro get_payment;
data _null_;
*早上;
n = day(&dt.) ;
*下午;
/*n = day(&nt.) - 1;*/
call symput("n", n);
run;

%put &n.;
%do i = 0 %to &n.;

data _null_;
start_dt = intnx("month", &dt., -1, "e");
cut_dt = intnx("day", start_dt, &i.);
call symput("cut_dt", cut_dt);
run;


/*%let cut_dt=mdy(05,24,2018);*/

/*cut_dt之前放款的合同*/
data contract;
set account_info(where = (loan_date <= &cut_dt.));
run;
********************************************
贷款余额——某个时间点（cut_dt）应还未还本息和
********************************************;
/*---------------------------------------贷款余额start-------------------------------------------------*/
/*截至cut_dt应还本金，即合同金额*/
data capital;
set account_info(keep = contract_no contract_amount rename = (contract_amount = total_capital));
run;

/*截至cut_dt应还利息*/
proc sort data = repay_plan nodupkey; by contract_no CURR_PERIOD; run;

data interest0;
set repay_plan;
by contract_no CURR_PERIOD;
format pre_repay_date yymmdd10.;
retain pre_rd;
if first.contract_no then pre_rd = repay_date;
else do; pre_repay_date = pre_rd; pre_rd = repay_date; end;

if repay_date <= &cut_dt. or (&cut_dt. < repay_date and pre_repay_date = .) or (&cut_dt. < repay_date and &cut_dt. > pre_repay_date);
if REPAY_DATE <= &cut_dt. then acc_interest = CURR_RECEIVE_INTEREST_AMT;
else do;
	if pre_repay_date = . then pre_repay_date = intnx("month", repay_date, -1, "s");
	acc_interest = CURR_RECEIVE_INTEREST_AMT * (&cut_dt. - pre_repay_date) / (repay_date - pre_repay_date);
	end;
run;


proc sql;
create table interest as
select contract_no, sum(acc_interest) as total_interest
from interest0
group by contract_no
;
quit;

*晋商;
data repay_plan_js_lx_owe;
set tttrepay_plan_js;
by contract_no PSPERDNO;
format pre_repay_date yymmdd10.;
retain pre_rd;
if first.contract_no then pre_rd = repay_date_js;
else do; pre_repay_date = pre_rd; pre_rd = repay_date_js; end;
if repay_date_js <= &cut_dt. or (&cut_dt. < repay_date_js and pre_repay_date = .) or (&cut_dt. < repay_date_js and &cut_dt. > pre_repay_date);
if REPAY_DATE_js <= &cut_dt. then acc_interest = PSNORMINTAMT;
else do;
	if pre_repay_date = . then pre_repay_date = intnx("month", repay_date_js, -1, "s");
	acc_interest = PSNORMINTAMT * (&cut_dt. - pre_repay_date) / (repay_date_js - pre_repay_date);
	end;
run;
proc sql;
create table interest_js as
select contract_no, sum(acc_interest) as total_interest_js
from repay_plan_js_lx_owe
group by contract_no
;
quit;
*小雨点;
/*data tttrepay_plan_xyd_lx_owe;*/
/*set tttrepay_plan_xyd;*/
/*by contract_no CURRENT_PERIOD;*/
/*format pre_repay_date yymmdd10.;*/
/*retain pre_rd;*/
/*if first.contract_no then pre_rd = BQYD_REPAY_DATE;*/
/*else do; pre_repay_date = pre_rd; pre_rd = BQYD_REPAY_DATE; end;*/
/*if BQYD_REPAY_DATE <= &cut_dt. or (&cut_dt. < BQYD_REPAY_DATE and pre_repay_date = .) or (&cut_dt. < BQYD_REPAY_DATE and &cut_dt. > pre_repay_date);*/
/*if BQYD_REPAY_DATE <= &cut_dt. then acc_interest = BQ_INTEREST_FEE;*/
/*else do;*/
/*	if pre_repay_date = . then pre_repay_date = intnx("month", BQYD_REPAY_DATE, -1, "s");*/
/*	acc_interest = BQ_INTEREST_FEE * (&cut_dt. - pre_repay_date) / (BQYD_REPAY_DATE - pre_repay_date);*/
/*	end;*/
/*run;*/
/*proc sql;*/
/*create table interest_xyd as*/
/*select contract_no, sum(acc_interest) as total_interest_xyd*/
/*from tttrepay_plan_xyd_lx_owe*/
/*group by contract_no*/
/*;*/
/*quit;*/
proc sort data = interest nodupkey; by contract_no; run;
proc sort data = interest_js nodupkey; by contract_no; run;
/*proc sort data = interest_xyd nodupkey; by contract_no; run;*/
data interest;
merge interest(in = a) interest_js(in = b) ;
by contract_no;
if a;
if b then total_interest = total_interest_js;
/*if c then total_interest = total_interest_xyd;*/
drop total_interest_js ;
run; 

/*截至cut_dt已还本金*/
proc sql;
create table receipt_capital as
select contract_no, sum(curr_receipt_amt) as receipt_capital
from bill_fee_dtl
where fee_name = "本金" & offset_date <= &cut_dt.
group by contract_no
;
quit;

/*截至cut_dt晋商合同已还本金*/
data repay_plan_js;
set tttrepay_plan_js;
if repay_date_js<= &cut_dt. ;
run;
proc sql;
create table setl_capital as
select contract_no, sum(SETLPRCP) as setl_capital
from repay_plan_js
group by contract_no
;
quit;
/*截至cut_dt小雨点合同已还本金*/
/*data repay_plan_xyd;*/
/*set tttrepay_plan_xyd;*/
/*if BQYD_REPAY_DATE<= &cut_dt. ;*/
/*run;*/
/*proc sql;*/
/*create table xyd_capital as*/
/*select contract_no, sum(BQYH_PRINCIPAL) as xyd_capital*/
/*from repay_plan_xyd*/
/*group by contract_no*/
/*;*/
/*quit;*/


proc sort data = receipt_capital nodupkey; by contract_no; run;
proc sort data = setl_capital nodupkey; by contract_no; run;
/*proc sort data = xyd_capital nodupkey; by contract_no; run;*/

data receipt_capital;
merge receipt_capital(in = a) setl_capital(in = b) ;
by contract_no;
if a;
if b then receipt_capital = setl_capital;
/*if c then receipt_capital = xyd_capital;*/
drop setl_capital ;
run; 

/*截至cut_dt已还利息*/
proc sql;
create table receipt_interest as
select contract_no, sum(curr_receipt_amt) as receipt_interest
from bill_fee_dtl
where fee_name = "利息" & offset_date <= &cut_dt. 
group by contract_no
;
quit;
/*截至cut_dt晋商合同已还利息*/
*repay_plan_js已经对  repay_date_js做处理了，下面有跟没有无区别;
proc sql;
create table receipt_interest_js as
select contract_no,sum(SETLNORMINT) as receipt_interest_js 
from repay_plan_js where repay_date_js<= &cut_dt. group by contract_no;
quit;
/*截至cut_dt小雨点合同已还利息*/
*repay_plan_xyd已经对  BQYD_REPAY_DATE做处理了，下面有跟没有无区别;

/*proc sql;*/
/*create table receipt_interest_xyd as*/
/*select contract_no,sum(BQYH_INTEREST_FEE) as receipt_interest_xyd */
/*from repay_plan_xyd where BQYD_REPAY_DATE<= &cut_dt.  group by contract_no;*/
/*quit;*/

/*proc sort data = receipt_interest_xyd nodupkey; by contract_no; run;*/
proc sort data = receipt_interest_js nodupkey; by contract_no; run;
proc sort data = receipt_interest nodupkey; by contract_no; run;
data receipt_interest;
merge receipt_interest(in = a) receipt_interest_js(in = b) ;
by contract_no;
if a;
if b then receipt_interest = receipt_interest_js;
/*if c then receipt_interest = receipt_interest_xyd;*/
drop receipt_interest_js ;
run; 

proc sort data = capital nodupkey; by contract_no; run;
proc sort data = interest nodupkey; by contract_no; run;
proc sort data = receipt_capital nodupkey; by contract_no; run;
proc sort data = receipt_interest nodupkey; by contract_no; run;
data outstanding;
merge capital(in = a) interest(in = b) receipt_capital(in = c) receipt_interest(in = d) early_repay(in = e);
by contract_no;
if a;
outstanding = sum(total_capital ,total_interest, -receipt_capital, -receipt_interest); /*贷款余额*/
outstanding_capital = sum(total_capital ,- receipt_capital); /*余额余额_本金部分*/
if es_date ^=. and es_date <= &cut_dt. then do; es = 1; outstanding = 0; outstanding_capital = 0; end; /*es-提前结清标志*/
if intck("month", &cut_dt., es_date) = 0 then crt_mth_es = 1; /*crt_mth_es-当月提前结清标志*/
drop total_capital total_interest  ;
run;
/*---------------------------------------贷款余额end-------------------------------------------------*/

****************************************
违约统计
****************************************;
/*---------------------------------------违约统计start-------------------------------------------------*/
/*账单日首次违约、新增违约、连续违约*/
data default_0;
set bill_main;
if repay_date <= &cut_dt.;
run;
proc sort data = default_0; by contract_no; run;
data default_0;
merge default_0(in = a) early_repay(in = b);
by contract_no;
if a;
if b & clear_date = es_date and clear_date>0 then delete; /*删除提前结清那条账单*/
run;
proc sort data = default_0 nodupkey; by contract_no curr_period; run;
data default_1;
set default_0;
by contract_no curr_period; 
format pre_clear_date yymmdd10.;
retain pcd od_times 0; /*od_times用来判断是否首次违约（default_1st_time）*/
if first.contract_no then do; pcd = clear_date; od_times = 0; end;
else do; pre_clear_date = pcd; pcd = clear_date; end;
if overdue_days > 0 then od_times = od_times + 1;
if last.contract_no;
run;
data default;
set default_1;
if od_times = 1 then default_1st_time = 1; 
if curr_period = 1 and (clear_date = . or (clear_date > repay_date and overdue_days > 0)) then default_new = 1;
if (pre_clear_date ^=. and pre_clear_date < repay_date) and ((repay_date < clear_date and overdue_days > 0) or clear_date = .) then default_new = 1; /*往期账单在本期账单日之前已结清，本期账单逾期*/
if default_new = 1 and max(clear_date, &cut_dt.) - repay_date > 5 then default_new_5p = 1;
if curr_period > 1 and (pre_clear_date = . or pre_clear_date > &cut_dt.) then default_continuous = 1;
if default_new = 1 and (clear_date ^=. and clear_date < repay_date + 30) then default_new_recovery_in30day = 1;
keep contract_no default_1st_time default_new default_new_5p default_continuous default_new_recovery_in30day repay_date clear_date ;
run;
*晋商;
data repay_plan_js;
set tttrepay_plan_js;
if repay_date_js<= &cut_dt.;
rename repay_date_js=repay_date
       clear_date_js=clear_date;
run;
proc sort data=repay_plan_js ;by contract_no descending repay_date;run;
proc sort data=repay_plan_js nodupkey out=repay_plan_js_rc(keep=contract_no repay_date clear_date );by contract_no ;run;
*小雨点;
/*data repay_plan_xyd;*/
/*set tttrepay_plan_xyd;*/
/*if BQYD_REPAY_DATE<= &cut_dt.;*/
/*rename BQYD_REPAY_DATE=repay_date;*/
/*run;*/
/*proc sort data=repay_plan_xyd ;by contract_no descending repay_date;run;*/
/*proc sort data=repay_plan_xyd nodupkey out=repay_plan_xyd_rc(keep=contract_no repay_date clear_date );by contract_no ;run;*/

proc sort data=default;by contract_no;run;
data default;
/*set default repay_plan_js_rc repay_plan_xyd_rc;*/
set default repay_plan_js_rc ;

run; 

/*截至cut_dt逾期天数、逾期期数*/
data period;
set bill_main(where = (REPAY_DATE <= &cut_dt.)); 
	 if (clear_date > &cut_dt. and overdue_days > 0) or clear_date = . then do; od = 1; od_days = &cut_dt. - repay_date; end;
else do; od = 0; od_days = 0; end;
run;
proc sql;
create table od_days as
select contract_no, max(od_days) as od_days, sum(od) as od_periods
from period
group by contract_no
;
quit;
*晋商;
data period_js;
set Tttrepay_plan_js(where = (REPAY_DATE_js <= &cut_dt.)); 
	 if (clear_date_js > &cut_dt. ) or clear_date_js in (.,0) then do; od = 1; od_days = &cut_dt. - repay_date_js; end;
else do; od = 0; od_days = 0; end;
run;
proc sql;
create table od_days_js as
select contract_no, max(od_days) as od_days, sum(od) as od_periods
from period_js
group by contract_no
;
quit;

/**小雨点;*/
/*data period_xyd;*/
/*set tttrepay_plan_xyd(where = (BQYD_REPAY_DATE <= &cut_dt.)); */
/*	 if (clear_date > &cut_dt. ) or clear_date in (.,0) then do; od = 1; od_days = &cut_dt. - BQYD_REPAY_DATE; end;*/
/*else do; od = 0; od_days = 0; end;*/
/*run;*/
/*proc sql;*/
/*create table od_days_xyd as*/
/*select contract_no, max(od_days) as od_days, sum(od) as od_periods*/
/*from period_xyd*/
/*group by contract_no*/
/*;*/
/*quit;*/
/*proc sort data=od_days_xyd;by contract_no;run;*/
proc sort data=od_days_js;by contract_no;run;
proc sort data=od_days;by contract_no;run;
/*此处直接拼接是因为前面bill_main的小雨点、晋商已做剔除，不需要像前面一样做拼接*/
data od_days;
/*set od_days od_days_js od_days_xyd;*/
set od_days od_days_js ;
run; 


/*截至cut_dt曾经最大逾期天数*/
data period_ever;
set bill_main(where = (REPAY_DATE <= &cut_dt.-1)); 
if clear_date in (.,0) or clear_date>&cut_dt.-1 then od_days = &cut_dt.-1 - repay_date; else od_days = clear_date-repay_date;
run;
proc sql;
create table od_days_ever as
select contract_no, max(od_days) as od_days_ever
from period_ever
group by contract_no
;
quit;
*晋商;
data period_ever_js;
set Tttrepay_plan_js(where = (REPAY_DATE_js <= &cut_dt.-1)); 
if clear_date_js in (.,0) or clear_date_js>&cut_dt.-1  then od_days = &cut_dt.-1 - repay_date_js;else od_days = clear_date_js-repay_date_js;
run;
proc sql;
create table od_days_ever_js as
select contract_no, max(od_days) as od_days_ever
from period_ever_js
group by contract_no
;
quit;
/**小雨点;*/
/*data period_ever_xyd;*/
/*set tttrepay_plan_xyd(where = (BQYD_REPAY_DATE <= &cut_dt.-1)); */
/*if clear_date in (.,0) or clear_date>&cut_dt.-1 then od_days = &cut_dt.-1 - BQYD_REPAY_DATE;else od_days = clear_date-BQYD_REPAY_DATE;*/
/*run;*/
/*proc sql;*/
/*create table od_days_ever_xyd as*/
/*select contract_no, max(od_days) as od_days_ever*/
/*from period_ever_xyd*/
/*group by contract_no*/
/*;*/
/*quit;*/
/*proc sort data=od_days_ever_xyd;by contract_no;run;*/
proc sort data=od_days_ever_js;by contract_no;run;
proc sort data=od_days_ever;by contract_no;run;
data od_days_ever;
/*set od_days_ever od_days_ever_js od_days_ever_xyd;*/
set od_days_ever od_days_ever_js ;
run; 

/*---------------------------------------违约统计end-------------------------------------------------*/

***************************************************
本月账单日后30天内回收本息，用于计算新增违约30天回收率
***************************************************;
/*---------------------------------------本月账单日后30天内回收本息start-------------------------------------------------*/
data crt_mth_repaydate;
set repay_plan(keep = contract_no repay_date);
if intck("month", repay_date, &cut_dt.) = 0;
run;
proc sort data = crt_mth_repaydate nodupkey; by contract_no; run;
proc sort data = bill_fee_dtl; by contract_no; run;
data crt_mth_repayamt;
merge crt_mth_repaydate(in = a) bill_fee_dtl(in = b);
by contract_no;
if a;
run;
proc sql;
create table recovery_amt_in30day as
select contract_no, sum(curr_receipt_amt) as recovery_amt_in30day
from crt_mth_repayamt
where fee_name in ("本金", "利息") & repay_date < offset_date <= repay_date + 30
group by contract_no
;
quit;

/*---------------------------------------本月账单日后30天内回收本息end-------------------------------------------------*/

****************************************
当期应还本息，不考虑逾期历史应还
****************************************;
/*---------------------------------------当期应还本息start-------------------------------------------------*/
proc sql;
create table crt_period_receive_amt as
select contract_no, sum(CURR_RECEIVE_CAPITAL_AMT) as total_receive_capital, sum(CURR_RECEIVE_INTEREST_AMT) as total_receive_interest,
		calculated total_receive_capital + calculated total_receive_interest as crt_period_receive_amt
from repay_plan
where intnx("month", &cut_dt., 0, "b") <= repay_date <= &cut_dt.
group by contract_no
;
quit;
/*---------------------------------------当期应还本息end-------------------------------------------------*/

**************************************************************
当月应还本息（含之前逾期截止到本月还款日时应还的本息）、已还本息
**************************************************************;
/*---------------------------------------当月应还本息、已还本息start-------------------------------------------------*/
/*截止当月应还本息*/
proc sql;
create table total_receive_amt as
select contract_no, sum(CURR_RECEIVE_CAPITAL_AMT) as total_receive_capital, sum(CURR_RECEIVE_INTEREST_AMT) as total_receive_interest
from repay_plan
where REPAY_DATE <= &cut_dt.
group by contract_no
;
quit;
/*截止上月底已还本息*/
proc sql;
create table total_receipt_amt as
select contract_no, sum(curr_receipt_amt) as total_receipt_amt
from bill_fee_dtl
where fee_name in ("本金", "利息") & 0<offset_date <= intnx("month", &cut_dt., -1, "e")
group by contract_no
;
quit;
/*当月应还本息*/
proc sort data = total_receive_amt nodupkey; by contract_no; run;
proc sort data = total_receipt_amt nodupkey; by contract_no; run;
data crt_mth_receive_amt;
merge total_receive_amt(in = a) total_receipt_amt(in = b);
by contract_no;
if a;
crt_mth_receive_amt = sum(total_receive_capital , total_receive_interest , - total_receipt_amt);
keep contract_no crt_mth_receive_amt;
run;

/*当月已还本息*/
proc sql;
create table crt_mth_receipt_amt as
select contract_no, sum(curr_receipt_amt) as crt_mth_receipt_amt
from bill_fee_dtl
where fee_name in ("本金", "利息") & intnx("month", &cut_dt., 0, "b") <= offset_date <= &cut_dt.
group by contract_no
;
quit;
/*---------------------------------------当月应还本息、已还本息end-------------------------------------------------*/


proc sql;
create table temp as
select a.*, b.*, c.*, d.*, e.crt_period_receive_amt, f.*, g.*, h.*, i.*
from contract as a
left join outstanding as b on a.contract_no = b.contract_no
left join od_days as c on a.contract_no = c.contract_no
left join default as d on a.contract_no = d.contract_no
left join crt_period_receive_amt as e on a.contract_no = e.contract_no
left join crt_mth_receive_amt as f on a.contract_no = f.contract_no
left join crt_mth_receipt_amt as g on a.contract_no = g.contract_no
left join od_days_ever as h on a.contract_no = h.contract_no
left join recovery_amt_in30day as i on a.contract_no = i.contract_no
;
quit;

data temp_result;
set temp;
format cut_date yymmdd10.;
cut_date = &cut_dt.;
month = put(&cut_dt., yymmn6.);
mob = intck("month", loan_date, &cut_dt.);
run;

%if &i. = 0 %then %do;
data payment;
set temp_result;
run;
%end;
%else %do;
proc append base = payment data = temp_result; run;
%end;
%end;
%mend;

%get_payment;

proc sql;
create table payment as
select a.*, b.default_1st_period, c.default_top2_period
from payment as a
left join default_1st_period as b on a.contract_no = b.contract_no and a.month = b.month
left join default_top2_period as c on a.contract_no = c.contract_no and a.month = c.month
;
quit;
proc sort data=payment;by contract_no   cut_date;run;

/*proc sort data=payment nodupkey out=aaa;by contract_no  营业部 cut_date;run;*/
*因为od_days_ever取的是cut_date前一天，所以这里想得到上月末的od_days_ever就用cut_date=月初;
proc sql;
create table payment1 as
select a.*,b.od_days_ever  as 上月末od_days_ever  from payment as a
left join payment(where=(cut_date=&pde.+1)) as b on a.contract_no=b.contract_no and a.营业部=b.营业部;
quit;
proc sort data=payment1;by contract_no   cut_date ;run;
proc sort data=payment1 nodupkey out=aaa;by contract_no  营业部 cut_date;run;

data repayfin.payment1;
set payment1;
run;

data payment_daily1;
set repayfin.payment1;
放款月份 = put(loan_date, yymmn6.);
放款日期 = put(loan_date, yymmdd10.);
if 营业部^="APP";
if 营业部^="";
last_oddays=lag(od_days);
by contract_no  cut_date ;
if first.contract_no then do ;last_oddays=od_days;end;

/*if repay_date = cut_date or od_days > 0 then 还款_当日应扣款合同 = 1;  /*当日有账单应扣合同 + 当日处于逾期的合同*/
if repay_date = cut_date and od_days=0 then 还款_当日应扣款合同 = 1;  /*当日有账单应扣合同*/
if 还款_当日应扣款合同 = 1 and (clear_date = . or clear_date > cut_date) then 还款_当日扣款失败合同 = 1;	
if repay_date = intnx("day", cut_date, -8) and od_periods < 2 then 还款_当日流入7加合同分母 = 1; /*从逾期不超5天流入逾期超5天*/
if 还款_当日流入7加合同分母 = 1 & last_oddays = 7 then 还款_当日流入7加合同 = 1;
if repay_date = intnx("day", cut_date, -16) and od_periods < 2 then 还款_当日流入15加合同分母 = 1; /*从逾期不超5天流入逾期超5天*/
if 还款_当日流入15加合同分母 = 1 & last_oddays = 15 then 还款_当日流入15加合同 = 1;
*这个M1逻辑包含了流入，却仍包含留留出(登锋逻辑）,暂时不管啦-20170228;
if od_periods > 0 and od_days <= 30 then do; 还款_M1合同 = 1; 还款_M1合同贷款余额 = outstanding; end;
*还款_从未逾期新增M1合同不同于指标定义手册中的新增，这个新增是指从未逾期的新增；指标手册的新增是指昨天未逾期，今天已逾期的新增，可对逾期已还再逾期的客户。;
if 还款_M1合同=1 and 上月末od_days_ever=0 then do;还款_从未逾期新增M1合同=1;还款_从未逾期新增M1合同贷款余额= outstanding; end;

if 30 < od_days <= 60 then do; 还款_M2合同 = 1; 还款_M2合同贷款余额 = outstanding; end;

if contract_no="C2017072517421313005856" and cut_date=mdy(2,28,2019) then 还款_当日扣款失败合同=0;
if contract_no="C151451316038603000001871" and cut_date=mdy(3,3,2019) then 还款_当日扣款失败合同=0;
if contract_no="C152879410504703000000889" and cut_date=mdy(3,3,2019) then 还款_当日扣款失败合同=0;
if contract_no="C152887137784402300001124" and cut_date=mdy(3,2,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017083117381269634457" and cut_date=mdy(3,9,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017083109172614420468" and cut_date=mdy(3,11,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017080313105954478610" and cut_date=mdy(3,15,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017101110263003249765" and cut_date=mdy(3,19,2019) then 还款_当日扣款失败合同=0;

if contract_no="C152886193731802300001045" and cut_date=mdy(03,20,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2016091409121455841732" and cut_date=mdy(03,20,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017111310243119919437" and cut_date=mdy(03,20,2019) then 还款_当日扣款失败合同=0;

if contract_no="C2017110619062282147179" and cut_date=mdy(03,21,2019) then 还款_当日扣款失败合同=0;

if contract_no="C152385455472102300010153" and cut_date=mdy(03,24,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017092111435555254662" and cut_date=mdy(03,22,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2018012219070532415053" and cut_date=mdy(03,24,2019) then 还款_当日扣款失败合同=0;


if contract_no="C2017092117533445057225" and cut_date=mdy(3,13,2019) then 还款_当日流入15加合同=0;

if contract_no="C2017070420050177544700" and cut_date=mdy(3,22,2019) then 还款_当日流入15加合同=0;
if contract_no="C2017072515281323868676" and cut_date=mdy(3,15,2019) then 还款_当日流入15加合同=0;
if contract_no="C2017080210272523240535" and cut_date=mdy(3,20,2019) then 还款_当日流入15加合同=0;


rename outstanding=贷款余额 outstanding_capital=贷款余额_剩余本金部分;
keep contract_no 客户姓名 cut_date repay_date clear_date od_days od_periods 还款_当日应扣款合同 还款_当日扣款失败合同 还款_当日流入7加合同 还款_当日流入7加合同分母 身份证号码
	放款日期 es es_date 营业部 还款_M1合同 还款_M2合同 还款_M1合同贷款余额 还款_M2合同贷款余额 outstanding outstanding_capital 资金渠道 CONTRACT_AMOUNT last_oddays od_days_ever 还款_从未逾期新增M1合同 还款_从未逾期新增M1合同贷款余额 还款_当日流入15加合同分母 还款_当日流入15加合同; 
run;
proc sort data=payment_daily1 nodupkey;by contract_no  cut_date;run;
data payment_daily2;
set repayfin.payment1;
放款月份 = put(loan_date, yymmn6.);
放款日期 = put(loan_date, yymmdd10.);
if 营业部="APP";
if 营业部^="";
last_oddays=lag(od_days);
by contract_no  cut_date ;
if first.contract_no then do ;last_oddays=od_days;end;

/*if repay_date = cut_date or od_days > 0 then 还款_当日应扣款合同 = 1;  /*当日有账单应扣合同 + 当日处于逾期的合同*/
if repay_date = cut_date and od_days=0 then 还款_当日应扣款合同 = 1;  /*当日有账单应扣合同*/
if 还款_当日应扣款合同 = 1 and (clear_date = . or clear_date > cut_date) then 还款_当日扣款失败合同 = 1;	
if repay_date = intnx("day", cut_date, -8) and od_periods < 2 then 还款_当日流入7加合同分母 = 1; /*从逾期不超5天流入逾期超5天*/
if 还款_当日流入7加合同分母 = 1 & last_oddays = 7 then 还款_当日流入7加合同 = 1;
if repay_date = intnx("day", cut_date, -16) and od_periods < 2 then 还款_当日流入15加合同分母 = 1; /*从逾期不超5天流入逾期超5天*/
if 还款_当日流入15加合同分母 = 1 & last_oddays = 15 then 还款_当日流入15加合同 = 1;
*这个M1逻辑包含了流入，却仍包含留留出(登锋逻辑）,暂时不管啦-20170228;
if od_periods > 0 and od_days <= 30 then do; 还款_M1合同 = 1; 还款_M1合同贷款余额 = outstanding; end;
*还款_从未逾期新增M1合同不同于指标定义手册中的新增，这个新增是指从未逾期的新增；指标手册的新增是指昨天未逾期，今天已逾期的新增，可对逾期已还再逾期的客户。;
if 还款_M1合同=1 and 上月末od_days_ever=0 then do;还款_从未逾期新增M1合同=1;还款_从未逾期新增M1合同贷款余额= outstanding; end;

if 30 < od_days <= 60 then do; 还款_M2合同 = 1; 还款_M2合同贷款余额 = outstanding; end;

if contract_no="C2017072517421313005856" and cut_date=mdy(2,28,2019) then 还款_当日扣款失败合同=0;
if contract_no="C151451316038603000001871" and cut_date=mdy(3,3,2019) then 还款_当日扣款失败合同=0;
if contract_no="C152879410504703000000889" and cut_date=mdy(3,3,2019) then 还款_当日扣款失败合同=0;
if contract_no="C152887137784402300001124" and cut_date=mdy(3,2,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017083117381269634457" and cut_date=mdy(3,9,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017083109172614420468" and cut_date=mdy(3,11,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017080313105954478610" and cut_date=mdy(3,15,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017101110263003249765" and cut_date=mdy(3,19,2019) then 还款_当日扣款失败合同=0;

if contract_no="C152886193731802300001045" and cut_date=mdy(03,20,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2016091409121455841732" and cut_date=mdy(03,20,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017111310243119919437" and cut_date=mdy(03,20,2019) then 还款_当日扣款失败合同=0;

if contract_no="C2017110619062282147179" and cut_date=mdy(03,21,2019) then 还款_当日扣款失败合同=0;

if contract_no="C152385455472102300010153" and cut_date=mdy(03,24,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2017092111435555254662" and cut_date=mdy(03,22,2019) then 还款_当日扣款失败合同=0;
if contract_no="C2018012219070532415053" and cut_date=mdy(03,24,2019) then 还款_当日扣款失败合同=0;


if contract_no="C2017092117533445057225" and cut_date=mdy(3,13,2019) then 还款_当日流入15加合同=0;

if contract_no="C2017070420050177544700" and cut_date=mdy(3,22,2019) then 还款_当日流入15加合同=0;
if contract_no="C2017072515281323868676" and cut_date=mdy(3,15,2019) then 还款_当日流入15加合同=0;
if contract_no="C2017080210272523240535" and cut_date=mdy(3,20,2019) then 还款_当日流入15加合同=0;


rename outstanding=贷款余额 outstanding_capital=贷款余额_剩余本金部分;
keep contract_no 客户姓名 cut_date repay_date clear_date od_days od_periods 还款_当日应扣款合同 还款_当日扣款失败合同 还款_当日流入7加合同 还款_当日流入7加合同分母 身份证号码
	放款日期 es es_date 营业部 还款_M1合同 还款_M2合同 还款_M1合同贷款余额 还款_M2合同贷款余额 outstanding outstanding_capital 资金渠道 CONTRACT_AMOUNT last_oddays od_days_ever 还款_从未逾期新增M1合同 还款_从未逾期新增M1合同贷款余额 还款_当日流入15加合同分母 还款_当日流入15加合同; 
run;
proc sort data=payment_daily2 nodupkey;by contract_no   cut_date;run;
/*因为last_oddays=lag(od_days);如果不复制两段一个APP一个没有APP，last_oddays会出错*/
data payment_daily;
set payment_daily1 payment_daily2;
run;
proc sort data=payment_daily ;by contract_no descending 营业部;run;

/*如果新增流失客户，先操作,看看cut_date的哪个还款_当日流入7加合同=1，把cut_date找出来，然后写在上面手动添加的代码上,然后复制粘贴到汇总代码*/
/*data xzkh;*/
/*set payment_daily;*/
/*if contract_no="C2017060515221962120988";run;*/;
/*上个月底状态*/
data pre_status;
set repayfin.Payment(keep = contract_no status pre_1m_status pre_2m_status pre_3m_status month 贷款余额_1月前_C 贷款余额_2月前_C 贷款余额_3月前_C
							贷款余额_1月前_M1 od_days cut_date pre_1m_status_r 贷款余额_1月前_M2_r status_r);
if month = put(&dt., yymmn6.);

if contract_no='C2017042617334370619840' and (cut_date=mdy(2,28,2019) or cut_date=mdy(3,1,2019)) then do;
	pre_1m_status_r='02_M1';status='02_M1';status_r='02_M1';pre_1m_status='02_M1';pre_2m_status='02_M1';pre_3m_status='02_M1';贷款余额_1月前_C=0;
	贷款余额_1月前_M1=11828.497;end;

if pre_1m_status_r in ("00_NB", "01_C") then 还款_上月底C = 1;
if pre_2m_status in ("00_NB", "01_C") then 还款_上两月底C = 1;
if pre_3m_status in ("00_NB", "01_C") then 还款_上三月底C = 1;

if pre_1m_status_r in ("02_M1") then 还款_上月底M1 = 1;
if pre_1m_status_r in ("03_M2") then 还款_上月底M2 = 1;

if pre_3m_status="09_ES" then  贷款余额_3月前_C=0;
if pre_2m_status="09_ES" then  贷款余额_2月前_C=0;
if pre_1m_status_r="09_ES" then 贷款余额_1月前_C=0;

/*该客户12月对公，1月入账，payment未做调整，导致其算到了M2*/
if contract_no='C2017092211131164787543' and month="201901" then do;还款_上月底M1 = 1;贷款余额_1月前_M1=32456.599032;贷款余额_1月前_M2_r=0;end;

/*因为小雨点逻辑修复后payment的这两个客户的历史逾期情况没有了，所以手动处理*/
if contract_no in ("C2017091514282595517604","C2017101316540954741014") and month="201806" then do;
pre_1m_status_r="02_M1";还款_上月底M1 = 1;贷款余额_1月前_M1=贷款余额_1月前_C;end;

/*因为小雨点提前结清信息没有了，所以手动处理*/
if contract_no in ("C2017080410211770435844","C2017113013252201372210") and month="201806" then do;
pre_1m_status_r="01_C";还款_上月底M2 = 0;end;
/*if 还款_上月底M1 and REPAY_DATE= &pde. and od_days-intck("day",&pde.,cut_date)=30  then do; 还款_上月底M1=0 ; 还款_上月底M2=1 ;end;*/
rename od_days=od_days1 cut_date=cut_date1;
run;
proc sort data = payment_daily; by contract_no  descending 营业部; run;
proc sort data = pre_status nodupkey; by contract_no; run;
data repayFin.payment_daily;
merge payment_daily(in = a) pre_status(in = b);
by contract_no;
if a;
报表日 = put(cut_date, yymmdd10.);
/*C2017082515143903937149这个客户比较特殊，它的还款日是30号，有些月份一个月只有30天，它会算两次M1，--12.07*/
/*if 还款_上月底M1 and REPAY_DATE= &pde. and od_days >= sum(20,intck("day",&pde.,cut_date)) then do; 还款_上月底M1=0 ; 还款_上月底M2=1 ;end; *垚垚逻辑*/
/*if 还款_上月底M1 and REPAY_DATE= &pde. and od_days-intck("day",&pde.,cut_date)>=30  then do; 还款_上月底M1=0 ; 还款_上月底M2=1 ;end;*/
/*if 还款_上月底M1 and REPAY_DATE= &pde. and od_days1>=30 and od_days>=od_days1-intck("day",&pde.,cut_date1)  then do; */
if 还款_上月底M1 and REPAY_DATE= &pde. and od_days >= sum(20,intck("day",&pde.,cut_date)) then do;
还款_上月底M1=0 ; 还款_上月底M2=1 ;
贷款余额_1月前_M2_r =贷款余额_1月前_M1;
贷款余额_1月前_M1=0;
*&pde.为上月底日期，有些刚好月初第一天还款，应该算作M2还款的;
end;

/*if  contract_no="C2017082515143903937149" then 还款_上月底M1=0;*/
/*if  contract_no="C2017062217200855935962" then do;还款_上月底M2=1 ;贷款余额_1月前_M2=还款_M2合同贷款余额;end;*/
/*if  contract_no="C2017110615410446431580" then do;还款_上月底M2=1;贷款余额_1月前_M2=还款_M2合同贷款余额;end;*/
/*if  contract_no="C2018011816340033024249" then do;还款_上月底M2=1;贷款余额_1月前_M2=还款_M2M3贷款余额;end;*/
/*if  contract_no="C2017071418261923010919" then do;还款_上月底M2=1;贷款余额_1月前_M2=还款_M2M3贷款余额;end;*/
/*if  contract_no="C2017112409362549464210" then do;还款_上月底M1=1;贷款余额_1月前_M1=还款_M1合同贷款余额;end;*/
/*if  contract_no="C2017112409362549464210" then do;还款_上月底M2=0;贷款余额_1月前_M2=还款_M2M3贷款余额=0;end;*/

/*6月后删除*/
/*if contract_no="C2017110615410446431580"  and cut_date>=mdy(5,4,2018) then do ;贷款余额_1月前_M2=37378.242;end;*/

if 还款_上月底M1 and od_days >= intck("day",&pde.,cut_date) then do; 还款_M1M2 = 1; 还款_M1M2贷款余额 = 贷款余额; end;
if 还款_M1M2=1 and od_days>=31 then 调整m2分子=贷款余额;
if 还款_上月底M2 and od_days > sum(intck("day",&last_month_begin.,&last_month_end.),intck("day",&pde.,cut_date)) then do; 还款_M2M3 = 1; 还款_M2M3贷款余额 = 贷款余额; end;
if 还款_上月底C and  0<od_days <= 30 then C_M1分子= 贷款余额;

if es_date>0 and es_date<=repay_date then do ;还款_当日流入15加合同分母=0 ;还款_当日应扣款合同=0 ;还款_当日流入7加合同分母=0 ; end;

if contract_no='C2018101613583597025048' then delete;*特殊客户，不用催收;

/*if  contract_no="C2017112409362549464210" then do;还款_上月底M1=1;贷款余额_1月前_M1=还款_M1合同贷款余额;end;*/
/*if  contract_no="C2017112409362549464210" then do;还款_上月底M2=0;贷款余额_1月前_M2=还款_M2M3贷款余额=0;end;*/

/*if  contract_no="C2018011816340033024249" then do;还款_上月底M2=1;贷款余额_1月前_M2=还款_M2M3贷款余额;end;*/
/*if  contract_no="C2017071418261923010919" then do;还款_上月底M2=1;贷款余额_1月前_M2=还款_M2M3贷款余额;end;*/
run;
proc sort data=repayFin.payment_daily; by CONTRACT_no  descending 营业部;run;


/*data zq.lastday;*/
/*set zq.payment_daily(where=(cut_date=mdy(8,31,2016)));*/
/*run;*/
data zq.Bill_fee_dtl;
set Bill_fee_dtl;
run;
data zq.bill_main;
set bill_main;
run;

data zq.Account_info;
set Account_info;
run;

data zq.early_repay;
set early_repay;
run;
