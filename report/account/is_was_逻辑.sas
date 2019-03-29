/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname yc "E:\guan\�м��\repayfin";*/
/**/
/*proc import datafile="E:\guan\���ձ���\IS_WAS\is_was����.xlsx"*/
/*	out=month dbms=excel replace;*/
/*	SHEET="Sheet1$";*/
/*	scantext=no;*/
/*	getnames=yes;*/
/*run;*/

data month1;
	set month end=last;
	call symput ("month_"||compress(_n_),month);

	*Average_TAT;
	was_b=5+(_n_-1)*12;
	was_e=12+(_n_-1)*12;
	call symput ("was_b_"||compress(_n_),compress(was_b));
	call symput("was_e_"||compress(_n_),compress(was_e));

	if last then
		call symput("lpn",compress(_n_));
run;

%macro was();
	%do i =1 %to &lpn.;

		proc sql;
			create table kan1(where=(pre_1m_status in ("01_C","02_M1","03_M2","00_NB","04_M3","05_M4","06_M5","07_M6"))) as
				select pre_1m_status,sum(�������_1��ǰ) as  �������_1��ǰ 
					from yc.payment_g(where=(month=&&month_&i. and ��Ʒ���� ^="����")) group by pre_1m_status;
		quit;

		filename DD DDE "EXCEL|[Is_Was_Analysis.xls]�������!r&&was_b_&i..c2:r&&was_e_&i..c2";

		data _null_;
			set kan1;
			file DD;
			put �������_1��ǰ;
		run;

		proc sql;
			create table kan2(where=(pre_1m_status in ("01_C","02_M1","03_M2","00_NB","04_M3","05_M4","06_M5","07_M6"))) as
				select pre_1m_status,status,sum(�������) as  ������� 
					from yc.payment_g(where=(month=&&month_&i. and ��Ʒ���� ^="����")) group by pre_1m_status,status;
		quit;

		*08_M6+���ܳ䵱����;
		data kan2a;
			set kan2;

			if status="08_M6+" then
				status="08_M6_";
		run;

		proc sort data=kan2a;
			by  pre_1m_status  status;
		run;

		proc transpose data=kan2a out=kan3  prefix=Interest_;
			by pre_1m_status;
			id status;
			var �������;
		run;

		filename DD DDE "EXCEL|[Is_Was_Analysis.xls]�������!r&&was_b_&i..c3:r&&was_e_&i..c10";

		data _null_;
			set kan3;
			file DD;
			put Interest_01_C Interest_02_M1 Interest_03_M2 Interest_04_M3 Interest_05_M4 Interest_06_M5 Interest_07_M6 Interest_08_M6_;
		run;

	%end;
%mend;

%was();
