option compress = yes validvarname = any;
libname acco odbc database=account_nf;
libname csdata 'E:\guan\ԭ����\csdata';
libname approval 'E:\guan\ԭ����\approval';
libname account 'E:\guan\ԭ����\account';
libname res "E:\guan\ԭ����\res";
libname repayfin "E:\guan\�м��\repayfin";

x 'E:\guan\���ձ���\���\��ð������估�߻���.xlsx';


proc import datafile="E:\guan\���ձ���\MTD\�����������ñ�.xls"
out=kanr_visit6 dbms=excel replace;
SHEET="���";
scantext=no;
getnames=yes;
run;

%include "E:\guan\���ձ���\���\���_�߼�.sas";

