--���������ݹ��ѯ��ʱ����ʱ����Ҫ��ѯ�ض�ĳһ�������ݣ�������ǵ�������û�б�ע�����ݵĲ㼶������ô���ǿ����ڵݹ��ʱ���Լ���һ�������ڶ�ȡ��ʱ����Ϊ��ѯ�������ã��������ݣ�
--SQL SERVER 2005֮ǰ�İ汾�����ú�������ʵ�֣�SQL SERVER 2005֮���������CTE�����ñ���ʽCommon Table Expression��SQL SERVER 2005�汾֮�������һ�����ԣ��ķ�ʽ����ѯ��
--�ݹ�CTE���ٰ���������ѯ(Ҳ����Ϊ��Ա)����һ����ѯΪ�����Ա�������Աֻ��һ��������Ч��Ĳ�ѯ�����ڵݹ�Ļ�����λ�㡣�ڶ�����ѯ����Ϊ�ݹ��Ա��ʹ�ò�ѯ��Ϊ�ݹ��Ա���Ƕ�CTE���Ƶĵݹ������Ǵ��������߼��Ͽ��Խ�CTE���Ƶ��ڲ�Ӧ�����Ϊǰһ����ѯ�Ľ������
--�ݹ��ѯû����ʽ�ĵݹ���ֹ������ֻ�е��ڶ����ݹ��ѯ���ؿս�������ǳ����˵ݹ�������������ʱ��ֹͣ�ݹ顣��ָ�ݹ�������޵ķ�����ʹ��MAXRECURION��
--Sql�ݹ���ŵ㣺Ч�ʸߣ��������ݼ��£��ٶȱȳ���Ĳ�ѯ�졣


--��������  
if not object_id(N'Tempdb..#T') is null
    drop table #T
Go

Create table #T([Id] int,[Name] nvarchar(24),[FatherId] int)  
Insert #T  
select 1,N'�ӱ�ʡ',0 union all
select 2,N'����ʡ',0 union all
select 3,N'ʯ��ׯ��',1 union all
select 4,N'�Ŷ���',3 union all
select 5,N'��ɽ��',1 UNION all
select 6,N'������',2 UNION all
select 7,N'������',6
Go  

--��������Ҫ��ȡ��һ�������ݣ���ѯ�������£�
;WITH cte AS (
SELECT *,1 AS [level] FROM #T WHERE FatherId=0
UNION ALL
SELECT #T.*,cte.level+1 FROM #T JOIN cte ON cte.Id = #T.FatherId
)
SELECT * FROM cte WHERE [level]=1










--��������
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

--������Ҫ�����ۻ��Ľ��������ÿ�����Ӽ������Ƕ��٣�������ʽ���½�������

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

--���ã�

SELECT  id ,
        ( SELECT    SUM(num)
          FROM      f_GetChildren(id, pid, num)
        ) AS sumnum
FROM    T


--����CTE�ķ�ʽ:

;WITH cte AS (
SELECT *,id AS sumid FROM dbo.T
UNION ALL
SELECT T.*,cte.sumid FROM T JOIN cte ON T.pid=cte.ID
)
SELECT sumid,SUM(num) AS sumnum FROM cte GROUP BY sumid









--����ģ��

select '01' as Code,'������' Name,'0' parentCode,1 level union all
select '02' as Code,'����ʡ' Name,'0' parentCode,1 level union all
select '0101' ,'������','01',2 union all
select '010101' ,'�ϵ�','0101',3 union all 
select '010102' ,'���','0101',3 union all
select '0102' ,'������','01',2 union all
select '0103' ,'������','01',2 union all
select '0201' ,'������','02',2 union all
select '020101' ,'����','0201',3 union all 
select '020102' ,'����','0201',3 union all
select '0202' ,'������','02',2 

--�ݹ��ѯ������Ӧ�¼�����

with T as
(--ģ���������
select '01' as Code,'������' Name,'0' parentCode,1 level union all
select '02' as Code,'����ʡ' Name,'0' parentCode,1 level union all
select '0101' ,'������','01',2 union all
select '010101' ,'�ϵ�','0101',3 union all 
select '010102' ,'���','0101',3 union all
select '0102' ,'������','01',2 union all
select '0103' ,'������','01',2 union all
select '0201' ,'������','02',2 union all
select '020101' ,'����','0201',3 union all 
select '020102' ,'����','0201',3 union all
select '0202' ,'������','02',2 
)
,A as(--�ݹ鷽��
select Code,Name,parentCode,level from T where Code='01'
union all
select T.Code,T.Name,T.parentCode,t.level from T 
inner join A on T.parentCode=A.Code 
)
--�ݹ��ѯ��������
select * from A ;

--------------------- 
��Ȩ����������ΪCSDN���������ɽ����ԭ�����£���ѭCC 4.0 by-sa��ȨЭ�飬ת���븽��ԭ�ĳ������Ӽ���������
ԭ�����ӣ�https://blog.csdn.net/lqh4188/article/details/51955325