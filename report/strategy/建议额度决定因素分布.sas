/*��ȹ�ʽ*/
option compress = yes validvarname = any;
***********************************************************************************************;
*�����õ������������λ��;
libname dta "\\ts\share\Datamart\�м��\daily";
libname approval "\\ts\share\Datamart\ԭ��\approval";
libname account "\\ts\share\Datamart\ԭ��\account";
libname urule odbc datasrc=urule;

FILENAME export1 "E:\company_file\����\��������ʽ\�����ͻ�.xlsx" ENCODING="utf-8";
FILENAME export2 "E:\company_file\����\��������ʽ\�ͻ������ȷֲ����.xlsx" ENCODING="utf-8";
***********************************************************************************************;

data _null_;
format dt nt yymmdd10.;
dt = today() - 1;
nt = today();
pde=intnx("month",nt,-1,"e");
call symput("nt", dhms(nt,0,0,0));
week = weekday(nt);
call symput('week',week);
run;


/*�ͻ���Ϣ*/
data apply_gre;
set dta.customer_info(keep=apply_code ������ ����ʱ�� check_end check_date group_Level PROPOSE_LIMIT_first PROPOSE_LIMIT_final approve_��Ʒ 
							΢������� ��ʵ���� ���� ͨ�� ���˽��_���� ��ծ��
					 where=(������^='')); /*ֻ���������õ����ֶκ����ݣ���ʡʱ��*/

�����·�=substr(compress(put(����ʱ��,yymmdd10.),"-"),1,6);
input_week =week(����ʱ��);

array xx _numeric_;
do over xx;
if xx=. then xx=0;
end;
run ;  

data model_score;
set urule.rule011param(keep=apply_code created_date model_score_level
					  where=(created_date <&nt.));
run;

proc sort data = model_score ;by apply_code  descending created_date;run;

proc sort data = model_score out = model_score_urule nodupkey;by apply_code;run;


proc sql;
create table model_score_con as select a.*,b.* from 
model_score_urule as a left join apply_gre as b on a.apply_code =b.apply_code;
quit;

proc sort data = model_score_con nodupkey;by apply_code;run;

/*��������ͨ���ͻ���������ڵ㴦�ͻ�����*/
data test;
set model_score_con;
if check_end=1 ;
if check_date>mdy(11,05,2018);
if model_score_level^='F' and model_score_level^="";

if group_Level="A" and model_score_level="A" then ����="1A";
	else if model_score_level="A" then ����="2A";
	else if model_score_level="B" then ����="3B";
	else if model_score_level="C" then ����="4C";
	else if model_score_level="D" then ����="5D";
	else if model_score_level="E" then ����="6E";

if approve_��Ʒ="E΢��-�Թ�" then approve_��Ʒ="E΢��-���籣";

if PROPOSE_LIMIT_first>0  and kindex(approve_��Ʒ,"E΢��") then  ����=PROPOSE_LIMIT_final/΢�������;
else if PROPOSE_LIMIT_first>0  and approve_��Ʒ in("E��ͨ","U��ͨ") then  ����=PROPOSE_LIMIT_final/��ʵ����;

else ����=-1;

if approve_��Ʒ="U��ͨ" then do ;
	if ����="1A" then do; ���鱶��=18;�����= 150000; ��ծ������=10 ;end;
	else if ����="2A" then do; ���鱶��=16;�����= 120000; ��ծ������=10 ;end;
	else if ����="3B" then do; ���鱶��=14;�����= 100000; ��ծ������=8 ;end;
	else if ����="4C" then do; ���鱶��=12;�����= 70000; ��ծ������=7 ;end;
	else if ����="5D" then do; ���鱶��=10;�����= 50000; ��ծ������=6 ;end;
	else if ����="6E" then do; ���鱶��=8;�����= 30000; ��ծ������=5 ;end;
end;

else if approve_��Ʒ="E��ͨ" then do ;
	if ����="1A" then do; ���鱶��=16;�����= 120000; ��ծ������=10 ;end;
	else if ����="2A" then do; ���鱶��=14;�����= 100000; ��ծ������=10 ;end;
	else if ����="3B" then do; ���鱶��=12;�����= 80000; ��ծ������=8 ;end;
	else if ����="4C" then do; ���鱶��=10;�����= 60000; ��ծ������=6 ;end;
	else if ����="5D" then do; ���鱶��=8;�����= 40000; ��ծ������=4 ;end;
	else if ����="6E" then do; ���鱶��=6;�����= 30000; ��ծ������=3 ;end;
