option compress = yes validvarname = any;
option missing = 0;
libname his "D:\share\����թ����\��������";

x  "D:\share\����թ����\����թ����.xlsx"; 

data all;
set his.check_result his.realtion
his.Fraud  his.company_account  his.black; 
keep apply_code ��ǩ ����ʱ�� aac �ſ�����;
aac=1;
run;
proc sort data = all  nodupkey ;by apply_code ��ǩ;
run;

filename DD DDE "EXCEL|[����թ����.xlsx]�����!r2c1:r100000c10";
data _null_;set all;file DD;put apply_code  ��ǩ  aac  ����ʱ�� �ſ����� ;run;




%include "D:\share\github\code\report\anti_fraud\���.sas";
%include "D:\share\github\code\report\anti_fraud\��������.sas";
%include "D:\share\github\code\report\anti_fraud\����.sas";
/*%include "F:\share\����թ����\�����.sas";*/

/*%include "F:\share\����թ����\������.sas";*/
%include "D:\share\github\code\report\anti_fraud\����.sas";








