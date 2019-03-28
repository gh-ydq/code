data apply_info;
set approval.apply_info(keep = apply_code name id_card_no branch_code branch_name DESIRED_PRODUCT SOURCE_CHANNEL);
	 if branch_code = "6" then branch_name = "�Ϻ�����·Ӫҵ��";
else if branch_code = "13" then branch_name = "�Ϻ�����·Ӫҵ��";
else if branch_code = "16" then branch_name = "�������ֺ���·Ӫҵ��";
else if branch_code = "14" then branch_name = "�Ϸ�վǰ·Ӫҵ��";
else if branch_code = "15" then branch_name = "��������·Ӫҵ��";
else if branch_code = "17" then branch_name = "�ɶ��츮����Ӫҵ��";
else if branch_code = "50" then branch_name = "���ݵ�һӪҵ��";
else if branch_code = "55" then branch_name = "�����е�һӪҵ��";
else if branch_code = "57" then branch_name = "���ݽ�����·Ӫҵ��";
else if branch_code = "56" then branch_name = "�����е�һӪҵ��";
else if branch_code = "118" then branch_name = "�����е�һӪҵ��";
else if branch_code = "65" then branch_name = "��³ľ���е�һӪҵ��";
else if branch_code = "63" then branch_name = "����е�һӪҵ��";
else if branch_code = "60" then branch_name = "���ͺ����е�һӪҵ��";
else if branch_code = "93" then branch_name = "Ȫ���е�һӪҵ��";
else if branch_code = "122" then branch_name = "֣���е�һӪҵ��";
else if branch_code = "91" then branch_name = "����е�һӪҵ��";
else if branch_code = "90" then branch_name = "�����е�һӪҵ��";
else if branch_code = "71" then branch_name = "�����е�һӪҵ��";
else if branch_code = "72" then branch_name = "�����е�һӪҵ��";
else if branch_code = "73" then branch_name = "�����е�һӪҵ��";
else if branch_code = "74" then branch_name = "�Ͼ��е�һӪҵ��";
else if branch_code = "75" then branch_name = "�����е�һӪҵ��";
else if branch_code = "89" then branch_name = "�����е�һӪҵ��";
else if branch_code = "50" then branch_name = "�����е�һӪҵ��";
else if branch_code = "117" then branch_name = "�γ���ҵ������";
else if branch_code = "116" then branch_name = "��ͨ��ҵ������";
else if branch_code = "114" then branch_name = "��ɽҵ������";
else if branch_code = "115" then branch_name = "������ҵ������";
else if branch_code = "119" then branch_name = "�人��ҵ������";
else if branch_code = "120" then branch_name = "�����ҵ������";
else if branch_code = "136" then branch_name = "��ɽ�е�һӪҵ��";

if kindex(branch_name,"����")  then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"����") and kindex(branch_name,"ҵ������") then branch_name="������ҵ������";
else if kindex(branch_name,"��ɽ") then branch_name="��ɽ�е�һӪҵ��";
else if kindex(branch_name,"�γ�") then branch_name="�γ��е�һӪҵ��";
else if kindex(branch_name,"տ��") then branch_name="տ���е�һӪҵ��";
else if kindex(branch_name,"�人") then branch_name="�人�е�һӪҵ��";
else if kindex(branch_name,"���") then branch_name="����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";
else if kindex(branch_name,"�����") then branch_name="������е�һӪҵ��";
else if kindex(branch_name,"��ͷ") then branch_name="��ͷ�е�һӪҵ��";
else if kindex(branch_name,"���") then branch_name="����е�һӪҵ��";
else if kindex(branch_name,"����") then branch_name="�����е�һӪҵ��";


prime_key=1;

rename branch_name = Ӫҵ��;
run;
data apply_info1;
set apply_info(where = ( SOURCE_CHANNEL="257"));
Ӫҵ�� = 'APP';
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


/*���״�¼�븴�����ʱ����Ϊ����ʱ��*/
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE")); /*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
keep bussiness_key_ create_time_;
rename bussiness_key_ = apply_code create_time_ = apply_time;
run;
proc sort data = apply_time nodupkey; by apply_code; run;
proc sort data=apply_info(where=(Ӫҵ��^="��˾����")) nodupkey ;by apply_code Ӫҵ��;run;
data appMid.apply_time;
merge apply_time(in = a) apply_info(in = b);
by apply_code;
if a;
�����·� = put(datepart(apply_time), yymmn6.);
�������� = put(datepart(apply_time), yymmdd10.);
apply_week = week(datepart(apply_time)); /*�����ܣ�һ�굱�еĵڼ���*/
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




/*�ҳ��ع��� ������*/
proc sql;
create table test1 as select 
a.* , b.FUND_CHANNEL_CODE as �ʽ����� from approval.contract as a left join account.account_info as b on a.contract_no = b.contract_no;
quit;

data ss;
set test1 (where=((�ʽ����� = 'tsjr1' and fund_channel_code = 'jsxj1')));
�ع� =1;
run;


