USE ProjectManage
GO
----------------------------------------------------------------
--1、行转列 PIVOT
/*
CREATE  TABLE scs
(
   stu    NVARCHAR(5),        --学生姓名
   cls    NVARCHAR(5),        --科目
   scr    FLOAT,              --成绩
)

INSERT INTO scs SELECT '张三', '语文', 80
INSERT INTO scs SELECT '张三', '数学', 90
INSERT INTO scs SELECT '张三', '英语', 70
INSERT INTO scs SELECT '张三', '生物', 85
INSERT INTO scs SELECT '李四', '语文', 80
INSERT INTO scs SELECT '李四', '数学', 92
INSERT INTO scs SELECT '李四', '英语', 76
INSERT INTO scs SELECT '李四', '生物', 88
INSERT INTO scs SELECT '码农', '语文', 60
INSERT INTO scs SELECT '码农', '数学', 82
INSERT INTO scs SELECT '码农', '英语', 96
INSERT INTO scs SELECT '码农', '生物', 78

SELECT stu 姓名,语文,数学,英语,生物 FROM scs /*数据源*/
AS P
PIVOT
(
    SUM(P.scr /*行转列后列的值*/) FOR
    P.cls /*需要行转列的列*/ IN (语文,数学,英语,生物 /*列的值*/)
)T

SELECT stu,cls,sco,
(SELECT count(*)+1 FROM scs T WHERE T.cls = P.cls AND T.sco > P.sco) AS 名次
FROM scs P
GROUP BY cls,sco,stu
ORDER BY cls DESC;
*/

----------------------------------------------------------------
--2、列转行 UNPIVOT
/*
CREATE TABLE ProgrectDetail
(
    ProgrectName         NVARCHAR(20), --工程名称
    OverseaSupply        INT,          --海外供应商供给数量
    NativeSupply         INT,          --国内供应商供给数量
    SouthSupply          INT,          --南方供应商供给数量
    NorthSupply          INT           --北方供应商供给数量
)

INSERT INTO ProgrectDetail
SELECT 'A', 100, 200, 50, 50
UNION ALL
SELECT 'B', 200, 300, 150, 150
UNION ALL
SELECT 'C', 159, 400, 20, 320
*/

/*
SELECT P.ProgrectName,P.Supplier,P.SupplyNum
FROM 
(
    SELECT ProgrectName, OverseaSupply, NativeSupply,
           SouthSupply, NorthSupply
     FROM ProgrectDetail
)T
UNPIVOT
(
    SupplyNum FOR Supplier IN
    (OverseaSupply, NativeSupply, SouthSupply, NorthSupply)
)P
*/

----------------------------------------------------------------
--3、创建交叉表 CASE WHEN THEN
/*
SELECT stu as 姓名,
Avg(CASE sub WHEN  '语文' THEN sco ELSE null END) as 语文,
Avg(CASE sub WHEN  '数学' THEN sco ELSE null END) as 数学,
Avg(CASE sub WHEN  '英语' THEN sco ELSE null END) as 英语,
Avg(CASE sub WHEN  '生物' THEN sco ELSE null END) as 生物
FROM scs
GROUP BY stu
ORDER BY stu
*/

----------------------------------------------------------------
--4、创建交叉表 CASE WHEN THEN
/*
CREATE  TABLE sc --成绩表
(
   stuid VARCHAR(5),  --学生编号
   clsid VARCHAR(5),  --课程编号
   scroe FLOAT        --成绩
)

INSERT INTO sc SELECT '101', '001', 75.0
INSERT INTO sc SELECT '102', '001', 70.0
INSERT INTO sc SELECT '103', '001', 90.0
INSERT INTO sc SELECT '101', '002', 89.0
INSERT INTO sc SELECT '102', '002', 80.0
INSERT INTO sc SELECT '103', '002', 99.0
INSERT INTO sc SELECT '101', '003', 89.0
INSERT INTO sc SELECT '102', '003', 79.0
INSERT INTO sc SELECT '103', '003', 67.0

CREATE  TABLE stu --学生表
(
   stuid   VARCHAR(5),     --学生编号
   stuname NVARCHAR(5),    --学生姓名
)

INSERT INTO stu SELECT '101', '张三'
INSERT INTO stu SELECT '102', '李四'
INSERT INTO stu SELECT '103', '王五'

CREATE  TABLE cls --课程表
(
   clsid   VARCHAR(5),      --课程编号
   clsname NVARCHAR(5),     --课程名称
)

INSERT INTO cls SELECT '001', '语文'
INSERT INTO cls SELECT '002', '数学'
INSERT INTO cls SELECT '003', '英语'

declare @sql nvarchar(4000),@sql1 nvarchar(4000)
select @sql='',@sql1=''

select @sql=@sql+',['+clsname+']=sum(case clsid when '''+clsid+''' then scroe else 0 end)',
       @sql1=@sql1+',['+clsname+'名次]=(select sum(1) from # where ['+clsname+']>=a.['+clsname+'])'       
from(select distinct b.clsid,c.clsname from sc as b inner join cls as c on c.clsid=b.clsid) as a order by clsid

exec('select stuid 学号'+@sql+',
总成绩=sum(scroe),
平均分=convert(dec(5,1),avg(scroe)),
总名次=(select sum(1) from(select stuid,aa=sum(scroe) from sc group by stuid) aa where sum(a.scroe)<=aa) into # from sc as a group by stuid select b.stuname as 姓名,a.*'+@sql1+' from # as a inner join stu as b on a.学号=b.stuid')
*/

