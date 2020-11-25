--我们在做递归查询的时候，有时候需要查询特定某一级的数据，如果我们的数据上没有标注该数据的层级数，那么我们可以在递归的时候自己加一个，并在读取的时候作为查询条件来用，测试数据：
--SQL SERVER 2005之前的版本可以用函数方法实现，SQL SERVER 2005之后可以利用CTE（公用表表达式Common Table Expression是SQL SERVER 2005版本之后引入的一个特性）的方式来查询。
--递归CTE最少包含两个查询(也被称为成员)。第一个查询为定点成员，定点成员只是一个返回有效表的查询，用于递归的基础或定位点。第二个查询被称为递归成员，使该查询称为递归成员的是对CTE名称的递归引用是触发。在逻辑上可以将CTE名称的内部应用理解为前一个查询的结果集。
--递归查询没有显式的递归终止条件，只有当第二个递归查询返回空结果集或是超出了递归次数的最大限制时才停止递归。是指递归次数上限的方法是使用MAXRECURION。
--Sql递归的优点：效率高，大量数据集下，速度比程序的查询快。


--测试数据  
if not object_id(N'Tempdb..#T') is null
    drop table #T
Go

Create table #T([Id] int,[Name] nvarchar(24),[FatherId] int)  
Insert #T  
select 1,N'河北省',0 union all
select 2,N'陕西省',0 union all
select 3,N'石家庄市',1 union all
select 4,N'桥东区',3 union all
select 5,N'唐山市',1 UNION all
select 6,N'西安市',2 UNION all
select 7,N'雁塔区',6
Go  

--例如我们要读取市一级的数据，查询代码如下：
;WITH cte AS (
SELECT *,1 AS [level] FROM #T WHERE FatherId=0
UNION ALL
SELECT #T.*,cte.level+1 FROM #T JOIN cte ON cte.Id = #T.FatherId
)
SELECT * FROM cte WHERE [level]=1










--测试数据
if not object_id(N'T') is null
	drop table T
Go
Create table T([id] int,[pid] int,[num] int)
Insert T
select 1,0,1 union all
select 2,1,1 union all
select 3,2,1 union all
select 4,2,1 union all
select 5,2,1 union all
select 6,3,1 union all
select 7,3,1
Go

--我们想要向上累积的结果，计算每级的子集集合是多少，函数方式，新建函数：

IF OBJECT_ID('dbo.f_GetChildren') IS NOT NULL
    DROP FUNCTION dbo.f_GetChildren
GO
CREATE FUNCTION f_GetChildren
    (
      @id INT ,
      @pid INT ,
      @num INT
    )
RETURNS @tab TABLE
    (
      [id] INT ,
      [pid] INT ,
      [num] INT
    )
AS
    BEGIN
        INSERT  @tab
                SELECT  @id ,
                        @pid ,
                        @num
        WHILE @@rowcount > 0
            BEGIN               
                INSERT  @tab
                        SELECT  T.id ,
                                T.pid ,
                                T.num
                        FROM    T
                                JOIN @tab t1 ON T.pid = t1.id
                        WHERE   NOT EXISTS ( SELECT *
                                             FROM   @tab
                                             WHERE  T.id = [@tab].id )
            END
        RETURN  
    END
	GO

--调用：

SELECT  id ,
        ( SELECT    SUM(num)
          FROM      f_GetChildren(id, pid, num)
        ) AS sumnum
FROM    T


--利用CTE的方式:

;WITH cte AS (
SELECT *,id AS sumid FROM dbo.T
UNION ALL
SELECT T.*,cte.sumid FROM T JOIN cte ON T.pid=cte.ID
)
SELECT sumid,SUM(num) AS sumnum FROM cte GROUP BY sumid









--数据模拟

select '01' as Code,'北京市' Name,'0' parentCode,1 level union all
select '02' as Code,'河南省' Name,'0' parentCode,1 level union all
select '0101' ,'海淀区','01',2 union all
select '010101' ,'上地','0101',3 union all 
select '010102' ,'清河','0101',3 union all
select '0102' ,'西城区','01',2 union all
select '0103' ,'东城区','01',2 union all
select '0201' ,'安阳市','02',2 union all
select '020101' ,'林州','0201',3 union all 
select '020102' ,'滑县','0201',3 union all
select '0202' ,'落阳市','02',2 

--递归查询北京对应下级数据

with T as
(--模拟测试数据
select '01' as Code,'北京市' Name,'0' parentCode,1 level union all
select '02' as Code,'河南省' Name,'0' parentCode,1 level union all
select '0101' ,'海淀区','01',2 union all
select '010101' ,'上地','0101',3 union all 
select '010102' ,'清河','0101',3 union all
select '0102' ,'西城区','01',2 union all
select '0103' ,'东城区','01',2 union all
select '0201' ,'安阳市','02',2 union all
select '020101' ,'林州','0201',3 union all 
select '020102' ,'滑县','0201',3 union all
select '0202' ,'落阳市','02',2 
)
,A as(--递归方法
select Code,Name,parentCode,level from T where Code='01'
union all
select T.Code,T.Name,T.parentCode,t.level from T 
inner join A on T.parentCode=A.Code 
)
--递归查询北京数据
select * from A ;

--------------------- 
版权声明：本文为CSDN博主「深海蓝山」的原创文章，遵循CC 4.0 by-sa版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/lqh4188/article/details/51955325