*����;
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
*��Ϊ��������������ƣ����̿ͻ��ݲ�����������������
if repay_date_js<=mdy(10,25,2016) then clear_date_js=repay_date_js;
run;
data ctl_loaninstallment;
set csdata.ctl_loaninstallment(keep=BQYD_REPAYMENT_DATE contract_no SETTLEMENT_DATE);
format repay_date clear_date_js yymmdd10.;
repay_date=datepart(BQYD_REPAYMENT_DATE);
clear_date_js=datepart(SETTLEMENT_DATE);
keep CONTRACT_NO clear_date_js repay_date ;
run;
/* �޳��ع��ĺ�ͬ  js*/
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
*С���;
/*2017-06-19*/
/*proc sql;*/
/*create table tttrepay_plan_xyd_1 as select a.*,b.�ع� from account.repay_plan_xyd as a left join test3 as b on a.contract_no = b.contract_no; quit;*/
/**/
/*proc sql;*/
/*create table ss as*/
/*select * from test3 where contract_no not in (select contract_no from tttrepay_plan_xyd_1);*/
/*quit;*/
/* �޳��ع��ĺ�ͬ  xyd 07-25*/
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
/*            DATAFILE= "F:\A_offline_zky\A_offline\daily\�ռ��\��ʷ����\С���ع�����\С���ع�����.xlsx" */
/*            DBMS=EXCEL REPLACE;*/
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/*proc sql;*/
/*create table tttrepay_plan_xyd_ as*/
/*select a.*,b.��������,b.��ע*/
/*from tttrepay_plan_xyd as a*/
/*left join xyd_hg as b*/
/*on a.contract_no=b.��ͬ��;*/
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
/*else if ��ע="�ع���" and CURRENT_PERIOD>=�������� then do;CLEAR_DATE=.;BQYH_PRINCIPAL=0;BQYH_INTEREST_FEE=0;end;*/
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
/*/*����Ƿ���ֻع�*/*/
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
/*create table tttrepay_plan_xyd(where=(�ʽ����� ^="tsjr1")) as */
/*select a.*,b.�ʽ����� from tttrepay_plan_xyd as a*/
/*left join account as b on a.contract_no=b.contract_no;*/
/*quit;*/


data apply_time;
set appMid.apply_time(keep = apply_code apply_time Ӫҵ�� DESIRED_PRODUCT �������� hire SOCIAL_SECURITY);
if kindex(Ӫҵ��,"�Ϻ��ڶ�") then Ӫҵ��="�Ϻ�����·Ӫҵ��";
run;

data account_info;
set account.account_info(keep = contract_no ch_name branch_code fund_channel_code product_name id_number account_status contract_amount remain_capital  
							period complete_period curr_period loan_date LAST_REPAY_DATE TEAM_MANAGER CUSTOMER_MANAGER BORROWER_TEL_ONE);
apply_code = tranwrd(contract_no, "C", "PL");
run;
proc sort data = account_info nodupkey; by apply_code ; run;
proc sort data = apply_time ; by apply_code Ӫҵ��; run;
data account_info1;
merge account_info(in = a) apply_time(in = b);
by apply_code;
if a;
format ��Ʒ���� $10.;
	 if index(product_name, "E��ͨ") then ��Ʒ���� = "E��ͨ";
else if index(product_name, "U��ͨ") & datepart(apply_time) < mdy(5, 8, 2016) then ��Ʒ���� = "U��ͨ";
else if index(product_name, "U��ͨ") then ��Ʒ���� = "��U��ͨ";
else if product_name = "E��ͨ-�Թ�" then ��Ʒ���� = "E��ͨ-�Թ�";
else if index(product_name,"E΢��-���籣") then ��Ʒ����="E΢��-���籣";
else if index(product_name,"E΢��-�Թ�") then ��Ʒ����="E΢��-�Թ�";
else if index(product_name,"Eլͨ-�Թ�") then ��Ʒ����="Eլͨ-�Թ�";
else if index(product_name,"Easy�����ÿ�") then ��Ʒ����="Easy�����ÿ�";
else if index(product_name,"Easy��֥���") then ��Ʒ����="Easy��֥���";
else ��Ʒ���� = ksubstr(product_name, 1, 3);

if apply_time>=mdy(3,1,2018) then do;
if hire=1 then do;
if ��Ʒ����="E��ͨ" then ��Ʒ����1="E��ͨ-�Թ�";
else if ��Ʒ����="E��ͨ" then ��Ʒ����1="E��ͨ-�Թ�";
else if ��Ʒ����="E��ͨ" then ��Ʒ����1="E��ͨ-�Թ�";
else if ��Ʒ���� in ("E΢��","") then ��Ʒ����1="E΢��-�Թ�";
else if ��Ʒ����="Eլͨ" then ��Ʒ����1="Eլͨ-�Թ�";
end;
else if SOCIAL_SECURITY=0 then do;
if ��Ʒ����="E��ͨ" then ��Ʒ����1="E��ͨ-���籣";
else if ��Ʒ����="E��ͨ" then ��Ʒ����1="E��ͨ-���籣";
else if ��Ʒ����="E��ͨ" then ��Ʒ����1="E��ͨ-���籣";
else if ��Ʒ����="E΢��" then ��Ʒ����1="E΢��-���籣";
else if ��Ʒ����="Eլͨ" then ��Ʒ����1="Eլͨ-���籣";
end;
end;
if ��Ʒ����1^="" then ��Ʒ����=��Ʒ����1;
drop ��Ʒ����1;


/*if not kindex(product_name,"RF");*/
/*if not kindex(DESIRED_PRODUCT,"RF");*/
rename fund_channel_code = �ʽ����� product_name = ��ƷС�� ch_name = �ͻ����� id_number = ���֤����;
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

/*/*��Ϊ6��С�����ǰ����������⣬��ʱ�޸�clear_dateΪ������,�˴�ֻ��Ϊ���ҳ���ͬ�ţ�clear_dateΪ����û��ϵ�������clear_date���޸�*/*/
/*data bill_main_zs;*/
/*set bill_main_ac;*/
/*if BILL_STATUS="0000" and clear_date<=0 then  do;
/*clear_date=mdy(6,22,2018);CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;*/*/
/*run;*/;