----------------------------------------------------------------
--5、学生各门课程成绩统计SQL语句大全
/*
CREATE  TABLE stuscore --成绩表
(
   stuid    INT,          --学生编号
   name     NVARCHAR(5),  --学生姓名
   subject  NVARCHAR(5),  --课程名称
   score    FLOAT         --成绩
)

insert into stuscore values (1,'张三','数学',89);
insert into stuscore values (1,'张三','语文',80);
insert into stuscore values (1,'张三','英语',70);
insert into stuscore values (2,'李四','数学',90);
insert into stuscore values (2,'李四','语文',70);
insert into stuscore values (2,'李四','英语',80)

--计算每个人的总成绩并排名(要求显示字段：姓名，总成绩) 
select name,sum(score) as allscore from stuscore
group by name
order by allscore;

--计算每个人的总成绩并排名(要求显示字段: 学号，姓名，总成绩) 
select stuid,name,sum(score) as allscore from dbo.stuscore
group by name,stuid
order by allscore;

--计算每个人单科的最高成绩(要求显示字段: 学号，姓名，课程，最高成绩)
select t1.stuid,t1.name,t1.subject,t1.score from stuscore t1,
(select stuid,max(score) as maxscore from stuscore group by stuid) t2
where t1.stuid=t2.stuid and t1.score=t2.maxscore;

--计算每个人的平均成绩（要求显示字段: 学号，姓名，平均成绩）
select stuid,name,avg(score) avgscore from dbo.stuscore
group by stuid,name;

--列出各门课程成绩最好的学生(要求显示字段: 学号，姓名,科目，成绩) 
select t1.stuid,t1.name,t1.subject,t1.score from stuscore t1,
(select subject,max(score) as maxscore from stuscore group by subject)t2
where t1.subject = t2.subject and t1.score = t2.maxscore;

--列出各门课程成绩最好的两位学生(要求显示字段: 学号，姓名,科目，成绩) 
select  t1.* from stuscore t1 where t1.stuid
in(select top 2 stuid from stuscore where subject = t1.subject order by score desc)
order by t1.subject;

--统计如下： 
select stuid 学号,name 姓名,sum(case when subject='语文' then score else 0 end )as 语文,
sum(case when subject='数学' then score else 0 end )as 数学,
sum(case when subject='英语' then score else 0 end )as 英语,
sum(score)总分,avg(score)平均分 from stuscore
group by stuid,name order by 总分;

--列出各门课程的平均成绩（要求显示字段：课程，平均成绩）
select subject,avg(score)平均成绩 from stuscore
group by subject;

--列出数学成绩的排名（要求显示字段：学号，姓名，成绩，排名）
--注释：排序，比较大小，比较的次数+1 = 排名。
select stuid,name,score,
(select count(*) from stuscore t1 where subject ='数学' and t1.score > t2.score)+1 as 名次 from stuscore t2
where subject='数学' order by score desc;

--列出数学成绩在2-3名的学生（要求显示字段：学号，姓名,科目，成绩） 
select t3.* from
(select top 2  t2.* from
 (select top 3 stuid,name,subject,score from stuscore where subject = '数学' order by score desc) t2
  order by t2.score) t3
order by t3.score desc;

select t3.*  from
(select top 100 percent stuid,name,subject,score,
(select count(*) from stuscore t1 where subject ='数学' and t1.score > t2.score)+1 as 名次 from
 stuscore t2  where subject='数学' order by t2.score desc) t3 
where t3.名次 between 2 and 3
order by t3.score desc;

select t3.*  from
(select stuid,name,subject,score,
(select count(*) from stuscore t1 where subject ='数学' and t1.score > t2.score)+1 as 名次 from
 stuscore t2  where subject='数学') t3
where t3.名次 between 2 and 3
order by t3.score desc;

--求出李四的数学成绩的排名
declare @tmp table(pm int,name varchar(50),score int,stuid int)
insert into @tmp select null,name,score,stuid from stuscore where subject='数学'
order by score desc declare @id int set @id=0;
update @tmp set @id=@id+1,pm=@id select * from @tmp where name='李四'

select stuid,name,subject,score,(select count(*) from stuscore t1 where subject ='数学' and t1.score > t2.score)+1 as 名次
from stuscore t2  where subject='数学' and name = '李四' order by score desc;

--统计如下：
课程 不及格（0-59）个  良（60-80）个  优（81-100）个
select subject 科目,sum(case when score between 0 and 59 then 1 else 0 end) as 不及格,
sum(case when score between 60 and 80 then 1 else 0 end) as 良,
sum(case when score between 81 and 100 then 1 else 0 end) as 优秀
from stuscore
group by subject;

--统计如下：
数学: 张三(50分),李四(90分),王五(90分),赵六(76分) 
declare @s nvarchar(1000)
set @s=''
select @s =@s+','+name+'('+convert(nvarchar(10),score)+'分)' from
stuscore where subject='数学'
set @s=stuff(@s,1,1,' ')print '数学:'+@s
*/