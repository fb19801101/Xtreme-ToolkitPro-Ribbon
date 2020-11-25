USE ProjectManage
select distinct * into #Tmp from 计量台账
drop table 计量台账
select * into 计量台账 from #Tmp
drop table #Tmp


我们可能会出现这种情况，某个表原来设计不周全，导致表里面的数据数据重复，那么，如何对重复的数据进行删除呢？ 
重复的数据可能有这样两种情况，第一种时表中只有某些字段一样，第二种是两行记录完全一样。 
一、对于部分字段重复数据的删除 
先来谈谈如何查询重复的数据吧。 
下面语句可以查询出那些数据是重复的：

select 字段1,字段2,count(*) from 表名 group by 字段1,字段2 having count(*) > 1

将上面的>号改为=号就可以查询出没有重复的数据了。 
想要删除这些重复的数据，可以使用下面语句进行删除

delete from 表名 a where 字段1,字段2 in  
(select 字段1,字段2,count(*) from 表名 group by 字段1,字段2 having count(*) > 1)

上面的语句非常简单，就是将查询到的数据删除掉。不过这种删除执行的效率非常低，对于大数据量来说，可能会将数据库吊死。所以我建议先将查询到的重复的数据插入到一个临时表中，然后对进行删除，这样，执行删除的时候就不用再进行一次查询了。如下：

CREATE TABLE 临时表 AS  
(select 字段1,字段2,count(*) from 表名 group by 字段1,字段2 having count(*) > 1)

上面这句话就是建立了临时表，并将查询到的数据插入其中。 
下面就可以进行这样的删除操作了

delete from 表名 a where 字段1,字段2 in (select 字段1，字段2 from 临时表);

这种先建临时表再进行删除的操作要比直接用一条语句进行删除要高效得多。 

这个时候，大家可能会跳出来说，什么？你叫我们执行这种语句，那不是把所有重复的全都删除吗？而我们想保留重复数据中最新的一条记录啊！大家不要急，下面我就讲一下如何进行这种操作。 
在oracle中，有个隐藏了自动rowid，里面给每条记录一个唯一的rowid，我们如果想保留最新的一条记录， 
我们就可以利用这个字段，保留重复数据中rowid最大的一条记录就可以了，

下面是查询重复数据的一个例子：

select a.rowid,a.* from 表名 a   
where a.rowid !=   
(  
select max(b.rowid) from 表名 b   
where a.字段1 = b.字段1 and   
a.字段2 = b.字段2   
)

下面我就来讲解一下，上面括号中的语句是查询出重复数据中rowid最大的一条记录。 
而外面就是查询出除了rowid最大之外的其他重复的数据了。 
由此，我们要删除重复数据，只保留最新的一条数据，就可以这样写了：

delete from 表名 a   
where a.rowid !=   
(  
select max(b.rowid) from 表名 b   
where a.字段1 = b.字段1 and   
a.字段2 = b.字段2   
)

随便说一下，上面语句的执行效率是很低的，可以考虑建立临时表，讲需要判断重复的字段、rowid插入临时表中，然后删除的时候在进行比较。

create table 临时表 as   
select a.字段1,a.字段2,MAX(a.ROWID) dataid from 正式表 a GROUP BY a.字段1,a.字段2
 

delete from 表名 a   
where a.rowid !=   
(  
select b.dataid from 临时表 b   
where a.字段1 = b.字段1 and   
a.字段2 = b.字段2   
);  
commit;

二、对于完全重复记录的删除 
对于表中两行记录完全一样的情况，可以用下面语句获取到去掉重复数据后的记录： 
select distinct * from 表名 
可以将查询的记录放到临时表中，然后再将原来的表记录删除，最后将临时表的数据导回原来的表中。如下：

CREATE TABLE 临时表 AS (select distinct * from 表名);  
drop table 正式表;  
insert into 正式表 (select * from 临时表);  
drop table 临时表;

如果想删除一个表的重复数据，可以先建一个临时表，将去掉重复数据后的数据导入到临时表，然后在从 
临时表将数据导入正式表中，如下：

INSERT INTO t_table_bak  
select distinct * from t_table;


--> --> (Roy)生成測試數據
 
if not object_id('Tempdb..#T') is null
    drop table #T
Go
Create table #T([ID] int,[Name] nvarchar(1),[Memo] nvarchar(2))
Insert #T
select 1,N'A',N'A1' union all
select 2,N'A',N'A2' union all
select 3,N'A',N'A3' union all
select 4,N'B',N'B1' union all
select 5,N'B',N'B2'
Go
 
--I、Name相同ID最小的记录(推荐用1,2,3),保留最小一条
方法1:
delete a from #T a where  exists(select 1 from #T where Name=a.Name and ID<a.ID)
 
方法2:
delete a  from #T a left join (select min(ID)ID,Name from #T group by Name) b on a.Name=b.Name and a.ID=b.ID where b.Id is null
 
方法3:
delete a from #T a where ID not in (select min(ID) from #T where Name=a.Name)
 
方法4(注:ID为唯一时可用):
delete a from #T a where ID not in(select min(ID)from #T group by Name)
 
方法5:
delete a from #T a where (select count(1) from #T where Name=a.Name and ID<a.ID)>0
 
方法6:
delete a from #T a where ID<>(select top 1 ID from #T where Name=a.name order by ID)
 
方法7:
delete a from #T a where ID>any(select ID from #T where Name=a.Name)
 
 
 
select * from #T
 
生成结果:
/*
ID          Name Memo
----------- ---- ----
1           A    A1
4           B    B1
 
(2 行受影响)
*/
 
 
--II、Name相同ID保留最大的一条记录:
 
方法1:
delete a from #T a where  exists(select 1 from #T where Name=a.Name and ID>a.ID)
 
方法2:
delete a  from #T a left join (select max(ID)ID,Name from #T group by Name) b on a.Name=b.Name and a.ID=b.ID where b.Id is null
 
方法3:
delete a from #T a where ID not in (select max(ID) from #T where Name=a.Name)
 
方法4(注:ID为唯一时可用):
delete a from #T a where ID not in(select max(ID)from #T group by Name)
 
方法5:
delete a from #T a where (select count(1) from #T where Name=a.Name and ID>a.ID)>0
 
方法6:
delete a from #T a where ID<>(select top 1 ID from #T where Name=a.name order by ID desc)
 
方法7:
delete a from #T a where ID<any(select ID from #T where Name=a.Name)
 
 
select * from #T
/*
ID          Name Memo
----------- ---- ----
3           A    A3
5           B    B2
 
(2 行受影响)
*/





第一步：查询重复记录
[sql] view plain copy
SELECT * FROM TableName  
WHERE RepeatFiled IN (  
    SELECT RepeatFiled  
    FROM TableName  
    GROUP BY RepeatFiled  
    HAVING COUNT(RepeatFiled) > 1  
)  

这一段逻辑很简单，就是把重复条数大于1的全部都搞出来就行了。
第二步：删除重复记录，只保留一条
[sql] view plain copy
SELECT * FROM TableName  
WHERE RepeatFiled IN (  
    SELECT RepeatFiled  
    FROM TableName  
    GROUP BY RepeatFiled  
    HAVING COUNT(RepeatFiled) > 1  
    AND  
    ID NOT IN (  
        SELECT MIN(ID)  
        FROM TableName  
        GROUP BY RepeatFiled  
        HAVING COUNT(RepeatFiled) > 1      
    )  
)  


去掉重复的UserName
delete Student2 where Id in
(
　select id from (
　select Id, UserName,ROW_NUMBER() over (partition by UserName order by id) orderid from Student2
　)t1
　where t1.orderid>1
)