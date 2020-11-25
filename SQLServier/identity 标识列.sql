-- 使用sql语句创建修改SQL Server标识列(即自动增长列)

-- 一、标识列的定义以及特点
-- SQL Server中的标识列又称标识符列,习惯上又叫自增列。
-- 该种列具有以下三种特点：
-- 1、列的数据类型为不带小数的数值类型
-- 2、在进行插入(Insert)操作时，该列的值是由系统按一定规律生成,不允许空值
-- 3、列值不重复，具有标识表中每一行的作用,每个表只能有一个标识列。
-- 由于以上特点，使得标识列在数据库的设计中得到广泛的使用。

-- 二、标识列的组成
-- 创建一个标识列，通常要指定三个内容:
-- 1、类型（type）
-- 在SQL Server 2000中，标识列类型必须是数值类型，如下：
-- decimal、int、numeric、smallint、bigint 、tinyint 
-- 其中要注意的是，当选择decimal和numeric时，小数位数必须为零
-- 另外还要注意每种数据类型所有表示的数值范围
-- 2、种子(seed)
-- 是指派给表中第一行的值,默认为1
-- 3、递增量(increment)
-- 相邻两个标识值之间的增量，默认为1。

-- 三、标识列的创建与修改
-- 标识列的创建与修改，通常在企业管理器和用Transact-SQL语句都可实现，使用企业管理管理器比较简单，请参考SQL Server的联机帮助，这
-- 里只讨论使用Transact-SQL的方法
-- 1、创建表时指定标识列
-- 标识列可用 IDENTITY 属性建立，因此在SQL Server中，又称标识列为具有IDENTITY属性的列或IDENTITY列。
-- 下面的例子创建一个包含名为ID,类型为int,种子为1，递增量为1的标识列
   CREATE TABLE T_test
   (ID int IDENTITY(1,1),
   Name varchar(50)
   )
-- 2、在现有表中添加标识列
-- 下面的例子向表T_test中添加一个名为ID,类型为int,种子为1，递增量为1的标识列
   --创建表
   CREATE TABLE T_test
   (Name varchar(50)
   )
   --插入数据
   INSERT T_test(Name) VALUES('张三')
   --增加标识列
   ALTER TABLE T_test
   ADD ID int IDENTITY(1,1)
-- 3、判段一个表是否具有标识列
-- 可以使用 OBJECTPROPERTY 函数确定一个表是否具有 IDENTITY（标识）列,用法:
   Select OBJECTPROPERTY(OBJECT_ID('表名'),'TableHasIdentity')
-- 如果有，则返回1,否则返回0
-- 4、判断某列是否是标识列
-- 可使用 COLUMNPROPERTY 函数确定 某列是否具有IDENTITY 属性,用法
   SELECT COLUMNPROPERTY( OBJECT_ID('表名'),'列名','IsIdentity')
-- 如果该列为标识列，则返回1,否则返回0
-- 4、查询某表标识列的列名
   SQL Server中没有现成的函数实现此功能，实现的SQL语句如下
   SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.columns
   WHERE TABLE_NAME='表名' AND COLUMNPROPERTY( 
   OBJECT_ID('表名'),COLUMN_NAME,'IsIdentity')=1
-- 5、标识列的引用
-- 如果在SQL语句中引用标识列，可用关键字IDENTITYCOL代替
-- 例如，若要查询上例中ID等于1的行，
-- 以下两条查询语句是等价的
   SELECT * FROM T_test WHERE IDENTITYCOL=1
   SELECT * FROM T_test WHERE ID=1
-- 6、获取标识列的种子值
-- 可使用函数IDENT_SEED,用法：
   SELECT IDENT_SEED ('表名')
-- 7、获取标识列的递增量
-- 可使用函数IDENT_INCR ,用法：
   SELECT IDENT_INCR('表名')
-- 8、获取指定表中最后生成的标识值
-- 可使用函数IDENT_CURRENT，用法:
   SELECT IDENT_CURRENT('表名') 
-- 注意事项：当包含标识列的表刚刚创建,为经过任何插入操作时，使用IDENT_CURRENT函数得到的值为标识列的种子值，这一点在开发数据库应用程序的时候尤其应该注意。


----------------

--利用 SQL 语句修改出一个标识列使用sql语句创建修改SQL <wbr>Server标识列(即自动增长列)
--将数据复制到临时表
select * into #aclist from aclist

--删除数据表
drop table aclist

--创建数据表（并设置标识列）
create table aclist(id int identity(1,1),[date] datetime,version nvarchar(6),[class] nvarchar(10),actitle nvarchar(50),acdetail nvarchar(max),author nvarchar(50))

--设置标识列允许插入
set identity_insert aclist on

--将数据从临时表转移过来
insert into aclist(id,[date],version,[class],actitle,acdetail,author)
select id,[date],version,[class],actitle,acdetail,author from #aclist

--关闭标识列插入
set identity_insert aclist off

--强制设置标识列的起始值:
DBCC CHECKIDENT (表名, RESEED, 1) --强制使标识值从1开始.


----------------

--修改原有字段中，不删除表，直接修改表中字段，删除数据后，处理。

--创建没有自动增长的数据表
CREATE TABLE [tbMessage](
[id] [decimal](18, 0),
[msg_content] [varchar](max) NULL
) ON [PRIMARY]

GO
--插入测试数据
insert into [tbMessage]([id],[msg_content])
values(20,'你知道吗？')

insert into [tbMessage]([id],[msg_content])
values(21,'你知道吗？201')
go
--查看数据
--select * from tbMessage

--插入临时表
select * into #tbMessage from [tbMessage]
go
--删除表数据
delete [tbMessage]
go

--删除字段ID
alter table [tbMessage] drop column [ID]
--增加ID自动增长字段
alter table [tbMessage] add [id] int identity(1,1)
set identity_insert [tbMessage] on

--将数据从临时表转移过来

insert into [tbMessage]([msg_content],[id])
select [msg_content],[id] from #tbMessage

--关闭标识列插入
set identity_insert [tbMessage] off

---删除临时表
drop table #tbMessage

--------------------------------------------------
/*
drop table tbMessage
---------------检测自动增长字段是否正常----------
----获取种子数据
SELECT IDENT_SEED ('[tbMessage]')

---drop table tbMessage
---插入二条数据

insert into [tbMessage]([msg_content])
values('你知道吗20111')

insert into [tbMessage]([msg_content])
values('你知道吗20112')

---查看这个ID是否,正常增长
select * from tbMessage
*/

--查询当前的标识列值：
SELECT IDENT_CURRENT('dbo.StayPushShipping') 
SELECT IDENT_INCR('dbo.StayPushShipping')
SELECT IDENT_SEED ('dbo.StayPushShipping')

--对于普通的表，用TRUNCATE TABLE
TRUNCATE TABLE name  --可以删除表内所有值并重置标识值 ，但是表内的数据将丢失。

--对于配置了复制的表，先用DELETE删掉数据后，再DBCC CHECKIDENT
DBCC CHECKIDENT ('dbo.StayPushShipping', RESEED,1)

-- 你想要重置标识值（不删除数据）采用下面方法即可：但是存在问题：
-- 1)DBCC CHECKIDENT ('表名', RESEED,new_value)(重置新的标识值，new_value为新值)
-- 2)问题：如dbcc checkident ('表名',reseed,1)即可，但如果表内有数据，则重设的值如果小于当前表
--   的标识最大值，再插入数据时未指定插入的标识值，这样会导致标识冲突问题，如果你的标识设置成自
--   增的。此外，你也可以用 dbcc checkident('表名',reseed)，即可自动重设值，最后生成值。