end;

else if approve_��Ʒ="E΢��" then do ;
	if ����="1A" then do; ���鱶��=10;�����= 120000; ��ծ������=8 ;end;
	else if ����="2A" then do; ���鱶��=8;�����= 100000; ��ծ������=8 ;end;
	else if ����="3B" then do; ���鱶��=6;�����= 80000; ��ծ������=6 ;end;
	else if ����="4C" then do; ���鱶��=5;�����= 60000; ��ծ������=5 ;end;
	else if ����="5D" then do; ���鱶��=4;�����= 40000; ��ծ������=4 ;end;
	else if ����="6E" then do; ���鱶��=3;�����= 30000; ��ծ������=3 ;end;
end;

else if approve_��Ʒ="E΢��-���籣" then do ;
	if ����="1A" then do; ���鱶��=10;�����= 100000; ��ծ������=8 ;end;
	else if ����="2A" then do; ���鱶��=8;�����= 80000; ��ծ������=8 ;end;
	else if ����="3B" then do; ���鱶��=6;�����= 70000; ��ծ������=6 ;end;
	else if ����="4C" then do; ���鱶��=5;�����= 50000; ��ծ������=5 ;end;
	else if ����="5D" then do; ���鱶��=4;�����= 30000; ��ծ������=4 ;end;
	else if ����="6E" then do; ���鱶��=3;�����= 20000; ��ծ������=3 ;end;
end;
if �����=PROPOSE_LIMIT_final  then ��������="�����";
else if ����>=���鱶�� then ��������="����";
else ��������='��ծ��';
/*if ��ʵ����>80000 then delete;*/
run;

/*-----------------------------------�����Ⱦ������طֲ����----------------------------------*/
proc tabulate data = test(where=(����ʱ��>=mdy(11,06,2018) and approve_��Ʒ in("E��ͨ","U��ͨ","E΢��" ,"E΢��-���籣"))) out=table1_1;
class approve_��Ʒ ���� �����·� ��������;
var ����;
table (approve_��Ʒ ALL)*(���� ALL), (�����·� ALL)*(�������� ALL)*����*(sum*f=8. pctn<���� ALL>)/misstext='0' box="��Ʒ����ֲ�";
run;

proc sql ;
create table table1 as select  approve_��Ʒ,����,�����·�,��������,count(*) as ���� 
from test(where=(����ʱ��>=mdy(11,06,2018) and approve_��Ʒ in("E��ͨ","U��ͨ","E΢��" ,"E΢��-���籣") and ͨ��=1)) group by
approve_��Ʒ,����,�����·�,��������;quit;

proc sql;
create table table2 as select approve_��Ʒ,����,�����·�,count(*) as ����,mean(���˽��_����) as ���� ,mean(PROPOSE_LIMIT_final) as ƽ��������
,mean(����) as ƽ������,mean(��ʵ����) as ƽ������,mean(΢�������)as ƽ��΢������� ,mean(��ծ��) as ƽ����ծ��
from test(where=(����ʱ��>=mdy(11,06,2018) and approve_��Ʒ in("E��ͨ","U��ͨ","E΢��" ,"E΢��-���籣")and ͨ��=1)) group by
approve_��Ʒ,����,�����·�;quit;

proc transpose data =table1 out=table1_1(drop=_name_);
by approve_��Ʒ ���� �����·�;
id ��������;
run;

/*ͨ���ͻ������ȷֲ����*/
data table_;
merge table1_1 table2;
by approve_��Ʒ ���� �����·�;
run;

/*���ݵ���*/
proc export  data=test(where=(����ʱ��>=mdy(11,06,2018) and approve_��Ʒ in("E��ͨ","U��ͨ","E΢��" ,"E΢��-���籣")))
OUTFILE= export1 DBMS=EXCEL REPLACE;SHEET="�ͻ�"; run;

proc export data = table_
outfile = export2
dbms = xlsx replace;
run;