*transfer_info����С�����ǰ������˵����ڣ��ù��˵�������Ϊ��ǰ���������;
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
*30�Ǵ��㷨�����������ٴ���һ����ǰ30�컹��Ŀͻ�����������ǰ������;
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
/*�Թ������ӳ٣��öԹ�������Ϊ��������*/
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
select a.*,b.clear_date as ��������,c.fund_channel_code as �ʽ�����  from bill_main as a
left join test2 as b on a.bill_code=b.bill_code
left join approval.contract as c on a.contract_no=c.contract_no;
quit;
data test4;
set test3;
format dat1 yymmdd10.;
if REPAY_DATE<=��������<=CLEAR_DATE and  ��������- REPAY_DATE+15>OVERDUE_DAYS then do; CLEAR_DATE=��������; dat1=��������;end;
/*if  ��������>0 and  REPAY_DATE<=��������  and  ��������- REPAY_DATE+15>OVERDUE_DAYS then do; CLEAR_DATE=��������; dat1=��������;end;*/
run;
/*2017-06-19*/
proc sql;
create table test_1 as
select * from test4 where contract_no  in (select contract_no from ss);
quit;
data test_1;
set test_1;
�ʽ����� = 'tsjr1';
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
if bill_status not in ("0003","0004","0005");	/*�ų�����(0003)��ȡ��(0005)���˵�*/
/*if clear_date ^= . then clear_date = intnx("day", repay_date, overdue_days);*/
/*�������ۿ�ʧ�ܻ�Թ������clear_date���ܲ�׼����overdue_days������*/
if bill_status="0001" and repay_date>&dt. then clear_date=repay_date;
if contract_no='C2018101613583597025048' then clear_date=repay_date;*����ͻ������ô���;
if �ʽ����� ="tsjr1" and BILL_STATUS="0000" then clear_date=intnx("day",REPAY_DATE,OVERDUE_DAYS);
/*if contract_no in ('C2016112914505881780538','C2016110918392520434310','C2016121615345621583310','C2016122113013749889988') then �ʽ����� = 'tsjr1';*/
if �ʽ����� not in ("jsxj1");*�޳�С��� ���̵�;
*�ֶ���ʰ��������̯��;
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

*�µ���ǰ����Ŀͻ�;
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
/*/*��Ϊ6��С�����ǰ����������⣬��ʱ�޸�clear_dateΪ������*/*/
/*data bill_main;*/
/*set bill_main_zs;*/
/*if BILL_STATUS="0000" and clear_date<=0 then  do;
/*clear_date=TRANSFER_DATE;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;*/*/
/*run;*/



********************************************** �ع��߼� start ********************************************************;
/*����bill_mainû���޸ĵ����ݣ���һ�ڿ϶��������Ļع�����*/
/*����5��23�պ��С���ع����ݣ�bill_main������offset_date�쳣�������ɻ�Ǩ�߼������޸�*/

proc sql;
create table turn_back as 
select a.contract_no,a.fund_channel_code , b.FUND_CHANNEL_CODE as �ʽ����� from approval.contract(keep=contract_no fund_channel_code) as a
left join account.account_info(keep=contract_no FUND_CHANNEL_CODE) as b on a.contract_no = b.contract_no;
quit;
data turn_back_1;
set turn_back;
if �ʽ�����="tsjr1" and (kindex(fund_channel_code,"xyd") or fund_channel_code = 'jsxj1');
run;
proc sql;
create table bill_main_tb as 
select a.* from account.bill_main as a
where a.contract_no in (select contract_no from turn_back_1);
quit;
proc sort data=bill_main_tb;by contract_no CURR_PERIOD;run;
proc sort data=bill_main_tb out=bill_main_tb_ nodupkey;by contract_no;run;

********************************************** �ع��߼� end ********************************************************;

********************************************************************** ��Ǩ�߼� start ***************************************************************************************;
/*�ҳ�С����һ��offset_date����,�����һ�ڵ�ʱ���ж�α��𻹿�ǻ�������ȷ����ʱ��Ϊ��Ǩʱ�䣬ʣ���ٲ�����ǰ�����clear_dateƴ��������Ӱ����*/
/*��һ�ڼ����ڣ���һ�λ����ڵĺ�ͬӦ�ñȽ��٣����������Ӱ��Ľ�����ʱ��ܶ�*/

proc sql;
create table huiqian_dt as
select contract_no,FEE_DATE,OFFSET_DATE,CURR_PERIOD
from account.bill_fee_dtl where FEE_NAME='����' and contract_no in (select contract_no from approval.contract where fund_channel_code in ('xyd1','xyd2'));
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
************************************************************************* ��Ǩ�߼� end ************************************************************************************;



data bill_fee_dtl;
set account.bill_fee_dtl(keep = contract_no fee_name curr_receive_amt curr_receipt_amt offset_date FEE_DATE bill_code);
if kindex(contract_no,"C");
run;

proc sql;
create table bill_fee_dtl_ac as
select a.*,b.clear_date,c.fund_channel_code as �ʽ�����,d.clear_date as clear_date_hg,e.offset_date as clear_date_hq from bill_fee_dtl as a
left join bill_main as b on a.contract_no=b.contract_no and a.BILL_CODE=b.BILL_CODE
left join approval.contract as c on a.contract_no=c.contract_no
left join bill_main_tb_ as d on a.contract_no=d.contract_no
left join huiqian_dt_3 as e on a.contract_no=e.contract_no;
quit;
*�㶨;
data bill_fee_dtl;
set bill_fee_dtl_ac;
*����offset_date���ڻع����ڲ��ֽ����޸�;
if clear_date_hg=offset_date and clear_date>0 then do;offset_date=clear_date;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;
*����offset_date���ڻ�Ǩ���ڲ��ֽ����޸�;
if kindex(�ʽ�����,"xyd") and clear_date_hq=offset_date and clear_date>0 then do;offset_date=clear_date;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;
*������Ҫ����ЩС����Ѿ����������offset_dateδ����;
if kindex(�ʽ�����,"xyd") and  clear_date>0 and offset_date<1 then do;offset_date=clear_date;CURR_RECEIPT_AMT=CURR_RECEIVE_AMT;end;
if bill_code="EBL2018011209071809" then delete;
if bill_code="EBL2016081614292303" then delete;
run;
proc sort data=bill_fee_dtl;by contract_no FEE_DATE;run;


