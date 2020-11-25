先看看我们要用到的几个目录视图的解释:
1,sys.foreign_keys--在这个视图中返回了所有的外键约束
2,sys.foreign_key_columns--在这个视图中返回了所有外键列(只返回列的id)
3,sys.columns--在这个视图中返回了表与视图的所有列

示例：
比如我们要查询表tb1的所有外键信息，代码如下：
select
a.name as 约束名,
object_name(b.parent_object_id) as 外键表,
d.name as 外键列,
object_name(b.referenced_object_id) as 主健表,
c.name as 主键列
from sys.foreign_keys a
inner join sys.foreign_key_columns b on a.object_id=b.constraint_object_id
inner join sys.columns c on b.parent_object_id=c.object_id and b.parent_column_id=c.column_id 
inner join sys.columns d on b.referenced_object_id=d.object_id and b.referenced_column_id=d.column_id 
where object_name(b.referenced_object_id)='tb1';

set xact_abort on
begin tran
declare @sql nvarchar(128)
declare cur_fk cursor local for
select 'alter table '+obj.name+' nocheck constraint '+fk.name as cmd
from sys.foreign_keys  fk  join  sys.all_objects  obj  on(fk.parent_object_id=obj.object_id)
where object_name(fk.referenced_object_id)='tb_points'
--删除所有外键
open cur_fk
fetch cur_fk into @sql
while @@fetch_status = 0
begin
  print @sql
  exec(@sql)
  fetch cur_fk into @sql
end
close cur_fk
deallocate cur_fk
commit tran



SQL Server 批量 停用/启用 外键约束
今天百度知道上面,看到这样一个要求:

现在有一个库,有很多张表
想要删除一张表的记录的时候,由于外键关联太多,
所以,没法删除相应的记录,
谁能帮忙写个存储过程,就是先删除所有表的主,外键,
然后进行删除表记录,然后再恢复之前所有的主外键.


一眼看上去，需要批量删除所有外键，并不困难。
但是要求批量所有外键之后，
一切处理完毕后，还要把外键重建回来。
这个有点复杂了。

心想，如果删除之后，还要重建的。
那还不如一开始就不删除，只是暂时 “不可用”。
等一系列的操作执行完毕后，
再把这些前面暂时 “不可用” 的外键  “恢复使用”

 

首先生成 停用 外键的SQL语句

select 'alter table '+obj.name+' nocheck constraint '+fk.name+';'  as  sql
from sys.foreign_keys  fk  join  sys.all_objects  obj  on(fk.parent_object_id=obj.object_id)
where object_name(fk.referenced_object_id)='tb_points';

具体会有多少条记录，取决于你的数据库里面，有多少个外键了。
在我的测试数据库里面，只有一个外键。所以我的执行结果为：

ALTER TABLE test_sub NOCHECK CONSTRAINT main_id_cons;

把所有的执行结果，都去执行一遍， 就可以将所有的 外键约束停用。
下面是执行的测试：

1> delete  from test_main
2> go
消息 547，级别 16，状态 1，服务器 GMJ-PC\SQLEXPRESS，第 1 行
DELETE 语句与 REFERENCE 约束"main_id_cons"冲突。该冲突发生于数据库"Test"，表"dbo
.test_sub", column 'main_id'。
语句已终止。
1>ALTER TABLE test_sub NOCHECK CONSTRAINT main_id_cons;
2> go
1> delete from test_main
2> go

(2 行受影响)
1> delete from test_sub
2> go

(2 行受影响)

数据清理完毕后，恢复外键

select 'alter table '+obj.name+' check constraint '+fk.name+';'  as  sql
from sys.foreign_keys  fk  join  sys.all_objects  obj  on(fk.parent_object_id=obj.object_id)
where object_name(fk.referenced_object_id)='tb_points';


我的执行结果为：

ALTER TABLE test_sub CHECK CONSTRAINT main_id_cons;

测试外键约束是否启用了

 

1> ALTER TABLE test_sub CHECK CONSTRAINT main_id_cons;
2> go
1> INSERT INTO test_sub VALUES (1, 2 , 'A');
2> go
消息 547，级别 16，状态 1，服务器 GMJ-PC\SQLEXPRESS，第 1 行
INSERT 语句与 FOREIGN KEY 约束"main_id_cons"冲突。该冲突发生于数据库"Test"，表"d
bo.test_main", column 'id'。
语句已终止。






SQL批量删除含有外键的表的方法(1)
写法一：

set xact_abort on
begin tran
DECLARE @SQL VARCHAR(99)
DECLARE CUR_FK CURSOR LOCAL FOR
SELECT 'alter table '+ OBJECT_NAME(FKEYID) + ' drop constraint ' + OBJECT_NAME(CONSTID) FROM SYSREFERENCES
--删除所有外键
OPEN CUR_FK
FETCH CUR_FK INTO @SQL
WHILE @@FETCH_STATUS =0
 BEGIN
  EXEC(@SQL)
  FETCH CUR_FK INTO @SQL
 END
CLOSE CUR_FK
DEALLOCATE CUR_FK
-- 删除所有表 
DECLARE CUR_TAB CURSOR LOCAL FOR
SELECT 'DROP TABLE '+ NAME FROM SYSOBJECTS WHERE XTYPE='U' -- AND NAME LIKE 'xx%'
OPEN CUR_TAB
FETCH CUR_TAB INTO @SQL
WHILE @@FETCH_STATUS =0
 BEGIN
  EXEC(@SQL)
  FETCH CUR_TAB INTO @SQL
 END
CLOSE CUR_TAB 
DEALLOCATE CUR_TAB
commit tran
写法二

DECLARE @SQL VARCHAR(99),@TBL VARCHAR(30),@FK VARCHAR(30)
DECLARE CUR_FK CURSOR LOCAL FOR
SELECT OBJECT_NAME(CONSTID),OBJECT_NAME(FKEYID) FROM SYSREFERENCES
--删除所有外键
OPEN CUR_FK
FETCH CUR_FK INTO @FK,@TBL
WHILE @@FETCH_STATUS =0
BEGIN
SELECT @SQL='ALTER TABLE '+@TBL+' DROP CONSTRAINT '+@FK
EXEC(@SQL)
FETCH CUR_FK INTO @FK,@TBL
END
CLOSE CUR_FK
DECLARE CUR_FKS CURSOR LOCAL FOR
SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U'
OPEN CUR_FKS
FETCH CUR_FKS INTO @TBL
WHILE @@FETCH_STATUS =0
BEGIN
SELECT @SQL='DROP TABLE ['+@TBL+']'
EXEC(@SQL)
FETCH CUR_FKS INTO @TBL
END
CLOSE CUR_FKS