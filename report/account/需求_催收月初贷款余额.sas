*ÿ���¸�������������;
*��������31���,��Ϊһ������31�죬�պ��³�1�����˵���;
*��Ϊ����������һ��ǰ2���µ�M2�ͻ���ϸ����7-31�ĵ�ǰC-M2�ķ���;
*�³��ܺ��µ�һ���µ�payment_daily֮�󼴿����������;

/*option validvarname=any;*/
/*option compress=yes;*/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname res odbc  datasrc=res_nf;*/
/*libname approval "E:\guan\ԭ����\approval";*/
/*libname account 'E:\guan\ԭ����\account';*/

*���滹�е����ļ���·������;

data macrodate;
format date  start_date  fk_month_begin month_begin  end_date last_month_end last_month_begin month_end yymmdd10.;*����ʱ�������ʽ;
if day(today())=1 then date=intnx("month",today(),-1,"end");
else date=today()-1;
/*date = mdy(12,31,2017);*/
call symput("tabledate",date);*����һ����;
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
if day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*����26-����25��ѭ��;
end_date = mdy(month(date)+1,25,year(date));end;
else do;fk_month_begin = mdy(month(date)-1,26,year(date));
end_date = mdy(month(date),25,year(date));end;
/*����һ��12�µ׸��µ�һ��1�³����������Ȼ��������µ׻���ֿ�ֵ*/
if month(date)=12 and day(date)>25 then do; fk_month_begin = mdy(month(date),26,year(date));*����26-����25��ѭ��;
end_date = mdy(month(date)-11,25,year(date)+1);end;
else if month(date)=1 and day(date)<=25 then do;fk_month_begin = mdy(month(date)+11,26,year(date)-1);
end_date = mdy(month(date),25,year(date));end;
call symput("fk_month_begin",fk_month_begin);
call symput("end_date",end_date);
run;

data dept_;
set repayFin.payment_daily(where=(cut_date=&month_begin.));
if ����_���µ�M1=1 and Ӫҵ��^="APP";
format apply_code $50.;
apply_code=tranwrd(contract_no,"C","PL");
if �ʽ�����^="";
format �ʽ����� �ʽ�����1 $100.;
if �ʽ����� in ("xyd1","xyd2") then �ʽ�����1="С���";
else if �ʽ����� in ("bhxt1","bhxt2") then �ʽ�����1="��������";
else if �ʽ����� in ("mindai1") then �ʽ�����1="���";
else if �ʽ����� in ("ynxt1","ynxt2","ynxt3") then �ʽ�����1="��������";
else if �ʽ����� in ("jrgc1") then �ʽ�����1="���ڹ���";
else if �ʽ����� in ("irongbei1") then �ʽ�����1="�ڱ�";
else if �ʽ����� in ("fotic3","fotic2") then �ʽ�����1="��һ������";
else if �ʽ����� in ("haxt1") then �ʽ�����1="��������";
else if �ʽ����� in ("p2p") then �ʽ�����1="�пƲƸ�";
else if �ʽ����� in ("jsxj1") then �ʽ�����1="�������ѽ���";
else if �ʽ����� in ("lanjingjr1") then �ʽ�����1="��������";
else if �ʽ����� in ("tsjr1") then �ʽ�����1="ͨ�ƽ���";
else if �ʽ����� in ("rx1") then �ʽ�����1="����";
else if �ʽ����� in ("yjh1","yjh2") then �ʽ�����1="��ݼ��";
else if �ʽ����� in ("hapx1") then �ʽ�����1="��������";
drop �ʽ�����;
keep  CONTRACT_NO Ӫҵ�� �������_1��ǰ_M1 �ͻ����� apply_code od_days  �ʽ�����1; 
rename �ʽ�����1=�ʽ�����;
run;

