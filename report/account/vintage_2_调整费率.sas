/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname account 'E:\guan\原数据\account';*/
/*libname repayFin "E:\guan\中间表\repayfin";*/
/*libname approval 'E:\guan\原数据\approval';*/
/*libname yc "E:\guan\中间表\repayfin";*/

data account_info0;
set account.account_info;
format product_code_2 $20.;
if not kindex(PRODUCT_CODE,"MPD");
if index(PRODUCT_CODE,"Elite")>0 or index(PRODUCT_CODE,"TYElite")>0 then product_code_2="U贷通" ;
else if index (product_code ,"Salariat")>0 or index(product_code,"TYSalariat")>0  then product_code_2="E贷通" ;
else if index (product_code ,"Ebaotong-zigu")>0 then product_code_2="E保通-自雇" ;
else if index (product_code ,"Ebaotong")>0 then product_code_2="E保通";
else if index (product_code ,"Efangtong")>0 then product_code_2="E房通" ;
else if index (product_code ,"Eshetong")>0 then product_code_2="E社通" ;
else if index (product_code ,"Ewangtong")>0 then product_code_2="E网通" ;
else if index (product_code ,"Eweidai-zigu")>0 then product_code_2="E微贷-自雇" ;
else if index (product_code ,"Eweidai-NoSecurity")>0 then product_code_2="E微贷-无社保" ;
else if index (product_code ,"Eweidai")>0 then product_code_2="E微贷" ;
else if index (product_code ,"Ezhaitong-zigu")>0 then product_code_2="E宅通-自雇" ;

else if index (product_code ,"Ezhaitong")>0 then product_code_2="E宅通" ;
else if index (product_code ,"Easy-CreditCard")>0 then product_code_2="Easy贷信用卡" ;
else if index (product_code ,"Easy-ZhiMa")>0 then product_code_2="Easy贷芝麻分" ;

if kindex (product_code ,"RFSalariat")>0 then product_code_2="E贷通续贷" ;
else if kindex (product_code ,"RFElite")>0 then product_code_2="U贷通续贷" ;

code=tranwrd(CONTRACT_NO,"C","PL");
产品费率=compress(product_code_2||INTEREST_RATE);
放款月份=put(LOAN_DATE,yymmn6.);
/*有效账户*/
run;
data apply_ext_data;
set approval.apply_ext_data;
run;
proc sql;
create table rate as
select a.*,b.婚姻状况,b.年龄,b.分群,c.CC_CODE,c.OC_CODE,b.营业部,b.户籍市,b.其他负债,b.无抵押贷款,b.负债率,b.户口性质,b.外地标签,b.批核日期,
sum(b.近3个月贷款查询次数,b.近3个月本人查询次数) as 近3个月查询次数,d.nation,d.SESAME_SCORE as 芝麻分
from account_info0 as a
left join  repayfin.big_table as b on a.contract_no=b.contract_no
left join apply_ext_data as c on b.APPLY_CODE=c.APPLY_CODE
left join approval.apply_base as d on b.apply_code=d.apply_code;
quit;
proc sort data=rate nodupkey ;by contract_no;run;
data rate1;
set rate;
if 户口性质="" then 户口性质=外地标签;
调整费率_last=substr(product_code,find(product_code,'.',1)-1,4);
run;


data interest_adjust_;
set rate1;
if product_code_2="U贷通" then do;
	调整费率='1.78';
	if kindex(户口性质,"本地") & 无抵押贷款<=0 & 负债率<=100 & 其他负债<=0 & 近3个月查询次数<=2 then 调整费率='1.38';
	else if 婚姻状况 in ("离异","未婚") or 年龄<=25 or 年龄>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
	or 近3个月查询次数>=7 then do;
		if 分群 in ("A","B") then 调整费率='1.98';else 调整费率='2.18';end;
	else if 分群 in ("A","B") then 调整费率='1.58';
end;
if kindex(product_code_2,"E") then do;
	调整费率='2.18';
	if kindex(户口性质,"本地") & 无抵押贷款<=0 & 负债率<=100 & 其他负债<=0 & 近3个月查询次数<=2 then 调整费率='1.58';
	else if 婚姻状况 in ("离异","未婚") or 年龄<=25 or 年龄>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
	or 近3个月查询次数>=7 then do;
	 	if 分群 in ("A","B") then 调整费率='1.98';else 调整费率='2.38';end;
	else if 分群 in ("A","B") then 调整费率='1.78';
end;

if (kindex(营业部,"乌鲁木齐") or kindex(营业部,"伊犁"))  and nation not in ("","01") then 调整费率1=sum(调整费率,0.2);
if product_code_2="U贷通" and 调整费率1>=2.18 then 调整费率1='2.18';
if  kindex(product_code_2,"E") and 调整费率1>=2.38 then 调整费率1='2.38';
if 调整费率1>0 then 调整费率=调整费率1;
if CC_CODE in ("CC04","CC05") and  调整费率>1.78 then 调整费率='1.78';

if product_code_2="Easy贷芝麻分" then do;
	if kindex(户口性质,"本地") & 无抵押贷款<=0 & 负债率<=100 & 其他负债<=0 & 近3个月查询次数<=2 & 芝麻分>=750 then 调整费率=1.98;
	else if 婚姻状况 in ("离异","未婚") or 年龄<=25 or 年龄>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	 OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
 	or 近3个月查询次数>=6 then do; 
		if 芝麻分>=700 then 调整费率='2.18';
		if 650<=芝麻分<=699 then 调整费率='2.38';
	end;
	else if 700<=芝麻分 then 调整费率='2.18';
	else if 650<=芝麻分<=699 then 调整费率='2.38';
end;
if product_code_2="Easy贷信用卡" then do;
	if kindex(户口性质,"本地") & 无抵押贷款<=0 & 负债率<=100 & 其他负债<=0 & 近3个月查询次数<=2 then 调整费率=1.98;
	else if 婚姻状况 in ("离异","未婚") or 年龄<=25 or 年龄>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	 OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
 	or 近3个月查询次数>=6 then do; 
		if 分群 in ("A","B") then 调整费率='2.38';
		if 分群 in ("C","D","E","F") then 调整费率='2.58';
	end;
	else if 分群 in ("A","B") then 调整费率='2.18';
	else if 分群 in ("C","D","E","F") then 调整费率='2.38';
end;

drop 调整费率1;
run;
data repayfin.interest_adjust;;
set interest_adjust_;
format 批核日期_ yymmdd10.;
批核日期_=mdy(substr(批核日期,6,2),substr(批核日期,9,2),substr(批核日期,1,4));
if 批核日期_>=mdy(6,5,2018) then 调整费率=调整费率_last;
run;



data kan;
set repayfin.interest_adjust;
if 调整费率_last='1.38';
/*if 调整费率 not in ('1.38','1.58','1.78','1.98','2.18','2.38','2.58');*/
/*if mdy(1,1,2017)<=loan_date<=mdy(5,31,2018);*/
keep 婚姻状况  年龄  CC_CODE 近3个月查询次数 分群 户口性质 无抵押贷款 负债率 其他负债 contract_no ch_name product_code_2 调整费率 放款月份;
run;
proc sort data=kan;by descending 放款月份;run;