/*proc sql;*/
/*create table bill_fee_dtl_1_ as*/
/*select a.*,b.��������,b.��ע,b.��������*/
/*from bill_fee_dtl as a*/
/*left join xyd_hg as b*/
/*on a.contract_no=b.��ͬ��;*/
/*quit;*/
/**/
/*data bill_fee_dtl;*/
/*set bill_fee_dtl_1_;*/
/*if ��������>0 and ��ע="�ع���" and CURR_PERIOD<�������� then do; CURR_RECEIPT_AMT=CURR_RECEIVE_AMT ; OFFSET_DATE=��������;end;*/
/*run;*/
/*proc sort data=bill_fee_dtl nodupkey ;by contract_no bill_code fee_name;run;*/


/*��ǰ����*/
/*/*ԭ�߼����޸ĺ󣬽�С�������ƴ�ӹ����޸�ȱ�ٵ���ǰ�����˻�*/*/
/*data early_repay;*/
/*set account_info(where = (account_status = "0003") keep = contract_no account_status); /*��ǰ�����˻�*/*/
/*keep contract_no;*/
/*run;*/;
data early_repay;
set account_info(where = (account_status = "0003") keep = contract_no account_status ); /*��С�����5.23ǰ�⣬��ǰ�����˻�*/
keep contract_no ;
run;

/*�˴���Bill_main��ǰ�������޸���С���ģ�ԭ��С����Ǩ֮ǰ�ѽ������bill_main��ʾ�ľ���0001���޸�������ǰ�棬�������Ѿ��޸���0000�����ڴ˴�ʹ��*/
data early_bill;
set bill_main(where = (bill_status = "0000") keep = contract_no bill_status curr_period clear_date); /*�����˵�*/
run;
proc sort data = early_bill nodupkey; by contract_no decending curr_period; run; 
proc sort data = early_bill nodupkey; by contract_no; run; /*��������˵�*/
proc sort data = early_repay nodupkey; by contract_no; run;
data early_repay;
merge early_repay(in = a) early_bill(in = b rename = (clear_date = es_date));
by contract_no;
if a;
keep contract_no es_date; /*��ǰ�����˻���������˵�����ʱ�伴�˻�����ʱ�� es_date-��ǰ����ʱ��*/
run;
proc sort data = early_repay nodupkey; by contract_no; run;

/*����ΥԼ*/
data default_1st_period;
set account.bill_main(where = (CURR_PERIOD = 1 & bill_status ^= "0003" & (clear_date = . or (clear_date > repay_date and overdue_days > 0)))); /*�������ۿ�ʧ�ܻ�Թ������clear_date���ܲ�׼���Ƿ�������overdue_days���ж�*/
if repay_date < &dt.;
default_1st_period = 1;
month = put(repay_date, yymmn6.);
run;
proc sort data=default_1st_period nodupkey out=aaa;by contract_no ;run;
/*proc freq data = default_1st_period;*/
/*table month;*/
/*run;*/
/*ǰ��������ΥԼ*/
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
*����;
n = day(&dt.) ;
*����;
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

/*cut_dt֮ǰ�ſ�ĺ�ͬ*/
data contract;
set account_info(where = (loan_date <= &cut_dt.));
run;
********************************************
��������ĳ��ʱ��㣨cut_dt��Ӧ��δ����Ϣ��
********************************************;
/*---------------------------------------�������start-------------------------------------------------*/
/*����cut_dtӦ�����𣬼���ͬ���*/
data capital;
set account_info(keep = contract_no contract_amount rename = (contract_amount = total_capital));
run;

/*����cut_dtӦ����Ϣ*/
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

*����;
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
*С���;
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

/*����cut_dt�ѻ�����*/
proc sql;
create table receipt_capital as
select contract_no, sum(curr_receipt_amt) as receipt_capital
from bill_fee_dtl
where fee_name = "����" & offset_date <= &cut_dt.
group by contract_no
;
quit;

/*����cut_dt���̺�ͬ�ѻ�����*/
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
/*����cut_dtС����ͬ�ѻ�����*/
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

/*����cut_dt�ѻ���Ϣ*/
proc sql;
create table receipt_interest as
select contract_no, sum(curr_receipt_amt) as receipt_interest
from bill_fee_dtl
where fee_name = "��Ϣ" & offset_date <= &cut_dt. 
group by contract_no
;
quit;
/*����cut_dt���̺�ͬ�ѻ���Ϣ*/
*repay_plan_js�Ѿ���  repay_date_js�������ˣ������и�û��������;
proc sql;
create table receipt_interest_js as
select contract_no,sum(SETLNORMINT) as receipt_interest_js 
from repay_plan_js where repay_date_js<= &cut_dt. group by contract_no;
quit;
/*����cut_dtС����ͬ�ѻ���Ϣ*/
*repay_plan_xyd�Ѿ���  BQYD_REPAY_DATE�������ˣ������и�û��������;

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
outstanding = sum(total_capital ,total_interest, -receipt_capital, -receipt_interest); /*�������*/
outstanding_capital = sum(total_capital ,- receipt_capital); /*������_���𲿷�*/
if es_date ^=. and es_date <= &cut_dt. then do; es = 1; outstanding = 0; outstanding_capital = 0; end; /*es-��ǰ�����־*/
if intck("month", &cut_dt., es_date) = 0 then crt_mth_es = 1; /*crt_mth_es-������ǰ�����־*/
drop total_capital total_interest  ;
run;
/*---------------------------------------�������end-------------------------------------------------*/