proc sql;
create table dept2_1 as
select a.* ,b.CURR_RECEIVE_CAPITAL_AMT+CURR_RECEIVE_INTEREST_AMT as �ڹ�
from dept_(where=(�ʽ����� not in ("�������ѽ���"))) as a
left join account.repay_plan as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_1 nodupkey ;by contract_no;run;
/*proc sql;*/
/*create table dept2_2 as*/
/*select a.* ,b.BQ_PRINCIPAL+BQ_INTEREST_FEE as �ڹ� */
/*from dept_(where=(�ʽ����� in ("xyd1"))) as a*/
/*left join repayfin.Tttrepay_plan_xyd as b*/
/*on a.contract_no=b.contract_no;*/
/*quit;*/
/*proc sort data=dept2_2 nodupkey ;by contract_no;run;*/

proc sql;
create table dept2_3 as
select a.* ,b.PSPRCPAMT+PSNORMINTAMT as �ڹ� 
from dept_(where=(�ʽ����� in ("�������ѽ���"))) as a
left join repayfin.Tttrepay_plan_js as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2_3 nodupkey ;by contract_no;run;

data dept;
set dept2_1  dept2_3;
run;
proc sort data=dept nodupkey out=aa;by contract_no;run;


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

data apply_base;
set approval.apply_base(keep = apply_code PHONE1 RESIDENCE_PROVINCE RESIDENCE_CITY RESIDENCE_DISTRICT PERMANENT_ADDR_PROVINCE PERMANENT_ADDR_CITY PERMANENT_TYPE
							PERMANENT_ADDR_DISTRICT LOCAL_RESCONDITION LOCAL_RES_YEARS EDUCATION MARRIAGE GENDER RESIDENCE_ADDRESS PERMANENT_ADDRESS );
/*RESIDENCE-��סַ PERMANENT-������ַ*/
run;

proc sql;
create table apply_base1 as
select a.*,b.itemName_zh as ��סʡ, c.itemName_zh as ��ס��, d.itemName_zh as ��ס��,
			e.itemName_zh as ����ʡ, f.itemName_zh as ������, g.itemName_zh as ������
from apply_base as a
left join province as b on a.RESIDENCE_PROVINCE = b.itemCode
left join city as c on a.RESIDENCE_CITY = c.itemCode
left join region as d on a.RESIDENCE_DISTRICT = d.itemCode
left join province as e on a.PERMANENT_ADDR_PROVINCE = e.itemCode
left join city as f on a.PERMANENT_ADDR_CITY = f.itemCode
left join region as g on a.PERMANENT_ADDR_DISTRICT = g.itemCode;
quit;

data apply_emp;
set approval.apply_emp(keep = apply_code COMP_NAME position comp_type COMP_ADDR_PROVINCE COMP_ADDR_CITY COMP_ADDR_DISTRICT START_DATE_4_PRESENT_COMP
							CURRENT_INDUSTRY WORK_YEARS COMP_ADDRESS TITLE);
run;
proc sql;
create table apply_emp1 as
select a.*, b.itemName_zh as ����ʡ, c.itemName_zh as ������, d.itemName_zh as ������
			
from apply_emp as a
left join province as b on a.COMP_ADDR_PROVINCE = b.itemCode
left join city as c on a.COMP_ADDR_CITY = c.itemCode
left join region as d on a.COMP_ADDR_DISTRICT = d.itemCode;
quit;
proc sql;
create table dept1(drop=apply_code) as 
select a.*,b.��סʡ,b.��ס��,b.��ס��,b.RESIDENCE_ADDRESS as ��ס��ϸ��ַ,
b.����ʡ,b.������,b.������,b.PERMANENT_ADDRESS as ������ϸ��ַ,
c.����ʡ,c.������,c.������,c.COMP_ADDRESS as ������ϸ��ַ
from dept as a
left join apply_base1 as b on a.apply_code=b.apply_code
left join apply_emp1 as c on a.apply_code=c.apply_code;
quit;
*M1M2���;
data dept1;
set dept1;
attrib _all_ label="";
run;
*�������;
/*PROC EXPORT DATA=dept1 OUTFILE= "E:\guan\�ռ����ʱ����\��������\dept1.xls" DBMS=EXCEL REPLACE;SHEET="Sheet1";run;*/

