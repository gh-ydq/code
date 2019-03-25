option compress = yes validvarname = any;
libname acco odbc database=account_nf;
libname csdata 'E:\guan\原数据\csdata';
libname approval 'E:\guan\原数据\approval';
libname account 'E:\guan\原数据\account';
libname res "E:\guan\原数据\res";
libname repayfin "E:\guan\中间表\repayfin";

x 'E:\guan\催收报表\外访\外访案件分配及催回率.xlsx';


proc import datafile="E:\guan\催收报表\MTD\米粒报表配置表.xls"
out=kanr_visit6 dbms=excel replace;
SHEET="外访";
scantext=no;
getnames=yes;
run;

%include "E:\guan\催收报表\外访\外访_逻辑.sas";