****************************************
ΥԼͳ��
****************************************;
/*---------------------------------------ΥԼͳ��start-------------------------------------------------*/
/*�˵����״�ΥԼ������ΥԼ������ΥԼ*/
data default_0;
set bill_main;
if repay_date <= &cut_dt.;
run;
proc sort data = default_0; by contract_no; run;
data default_0;
merge default_0(in = a) early_repay(in = b);
by contract_no;
if a;
if b & clear_date = es_date and clear_date>0 then delete; /*ɾ����ǰ���������˵�*/
run;
proc sort data = default_0 nodupkey; by contract_no curr_period; run;
data default_1;
set default_0;
by contract_no curr_period; 
format pre_clear_date yymmdd10.;
retain pcd od_times 0; /*od_times�����ж��Ƿ��״�ΥԼ��default_1st_time��*/
if first.contract_no then do; pcd = clear_date; od_times = 0; end;
else do; pre_clear_date = pcd; pcd = clear_date; end;
if overdue_days > 0 then od_times = od_times + 1;
if last.contract_no;
run;
data default;
set default_1;
if od_times = 1 then default_1st_time = 1; 
if curr_period = 1 and (clear_date = . or (clear_date > repay_date and overdue_days > 0)) then default_new = 1;
if (pre_clear_date ^=. and pre_clear_date < repay_date) and ((repay_date < clear_date and overdue_days > 0) or clear_date = .) then default_new = 1; /*�����˵��ڱ����˵���֮ǰ�ѽ��壬�����˵�����*/
if default_new = 1 and max(clear_date, &cut_dt.) - repay_date > 5 then default_new_5p = 1;
if curr_period > 1 and (pre_clear_date = . or pre_clear_date > &cut_dt.) then default_continuous = 1;
if default_new = 1 and (clear_date ^=. and clear_date < repay_date + 30) then default_new_recovery_in30day = 1;
keep contract_no default_1st_time default_new default_new_5p default_continuous default_new_recovery_in30day repay_date clear_date ;
run;
*����;
data repay_plan_js;
set tttrepay_plan_js;
if repay_date_js<= &cut_dt.;
rename repay_date_js=repay_date
       clear_date_js=clear_date;
run;
proc sort data=repay_plan_js ;by contract_no descending repay_date;run;
proc sort data=repay_plan_js nodupkey out=repay_plan_js_rc(keep=contract_no repay_date clear_date );by contract_no ;run;
*С���;
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

/*����cut_dt������������������*/
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
*����;
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

/**С���;*/
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
/*�˴�ֱ��ƴ������Ϊǰ��bill_main��С��㡢���������޳�������Ҫ��ǰ��һ����ƴ��*/
data od_days;
/*set od_days od_days_js od_days_xyd;*/
set od_days od_days_js ;
run; 


/*����cut_dt���������������*/
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
*����;
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
/**С���;*/
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

/*---------------------------------------ΥԼͳ��end-------------------------------------------------*/

***************************************************
�����˵��պ�30���ڻ��ձ�Ϣ�����ڼ�������ΥԼ30�������
***************************************************;
/*---------------------------------------�����˵��պ�30���ڻ��ձ�Ϣstart-------------------------------------------------*/
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
where fee_name in ("����", "��Ϣ") & repay_date < offset_date <= repay_date + 30
group by contract_no
;
quit;

/*---------------------------------------�����˵��պ�30���ڻ��ձ�Ϣend-------------------------------------------------*/

****************************************
����Ӧ����Ϣ��������������ʷӦ��
****************************************;
/*---------------------------------------����Ӧ����Ϣstart-------------------------------------------------*/
proc sql;
create table crt_period_receive_amt as
select contract_no, sum(CURR_RECEIVE_CAPITAL_AMT) as total_receive_capital, sum(CURR_RECEIVE_INTEREST_AMT) as total_receive_interest,
		calculated total_receive_capital + calculated total_receive_interest as crt_period_receive_amt
from repay_plan
where intnx("month", &cut_dt., 0, "b") <= repay_date <= &cut_dt.
group by contract_no
;
quit;
/*---------------------------------------����Ӧ����Ϣend-------------------------------------------------*/

**************************************************************
����Ӧ����Ϣ����֮ǰ���ڽ�ֹ�����»�����ʱӦ���ı�Ϣ�����ѻ���Ϣ
**************************************************************;
/*---------------------------------------����Ӧ����Ϣ���ѻ���Ϣstart-------------------------------------------------*/
/*��ֹ����Ӧ����Ϣ*/
proc sql;
create table total_receive_amt as
select contract_no, sum(CURR_RECEIVE_CAPITAL_AMT) as total_receive_capital, sum(CURR_RECEIVE_INTEREST_AMT) as total_receive_interest
from repay_plan
where REPAY_DATE <= &cut_dt.
group by contract_no
;
quit;
/*��ֹ���µ��ѻ���Ϣ*/
proc sql;
create table total_receipt_amt as
select contract_no, sum(curr_receipt_amt) as total_receipt_amt
from bill_fee_dtl
where fee_name in ("����", "��Ϣ") & 0<offset_date <= intnx("month", &cut_dt., -1, "e")
group by contract_no
;
quit;
/*����Ӧ����Ϣ*/
proc sort data = total_receive_amt nodupkey; by contract_no; run;
proc sort data = total_receipt_amt nodupkey; by contract_no; run;
data crt_mth_receive_amt;
merge total_receive_amt(in = a) total_receipt_amt(in = b);
by contract_no;
if a;
crt_mth_receive_amt = sum(total_receive_capital , total_receive_interest , - total_receipt_amt);
keep contract_no crt_mth_receive_amt;
run;

/*�����ѻ���Ϣ*/
proc sql;
create table crt_mth_receipt_amt as
select contract_no, sum(curr_receipt_amt) as crt_mth_receipt_amt
from bill_fee_dtl
where fee_name in ("����", "��Ϣ") & intnx("month", &cut_dt., 0, "b") <= offset_date <= &cut_dt.
group by contract_no
;
quit;
/*---------------------------------------����Ӧ����Ϣ���ѻ���Ϣend-------------------------------------------------*/


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

/*proc sort data=payment nodupkey out=aaa;by contract_no  Ӫҵ�� cut_date;run;*/
*��Ϊod_days_everȡ����cut_dateǰһ�죬����������õ�����ĩ��od_days_ever����cut_date=�³�;
proc sql;
create table payment1 as
select a.*,b.od_days_ever  as ����ĩod_days_ever  from payment as a
left join payment(where=(cut_date=&pde.+1)) as b on a.contract_no=b.contract_no and a.Ӫҵ��=b.Ӫҵ��;
quit;
proc sort data=payment1;by contract_no   cut_date ;run;
proc sort data=payment1 nodupkey out=aaa;by contract_no  Ӫҵ�� cut_date;run;

