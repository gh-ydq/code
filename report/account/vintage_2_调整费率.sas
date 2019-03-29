/*option compress = yes validvarname = any;*/
/*option missing = 0;*/
/*libname account 'E:\guan\ԭ����\account';*/
/*libname repayFin "E:\guan\�м��\repayfin";*/
/*libname approval 'E:\guan\ԭ����\approval';*/
/*libname yc "E:\guan\�м��\repayfin";*/

data account_info0;
set account.account_info;
format product_code_2 $20.;
if not kindex(PRODUCT_CODE,"MPD");
if index(PRODUCT_CODE,"Elite")>0 or index(PRODUCT_CODE,"TYElite")>0 then product_code_2="U��ͨ" ;
else if index (product_code ,"Salariat")>0 or index(product_code,"TYSalariat")>0  then product_code_2="E��ͨ" ;
else if index (product_code ,"Ebaotong-zigu")>0 then product_code_2="E��ͨ-�Թ�" ;
else if index (product_code ,"Ebaotong")>0 then product_code_2="E��ͨ";
else if index (product_code ,"Efangtong")>0 then product_code_2="E��ͨ" ;
else if index (product_code ,"Eshetong")>0 then product_code_2="E��ͨ" ;
else if index (product_code ,"Ewangtong")>0 then product_code_2="E��ͨ" ;
else if index (product_code ,"Eweidai-zigu")>0 then product_code_2="E΢��-�Թ�" ;
else if index (product_code ,"Eweidai-NoSecurity")>0 then product_code_2="E΢��-���籣" ;
else if index (product_code ,"Eweidai")>0 then product_code_2="E΢��" ;
else if index (product_code ,"Ezhaitong-zigu")>0 then product_code_2="Eլͨ-�Թ�" ;

else if index (product_code ,"Ezhaitong")>0 then product_code_2="Eլͨ" ;
else if index (product_code ,"Easy-CreditCard")>0 then product_code_2="Easy�����ÿ�" ;
else if index (product_code ,"Easy-ZhiMa")>0 then product_code_2="Easy��֥���" ;

if kindex (product_code ,"RFSalariat")>0 then product_code_2="E��ͨ����" ;
else if kindex (product_code ,"RFElite")>0 then product_code_2="U��ͨ����" ;

code=tranwrd(CONTRACT_NO,"C","PL");
��Ʒ����=compress(product_code_2||INTEREST_RATE);
�ſ��·�=put(LOAN_DATE,yymmn6.);
/*��Ч�˻�*/
run;
data apply_ext_data;
set approval.apply_ext_data;
run;
proc sql;
create table rate as
select a.*,b.����״��,b.����,b.��Ⱥ,c.CC_CODE,c.OC_CODE,b.Ӫҵ��,b.������,b.������ծ,b.�޵�Ѻ����,b.��ծ��,b.��������,b.��ر�ǩ,b.��������,
sum(b.��3���´����ѯ����,b.��3���±��˲�ѯ����) as ��3���²�ѯ����,d.nation,d.SESAME_SCORE as ֥���
from account_info0 as a
left join  repayfin.big_table as b on a.contract_no=b.contract_no
left join apply_ext_data as c on b.APPLY_CODE=c.APPLY_CODE
left join approval.apply_base as d on b.apply_code=d.apply_code;
quit;
proc sort data=rate nodupkey ;by contract_no;run;
data rate1;
set rate;
if ��������="" then ��������=��ر�ǩ;
��������_last=substr(product_code,find(product_code,'.',1)-1,4);
run;


data interest_adjust_;
set rate1;
if product_code_2="U��ͨ" then do;
	��������='1.78';
	if kindex(��������,"����") & �޵�Ѻ����<=0 & ��ծ��<=100 & ������ծ<=0 & ��3���²�ѯ����<=2 then ��������='1.38';
	else if ����״�� in ("����","δ��") or ����<=25 or ����>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
	or ��3���²�ѯ����>=7 then do;
		if ��Ⱥ in ("A","B") then ��������='1.98';else ��������='2.18';end;
	else if ��Ⱥ in ("A","B") then ��������='1.58';
