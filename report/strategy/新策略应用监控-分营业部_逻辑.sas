*������²���Ӧ�ü����;

/*x 'E:\guan\���Լ��\�²���Ӧ�ü��-��Ӫҵ��.xlsx';*/

data test_y_1;
set test_r_2;
if region="��һ��" then ά��="һ��Ӫҵ������";
	else if region="�ڶ���" then ά��="����Ӫҵ������";
	else if region="������" then ά��="����Ӫҵ������";
����="����";
if date>=&db.;
if model_score_level="A" and ����ͨ��=1 then Aͨ��=1;else Aͨ��=0;
if model_score_level="B" and ����ͨ��=1 then Bͨ��=1;else Bͨ��=0;
if model_score_level="C" and ����ͨ��=1 then Cͨ��=1;else Cͨ��=0;
if model_score_level="D" and ����ͨ��=1 then Dͨ��=1;else Dͨ��=0;
if model_score_level="E" and ����ͨ��=1 then Eͨ��=1;else Eͨ��=0;

if model_score_level="A" then A����=1;else A����=0;
if model_score_level="B" then B����=1;else B����=0;
if model_score_level="C" then C����=1;else C����=0;
if model_score_level="D" then D����=1;else D����=0;
if model_score_level="E" then E����=1;else E����=0;
run;
proc sql;
create table test_y_2_1 as 
select Ӫҵ��,count(apply_code) as ������,sum(�����ܾ�) as ���ŵȾܾ���,sum(������) as �����־ܾ���,sum(��ģ��) as ��ģ��,sum(����������) as ����������,
	sum(��360) as ��360,sum(�绰��) as �绰��,sum(����ͨ��) as ����ͨ����,sum(��������) as ��������,sum(�Զ��ܾ�) as �Զ��ܾ�,sum(Aͨ��) as Aͨ��,
	sum(Bͨ��) as Bͨ��,sum(Cͨ��) as Cͨ��,sum(Dͨ��) as Dͨ��,sum(Eͨ��) as Eͨ��,sum(A����) as A����,sum(B����) as B����,sum(C����) as C����,
	sum(D����) as D����,sum(E����) as E����
from test_y_1 group by Ӫҵ��;
quit;
proc sql;
create table test_y_2_2 as 
select ά�� as Ӫҵ��,count(apply_code) as ������,sum(�����ܾ�) as ���ŵȾܾ���,sum(������) as �����־ܾ���,sum(��ģ��) as ��ģ��,sum(����������) as ����������,
	sum(��360) as ��360,sum(�绰��) as �绰��,sum(����ͨ��) as ����ͨ����,sum(��������) as ��������,sum(�Զ��ܾ�) as �Զ��ܾ�,sum(Aͨ��) as Aͨ��,
	sum(Bͨ��) as Bͨ��,sum(Cͨ��) as Cͨ��,sum(Dͨ��) as Dͨ��,sum(Eͨ��) as Eͨ��,sum(A����) as A����,sum(B����) as B����,sum(C����) as C����,
	sum(D����) as D����,sum(E����) as E����
from test_y_1 group by ά��;
quit;
proc sql;
create table test_y_2_3 as 
select ���� as Ӫҵ��,count(apply_code) as ������,sum(�����ܾ�) as ���ŵȾܾ���,sum(������) as �����־ܾ���,sum(��ģ��) as ��ģ��,sum(����������) as ����������,
	sum(��360) as ��360,sum(�绰��) as �绰��,sum(����ͨ��) as ����ͨ����,sum(��������) as ��������,sum(�Զ��ܾ�) as �Զ��ܾ�,sum(Aͨ��) as Aͨ��,
	sum(Bͨ��) as Bͨ��,sum(Cͨ��) as Cͨ��,sum(Dͨ��) as Dͨ��,sum(Eͨ��) as Eͨ��,sum(A����) as A����,sum(B����) as B����,sum(C����) as C����,
	sum(D����) as D����,sum(E����) as E����
from test_y_1 group by ����;
quit;
data test_y_3;
set test_y_2_1 test_y_2_2 test_y_2_3;
run;
proc import datafile="E:\guan\���Լ��\�²������ñ�.xlsx"
out=test_y_3_ dbms=excel replace;
SHEET="Ӫҵ��";
scantext=no;
getnames=yes;
run;
proc sql;
create table test_y_4 as 
select a.* ,b.* from test_y_3_ as a
left join test_y_3 as b on a.Ӫҵ��=b.Ӫҵ��;
quit;
proc sort data=test_y_4;by nums;run;
filename DD DDE "EXCEL|[�²���Ӧ�ü��-��Ӫҵ��.xlsx]Ӫҵ��MTD!r37c2:r67c21";
data _null_;set test_y_4;file DD;put ������ ���ŵȾܾ��� �����־ܾ��� ��ģ�� ���������� ��360 �绰�� �Զ��ܾ� �������� ����ͨ���� Aͨ�� Bͨ�� Cͨ�� Dͨ�� Eͨ�� A���� B���� C���� D���� E����;run;
