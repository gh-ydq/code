/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname yc "E:\guan\中间表\repayfin";*/
/**/
/*proc import datafile="E:\guan\催收报表\IS_WAS\is_was配置.xlsx"*/
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
			create table kan1_1(where=(pre_1m_status in ("01_C","02_M1","03_M2","00_NB","04_M3","05_M4","06_M5","07_M6"))) as
				select pre_1m_status,sum(贷款余额_1月前) as  贷款余额_1月前 
					from yc.payment_g(where=(month=&&month_&i. and 产品大类 ^="续贷")) group by pre_1m_status;
		quit;
		*201908开始无新放款数据，此处添加新放款数据为0，以适应DDE;
		data kan1_2;
		format pre_1m_status $24.;
		pre_1m_status="00_NB";
		贷款余额_1月前=0;
		run;
		data kan1;
		set kan1_1 kan1_2;
		run;
		proc sort data=kan1;by pre_1m_status descending 贷款余额_1月前;run;
		proc sort data=kan1 nodupkey;by pre_1m_status;run;

		filename DD DDE "EXCEL|[Is_Was_Analysis.xls]贷款余额!r&&was_b_&i..c2:r&&was_e_&i..c2";

		data _null_;
			set kan1;
			file DD;
			put 贷款余额_1月前;
		run;

		proc sql;
			create table kan2(where=(pre_1m_status in ("01_C","02_M1","03_M2","00_NB","04_M3","05_M4","06_M5","07_M6"))) as
				select pre_1m_status,status,sum(贷款余额) as  贷款余额 
					from yc.payment_g(where=(month=&&month_&i. and 产品大类 ^="续贷")) group by pre_1m_status,status;
		quit;

		*08_M6+不能充当列名;
		data kan2a;
			set kan2;

			if status="08_M6+" then
				status="08_M6_";
		run;

		proc sort data=kan2a;
			by  pre_1m_status  status;
		run;

		proc transpose data=kan2a out=kan3_1  prefix=Interest_;
			by pre_1m_status;
			id status;
			var 贷款余额;
		run;
		*201908开始无新放款数据，此处添加新放款数据为0，以适应DDE;
		data kan3_2;
		format pre_1m_status $24.;
		format _NAME_ $8.;
		pre_1m_status="00_NB";
		_NAME_="贷款余额";
		Interest_01_C=0;
		Interest_02_M1=0;
		Interest_03_M2 =0;
		Interest_04_M3 =0;
		Interest_05_M4 =0;
		Interest_06_M5 =0;
		Interest_07_M6 =0;
		Interest_08_M6_=0;
		run;
		data kan3;
		set kan3_2 kan3_1;
		run;
		proc sort data=kan3;by pre_1m_status descending Interest_01_C;run;
		proc sort data=kan3 nodupkey;by pre_1m_status;run;
		filename DD DDE "EXCEL|[Is_Was_Analysis.xls]贷款余额!r&&was_b_&i..c3:r&&was_e_&i..c10";

		data _null_;
			set kan3;
			file DD;
			put Interest_01_C Interest_02_M1 Interest_03_M2 Interest_04_M3 Interest_05_M4 Interest_06_M5 Interest_07_M6 Interest_08_M6_;
		run;

	%end;
%mend;

%was();
