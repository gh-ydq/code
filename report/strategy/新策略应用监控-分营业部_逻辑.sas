*需接着新策略应用监控跑;

/*x 'E:\guan\策略监控\新策略应用监控-分营业部.xlsx';*/

data test_y_1;
set test_r_2;
if region="第一类" then 维度="一类营业部汇总";
	else if region="第二类" then 维度="二类营业部汇总";
	else if region="第三类" then 维度="三类营业部汇总";
汇总="汇总";
if date>=&db.;
if model_score_level="A" and 审批通过=1 then A通过=1;else A通过=0;
if model_score_level="B" and 审批通过=1 then B通过=1;else B通过=0;
if model_score_level="C" and 审批通过=1 then C通过=1;else C通过=0;
if model_score_level="D" and 审批通过=1 then D通过=1;else D通过=0;
if model_score_level="E" and 审批通过=1 then E通过=1;else E通过=0;

if model_score_level="A" then A进件=1;else A进件=0;
if model_score_level="B" then B进件=1;else B进件=0;
if model_score_level="C" then C进件=1;else C进件=0;
if model_score_level="D" then D进件=1;else D进件=0;
if model_score_level="E" then E进件=1;else E进件=0;
run;
proc sql;
create table test_y_2_1 as 
select 营业部,count(apply_code) as 进件量,sum(其他拒绝) as 征信等拒绝量,sum(旧评分) as 旧评分拒绝量,sum(新模型) as 新模型,sum(天启黑名单) as 天启黑名单,
	sum(融360) as 融360,sum(电话邦) as 电话邦,sum(审批通过) as 审批通过量,sum(审批数量) as 审批数量,sum(自动拒绝) as 自动拒绝,sum(A通过) as A通过,
	sum(B通过) as B通过,sum(C通过) as C通过,sum(D通过) as D通过,sum(E通过) as E通过,sum(A进件) as A进件,sum(B进件) as B进件,sum(C进件) as C进件,
	sum(D进件) as D进件,sum(E进件) as E进件
from test_y_1 group by 营业部;
quit;
proc sql;
create table test_y_2_2 as 
select 维度 as 营业部,count(apply_code) as 进件量,sum(其他拒绝) as 征信等拒绝量,sum(旧评分) as 旧评分拒绝量,sum(新模型) as 新模型,sum(天启黑名单) as 天启黑名单,
	sum(融360) as 融360,sum(电话邦) as 电话邦,sum(审批通过) as 审批通过量,sum(审批数量) as 审批数量,sum(自动拒绝) as 自动拒绝,sum(A通过) as A通过,
	sum(B通过) as B通过,sum(C通过) as C通过,sum(D通过) as D通过,sum(E通过) as E通过,sum(A进件) as A进件,sum(B进件) as B进件,sum(C进件) as C进件,
	sum(D进件) as D进件,sum(E进件) as E进件
from test_y_1 group by 维度;
quit;
proc sql;
create table test_y_2_3 as 
select 汇总 as 营业部,count(apply_code) as 进件量,sum(其他拒绝) as 征信等拒绝量,sum(旧评分) as 旧评分拒绝量,sum(新模型) as 新模型,sum(天启黑名单) as 天启黑名单,
	sum(融360) as 融360,sum(电话邦) as 电话邦,sum(审批通过) as 审批通过量,sum(审批数量) as 审批数量,sum(自动拒绝) as 自动拒绝,sum(A通过) as A通过,
	sum(B通过) as B通过,sum(C通过) as C通过,sum(D通过) as D通过,sum(E通过) as E通过,sum(A进件) as A进件,sum(B进件) as B进件,sum(C进件) as C进件,
	sum(D进件) as D进件,sum(E进件) as E进件
from test_y_1 group by 汇总;
quit;
data test_y_3;
set test_y_2_1 test_y_2_2 test_y_2_3;
run;
proc import datafile="E:\guan\策略监控\新策略配置表.xlsx"
out=test_y_3_ dbms=excel replace;
SHEET="营业部";
scantext=no;
getnames=yes;
run;
proc sql;
create table test_y_4 as 
select a.* ,b.* from test_y_3_ as a
left join test_y_3 as b on a.营业部=b.营业部;
quit;
proc sort data=test_y_4;by nums;run;
filename DD DDE "EXCEL|[新策略应用监控-分营业部.xlsx]营业部MTD!r37c2:r67c21";
data _null_;set test_y_4;file DD;put 进件量 征信等拒绝量 旧评分拒绝量 新模型 天启黑名单 融360 电话邦 自动拒绝 审批数量 审批通过量 A通过 B通过 C通过 D通过 E通过 A进件 B进件 C进件 D进件 E进件;run;