end;
if kindex(product_code_2,"E") then do;
	��������='2.18';
	if kindex(��������,"����") & �޵�Ѻ����<=0 & ��ծ��<=100 & ������ծ<=0 & ��3���²�ѯ����<=2 then ��������='1.58';
	else if ����״�� in ("����","δ��") or ����<=25 or ����>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
	or ��3���²�ѯ����>=7 then do;
	 	if ��Ⱥ in ("A","B") then ��������='1.98';else ��������='2.38';end;
	else if ��Ⱥ in ("A","B") then ��������='1.78';
end;

if (kindex(Ӫҵ��,"��³ľ��") or kindex(Ӫҵ��,"����"))  and nation not in ("","01") then ��������1=sum(��������,0.2);
if product_code_2="U��ͨ" and ��������1>=2.18 then ��������1='2.18';
if  kindex(product_code_2,"E") and ��������1>=2.38 then ��������1='2.38';
if ��������1>0 then ��������=��������1;
if CC_CODE in ("CC04","CC05") and  ��������>1.78 then ��������='1.78';

if product_code_2="Easy��֥���" then do;
	if kindex(��������,"����") & �޵�Ѻ����<=0 & ��ծ��<=100 & ������ծ<=0 & ��3���²�ѯ����<=2 & ֥���>=750 then ��������=1.98;
	else if ����״�� in ("����","δ��") or ����<=25 or ����>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	 OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
 	or ��3���²�ѯ����>=6 then do; 
		if ֥���>=700 then ��������='2.18';
		if 650<=֥���<=699 then ��������='2.38';
	end;
	else if 700<=֥��� then ��������='2.18';
	else if 650<=֥���<=699 then ��������='2.38';
end;
if product_code_2="Easy�����ÿ�" then do;
	if kindex(��������,"����") & �޵�Ѻ����<=0 & ��ծ��<=100 & ������ծ<=0 & ��3���²�ѯ����<=2 then ��������=1.98;
	else if ����״�� in ("����","δ��") or ����<=25 or ����>=50 or 
	CC_CODE in ("CC07","CC08","CC09","CC10","CC15","CC16","CC17","CC19","CC21","CC22","CC23","CC24",
	"CC27","CC60","CC61","CC62","CC63","CC66","CC69","CC71","CC76","CC77","CC78","CC79") or
	 OC_CODE in ("OC08","OC17","OC18","OC22","OC23","OC24","OC25","OC26","OC27","OC28","OC29","OC30","OC31","OC32")
 	or ��3���²�ѯ����>=6 then do; 
		if ��Ⱥ in ("A","B") then ��������='2.38';
		if ��Ⱥ in ("C","D","E","F") then ��������='2.58';
	end;
	else if ��Ⱥ in ("A","B") then ��������='2.18';
	else if ��Ⱥ in ("C","D","E","F") then ��������='2.38';
end;

drop ��������1;
run;
data repayfin.interest_adjust;;
set interest_adjust_;
format ��������_ yymmdd10.;
��������_=mdy(substr(��������,6,2),substr(��������,9,2),substr(��������,1,4));
if ��������_>=mdy(6,5,2018) then ��������=��������_last;
run;



data kan;
set repayfin.interest_adjust;
if ��������_last='1.38';
/*if �������� not in ('1.38','1.58','1.78','1.98','2.18','2.38','2.58');*/
/*if mdy(1,1,2017)<=loan_date<=mdy(5,31,2018);*/
keep ����״��  ����  CC_CODE ��3���²�ѯ���� ��Ⱥ �������� �޵�Ѻ���� ��ծ�� ������ծ contract_no ch_name product_code_2 �������� �ſ��·�;
run;
proc sort data=kan;by descending �ſ��·�;run;