data repayfin.payment1;
set payment1;
run;

data payment_daily1;
set repayfin.payment1;
�ſ��·� = put(loan_date, yymmn6.);
�ſ����� = put(loan_date, yymmdd10.);
if Ӫҵ��^="APP";
if Ӫҵ��^="";
last_oddays=lag(od_days);
by contract_no  cut_date ;
if first.contract_no then do ;last_oddays=od_days;end;

/*if repay_date = cut_date or od_days > 0 then ����_����Ӧ�ۿ��ͬ = 1;  /*�������˵�Ӧ�ۺ�ͬ + ���մ������ڵĺ�ͬ*/
if repay_date = cut_date and od_days=0 then ����_����Ӧ�ۿ��ͬ = 1;  /*�������˵�Ӧ�ۺ�ͬ*/
if ����_����Ӧ�ۿ��ͬ = 1 and (clear_date = . or clear_date > cut_date) then ����_���տۿ�ʧ�ܺ�ͬ = 1;	
if repay_date = intnx("day", cut_date, -8) and od_periods < 2 then ����_��������7�Ӻ�ͬ��ĸ = 1; /*�����ڲ���5���������ڳ�5��*/
if ����_��������7�Ӻ�ͬ��ĸ = 1 & last_oddays = 7 then ����_��������7�Ӻ�ͬ = 1;
if repay_date = intnx("day", cut_date, -16) and od_periods < 2 then ����_��������15�Ӻ�ͬ��ĸ = 1; /*�����ڲ���5���������ڳ�5��*/
if ����_��������15�Ӻ�ͬ��ĸ = 1 & last_oddays = 15 then ����_��������15�Ӻ�ͬ = 1;
*���M1�߼����������룬ȴ�԰���������(�Ƿ��߼���,��ʱ������-20170228;
if od_periods > 0 and od_days <= 30 then do; ����_M1��ͬ = 1; ����_M1��ͬ������� = outstanding; end;
*����_��δ��������M1��ͬ��ͬ��ָ�궨���ֲ��е����������������ָ��δ���ڵ�������ָ���ֲ��������ָ����δ���ڣ����������ڵ��������ɶ������ѻ������ڵĿͻ���;
if ����_M1��ͬ=1 and ����ĩod_days_ever=0 then do;����_��δ��������M1��ͬ=1;����_��δ��������M1��ͬ�������= outstanding; end;

if 30 < od_days <= 60 then do; ����_M2��ͬ = 1; ����_M2��ͬ������� = outstanding; end;

if contract_no="C2017072517421313005856" and cut_date=mdy(2,28,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C151451316038603000001871" and cut_date=mdy(3,3,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C152879410504703000000889" and cut_date=mdy(3,3,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C152887137784402300001124" and cut_date=mdy(3,2,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017083117381269634457" and cut_date=mdy(3,9,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017083109172614420468" and cut_date=mdy(3,11,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017080313105954478610" and cut_date=mdy(3,15,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017101110263003249765" and cut_date=mdy(3,19,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;

if contract_no="C152886193731802300001045" and cut_date=mdy(03,20,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2016091409121455841732" and cut_date=mdy(03,20,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017111310243119919437" and cut_date=mdy(03,20,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;

if contract_no="C2017110619062282147179" and cut_date=mdy(03,21,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;

if contract_no="C152385455472102300010153" and cut_date=mdy(03,24,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017092111435555254662" and cut_date=mdy(03,22,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2018012219070532415053" and cut_date=mdy(03,24,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;


if contract_no="C2017092117533445057225" and cut_date=mdy(3,13,2019) then ����_��������15�Ӻ�ͬ=0;

if contract_no="C2017070420050177544700" and cut_date=mdy(3,22,2019) then ����_��������15�Ӻ�ͬ=0;
if contract_no="C2017072515281323868676" and cut_date=mdy(3,15,2019) then ����_��������15�Ӻ�ͬ=0;
if contract_no="C2017080210272523240535" and cut_date=mdy(3,20,2019) then ����_��������15�Ӻ�ͬ=0;


rename outstanding=������� outstanding_capital=�������_ʣ�౾�𲿷�;
keep contract_no �ͻ����� cut_date repay_date clear_date od_days od_periods ����_����Ӧ�ۿ��ͬ ����_���տۿ�ʧ�ܺ�ͬ ����_��������7�Ӻ�ͬ ����_��������7�Ӻ�ͬ��ĸ ���֤����
	�ſ����� es es_date Ӫҵ�� ����_M1��ͬ ����_M2��ͬ ����_M1��ͬ������� ����_M2��ͬ������� outstanding outstanding_capital �ʽ����� CONTRACT_AMOUNT last_oddays od_days_ever ����_��δ��������M1��ͬ ����_��δ��������M1��ͬ������� ����_��������15�Ӻ�ͬ��ĸ ����_��������15�Ӻ�ͬ; 
run;
proc sort data=payment_daily1 nodupkey;by contract_no  cut_date;run;
data payment_daily2;
set repayfin.payment1;
�ſ��·� = put(loan_date, yymmn6.);
�ſ����� = put(loan_date, yymmdd10.);
if Ӫҵ��="APP";
if Ӫҵ��^="";
last_oddays=lag(od_days);
by contract_no  cut_date ;
if first.contract_no then do ;last_oddays=od_days;end;

/*if repay_date = cut_date or od_days > 0 then ����_����Ӧ�ۿ��ͬ = 1;  /*�������˵�Ӧ�ۺ�ͬ + ���մ������ڵĺ�ͬ*/
if repay_date = cut_date and od_days=0 then ����_����Ӧ�ۿ��ͬ = 1;  /*�������˵�Ӧ�ۺ�ͬ*/
if ����_����Ӧ�ۿ��ͬ = 1 and (clear_date = . or clear_date > cut_date) then ����_���տۿ�ʧ�ܺ�ͬ = 1;	
if repay_date = intnx("day", cut_date, -8) and od_periods < 2 then ����_��������7�Ӻ�ͬ��ĸ = 1; /*�����ڲ���5���������ڳ�5��*/
if ����_��������7�Ӻ�ͬ��ĸ = 1 & last_oddays = 7 then ����_��������7�Ӻ�ͬ = 1;
if repay_date = intnx("day", cut_date, -16) and od_periods < 2 then ����_��������15�Ӻ�ͬ��ĸ = 1; /*�����ڲ���5���������ڳ�5��*/
if ����_��������15�Ӻ�ͬ��ĸ = 1 & last_oddays = 15 then ����_��������15�Ӻ�ͬ = 1;
*���M1�߼����������룬ȴ�԰���������(�Ƿ��߼���,��ʱ������-20170228;
if od_periods > 0 and od_days <= 30 then do; ����_M1��ͬ = 1; ����_M1��ͬ������� = outstanding; end;
*����_��δ��������M1��ͬ��ͬ��ָ�궨���ֲ��е����������������ָ��δ���ڵ�������ָ���ֲ��������ָ����δ���ڣ����������ڵ��������ɶ������ѻ������ڵĿͻ���;
if ����_M1��ͬ=1 and ����ĩod_days_ever=0 then do;����_��δ��������M1��ͬ=1;����_��δ��������M1��ͬ�������= outstanding; end;

if 30 < od_days <= 60 then do; ����_M2��ͬ = 1; ����_M2��ͬ������� = outstanding; end;

if contract_no="C2017072517421313005856" and cut_date=mdy(2,28,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C151451316038603000001871" and cut_date=mdy(3,3,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C152879410504703000000889" and cut_date=mdy(3,3,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C152887137784402300001124" and cut_date=mdy(3,2,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017083117381269634457" and cut_date=mdy(3,9,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017083109172614420468" and cut_date=mdy(3,11,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017080313105954478610" and cut_date=mdy(3,15,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017101110263003249765" and cut_date=mdy(3,19,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;

if contract_no="C152886193731802300001045" and cut_date=mdy(03,20,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2016091409121455841732" and cut_date=mdy(03,20,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017111310243119919437" and cut_date=mdy(03,20,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;

if contract_no="C2017110619062282147179" and cut_date=mdy(03,21,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;

if contract_no="C152385455472102300010153" and cut_date=mdy(03,24,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2017092111435555254662" and cut_date=mdy(03,22,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;
if contract_no="C2018012219070532415053" and cut_date=mdy(03,24,2019) then ����_���տۿ�ʧ�ܺ�ͬ=0;


if contract_no="C2017092117533445057225" and cut_date=mdy(3,13,2019) then ����_��������15�Ӻ�ͬ=0;

if contract_no="C2017070420050177544700" and cut_date=mdy(3,22,2019) then ����_��������15�Ӻ�ͬ=0;
if contract_no="C2017072515281323868676" and cut_date=mdy(3,15,2019) then ����_��������15�Ӻ�ͬ=0;
if contract_no="C2017080210272523240535" and cut_date=mdy(3,20,2019) then ����_��������15�Ӻ�ͬ=0;


rename outstanding=������� outstanding_capital=�������_ʣ�౾�𲿷�;
keep contract_no �ͻ����� cut_date repay_date clear_date od_days od_periods ����_����Ӧ�ۿ��ͬ ����_���տۿ�ʧ�ܺ�ͬ ����_��������7�Ӻ�ͬ ����_��������7�Ӻ�ͬ��ĸ ���֤����
	�ſ����� es es_date Ӫҵ�� ����_M1��ͬ ����_M2��ͬ ����_M1��ͬ������� ����_M2��ͬ������� outstanding outstanding_capital �ʽ����� CONTRACT_AMOUNT last_oddays od_days_ever ����_��δ��������M1��ͬ ����_��δ��������M1��ͬ������� ����_��������15�Ӻ�ͬ��ĸ ����_��������15�Ӻ�ͬ; 
run;
proc sort data=payment_daily2 nodupkey;by contract_no   cut_date;run;
/*��Ϊlast_oddays=lag(od_days);�������������һ��APPһ��û��APP��last_oddays�����*/
data payment_daily;
set payment_daily1 payment_daily2;
run;
proc sort data=payment_daily ;by contract_no descending Ӫҵ��;run;

/*���������ʧ�ͻ����Ȳ���,����cut_date���ĸ�����_��������7�Ӻ�ͬ=1����cut_date�ҳ�����Ȼ��д�������ֶ���ӵĴ�����,Ȼ����ճ�������ܴ���*/
/*data xzkh;*/
/*set payment_daily;*/
/*if contract_no="C2017060515221962120988";run;*/;
/*�ϸ��µ�״̬*/
data pre_status;
set repayfin.Payment(keep = contract_no status pre_1m_status pre_2m_status pre_3m_status month �������_1��ǰ_C �������_2��ǰ_C �������_3��ǰ_C
							�������_1��ǰ_M1 od_days cut_date pre_1m_status_r �������_1��ǰ_M2_r status_r);
if month = put(&dt., yymmn6.);

if contract_no='C2017042617334370619840' and (cut_date=mdy(2,28,2019) or cut_date=mdy(3,1,2019)) then do;
	pre_1m_status_r='02_M1';status='02_M1';status_r='02_M1';pre_1m_status='02_M1';pre_2m_status='02_M1';pre_3m_status='02_M1';�������_1��ǰ_C=0;
	�������_1��ǰ_M1=11828.497;end;

if pre_1m_status_r in ("00_NB", "01_C") then ����_���µ�C = 1;
if pre_2m_status in ("00_NB", "01_C") then ����_�����µ�C = 1;
if pre_3m_status in ("00_NB", "01_C") then ����_�����µ�C = 1;

if pre_1m_status_r in ("02_M1") then ����_���µ�M1 = 1;
if pre_1m_status_r in ("03_M2") then ����_���µ�M2 = 1;

if pre_3m_status="09_ES" then  �������_3��ǰ_C=0;
if pre_2m_status="09_ES" then  �������_2��ǰ_C=0;
if pre_1m_status_r="09_ES" then �������_1��ǰ_C=0;

/*�ÿͻ�12�¶Թ���1�����ˣ�paymentδ���������������㵽��M2*/
if contract_no='C2017092211131164787543' and month="201901" then do;����_���µ�M1 = 1;�������_1��ǰ_M1=32456.599032;�������_1��ǰ_M2_r=0;end;

/*��ΪС����߼��޸���payment���������ͻ�����ʷ�������û���ˣ������ֶ�����*/
if contract_no in ("C2017091514282595517604","C2017101316540954741014") and month="201806" then do;
pre_1m_status_r="02_M1";����_���µ�M1 = 1;�������_1��ǰ_M1=�������_1��ǰ_C;end;

/*��ΪС�����ǰ������Ϣû���ˣ������ֶ�����*/
if contract_no in ("C2017080410211770435844","C2017113013252201372210") and month="201806" then do;
pre_1m_status_r="01_C";����_���µ�M2 = 0;end;
/*if ����_���µ�M1 and REPAY_DATE= &pde. and od_days-intck("day",&pde.,cut_date)=30  then do; ����_���µ�M1=0 ; ����_���µ�M2=1 ;end;*/
rename od_days=od_days1 cut_date=cut_date1;
run;
proc sort data = payment_daily; by contract_no  descending Ӫҵ��; run;
proc sort data = pre_status nodupkey; by contract_no; run;
data repayFin.payment_daily;
merge payment_daily(in = a) pre_status(in = b);
by contract_no;
if a;
������ = put(cut_date, yymmdd10.);
/*C2017082515143903937149����ͻ��Ƚ����⣬���Ļ�������30�ţ���Щ�·�һ����ֻ��30�죬����������M1��--12.07*/
/*if ����_���µ�M1 and REPAY_DATE= &pde. and od_days >= sum(20,intck("day",&pde.,cut_date)) then do; ����_���µ�M1=0 ; ����_���µ�M2=1 ;end; *�����߼�*/
/*if ����_���µ�M1 and REPAY_DATE= &pde. and od_days-intck("day",&pde.,cut_date)>=30  then do; ����_���µ�M1=0 ; ����_���µ�M2=1 ;end;*/
/*if ����_���µ�M1 and REPAY_DATE= &pde. and od_days1>=30 and od_days>=od_days1-intck("day",&pde.,cut_date1)  then do; */
if ����_���µ�M1 and REPAY_DATE= &pde. and od_days >= sum(20,intck("day",&pde.,cut_date)) then do;
����_���µ�M1=0 ; ����_���µ�M2=1 ;
�������_1��ǰ_M2_r =�������_1��ǰ_M1;
�������_1��ǰ_M1=0;
*&pde.Ϊ���µ����ڣ���Щ�պ��³���һ�컹�Ӧ������M2�����;
end;

/*if  contract_no="C2017082515143903937149" then ����_���µ�M1=0;*/
/*if  contract_no="C2017062217200855935962" then do;����_���µ�M2=1 ;�������_1��ǰ_M2=����_M2��ͬ�������;end;*/
/*if  contract_no="C2017110615410446431580" then do;����_���µ�M2=1;�������_1��ǰ_M2=����_M2��ͬ�������;end;*/
/*if  contract_no="C2018011816340033024249" then do;����_���µ�M2=1;�������_1��ǰ_M2=����_M2M3�������;end;*/
/*if  contract_no="C2017071418261923010919" then do;����_���µ�M2=1;�������_1��ǰ_M2=����_M2M3�������;end;*/
/*if  contract_no="C2017112409362549464210" then do;����_���µ�M1=1;�������_1��ǰ_M1=����_M1��ͬ�������;end;*/
/*if  contract_no="C2017112409362549464210" then do;����_���µ�M2=0;�������_1��ǰ_M2=����_M2M3�������=0;end;*/

/*6�º�ɾ��*/
/*if contract_no="C2017110615410446431580"  and cut_date>=mdy(5,4,2018) then do ;�������_1��ǰ_M2=37378.242;end;*/

if ����_���µ�M1 and od_days >= intck("day",&pde.,cut_date) then do; ����_M1M2 = 1; ����_M1M2������� = �������; end;
if ����_M1M2=1 and od_days>=31 then ����m2����=�������;
if ����_���µ�M2 and od_days > sum(intck("day",&last_month_begin.,&last_month_end.),intck("day",&pde.,cut_date)) then do; ����_M2M3 = 1; ����_M2M3������� = �������; end;
if ����_���µ�C and  0<od_days <= 30 then C_M1����= �������;

if es_date>0 and es_date<=repay_date then do ;����_��������15�Ӻ�ͬ��ĸ=0 ;����_����Ӧ�ۿ��ͬ=0 ;����_��������7�Ӻ�ͬ��ĸ=0 ; end;

if contract_no='C2018101613583597025048' then delete;*����ͻ������ô���;

/*if  contract_no="C2017112409362549464210" then do;����_���µ�M1=1;�������_1��ǰ_M1=����_M1��ͬ�������;end;*/
/*if  contract_no="C2017112409362549464210" then do;����_���µ�M2=0;�������_1��ǰ_M2=����_M2M3�������=0;end;*/

/*if  contract_no="C2018011816340033024249" then do;����_���µ�M2=1;�������_1��ǰ_M2=����_M2M3�������;end;*/
/*if  contract_no="C2017071418261923010919" then do;����_���µ�M2=1;�������_1��ǰ_M2=����_M2M3�������;end;*/
run;
proc sort data=repayFin.payment_daily; by CONTRACT_no  descending Ӫҵ��;run;


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
