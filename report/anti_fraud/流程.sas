option compress = yes validvarname = any;
option missing = 0;
libname his "D:\share\反欺诈数据\更新数据";

x  "D:\share\反欺诈数据\反欺诈数据.xlsx"; 

data all;
set his.check_result his.realtion
his.Fraud  his.company_account  his.black; 
keep apply_code 标签 更新时间 aac 放款日期;
aac=1;
run;
proc sort data = all  nodupkey ;by apply_code 标签;
run;

filename DD DDE "EXCEL|[反欺诈数据.xlsx]多规则!r2c1:r100000c10";
data _null_;set all;file DD;put apply_code  标签  aac  更新时间 放款日期 ;run;




%include "D:\share\github\code\report\anti_fraud\审核.sas";
%include "D:\share\github\code\report\anti_fraud\关联规则.sas";
%include "D:\share\github\code\report\anti_fraud\催收.sas";
/*%include "F:\share\反欺诈数据\集体件.sas";*/

/*%include "F:\share\反欺诈数据\黑名单.sas";*/
%include "D:\share\github\code\report\anti_fraud\销售.sas";