*ÿ���¸������;
data dept_k;
set repayFin.payment_daily(where=(cut_date=&month_begin.));
if ����_���µ�M2=1 and Ӫҵ��^="APP";
format apply_code $50.;
apply_code=tranwrd(contract_no,"C","PL");
if �ʽ�����^="";
format �ʽ����� �ʽ�����1 $100.;
if �ʽ����� in ("xyd1","xyd2") then �ʽ�����1="С���";
else if �ʽ����� in ("bhxt1","bhxt2") then �ʽ�����1="��������";
else if �ʽ����� in ("mindai1") then �ʽ�����1="���";
else if �ʽ����� in ("ynxt1","ynxt2","ynxt3") then �ʽ�����1="��������";
else if �ʽ����� in ("jrgc1") then �ʽ�����1="���ڹ���";
else if �ʽ����� in ("irongbei1") then �ʽ�����1="�ڱ�";
else if �ʽ����� in ("fotic3","fotic2") then �ʽ�����1="��һ������";
else if �ʽ����� in ("haxt1") then �ʽ�����1="��������";
else if �ʽ����� in ("p2p") then �ʽ�����1="�пƲƸ�";
else if �ʽ����� in ("jsxj1") then �ʽ�����1="�������ѽ���";
else if �ʽ����� in ("lanjingjr1") then �ʽ�����1="��������";
else if �ʽ����� in ("tsjr1") then �ʽ�����1="ͨ�ƽ���";
else if �ʽ����� in ("rx1") then �ʽ�����1="����";
else if �ʽ����� in ("yjh1","yjh2") then �ʽ�����1="��ݼ��";
else if �ʽ����� in ("hapx1") then �ʽ�����1="��������";
drop �ʽ�����;
keep  CONTRACT_NO Ӫҵ�� �������_1��ǰ_M2_r �ͻ����� apply_code od_days  �ʽ�����1; 
rename �ʽ�����1=�ʽ����� �������_1��ǰ_M2_r=�������_1��ǰ_M2;
run;

proc sql;
create table dept2k_1 as
select a.* ,b.CURR_RECEIVE_CAPITAL_AMT+CURR_RECEIVE_INTEREST_AMT as �ڹ�
from dept_k(where=(�ʽ����� not in ("�������ѽ���"))) as a
left join account.repay_plan as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2k_1 nodupkey ;by contract_no;run;
/*proc sql;*/
/*create table dept2_2 as*/
/*select a.* ,b.BQ_PRINCIPAL+BQ_INTEREST_FEE as �ڹ�*/
/*from dept_(where=(�ʽ����� in ("xyd1"))) as a*/
/*left join repayfin.Tttrepay_plan_xyd as b*/
/*on a.contract_no=b.contract_no;*/
/*quit;*/
/*proc sort data=dept2_2 nodupkey ;by contract_no;run;*/

proc sql;
create table dept2k_3 as
select a.* ,b.PSPRCPAMT+PSNORMINTAMT as �ڹ�
from dept_k(where=(�ʽ����� in ("�������ѽ���"))) as a
left join repayfin.Tttrepay_plan_js as b
on a.contract_no=b.contract_no;
quit;
proc sort data=dept2k_3 nodupkey ;by contract_no;run;

data deptk;
set dept2k_1  dept2k_3;
run;
proc sort data=deptk nodupkey out=aa;by contract_no;run;
proc sql;
create table dept1k(drop=apply_code) as 
select a.*,b.��סʡ,b.��ס��,b.��ס��,b.RESIDENCE_ADDRESS as ��ס��ϸ��ַ,
b.����ʡ,b.������,b.������,b.PERMANENT_ADDRESS as ������ϸ��ַ,
c.����ʡ,c.������,c.������,c.COMP_ADDRESS as ������ϸ��ַ
from deptk as a
left join apply_base1 as b on a.apply_code=b.apply_code
left join apply_emp1 as c on a.apply_code=c.apply_code;
quit;
*M2M3���;
data dept1k;
set dept1k;
attrib _all_ label="";
run;

/*PROC EXPORT DATA=dept1 OUTFILE= "E:\guan\�ռ����ʱ����\��������\dept1.xls" DBMS=EXCEL REPLACE;SHEET="Sheet1";run;*/
/*PROC EXPORT DATA=dept1k OUTFILE= "E:\guan\�ռ����ʱ����\��������\dept1.xls" DBMS=EXCEL REPLACE;SHEET="Sheet2";run;*/

