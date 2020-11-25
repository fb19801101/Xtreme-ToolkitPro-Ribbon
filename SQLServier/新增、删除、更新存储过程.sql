/*功能：自动生成自增字段值的存储过程*/
--if exists(select * from dbo.sysobjects where id = object_id(N'sp_AutoCode') and type = 'P')
if exists(select name from sys.procedures where name = 'sp_AutoCode')
drop procedure sp_AutoCode

go
create procedure sp_AutoCode(@tbl nvarchar(20),@fid nvarchar(20) output,@val varchar(10) output)
as
begin
declare @sql nvarchar(100)
declare @code varchar(10)
declare @deft varchar(14)
declare @size tinyint
select @fid=column_name, @size=character_maximum_length, @deft=column_default from information_schema.columns where table_name=@tbl and ordinal_position=1
set @sql='select @val=max('+@fid+') from '+@tbl
exec sp_executesql @sql, N'@val varchar(10) out', @val output
declare @idx int
if @val is null
begin
set @idx = charindex('''', @deft)+1
set @val = substring(@deft,@idx,@size+@idx)
end
set @idx = patindex('%[0-9]%', @val)-1
set @sql='select top 1 @code='+@fid+' from '+@tbl+' order by '+@fid+' desc'
exec sp_executesql @sql, N'@code varchar(10) out', @code output
if @code is null
  set @val=upper(left(@val,@idx))+right('000000000'+cast(1 as varchar),@size-@idx)
else
  set @val=upper(left(@val,@idx))+right('000000000'+cast(convert(bigint,right(@code,@size-@idx))+1 as varchar),@size-@idx)
end

go
if exists(select name from sys.procedures where name = 'sp_ExistsTable')
drop procedure sp_ExistsTable

go
create procedure sp_ExistsTable(@tbl nvarchar(20),@ret bit output)
as
begin
if exists(select name from sysObjects where Name = @tbl And Type In ('V','U'))
--if object_id(@tbl, N'U') is not null
  set @ret = 1
else
  set @ret = 0
end

go
if exists(select name from sys.procedures where name = 'sp_CopyTable')
drop procedure sp_CopyTable

go
create procedure sp_CopyTable(@tblOld nvarchar(30),@tblNew nvarchar(30),@ret bit output)
as
begin
declare @sql nvarchar(1000)
if exists(select name from sysObjects where Name = @tblNew And Type In ('V','U'))
  begin
	  set @sql='delete '+@tblNew
	  exec @ret = sp_executesql @sql
	  set @sql=' insert into '+@tblNew+' select * from '+@tblOld
	  exec @ret = sp_executesql @sql
  end
else
	begin
	  set @sql='select * into '+@tblNew+' from  '+@tblOld
	  exec @ret =sp_executesql @sql
  end
end

go
if exists(select name from sys.procedures where name = 'sp_SumTable')
drop procedure sp_SumTable

go
create procedure sp_SumTable(@tbl nvarchar(20), @fid nvarchar(20), @val float output)
as
begin
declare @sql nvarchar(100)
set @sql='select @val=sum('+@fid+') from '+@tbl
exec sp_executesql @sql, N'@val float output', @val output
end

go
if exists(select name from sys.procedures where name = 'sp_GetFieldName')
drop procedure sp_GetFieldName

go
create procedure sp_GetFieldName(@tbl nvarchar(20),@idx integer,@fid nvarchar(20) output)
as
begin
declare @sql nvarchar(100)
set @sql='select @fid=name from syscolumns where id=object_id(@tbl) and colid=@idx'
exec sp_executesql @sql, N'@fid nvarchar(20) output,@tbl nvarchar(20),@idx integer', @fid output,@tbl,@idx
end

go
declare @tbl nvarchar(20)
declare @fid nvarchar(20)
declare @val varchar(10)
set @tbl='tv_outstock' 
exec sp_AutoCode @tbl,@fid output,@val output
print @fid
print @val

go
declare @tbl nvarchar(20)
declare @ret bit
set @tbl='tb_units' 
exec sp_ExistsTable @tbl,@ret output
print @ret


go
declare @tbl nvarchar(20)
declare @fid nvarchar(20)
declare @idx integer
set @tbl='tb_units' 
set @idx =3
exec sp_GetFieldName @tbl,@idx,@fid output
print @fid

go
declare @sql nvarchar(100)
declare @tbl nvarchar(20)
declare @val varchar(20) 
declare @fid nvarchar(10) 
set @tbl='tb_units' 
select @fid=column_name from information_schema.columns where table_name=@tbl and ordinal_position=1
set @sql='select @val=max('+@fid+') from '+@tbl
exec sp_executesql @sql, N'@val varchar(10) out', @val out
print @val

go
if exists(select name from sys.procedures where name = 'sp_CountField')
drop procedure sp_CountField

go
create procedure sp_CountField(@tbl nvarchar(20), @fid nvarchar(20), @cond1 nvarchar(20), @cond2 nvarchar(20), @val bigint output)
as
begin
declare @sql nvarchar(200)
if len(@cond2) = 0
	set @sql='select @val=count('+@fid+') from '+@tbl+' where '+@fid+@cond1
else
	set @sql='select @val=count('+@fid+') from '+@tbl+' where '+@fid+@cond1+' and '+@fid+@cond2
print @sql
exec sp_executesql @sql, N'@val bigint output', @val output
end

go
declare @tbl nvarchar(20)
declare @fid nvarchar(20)
declare @cond1 nvarchar(20)
declare @cond2 nvarchar(20)
declare @val bigint
set @tbl='tb_retest_orbit'
set @fid='ro_left_vertical' 
set @cond1='>=3'
set @cond2='<=4'
exec sp_CountField @tbl,@fid,@cond1,@cond2,@val output
print @val

go
if exists(select name from sys.procedures where name = 'sp_budget_rep')
drop procedure sp_budget_rep

go
create procedure sp_budget_rep
as
begin
	delete from tb_budget_rep
	insert into tb_budget_rep(bg_id,ct_id,gd_code,gd_name,gd_unit,gd_rate,gd_qty,gd_price,gd_money,bg_info)
	select * from tb_budget

	update A set A.gd_code=B.gd_code,A.gd_label=B.gd_label,A.gd_name=B.gd_name,A.gd_unit=B.gd_unit,A.gd_rate=B.gd_rate,
	A.gd_qty=A.gd_qty*B.gd_rate,A.gd_price=B.gd_price,A.gd_money=A.gd_qty*B.gd_rate*B.gd_price
	from tb_budget_rep A
	right join tb_guidance B on A.gd_code=B.gd_code

	update A set A.qy_budget=C.qy_budget,
	A.qy_dwg_design=C.qy_dwg_design,A.qy_dwg_change=C.qy_dwg_change,
	A.qy_chk_design=C.qy_chk_design,A.qy_chk_change=C.qy_chk_change,
	A.qy_act_design=C.qy_act_design,A.qy_act_change=C.qy_act_change
	from tb_budget_rep A
	right join tb_quantity_sum C on A.bg_id=C.bg_id

	update A set A.qy_do_design=D.qy_do_design,A.qy_do_change=D.qy_do_change,
	A.qy_up_design=D.qy_up_design,A.qy_up_change=D.qy_up_change,
	A.qy_down_design=D.qy_down_design,A.qy_down_change=D.qy_down_change
	from tb_budget_rep A
	right join tp_quantity_sum D on A.bg_id=D.bg_id
end


go
create procedure sp_quantity_sum
as
begin
	delete from tb_quantity_sum
	insert into tb_quantity_sum(qy_id,pi_id,lb_id,ct_id,bg_id,qy_date,qy_name,qy_unit,qy_do_design,qy_do_change,qy_up_design,qy_up_change,qy_down_design,qy_down_change,qy_info)
	select * from tp_quantity_sum

	update A set
	A.qy_budget=B.bg_qty from tb_quantity_sum A
	left join tb_budget B on A.ct_id=B.ct_id

	update A set
	A.qy_do_design=B.qy_do_design,A.qy_do_change=B.qy_do_change,
	A.qy_up_design=B.qy_up_design,A.qy_up_change=B.qy_up_change,
	A.qy_down_design=B.qy_down_design,A.qy_down_change=B.qy_down_change from tb_quantity_sum A
	left join tp_quantity_sum B on A.pi_id=B.pi_id and A.bg_id=B.bg_id
end

go
create procedure sp_sys_quantity_sum
as
begin
	delete from tb_sys_quantity_sum
	insert into tb_sys_quantity_sum(sqy_id,spi_id,lb_id,sct_id,sbg_id,sqy_date,sqy_name,sqy_unit,sqy_do_design,sqy_do_change,sqy_up_design,sqy_up_change,sqy_down_design,sqy_down_change,sqy_info)
	select * from tp_sys_quantity_sum

	update A set
	A.sqy_budget=B.ct_qty from tb_sys_quantity_sum A
	left join tb_contract B on A.sct_id=B.ct_id

	update A set
	A.sqy_do_design=B.sqy_do_design,A.sqy_do_change=B.sqy_do_change,
	A.sqy_up_design=B.sqy_up_design,A.sqy_up_change=B.sqy_up_change,
	A.sqy_down_design=B.sqy_down_design,A.sqy_down_change=B.sqy_down_change from tb_sys_quantity_sum A
	left join tp_sys_quantity_sum B on A.spi_id=B.spi_id and A.sbg_id=B.sbg_id
end

go
create procedure sp_ResetIdent(@tbl nvarchar(20), @seed int, @ret bit output)
as
begin
if exists(select name from sysObjects where Name = @tbl And Type In ('V','U'))
  begin
    dbcc checkident (@tbl, reseed, @seed)
    set @ret = 1
  end
else
  set @ret = 0
end

go
if exists(select name from sys.procedures where name = 'sp_AddColumn')
drop procedure sp_AddColumn

go
create procedure sp_AddColumn(@tablename varchar(30), @colname varchar(30), @coltype varchar(100), @colid int)
as
begin
declare @colid_max int
declare @sql varchar(1000) --动态sql语句
--------------------------------------------------
if not exists(select  1 from sysobjects where name = @tablename and xtype = 'u')
  begin
  raiserror( '没有这个表！',2001,1)
  return -1
  end
--------------------------------------------------
if exists(select 1 from syscolumns where id = object_id(@tablename) and name = @colname)
  begin
  raiserror( '这个表已经有这个列了！',2002,1)
  return -1
  end
--------------------------------------------------
--保证该表的colid是连续的
select @colid_max = max(colid) from syscolumns where id=object_id(@tablename)

if @colid > @colid_max or @colid < 1
   set @colid = @colid + 1
--------------------------------------------------
set @sql = 'alter table '+@tablename+' add '+@colname+' '+@coltype 
exec(@sql)

select @colid_max = colid 
from syscolumns where id = object_id(@tablename) and name = @colname
if @@rowcount <> 1
  begin
  raiserror( '加一个新列不成功，请检查你的列类型是否正确！',2003,1)
  return -1
  end
--------------------------------------------------
--打开修改系统表的开关
exec sp_configure 'allow updates',1  reconfigure with override

--将新列列号暂置为-1
set @sql = 'update syscolumns set colid = -1 where id = object_id('''+@tablename+''') 
            and colid = '+cast(@colid_max as varchar(10))
exec(@sql)

--将其他列的列号加1
set @sql = 'update syscolumns set colid = colid + 1 where id = object_id('''+@tablename+''') 
            and colid >= '+cast(@colid as varchar(10))
exec(@sql)

--将新列列号复位
set @sql = 'update syscolumns set colid = '+cast(@colid as varchar(10))+' where id = object_id('''+@tablename+''') 
            and name = '''+@colname +''''
exec(@sql)
--------------------------------------------------
--关闭修改系统表的开关
exec sp_configure 'allow updates',0  reconfigure with override
end


--调用方法：
--exec addcolumn '表名','新列名','新列类型',加到第几个位置
exec addcolumn 'test','id2','char(10)',2

/*
对象类型：

AF = 聚合函数 (CLR)

C = CHECK 约束

D = DEFAULT（约束或独立）

F = FOREIGN KEY 约束

PK = PRIMARY KEY 约束

P = SQL 存储过程

PC = 程序集 (CLR) 存储过程

FN = SQL 标量函数

FS = 程序集 (CLR) 标量函数

FT = 程序集 (CLR) 表值函数

R = 规则（旧式，独立）

RF = 复制筛选过程

SN = 同义词

SQ = 服务队列

TA = 程序集 (CLR) DML 触发器

TR = SQL DML 触发器

IF = SQL 内联表值函数

TF = SQL 表值函数

U = 表（用户定义类型）

UQ = UNIQUE 约束

V = 视图

X = 扩展存储过程

IT = 内部表

--1、查看所有存储过程与函数 
     exec sp_stored_procedures 
    或者 
     select * from dbo.sysobjects where OBJECTPROPERTY(id, N'IsProcedure') = 1 order by name 
--2、查看存储过程的内容    
   select text from syscomments where id=object_id('存储过程名称') 
   -- 或者用 
   sp_helptext  存储过程名称

--3、查看存储过程的参数情况 
   select '参数名称' = name, 
         '类型' = type_name(xusertype), 
         '长度' = length,    
         '参数顺序' = colid, 
         '排序方式' = collation 
   from    syscolumns 
   where   id=object_id('存储过程名称')

   --或者

   --查看存储过程参数信息：   
--如果返回值>1，则有参数。否则无   
CREATE   PROC sp_PROC_Params 
       @procedure_name sysname  ,  --存储过程或者用户定义函数名   
       @group_number int=1     ,   --存储过程的组号,必须在0到32767之间,0表示显示该存储过程组的所有参数   
       @operator nchar(2)=N'='     --查找对象的运算符   
AS 
SET   NOCOUNT ON   
DECLARE @SQL nvarchar(4000)   
SET @SQL=N'SELECT   
  PorcedureName=CASE     
  WHEN   o.xtype   IN(''P'',''X'')   
  THEN   QUOTENAME(o.name)+N'';''+CAST(c.number   as   varchar)   
  WHEN   USER_NAME(o.uid)=''system_function_schema''   
  AND   o.xtype=''FN''   
  THEN   o.name   
  WHEN     USER_NAME(o.uid)=''system_function_schema''   
  THEN   ''::''+o.name   
  WHEN   o.xtype=''FN''   
  THEN   QUOTENAME(USER_NAME(o.uid))+N''.''+QUOTENAME(o.name)   
  ELSE   QUOTENAME(o.name)   END,   
  Owner=USER_NAME(o.uid),   
  GroupNumber=c.number,   
  ParamId=c.colid,   
  ParamName=CASE     
  WHEN   o.xtype=''FN''   AND   c.colid=0   THEN   ''<Returns>''   
  ELSE   c.name   END,   
  Type=QUOTENAME(t.name)+CASE     
  WHEN   t.name   IN   (''decimal'',''numeric'')   
  THEN   N''(''+CAST(c.prec   as   varchar)+N'',''+CAST(c.scale   as   varchar)+N'')''   
  WHEN   t.name=N''float''   
  OR   t.name   like   ''%char''   
  OR   t.name   like   ''%binary''   
  THEN   N''(''+CAST(c.prec   as   varchar)+N'')''   
  ELSE   ''''   END,   
  Orientation=CASE     
  WHEN   o.xtype=''FN''   AND   c.colid=0   THEN   ''<Returns>''   
  ELSE   N''Input''   
  +CASE   WHEN   c.isoutparam=1   THEN   ''/Output''   ELSE   ''''   END   
  END   
  FROM   sysobjects   o,syscolumns   c,systypes   t   
  WHERE   o.id=c.id   
  AND   c.xusertype=t.xusertype   
  AND   o.name' 
    +CASE WHEN @operator IN ('=','>','>=','!>','<','<=','!<','<>','!=') 
          THEN @operator+QUOTENAME(@procedure_name,'''') 
          WHEN @operator='IN' 
          THEN @operator+N'   IN('+QUOTENAME(@procedure_name,'''')+')' 
          WHEN @operator IN ('LIKE','%') 
          THEN '   LIKE   '+QUOTENAME(@procedure_name,'''') 
          ELSE '='+QUOTENAME(@procedure_name,'''') 
     END+N'     
  AND(('+CASE WHEN @group_number BETWEEN 1 AND 32767 
              THEN N'c.number='+CAST(@group_number as varchar) 
              WHEN @group_number=0 THEN N'1=1' 
              ELSE N'c.number=1' 
         END+N'   AND   o.xtype   IN(''P'',''X''))     
  OR   (c.number=0   AND   o.xtype=''FN'')   
  OR   (c.number=1   AND   o.xtype   IN(''IF'',''TF'')))'   
EXEC sp_executesql @SQL  

--4、查看所有存储过程内容 
   select   b.name   ,a.text   from   syscomments   a,sysobjects   b   where   object_id(b.name)=a.id   and   b.xtype   in('P','TR') 

--5、查看包含字符串内容的存储过程 

select   b.name   ,a.text   from   syscomments   a,sysobjects   b 
where 
charindex('字符串内容',a.text)>0    and 
object_id(b.name)=a.id   and   b.xtype   in('P','TR')
*/