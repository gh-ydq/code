options compress =yes validvarname = any ;

libname credit odbc datasrc = credit;
libname approval  odbc datasrc =approval;

data a;
format last_date month_begin  yymmdd10.;
last_date = today()-1;
month_begin = intnx('month',last_date,0);
call symput("dt",last_date);
call symput("mb",month_begin);
run;
%put &dt. &mb.;

/*����д��Ŀ���ǻ�ȡ����ʱ��ͽ�������*/
/*���״�¼�븴����ɵ�ʱ����Ϊ����ʱ��*/
data apply_time;
set approval.act_opt_log(where = (task_Def_Name_ = "¼�븴��" and action_ = "COMPLETE")); /*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
input_complete=1;/*action_������COMPLETE�Ĳ��ǽ��������ģ�JUMP���Ǹ���ʱȡ����ܾ�*/
keep bussiness_key_ create_time_ input_complete;
rename bussiness_key_ = apply_code create_time_ = apply_time;
if APPLY_CODE in("PL2017080710404340041165" "PL2017080711092188055701" "PL2017080817340444920689" ) then delete;
/*2017��8���ظ�������ϢҪɾ��*/
run;
proc sort data = apply_time dupout = a nodupkey; by apply_code apply_time; run;
proc sort data = approval.apply_info nodupkey out =apply_info; by apply_code; run;
data apply_time1(keep = apply_code �����·� ����ʱ�� ������);
merge apply_time(in = a) apply_info(in = b);
by apply_code;
format ����ʱ�� yymmdd10.;
�����·� = put(datepart(apply_time), yymmn6.);
����ʱ�� = datepart(apply_time);
������ =1;
run;

data apply_time2;
set apply_time1;
if input("20180501",yymmdd9.)<=����ʱ��<=&dt.;
run;
proc sort  data=apply_time2;by �����·�;run;



/*�������е�ƴ��*/
data early_warning_info(keep = apply_no content  level  hit_id_new);
set approval.early_warning_info;
if SOURCE ="urule";
/*��ʾ���ִ�content����|Ϊ�ָ�����ȡ��2���ִ���*/
hit_id = scan(content,2,"|");
if length(hit_id) =5 then hit_id_new = compress(substr(hit_id,1,2)|| substr(hit_id,4,2));
else if level="R" and length(hit_id) >4 then hit_id_new=substr(hit_id,3,4); 
else if kindex(content,"SPTS") then hit_id_new = compress(substr(hit_id,1,2)|| substr(hit_id,5,2));
/*��ȡSP���ֶ�����*/
else if kindex(content,"SP") then hit_id_new =substr(hit_id,1,4);
else if hit_id ="TS" then do;
	if kindex(content,"�Ϸ�") then hit_id_new= "SP03";
	if kindex(content,"֣��") then hit_id_new="RJ01";
	if kindex(content,"�人") then hit_id_new="RJ04";
	if kindex(content,"��³ľ��") then hit_id_new="SP05";
	if kindex(content,"����") then hit_id_new="RJ02";
	end;
else if kindex(content,"R743") then hit_id_new ="R743";
else if kindex(content,"R753") then hit_id_new ="R753";
else if kindex(content,"R754") then hit_id_new ="R754";
else if kindex(content,"R755") then hit_id_new="R755";
else if kindex(content,"R756") then hit_id_new ="R756";
else if kindex(content,"R757") then hit_id_new ="R757";
else hit_id_new=hit_id;
run;
/*ƴ�ӽ���ʱ��*/
proc sql noprint;
create table result as
select a.*,b.����ʱ��
from early_warning_info as a 
left join apply_time1 as b on a.apply_no = b.apply_code;
quit;

data result1;
set result;
month = substr(compress(put(����ʱ��,yymmdd10.),"-"),1,6);
where input("20180501",yymmdd9.)<=����ʱ�� <=&dt.;
����=1;
run;



/*---------------д�������� �����º�������д--------------*/
/*�������ķֲ�*/
/*�����·���*/
proc tabulate data = apply_time2 out= apply_month(drop= _TYPE_  _TABLE_  _PAGE_  N);
class �����·�;
var ������;
table �����·�*������(N);
run;
proc transpose data = apply_month out=apply_month1;
id �����·�;
var ������_SUM;
run;
/*����������д*/
data apply_daily;
set apply_time2;
where &mb. <= ����ʱ�� <= &dt.;
run;
proc tabulate data = apply_daily out= apply_daily1(drop= _TYPE_  _TABLE_  _PAGE_  N);
class  ����ʱ��;
var ������;
table ����ʱ��*������*(N);
run;
proc transpose data = apply_daily1 out=apply_daily2;
id ����ʱ��;
var ������_N;
run;
/*---------------------------------The End---------------------------------*/

/*-------------------------д���й������� �����º�������д-------------------*/
/*�·ݷֲ����*/
proc sql noprint;
create table rule_month as 
select month,hit_id_new,���� from result1 order by hit_id_new;
run;
proc tabulate data = rule_month out= rule_month1(drop= _TYPE_  _TABLE_  _PAGE_  N);
class month hit_id_new;
var ����;
table hit_id_new,month*����*(n);
run;
proc transpose data=rule_month1 out=rule_month2;
by hit_id_new;
id month;
var ����_N;
run;

/*�������������зֲ����Ӧ�Ĺ����������*/
data rule_daily;
set result1;
where &mb. <= ����ʱ��<=&dt.;
run;
proc sql noprint;
create table rule_daily2 as 
select ����ʱ��,hit_id_new,���� from rule_daily order by hit_id_new;
run;

proc tabulate data = rule_daily2 out= rule_daily3(drop= drop= _TYPE_  _TABLE_  _PAGE_  N);
class ����ʱ�� hit_id_new;
var ����;
table hit_id_new,����ʱ��*����*(n);
run;
proc transpose data=rule_daily3 out=daily4;
by hit_id_new;
id ����ʱ��;
var ����_N;
run;

/*--------------------------The End----------------------------------------*/
/*����ƴ�� �������·ݵ�����ƴ����һ��*/
data reasult_month(drop=_NAME_);
set  apply_month1  rule_month2;
run;

/*�ٽ����ǰ���������ƴ����һ��*/
data reasult_daily(drop =_NAME_);
set apply_daily2 daily4;
run;

/*����ȱʧֵ*/

data reasult_month;
set reasult_month;
array num{*} _numeric_;
do i  =1 to dim(num);
if missing(num{i}) then num{i} =0;
end;
run;


data reasult_daily;
set reasult_daily;
array num{*} _numeric_;
do i  =1 to dim(num);
if missing(num{i}) then num{i} =0;
end;
run;


/*���ĵ����浽*/
FILENAME export "e:\company_file\����\��������\month.xlsx" ENCODING="utf-8";
PROC EXPORT DATA= reasult_month
            OUTFILE= export
            DBMS=xlsx label REPLACE;
RUN;

FILENAME export "e:\company_file\����\��������\daily.xlsx" ENCODING="utf-8";
PROC EXPORT DATA= reasult_daily
            OUTFILE= export
            DBMS=xlsx  label REPLACE;
RUN;



