USE [master]
GO
/****** Object:  Database [ProjectManage]    Script Date: 2019/12/30 14:11:56 ******/
CREATE DATABASE [ProjectManage]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ProjectManage', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\ProjectManage.mdf' , SIZE = 71680KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'ProjectManage_log', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\ProjectManage_log.ldf' , SIZE = 2876352KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [ProjectManage] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ProjectManage].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ProjectManage] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ProjectManage] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ProjectManage] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ProjectManage] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ProjectManage] SET ARITHABORT OFF 
GO
ALTER DATABASE [ProjectManage] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ProjectManage] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [ProjectManage] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ProjectManage] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ProjectManage] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ProjectManage] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ProjectManage] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ProjectManage] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ProjectManage] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ProjectManage] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ProjectManage] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ProjectManage] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ProjectManage] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ProjectManage] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ProjectManage] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ProjectManage] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ProjectManage] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ProjectManage] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ProjectManage] SET RECOVERY FULL 
GO
ALTER DATABASE [ProjectManage] SET  MULTI_USER 
GO
ALTER DATABASE [ProjectManage] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ProjectManage] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ProjectManage] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ProjectManage] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'ProjectManage', N'ON'
GO
USE [ProjectManage]
GO
/****** Object:  StoredProcedure [dbo].[sp_AddColumn]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_AddColumn](@tablename varchar(30), @colname varchar(30), @coltype varchar(100), @colid int)
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

GO
/****** Object:  StoredProcedure [dbo].[sp_AutoCode]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_AutoCode](@tbl nvarchar(20),@fid nvarchar(20) output,@val varchar(10) output)
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





GO
/****** Object:  StoredProcedure [dbo].[sp_budget_rep]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_budget_rep]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_CopyTable]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_CopyTable](@tblOld nvarchar(30),@tblNew nvarchar(30),@ret bit output)
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

GO
/****** Object:  StoredProcedure [dbo].[sp_CountField]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_CountField](@tbl nvarchar(20), @fid nvarchar(20), @cond1 nvarchar(20), @cond2 nvarchar(20), @val bigint output)
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
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateProcdure]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_CreateProcdure](@TableName nvarchar(50))
as
	begin
	declare @strParameter nvarchar(3000)
	declare @strInsert nvarchar(3000)
	declare @strUpdate nvarchar(3000)
	declare @strDelete nvarchar(500)
	declare @strWhere nvarchar(100)
	declare @strNewID nvarchar(100)
	declare @strSqlProc nvarchar(4000)

	set @strSqlProc='create procedure up_'+@TableName+char(13)+'@intUpdateId int,'
	               +' /* -1 删除 0 修改 1新增 */'
	set @strParameter=''
	set @strInsert=''
	set @strUpdate=''
	set @strWhere=''

	declare @TName nvarchar(50),@TypeName nvarchar(50),@TypeLength nvarchar(50),@Colstat bit
	declare Obj_Cursor cursor for select * from fn_GetObjectInfo(@TableName)
	open Obj_Cursor
	fetch next from Obj_Cursor into @TName,@TypeName,@TypeLength,@Colstat

	while @@fetch_status=0
	begin
		--构造存储过程参数部分
		set @strParameter=@strParameter +char(13)+'@'+ @TName + ' ' +@TypeName+','

		--构造新增数据部分
		if @Colstat=0 set @strInsert=@strInsert + '@'+ @TName +','

		--构造更新数据部分
		if (@strWhere='')
			begin
				set @strNewID='set @'+@TName+'=(select isnull(max('+@TName+'),0) from '+@TableName+')+1'

				--取新的ID
				set @strWhere=' where '+@TName+'='+'@'+@TName
			end
		else
			set @strUpdate=@strUpdate+@TName+'='+'@'+@TName +','
			--构造删除数据部分
			fetch next from Obj_Cursor into @TName,@TypeName,@TypeLength,@Colstat
	end

	close Obj_Cursor
	
	deallocate Obj_Cursor
	set @strParameter=left(@strParameter,len(@strParameter)-1) --去掉最右边的逗号
	set @strUpdate=left(@strUpdate,len(@strUpdate)-1)
	set @strInsert=left(@strInsert,len(@strInsert)-1)

	--存储过程名、参数
	print @strSqlProc+@strParameter+char(13)+'as'

	--修改
	print 'if (@intUpdateId=0)'
	print' begin'+char(13)
	print char(9)+'update '+@TableName+' set '+@strUpdate+char(13)+char(9)+@strWhere
	print ' end'

	--增加
	print 'if (@intUpdateId=1)'
	print ' begin'
	print char(9)+@strNewID
	print char(9)+'insert into '+@TableName+' select '+@strInsert
	print ' end'

	--删除
	print 'else'
	print ' begin'
	print char(9)+'delete from '+@TableName +@strWhere
	print ' end'
	print 'go'
end

GO
/****** Object:  StoredProcedure [dbo].[sp_Data_Backup]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_Data_Backup]
@backup_db_name nvarchar(128), --数据库名字
@filename nvarchar(255),       --路径+文件名字
@ret bit out,                  --执行标志
@flag varchar(20) out          --执行标志
as
declare @sql nvarchar(4000),@parm nvarchar(1000)
if not exists(select * from master..sysdatabases where name=@backup_db_name)
begin
  set @flag='db not exist'  --数据库不存在
  set @ret = 0
  return
end
else
begin
  if right(@filename,1) <> '\' and charindex('\',@filename) <> 0
  begin
    set @parm='@filename varchar(1000)'
    set @sql='backup database '+@backup_db_name+' to disk= @filename with init'
  	execute sp_executesql @sql,@parm,@filename
    set @flag='ok'
	set @ret = 1
    return
  end
  else
  begin
    set @flag='file type error'  --参数@filename输入格式错误
	set @ret = 0
    return
  end
end




GO
/****** Object:  StoredProcedure [dbo].[sp_Data_Clear]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_Data_Clear]
as
begin transaction --开始一个事务
  declare @tbl nvarchar(128)
  declare cur_clear cursor for select rtrim(name) from sysobjects where type = 'U' order by crdate desc
  open cur_clear
  declare @sql nvarchar(255)
  fetch next from cur_clear into @tbl
  while(@@fetch_status = 0)
  begin
    set @sql = 'delete from '+@tbl
    exec(@sql)
    if(ident_seed(@tbl) is not null)
    begin
      dbcc checkident(@tbl, reseed, 0)  --主键自增列重新设置种子值
    end
    fetch next from cur_clear into @tbl
  end
  close cur_clear
  deallocate cur_clear
commit transaction --结束一个事务

GO
/****** Object:  StoredProcedure [dbo].[sp_Data_Restore]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*恢复数据库*/
CREATE procedure [dbo].[sp_Data_Restore]    
@restore_db_name nvarchar(128),  --要恢复的数据名字
@filename nvarchar(255),         --备份文件存放的路径+备份文件名字
@ret bit out,                    --执行标志
@flag varchar(20) out            --执行标志
as
/*返回系统存储过程xp_cmdshell运行结果*/
declare @proc_result tinyint 
declare @loop_time smallint  --循环次数
/*@tem表的ids列最大数*/
declare @max_ids smallint    
declare @file_bak_path nvarchar(260)  --原数据库存放路径
declare @flag_file bit   --文件存放标志
/*数据库master文件路径*/
declare @master_path nvarchar(260)  
declare @sql nvarchar(4000),@parm nvarchar(1000)
declare @sql_sub nvarchar(4000)
declare @sql_cmd nvarchar(100) 
declare @sql_kill nvarchar(100) 

/*判断参数@filename文件格式合法性，以防止用户输入类似d: 或者 c:a 等非法文件名
参数@filename里面必须有''''并且不以''''结尾*/
if right(@filename,1)<>'\' and charindex('\',@filename)<>0
begin 
  set @sql_cmd='dir '+@filename
  exec @proc_result = master..xp_cmdshell @sql_cmd,no_output

  /*系统存储过程xp_cmdshell返回代码值:0(成功）或1（失败）*/
  if (@proc_result<>0)  
  begin
    /*备份文件不存在*/
    set @flag='not exist'   
    /*退出过程*/
	set @ret = 0
    return
  end

  /*创建临时表,保存由备份集内包含的数据库和日志文件列表组成的结果集*/
  create table #temp_backup(
	LogicalName nvarchar(128) null,         --文件逻辑名称
    PhysicalName nvarchar(260) null,        --文件的物理名称或操作系统名称
    Type char(1) null,                      --文件的类型，其中包括：L = MicrosoftSQL Server日志文件 ;D = SQL Server data file ;F = 全文目录 ;S = FileStream、 FileTable，或内存中 OLTP容器
    FileGroupName nvarchar(128) null,       --包含文件的文件组的名称
    Size bigint null ,                      --当前大小（以字节为单位）
    MaxSize Bigint null,                    --允许的最大大小（以字节为单位）
    FileId bigint,						    --文件标识符，在数据库中唯一
    CreateLSN numeric(25,0),			    --创建文件时的日志序列号
    DropLSN numeric(25,0) NULL,			    --该文件已删除的日志序列号。 如果文件尚未删除，该值为 NULL
    UniqueID uniqueidentifier,			    --文件的全局唯一标识符
    ReadOnlyLSN numeric(25,0) NULL,		    --包含该文件的文件组从读写属性更改为只读属性（最新更改）时的日志序列号										    
    ReadWriteLSN numeric(25,0) NULL,	    --包含该文件的文件组从只读属性更改为读写属性（最新更改）时的日志序列号
    BackupSizeInBytes bigint,               --此文件的备份的大小（字节）
    SourceBlockSize int,					--包含文件的物理设备（并非备份设备）的块大小（以字节为单位）
    FileGroupID int,						--文件组的 ID
    LogGroupGUID uniqueidentifier NULL,		--NULL
    DifferentialBaseLSN numeric(25,0) NULL,	--差异备份，更改日志序列号大于或等于DifferentialBaseLSN纳入差异,对于其他备份类型，该值为 NULLL
    DifferentialBaseGUID uniqueidentifier,	--对于差异备份，该值是差异基准的唯一标识符,对于其他备份类型，该值为 NULL
    IsReadOnly bit,							--1 = 文件是只读的
    IsPresent BIT,							--1 = 的文件是否存在备份中
	TDEThumbprint varbinary(32)				--显示数据库加密密钥的指纹。 加密程序的指纹是带有加密密钥的证书的 SHA-1 哈希。 有关数据库加密的信息，请参阅透明数据加密 (TDE)
  )
  /*创建表变量，表结构与临时表基本一样就是多了两列,
  列ids（自增编号列）,
  列file_path,存放文件的路径*/
  declare @temp_backup table(
     [ids] smallint identity,  --自增编号列
     [LogicalName] nvarchar(128), 
     [PhysicalName] nvarchar(260), 
     [File_path] nvarchar(260), 
     [Type] char(1),
     [FileGroupName] nvarchar(128)
  )
  insert into #temp_backup execute('restore filelistonly from disk='''+@filename+'''')
  /*将临时表导入表变量中,并且计算出相应得路径*/
  insert into @temp_backup(LogicalName,PhysicalName,File_path,Type,FileGroupName)
  select LogicalName,PhysicalName,dbo.fn_GetFilePath ( PhysicalName),Type,FileGroupName from #temp_backup
  if @@rowcount>0
  begin
    drop table #temp_backup
  end
  set @loop_time=1

  /*@tem表的ids列最大数*/
  select @max_ids=max(ids) from @temp_backup
  while @loop_time<=@max_ids
  begin
	select @file_bak_path=file_path from @temp_backup where ids=@loop_time
	set @sql_cmd='dir '+@file_bak_path
	exec @proc_result = master..xp_cmdshell @sql_cmd,no_output
	
	/*系统存储过程xp_cmdshell返回代码值:0(成功）或1（失败）*/
    if (@proc_result<>0) 
    set @loop_time=@loop_time+1  
    else
    /*没有找到备份前数据文件原有存放路径，退出循环*/
    break 
  end
  set @master_path=''
  if @loop_time>@max_ids 
  /*备份前数据文件原有存放路径存在*/
  set @flag_file=1
  else
  begin
    /*备份前数据文件原有存放路径不存在*/
    set @flag_file=0  
    select @master_path=dbo.fn_GetFilePath(filename) from master..sysdatabases where name='master'
  end
  set @sql_sub=''
  /*type='d'是数据文件,type='l'是日志文件 */
  /*@flag_file=1时新的数据库文件还是存放在原来路径，否则存放路径和master数据 库 路径一样*/
  select @sql_sub=@sql_sub+'move ''' +LogicalName+ ''' to '''
  +case type
    when 'd' then case @flag_file
    when 1 then  File_path
    else @master_path
    end
    when 'l' then case  @flag_file
    when 1 then  File_path 
    else @master_path 
    end
  end
  +case type
    when 'd' then LogicalName+'.mdf'','
    when 'l' then LogicalName+'.ldf'','
  end
  from @temp_backup

  set @sql=N'restore database @restore_db_name from disk = @filename with '
  set @sql=@sql+@sql_sub+'replace'
  set @parm=N'@restore_db_name nvarchar(128),@filename nvarchar(260)'
  execute sp_executesql @sql,@parm,@restore_db_name,@filename
  /*关闭相关进程，把相应进程状况导入临时表中*/
  select identity(int,1,1) ids, spid into #temp from master..sysprocesses where dbid=db_id(@restore_db_name)
  /*找到相应进程*/
  if @@rowcount>0
  begin
    select @max_ids=max(ids) from #temp
    set @loop_time=1
    while @loop_time<=@max_ids
    begin
      select @sql_kill='kill '+convert(nvarchar(20),spid) from #temp where ids=@loop_time
      execute sp_executesql @sql_kill
	  set @loop_time=@loop_time+1 
	end
  end
  drop table #temp
  execute sp_executesql @sql,@parm,@restore_db_name,@filename
  /*操作成功*/
  set @flag='ok'
  set @ret = 1
end
else
begin
  /*参数@filename输入格式错误*/
  set @flag='file type error'
  set @ret = 0
end

GO
/****** Object:  StoredProcedure [dbo].[sp_ExistsTable]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_ExistsTable](@tbl nvarchar(20),@ret bit output)
as
begin
if exists(select name from sysObjects where Name = @tbl And Type In ('V','U'))
--if object_id(@tbl, N'U') is not null
  set @ret = 1
else
  set @ret = 0
end



GO
/****** Object:  StoredProcedure [dbo].[sp_GetFieldName]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_GetFieldName](@tbl nvarchar(20),@idx integer,@fid nvarchar(20) output)
as
begin
declare @sql nvarchar(100)
set @sql='select @fid=name from syscolumns where id=object_id(@tbl) and colid=@idx'
exec sp_executesql @sql, N'@fid nvarchar(20) output,@tbl nvarchar(20),@idx integer', @fid output,@tbl,@idx
end



GO
/****** Object:  StoredProcedure [dbo].[sp_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_quantity_sum]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_ResetIdent]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_ResetIdent](@tbl nvarchar(20), @seed int, @ret bit output)
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


GO
/****** Object:  StoredProcedure [dbo].[sp_SumTable]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_SumTable](@tbl nvarchar(20), @fid nvarchar(20), @val float output)
as
begin
declare @sql nvarchar(100)
set @sql='select @val=sum('+@fid+') from '+@tbl
exec sp_executesql @sql, N'@val float output', @val output
end



GO
/****** Object:  StoredProcedure [dbo].[sp_sys_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_sys_contract](@id1 int,@id2 int)
as
begin
SELECT [清单ID]
      ,[清单编码]
      ,[细目名称]
      ,[计价单位]
      ,[工程数量]
      ,[综合单价]
      ,[合价]
  FROM [tv_sys_contract]
  WHERE [节点ID] BETWEEN @id1 AND @id2
end
GO
/****** Object:  StoredProcedure [dbo].[sp_sys_quantity]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_sys_quantity](@id1 int,@id2 int)
as
begin
SELECT [数量ID]
	  ,[清单编码]
      ,[施工日期]
      ,[数量名称]
      ,[计量单位]
      ,[已完设计数量]
      ,[已完变更数量]
      ,[对上计价设计数量]
      ,[对上计价变更数量]
      ,[对下计价设计数量]
      ,[对下计价变更数量]
  FROM [tv_sys_quantity]
  WHERE [节点ID] BETWEEN @id1 AND @id2
end
GO
/****** Object:  StoredProcedure [dbo].[sp_sys_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_sys_quantity_sum]
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
	left join tp_sys_quantity_sum B on A.spi_id=B.spi_id and A.sct_id=B.sct_id
end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetFilePath]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetFilePath](@file nvarchar(255))
returns nvarchar(255)
as
begin
  declare @path nvarchar(255)
  declare @reverse nvarchar(255)
  set @reverse=reverse(@file)
  set @path=substring(@file,1,len(@file)+1-charindex('\',@reverse))
  return @path
end


GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetObjColInfo]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetObjColInfo](@ObjName varchar(50))
returns @tb_ret table(TName nvarchar(50), TypeName nvarchar(50), TypeLength nvarchar(50), Colstat Bit)
as
begin
	insert @tb_ret
	select b.name as 字段名,c.name as 字段类型,b.length
	as 字段长度,b.colstat as 是否自动增长
	from sysobjects a
	inner join syscolumns b on a.id=b.id
	inner join systypes c on c.xusertype=b.xtype
	where a.name =@ObjName
	order by B.ColID
	return
end

/*功能： 自动生成表的更新数据的存储过程
如：当建立表MyTable后，执行SP_CreateProcdure ，生成表MyTable的数据更
新的存储过程UP_MyTable
设计： OK_008
时间： 2006-05
备注：
1、请在查询分析器上执行：EXEC SP_CreateProcdure TableName
2、由于生成的字符串长度合计很多时候存在>4000以上，所有只使用Print输出，
再Copy即可。
3、该方法能生成一般表的更新数据的存储过程，其中更新格式可以根据实际
情况修改。
设计方法：
1、提取表的各个字段信息
2、 ──┰─ 构造更新数据过程
├─ 构造存储过程参数部分
├─ 构造新增数据部分
├─ 构造更新数据部分
├─ 构造删除数据部分
3、分段PRINT
4、把输出来的结果复制到新建立存储过程界面中即可使用。*/
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetSheetName]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_GetSheetName](@xls nvarchar(255))
returns @tb_ret table(id int identity(1,1), sheet nvarchar(100))
as
begin
	declare @err int, @src varchar(255), @desc varchar(255)
	declare @obj int, @cnt int, @sheet varchar(200)

	exec @err=sp_oacreate 'Excel.Application',@obj out
	if @err<>0 goto lb_err
 
	exec @err=sp_oamethod @obj, 'Workbooks.Open', @cnt out, @xls
	if @err<>0 goto lb_err

	exec @err=sp_oagetproperty @obj, 'ActiveWorkbook.Sheets.Count', @cnt out
	if @err<>0 goto lb_err
	
	while @cnt>0
	begin
		set @src='ActiveWorkbook.Sheets('+cast(@cnt as varchar)+').Name'
		exec @err=sp_oagetproperty @obj, @src, @sheet out
		if @err<>0 goto lb_err
		insert @tb_ret values (@sheet)
		set @cnt=@cnt-1
	end

	exec @err=sp_oadestroy @obj
	goto lb_ret

	lb_err:
	exec sp_oageterrorinfo 0, @src out, @desc out
	insert @tb_ret
	select cast(@err as varbinary(4)) as 错误号
	union all select @src as 错误源
	union all select @desc as 错误描述
	lb_ret:
	return
end


GO
/****** Object:  Table [dbo].[T]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T](
	[id] [int] NOT NULL,
	[code] [varchar](50) NULL,
	[_id] [int] NULL,
	[_code] [varchar](50) NULL,
	[name] [nvarchar](50) NULL,
 CONSTRAINT [PK_T] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_barn]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_barn](
	[b_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_barn_b_code]  DEFAULT ('B0000'),
	[b_name] [nvarchar](10) NOT NULL CONSTRAINT [DF_tb_barn_b_name]  DEFAULT (N'某某仓库'),
	[b_dateopen] [date] NULL CONSTRAINT [DF_tb_barn_b_dateopen]  DEFAULT (getdate()),
	[b_dateclose] [date] NULL CONSTRAINT [DF_tb_barn_b_dateclose]  DEFAULT (getdate()),
	[b_place] [nvarchar](20) NULL CONSTRAINT [DF_tb_barn_b_place]  DEFAULT (N'凌源'),
	[b_linkman] [nvarchar](5) NULL CONSTRAINT [DF_tb_barn_b_linkman]  DEFAULT (N'张三'),
	[b_tel] [varchar](15) NULL CONSTRAINT [DF_tb_barn_b_tel]  DEFAULT ((1234567890)),
	[b_state] [nvarchar](5) NULL CONSTRAINT [DF_tb_barn_b_state]  DEFAULT (N'在用'),
	[b_time] [date] NOT NULL CONSTRAINT [DF_tb_barn_b_time]  DEFAULT (getdate()),
	[b_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_barn_b_estab]  DEFAULT (N'编制'),
	[b_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_barn_b_check]  DEFAULT (N'未复核'),
	[b_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_barn_b_audit]  DEFAULT (N'未审核'),
	[b_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_barn] PRIMARY KEY CLUSTERED 
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_bridge_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_bridge_down](
	[bd_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_code]  DEFAULT ('BD00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_down_pt_code]  DEFAULT ('PT001'),
	[bl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_down_bl_code]  DEFAULT ('BL001'),
	[lr_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_down_lr_code]  DEFAULT ('LR001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_down_u_code]  DEFAULT ('U0001'),
	[bd_qty_pre_design] [float] NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_qty_pre_design]  DEFAULT ((0)),
	[bd_qty_pre_change] [float] NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_qty_pre_change]  DEFAULT ((0)),
	[bd_qty_cur_design] [float] NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_qty_cur_design]  DEFAULT ((0)),
	[bd_qty_cur_change] [float] NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_qty_cur_change]  DEFAULT ((0)),
	[bd_time] [date] NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_time]  DEFAULT (getdate()),
	[bd_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_estab]  DEFAULT (N'编制'),
	[bd_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_check]  DEFAULT (N'未复核'),
	[bd_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_down_bd_audit]  DEFAULT (N'未审核'),
	[bd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_bridge_down] PRIMARY KEY CLUSTERED 
(
	[bd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_bridge_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_bridge_lst](
	[bl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_code]  DEFAULT ('BL000'),
	[bl_number] [varchar](20) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_number]  DEFAULT ((1234567890)),
	[bl_section] [varchar](20) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_section]  DEFAULT ((1234567890)),
	[bl_project] [nvarchar](40) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_project]  DEFAULT (N'xxx项目'),
	[bl_unit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_unit]  DEFAULT (N'm3'),
	[bl_qty_lst] [float] NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_qty_lst]  DEFAULT ((0)),
	[bl_price_lst] [float] NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_price_lst]  DEFAULT ((0)),
	[bl_money_lst]  AS ([bl_qty_lst]*[bl_price_lst]),
	[bl_qty_lbr] [float] NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_qty_lbr]  DEFAULT ((0)),
	[bl_price_lbr_Labor] [float] NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_price_lbr_Labor]  DEFAULT ((0)),
	[bl_price_lbr_good] [float] NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_price_lbr_good]  DEFAULT ((0)),
	[bl_price_lbr_device] [float] NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_price_lbr_device]  DEFAULT ((0)),
	[bl_price_lbr]  AS (([bl_price_lbr_Labor]+[bl_price_lbr_good])+[bl_price_lbr_device]),
	[bl_money_lbr_Labor]  AS ([bl_qty_lbr]*[bl_price_lbr_Labor]),
	[bl_money_lbr_good]  AS ([bl_qty_lbr]*[bl_price_lbr_good]),
	[bl_money_lbr_device]  AS ([bl_qty_lbr]*[bl_price_lbr_device]),
	[bl_money_lbr]  AS ([bl_qty_lbr]*(([bl_price_lbr_Labor]+[bl_price_lbr_good])+[bl_price_lbr_device])),
	[bl_time] [date] NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_date]  DEFAULT (getdate()),
	[bl_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_estab]  DEFAULT (N'编制'),
	[bl_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_check]  DEFAULT (N'未复核'),
	[bl_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_lst_bl_audit]  DEFAULT (N'未审核'),
	[bl_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_bridge_lst] PRIMARY KEY CLUSTERED 
(
	[bl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_bridge_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_bridge_qty](
	[bq_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_code]  DEFAULT ('BQ00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_qty_pt_code]  DEFAULT ('PT001'),
	[bl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_qty_bl_code]  DEFAULT ('BL001'),
	[bq_qty_dwg_design] [float] NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_qty_dwg_design]  DEFAULT ((0)),
	[bq_qty_dwg_change] [float] NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_qty_dwg_change]  DEFAULT ((0)),
	[bq_qty_chk_design] [float] NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_qty_chk_design]  DEFAULT ((0)),
	[bq_qty_chk_change] [float] NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_qty_chk_change]  DEFAULT ((0)),
	[bq_qty_doe_design] [float] NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_qty_doe_design]  DEFAULT ((0)),
	[bq_qty_doe_change] [float] NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_qty_doe_change]  DEFAULT ((0)),
	[bq_time] [date] NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_time]  DEFAULT (getdate()),
	[bq_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_estab]  DEFAULT (N'编制'),
	[bq_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_check]  DEFAULT (N'未复核'),
	[bq_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_qty_bq_audit]  DEFAULT (N'未审核'),
	[bq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_bridge_qty] PRIMARY KEY CLUSTERED 
(
	[bq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_bridge_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_bridge_up](
	[bu_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_code]  DEFAULT ('BU00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_up_pt_code]  DEFAULT ('PT001'),
	[bl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_up_bl_code]  DEFAULT ('BL001'),
	[lr_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_up_lr_code]  DEFAULT ('LR001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_up_u_code]  DEFAULT ('U0001'),
	[bu_qty_pre_design] [float] NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_qty_pre_design]  DEFAULT ((0)),
	[bu_qty_pre_change] [float] NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_qty_pre_change]  DEFAULT ((0)),
	[bu_qty_cur_design] [float] NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_qty_cur_design]  DEFAULT ((0)),
	[bu_qty_cur_change] [float] NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_qty_cur_change]  DEFAULT ((0)),
	[bu_time] [date] NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_time]  DEFAULT (getdate()),
	[bu_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_estab]  DEFAULT (N'编制'),
	[bu_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_check]  DEFAULT (N'未复核'),
	[bu_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_bridge_up_bu_audit]  DEFAULT (N'未审核'),
	[bu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_bridge_up] PRIMARY KEY CLUSTERED 
(
	[bu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_budget]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_budget](
	[bg_id] [int] NOT NULL CONSTRAINT [DF_tb_budget_bg_id]  DEFAULT ((0)),
	[ct_id] [int] NOT NULL CONSTRAINT [DF_tb_budget_ct_id]  DEFAULT ((0)),
	[bg_code] [varchar](20) NULL CONSTRAINT [DF_tb_budget_bg_code]  DEFAULT ('20000'),
	[bg_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_budget_bg_name]  DEFAULT (N'单项概算细目'),
	[bg_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_budget_bg_unit]  DEFAULT (N'm3'),
	[bg_rate] [float] NULL CONSTRAINT [DF_tb_budget_bg_rate]  DEFAULT ((0)),
	[bg_qty] [float] NULL CONSTRAINT [DF_tb_budget_bg_qty]  DEFAULT ((0)),
	[bg_price] [float] NULL CONSTRAINT [DF_tb_budget_bg_price]  DEFAULT ((0)),
	[bg_money] [float] NULL CONSTRAINT [DF_tb_budget_bg_money]  DEFAULT ((0)),
	[bg_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_budget] PRIMARY KEY CLUSTERED 
(
	[bg_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_budget_rep]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_budget_rep](
	[bg_id] [int] NOT NULL CONSTRAINT [DF_tb_budget_rep_bg_id]  DEFAULT ((0)),
	[ct_id] [int] NOT NULL CONSTRAINT [DF_tb_budget_rep_ct_id]  DEFAULT ((0)),
	[gd_code] [varchar](20) NULL CONSTRAINT [DF_tb_budget_rep_gd_code]  DEFAULT ('30000'),
	[gd_label] [char](3) NULL CONSTRAINT [DF_tb_budget_rep_gd_label]  DEFAULT ('A'),
	[gd_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_budget_rep_gd_name]  DEFAULT (N'概算细目'),
	[gd_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_budget_rep_gd_unit]  DEFAULT (N'm3'),
	[gd_rate] [float] NULL CONSTRAINT [DF_tb_budget_rep_gd_rate]  DEFAULT ((0)),
	[gd_qty] [float] NULL CONSTRAINT [DF_tb_budget_rep_gd_qty]  DEFAULT ((0)),
	[gd_price] [float] NULL CONSTRAINT [DF_tb_budget_rep_gd_price]  DEFAULT ((0)),
	[gd_money] [float] NULL CONSTRAINT [DF_tb_budget_rep_gd_money]  DEFAULT ((0)),
	[qy_budget] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_budget]  DEFAULT ((0)),
	[qy_dwg_design] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_dwg_design]  DEFAULT ((0)),
	[qy_dwg_change] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_dwg_change]  DEFAULT ((0)),
	[qy_chk_design] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_chk_design]  DEFAULT ((0)),
	[qy_chk_change] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_chk_change]  DEFAULT ((0)),
	[qy_act_design] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_act_design]  DEFAULT ((0)),
	[qy_act_change] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_act_change]  DEFAULT ((0)),
	[qy_do_design] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_do_design]  DEFAULT ((0)),
	[qy_do_change] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_do_change]  DEFAULT ((0)),
	[qy_up_change] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_up_change]  DEFAULT ((0)),
	[qy_up_design] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_up_design]  DEFAULT ((0)),
	[qy_down_design] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_down_design]  DEFAULT ((0)),
	[qy_down_change] [float] NULL CONSTRAINT [DF_tb_budget_rep_qy_down_change]  DEFAULT ((0)),
	[bg_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_budget_rep] PRIMARY KEY CLUSTERED 
(
	[bg_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_check]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_check](
	[c_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_check_c_code]  DEFAULT ('C000000000'),
	[c_date] [date] NOT NULL CONSTRAINT [DF_tb_check_c_date]  DEFAULT (getdate()),
	[b_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_check_b_code]  DEFAULT ('B0001'),
	[g_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_check_g_code]  DEFAULT ('G0001'),
	[e_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_check_e_code]  DEFAULT ('E0001'),
	[c_qtyplain] [float] NULL CONSTRAINT [DF_tb_check_c_qtyplain]  DEFAULT ((0)),
	[c_qtycheck] [float] NULL CONSTRAINT [DF_tb_check_c_qtycheck]  DEFAULT ((0)),
	[c_qtyupper] [float] NULL CONSTRAINT [DF_tb_check_c_qtyupper]  DEFAULT ((0)),
	[c_qtylower] [float] NULL CONSTRAINT [DF_tb_check_c_qtylower]  DEFAULT ((0)),
	[c_time] [date] NOT NULL CONSTRAINT [DF_tb_check_c_time]  DEFAULT (getdate()),
	[c_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_check_c_estab]  DEFAULT (N'编制'),
	[c_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_check_c_check]  DEFAULT (N'未复核'),
	[c_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_check_c_audit]  DEFAULT (N'未审核'),
	[c_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_check] PRIMARY KEY CLUSTERED 
(
	[c_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_contract](
	[ct_id] [int] NOT NULL CONSTRAINT [DF_tb_contract_ct_id]  DEFAULT ((0)),
	[ct_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_contract_ct_code]  DEFAULT ('10000'),
	[ct_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_contract_ct_name]  DEFAULT (N'合同清单细目'),
	[ct_unit] [nvarchar](10) NULL CONSTRAINT [DF_tb_contract_ct_unit]  DEFAULT (N'm3'),
	[ct_qty] [float] NULL CONSTRAINT [DF_tb_contract_ct_qty]  DEFAULT ((0)),
	[ct_price] [float] NULL CONSTRAINT [DF_tb_contract_ct_price]  DEFAULT ((0)),
	[ct_money] [float] NULL CONSTRAINT [DF_tb_contract_ct_money]  DEFAULT ((0)),
	[ct_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_contract] PRIMARY KEY CLUSTERED 
(
	[ct_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_costlist]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_costlist](
	[cl_id] [int] NOT NULL CONSTRAINT [DF_tb_costlist_cl_id]  DEFAULT ((1)),
	[cl_rootId] [int] NOT NULL CONSTRAINT [DF_tb_costlist_cl_rootId]  DEFAULT ((0)),
	[cl_level] [tinyint] NOT NULL CONSTRAINT [DF_tb_costlist_cl_level]  DEFAULT ((1)),
	[cl_node] [nvarchar](125) NULL CONSTRAINT [DF_tb_costlist_cl_node]  DEFAULT (N'XXX节点'),
	[cl_info] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_costlist] PRIMARY KEY CLUSTERED 
(
	[cl_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_employee]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_employee](
	[e_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_employee_e_code]  DEFAULT ('E0000'),
	[e_name] [nvarchar](4) NOT NULL CONSTRAINT [DF_tb_employee_e_name]  DEFAULT (N'张三'),
	[e_sex] [nchar](1) NULL CONSTRAINT [DF_employee_e_sex]  DEFAULT ('男'),
	[e_place] [nvarchar](20) NULL CONSTRAINT [DF_tb_employee_e_place]  DEFAULT (N'西安'),
	[e_birth] [date] NULL CONSTRAINT [DF_employee_e_birth]  DEFAULT (getdate()),
	[e_dept] [nvarchar](10) NULL CONSTRAINT [DF_tb_employee_e_dept]  DEFAULT (N'工程部'),
	[e_duty] [nvarchar](5) NULL CONSTRAINT [DF_tb_employee_e_duty]  DEFAULT (N'工程部长'),
	[e_identity] [nvarchar](5) NULL CONSTRAINT [DF_tb_employee_e_identity]  DEFAULT (N'党员'),
	[e_education] [nvarchar](5) NULL CONSTRAINT [DF_tb_employee_e_education]  DEFAULT (N'本科'),
	[e_college] [nvarchar](10) NULL CONSTRAINT [DF_tb_employee_e_college]  DEFAULT (N'石家庄铁道大学'),
	[e_profession] [nvarchar](10) NULL CONSTRAINT [DF_tb_employee_e_profession]  DEFAULT (N'工程师'),
	[e_tel] [varchar](20) NULL CONSTRAINT [DF_tb_employee_e_tel]  DEFAULT ((1234567890)),
	[e_time] [date] NOT NULL CONSTRAINT [DF_tb_employee_e_time]  DEFAULT (getdate()),
	[e_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_employee_e_estab]  DEFAULT (N'编制'),
	[e_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_employee_e_check]  DEFAULT (N'未复核'),
	[e_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_employee_e_audit]  DEFAULT (N'未审核'),
	[e_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_employee] PRIMARY KEY CLUSTERED 
(
	[e_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_finance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_finance](
	[p_code] [varchar](10) NOT NULL CONSTRAINT [Dp_tb_finance_p_code]  DEFAULT ('P000000000'),
	[p_date] [date] NOT NULL CONSTRAINT [Dp_tb_finance_p_date]  DEFAULT (getdate()),
	[f_code] [varchar](5) NOT NULL CONSTRAINT [Dp_tb_finance_f_code]  DEFAULT ('F0001'),
	[m_code] [varchar](5) NOT NULL CONSTRAINT [Dp_tb_finance_m_code]  DEFAULT ('M0001'),
	[p_qty] [float] NULL CONSTRAINT [Dp_tb_finance_p_qty]  DEFAULT ((0)),
	[p_money] [float] NOT NULL CONSTRAINT [Dp_tb_finance_p_money]  DEFAULT ((0)),
	[p_type] [nvarchar](5) NOT NULL CONSTRAINT [Dp_tb_finance_p_type]  DEFAULT ('支出'),
	[p_method] [nvarchar](10) NULL CONSTRAINT [Dp_tb_finance_p_method]  DEFAULT ('银行卡'),
	[p_time] [date] NOT NULL CONSTRAINT [Dp_tb_finance_p_time]  DEFAULT (getdate()),
	[p_estab] [nvarchar](5) NOT NULL CONSTRAINT [Dp_tb_finance_p_estab]  DEFAULT (N'编制'),
	[p_check] [nvarchar](5) NOT NULL CONSTRAINT [Dp_tb_finance_p_check]  DEFAULT (N'未复核'),
	[p_audit] [nvarchar](5) NOT NULL CONSTRAINT [Dp_tb_finance_p_audit]  DEFAULT (N'未审核'),
	[p_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_finance] PRIMARY KEY CLUSTERED 
(
	[p_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_funds]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[tb_funds](
	[f_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_funds_f_code]  DEFAULT ('F0000'),
	[f_name] [nvarchar](20) NOT NULL CONSTRAINT [DF_tb_funds_f_name]  DEFAULT (N'款项'),
	[f_category] [nvarchar](10) NULL CONSTRAINT [DF_tb_funds_f_category]  DEFAULT (N'类别'),
	[f_business] [nvarchar](20) NULL CONSTRAINT [DF_tb_funds_f_business]  DEFAULT (N'商家'),
	[f_unit] [nvarchar](5) NULL CONSTRAINT [DF_tb_funds_f_unit]  DEFAULT (N'台'),
	[f_price] [float] NULL CONSTRAINT [DF_tb_funds_f_price]  DEFAULT ((0)),
	[f_time] [date] NOT NULL CONSTRAINT [DF_tb_funds_f_time]  DEFAULT (getdate()),
	[f_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_funds_f_estab]  DEFAULT (N'编制'),
	[f_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_funds_f_check]  DEFAULT (N'未复核'),
	[f_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_funds_f_audit]  DEFAULT (N'未审核'),
	[f_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_funds] PRIMARY KEY CLUSTERED 
(
	[f_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_goods]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_goods](
	[g_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_goods_g_code]  DEFAULT ('G0000'),
	[g_name] [nvarchar](20) NOT NULL CONSTRAINT [DF_tb_goods_g_name]  DEFAULT (N'材料/设备'),
	[g_type] [nvarchar](10) NULL CONSTRAINT [DF_tb_goods_g_type]  DEFAULT (N'地材/刚才/预埋件'),
	[g_brand] [nvarchar](10) NULL CONSTRAINT [DF_tb_goods_g_brand]  DEFAULT (N'现代'),
	[g_standard] [nvarchar](10) NULL CONSTRAINT [DF_tb_goods_g_standard]  DEFAULT (N'90型'),
	[g_unit] [nvarchar](5) NULL CONSTRAINT [DF_tb_goods_g_unit]  DEFAULT (N'台'),
	[g_produce] [nvarchar](20) NULL CONSTRAINT [DF_tb_goods_g_produce]  DEFAULT (N'四川'),
	[g_price] [float] NULL CONSTRAINT [DF_tb_goods_g_price]  DEFAULT ((0)),
	[g_pricebudget] [float] NULL CONSTRAINT [DF_tb_goods_g_pricebudget]  DEFAULT ((0)),
	[g_pricesearch] [float] NULL CONSTRAINT [DF_tb_goods_g_pricesearch]  DEFAULT ((0)),
	[g_pricecheck] [float] NULL CONSTRAINT [DF_tb_goods_g_pricecheck]  DEFAULT ((0)),
	[g_method] [nvarchar](10) NULL CONSTRAINT [DF_tb_goods_g_method]  DEFAULT (N'平均年限法'),
	[g_rate] [float] NULL CONSTRAINT [DF_tb_goods_g_rate]  DEFAULT ((0)),
	[g_time] [date] NOT NULL CONSTRAINT [DF_tb_goods_g_time]  DEFAULT (getdate()),
	[g_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_goods_g_estab]  DEFAULT (N'编制'),
	[g_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_goods_g_check]  DEFAULT (N'未复核'),
	[g_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_goods_g_audit]  DEFAULT (N'未审核'),
	[g_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_goods] PRIMARY KEY CLUSTERED 
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_guidance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_guidance](
	[gd_id] [int] NOT NULL CONSTRAINT [DF_tb_guidance_gd_id]  DEFAULT ((0)),
	[ct_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_guidance_ct_code]  DEFAULT ('10000'),
	[bg_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_guidance_bg_code]  DEFAULT ('20000'),
	[gd_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_guidance_gd_code]  DEFAULT ('30000'),
	[gd_label] [char](3) NULL CONSTRAINT [DF_tb_guidance_gd_label]  DEFAULT ('A'),
	[gd_name] [nvarchar](100) NOT NULL CONSTRAINT [DF_tb_guidance_gd_name]  DEFAULT (N'指导价清单细目'),
	[gd_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_guidance_gd_unit]  DEFAULT (N'm3'),
	[gd_rate] [float] NULL CONSTRAINT [DF_tb_guidance_gd_rate]  DEFAULT ((0)),
	[gd_price] [float] NULL CONSTRAINT [DF_tb_guidance_gd_price]  DEFAULT ((0)),
	[gd_item] [float] NULL CONSTRAINT [DF_tb_guidance_gd_item]  DEFAULT ((0)),
	[gd_wark] [nvarchar](1024) NULL,
	[gd_cost] [nvarchar](1024) NULL,
	[gd_role] [nvarchar](255) NULL,
	[gd_info] [nvarchar](255) NULL,
 CONSTRAINT [PK_tb_guidance] PRIMARY KEY CLUSTERED 
(
	[gd_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_highway_partitem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_highway_partitem](
	[hpi_id] [int] NOT NULL CONSTRAINT [DF_tb_highway_partitem_hpi_id]  DEFAULT ((1)),
	[hpi_rootid] [int] NOT NULL CONSTRAINT [DF_tb_highway_partitem_hpi_rootid]  DEFAULT ((0)),
	[hpi_level] [tinyint] NOT NULL CONSTRAINT [DF_tb_highway_partitem_hpi_level]  DEFAULT ((1)),
	[hpi_node] [nvarchar](125) NOT NULL CONSTRAINT [DF_tb_highway_partitem_hpi_node]  DEFAULT (N'XXX节点'),
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_highway_partitem_spi_id]  DEFAULT ((1)),
	[hpi_info] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_highway_partitem] PRIMARY KEY CLUSTERED 
(
	[hpi_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_income]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_income](
	[i_code] [varchar](10) NOT NULL CONSTRAINT [Di_tb_income_i_code]  DEFAULT ('I000000000'),
	[i_date] [date] NOT NULL CONSTRAINT [Di_tb_income_i_date]  DEFAULT (getdate()),
	[f_code] [varchar](5) NOT NULL CONSTRAINT [Di_tb_income_f_code]  DEFAULT ('F0001'),
	[m_code] [varchar](5) NOT NULL CONSTRAINT [Di_tb_income_m_code]  DEFAULT ('M0001'),
	[i_qty] [float] NULL CONSTRAINT [Di_tb_income_i_qty]  DEFAULT ((0)),
	[i_money] [float] NOT NULL CONSTRAINT [Di_tb_income_i_money]  DEFAULT ((0)),
	[i_method] [nvarchar](10) NULL CONSTRAINT [Di_tb_income_i_method]  DEFAULT ('银行卡'),
	[i_time] [date] NOT NULL CONSTRAINT [Di_tb_income_i_time]  DEFAULT (getdate()),
	[i_estab] [nvarchar](5) NOT NULL CONSTRAINT [Di_tb_income_i_estab]  DEFAULT (N'编制'),
	[i_check] [nvarchar](5) NOT NULL CONSTRAINT [Di_tb_income_i_check]  DEFAULT (N'未复核'),
	[i_audit] [nvarchar](5) NOT NULL CONSTRAINT [Di_tb_income_i_audit]  DEFAULT (N'未审核'),
	[i_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_income] PRIMARY KEY CLUSTERED 
(
	[i_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_instock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_instock](
	[i_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_instock_i_code]  DEFAULT ('I000000000'),
	[i_date] [date] NOT NULL CONSTRAINT [DF_tb_instock_i_date]  DEFAULT (getdate()),
	[i_bill] [varchar](10) NOT NULL CONSTRAINT [DF_tb_instock_i_bill]  DEFAULT ((1234567890)),
	[b_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_instock_b_code]  DEFAULT ('B0001'),
	[g_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_instock_g_code]  DEFAULT ('G0001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_instock_u_code]  DEFAULT ('U0001'),
	[e_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_instock_e_code]  DEFAULT ('E0001'),
	[p_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_instock_p_code]  DEFAULT ('P0001'),
	[i_qty] [float] NULL CONSTRAINT [DF_tb_instock_i_qty]  DEFAULT ((0)),
	[i_payable] [float] NULL CONSTRAINT [DF_tb_instock_i_payable]  DEFAULT ((0)),
	[i_payout] [float] NULL CONSTRAINT [DF_tb_instock_i_payout]  DEFAULT ((0)),
	[i_plant] [float] NULL CONSTRAINT [DF_tb_instock_i_plant]  DEFAULT ((0)),
	[i_time] [date] NOT NULL CONSTRAINT [DF_tb_instock_i_time]  DEFAULT (getdate()),
	[i_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_instock_i_estab]  DEFAULT (N'编制'),
	[i_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_instock_i_check]  DEFAULT (N'未复核'),
	[i_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_instock_i_audit]  DEFAULT (N'未审核'),
	[i_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_instock] PRIMARY KEY CLUSTERED 
(
	[i_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_labour]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_labour](
	[lb_id] [int] NOT NULL CONSTRAINT [DF_tb_labour_lb_id]  DEFAULT ((0)),
	[lb_name] [nvarchar](64) NULL CONSTRAINT [DF_tb_labour_lb_name]  DEFAULT (N'X劳务队'),
	[lb_level] [nvarchar](3) NULL CONSTRAINT [DF_tb_labour_lb_level]  DEFAULT (N'X级'),
	[lb_leader] [nvarchar](5) NULL CONSTRAINT [DF_tb_labour_lb_leader]  DEFAULT (N'X负责人'),
	[lb_type] [nvarchar](100) NULL CONSTRAINT [DF_tb_labour_lb_type]  DEFAULT (N'X类别'),
	[lb_scale] [tinyint] NULL CONSTRAINT [DF_tb_labour_lb_scale]  DEFAULT ((0)),
	[lb_score] [float] NULL CONSTRAINT [DF_tb_labour_lb_score]  DEFAULT ((0)),
	[lb_project] [nvarchar](100) NULL CONSTRAINT [DF_tb_labour_lb_project]  DEFAULT (N'X项目部'),
	[lb_number] [tinyint] NULL CONSTRAINT [DF_tb_labour_lb_number]  DEFAULT ((0)),
	[lb_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_labour] PRIMARY KEY CLUSTERED 
(
	[lb_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_ledger]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_ledger](
	[lr_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_ledger_lr_code]  DEFAULT ('LR000'),
	[lr_date] [date] NOT NULL CONSTRAINT [DF_tb_ledger_lr_date]  DEFAULT (getdate()),
	[lr_road] [bit] NOT NULL CONSTRAINT [DF_tb_ledger_lr_road]  DEFAULT ((0)),
	[lr_bridge] [bit] NOT NULL CONSTRAINT [DF_tb_ledger_lr_bridge]  DEFAULT ((0)),
	[lr_tunnel] [bit] NOT NULL CONSTRAINT [DF_tb_ledger_lr_tunnel]  DEFAULT ((0)),
	[lr_orbital] [bit] NOT NULL CONSTRAINT [DF_tb_ledger_lr_rail]  DEFAULT ((0)),
	[lr_yard] [bit] NOT NULL CONSTRAINT [DF_tb_ledger_lr_yard]  DEFAULT ((0)),
	[lr_temp] [bit] NOT NULL CONSTRAINT [DF_tb_ledger_lr_temp]  DEFAULT ((0)),
	[lr_time] [date] NOT NULL CONSTRAINT [DF_tb_ledger_lr_time]  DEFAULT (getdate()),
	[lr_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_ledger_lr_estab]  DEFAULT (N'编制'),
	[lr_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_ledger_lr_check]  DEFAULT (N'未复核'),
	[lr_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_ledger_lr_audit]  DEFAULT (N'未审核'),
	[lr_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_ledger] PRIMARY KEY CLUSTERED 
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_member]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[tb_member](
	[m_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_member_m_code]  DEFAULT ('M0000'),
	[m_name] [nvarchar](4) NOT NULL CONSTRAINT [DF_tb_member_m_name]  DEFAULT (N'张三'),
	[m_sex] [nchar](1) NULL CONSTRAINT [DF_employem_m_sex]  DEFAULT ('男'),
	[m_birth] [date] NULL CONSTRAINT [DF_employem_m_birth]  DEFAULT (getdate()),
	[m_identity] [nvarchar](5) NULL CONSTRAINT [DF_tb_member_m_identity]  DEFAULT (N'党员'),
	[m_relation] [nvarchar](5) NULL CONSTRAINT [DF_tb_member_m_relation]  DEFAULT (N'爸爸'),
	[m_origin] [nvarchar](40) NULL CONSTRAINT [DF_tb_member_m_origin]  DEFAULT (N'户县'),
	[m_education] [nvarchar](5) NULL CONSTRAINT [DF_tb_member_m_education]  DEFAULT (N'本科'),
	[m_college] [nvarchar](10) NULL CONSTRAINT [DF_tb_member_m_college]  DEFAULT (N'西安理工大学'),
	[m_tel] [varchar](20) NULL CONSTRAINT [DF_tb_member_m_tel]  DEFAULT ((1234567890)),
	[m_time] [date] NOT NULL CONSTRAINT [DF_tb_member_m_time]  DEFAULT (getdate()),
	[m_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_member_m_estab]  DEFAULT (N'编制'),
	[m_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_member_m_check]  DEFAULT (N'未复核'),
	[m_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_member_m_audit]  DEFAULT (N'未审核'),
	[m_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_member] PRIMARY KEY CLUSTERED 
(
	[m_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_mixstock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_mixstock](
	[m_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_mixstock_m_code]  DEFAULT ('M000000000'),
	[m_date] [date] NOT NULL CONSTRAINT [DF_tb_mixstock_m_date]  DEFAULT (getdate()),
	[m_bill] [varchar](10) NOT NULL CONSTRAINT [DF_tb_mixstock_m_bill]  DEFAULT ((1234567890)),
	[b_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_b_code]  DEFAULT ('B0001'),
	[g_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_g_code]  DEFAULT ('G0001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_u_code]  DEFAULT ('U0001'),
	[e_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_e_code]  DEFAULT ('E0001'),
	[p_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_p_code]  DEFAULT ('P0001'),
	[m_qty] [float] NULL CONSTRAINT [DF_tb_mixstock_m_qty]  DEFAULT ((0)),
	[m_payable] [float] NULL,
	[m_payout] [float] NULL,
	[m_plant] [float] NULL,
	[m_time] [date] NOT NULL CONSTRAINT [DF_tb_mixstock_m_time]  DEFAULT (getdate()),
	[m_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_m_estab]  DEFAULT (N'编制'),
	[m_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_m_check]  DEFAULT (N'未复核'),
	[m_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_mixstock_m_audit]  DEFAULT (N'未审核'),
	[m_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_mixstock] PRIMARY KEY CLUSTERED 
(
	[m_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_orbital_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_orbital_down](
	[od_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[ol_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[od_qty_pre_design] [float] NOT NULL,
	[od_qty_pre_change] [float] NOT NULL,
	[od_qty_cur_design] [float] NOT NULL,
	[od_qty_cur_change] [float] NOT NULL,
	[od_time] [date] NOT NULL,
	[od_estab] [nvarchar](5) NOT NULL,
	[od_check] [nvarchar](5) NOT NULL,
	[od_audit] [nvarchar](5) NOT NULL,
	[od_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_orbital_down] PRIMARY KEY CLUSTERED 
(
	[od_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_orbital_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_orbital_lst](
	[ol_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_code]  DEFAULT ('OL000'),
	[ol_number] [varchar](20) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_number]  DEFAULT ((1234567890)),
	[ol_section] [varchar](20) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_section]  DEFAULT ((1234567890)),
	[ol_project] [nvarchar](40) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_project]  DEFAULT (N'xxx项目'),
	[ol_unit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_unit]  DEFAULT (N'm3'),
	[ol_qty_lst] [float] NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_qty_lst]  DEFAULT ((0)),
	[ol_price_lst] [float] NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_price_lst]  DEFAULT ((0)),
	[ol_money_lst]  AS ([ol_qty_lst]*[ol_price_lst]),
	[ol_qty_lbr] [float] NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_qty_lbr]  DEFAULT ((0)),
	[ol_price_lbr_Labor] [float] NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_price_lbr_Labor]  DEFAULT ((0)),
	[ol_price_lbr_good] [float] NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_price_lbr_good]  DEFAULT ((0)),
	[ol_price_lbr_device] [float] NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_price_lbr_device]  DEFAULT ((0)),
	[ol_price_lbr]  AS (([ol_price_lbr_Labor]+[ol_price_lbr_good])+[ol_price_lbr_device]),
	[ol_money_lbr_Labor]  AS ([ol_qty_lbr]*[ol_price_lbr_Labor]),
	[ol_money_lbr_good]  AS ([ol_qty_lbr]*[ol_price_lbr_good]),
	[ol_money_lbr_device]  AS ([ol_qty_lbr]*[ol_price_lbr_device]),
	[ol_money_lbr]  AS ([ol_qty_lbr]*(([ol_price_lbr_Labor]+[ol_price_lbr_good])+[ol_price_lbr_device])),
	[ol_time] [date] NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_date]  DEFAULT (getdate()),
	[ol_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_estab]  DEFAULT (N'编制'),
	[ol_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_check]  DEFAULT (N'未复核'),
	[ol_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_orbital_lst_ol_audit]  DEFAULT (N'未审核'),
	[ol_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_orbital_lst] PRIMARY KEY CLUSTERED 
(
	[ol_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_orbital_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_orbital_qty](
	[oq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[ol_code] [varchar](5) NOT NULL,
	[oq_qty_dwg_design] [float] NOT NULL,
	[oq_qty_dwg_change] [float] NOT NULL,
	[oq_qty_chk_design] [float] NOT NULL,
	[oq_qty_chk_change] [float] NOT NULL,
	[oq_qty_doe_design] [float] NOT NULL,
	[oq_qty_doe_change] [float] NOT NULL,
	[oq_time] [date] NOT NULL,
	[oq_estab] [nvarchar](5) NOT NULL,
	[oq_check] [nvarchar](5) NOT NULL,
	[oq_audit] [nvarchar](5) NOT NULL,
	[oq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_orbital_qty] PRIMARY KEY CLUSTERED 
(
	[oq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_orbital_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_orbital_up](
	[ou_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[ol_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[ou_qty_pre_design] [float] NOT NULL,
	[ou_qty_pre_change] [float] NOT NULL,
	[ou_qty_cur_design] [float] NOT NULL,
	[ou_qty_cur_change] [float] NOT NULL,
	[ou_time] [date] NOT NULL,
	[ou_estab] [nvarchar](5) NOT NULL,
	[ou_check] [nvarchar](5) NOT NULL,
	[ou_audit] [nvarchar](5) NOT NULL,
	[ou_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_orbital_up] PRIMARY KEY CLUSTERED 
(
	[ou_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_outlay]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[tb_outlay](
	[o_code] [varchar](10) NOT NULL CONSTRAINT [Do_tb_outlay_o_code]  DEFAULT ('O000000000'),
	[o_date] [date] NOT NULL CONSTRAINT [Do_tb_outlay_o_date]  DEFAULT (getdate()),
	[f_code] [varchar](5) NOT NULL CONSTRAINT [Do_tb_outlay_f_code]  DEFAULT ('F0001'),
	[m_code] [varchar](5) NOT NULL CONSTRAINT [Do_tb_outlay_m_code]  DEFAULT ('M0001'),
	[o_qty] [float] NULL CONSTRAINT [Do_tb_outlay_o_qty]  DEFAULT ((0)),
	[o_money] [float] NOT NULL CONSTRAINT [Do_tb_outlay_o_money]  DEFAULT ((0)),
	[o_method] [nvarchar](10) NULL CONSTRAINT [Do_tb_outlay_o_method]  DEFAULT ('银行卡'),
	[o_time] [date] NOT NULL CONSTRAINT [Do_tb_outlay_o_time]  DEFAULT (getdate()),
	[o_estab] [nvarchar](5) NOT NULL CONSTRAINT [Do_tb_outlay_o_estab]  DEFAULT (N'编制'),
	[o_check] [nvarchar](5) NOT NULL CONSTRAINT [Do_tb_outlay_o_check]  DEFAULT (N'未复核'),
	[o_audit] [nvarchar](5) NOT NULL CONSTRAINT [Do_tb_outlay_o_audit]  DEFAULT (N'未审核'),
	[o_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_outlay] PRIMARY KEY CLUSTERED 
(
	[o_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_outstock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_outstock](
	[o_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_outstock_o_code]  DEFAULT ('O000000000'),
	[o_date] [date] NOT NULL CONSTRAINT [DF_tb_outstock_o_date]  DEFAULT (getdate()),
	[o_bill] [varchar](10) NOT NULL CONSTRAINT [DF_tb_outstock_o_bill]  DEFAULT ((1234567890)),
	[b_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_b_code]  DEFAULT ('B0001'),
	[g_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_g_code]  DEFAULT ('G0001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_u_code]  DEFAULT ('U0001'),
	[e_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_e_code]  DEFAULT ('E0001'),
	[p_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_p_code]  DEFAULT ('P0001'),
	[o_qty] [float] NULL CONSTRAINT [DF_tb_outstock_o_qty]  DEFAULT ((0)),
	[o_payable] [float] NULL CONSTRAINT [DF_tb_outstock_o_payable]  DEFAULT ((0)),
	[o_payout] [float] NULL CONSTRAINT [DF_tb_outstock_o_payout]  DEFAULT ((0)),
	[o_plant] [float] NULL CONSTRAINT [DF_tb_outstock_o_plant]  DEFAULT ((0)),
	[o_time] [date] NOT NULL CONSTRAINT [DF_tb_outstock_o_time]  DEFAULT (getdate()),
	[o_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_o_estab]  DEFAULT (N'编制'),
	[o_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_o_check]  DEFAULT (N'未复核'),
	[o_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_outstock_o_audit]  DEFAULT (N'未审核'),
	[o_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_outstock] PRIMARY KEY CLUSTERED 
(
	[o_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_pact]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_pact](
	[p_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_pact_p_code]  DEFAULT ('P0000'),
	[p_date] [date] NOT NULL CONSTRAINT [DF_tb_pact_p_date]  DEFAULT (getdate()),
	[p_number] [varchar](10) NOT NULL CONSTRAINT [DF_tb_pact_p_part]  DEFAULT ((1234567890)),
	[p_name] [nvarchar](20) NOT NULL CONSTRAINT [DF_tb_pact_p_name]  DEFAULT (N'拌和站租赁合同'),
	[p_owner] [nvarchar](20) NULL CONSTRAINT [DF_tb_pact_p_ower]  DEFAULT (N'中铁十二局集团第一工程有限公司'),
	[p_party] [nvarchar](20) NULL CONSTRAINT [DF_tb_pact_p_party]  DEFAULT (N'某某某建筑有限公司'),
	[p_time] [date] NOT NULL CONSTRAINT [DF_tb_pact_p_time]  DEFAULT (getdate()),
	[p_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_pact_p_estab]  DEFAULT (N'编制'),
	[p_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_pact_p_check]  DEFAULT (N'未复核'),
	[p_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_pact_p_audit]  DEFAULT (N'未审核'),
	[p_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_pact] PRIMARY KEY CLUSTERED 
(
	[p_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_partitem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_partitem](
	[pi_id] [int] NOT NULL CONSTRAINT [DF_tb_partitem_pi_id]  DEFAULT ((1)),
	[pi_rootid] [int] NOT NULL CONSTRAINT [DF_tb_partitem_pi_rootid]  DEFAULT ((0)),
	[pi_level] [tinyint] NOT NULL CONSTRAINT [DF_tb_partitem_pi_level]  DEFAULT ((1)),
	[pi_node] [nvarchar](125) NOT NULL CONSTRAINT [DF_tb_partitem_pi_node]  DEFAULT (N'XXX节点'),
	[pi_info] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_partitem] PRIMARY KEY CLUSTERED 
(
	[pi_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_points]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_points](
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_points_pt_code]  DEFAULT ('PT000'),
	[pt_name] [nvarchar](40) NOT NULL CONSTRAINT [DF_tb_points_pt_name]  DEFAULT (N'xxx路基'),
	[pt_type] [nvarchar](20) NOT NULL CONSTRAINT [DF_tb_points_pt_type]  DEFAULT (N'路基'),
	[pt_place] [nvarchar](15) NULL CONSTRAINT [DF_tb_points_pt_place]  DEFAULT (N'凌源'),
	[pt_bstat] [nvarchar](15) NULL CONSTRAINT [DF_tb_points_pt_bstat]  DEFAULT (N'DKxxx.xxx'),
	[pt_estat] [nvarchar](15) NULL CONSTRAINT [DF_tb_points_pt_estat]  DEFAULT (N'DKxxx.xxx'),
	[pt_cstat] [nvarchar](15) NULL CONSTRAINT [DF_tb_points_pt_cstat]  DEFAULT (N'DKxxx.xxx'),
	[pt_len] [float] NOT NULL CONSTRAINT [DF_tb_points_pt_len]  DEFAULT ((0)),
	[pt_mask] [float] NOT NULL DEFAULT ((0)),
	[pt_time] [date] NOT NULL DEFAULT (getdate()),
	[pt_estab] [nvarchar](5) NOT NULL DEFAULT (N'编制'),
	[pt_check] [nvarchar](5) NOT NULL DEFAULT (N'未复核'),
	[pt_audit] [nvarchar](5) NOT NULL DEFAULT (N'未审核'),
	[pt_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_points] PRIMARY KEY CLUSTERED 
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_problem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_problem](
	[pm_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_problem_pm_code]  DEFAULT ('PM00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pt_code]  DEFAULT ('PT001'),
	[pm_units] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_units]  DEFAULT (N'XXX单元'),
	[pm_team] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_team]  DEFAULT (N'XXX队伍'),
	[pm_number] [varchar](10) NOT NULL CONSTRAINT [DF_tb_problem_pm_number]  DEFAULT ('NR00000000'),
	[pm_name] [nvarchar](20) NOT NULL CONSTRAINT [DF_tb_problem_pm_name]  DEFAULT (N'XXX单位工程'),
	[pm_part] [nvarchar](40) NOT NULL CONSTRAINT [DF_tb_problem_pm_part]  DEFAULT (N'XXX具体部位'),
	[pm_position] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_position]  DEFAULT (N'双线'),
	[pm_project] [nvarchar](20) NOT NULL CONSTRAINT [DF_tb_problem_pm_project]  DEFAULT (N'XXX问题'),
	[pm_category] [nvarchar](40) NOT NULL CONSTRAINT [DF_tb_problem_pm_category]  DEFAULT (N'XXX分类'),
	[pm_details] [nvarchar](128) NOT NULL CONSTRAINT [DF_tb_problem_pm_details]  DEFAULT (N'XXX明细'),
	[pm_method] [nvarchar](128) NOT NULL CONSTRAINT [DF_tb_problem_pm_method]  DEFAULT (N'XXX方案'),
	[pm_date] [date] NOT NULL CONSTRAINT [DF_tb_problem_pm_date]  DEFAULT (getdate()),
	[pm_state] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_state]  DEFAULT (N'未整改'),
	[pm_sign_confirm] [bit] NOT NULL CONSTRAINT [DF_tb_problem_pm_sign_confirm]  DEFAULT ((0)),
	[pm_sign_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_sign_estab]  DEFAULT (N'确认人'),
	[pm_sign_date] [date] NOT NULL CONSTRAINT [DF_tb_problem_pm_sign_date]  DEFAULT (getdate()),
	[pm_info] [nvarchar](40) NULL,
	[pm_level] [varchar](2) NOT NULL CONSTRAINT [DF_tb_problem_pm_level]  DEFAULT ('AB'),
	[pm_reason] [nvarchar](128) NOT NULL CONSTRAINT [DF_tb_problem_pm_reason]  DEFAULT (N'XXX原因'),
	[pm_time] [date] NOT NULL CONSTRAINT [DF_tb_problem_pm_time]  DEFAULT (getdate()),
	[pm_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_estab]  DEFAULT (N'编制'),
	[pm_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_check]  DEFAULT (N'未复核'),
	[pm_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_problem_pm_audit]  DEFAULT (N'未审核'),
 CONSTRAINT [PK_tb_problem] PRIMARY KEY CLUSTERED 
(
	[pm_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_quantity]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_quantity](
	[qy_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_qy_id]  DEFAULT ((0)),
	[pi_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_pi_id]  DEFAULT ((0)),
	[lb_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_lb_id]  DEFAULT ((0)),
	[ct_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_ct_id]  DEFAULT ((0)),
	[bg_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_bg_id]  DEFAULT ((0)),
	[qy_date] [date] NULL CONSTRAINT [DF_tb_quantity_qy_date]  DEFAULT (getdate()),
	[qy_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_quantity_qy_name]  DEFAULT (N'工程数量名称'),
	[qy_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_quantity_qy_unit]  DEFAULT (N'立方米'),
	[qy_do_design] [float] NULL CONSTRAINT [DF_tb_quantity_qy_do_design]  DEFAULT ((0)),
	[qy_do_change] [float] NULL CONSTRAINT [DF_tb_quantity_qy_do_change]  DEFAULT ((0)),
	[qy_up_design] [float] NULL CONSTRAINT [DF_tb_quantity_qy_up_design]  DEFAULT ((0)),
	[qy_up_change] [float] NULL CONSTRAINT [DF_tb_quantity_qy_up_change]  DEFAULT ((0)),
	[qy_down_design] [float] NULL CONSTRAINT [DF_tb_quantity_qy_down_design]  DEFAULT ((0)),
	[qy_down_change] [float] NULL CONSTRAINT [DF_tb_quantity_qy_down_change]  DEFAULT ((0)),
	[qy_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_quantity] PRIMARY KEY CLUSTERED 
(
	[qy_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_quantity_sum](
	[qy_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_sum_qy_id]  DEFAULT ((0)),
	[pi_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_sum_pi_id]  DEFAULT ((0)),
	[lb_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_sum_lb_id]  DEFAULT ((0)),
	[ct_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_sum_ct_id]  DEFAULT ((0)),
	[bg_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_sum_bg_id]  DEFAULT ((0)),
	[qy_date] [date] NULL CONSTRAINT [DF_tb_quantity_sum_qy_date]  DEFAULT (getdate()),
	[qy_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_quantity_sum_qy_name]  DEFAULT (N'工程数量名称'),
	[qy_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_quantity_sum_qy_unit]  DEFAULT (N'立方米'),
	[qy_budget] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_budget]  DEFAULT ((0)),
	[qy_dwg_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_dwg_design]  DEFAULT ((0)),
	[qy_dwg_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_dwg_change]  DEFAULT ((0)),
	[qy_chk_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_chk_design]  DEFAULT ((0)),
	[qy_chk_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_chk_change]  DEFAULT ((0)),
	[qy_act_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_act_design]  DEFAULT ((0)),
	[qy_act_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_act_change]  DEFAULT ((0)),
	[qy_do_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_do_design]  DEFAULT ((0)),
	[qy_do_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_do_change]  DEFAULT ((0)),
	[qy_up_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_up_design]  DEFAULT ((0)),
	[qy_up_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_up_change]  DEFAULT ((0)),
	[qy_down_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_down_design]  DEFAULT ((0)),
	[qy_down_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_down_change]  DEFAULT ((0)),
	[qy_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_quantity_sum] PRIMARY KEY CLUSTERED 
(
	[qy_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_railway_partitem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_railway_partitem](
	[rpi_id] [int] NOT NULL,
	[rpi_rootid] [int] NOT NULL,
	[rpi_level] [tinyint] NOT NULL,
	[rpi_node] [nvarchar](125) NOT NULL,
	[spi_id] [int] NOT NULL,
	[rpi_info] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_railway_partitem] PRIMARY KEY CLUSTERED 
(
	[rpi_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_retest_orbit]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_retest_orbit](
	[ro_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_code]  DEFAULT ('RO00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retest_orbit_pt_code]  DEFAULT ('PT001'),
	[rp_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_orbit_rp_code]  DEFAULT ('RP00000001'),
	[ro_left_point] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_point]  DEFAULT ('L000000000'),
	[ro_left_mileage] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_mileage]  DEFAULT ((0)),
	[ro_left_horizon] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_horizon]  DEFAULT ((0)),
	[ro_left_vertical] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_vertical]  DEFAULT ((0)),
	[ro_right_point] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_point]  DEFAULT ('R000000000'),
	[ro_right_mileage] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_mileage]  DEFAULT ((0)),
	[ro_right_horizon] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_horizon]  DEFAULT ((0)),
	[ro_right_vertical] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_vertical]  DEFAULT ((0)),
	[ro_dif_horizon] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_dif_horizon]  DEFAULT ((0)),
	[ro_dif_vertical] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_dif_vertical]  DEFAULT ((0)),
	[ro_left_in_dl] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_in_dl]  DEFAULT ((0)),
	[ro_left_in_dq] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_in_dq]  DEFAULT ((0)),
	[ro_left_in_dh] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_in_dh]  DEFAULT ((0)),
	[ro_right_in_dl] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_in_dl]  DEFAULT ((0)),
	[ro_right_in_dq] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_in_dq]  DEFAULT ((0)),
	[ro_right_in_dh] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_in_dh]  DEFAULT ((0)),
	[ro_left_out_dq] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_out_dq]  DEFAULT ((0)),
	[ro_left_out_dh] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_left_out_dh]  DEFAULT ((0)),
	[ro_right_out_dq] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_out_dq]  DEFAULT ((0)),
	[ro_right_out_dh] [float] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_right_out_dh]  DEFAULT ((0)),
	[ro_time] [date] NOT NULL CONSTRAINT [DF_tb_retest_orbit_ro_time]  DEFAULT (getdate()),
	[ro_estab] [nvarchar](5) NOT NULL DEFAULT (N'编制'),
	[ro_check] [nvarchar](5) NOT NULL DEFAULT (N'未复核'),
	[ro_audit] [nvarchar](5) NOT NULL DEFAULT (N'未审核'),
	[ro_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_retest_orbit] PRIMARY KEY CLUSTERED 
(
	[ro_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_retest_plate]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_retest_plate](
	[rp_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_code]  DEFAULT ('RP00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retest_plate_pt_code]  DEFAULT ('PT001'),
	[rp_mark] [varchar](7) NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_mark]  DEFAULT ('LR00000'),
	[rp_mileage] [float] NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_mileage]  DEFAULT ((0)),
	[rp_length] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_length]  DEFAULT ((0)),
	[rp_type] [varchar](8) NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_type]  DEFAULT ('P5600'),
	[rp_dif_up] [float] NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_dif_up]  DEFAULT ((0)),
	[rp_dif_down] [float] NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_dif_down]  DEFAULT ((0)),
	[rp_tie] [int] NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_tie]  DEFAULT ((18)),
	[rp_time] [date] NOT NULL CONSTRAINT [DF_tb_retest_plate_rp_time]  DEFAULT (getdate()),
	[rp_estab] [nvarchar](5) NOT NULL DEFAULT (N'编制'),
	[rp_check] [nvarchar](5) NOT NULL DEFAULT (N'未复核'),
	[rp_audit] [nvarchar](5) NOT NULL DEFAULT (N'未审核'),
	[rp_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_retest_plate] PRIMARY KEY CLUSTERED 
(
	[rp_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_retest_rail]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_retest_rail](
	[rr_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_code]  DEFAULT ('RR00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retest_rail_pt_code]  DEFAULT ('PT001'),
	[rp_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_rail_rp_code]  DEFAULT ('RP00000001'),
	[rr_mileage] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_mileage]  DEFAULT ((0)),
	[rr_left_point] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_left_point]  DEFAULT ('L000000000'),
	[rr_left_horizon] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_left_horizon]  DEFAULT ((0)),
	[rr_left_vertical] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_left_vertical]  DEFAULT ((0)),
	[rr_right_point] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_right_point]  DEFAULT ('R000000000'),
	[rr_right_horizon] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_right_horizon]  DEFAULT ((0)),
	[rr_right_vertical] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_right_vertical]  DEFAULT ((0)),
	[rr_dif_horizon] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_dif_horizon]  DEFAULT ((0)),
	[rr_dif_vertical] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_dif_vertical]  DEFAULT ((0)),
	[rr_left_dq] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_left_dq]  DEFAULT ((0)),
	[rr_left_dh] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_left_dh]  DEFAULT ((0)),
	[rr_right_dq] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_right_dq]  DEFAULT ((0)),
	[rr_right_dh] [float] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_right_dh]  DEFAULT ((0)),
	[rr_left_wfp15u_out]  AS ([rr_left_dq]+(7)),
	[rr_left_wfp15u_in]  AS ([rr_left_dq]+(9)),
	[rr_left_zw692]  AS ([rr_left_dh]+(6)),
	[rr_right_wfp15u_in]  AS ([rr_right_dq]+(9)),
	[rr_right_wfp15u_out]  AS ([rr_right_dq]+(7)),
	[rr_right_zw692]  AS ([rr_right_dh]+(6)),
	[rr_time] [date] NOT NULL CONSTRAINT [DF_tb_retest_rail_rr_time]  DEFAULT (getdate()),
	[rr_estab] [nvarchar](5) NOT NULL DEFAULT (N'编制'),
	[rr_check] [nvarchar](5) NOT NULL DEFAULT (N'未复核'),
	[rr_audit] [nvarchar](5) NOT NULL DEFAULT (N'未审核'),
	[rr_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_retest_rail] PRIMARY KEY CLUSTERED 
(
	[rr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_retstock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_retstock](
	[r_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retstock_r_code]  DEFAULT ('R000000000'),
	[r_date] [date] NOT NULL CONSTRAINT [DF_tb_retstock_r_date]  DEFAULT (getdate()),
	[r_bill] [varchar](10) NOT NULL CONSTRAINT [DF_tb_retstock_r_bill]  DEFAULT ((1234567890)),
	[b_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_b_code]  DEFAULT ('B0001'),
	[g_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_g_code]  DEFAULT ('G0001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_u_code]  DEFAULT ('U0001'),
	[e_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_e_code]  DEFAULT ('E0001'),
	[p_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_p_code]  DEFAULT ('P0001'),
	[r_qty] [float] NULL CONSTRAINT [DF_tb_retstock_r_qty]  DEFAULT ((0)),
	[r_payable] [float] NULL CONSTRAINT [DF_tb_retstock_r_payable]  DEFAULT ((0)),
	[r_payout] [float] NULL CONSTRAINT [DF_tb_retstock_r_payout]  DEFAULT ((0)),
	[r_plant] [float] NULL CONSTRAINT [DF_tb_retstock_r_plant]  DEFAULT ((0)),
	[r_time] [date] NOT NULL CONSTRAINT [DF_tb_retstock_r_time]  DEFAULT (getdate()),
	[r_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_r_estab]  DEFAULT (N'编制'),
	[r_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_r_check]  DEFAULT (N'未复核'),
	[r_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_retstock_r_audit]  DEFAULT (N'未审核'),
	[r_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_retstock] PRIMARY KEY CLUSTERED 
(
	[r_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_road_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_road_down](
	[rd_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_road_down_rd_code]  DEFAULT ('RD00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_down_pt_code]  DEFAULT ('PT001'),
	[rl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_down_rl_code]  DEFAULT ('RL001'),
	[lr_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_down_lr_code]  DEFAULT ('LR001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_down_u_code]  DEFAULT ('U0001'),
	[rd_qty_pre_design] [float] NOT NULL CONSTRAINT [DF_tb_road_down_rd_qty_pre_design]  DEFAULT ((0)),
	[rd_qty_pre_change] [float] NOT NULL CONSTRAINT [DF_tb_road_down_rd_qty_pre_change]  DEFAULT ((0)),
	[rd_qty_cur_design] [float] NOT NULL CONSTRAINT [DF_tb_road_down_rd_qty_cur_design]  DEFAULT ((0)),
	[rd_qty_cur_change] [float] NOT NULL CONSTRAINT [DF_tb_road_down_rd_qty_cur_change]  DEFAULT ((0)),
	[rd_time] [date] NOT NULL CONSTRAINT [DF_tb_road_down_rd_time]  DEFAULT (getdate()),
	[rd_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_down_rd_estab]  DEFAULT (N'编制'),
	[rd_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_down_rd_check]  DEFAULT (N'未复核'),
	[rd_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_down_rd_audit]  DEFAULT (N'未审核'),
	[rd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_road_down] PRIMARY KEY CLUSTERED 
(
	[rd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_road_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_road_lst](
	[rl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_code]  DEFAULT ('RL000'),
	[rl_number] [varchar](20) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_number]  DEFAULT ((1234567890)),
	[rl_section] [varchar](20) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_section]  DEFAULT ((1234567890)),
	[rl_project] [nvarchar](40) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_project]  DEFAULT (N'xxx项目'),
	[rl_unit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_unit]  DEFAULT (N'm3'),
	[rl_qty_lst] [float] NOT NULL CONSTRAINT [DF_tb_road_lst_rl_qty_lst]  DEFAULT ((0)),
	[rl_price_lst] [float] NOT NULL CONSTRAINT [DF_tb_road_lst_rl_price_lst]  DEFAULT ((0)),
	[rl_money_lst]  AS ([rl_qty_lst]*[rl_price_lst]),
	[rl_qty_lbr] [float] NOT NULL CONSTRAINT [DF_tb_road_lst_rl_qty_lbr]  DEFAULT ((0)),
	[rl_price_lbr_Labor] [float] NOT NULL CONSTRAINT [DF_tb_road_lst_rl_price_lbr_Labor]  DEFAULT ((0)),
	[rl_price_lbr_good] [float] NOT NULL CONSTRAINT [DF_tb_road_lst_rl_price_lbr_good]  DEFAULT ((0)),
	[rl_price_lbr_device] [float] NOT NULL CONSTRAINT [DF_tb_road_lst_rl_price_lbr_device]  DEFAULT ((0)),
	[rl_price_lbr]  AS (([rl_price_lbr_Labor]+[rl_price_lbr_good])+[rl_price_lbr_device]),
	[rl_money_lbr_Labor]  AS ([rl_qty_lbr]*[rl_price_lbr_Labor]),
	[rl_money_lbr_good]  AS ([rl_qty_lbr]*[rl_price_lbr_good]),
	[rl_money_lbr_device]  AS ([rl_qty_lbr]*[rl_price_lbr_device]),
	[rl_money_lbr]  AS ([rl_qty_lbr]*(([rl_price_lbr_Labor]+[rl_price_lbr_good])+[rl_price_lbr_device])),
	[rl_time] [date] NOT NULL CONSTRAINT [DF_tb_road_lst_rl_date]  DEFAULT (getdate()),
	[rl_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_estab]  DEFAULT (N'编制'),
	[rl_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_check]  DEFAULT (N'未复核'),
	[rl_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_lst_rl_audit]  DEFAULT (N'未审核'),
	[rl_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_road_lst] PRIMARY KEY CLUSTERED 
(
	[rl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_road_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_road_qty](
	[rq_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_road_qty_rq_code]  DEFAULT ('RQ00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_qty_pt_code]  DEFAULT ('PT001'),
	[rl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_qty_rl_code]  DEFAULT ('RL001'),
	[rq_qty_dwg_design] [float] NOT NULL CONSTRAINT [DF_tb_road_qty_rq_qty_dwg_design]  DEFAULT ((0)),
	[rq_qty_dwg_change] [float] NOT NULL CONSTRAINT [DF_tb_road_qty_rq_qty_dwg_change]  DEFAULT ((0)),
	[rq_qty_chk_design] [float] NOT NULL CONSTRAINT [DF_tb_road_qty_rq_qty_chk_design]  DEFAULT ((0)),
	[rq_qty_chk_change] [float] NOT NULL CONSTRAINT [DF_tb_road_qty_rq_qty_chk_change]  DEFAULT ((0)),
	[rq_qty_doe_design] [float] NOT NULL CONSTRAINT [DF_tb_road_qty_rq_qty_doe_design]  DEFAULT ((0)),
	[rq_qty_doe_change] [float] NOT NULL CONSTRAINT [DF_tb_road_qty_rq_qty_doe_change]  DEFAULT ((0)),
	[rq_time] [date] NOT NULL CONSTRAINT [DF_tb_road_qty_rq_time]  DEFAULT (getdate()),
	[rq_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_qty_rq_estab]  DEFAULT (N'编制'),
	[rq_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_qty_rq_check]  DEFAULT (N'未复核'),
	[rq_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_qty_rq_audit]  DEFAULT (N'未审核'),
	[rq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_road_qty] PRIMARY KEY CLUSTERED 
(
	[rq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_road_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_road_up](
	[ru_code] [varchar](10) NOT NULL CONSTRAINT [DF_tb_road_up_ru_code]  DEFAULT ('RU00000000'),
	[pt_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_up_pt_code]  DEFAULT ('PT001'),
	[rl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_up_rl_code]  DEFAULT ('RL001'),
	[lr_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_up_lr_code]  DEFAULT ('LR001'),
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_road_up_u_code]  DEFAULT ('U0001'),
	[ru_qty_pre_design] [float] NOT NULL CONSTRAINT [DF_tb_road_up_ru_qty_pre_design]  DEFAULT ((0)),
	[ru_qty_pre_change] [float] NOT NULL CONSTRAINT [DF_tb_road_up_ru_qty_pre_change]  DEFAULT ((0)),
	[ru_qty_cur_design] [float] NOT NULL CONSTRAINT [DF_tb_road_up_ru_qty_cur_design]  DEFAULT ((0)),
	[ru_qty_cur_change] [float] NOT NULL CONSTRAINT [DF_tb_road_up_ru_qty_cur_change]  DEFAULT ((0)),
	[ru_time] [date] NOT NULL CONSTRAINT [DF_tb_road_up_ru_time]  DEFAULT (getdate()),
	[ru_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_up_ru_estab]  DEFAULT (N'编制'),
	[ru_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_up_ru_check]  DEFAULT (N'未复核'),
	[ru_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_road_up_ru_audit]  DEFAULT (N'未审核'),
	[ru_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_road_up] PRIMARY KEY CLUSTERED 
(
	[ru_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_stock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_stock](
	[s_code] [varchar](10) NOT NULL,
	[b_code] [varchar](5) NOT NULL,
	[g_code] [varchar](5) NOT NULL,
	[s_qty] [float] NULL,
	[s_time] [date] NOT NULL,
	[s_estab] [nvarchar](5) NOT NULL,
	[s_check] [nvarchar](5) NOT NULL,
	[s_audit] [nvarchar](5) NOT NULL,
	[s_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_stock] PRIMARY KEY CLUSTERED 
(
	[s_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_sys_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[tb_sys_contract](
	[sct_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_contract_sct_id]  DEFAULT ((0)),
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_contract_spi_id]  DEFAULT ((0)),
	[sct_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_sys_contract_sct_code]  DEFAULT ('10000'),
	[sct_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_sys_contract_sct_name]  DEFAULT (N'合同清单细目'),
	[sct_unit] [nvarchar](10) NULL CONSTRAINT [DF_tb_sys_contract_sct_unit]  DEFAULT (N'm3'),
	[sct_qty] [float] NULL CONSTRAINT [DF_tb_sys_contract_sct_qty]  DEFAULT ((0)),
	[sct_price] [float] NULL CONSTRAINT [DF_tb_sys_contract_sct_price]  DEFAULT ((0)),
	[sct_money] [float] NULL CONSTRAINT [DF_tb_sys_contract_sct_money]  DEFAULT ((0)),
	[sct_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_sys_contract] PRIMARY KEY CLUSTERED 
(
	[sct_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_sys_guidance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_sys_guidance](
	[sgd_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_guidance_sgd_id]  DEFAULT ((0)),
	[sct_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_sys_guidance_sct_code]  DEFAULT ('10000'),
	[sbg_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_sys_guidance_sbg_code]  DEFAULT ('20000'),
	[sgd_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_sys_guidance_sgd_code]  DEFAULT ('30000'),
	[sgd_label] [char](3) NULL CONSTRAINT [DF_tb_sys_guidance_sgd_label]  DEFAULT ('A'),
	[sgd_name] [nvarchar](100) NOT NULL CONSTRAINT [DF_tb_sys_guidance_sgd_name]  DEFAULT (N'指导价清单细目'),
	[sgd_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_sys_guidance_sgd_unit]  DEFAULT (N'm3'),
	[sgd_rate] [float] NULL CONSTRAINT [DF_tb_sys_guidance_sgd_rate]  DEFAULT ((0)),
	[sgd_price] [float] NULL CONSTRAINT [DF_tb_sys_guidance_sgd_price]  DEFAULT ((0)),
	[sgd_item] [float] NULL CONSTRAINT [DF_tb_sys_guidance_sgd_item]  DEFAULT ((0)),
	[sgd_wark] [nvarchar](1024) NULL,
	[sgd_cost] [nvarchar](1024) NULL,
	[sgd_role] [nvarchar](255) NULL,
	[sgd_info] [nvarchar](255) NULL,
 CONSTRAINT [PK_tb_sys_guidance] PRIMARY KEY CLUSTERED 
(
	[sgd_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_sys_partitem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sys_partitem](
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_parttype_pt_id]  DEFAULT ((1)),
	[spi_rootid] [int] NOT NULL CONSTRAINT [DF_tb_parttype_pt_rootid]  DEFAULT ((0)),
	[spi_level] [tinyint] NOT NULL CONSTRAINT [DF_tb_parttype_pt_level]  DEFAULT ((1)),
	[spi_node] [nvarchar](125) NOT NULL CONSTRAINT [DF_tb_parttype_pt_node]  DEFAULT (N'XXX节点'),
	[spi_info] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_parttype] PRIMARY KEY CLUSTERED 
(
	[spi_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_sys_quantity]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sys_quantity](
	[sqy_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sqy_id]  DEFAULT ((0)),
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_spi_id]  DEFAULT ((0)),
	[lb_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_lb_id]  DEFAULT ((0)),
	[sct_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sct_id]  DEFAULT ((0)),
	[sbg_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sbg_id]  DEFAULT ((0)),
	[sqy_date] [date] NULL CONSTRAINT [DF_tb_sys_quantity_sqy_date]  DEFAULT (getdate()),
	[sqy_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_sys_quantity_sqy_name]  DEFAULT (N'工程数量名称'),
	[sqy_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_sys_quantity_sqy_unit]  DEFAULT (N'立方米'),
	[sqy_do_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sqy_do_design]  DEFAULT ((0)),
	[sqy_do_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sqy_do_change]  DEFAULT ((0)),
	[sqy_up_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sqy_up_design]  DEFAULT ((0)),
	[sqy_up_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sqy_up_change]  DEFAULT ((0)),
	[sqy_down_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sqy_down_design]  DEFAULT ((0)),
	[sqy_down_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sqy_down_change]  DEFAULT ((0)),
	[sqy_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_sys_quantity] PRIMARY KEY CLUSTERED 
(
	[sqy_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_sys_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sys_quantity_sum](
	[sqy_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_id]  DEFAULT ((0)),
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sum_spi_id]  DEFAULT ((0)),
	[lb_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sum_lb_id]  DEFAULT ((0)),
	[sct_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sum_sct_id]  DEFAULT ((0)),
	[sbg_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_quantity_sum_sbg_id]  DEFAULT ((0)),
	[sqy_date] [date] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_date]  DEFAULT (getdate()),
	[sqy_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_name]  DEFAULT (N'工程数量名称'),
	[sqy_unit] [nvarchar](20) NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_unit]  DEFAULT (N'立方米'),
	[sqy_budget] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_budget]  DEFAULT ((0)),
	[sqy_dwg_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_dwg_design]  DEFAULT ((0)),
	[sqy_dwg_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_dwg_change]  DEFAULT ((0)),
	[sqy_chk_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_chk_design]  DEFAULT ((0)),
	[sqy_chk_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_chk_change]  DEFAULT ((0)),
	[sqy_act_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_asct_design]  DEFAULT ((0)),
	[sqy_act_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_asct_change]  DEFAULT ((0)),
	[sqy_do_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_do_design]  DEFAULT ((0)),
	[sqy_do_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_do_change]  DEFAULT ((0)),
	[sqy_up_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_up_design]  DEFAULT ((0)),
	[sqy_up_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_up_change]  DEFAULT ((0)),
	[sqy_down_design] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_down_design]  DEFAULT ((0)),
	[sqy_down_change] [float] NULL CONSTRAINT [DF_tb_sys_quantity_sum_sqy_down_change]  DEFAULT ((0)),
	[sqy_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_sys_quantity_sum] PRIMARY KEY CLUSTERED 
(
	[sqy_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_sys_steel_library]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_sys_steel_library](
	[ssl_code] [nvarchar](20) NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_code]  DEFAULT (N'XXX构件编号'),
	[ssl_describe] [nvarchar](50) NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_describe]  DEFAULT (N'XXX构件描述'),
	[ssl_number] [varchar](5) NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_number]  DEFAULT ('N1'),
	[ssl_type] [varchar](10) NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_type]  DEFAULT ('HRB400'),
	[ssl_diameter] [tinyint] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_diameter]  DEFAULT ((0)),
	[ssl_len_single] [float] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_len_single]  DEFAULT ((0)),
	[ssl_count] [int] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_count]  DEFAULT ((0)),
	[ssl_len_total] [float] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_len_total]  DEFAULT ((0)),
	[ssl_mg_single] [float] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_mg_single]  DEFAULT ((0)),
	[ssl_mg_total] [float] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_mg_total]  DEFAULT ((0)),
	[ssl_time] [datetime] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_time]  DEFAULT (getdate()),
	[ssl_diagram] [float] NULL CONSTRAINT [DF_tb_sys_steel_library_ssl_diagram]  DEFAULT ((0)),
	[ssl_info] [nvarchar](100) NULL,
	[ssl_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_tb_sys_steel_library] PRIMARY KEY CLUSTERED 
(
	[ssl_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_sys_steel_order]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sys_steel_order](
	[hpi_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_steel_order_spi_id]  DEFAULT ((0)),
	[sso_code] [nvarchar](20) NULL CONSTRAINT [DF_tb_sys_steel_order_sso_code]  DEFAULT (N'XXX订单编号'),
	[ssl_code] [nvarchar](20) NULL CONSTRAINT [DF_tb_sys_steel_order_ssl_code]  DEFAULT (N'XXX构件编号'),
	[sso_dt_order] [date] NULL CONSTRAINT [DF_tb_sys_steel_order_sso_dt_order]  DEFAULT (getdate()),
	[sso_dt_proc] [date] NULL CONSTRAINT [DF_tb_sys_steel_order_sso_dt_proc]  DEFAULT (getdate()),
	[sso_dt_pick] [date] NULL CONSTRAINT [DF_tb_sys_steel_order_sso_dt_pick]  DEFAULT (getdate()),
	[sso_info] [nvarchar](100) NULL,
	[sso_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_tb_sys_steel_order] PRIMARY KEY CLUSTERED 
(
	[sso_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_sys_steel_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_sys_steel_qty](
	[hpi_pid] [int] NOT NULL CONSTRAINT [DF_tb_sys_steel_qty_hpi_pid]  DEFAULT ((0)),
	[hpi_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_steel_qty_hpi_id]  DEFAULT ((0)),
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_steel_qty_spi_id]  DEFAULT ((0)),
	[ssl_code] [nvarchar](20) NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_code]  DEFAULT (N'XXX构件编号'),
	[ssl_describe] [nvarchar](50) NULL CONSTRAINT [DF_tb_sys_steel_qty_ssl_describe]  DEFAULT (N'XXX构件描述'),
	[ssq_number] [varchar](5) NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_number]  DEFAULT ('N1'),
	[ssq_type] [varchar](10) NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_type]  DEFAULT ('HRB400'),
	[ssq_diameter] [tinyint] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_diameter]  DEFAULT ((0)),
	[ssq_len_single] [float] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_len_single]  DEFAULT ((0)),
	[ssq_count] [int] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_count]  DEFAULT ((0)),
	[ssq_len_total] [float] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_len_total]  DEFAULT ((0)),
	[ssq_mg_single] [float] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_mg_single]  DEFAULT ((0)),
	[ssq_mg_total] [float] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_mg_total]  DEFAULT ((0)),
	[ssq_entire_m] [nvarchar](10) NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_entire_m]  DEFAULT (N'C30砼'),
	[ssq_entire_v] [float] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_entire_v]  DEFAULT ((0)),
	[ssq_sub_m] [nvarchar](10) NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_sub_m]  DEFAULT (N'C15砼'),
	[ssq_sub_v] [float] NULL CONSTRAINT [DF_tb_sys_steel_qty_ssq_sub_v]  DEFAULT ((0)),
	[ssq_info] [nvarchar](100) NULL,
	[ssq_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_tb_sys_steel_qty] PRIMARY KEY CLUSTERED 
(
	[ssq_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_sys_template]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sys_template](
	[stp_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_template_stp_id]  DEFAULT ((0)),
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_sys_template_spi_id]  DEFAULT ((0)),
	[stp_partitem] [nvarchar](100) NOT NULL CONSTRAINT [DF_tb_sys_template_stp_partitem]  DEFAULT (N'分部分项'),
	[stp_template] [nvarchar](100) NOT NULL CONSTRAINT [DF_tb_sys_template_stp_template]  DEFAULT (N'XXX.xlsx'),
	[stp_info] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_sys_template] PRIMARY KEY CLUSTERED 
(
	[stp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_sysprogram_demonstrate]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sysprogram_demonstrate](
	[spd_id] [int] NOT NULL CONSTRAINT [DF_Table_1_spe_id]  DEFAULT ((0)),
	[spi_id] [int] NOT NULL CONSTRAINT [DF_tb_sysprogram_demonstrate_spi_id]  DEFAULT ((0)),
	[spd_type] [nvarchar](20) NOT NULL CONSTRAINT [DF_Table_1_spe_type]  DEFAULT (N'方案类别'),
	[spd_program] [nvarchar](255) NOT NULL CONSTRAINT [DF_Table_1_spe_program]  DEFAULT (N'XXX方案'),
	[spd_demonstrate] [nvarchar](255) NULL CONSTRAINT [DF_Table_1_spe_demonstrate]  DEFAULT (N'专家论证'),
	[spd_info] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_sysprogram_demonstrate] PRIMARY KEY CLUSTERED 
(
	[spd_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tb_temp_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_temp_down](
	[pd_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[pl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[pd_qty_pre_design] [float] NOT NULL,
	[pd_qty_pre_change] [float] NOT NULL,
	[pd_qty_cur_design] [float] NOT NULL,
	[pd_qty_cur_change] [float] NOT NULL,
	[pd_time] [date] NOT NULL,
	[pd_estab] [nvarchar](5) NOT NULL,
	[pd_check] [nvarchar](5) NOT NULL,
	[pd_audit] [nvarchar](5) NOT NULL,
	[pd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_temp_down] PRIMARY KEY CLUSTERED 
(
	[pd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_temp_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_temp_lst](
	[pl_code] [varchar](5) NOT NULL,
	[pl_number] [varchar](20) NOT NULL,
	[pl_section] [varchar](20) NOT NULL,
	[pl_project] [nvarchar](40) NOT NULL,
	[pl_unit] [nvarchar](5) NOT NULL,
	[pl_qty_lst] [float] NOT NULL,
	[pl_price_lst] [float] NOT NULL,
	[pl_money_lst]  AS ([pl_qty_lst]*[pl_price_lst]),
	[pl_qty_lbr] [float] NOT NULL,
	[pl_price_lbr_Labor] [float] NOT NULL,
	[pl_price_lbr_good] [float] NOT NULL,
	[pl_price_lbr_device] [float] NOT NULL,
	[pl_price_lbr]  AS (([pl_price_lbr_Labor]+[pl_price_lbr_good])+[pl_price_lbr_device]),
	[pl_money_lbr_Labor]  AS ([pl_qty_lbr]*[pl_price_lbr_Labor]),
	[pl_money_lbr_good]  AS ([pl_qty_lbr]*[pl_price_lbr_good]),
	[pl_money_lbr_device]  AS ([pl_qty_lbr]*[pl_price_lbr_device]),
	[pl_money_lbr]  AS ([pl_qty_lbr]*(([pl_price_lbr_Labor]+[pl_price_lbr_good])+[pl_price_lbr_device])),
	[pl_time] [date] NOT NULL,
	[pl_estab] [nvarchar](5) NOT NULL,
	[pl_check] [nvarchar](5) NOT NULL,
	[pl_audit] [nvarchar](5) NOT NULL,
	[pl_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_temp_lst] PRIMARY KEY CLUSTERED 
(
	[pl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_temp_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_temp_qty](
	[pq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[pl_code] [varchar](5) NOT NULL,
	[pq_qty_dwg_design] [float] NOT NULL,
	[pq_qty_dwg_change] [float] NOT NULL,
	[pq_qty_chk_design] [float] NOT NULL,
	[pq_qty_chk_change] [float] NOT NULL,
	[pq_qty_doe_design] [float] NOT NULL,
	[pq_qty_doe_change] [float] NOT NULL,
	[pq_time] [date] NOT NULL,
	[pq_estab] [nvarchar](5) NOT NULL,
	[pq_check] [nvarchar](5) NOT NULL,
	[pq_audit] [nvarchar](5) NOT NULL,
	[pq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_temp_qty] PRIMARY KEY CLUSTERED 
(
	[pq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_temp_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_temp_up](
	[pu_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[pl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[pu_qty_pre_design] [float] NOT NULL,
	[pu_qty_pre_change] [float] NOT NULL,
	[pu_qty_cur_design] [float] NOT NULL,
	[pu_qty_cur_change] [float] NOT NULL,
	[pu_time] [date] NOT NULL,
	[pu_estab] [nvarchar](5) NOT NULL,
	[pu_check] [nvarchar](5) NOT NULL,
	[pu_audit] [nvarchar](5) NOT NULL,
	[pu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_temp_up] PRIMARY KEY CLUSTERED 
(
	[pu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_tunnel_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_tunnel_down](
	[td_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[tl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[td_qty_pre_design] [float] NOT NULL,
	[td_qty_pre_change] [float] NOT NULL,
	[td_qty_cur_design] [float] NOT NULL,
	[td_qty_cur_change] [float] NOT NULL,
	[td_time] [date] NOT NULL,
	[td_estab] [nvarchar](5) NOT NULL,
	[td_check] [nvarchar](5) NOT NULL,
	[td_audit] [nvarchar](5) NOT NULL,
	[td_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_tunnel_down] PRIMARY KEY CLUSTERED 
(
	[td_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_tunnel_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_tunnel_lst](
	[tl_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_code]  DEFAULT ('TL000'),
	[tl_number] [varchar](20) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_number]  DEFAULT ((1234567890)),
	[tl_section] [varchar](20) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_section]  DEFAULT ((1234567890)),
	[tl_project] [nvarchar](40) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_project]  DEFAULT (N'xxx项目'),
	[tl_unit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_unit]  DEFAULT (N'm3'),
	[tl_qty_lst] [float] NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_qty_lst]  DEFAULT ((0)),
	[tl_price_lst] [float] NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_price_lst]  DEFAULT ((0)),
	[tl_money_lst]  AS ([tl_qty_lst]*[tl_price_lst]),
	[tl_qty_lbr] [float] NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_qty_lbr]  DEFAULT ((0)),
	[tl_price_lbr_Labor] [float] NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_price_lbr_Labor]  DEFAULT ((0)),
	[tl_price_lbr_good] [float] NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_price_lbr_good]  DEFAULT ((0)),
	[tl_price_lbr_device] [float] NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_price_lbr_device]  DEFAULT ((0)),
	[tl_price_lbr]  AS (([tl_price_lbr_Labor]+[tl_price_lbr_good])+[tl_price_lbr_device]),
	[tl_money_lbr_Labor]  AS ([tl_qty_lbr]*[tl_price_lbr_Labor]),
	[tl_money_lbr_good]  AS ([tl_qty_lbr]*[tl_price_lbr_good]),
	[tl_money_lbr_device]  AS ([tl_qty_lbr]*[tl_price_lbr_device]),
	[tl_money_lbr]  AS ([tl_qty_lbr]*(([tl_price_lbr_Labor]+[tl_price_lbr_good])+[tl_price_lbr_device])),
	[tl_time] [date] NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_date]  DEFAULT (getdate()),
	[tl_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_estab]  DEFAULT (N'编制'),
	[tl_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_check]  DEFAULT (N'未复核'),
	[tl_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_tunnel_lst_tl_audit]  DEFAULT (N'未审核'),
	[tl_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_tunnel_lst] PRIMARY KEY CLUSTERED 
(
	[tl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_tunnel_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_tunnel_qty](
	[tq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[tl_code] [varchar](5) NOT NULL,
	[tq_qty_dwg_design] [float] NOT NULL,
	[tq_qty_dwg_change] [float] NOT NULL,
	[tq_qty_chk_design] [float] NOT NULL,
	[tq_qty_chk_change] [float] NOT NULL,
	[tq_qty_doe_design] [float] NOT NULL,
	[tq_qty_doe_change] [float] NOT NULL,
	[tq_time] [date] NOT NULL,
	[tq_estab] [nvarchar](5) NOT NULL,
	[tq_check] [nvarchar](5) NOT NULL,
	[tq_audit] [nvarchar](5) NOT NULL,
	[tq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_tunnel_qty] PRIMARY KEY CLUSTERED 
(
	[tq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_tunnel_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_tunnel_up](
	[tu_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[tl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[tu_qty_pre_design] [float] NOT NULL,
	[tu_qty_pre_change] [float] NOT NULL,
	[tu_qty_cur_design] [float] NOT NULL,
	[tu_qty_cur_change] [float] NOT NULL,
	[tu_time] [date] NOT NULL,
	[tu_estab] [nvarchar](5) NOT NULL,
	[tu_check] [nvarchar](5) NOT NULL,
	[tu_audit] [nvarchar](5) NOT NULL,
	[tu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_tunnel_up] PRIMARY KEY CLUSTERED 
(
	[tu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_units]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_units](
	[u_code] [varchar](5) NOT NULL CONSTRAINT [DF_tb_units_u_code]  DEFAULT ('U0000'),
	[u_name] [nvarchar](20) NOT NULL CONSTRAINT [DF_tb_units_u_name]  DEFAULT ('建筑劳务公司/供应商/生产商/维修站'),
	[u_type] [nvarchar](10) NULL CONSTRAINT [DF_tb_units_u_type]  DEFAULT ('专业/物资/设备'),
	[u_tax] [varchar](15) NULL CONSTRAINT [DF_tb_units_u_tax]  DEFAULT ((1234567890)),
	[u_tel] [varchar](15) NULL CONSTRAINT [DF_tb_units_u_tel]  DEFAULT ((1234567890)),
	[u_address] [nvarchar](20) NULL CONSTRAINT [DF_tb_units_u_address]  DEFAULT (N'西安灞桥区柳雪路'),
	[u_email] [varchar](30) NULL CONSTRAINT [DF_tb_units_u_email]  DEFAULT ('fb19801101@126.com'),
	[u_bank] [nvarchar](10) NULL CONSTRAINT [DF_tb_units_u_bank]  DEFAULT (N'中国银行'),
	[u_account] [varchar](20) NULL CONSTRAINT [DF_tb_units_u_account]  DEFAULT ((1234567890)),
	[u_legalman] [nvarchar](4) NULL CONSTRAINT [DF_tb_units_u_legalman]  DEFAULT (N'张三'),
	[u_linkman] [nvarchar](4) NULL CONSTRAINT [DF_tb_units_u_linkman]  DEFAULT (N'李四'),
	[u_linktel] [varchar](15) NULL CONSTRAINT [DF_tb_units_u_linktel]  DEFAULT ((1234567890)),
	[u_income] [float] NULL CONSTRAINT [DF_tb_units_u_income]  DEFAULT ((0)),
	[u_payout] [float] NULL CONSTRAINT [DF_tb_units_u_payout]  DEFAULT ((0)),
	[u_time] [date] NOT NULL CONSTRAINT [DF_tb_units_u_time]  DEFAULT (getdate()),
	[u_estab] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_units_u_estab]  DEFAULT (N'编制'),
	[u_check] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_units_u_check]  DEFAULT (N'未复核'),
	[u_audit] [nvarchar](5) NOT NULL CONSTRAINT [DF_tb_units_u_audit]  DEFAULT (N'未审核'),
	[u_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_units] PRIMARY KEY CLUSTERED 
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_users]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_users](
	[id] [varchar](5) NOT NULL CONSTRAINT [DF_tb_users_id]  DEFAULT ('SYS01'),
	[sysuser] [varchar](20) NOT NULL CONSTRAINT [DF_tb_users_sysuser]  DEFAULT (user_name()),
	[password] [varchar](20) NOT NULL CONSTRAINT [DF_tb_users_password]  DEFAULT (user_name()),
	[md5pwd] [varchar](32) NOT NULL CONSTRAINT [DF_tb_users_md5pwd]  DEFAULT (user_name()),
	[cip] [varchar](20) NULL CONSTRAINT [DF_tb_users_cip]  DEFAULT ('local'),
	[cport] [int] NULL CONSTRAINT [DF_tb_users_cport]  DEFAULT ((5000)),
	[sip] [varchar](20) NULL CONSTRAINT [DF_tb_users_sip]  DEFAULT ('local'),
	[sport] [int] NULL CONSTRAINT [DF_tb_users_sport]  DEFAULT ((5000)),
	[state] [int] NULL CONSTRAINT [DF_tb_users_state]  DEFAULT ((0)),
	[advanced] [bit] NULL CONSTRAINT [DF_tb_users_advanced]  DEFAULT ((0)),
	[remberpwd] [bit] NULL CONSTRAINT [DF_tb_users_remberpwd]  DEFAULT ((0)),
	[autologin] [bit] NULL CONSTRAINT [DF_tb_users_autologin]  DEFAULT ((0)),
	[autoframe] [bit] NULL CONSTRAINT [DF_tb_users_frmribbon]  DEFAULT ((0))
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_yard_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_yard_down](
	[yd_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[yl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[yd_qty_pre_design] [float] NOT NULL,
	[yd_qty_pre_change] [float] NOT NULL,
	[yd_qty_cur_design] [float] NOT NULL,
	[yd_qty_cur_change] [float] NOT NULL,
	[yd_time] [date] NOT NULL,
	[yd_estab] [nvarchar](5) NOT NULL,
	[yd_check] [nvarchar](5) NOT NULL,
	[yd_audit] [nvarchar](5) NOT NULL,
	[yd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_yard_down] PRIMARY KEY CLUSTERED 
(
	[yd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_yard_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_yard_lst](
	[yl_code] [varchar](5) NOT NULL,
	[yl_number] [varchar](20) NOT NULL,
	[yl_section] [varchar](20) NOT NULL,
	[yl_project] [nvarchar](40) NOT NULL,
	[yl_unit] [nvarchar](5) NOT NULL,
	[yl_qty_lst] [float] NOT NULL,
	[yl_price_lst] [float] NOT NULL,
	[yl_money_lst]  AS ([yl_qty_lst]*[yl_price_lst]),
	[yl_qty_lbr] [float] NOT NULL,
	[yl_price_lbr_Labor] [float] NOT NULL,
	[yl_price_lbr_good] [float] NOT NULL,
	[yl_price_lbr_device] [float] NOT NULL,
	[yl_price_lbr]  AS (([yl_price_lbr_Labor]+[yl_price_lbr_good])+[yl_price_lbr_device]),
	[yl_money_lbr_Labor]  AS ([yl_qty_lbr]*[yl_price_lbr_Labor]),
	[yl_money_lbr_good]  AS ([yl_qty_lbr]*[yl_price_lbr_good]),
	[yl_money_lbr_device]  AS ([yl_qty_lbr]*[yl_price_lbr_device]),
	[yl_money_lbr]  AS ([yl_qty_lbr]*(([yl_price_lbr_Labor]+[yl_price_lbr_good])+[yl_price_lbr_device])),
	[yl_time] [date] NOT NULL,
	[yl_estab] [nvarchar](5) NOT NULL,
	[yl_check] [nvarchar](5) NOT NULL,
	[yl_audit] [nvarchar](5) NOT NULL,
	[yl_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_yard_lst] PRIMARY KEY CLUSTERED 
(
	[yl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_yard_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_yard_qty](
	[yq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[yl_code] [varchar](5) NOT NULL,
	[yq_qty_dwg_design] [float] NOT NULL,
	[yq_qty_dwg_change] [float] NOT NULL,
	[yq_qty_chk_design] [float] NOT NULL,
	[yq_qty_chk_change] [float] NOT NULL,
	[yq_qty_doe_design] [float] NOT NULL,
	[yq_qty_doe_change] [float] NOT NULL,
	[yq_time] [date] NOT NULL,
	[yq_estab] [nvarchar](5) NOT NULL,
	[yq_check] [nvarchar](5) NOT NULL,
	[yq_audit] [nvarchar](5) NOT NULL,
	[yq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_yard_qty] PRIMARY KEY CLUSTERED 
(
	[yq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_yard_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_yard_up](
	[yu_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[yl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[yu_qty_pre_design] [float] NOT NULL,
	[yu_qty_pre_change] [float] NOT NULL,
	[yu_qty_cur_design] [float] NOT NULL,
	[yu_qty_cur_change] [float] NOT NULL,
	[yu_time] [date] NOT NULL,
	[yu_estab] [nvarchar](5) NOT NULL,
	[yu_check] [nvarchar](5) NOT NULL,
	[yu_audit] [nvarchar](5) NOT NULL,
	[yu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_yard_up] PRIMARY KEY CLUSTERED 
(
	[yu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TT]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TT](
	[id] [int] NOT NULL,
	[code] [varchar](50) NULL,
	[_id] [int] NULL,
	[_code] [varchar](50) NULL,
	[name] [nvarchar](50) NULL,
 CONSTRAINT [PK_TT] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[tp_retest_orbit]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_orbit]
AS
SELECT   dbo.tb_retest_orbit.ro_code, dbo.tb_points.pt_name AS ro_name, dbo.tb_points.pt_bstat AS ro_bstat, 
                dbo.tb_points.pt_estat AS ro_estat, dbo.tb_points.pt_cstat AS ro_cstat, dbo.tb_points.pt_len AS ro_len, 
                dbo.tb_points.pt_mask AS ro_count, dbo.tb_retest_plate.rp_mark AS ro_mask, 
                CASE WHEN ro_left_mileage > ro_right_mileage THEN ro_left_mileage ELSE ro_right_mileage END AS ro_mileage, 
                CASE WHEN ro_left_horizon > ro_right_horizon THEN ro_left_horizon ELSE ro_right_horizon END AS ro_horizon, 
                CASE WHEN ro_left_vertical > ro_right_vertical THEN ro_left_vertical ELSE ro_right_vertical END AS ro_vertical, 
                dbo.tb_retest_orbit.ro_dif_horizon, dbo.tb_retest_orbit.ro_dif_vertical, 
                CASE WHEN ro_left_in_dl > ro_right_in_dl THEN ro_left_in_dl ELSE ro_right_in_dl END AS ro_in_dl, 
                CASE WHEN ro_left_in_dq > ro_right_in_dq THEN ro_left_in_dq ELSE ro_right_in_dq END AS ro_in_dq, 
                CASE WHEN ro_left_in_dh > ro_right_in_dh THEN ro_left_in_dh ELSE ro_right_in_dh END AS ro_in_dh, 
                CASE WHEN ro_left_out_dq > ro_right_out_dq THEN ro_left_out_dq ELSE ro_right_out_dq END AS ro_out_dq, 
                CASE WHEN ro_left_out_dh > ro_right_out_dh THEN ro_left_out_dh ELSE ro_right_out_dh END AS ro_out_dh
FROM      dbo.tb_retest_orbit INNER JOIN
                dbo.tb_points ON dbo.tb_retest_orbit.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_retest_plate ON dbo.tb_retest_orbit.rp_code = dbo.tb_retest_plate.rp_code


GO
/****** Object:  View [dbo].[tp_retest_orbit_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_orbit_sum]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY code) AS 序号, name AS 工点名称, bstat AS 起点里程, estat AS 终点里程, 
cstat AS 中心里程, len AS 线路长度, count AS 布板数量, mask AS 布板板号, mileage AS 测点里程, horizon AS 横向偏差, 
vertical AS 高程偏差, dif_horizon AS 左右端横向差, dif_vertical AS 左右端高程差, in_dl AS 板内纵向平顺性, 
in_dq AS 板内横向平顺性, in_dh AS 板内高程平顺性, out_dq AS 板间横向平顺性, out_dh AS 板间高程平顺性
FROM      (SELECT   ROW_NUMBER() OVER (ORDER BY t1.ro_code) AS rn, t1.ro_code AS code, t1.ro_name AS name, 
                t1.ro_bstat AS bstat, t1.ro_estat AS estat, t1.ro_cstat AS cstat, t1.ro_len AS len, t1.ro_count AS count, 
                t1.ro_mask AS mask, 
                CASE WHEN t1.ro_mileage > t2.ro_mileage THEN t1.ro_mileage ELSE t2.ro_mileage END AS mileage, 
                CASE WHEN ABS(t1.ro_horizon) > ABS(t2.ro_horizon) THEN t1.ro_horizon ELSE t2.ro_horizon END AS horizon, 
                CASE WHEN t1.ro_vertical > t2.ro_vertical THEN t1.ro_vertical ELSE t2.ro_vertical END AS vertical, 
                CASE WHEN ABS(t1.ro_dif_horizon) > ABS(t2.ro_dif_horizon) THEN t1.ro_dif_horizon ELSE t2.ro_dif_horizon END AS dif_horizon, 
                CASE WHEN t1.ro_dif_vertical > t2.ro_dif_vertical THEN t1.ro_dif_vertical ELSE t2.ro_dif_vertical END AS dif_vertical, 
                CASE WHEN ABS(t1.ro_in_dl) > ABS(t2.ro_in_dl) THEN t1.ro_in_dl ELSE t2.ro_in_dl END AS in_dl, 
                CASE WHEN ABS(t1.ro_in_dq) > ABS(t2.ro_in_dq) THEN t1.ro_in_dq ELSE t2.ro_in_dq END AS in_dq, 
                CASE WHEN t1.ro_in_dh > t2.ro_in_dh THEN t1.ro_in_dh ELSE t2.ro_in_dh END AS in_dh, 
                CASE WHEN ABS(t1.ro_out_dq) > ABS(t2.ro_out_dq) THEN t1.ro_out_dq ELSE t2.ro_out_dq END AS out_dq, 
                CASE WHEN t1.ro_out_dh > t2.ro_out_dh THEN t1.ro_out_dh ELSE t2.ro_out_dh END AS out_dh
FROM      (SELECT   ROW_NUMBER() OVER (ORDER BY ro_code) AS rn1, ro_code, ro_name, ro_bstat, ro_estat, ro_cstat, ro_len, 
                ro_count, ro_mask, ro_mileage, ro_horizon, ro_vertical, ro_dif_horizon, ro_dif_vertical, ro_in_dl, ro_in_dq, ro_in_dh, 
                ro_out_dq, ro_out_dh
FROM      dbo.tp_retest_orbit) t1 INNER JOIN
    (SELECT   ROW_NUMBER() OVER (ORDER BY ro_code) AS rn2, ro_code, ro_name, ro_bstat, ro_estat, ro_cstat, ro_len, 
ro_count, ro_mask, ro_mileage, ro_horizon, ro_vertical, ro_dif_horizon, ro_dif_vertical, ro_in_dl, ro_in_dq, ro_in_dh, ro_out_dq, 
ro_out_dh
FROM      dbo.tp_retest_orbit) t2 ON t1.rn1 = t2.rn2 - 1) t
WHERE   rn % 2 = 1


GO
/****** Object:  View [dbo].[tp_retest_orbit_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_orbit_all]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY ro_bstat) AS 序号, MIN(ro_name) AS 工点名称, ro_bstat AS 起点里程, MIN(ro_estat) 
AS 终点里程, MIN(ro_cstat) AS 中心里程, MIN(ro_len) AS 线路长度, MIN(ro_count) AS 布板数量, COUNT(ro_mask) 
/ 2 AS 上传数量
FROM      dbo.tp_retest_orbit
GROUP BY ro_bstat


GO
/****** Object:  View [dbo].[tp_retest_orbit_cnt]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_orbit_cnt]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY 起点里程) AS 序号, MIN(工点名称) AS 工点名称, 起点里程, MIN(终点里程) 
AS 终点里程, MIN(中心里程) AS 中心里程, MIN(线路长度) AS 线路长度, MIN(布板数量) AS 布板数量, 
COUNT(CASE WHEN 横向偏差 >= 0 AND 横向偏差 <= 1 THEN 横向偏差 END) AS [DQ ≥0 & ≤1],
COUNT(CASE WHEN 横向偏差 > 1 AND 横向偏差 <= 2 THEN 横向偏差 END) AS [DQ ＞1 & ≤2],
COUNT(CASE WHEN 横向偏差 > 2 AND 横向偏差 <= 3 THEN 横向偏差 END) AS [DQ ＞2 & ≤3],
COUNT(CASE WHEN 横向偏差 > 3 AND 横向偏差 <= 4 THEN 横向偏差 END) AS [DQ ＞3 & ≤4],
COUNT(CASE WHEN 横向偏差 > 4 AND 横向偏差 <= 5 THEN 横向偏差 END) AS [DQ ＞4 & ≤5],
COUNT(CASE WHEN 横向偏差 > 5 AND 横向偏差 <= 6 THEN 横向偏差 END) AS [DQ ＞5 & ≤6],
COUNT(CASE WHEN 横向偏差 > 6 AND 横向偏差 <= 7 THEN 横向偏差 END) AS [DQ ＞6 & ≤7],
COUNT(CASE WHEN 横向偏差 > 7 AND 横向偏差 <= 8 THEN 横向偏差 END) AS [DQ ＞7 & ≤8],
COUNT(CASE WHEN 横向偏差 < 0 AND 横向偏差 >= -1 THEN 横向偏差 END) AS [DQ ＜0 & ≥-1],
COUNT(CASE WHEN 横向偏差 < -1 AND 横向偏差 >= -2 THEN 横向偏差 END) AS [DQ ＜-1 & ≥-2],
COUNT(CASE WHEN 横向偏差 < -2 AND 横向偏差 >= -3 THEN 横向偏差 END) AS [DQ ＜-2 & ≥-3],
COUNT(CASE WHEN 横向偏差 < -3 AND 横向偏差 >= -4 THEN 横向偏差 END) AS [DQ ＜-3 & ≥-4],
COUNT(CASE WHEN 横向偏差 < -4 AND 横向偏差 >= -5 THEN 横向偏差 END) AS [DQ ＜-4 & ≥-5],
COUNT(CASE WHEN 横向偏差 < -5 AND 横向偏差 >= -6 THEN 横向偏差 END) AS [DQ ＜-5 & ≥-6],
COUNT(CASE WHEN 横向偏差 < -6 AND 横向偏差 >= -7 THEN 横向偏差 END) AS [DQ ＜-6 & ≥-7],
COUNT(CASE WHEN 横向偏差 < -7 AND 横向偏差 >= -8 THEN 横向偏差 END) AS [DQ ＜-7 & ≥-8],
COUNT(CASE WHEN 高程偏差 >= 0 AND 高程偏差 <= 1 THEN 高程偏差 END) AS [DH ≥0 & ≤1],
COUNT(CASE WHEN 高程偏差 > 1 AND 高程偏差 <= 2 THEN 高程偏差 END) AS [DH ＞1 & ≤2],
COUNT(CASE WHEN 高程偏差 > 2 AND 高程偏差 <= 3 THEN 高程偏差 END) AS [DH ＞2 & ≤3],
COUNT(CASE WHEN 高程偏差 > 3 AND 高程偏差 <= 4 THEN 高程偏差 END) AS [DH ＞3 & ≤4],
COUNT(CASE WHEN 高程偏差 < 0 AND 高程偏差 >= -1 THEN 高程偏差 END) AS [DH ＜0 & ≥-1],
COUNT(CASE WHEN 高程偏差 < -1 AND 高程偏差 >= -2 THEN 高程偏差 END) AS [DH ＜-1 & ≥-2],
COUNT(CASE WHEN 高程偏差 < -2 AND 高程偏差 >= -3 THEN 高程偏差 END) AS [DH ＜-2 & ≥-3],
COUNT(CASE WHEN 高程偏差 < -3 AND 高程偏差 >= -4 THEN 高程偏差 END) AS [DH ＜-3 & ≥-4],
COUNT(CASE WHEN 高程偏差 < -4 AND 高程偏差 >= -5 THEN 高程偏差 END) AS [DH ＜-4 & ≥-5],
COUNT(CASE WHEN 高程偏差 < -5 AND 高程偏差 >= -6 THEN 高程偏差 END) AS [DH ＜-5 & ≥-6],
COUNT(CASE WHEN 高程偏差 < -6 AND 高程偏差 >= -7 THEN 高程偏差 END) AS [DH ＜-6 & ≥-7],
COUNT(CASE WHEN 高程偏差 < -7 AND 高程偏差 >= -8 THEN 高程偏差 END) AS [DH ＜-7 & ≥-8],
COUNT(CASE WHEN 板内横向平顺性 >= 0 AND 板内横向平顺性 <= 1 THEN 板内横向平顺性 END) AS [板内DQ ≥0 & ≤1],
COUNT(CASE WHEN 板内横向平顺性 > 1 AND 板内横向平顺性 <= 2 THEN 板内横向平顺性 END) AS [板内DQ ＞1 & ≤2],
COUNT(CASE WHEN 板内横向平顺性 > 2 AND 板内横向平顺性 <= 3 THEN 板内横向平顺性 END) AS [板内DQ ＞2 & ≤3],
COUNT(CASE WHEN 板内横向平顺性 > 3 AND 板内横向平顺性 <= 4 THEN 板内横向平顺性 END) AS [板内DQ ＞3 & ≤4],
COUNT(CASE WHEN 板内横向平顺性 > 4 AND 板内横向平顺性 <= 5 THEN 板内横向平顺性 END) AS [板内DQ ＞4 & ≤5],
COUNT(CASE WHEN 板内横向平顺性 > 5 AND 板内横向平顺性 <= 6 THEN 板内横向平顺性 END) AS [板内DQ ＞5 & ≤6],
COUNT(CASE WHEN 板内横向平顺性 > 6 AND 板内横向平顺性 <= 7 THEN 板内横向平顺性 END) AS [板内DQ ＞6 & ≤7],
COUNT(CASE WHEN 板内横向平顺性 > 7 AND 板内横向平顺性 <= 8 THEN 板内横向平顺性 END) AS [板内DQ ＞7 & ≤8],
COUNT(CASE WHEN 板内横向平顺性 < 0 AND 板内横向平顺性 >= -1 THEN 板内横向平顺性 END) AS [板内DQ ＜0 & ≥-1],
COUNT(CASE WHEN 板内横向平顺性 < -1 AND 板内横向平顺性 >= -2 THEN 板内横向平顺性 END) AS [板内DQ ＜-1 & ≥-2],
COUNT(CASE WHEN 板内横向平顺性 < -2 AND 板内横向平顺性 >= -3 THEN 板内横向平顺性 END) AS [板内DQ ＜-2 & ≥-3],
COUNT(CASE WHEN 板内横向平顺性 < -3 AND 板内横向平顺性 >= -4 THEN 板内横向平顺性 END) AS [板内DQ ＜-3 & ≥-4],
COUNT(CASE WHEN 板内横向平顺性 < -4 AND 板内横向平顺性 >= -5 THEN 板内横向平顺性 END) AS [板内DQ ＜-4 & ≥-5],
COUNT(CASE WHEN 板内横向平顺性 < -5 AND 板内横向平顺性 >= -6 THEN 板内横向平顺性 END) AS [板内DQ ＜-5 & ≥-6],
COUNT(CASE WHEN 板内横向平顺性 < -6 AND 板内横向平顺性 >= -7 THEN 板内横向平顺性 END) AS [板内DQ ＜-6 & ≥-7],
COUNT(CASE WHEN 板内横向平顺性 < -7 AND 板内横向平顺性 >= -8 THEN 板内横向平顺性 END) AS [板内DQ ＜-7 & ≥-8],
COUNT(CASE WHEN 板内高程平顺性 >= 0 AND 板内高程平顺性 <= 1 THEN 板内高程平顺性 END) AS [板内DH ≥0 & ≤1],
COUNT(CASE WHEN 板内高程平顺性 > 1 AND 板内高程平顺性 <= 2 THEN 板内高程平顺性 END) AS [板内DH ＞1 & ≤2],
COUNT(CASE WHEN 板内高程平顺性 > 2 AND 板内高程平顺性 <= 3 THEN 板内高程平顺性 END) AS [板内DH ＞2 & ≤3],
COUNT(CASE WHEN 板内高程平顺性 > 3 AND 板内高程平顺性 <= 4 THEN 板内高程平顺性 END) AS [板内DH ＞3 & ≤4],
COUNT(CASE WHEN 板内高程平顺性 < 0 AND 板内高程平顺性 >= -1 THEN 板内高程平顺性 END) AS [板内DH ＜0 & ≥-1],
COUNT(CASE WHEN 板内高程平顺性 < -1 AND 板内高程平顺性 >= -2 THEN 板内高程平顺性 END) AS [板内DH ＜-1 & ≥-2],
COUNT(CASE WHEN 板内高程平顺性 < -2 AND 板内高程平顺性 >= -3 THEN 板内高程平顺性 END) AS [板内DH ＜-2 & ≥-3],
COUNT(CASE WHEN 板内高程平顺性 < -3 AND 板内高程平顺性 >= -4 THEN 板内高程平顺性 END) AS [板内DH ＜-3 & ≥-4],
COUNT(CASE WHEN 板内高程平顺性 < -4 AND 板内高程平顺性 >= -5 THEN 板内高程平顺性 END) AS [板内DH ＜-4 & ≥-5],
COUNT(CASE WHEN 板内高程平顺性 < -5 AND 板内高程平顺性 >= -6 THEN 板内高程平顺性 END) AS [板内DH ＜-5 & ≥-6],
COUNT(CASE WHEN 板内高程平顺性 < -6 AND 板内高程平顺性 >= -7 THEN 板内高程平顺性 END) AS [板内DH ＜-6 & ≥-7],
COUNT(CASE WHEN 板内高程平顺性 < -7 AND 板内高程平顺性 >= -8 THEN 板内高程平顺性 END) AS [板内DH ＜-7 & ≥-8],
COUNT(CASE WHEN 板间横向平顺性 >= 0 AND 板间横向平顺性 <= 1 THEN 板间横向平顺性 END) AS [板间DQ ≥0 & ≤1],
COUNT(CASE WHEN 板间横向平顺性 > 1 AND 板间横向平顺性 <= 2 THEN 板间横向平顺性 END) AS [板间DQ ＞1 & ≤2],
COUNT(CASE WHEN 板间横向平顺性 > 2 AND 板间横向平顺性 <= 3 THEN 板间横向平顺性 END) AS [板间DQ ＞2 & ≤3],
COUNT(CASE WHEN 板间横向平顺性 > 3 AND 板间横向平顺性 <= 4 THEN 板间横向平顺性 END) AS [板间DQ ＞3 & ≤4],
COUNT(CASE WHEN 板间横向平顺性 > 4 AND 板间横向平顺性 <= 5 THEN 板间横向平顺性 END) AS [板间DQ ＞4 & ≤5],
COUNT(CASE WHEN 板间横向平顺性 > 5 AND 板间横向平顺性 <= 6 THEN 板间横向平顺性 END) AS [板间DQ ＞5 & ≤6],
COUNT(CASE WHEN 板间横向平顺性 > 6 AND 板间横向平顺性 <= 7 THEN 板间横向平顺性 END) AS [板间DQ ＞6 & ≤7],
COUNT(CASE WHEN 板间横向平顺性 > 7 AND 板间横向平顺性 <= 8 THEN 板间横向平顺性 END) AS [板间DQ ＞7 & ≤8],
COUNT(CASE WHEN 板间横向平顺性 < 0 AND 板间横向平顺性 >= -1 THEN 板间横向平顺性 END) AS [板间DQ ＜0 & ≥-1],
COUNT(CASE WHEN 板间横向平顺性 < -1 AND 板间横向平顺性 >= -2 THEN 板间横向平顺性 END) AS [板间DQ ＜-1 & ≥-2],
COUNT(CASE WHEN 板间横向平顺性 < -2 AND 板间横向平顺性 >= -3 THEN 板间横向平顺性 END) AS [板间DQ ＜-2 & ≥-3],
COUNT(CASE WHEN 板间横向平顺性 < -3 AND 板间横向平顺性 >= -4 THEN 板间横向平顺性 END) AS [板间DQ ＜-3 & ≥-4],
COUNT(CASE WHEN 板间横向平顺性 < -4 AND 板间横向平顺性 >= -5 THEN 板间横向平顺性 END) AS [板间DQ ＜-4 & ≥-5],
COUNT(CASE WHEN 板间横向平顺性 < -5 AND 板间横向平顺性 >= -6 THEN 板间横向平顺性 END) AS [板间DQ ＜-5 & ≥-6],
COUNT(CASE WHEN 板间横向平顺性 < -6 AND 板间横向平顺性 >= -7 THEN 板间横向平顺性 END) AS [板间DQ ＜-6 & ≥-7],
COUNT(CASE WHEN 板间横向平顺性 < -7 AND 板间横向平顺性 >= -8 THEN 板间横向平顺性 END) AS [板间DQ ＜-7 & ≥-8],
COUNT(CASE WHEN 板间高程平顺性 >= 0 AND 板间高程平顺性 <= 1 THEN 板间高程平顺性 END) AS [板间DH ≥0 & ≤1],
COUNT(CASE WHEN 板间高程平顺性 > 1 AND 板间高程平顺性 <= 2 THEN 板间高程平顺性 END) AS [板间DH ＞1 & ≤2],
COUNT(CASE WHEN 板间高程平顺性 > 2 AND 板间高程平顺性 <= 3 THEN 板间高程平顺性 END) AS [板间DH ＞2 & ≤3],
COUNT(CASE WHEN 板间高程平顺性 > 3 AND 板间高程平顺性 <= 4 THEN 板间高程平顺性 END) AS [板间DH ＞3 & ≤4],
COUNT(CASE WHEN 板间高程平顺性 < 0 AND 板间高程平顺性 >= -1 THEN 板间高程平顺性 END) AS [板间DH ＜0 & ≥-1],
COUNT(CASE WHEN 板间高程平顺性 < -1 AND 板间高程平顺性 >= -2 THEN 板间高程平顺性 END) AS [板间DH ＜-1 & ≥-2],
COUNT(CASE WHEN 板间高程平顺性 < -2 AND 板间高程平顺性 >= -3 THEN 板间高程平顺性 END) AS [板间DH ＜-2 & ≥-3],
COUNT(CASE WHEN 板间高程平顺性 < -3 AND 板间高程平顺性 >= -4 THEN 板间高程平顺性 END) AS [板间DH ＜-3 & ≥-4],
COUNT(CASE WHEN 板间高程平顺性 < -4 AND 板间高程平顺性 >= -5 THEN 板间高程平顺性 END) AS [板间DH ＜-4 & ≥-5],
COUNT(CASE WHEN 板间高程平顺性 < -5 AND 板间高程平顺性 >= -6 THEN 板间高程平顺性 END) AS [板间DH ＜-5 & ≥-6],
COUNT(CASE WHEN 板间高程平顺性 < -6 AND 板间高程平顺性 >= -7 THEN 板间高程平顺性 END) AS [板间DH ＜-6 & ≥-7],
COUNT(CASE WHEN 板间高程平顺性 < -7 AND 板间高程平顺性 >= -8 THEN 板间高程平顺性 END) AS [板间DH ＜-7 & ≥-8]
FROM      dbo.tp_retest_orbit_sum
GROUP BY 起点里程


GO
/****** Object:  View [dbo].[tp_road_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_road_down]
AS
SELECT   dbo.tb_road_qty.rq_code AS 数量编号, dbo.tb_road_down.pt_code AS 工点编号, dbo.tb_road_down.rl_code AS 清单编号, 
                dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_road_lst.rl_project AS 工程项目, dbo.tb_road_lst.rl_unit AS 单位, dbo.tb_road_lst.rl_price_lbr AS 劳务单价, 
                dbo.tb_road_qty.rq_qty_dwg_design AS 蓝图设计数量, dbo.tb_road_qty.rq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_road_qty.rq_qty_dwg_design + dbo.tb_road_qty.rq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_road_lst.rl_price_lbr * (dbo.tb_road_qty.rq_qty_dwg_design + dbo.tb_road_qty.rq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_road_qty.rq_qty_doe_design AS 已完设计数量, 
                dbo.tb_road_qty.rq_qty_doe_change AS 已完变更数量, 
                dbo.tb_road_qty.rq_qty_doe_design + dbo.tb_road_qty.rq_qty_doe_change AS 已完计算数量, 
                dbo.tb_road_lst.rl_price_lbr * (dbo.tb_road_qty.rq_qty_doe_design + dbo.tb_road_qty.rq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_road_down.rd_qty_pre_design AS 上期设计数量, 
                dbo.tb_road_down.rd_qty_pre_change AS 上期变更数量, 
                dbo.tb_road_down.rd_qty_pre_design + dbo.tb_road_down.rd_qty_pre_change AS 上期计价数量, 
                dbo.tb_road_lst.rl_price_lbr * (dbo.tb_road_down.rd_qty_pre_design + dbo.tb_road_down.rd_qty_pre_change) 
                AS 上期计价金额, dbo.tb_road_down.rd_qty_cur_design AS 本期设计数量, 
                dbo.tb_road_down.rd_qty_cur_change AS 本期变更数量, 
                dbo.tb_road_down.rd_qty_cur_design + dbo.tb_road_down.rd_qty_cur_change AS 本期计价数量, 
                dbo.tb_road_lst.rl_price_lbr * (dbo.tb_road_down.rd_qty_cur_design + dbo.tb_road_down.rd_qty_cur_change) 
                AS 本期计价金额, dbo.tb_road_down.rd_qty_pre_design + dbo.tb_road_down.rd_qty_cur_design AS 开累设计数量, 
                dbo.tb_road_down.rd_qty_pre_change + dbo.tb_road_down.rd_qty_cur_change AS 开累变更数量, 
                dbo.tb_road_down.rd_qty_pre_design + dbo.tb_road_down.rd_qty_cur_design + dbo.tb_road_down.rd_qty_pre_change + dbo.tb_road_down.rd_qty_cur_change
                 AS 开累计价数量, 
                dbo.tb_road_lst.rl_price_lbr * (dbo.tb_road_down.rd_qty_pre_design + dbo.tb_road_down.rd_qty_cur_design + dbo.tb_road_down.rd_qty_pre_change
                 + dbo.tb_road_down.rd_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_road_down INNER JOIN
                dbo.tb_road_qty ON dbo.tb_road_down.pt_code = dbo.tb_road_qty.pt_code AND 
                dbo.tb_road_down.rl_code = dbo.tb_road_qty.rl_code INNER JOIN
                dbo.tb_points ON dbo.tb_road_down.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_road_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_points AS tb_points_1 ON dbo.tb_road_down.pt_code = tb_points_1.pt_code AND 
                dbo.tb_road_qty.pt_code = tb_points_1.pt_code INNER JOIN
                dbo.tb_road_lst ON dbo.tb_road_down.rl_code = dbo.tb_road_lst.rl_code AND 
                dbo.tb_road_qty.rl_code = dbo.tb_road_lst.rl_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_road_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_road_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tp_road_down_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_road_down_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_road_down INNER JOIN
                dbo.tb_points ON dbo.tp_road_down.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_road_down_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_road_down_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(劳务单价) AS 劳务单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, SUM(上期计价金额) AS 上期金额, 
                SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, SUM(开累计价数量) AS 开累数量, 
                SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_road_down
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_tunnel_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_tunnel_down]
AS
SELECT   dbo.tb_tunnel_qty.tq_code AS 数量编号, dbo.tb_tunnel_down.pt_code AS 工点编号, 
                dbo.tb_tunnel_down.tl_code AS 清单编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_tunnel_lst.tl_project AS 工程项目, dbo.tb_tunnel_lst.tl_unit AS 单位, dbo.tb_tunnel_lst.tl_price_lbr AS 劳务单价, 
                dbo.tb_tunnel_qty.tq_qty_dwg_design AS 蓝图设计数量, dbo.tb_tunnel_qty.tq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_tunnel_qty.tq_qty_dwg_design + dbo.tb_tunnel_qty.tq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_tunnel_lst.tl_price_lbr * (dbo.tb_tunnel_qty.tq_qty_dwg_design + dbo.tb_tunnel_qty.tq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_tunnel_qty.tq_qty_doe_design AS 已完设计数量, 
                dbo.tb_tunnel_qty.tq_qty_doe_change AS 已完变更数量, 
                dbo.tb_tunnel_qty.tq_qty_doe_design + dbo.tb_tunnel_qty.tq_qty_doe_change AS 已完计算数量, 
                dbo.tb_tunnel_lst.tl_price_lbr * (dbo.tb_tunnel_qty.tq_qty_doe_design + dbo.tb_tunnel_qty.tq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_tunnel_down.td_qty_pre_design AS 上期设计数量, 
                dbo.tb_tunnel_down.td_qty_pre_change AS 上期变更数量, 
                dbo.tb_tunnel_down.td_qty_pre_design + dbo.tb_tunnel_down.td_qty_pre_change AS 上期计价数量, 
                dbo.tb_tunnel_lst.tl_price_lbr * (dbo.tb_tunnel_down.td_qty_pre_design + dbo.tb_tunnel_down.td_qty_pre_change) 
                AS 上期计价金额, dbo.tb_tunnel_down.td_qty_cur_design AS 本期设计数量, 
                dbo.tb_tunnel_down.td_qty_cur_change AS 本期变更数量, 
                dbo.tb_tunnel_down.td_qty_cur_design + dbo.tb_tunnel_down.td_qty_cur_change AS 本期计价数量, 
                dbo.tb_tunnel_lst.tl_price_lbr * (dbo.tb_tunnel_down.td_qty_cur_design + dbo.tb_tunnel_down.td_qty_cur_change) 
                AS 本期计价金额, dbo.tb_tunnel_down.td_qty_pre_design + dbo.tb_tunnel_down.td_qty_cur_design AS 开累设计数量, 
                dbo.tb_tunnel_down.td_qty_pre_change + dbo.tb_tunnel_down.td_qty_cur_change AS 开累变更数量, 
                dbo.tb_tunnel_down.td_qty_pre_design + dbo.tb_tunnel_down.td_qty_cur_design + dbo.tb_tunnel_down.td_qty_pre_change
                 + dbo.tb_tunnel_down.td_qty_cur_change AS 开累计价数量, 
                dbo.tb_tunnel_lst.tl_price_lbr * (dbo.tb_tunnel_down.td_qty_pre_design + dbo.tb_tunnel_down.td_qty_cur_design + dbo.tb_tunnel_down.td_qty_pre_change
                 + dbo.tb_tunnel_down.td_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_tunnel_down INNER JOIN
                dbo.tb_tunnel_qty ON dbo.tb_tunnel_down.pt_code = dbo.tb_tunnel_qty.pt_code AND 
                dbo.tb_tunnel_down.tl_code = dbo.tb_tunnel_qty.tl_code INNER JOIN
                dbo.tb_tunnel_lst ON dbo.tb_tunnel_down.tl_code = dbo.tb_tunnel_lst.tl_code AND 
                dbo.tb_tunnel_qty.tl_code = dbo.tb_tunnel_lst.tl_code INNER JOIN
                dbo.tb_points ON dbo.tb_tunnel_down.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_tunnel_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_tunnel_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_tunnel_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tp_tunnel_down_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_tunnel_down_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_tunnel_down INNER JOIN
                dbo.tb_points ON dbo.tp_tunnel_down.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_tunnel_down_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_tunnel_down_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(劳务单价) AS 劳务单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, 
                SUM(上期计价金额) AS 上期金额, SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, 
                SUM(开累计价数量) AS 开累数量, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_tunnel_down
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_bridge_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_bridge_down]
AS
SELECT   dbo.tb_bridge_qty.bq_code AS 数量编号, dbo.tb_bridge_down.pt_code AS 工点编号, 
                dbo.tb_bridge_down.bl_code AS 清单编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_bridge_lst.bl_project AS 工程项目, dbo.tb_bridge_lst.bl_unit AS 单位, dbo.tb_bridge_lst.bl_price_lbr AS 劳务单价, 
                dbo.tb_bridge_qty.bq_qty_dwg_design AS 蓝图设计数量, dbo.tb_bridge_qty.bq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_bridge_qty.bq_qty_dwg_design + dbo.tb_bridge_qty.bq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_bridge_lst.bl_price_lbr * (dbo.tb_bridge_qty.bq_qty_dwg_design + dbo.tb_bridge_qty.bq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_bridge_qty.bq_qty_doe_design AS 已完设计数量, 
                dbo.tb_bridge_qty.bq_qty_doe_change AS 已完变更数量, 
                dbo.tb_bridge_qty.bq_qty_doe_design + dbo.tb_bridge_qty.bq_qty_doe_change AS 已完计算数量, 
                dbo.tb_bridge_lst.bl_price_lbr * (dbo.tb_bridge_qty.bq_qty_doe_design + dbo.tb_bridge_qty.bq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_bridge_down.bd_qty_pre_design AS 上期设计数量, 
                dbo.tb_bridge_down.bd_qty_pre_change AS 上期变更数量, 
                dbo.tb_bridge_down.bd_qty_pre_design + dbo.tb_bridge_down.bd_qty_pre_change AS 上期计价数量, 
                dbo.tb_bridge_lst.bl_price_lbr * (dbo.tb_bridge_down.bd_qty_pre_design + dbo.tb_bridge_down.bd_qty_pre_change) 
                AS 上期计价金额, dbo.tb_bridge_down.bd_qty_cur_design AS 本期设计数量, 
                dbo.tb_bridge_down.bd_qty_cur_change AS 本期变更数量, 
                dbo.tb_bridge_down.bd_qty_cur_design + dbo.tb_bridge_down.bd_qty_cur_change AS 本期计价数量, 
                dbo.tb_bridge_lst.bl_price_lbr * (dbo.tb_bridge_down.bd_qty_cur_design + dbo.tb_bridge_down.bd_qty_cur_change) 
                AS 本期计价金额, dbo.tb_bridge_down.bd_qty_pre_design + dbo.tb_bridge_down.bd_qty_cur_design AS 开累设计数量, 
                dbo.tb_bridge_down.bd_qty_pre_change + dbo.tb_bridge_down.bd_qty_cur_change AS 开累变更数量, 
                dbo.tb_bridge_down.bd_qty_pre_design + dbo.tb_bridge_down.bd_qty_cur_design + dbo.tb_bridge_down.bd_qty_pre_change
                 + dbo.tb_bridge_down.bd_qty_cur_change AS 开累计价数量, 
                dbo.tb_bridge_lst.bl_price_lbr * (dbo.tb_bridge_down.bd_qty_pre_design + dbo.tb_bridge_down.bd_qty_cur_design + dbo.tb_bridge_down.bd_qty_pre_change
                 + dbo.tb_bridge_down.bd_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_bridge_down INNER JOIN
                dbo.tb_bridge_qty ON dbo.tb_bridge_down.pt_code = dbo.tb_bridge_qty.pt_code AND 
                dbo.tb_bridge_down.bl_code = dbo.tb_bridge_qty.bl_code INNER JOIN
                dbo.tb_points ON dbo.tb_bridge_down.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_bridge_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_bridge_lst ON dbo.tb_bridge_down.bl_code = dbo.tb_bridge_lst.bl_code AND 
                dbo.tb_bridge_qty.bl_code = dbo.tb_bridge_lst.bl_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_bridge_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_bridge_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tp_bridge_down_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_bridge_down_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, 
SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_bridge_down INNER JOIN
                dbo.tb_points ON dbo.tp_bridge_down.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_bridge_down_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_bridge_down_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(劳务单价) AS 劳务单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, 
                SUM(上期计价金额) AS 上期金额, SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, 
                SUM(开累计价数量) AS 开累数量, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_bridge_down
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_orbital_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_orbital_down]
AS
SELECT   dbo.tb_orbital_qty.oq_code AS 数量编号, dbo.tb_orbital_down.pt_code AS 工点编号, 
                dbo.tb_orbital_down.ol_code AS 清单编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_orbital_lst.ol_project AS 工程项目, dbo.tb_orbital_lst.ol_unit AS 单位, dbo.tb_orbital_lst.ol_price_lbr AS 劳务单价, 
                dbo.tb_orbital_qty.oq_qty_dwg_design AS 蓝图设计数量, dbo.tb_orbital_qty.oq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_orbital_qty.oq_qty_dwg_design + dbo.tb_orbital_qty.oq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_orbital_lst.ol_price_lbr * (dbo.tb_orbital_qty.oq_qty_dwg_design + dbo.tb_orbital_qty.oq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_orbital_qty.oq_qty_doe_design AS 已完设计数量, 
                dbo.tb_orbital_qty.oq_qty_doe_change AS 已完变更数量, 
                dbo.tb_orbital_qty.oq_qty_doe_design + dbo.tb_orbital_qty.oq_qty_doe_change AS 已完计算数量, 
                dbo.tb_orbital_lst.ol_price_lbr * (dbo.tb_orbital_qty.oq_qty_doe_design + dbo.tb_orbital_qty.oq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_orbital_down.od_qty_pre_design AS 上期设计数量, 
                dbo.tb_orbital_down.od_qty_pre_change AS 上期变更数量, 
                dbo.tb_orbital_down.od_qty_pre_design + dbo.tb_orbital_down.od_qty_pre_change AS 上期计价数量, 
                dbo.tb_orbital_lst.ol_price_lbr * (dbo.tb_orbital_down.od_qty_pre_design + dbo.tb_orbital_down.od_qty_pre_change) 
                AS 上期计价金额, dbo.tb_orbital_down.od_qty_cur_design AS 本期设计数量, 
                dbo.tb_orbital_down.od_qty_cur_change AS 本期变更数量, 
                dbo.tb_orbital_down.od_qty_cur_design + dbo.tb_orbital_down.od_qty_cur_change AS 本期计价数量, 
                dbo.tb_orbital_lst.ol_price_lbr * (dbo.tb_orbital_down.od_qty_cur_design + dbo.tb_orbital_down.od_qty_cur_change) 
                AS 本期计价金额, dbo.tb_orbital_down.od_qty_pre_design + dbo.tb_orbital_down.od_qty_cur_design AS 开累设计数量, 
                dbo.tb_orbital_down.od_qty_pre_change + dbo.tb_orbital_down.od_qty_cur_change AS 开累变更数量, 
                dbo.tb_orbital_down.od_qty_pre_design + dbo.tb_orbital_down.od_qty_cur_design + dbo.tb_orbital_down.od_qty_pre_change
                 + dbo.tb_orbital_down.od_qty_cur_change AS 开累计价数量, 
                dbo.tb_orbital_lst.ol_price_lbr * (dbo.tb_orbital_down.od_qty_pre_design + dbo.tb_orbital_down.od_qty_cur_design + dbo.tb_orbital_down.od_qty_pre_change
                 + dbo.tb_orbital_down.od_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_orbital_down INNER JOIN
                dbo.tb_orbital_qty ON dbo.tb_orbital_down.pt_code = dbo.tb_orbital_qty.pt_code AND 
                dbo.tb_orbital_down.ol_code = dbo.tb_orbital_qty.ol_code INNER JOIN
                dbo.tb_orbital_lst ON dbo.tb_orbital_down.ol_code = dbo.tb_orbital_lst.ol_code AND 
                dbo.tb_orbital_qty.ol_code = dbo.tb_orbital_lst.ol_code INNER JOIN
                dbo.tb_points ON dbo.tb_orbital_down.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_orbital_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_orbital_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_orbital_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tp_orbital_down_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_orbital_down_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_orbital_down INNER JOIN
                dbo.tb_points ON dbo.tp_orbital_down.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_orbital_down_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_orbital_down_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(劳务单价) AS 劳务单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, 
                SUM(上期计价金额) AS 上期金额, SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, 
                SUM(开累计价数量) AS 开累数量, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_orbital_down
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_yard_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_yard_down]
AS
SELECT   dbo.tb_yard_qty.yq_code AS 数量编号, dbo.tb_yard_down.pt_code AS 工点编号, 
                dbo.tb_yard_down.yl_code AS 清单编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_yard_lst.yl_project AS 工程项目, dbo.tb_yard_lst.yl_unit AS 单位, dbo.tb_yard_lst.yl_price_lbr AS 劳务单价, 
                dbo.tb_yard_qty.yq_qty_dwg_design AS 蓝图设计数量, dbo.tb_yard_qty.yq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_yard_qty.yq_qty_dwg_design + dbo.tb_yard_qty.yq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_yard_lst.yl_price_lbr * (dbo.tb_yard_qty.yq_qty_dwg_design + dbo.tb_yard_qty.yq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_yard_qty.yq_qty_doe_design AS 已完设计数量, 
                dbo.tb_yard_qty.yq_qty_doe_change AS 已完变更数量, 
                dbo.tb_yard_qty.yq_qty_doe_design + dbo.tb_yard_qty.yq_qty_doe_change AS 已完计算数量, 
                dbo.tb_yard_lst.yl_price_lbr * (dbo.tb_yard_qty.yq_qty_doe_design + dbo.tb_yard_qty.yq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_yard_down.yd_qty_pre_design AS 上期设计数量, 
                dbo.tb_yard_down.yd_qty_pre_change AS 上期变更数量, 
                dbo.tb_yard_down.yd_qty_pre_design + dbo.tb_yard_down.yd_qty_pre_change AS 上期计价数量, 
                dbo.tb_yard_lst.yl_price_lbr * (dbo.tb_yard_down.yd_qty_pre_design + dbo.tb_yard_down.yd_qty_pre_change) 
                AS 上期计价金额, dbo.tb_yard_down.yd_qty_cur_design AS 本期设计数量, 
                dbo.tb_yard_down.yd_qty_cur_change AS 本期变更数量, 
                dbo.tb_yard_down.yd_qty_cur_design + dbo.tb_yard_down.yd_qty_cur_change AS 本期计价数量, 
                dbo.tb_yard_lst.yl_price_lbr * (dbo.tb_yard_down.yd_qty_cur_design + dbo.tb_yard_down.yd_qty_cur_change) 
                AS 本期计价金额, dbo.tb_yard_down.yd_qty_pre_design + dbo.tb_yard_down.yd_qty_cur_design AS 开累设计数量, 
                dbo.tb_yard_down.yd_qty_pre_change + dbo.tb_yard_down.yd_qty_cur_change AS 开累变更数量, 
                dbo.tb_yard_down.yd_qty_pre_design + dbo.tb_yard_down.yd_qty_cur_design + dbo.tb_yard_down.yd_qty_pre_change +
                 dbo.tb_yard_down.yd_qty_cur_change AS 开累计价数量, 
                dbo.tb_yard_lst.yl_price_lbr * (dbo.tb_yard_down.yd_qty_pre_design + dbo.tb_yard_down.yd_qty_cur_design + dbo.tb_yard_down.yd_qty_pre_change
                 + dbo.tb_yard_down.yd_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_yard_down INNER JOIN
                dbo.tb_yard_qty ON dbo.tb_yard_down.pt_code = dbo.tb_yard_qty.pt_code AND 
                dbo.tb_yard_down.yl_code = dbo.tb_yard_qty.yl_code INNER JOIN
                dbo.tb_yard_lst ON dbo.tb_yard_down.yl_code = dbo.tb_yard_lst.yl_code AND 
                dbo.tb_yard_qty.yl_code = dbo.tb_yard_lst.yl_code INNER JOIN
                dbo.tb_points ON dbo.tb_yard_down.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_yard_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_yard_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_yard_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tp_yard_down_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_yard_down_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_yard_down INNER JOIN
                dbo.tb_points ON dbo.tp_yard_down.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_yard_down_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_yard_down_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(劳务单价) AS 劳务单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, 
                SUM(上期计价金额) AS 上期金额, SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, 
                SUM(开累计价数量) AS 开累数量, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_yard_down
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_temp_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_temp_down]
AS
SELECT   dbo.tb_temp_qty.pq_code AS 数量编号, dbo.tb_temp_down.pt_code AS 工点编号, 
                dbo.tb_temp_down.pl_code AS 清单编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_temp_lst.pl_project AS 工程项目, dbo.tb_temp_lst.pl_unit AS 单位, dbo.tb_temp_lst.pl_price_lbr AS 劳务单价, 
                dbo.tb_temp_qty.pq_qty_dwg_design AS 蓝图设计数量, dbo.tb_temp_qty.pq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_temp_qty.pq_qty_dwg_design + dbo.tb_temp_qty.pq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_temp_lst.pl_price_lbr * (dbo.tb_temp_qty.pq_qty_dwg_design + dbo.tb_temp_qty.pq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_temp_qty.pq_qty_doe_design AS 已完设计数量, 
                dbo.tb_temp_qty.pq_qty_doe_change AS 已完变更数量, 
                dbo.tb_temp_qty.pq_qty_doe_design + dbo.tb_temp_qty.pq_qty_doe_change AS 已完计算数量, 
                dbo.tb_temp_lst.pl_price_lbr * (dbo.tb_temp_qty.pq_qty_doe_design + dbo.tb_temp_qty.pq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_temp_down.pd_qty_pre_design AS 上期设计数量, 
                dbo.tb_temp_down.pd_qty_pre_change AS 上期变更数量, 
                dbo.tb_temp_down.pd_qty_pre_design + dbo.tb_temp_down.pd_qty_pre_change AS 上期计价数量, 
                dbo.tb_temp_lst.pl_price_lbr * (dbo.tb_temp_down.pd_qty_pre_design + dbo.tb_temp_down.pd_qty_pre_change) 
                AS 上期计价金额, dbo.tb_temp_down.pd_qty_cur_design AS 本期设计数量, 
                dbo.tb_temp_down.pd_qty_cur_change AS 本期变更数量, 
                dbo.tb_temp_down.pd_qty_cur_design + dbo.tb_temp_down.pd_qty_cur_change AS 本期计价数量, 
                dbo.tb_temp_lst.pl_price_lbr * (dbo.tb_temp_down.pd_qty_cur_design + dbo.tb_temp_down.pd_qty_cur_change) 
                AS 本期计价金额, dbo.tb_temp_down.pd_qty_pre_design + dbo.tb_temp_down.pd_qty_cur_design AS 开累设计数量, 
                dbo.tb_temp_down.pd_qty_pre_change + dbo.tb_temp_down.pd_qty_cur_change AS 开累变更数量, 
                dbo.tb_temp_down.pd_qty_pre_design + dbo.tb_temp_down.pd_qty_cur_design + dbo.tb_temp_down.pd_qty_pre_change
                 + dbo.tb_temp_down.pd_qty_cur_change AS 开累计价数量, 
                dbo.tb_temp_lst.pl_price_lbr * (dbo.tb_temp_down.pd_qty_pre_design + dbo.tb_temp_down.pd_qty_cur_design + dbo.tb_temp_down.pd_qty_pre_change
                 + dbo.tb_temp_down.pd_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_temp_down INNER JOIN
                dbo.tb_temp_qty ON dbo.tb_temp_down.pt_code = dbo.tb_temp_qty.pt_code AND 
                dbo.tb_temp_down.pl_code = dbo.tb_temp_qty.pl_code INNER JOIN
                dbo.tb_temp_lst ON dbo.tb_temp_down.pl_code = dbo.tb_temp_lst.pl_code AND 
                dbo.tb_temp_qty.pl_code = dbo.tb_temp_lst.pl_code INNER JOIN
                dbo.tb_points ON dbo.tb_temp_down.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_temp_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_temp_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_temp_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tp_temp_down_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_temp_down_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_temp_down INNER JOIN
                dbo.tb_points ON dbo.tp_temp_down.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_temp_down_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_temp_down_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, 
MIN(单位) AS 单位, MIN(劳务单价) AS 劳务单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, 
SUM(已完计算数量) AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) 
AS 上期数量, SUM(上期计价金额) AS 上期金额, SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, 
SUM(开累计价数量) AS 开累数量, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_temp_down
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tv_finance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_finance]
AS
SELECT   dbo.tb_finance.p_code AS 编号, dbo.tb_finance.p_date AS 日期, dbo.tb_member.m_name AS 姓名, 
                dbo.tb_funds.f_name AS 款项, dbo.tb_funds.f_category AS 类别, dbo.tb_funds.f_business AS 商家, 
                dbo.tb_funds.f_unit AS 单位, dbo.tb_finance.p_qty AS 数量, dbo.tb_funds.f_price AS 单价, 
                CASE WHEN tb_finance.p_type = '收入' THEN tb_finance.p_money ELSE - tb_finance.p_money END AS 金额, 
                dbo.tb_finance.p_type AS 收支, dbo.tb_finance.p_method AS 方式, dbo.tb_finance.p_info AS 备注
FROM      dbo.tb_finance INNER JOIN
                dbo.tb_funds ON dbo.tb_finance.f_code = dbo.tb_funds.f_code INNER JOIN
                dbo.tb_member ON dbo.tb_finance.m_code = dbo.tb_member.m_code

GO
/****** Object:  View [dbo].[tp_finance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_finance]
AS
SELECT   TOP (100) PERCENT 收支, 姓名, 日期, 类别, SUM(金额) AS 金额, 方式
FROM      dbo.tv_finance
GROUP BY 收支, 姓名, 日期, 类别, 方式
ORDER BY 姓名

GO
/****** Object:  View [dbo].[vT_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vT_contract]
AS
SELECT  TOP (100) PERCENT dbo.T.id, MIN(dbo.tb_contract.ct_id) AS ct_id, dbo.tb_contract.ct_code, MIN(dbo.tb_contract.ct_name) 
                   AS ct_name, MIN(dbo.tb_contract.ct_unit) AS ct_unit, MIN(dbo.tb_contract.ct_qty) AS ct_qty, MIN(dbo.tb_contract.ct_price) 
                   AS ct_price, MIN(dbo.tb_contract.ct_money) AS ct_money, MIN(dbo.tb_contract.ct_info) AS ct_info
FROM      dbo.T LEFT OUTER JOIN
                   dbo.tb_contract ON dbo.T.code = dbo.tb_contract.ct_code
GROUP BY dbo.T.id, dbo.tb_contract.ct_code
ORDER BY dbo.T.id

GO
/****** Object:  View [dbo].[vT_budget]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vT_budget]
AS
SELECT  TOP (100) PERCENT A.id, A.ct_code, MIN(B.ct_id) AS ct_id, MIN(B.bg_code) AS bg_code, MIN(B.bg_id) AS bg_id, 
                   MIN(B.bg_name) AS bg_name, MIN(B.bg_unit) AS bg_unit, MIN(B.bg_rate) AS bg_rate, MIN(B.bg_qty) AS bg_qty, 
                   MIN(B.bg_price) AS bg_price, MIN(B.bg_money) AS bg_money, MIN(B.bg_info) AS bg_info
FROM      dbo.vT_contract AS A LEFT OUTER JOIN
                   dbo.tb_budget AS B ON A.ct_id = B.ct_id
GROUP BY A.id, A.ct_code
ORDER BY A.id

GO
/****** Object:  View [dbo].[tv_sys_steel_qty_tmp]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_steel_qty_tmp]
AS
SELECT   dbo.tb_sys_steel_qty.ssq_id, dbo.tb_sys_steel_qty.hpi_pid, dbo.tb_sys_steel_qty.hpi_id, 
                dbo.tb_highway_partitem.hpi_node, dbo.tb_sys_steel_qty.spi_id, dbo.tb_sys_partitem.spi_node, 
                dbo.tb_sys_steel_qty.ssl_code, dbo.tb_sys_steel_qty.ssl_describe, dbo.tb_sys_steel_qty.ssq_number, 
                dbo.tb_sys_steel_qty.ssq_type, dbo.tb_sys_steel_qty.ssq_diameter, dbo.tb_sys_steel_qty.ssq_len_single, 
                dbo.tb_sys_steel_qty.ssq_count, dbo.tb_sys_steel_qty.ssq_len_total, dbo.tb_sys_steel_qty.ssq_mg_single, 
                dbo.tb_sys_steel_qty.ssq_mg_total, dbo.tb_sys_steel_qty.ssq_entire_m, dbo.tb_sys_steel_qty.ssq_entire_v, 
                dbo.tb_sys_steel_qty.ssq_sub_m, dbo.tb_sys_steel_qty.ssq_sub_v, dbo.tb_sys_steel_qty.ssq_info
FROM      dbo.tb_sys_steel_qty INNER JOIN
                dbo.tb_sys_partitem ON dbo.tb_sys_steel_qty.spi_id = dbo.tb_sys_partitem.spi_id INNER JOIN
                dbo.tb_highway_partitem ON dbo.tb_sys_steel_qty.hpi_id = dbo.tb_highway_partitem.hpi_id

GO
/****** Object:  View [dbo].[tp_sys_steel_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_sys_steel_qty]
AS
SELECT   dbo.tv_sys_steel_qty_tmp.ssq_id AS 数量ID, dbo.tb_highway_partitem.hpi_node AS 桥梁名称, 
                dbo.tv_sys_steel_qty_tmp.hpi_node AS 墩台号, dbo.tv_sys_steel_qty_tmp.spi_node AS 构建类型, 
                dbo.tv_sys_steel_qty_tmp.ssl_code AS 构件编号, dbo.tv_sys_steel_qty_tmp.ssl_describe AS 构件描述, 
                dbo.tv_sys_steel_qty_tmp.ssq_number AS 钢筋编号, dbo.tv_sys_steel_qty_tmp.ssq_type AS 钢筋类型, 
                dbo.tv_sys_steel_qty_tmp.ssq_diameter AS [钢筋直径(mm)], 
                dbo.tv_sys_steel_qty_tmp.ssq_len_single AS [单根长(cm)], dbo.tv_sys_steel_qty_tmp.ssq_count AS 根数, 
                dbo.tv_sys_steel_qty_tmp.ssq_len_total AS [总长(m)], dbo.tv_sys_steel_qty_tmp.ssq_mg_single AS [单位重(Kg/m)], 
                dbo.tv_sys_steel_qty_tmp.ssq_mg_total AS [总重(Kg)], dbo.tv_sys_steel_qty_tmp.ssq_entire_m AS 承台材质, 
                dbo.tv_sys_steel_qty_tmp.ssq_entire_v AS [承台砼(m3)], dbo.tv_sys_steel_qty_tmp.ssq_sub_m AS 垫层材质, 
                dbo.tv_sys_steel_qty_tmp.ssq_sub_v AS [垫层砼(m3)], dbo.tv_sys_steel_qty_tmp.ssq_info AS 数量备注
FROM      dbo.tv_sys_steel_qty_tmp INNER JOIN
                dbo.tb_highway_partitem ON dbo.tv_sys_steel_qty_tmp.hpi_pid = dbo.tb_highway_partitem.hpi_id

GO
/****** Object:  View [dbo].[tp_retest_rail]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_rail]
AS
SELECT   dbo.tb_retest_rail.rr_code AS 编号, dbo.tb_points.pt_name AS 工点, dbo.tb_points.pt_bstat AS 起点, 
                dbo.tb_points.pt_estat AS 终点, dbo.tb_retest_plate.rp_mark AS 板号, dbo.tb_retest_rail.rr_mileage AS 里程, 
                dbo.tb_retest_rail.rr_left_point AS 左点号, dbo.tb_retest_rail.rr_left_horizon AS 左轨平面, 
                dbo.tb_retest_rail.rr_left_vertical AS 左轨高程, dbo.tb_retest_rail.rr_right_point AS 右点号, 
                dbo.tb_retest_rail.rr_right_horizon AS 右轨平面, dbo.tb_retest_rail.rr_right_vertical AS 右轨高程, 
                dbo.tb_retest_rail.rr_dif_horizon AS 轨距, dbo.tb_retest_rail.rr_dif_vertical AS 水平, 
                dbo.tb_retest_rail.rr_left_dq AS 左轨轨向, dbo.tb_retest_rail.rr_left_dh AS 左轨高低, 
                dbo.tb_retest_rail.rr_right_dq AS 右轨轨向, dbo.tb_retest_rail.rr_right_dh AS 右轨高低, 
                dbo.tb_retest_rail.rr_left_wfp15u_out AS 左轨外挡板, dbo.tb_retest_rail.rr_left_wfp15u_in AS 左轨内挡板, 
                dbo.tb_retest_rail.rr_left_zw692 AS 左轨下垫片, dbo.tb_retest_rail.rr_right_wfp15u_in AS 右轨内挡板, 
                dbo.tb_retest_rail.rr_right_wfp15u_out AS 右轨外挡板, dbo.tb_retest_rail.rr_right_zw692 AS 右轨下垫片, 
                dbo.tb_retest_rail.rr_info AS 备注
FROM      dbo.tb_retest_rail INNER JOIN
                dbo.tb_points ON dbo.tb_retest_rail.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_retest_plate ON dbo.tb_retest_rail.rp_code = dbo.tb_retest_plate.rp_code


GO
/****** Object:  View [dbo].[tp_retest_rail_wfp]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_rail_wfp]
AS
SELECT   A.左编号, A.左轨挡板类型, A.左轨挡板数量, B.右编号, B.右轨挡板类型, B.右轨挡板数量
FROM      (SELECT   ROW_NUMBER() OVER (ORDER BY 左轨外挡板) AS 左编号, MIN(CASE WHEN 左轨外挡板 = 7 THEN 'wfp15u' ELSE 'wfp15u_±' + cast(ABS(左轨外挡板 - 7) 
                AS varchar) END) AS 左轨挡板类型, COUNT(左轨外挡板) AS 左轨挡板数量
FROM      dbo.tp_retest_rail
GROUP BY 左轨外挡板) AS A RIGHT OUTER JOIN
    (SELECT   ROW_NUMBER() OVER (ORDER BY 右轨内挡板) AS 右编号, MIN(CASE WHEN 右轨内挡板 = 9 THEN 'wfp15u' ELSE 'wfp15u_±' + cast(ABS(右轨内挡板 - 9) AS varchar) END) 
AS 右轨挡板类型, COUNT(右轨内挡板) AS 右轨挡板数量
FROM      dbo.tp_retest_rail
GROUP BY 右轨内挡板) AS B ON A.左编号 = B.右编号


GO
/****** Object:  View [dbo].[tp_retest_rail_zw6]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_rail_zw6]
AS
SELECT   A.左编号, A.左轨下垫片类型, A.左轨下垫片数量, B.右编号,B.右轨下垫片类型, B.右轨下垫片数量
FROM      (SELECT   ROW_NUMBER() OVER (ORDER BY 左轨下垫片) AS 左编号, MIN('zw692_' + cast(左轨下垫片 AS varchar)) 
                AS 左轨下垫片类型, COUNT(左轨下垫片) AS 左轨下垫片数量
FROM      dbo.tp_retest_rail
GROUP BY 左轨下垫片) AS A LEFT OUTER JOIN
    (SELECT   ROW_NUMBER() OVER (ORDER BY 右轨下垫片) AS 右编号, MIN('zw692_' + cast(右轨下垫片 AS varchar)) 
AS 右轨下垫片类型, COUNT(右轨下垫片) AS 右轨下垫片数量
FROM      dbo.tp_retest_rail
GROUP BY 右轨下垫片) AS B ON A.左编号 = B.右编号


GO
/****** Object:  View [dbo].[tp_road_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_road_up]
AS
SELECT   dbo.tb_road_qty.rq_code AS 数量编号, dbo.tb_road_up.pt_code AS 工点编号, dbo.tb_road_up.rl_code AS 清单编号, 
                dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_road_lst.rl_project AS 工程项目, dbo.tb_road_lst.rl_unit AS 单位, dbo.tb_road_lst.rl_price_lst AS 清单单价, 
                dbo.tb_road_qty.rq_qty_dwg_design AS 蓝图设计数量, dbo.tb_road_qty.rq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_road_qty.rq_qty_dwg_design + dbo.tb_road_qty.rq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_road_lst.rl_price_lst * (dbo.tb_road_qty.rq_qty_dwg_design + dbo.tb_road_qty.rq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_road_qty.rq_qty_doe_design AS 已完设计数量, 
                dbo.tb_road_qty.rq_qty_doe_change AS 已完变更数量, 
                dbo.tb_road_qty.rq_qty_doe_design + dbo.tb_road_qty.rq_qty_doe_change AS 已完计算数量, 
                dbo.tb_road_lst.rl_price_lst * (dbo.tb_road_qty.rq_qty_doe_design + dbo.tb_road_qty.rq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_road_up.ru_qty_pre_design AS 上期设计数量, 
                dbo.tb_road_up.ru_qty_pre_change AS 上期变更数量, 
                dbo.tb_road_up.ru_qty_pre_design + dbo.tb_road_up.ru_qty_pre_change AS 上期计价数量, 
                dbo.tb_road_lst.rl_price_lst * (dbo.tb_road_up.ru_qty_pre_design + dbo.tb_road_up.ru_qty_pre_change) 
                AS 上期计价金额, dbo.tb_road_up.ru_qty_cur_design AS 本期设计数量, 
                dbo.tb_road_up.ru_qty_cur_change AS 本期变更数量, 
                dbo.tb_road_up.ru_qty_cur_design + dbo.tb_road_up.ru_qty_cur_change AS 本期计价数量, 
                dbo.tb_road_lst.rl_price_lst * (dbo.tb_road_up.ru_qty_cur_design + dbo.tb_road_up.ru_qty_cur_change) 
                AS 本期计价金额, dbo.tb_road_up.ru_qty_pre_design + dbo.tb_road_up.ru_qty_cur_design AS 开累设计数量, 
                dbo.tb_road_up.ru_qty_pre_change + dbo.tb_road_up.ru_qty_cur_change AS 开累变更数量, 
                dbo.tb_road_up.ru_qty_pre_design + dbo.tb_road_up.ru_qty_cur_design + dbo.tb_road_up.ru_qty_pre_change + dbo.tb_road_up.ru_qty_cur_change
                 AS 开累计价数量, 
                dbo.tb_road_lst.rl_price_lst * (dbo.tb_road_up.ru_qty_pre_design + dbo.tb_road_up.ru_qty_cur_design + dbo.tb_road_up.ru_qty_pre_change
                 + dbo.tb_road_up.ru_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_road_up INNER JOIN
                dbo.tb_road_qty ON dbo.tb_road_up.pt_code = dbo.tb_road_qty.pt_code AND 
                dbo.tb_road_up.rl_code = dbo.tb_road_qty.rl_code INNER JOIN
                dbo.tb_points ON dbo.tb_road_up.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_road_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_road_lst ON dbo.tb_road_up.rl_code = dbo.tb_road_lst.rl_code AND 
                dbo.tb_road_qty.rl_code = dbo.tb_road_lst.rl_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_road_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tp_road_up_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_road_up_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(清单单价) AS 清单单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, SUM(上期计价金额) AS 上期金额, 
                SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, SUM(开累计价数量) AS 开累数量, 
                SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_road_up
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_road_up_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_road_up_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_road_up INNER JOIN
                dbo.tb_points ON dbo.tp_road_up.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_bridge_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_bridge_up]
AS
SELECT   dbo.tb_bridge_qty.bq_code AS 数量编号, dbo.tb_bridge_up.pt_code AS 工点编号, 
                dbo.tb_bridge_up.bl_code AS 清单编号, dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_bridge_lst.bl_project AS 工程项目, dbo.tb_bridge_lst.bl_unit AS 单位, dbo.tb_bridge_lst.bl_price_lst AS 清单单价, 
                dbo.tb_bridge_qty.bq_qty_dwg_design AS 蓝图设计数量, dbo.tb_bridge_qty.bq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_bridge_qty.bq_qty_dwg_design + dbo.tb_bridge_qty.bq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_bridge_lst.bl_price_lst * (dbo.tb_bridge_qty.bq_qty_dwg_design + dbo.tb_bridge_qty.bq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_bridge_qty.bq_qty_doe_design AS 已完设计数量, 
                dbo.tb_bridge_qty.bq_qty_doe_change AS 已完变更数量, 
                dbo.tb_bridge_qty.bq_qty_doe_design + dbo.tb_bridge_qty.bq_qty_doe_change AS 已完计算数量, 
                dbo.tb_bridge_lst.bl_price_lst * (dbo.tb_bridge_qty.bq_qty_doe_design + dbo.tb_bridge_qty.bq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_bridge_up.bu_qty_pre_design AS 上期设计数量, 
                dbo.tb_bridge_up.bu_qty_pre_change AS 上期变更数量, 
                dbo.tb_bridge_up.bu_qty_pre_design + dbo.tb_bridge_up.bu_qty_pre_change AS 上期计价数量, 
                dbo.tb_bridge_lst.bl_price_lst * (dbo.tb_bridge_up.bu_qty_pre_design + dbo.tb_bridge_up.bu_qty_pre_change) 
                AS 上期计价金额, dbo.tb_bridge_up.bu_qty_cur_design AS 本期设计数量, 
                dbo.tb_bridge_up.bu_qty_cur_change AS 本期变更数量, 
                dbo.tb_bridge_up.bu_qty_cur_design + dbo.tb_bridge_up.bu_qty_cur_change AS 本期计价数量, 
                dbo.tb_bridge_lst.bl_price_lst * (dbo.tb_bridge_up.bu_qty_cur_design + dbo.tb_bridge_up.bu_qty_cur_change) 
                AS 本期计价金额, dbo.tb_bridge_up.bu_qty_pre_design + dbo.tb_bridge_up.bu_qty_cur_design AS 开累设计数量, 
                dbo.tb_bridge_up.bu_qty_pre_change + dbo.tb_bridge_up.bu_qty_cur_change AS 开累变更数量, 
                dbo.tb_bridge_up.bu_qty_pre_design + dbo.tb_bridge_up.bu_qty_cur_design + dbo.tb_bridge_up.bu_qty_pre_change + dbo.tb_bridge_up.bu_qty_cur_change
                 AS 开累计价数量, 
                dbo.tb_bridge_lst.bl_price_lst * (dbo.tb_bridge_up.bu_qty_pre_design + dbo.tb_bridge_up.bu_qty_cur_design + dbo.tb_bridge_up.bu_qty_pre_change
                 + dbo.tb_bridge_up.bu_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_bridge_up INNER JOIN
                dbo.tb_bridge_qty ON dbo.tb_bridge_up.pt_code = dbo.tb_bridge_qty.pt_code AND 
                dbo.tb_bridge_up.bl_code = dbo.tb_bridge_qty.bl_code INNER JOIN
                dbo.tb_bridge_lst ON dbo.tb_bridge_up.bl_code = dbo.tb_bridge_lst.bl_code AND 
                dbo.tb_bridge_qty.bl_code = dbo.tb_bridge_lst.bl_code INNER JOIN
                dbo.tb_points ON dbo.tb_bridge_up.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_bridge_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_bridge_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tp_bridge_up_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_bridge_up_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(清单单价) AS 清单单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, SUM(上期计价金额) AS 上期金额, 
                SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, SUM(开累计价数量) AS 开累数量, 
                SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_bridge_up
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_bridge_up_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_bridge_up_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(里程桩号) AS 里程桩号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_bridge_up INNER JOIN
                dbo.tb_points ON dbo.tp_bridge_up.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_tunnel_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_tunnel_up]
AS
SELECT   dbo.tb_tunnel_qty.tq_code AS 数量编号, dbo.tb_tunnel_up.pt_code AS 工点编号, dbo.tb_tunnel_up.tl_code AS 清单编号, 
                dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_tunnel_lst.tl_project AS 工程项目, dbo.tb_tunnel_lst.tl_unit AS 单位, dbo.tb_tunnel_lst.tl_price_lst AS 清单单价, 
                dbo.tb_tunnel_qty.tq_qty_dwg_design AS 蓝图设计数量, dbo.tb_tunnel_qty.tq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_tunnel_qty.tq_qty_dwg_design + dbo.tb_tunnel_qty.tq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_tunnel_lst.tl_price_lst * (dbo.tb_tunnel_qty.tq_qty_dwg_design + dbo.tb_tunnel_qty.tq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_tunnel_qty.tq_qty_doe_design AS 已完设计数量, 
                dbo.tb_tunnel_qty.tq_qty_doe_change AS 已完变更数量, 
                dbo.tb_tunnel_qty.tq_qty_doe_design + dbo.tb_tunnel_qty.tq_qty_doe_change AS 已完计算数量, 
                dbo.tb_tunnel_lst.tl_price_lst * (dbo.tb_tunnel_qty.tq_qty_doe_design + dbo.tb_tunnel_qty.tq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_tunnel_up.tu_qty_pre_design AS 上期设计数量, 
                dbo.tb_tunnel_up.tu_qty_pre_change AS 上期变更数量, 
                dbo.tb_tunnel_up.tu_qty_pre_design + dbo.tb_tunnel_up.tu_qty_pre_change AS 上期计价数量, 
                dbo.tb_tunnel_lst.tl_price_lst * (dbo.tb_tunnel_up.tu_qty_pre_design + dbo.tb_tunnel_up.tu_qty_pre_change) 
                AS 上期计价金额, dbo.tb_tunnel_up.tu_qty_cur_design AS 本期设计数量, 
                dbo.tb_tunnel_up.tu_qty_cur_change AS 本期变更数量, 
                dbo.tb_tunnel_up.tu_qty_cur_design + dbo.tb_tunnel_up.tu_qty_cur_change AS 本期计价数量, 
                dbo.tb_tunnel_lst.tl_price_lst * (dbo.tb_tunnel_up.tu_qty_cur_design + dbo.tb_tunnel_up.tu_qty_cur_change) 
                AS 本期计价金额, dbo.tb_tunnel_up.tu_qty_pre_design + dbo.tb_tunnel_up.tu_qty_cur_design AS 开累设计数量, 
                dbo.tb_tunnel_up.tu_qty_pre_change + dbo.tb_tunnel_up.tu_qty_cur_change AS 开累变更数量, 
                dbo.tb_tunnel_up.tu_qty_pre_design + dbo.tb_tunnel_up.tu_qty_cur_design + dbo.tb_tunnel_up.tu_qty_pre_change + dbo.tb_tunnel_up.tu_qty_cur_change
                 AS 开累计价数量, 
                dbo.tb_tunnel_lst.tl_price_lst * (dbo.tb_tunnel_up.tu_qty_pre_design + dbo.tb_tunnel_up.tu_qty_cur_design + dbo.tb_tunnel_up.tu_qty_pre_change
                 + dbo.tb_tunnel_up.tu_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_tunnel_up INNER JOIN
                dbo.tb_tunnel_qty ON dbo.tb_tunnel_up.pt_code = dbo.tb_tunnel_qty.pt_code AND 
                dbo.tb_tunnel_up.tl_code = dbo.tb_tunnel_qty.tl_code INNER JOIN
                dbo.tb_points ON dbo.tb_tunnel_up.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_tunnel_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_tunnel_lst ON dbo.tb_tunnel_up.tl_code = dbo.tb_tunnel_lst.tl_code AND 
                dbo.tb_tunnel_qty.tl_code = dbo.tb_tunnel_lst.tl_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_tunnel_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tp_tunnel_up_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_tunnel_up_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(清单单价) AS 清单单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, SUM(上期计价金额) AS 上期金额, 
                SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, SUM(开累计价数量) AS 开累数量, 
                SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_tunnel_up
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_tunnel_up_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_tunnel_up_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_tunnel_up INNER JOIN
                dbo.tb_points ON dbo.tp_tunnel_up.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_yard_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_yard_up]
AS
SELECT   dbo.tb_yard_qty.yq_code AS 数量编号, dbo.tb_yard_up.pt_code AS 工点编号, dbo.tb_yard_up.yl_code AS 清单编号, 
                dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_yard_lst.yl_project AS 工程项目, dbo.tb_yard_lst.yl_unit AS 单位, dbo.tb_yard_lst.yl_price_lst AS 清单单价, 
                dbo.tb_yard_qty.yq_qty_dwg_design AS 蓝图设计数量, dbo.tb_yard_qty.yq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_yard_qty.yq_qty_dwg_design + dbo.tb_yard_qty.yq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_yard_lst.yl_price_lst * (dbo.tb_yard_qty.yq_qty_dwg_design + dbo.tb_yard_qty.yq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_yard_qty.yq_qty_doe_design AS 已完设计数量, 
                dbo.tb_yard_qty.yq_qty_doe_change AS 已完变更数量, 
                dbo.tb_yard_qty.yq_qty_doe_design + dbo.tb_yard_qty.yq_qty_doe_change AS 已完计算数量, 
                dbo.tb_yard_lst.yl_price_lst * (dbo.tb_yard_qty.yq_qty_doe_design + dbo.tb_yard_qty.yq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_yard_up.yu_qty_pre_design AS 上期设计数量, 
                dbo.tb_yard_up.yu_qty_pre_change AS 上期变更数量, 
                dbo.tb_yard_up.yu_qty_pre_design + dbo.tb_yard_up.yu_qty_pre_change AS 上期计价数量, 
                dbo.tb_yard_lst.yl_price_lst * (dbo.tb_yard_up.yu_qty_pre_design + dbo.tb_yard_up.yu_qty_pre_change) 
                AS 上期计价金额, dbo.tb_yard_up.yu_qty_cur_design AS 本期设计数量, 
                dbo.tb_yard_up.yu_qty_cur_change AS 本期变更数量, 
                dbo.tb_yard_up.yu_qty_cur_design + dbo.tb_yard_up.yu_qty_cur_change AS 本期计价数量, 
                dbo.tb_yard_lst.yl_price_lst * (dbo.tb_yard_up.yu_qty_cur_design + dbo.tb_yard_up.yu_qty_cur_change) 
                AS 本期计价金额, dbo.tb_yard_up.yu_qty_pre_design + dbo.tb_yard_up.yu_qty_cur_design AS 开累设计数量, 
                dbo.tb_yard_up.yu_qty_pre_change + dbo.tb_yard_up.yu_qty_cur_change AS 开累变更数量, 
                dbo.tb_yard_up.yu_qty_pre_design + dbo.tb_yard_up.yu_qty_cur_design + dbo.tb_yard_up.yu_qty_pre_change + dbo.tb_yard_up.yu_qty_cur_change
                 AS 开累计价数量, 
                dbo.tb_yard_lst.yl_price_lst * (dbo.tb_yard_up.yu_qty_pre_design + dbo.tb_yard_up.yu_qty_cur_design + dbo.tb_yard_up.yu_qty_pre_change
                 + dbo.tb_yard_up.yu_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_yard_up INNER JOIN
                dbo.tb_yard_qty ON dbo.tb_yard_up.pt_code = dbo.tb_yard_qty.pt_code AND 
                dbo.tb_yard_up.yl_code = dbo.tb_yard_qty.yl_code INNER JOIN
                dbo.tb_points ON dbo.tb_yard_up.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_yard_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_yard_lst ON dbo.tb_yard_up.yl_code = dbo.tb_yard_lst.yl_code AND 
                dbo.tb_yard_qty.yl_code = dbo.tb_yard_lst.yl_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_yard_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tp_yard_up_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_yard_up_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(清单单价) AS 清单单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, SUM(上期计价金额) AS 上期金额, 
                SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, SUM(开累计价数量) AS 开累数量, 
                SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_yard_up
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_yard_up_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_yard_up_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_yard_up INNER JOIN
                dbo.tb_points ON dbo.tp_yard_up.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_temp_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_temp_up]
AS
SELECT   dbo.tb_temp_qty.pq_code AS 数量编号, dbo.tb_temp_up.pt_code AS 工点编号, dbo.tb_temp_up.pl_code AS 清单编号, 
                dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_temp_lst.pl_project AS 工程项目, dbo.tb_temp_lst.pl_unit AS 单位, dbo.tb_temp_lst.pl_price_lst AS 清单单价, 
                dbo.tb_temp_qty.pq_qty_dwg_design AS 蓝图设计数量, dbo.tb_temp_qty.pq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_temp_qty.pq_qty_dwg_design + dbo.tb_temp_qty.pq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_temp_lst.pl_price_lst * (dbo.tb_temp_qty.pq_qty_dwg_design + dbo.tb_temp_qty.pq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_temp_qty.pq_qty_doe_design AS 已完设计数量, 
                dbo.tb_temp_qty.pq_qty_doe_change AS 已完变更数量, 
                dbo.tb_temp_qty.pq_qty_doe_design + dbo.tb_temp_qty.pq_qty_doe_change AS 已完计算数量, 
                dbo.tb_temp_lst.pl_price_lst * (dbo.tb_temp_qty.pq_qty_doe_design + dbo.tb_temp_qty.pq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_temp_up.pu_qty_pre_design AS 上期设计数量, 
                dbo.tb_temp_up.pu_qty_pre_change AS 上期变更数量, 
                dbo.tb_temp_up.pu_qty_pre_design + dbo.tb_temp_up.pu_qty_pre_change AS 上期计价数量, 
                dbo.tb_temp_lst.pl_price_lst * (dbo.tb_temp_up.pu_qty_pre_design + dbo.tb_temp_up.pu_qty_pre_change) 
                AS 上期计价金额, dbo.tb_temp_up.pu_qty_cur_design AS 本期设计数量, 
                dbo.tb_temp_up.pu_qty_cur_change AS 本期变更数量, 
                dbo.tb_temp_up.pu_qty_cur_design + dbo.tb_temp_up.pu_qty_cur_change AS 本期计价数量, 
                dbo.tb_temp_lst.pl_price_lst * (dbo.tb_temp_up.pu_qty_cur_design + dbo.tb_temp_up.pu_qty_cur_change) 
                AS 本期计价金额, dbo.tb_temp_up.pu_qty_pre_design + dbo.tb_temp_up.pu_qty_cur_design AS 开累设计数量, 
                dbo.tb_temp_up.pu_qty_pre_change + dbo.tb_temp_up.pu_qty_cur_change AS 开累变更数量, 
                dbo.tb_temp_up.pu_qty_pre_design + dbo.tb_temp_up.pu_qty_cur_design + dbo.tb_temp_up.pu_qty_pre_change + dbo.tb_temp_up.pu_qty_cur_change
                 AS 开累计价数量, 
                dbo.tb_temp_lst.pl_price_lst * (dbo.tb_temp_up.pu_qty_pre_design + dbo.tb_temp_up.pu_qty_cur_design + dbo.tb_temp_up.pu_qty_pre_change
                 + dbo.tb_temp_up.pu_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_temp_up INNER JOIN
                dbo.tb_temp_qty ON dbo.tb_temp_up.pt_code = dbo.tb_temp_qty.pt_code AND 
                dbo.tb_temp_up.pl_code = dbo.tb_temp_qty.pl_code INNER JOIN
                dbo.tb_points ON dbo.tb_temp_up.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_temp_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_temp_lst ON dbo.tb_temp_up.pl_code = dbo.tb_temp_lst.pl_code AND 
                dbo.tb_temp_qty.pl_code = dbo.tb_temp_lst.pl_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_temp_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tp_temp_up_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_temp_up_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(清单单价) AS 清单单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, SUM(上期计价金额) AS 上期金额, 
                SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, SUM(开累计价数量) AS 开累数量, 
                SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_temp_up
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_temp_up_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_temp_up_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_temp_up INNER JOIN
                dbo.tb_points ON dbo.tp_temp_up.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_orbital_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_orbital_up]
AS
SELECT   dbo.tb_orbital_qty.oq_code AS 数量编号, dbo.tb_orbital_up.pt_code AS 工点编号, 
                dbo.tb_orbital_up.ol_code AS 清单编号, dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_orbital_lst.ol_project AS 工程项目, dbo.tb_orbital_lst.ol_unit AS 单位, dbo.tb_orbital_lst.ol_price_lst AS 清单单价, 
                dbo.tb_orbital_qty.oq_qty_dwg_design AS 蓝图设计数量, dbo.tb_orbital_qty.oq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_orbital_qty.oq_qty_dwg_design + dbo.tb_orbital_qty.oq_qty_dwg_change AS 蓝图计算数量, 
                dbo.tb_orbital_lst.ol_price_lst * (dbo.tb_orbital_qty.oq_qty_dwg_design + dbo.tb_orbital_qty.oq_qty_dwg_change) 
                AS 蓝图计算金额, dbo.tb_orbital_qty.oq_qty_doe_design AS 已完设计数量, 
                dbo.tb_orbital_qty.oq_qty_doe_change AS 已完变更数量, 
                dbo.tb_orbital_qty.oq_qty_doe_design + dbo.tb_orbital_qty.oq_qty_doe_change AS 已完计算数量, 
                dbo.tb_orbital_lst.ol_price_lst * (dbo.tb_orbital_qty.oq_qty_doe_design + dbo.tb_orbital_qty.oq_qty_doe_change) 
                AS 已完计算金额, dbo.tb_orbital_up.ou_qty_pre_design AS 上期设计数量, 
                dbo.tb_orbital_up.ou_qty_pre_change AS 上期变更数量, 
                dbo.tb_orbital_up.ou_qty_pre_design + dbo.tb_orbital_up.ou_qty_pre_change AS 上期计价数量, 
                dbo.tb_orbital_lst.ol_price_lst * (dbo.tb_orbital_up.ou_qty_pre_design + dbo.tb_orbital_up.ou_qty_pre_change) 
                AS 上期计价金额, dbo.tb_orbital_up.ou_qty_cur_design AS 本期设计数量, 
                dbo.tb_orbital_up.ou_qty_cur_change AS 本期变更数量, 
                dbo.tb_orbital_up.ou_qty_cur_design + dbo.tb_orbital_up.ou_qty_cur_change AS 本期计价数量, 
                dbo.tb_orbital_lst.ol_price_lst * (dbo.tb_orbital_up.ou_qty_cur_design + dbo.tb_orbital_up.ou_qty_cur_change) 
                AS 本期计价金额, dbo.tb_orbital_up.ou_qty_pre_design + dbo.tb_orbital_up.ou_qty_cur_design AS 开累设计数量, 
                dbo.tb_orbital_up.ou_qty_pre_change + dbo.tb_orbital_up.ou_qty_cur_change AS 开累变更数量, 
                dbo.tb_orbital_up.ou_qty_pre_design + dbo.tb_orbital_up.ou_qty_cur_design + dbo.tb_orbital_up.ou_qty_pre_change + dbo.tb_orbital_up.ou_qty_cur_change
                 AS 开累计价数量, 
                dbo.tb_orbital_lst.ol_price_lst * (dbo.tb_orbital_up.ou_qty_pre_design + dbo.tb_orbital_up.ou_qty_cur_design + dbo.tb_orbital_up.ou_qty_pre_change
                 + dbo.tb_orbital_up.ou_qty_cur_change) AS 开累计价金额
FROM      dbo.tb_orbital_up INNER JOIN
                dbo.tb_orbital_qty ON dbo.tb_orbital_up.pt_code = dbo.tb_orbital_qty.pt_code AND 
                dbo.tb_orbital_up.ol_code = dbo.tb_orbital_qty.ol_code INNER JOIN
                dbo.tb_orbital_lst ON dbo.tb_orbital_up.ol_code = dbo.tb_orbital_lst.ol_code AND 
                dbo.tb_orbital_qty.ol_code = dbo.tb_orbital_lst.ol_code INNER JOIN
                dbo.tb_points ON dbo.tb_orbital_up.pt_code = dbo.tb_points.pt_code AND 
                dbo.tb_orbital_qty.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_orbital_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tp_orbital_up_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_orbital_up_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 清单编号) AS 序号, 清单编号, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, 
                MIN(清单单价) AS 清单单价, SUM(蓝图计算数量) AS 蓝图数量, SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算数量) 
                AS 已完数量, SUM(已完计算金额) AS 已完金额, SUM(上期计价数量) AS 上期数量, SUM(上期计价金额) AS 上期金额, 
                SUM(本期计价数量) AS 本期数量, SUM(本期计价金额) AS 本期金额, SUM(开累计价数量) AS 开累数量, 
                SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_orbital_up
GROUP BY 清单编号


GO
/****** Object:  View [dbo].[tp_orbital_up_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_orbital_up_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 工点编号) AS 序号, 工点编号, MIN(dbo.tb_points.pt_name) 
AS 工点名称, MIN(里程桩号) AS 里程编号, 
SUM(蓝图计算金额) AS 蓝图金额, SUM(已完计算金额) AS 已完金额, SUM(上期计价金额) AS 上期金额, SUM(本期计价金额) 
AS 本期金额, SUM(开累计价金额) AS 开累金额
FROM      dbo.tp_orbital_up INNER JOIN
                dbo.tb_points ON dbo.tp_orbital_up.工点编号 = dbo.tb_points.pt_code
GROUP BY 工点编号


GO
/****** Object:  View [dbo].[tp_budget_rep_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_budget_rep_sum]
AS
SELECT  ct_code AS 清单编码, 细目名称, 单位, 数量, 单价, 合价, 概算数量, 图纸数量, 复核数量, 现场数量, 完成数量, 对上数量, 
                   对下数量
FROM      (SELECT  ct_id AS 清单ID, gd_name AS 细目名称, gd_unit AS 单位, gd_qty AS 数量, gd_price AS 单价, 
                                      gd_money AS 合价, qy_budget AS 概算数量, qy_dwg_design + qy_dwg_change AS 图纸数量, 
                                      qy_chk_design + qy_chk_change AS 复核数量, qy_act_design + qy_act_change AS 现场数量, 
                                      qy_do_design + qy_do_change AS 完成数量, qy_up_design + qy_up_change AS 对上数量, 
                                      qy_down_change + qy_down_design AS 对下数量, ROW_NUMBER() OVER (PARTITION BY ct_id
                   ORDER BY ct_id) AS i
FROM      dbo.tb_budget_rep) AS tab
LEFT JOIN dbo.tb_contract ON tab.清单ID = tb_contract.ct_id
WHERE   tab.i = 1

GO
/****** Object:  View [dbo].[tp_budget_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_budget_sum]
AS
SELECT  ct_code AS 清单编码, 细目名称, 计量单位, 清单数量, 综合单价, 清单合价
FROM      (SELECT  ct_id AS 清单ID, bg_name AS 细目名称, bg_unit AS 计量单位, bg_qty AS 清单数量, bg_price AS 综合单价, 
                                      bg_money AS 清单合价, ROW_NUMBER() OVER (PARTITION BY ct_id
                   ORDER BY ct_id) AS i
FROM      dbo.tb_budget) tab
LEFT JOIN dbo.tb_contract ON tab.清单ID = tb_contract.ct_id
WHERE   tab.i = 1

GO
/****** Object:  View [dbo].[tp_problem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE '%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_problem_all]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_all]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 专业) AS 序号, 专业, 整改情况, COUNT(序号) AS 整改数量, 
SUM(CAST(消号情况 AS int)) AS 消号数量
FROM      (SELECT   pm_code AS 序号, CASE WHEN LEFT(pm_number, 2) = 'LJ' THEN '路基问题' WHEN LEFT(pm_number, 2) 
                                 = 'QH' THEN '桥涵问题' WHEN LEFT(pm_number, 2) = 'SD' THEN '隧道问题' WHEN LEFT(pm_number, 2) 
                                 = 'GD' THEN '轨道问题' WHEN LEFT(pm_number, 2) = 'JC' THEN '精测问题' WHEN LEFT(pm_number, 2) 
                                 = 'JD' THEN '接地问题' WHEN LEFT(pm_number, 2) 
                                 = 'SP' THEN '声屏问题' ELSE '工务问题' END AS 专业, pm_state AS 整改情况, 
                                 pm_sign_confirm AS 消号情况
                 FROM      dbo.tb_problem) AS derivedtbl_problem
GROUP BY 专业, 整改情况

GO
/****** Object:  View [dbo].[tp_problem_barrier]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_barrier]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE 'SP%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_problem_bridge]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_bridge]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE 'QH%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_problem_groud]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_groud]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE 'JD%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_problem_measure]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_measure]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE 'JC%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_problem_orbital]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_orbital]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE 'GD%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_problem_road]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_road]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE 'LJ%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_problem_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_sum]
AS
SELECT   TOP (100) PERCENT ROW_NUMBER() OVER (ORDER BY 专业) AS 序号, 施工单元, 专业, 整改情况, COUNT(序号) 
AS 整改数量, SUM(CAST(消号情况 AS int)) AS 消号数量
FROM      (SELECT   pm_code AS 序号, pm_units AS 施工单元, CASE WHEN LEFT(pm_number, 2) 
                                 = 'LJ' THEN '路基问题' WHEN LEFT(pm_number, 2) = 'QH' THEN '桥涵问题' WHEN LEFT(pm_number, 2) 
                                 = 'SD' THEN '隧道问题' WHEN LEFT(pm_number, 2) = 'GD' THEN '轨道问题' WHEN LEFT(pm_number, 2) 
                                 = 'JD' THEN '接地问题' WHEN LEFT(pm_number, 2) = 'JC' THEN '精测问题' WHEN LEFT(pm_number, 2) 
                                 = 'SP' THEN '声屏问题' ELSE '工务问题' END AS 专业, pm_state AS 整改情况, 
                                 pm_sign_confirm AS 消号情况
                 FROM      dbo.tb_problem) AS derivedtbl_problem
GROUP BY 施工单元, 专业, 整改情况

GO
/****** Object:  View [dbo].[tp_problem_tunnel]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_problem_tunnel]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY dbo.tb_problem.pt_code) AS 序号, MIN(dbo.tb_problem.pm_units) AS 施工单元, 
MIN(dbo.tb_points.pt_name) AS 工点名称, MIN(dbo.tb_points.pt_bstat) AS 起点里程, MIN(dbo.tb_points.pt_estat) AS 终点里程, 
MIN(dbo.tb_points.pt_cstat) AS 中心里程, MIN(dbo.tb_points.pt_len) AS 线路长度, dbo.tb_problem.pm_category AS 具体分类, 
COUNT(dbo.tb_problem.pm_details) AS 问题数量, SUM(cast(dbo.tb_problem.pm_sign_confirm AS int)) AS 消号数量
FROM      dbo.tb_points INNER JOIN
                dbo.tb_problem ON dbo.tb_points.pt_code = dbo.tb_problem.pt_code
WHERE   dbo.tb_problem.pm_number LIKE 'SD%'
GROUP BY dbo.tb_problem.pt_code, dbo.tb_problem.pm_category

GO
/****** Object:  View [dbo].[tp_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_quantity_sum]
AS
SELECT  TOP (100) PERCENT MIN(qy_id) AS qy_id, pi_id, MIN(lb_id) AS lb_id, ct_id, bg_id, MIN(qy_date) AS qy_date, MIN(qy_name) 
                   AS qy_name, MIN(qy_unit) AS qy_unit, SUM(qy_do_design) AS qy_do_design, SUM(qy_do_change) AS qy_do_change, 
                   SUM(qy_up_design) AS qy_up_design, SUM(qy_up_change) AS qy_up_change, SUM(qy_down_design) 
                   AS qy_down_design, SUM(qy_down_change) AS qy_down_change, MIN(qy_info) AS qy_info
FROM      dbo.tb_quantity
GROUP BY pi_id, ct_id, bg_id
ORDER BY qy_id

GO
/****** Object:  View [dbo].[tp_retest_rail_calc]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_retest_rail_calc]
AS
SELECT   TOP (100) PERCENT 'RR' + RIGHT('0000000' + cast(ROW_NUMBER() OVER (ORDER BY tb_retest_orbit.ro_code) 
AS varchar), 8) AS code, dbo.tb_retest_orbit.pt_code AS ptcode, dbo.tb_retest_plate.rp_mark AS mark, 
dbo.tb_retest_orbit.ro_left_mileage AS mileage, dbo.tb_retest_orbit.ro_left_point AS left_point, 
dbo.tb_retest_orbit.ro_left_horizon AS left_horizon, dbo.tb_retest_orbit.ro_left_vertical AS left_vertical, 
dbo.tb_retest_orbit.ro_right_point AS right_point, dbo.tb_retest_orbit.ro_right_horizon AS right_horizon, 
dbo.tb_retest_orbit.ro_right_vertical AS right_vertical, dbo.tb_retest_orbit.ro_dif_horizon AS dif_horizon, 
dbo.tb_retest_orbit.ro_dif_vertical AS dif_vertical, dbo.tb_retest_plate.rp_tie AS marktie, 
dbo.tb_retest_plate.rp_code AS rpcode
FROM      dbo.tb_retest_orbit INNER JOIN
                dbo.tb_retest_plate ON dbo.tb_retest_orbit.rp_code = dbo.tb_retest_plate.rp_code
ORDER BY mark, mileage


GO
/****** Object:  View [dbo].[tp_sys_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_sys_contract]
AS
SELECT  TOP (100) PERCENT dbo.tb_sys_guidance.sgd_id AS 指导价ID, CASE WHEN MIN(dbo.tb_sys_contract.spi_id) 
                   = 1 THEN NULL ELSE MIN(dbo.tb_sys_contract.spi_id) END AS 节点ID, MIN(dbo.tb_sys_guidance.sct_code) AS 清单编码, 
                   MIN(dbo.tb_sys_contract.sct_name) AS 清单细目, MIN(dbo.tb_sys_contract.sct_unit) AS 清单单位, 
                   MIN(dbo.tb_sys_guidance.sgd_code) AS 指导价编码, MIN(dbo.tb_sys_guidance.sgd_label) AS 计量标识, 
                   MIN(dbo.tb_sys_guidance.sgd_name) AS 指导价细目, MIN(dbo.tb_sys_guidance.sgd_unit) AS 指导价单位, 
                   MIN(dbo.tb_sys_guidance.sgd_rate) AS 单位比率, MIN(dbo.tb_sys_guidance.sgd_price) AS 指导价单价
FROM      dbo.tb_sys_contract RIGHT OUTER JOIN
                   dbo.tb_sys_guidance ON dbo.tb_sys_guidance.sct_code = dbo.tb_sys_contract.sct_code
GROUP BY dbo.tb_sys_guidance.sgd_id
ORDER BY 指导价ID

GO
/****** Object:  View [dbo].[tp_sys_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_sys_quantity_sum]
AS
SELECT  TOP (100) PERCENT MIN(sqy_id) AS sqy_id, spi_id, MIN(lb_id) AS lb_id, sct_id, sbg_id AS Expr1, MIN(sqy_date) AS sqy_date, 
                   MIN(sqy_name) AS sqy_name, MIN(sqy_unit) AS sqy_unit, SUM(sqy_do_design) AS sqy_do_design, SUM(sqy_do_change) 
                   AS sqy_do_change, SUM(sqy_up_design) AS sqy_up_design, SUM(sqy_up_change) AS sqy_up_change, 
                   SUM(sqy_down_design) AS sqy_down_design, SUM(sqy_down_change) AS sqy_down_change, MIN(sqy_info) 
                   AS sqy_info
FROM      dbo.tb_sys_quantity
GROUP BY spi_id, sct_id, sbg_id
ORDER BY sqy_id

GO
/****** Object:  View [dbo].[tp_sys_steel_order]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_sys_steel_order]
AS
SELECT  dbo.tb_sys_steel_order.sso_id AS 订单ID, dbo.tb_sys_steel_order.sso_code AS 订单编号, 
                   dbo.tb_highway_partitem.hpi_node AS 节点名称, dbo.tb_sys_partitem.spi_node AS 构件类型, 
                   dbo.tb_sys_steel_order.ssl_code AS 构件编号, dbo.tb_sys_steel_order.sso_dt_order AS 订单日期, 
                   dbo.tb_sys_steel_order.sso_dt_proc AS 加工日期, dbo.tb_sys_steel_order.sso_dt_pick AS 领料日期, 
                   dbo.tb_sys_steel_order.sso_info AS 订单备注
FROM      dbo.tb_sys_steel_order INNER JOIN
                   dbo.tb_highway_partitem ON dbo.tb_sys_steel_order.hpi_id = dbo.tb_highway_partitem.hpi_id LEFT OUTER JOIN
                   dbo.tb_sys_partitem ON dbo.tb_highway_partitem.spi_id = dbo.tb_sys_partitem.spi_id

GO
/****** Object:  View [dbo].[tp_sys_steel_process]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tp_sys_steel_process]
AS
SELECT  ROW_NUMBER() OVER (ORDER BY dbo.tb_sys_steel_order.sso_id,dbo.tb_sys_steel_library.ssl_id) AS 序号, dbo.tb_sys_steel_order.sso_id AS 订单ID, 
dbo.tb_sys_steel_order.sso_code AS 订单编号, dbo.tb_highway_partitem.hpi_node AS 节点名称, 
dbo.tb_sys_partitem.spi_node AS 构件类型, dbo.tb_sys_steel_order.ssl_code AS 构件编号, 
dbo.tb_sys_steel_order.sso_dt_order AS 订单日期, dbo.tb_sys_steel_order.sso_dt_proc AS 加工日期, 
dbo.tb_sys_steel_order.sso_dt_pick AS 领料日期, dbo.tb_sys_steel_library.ssl_number AS 钢筋编号, 
dbo.tb_sys_steel_library.ssl_type AS 钢筋类型, dbo.tb_sys_steel_library.ssl_diameter AS [钢筋直径(mm)], 
dbo.tb_sys_steel_library.ssl_len_single AS [单根长(cm)], dbo.tb_sys_steel_library.ssl_count AS 根数, 
dbo.tb_sys_steel_library.ssl_len_total AS [总长(m)], dbo.tb_sys_steel_library.ssl_mg_single AS [单位重(Kg/m)], 
dbo.tb_sys_steel_library.ssl_mg_total AS [总重(Kg)], dbo.tb_sys_steel_library.ssl_time AS [工时(h)], 
dbo.tb_sys_steel_library.ssl_diagram AS 构件简图, dbo.tb_sys_steel_order.sso_info AS 订单备注
FROM      dbo.tb_sys_steel_order INNER JOIN
                   dbo.tb_highway_partitem ON dbo.tb_sys_steel_order.hpi_id = dbo.tb_highway_partitem.hpi_id LEFT OUTER JOIN
                   dbo.tb_sys_partitem ON dbo.tb_highway_partitem.spi_id = dbo.tb_sys_partitem.spi_id LEFT OUTER JOIN
                   dbo.tb_sys_steel_library ON dbo.tb_sys_steel_order.ssl_code = dbo.tb_sys_steel_library.ssl_code

GO
/****** Object:  View [dbo].[tv_barn]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_barn]
AS
SELECT   TOP (100) PERCENT b_code AS 仓库编号, b_name AS 仓库名称, b_dateopen AS 建库日期, b_dateclose AS 销库日期, 
                b_place AS 仓库地点, b_linkman AS 负责人, b_tel AS 联系电话, b_state AS 仓库状态, b_info AS 备注信息
FROM      dbo.tb_barn
ORDER BY 仓库编号


GO
/****** Object:  View [dbo].[tv_bridge_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_bridge_down]
AS
SELECT   dbo.tb_bridge_down.bd_code AS 对下编号, dbo.tb_bridge_down.pt_code AS 工点编号, 
                dbo.tb_bridge_down.bl_code AS 清单编号, dbo.tb_bridge_down.lr_code AS 台账编号, 
                dbo.tb_bridge_down.u_code AS 队伍编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_bridge_lst.bl_project AS 工程项目, dbo.tb_bridge_lst.bl_unit AS 单位, dbo.tb_bridge_lst.bl_price_lbr AS 单价, 
                dbo.tb_bridge_down.bd_qty_pre_design AS 上期设计数量, dbo.tb_bridge_down.bd_qty_pre_change AS 上期变更数量, 
                dbo.tb_bridge_down.bd_qty_cur_design AS 本期设计数量, dbo.tb_bridge_down.bd_qty_cur_change AS 本期变更数量, 
                dbo.tb_bridge_down.bd_qty_pre_design + dbo.tb_bridge_down.bd_qty_cur_design AS 累计设计数量, 
                dbo.tb_bridge_down.bd_qty_pre_change + dbo.tb_bridge_down.bd_qty_cur_change AS 累计变更数量, 
                dbo.tb_bridge_down.bd_info AS 备注
FROM      dbo.tb_bridge_down INNER JOIN
                dbo.tb_bridge_lst ON dbo.tb_bridge_down.bl_code = dbo.tb_bridge_lst.bl_code INNER JOIN
                dbo.tb_points ON dbo.tb_bridge_down.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_bridge_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_bridge_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tv_bridge_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_bridge_lst]
AS
SELECT   bl_code AS 清单编号, bl_number AS 清单编码, bl_section AS 清单节号, bl_project AS 工程细目名称, bl_unit AS 单位, 
                bl_qty_lst AS 清单数量, bl_price_lst AS 清单单价, bl_money_lst AS 清单合价, bl_qty_lbr AS 劳务数量, 
                bl_price_lbr_Labor AS 劳务单价, bl_price_lbr_good AS 主材单价, bl_price_lbr_device AS 机械单价, bl_price_lbr, 
                bl_money_lbr_Labor AS 劳务合价, bl_money_lbr_good AS 主材合价, bl_money_lbr_device AS 机械合价, bl_money_lbr, 
                bl_info AS 备注
FROM      dbo.tb_bridge_lst


GO
/****** Object:  View [dbo].[tv_bridge_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_bridge_qty]
AS
SELECT   dbo.tb_bridge_qty.bq_code AS 数量编号, dbo.tb_bridge_qty.pt_code AS 工点编号, 
                dbo.tb_bridge_qty.bl_code AS 清单编号, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_bridge_lst.bl_project AS 工程项目, dbo.tb_bridge_lst.bl_unit AS 单位, 
                dbo.tb_bridge_qty.bq_qty_dwg_design AS 蓝图设计数量, dbo.tb_bridge_qty.bq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_bridge_qty.bq_qty_chk_design AS 复核设计数量, dbo.tb_bridge_qty.bq_qty_chk_change AS 复核变更数量, 
                dbo.tb_bridge_qty.bq_qty_doe_design AS 已完设计数量, dbo.tb_bridge_qty.bq_qty_doe_change AS 已完变更数量, 
                dbo.tb_bridge_qty.bq_info AS 备注
FROM      dbo.tb_bridge_qty INNER JOIN
                dbo.tb_bridge_lst ON dbo.tb_bridge_qty.bl_code = dbo.tb_bridge_lst.bl_code INNER JOIN
                dbo.tb_points ON dbo.tb_bridge_qty.pt_code = dbo.tb_points.pt_code


GO
/****** Object:  View [dbo].[tv_bridge_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_bridge_up]
AS
SELECT   dbo.tb_bridge_up.bu_code AS 对上编号, dbo.tb_bridge_up.pt_code AS 工点编号, 
                dbo.tb_bridge_up.bl_code AS 清单编号, dbo.tb_bridge_up.lr_code AS 台账编号, dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_bridge_lst.bl_project AS 工程项目, dbo.tb_bridge_lst.bl_unit AS 单位, dbo.tb_bridge_lst.bl_price_lst AS 单价, 
                dbo.tb_bridge_up.bu_qty_pre_design AS 上期设计数量, dbo.tb_bridge_up.bu_qty_pre_change AS 上期变更数量, 
                dbo.tb_bridge_up.bu_qty_cur_design AS 本期设计数量, dbo.tb_bridge_up.bu_qty_cur_change AS 本期变更数量, 
                dbo.tb_bridge_up.bu_qty_pre_design + dbo.tb_bridge_up.bu_qty_cur_design AS 累计设计数量, 
                dbo.tb_bridge_up.bu_qty_pre_change + dbo.tb_bridge_up.bu_qty_cur_change AS 累计变更数量, 
                dbo.tb_bridge_up.bu_info AS 备注
FROM      dbo.tb_bridge_up INNER JOIN
                dbo.tb_bridge_lst ON dbo.tb_bridge_up.bl_code = dbo.tb_bridge_lst.bl_code INNER JOIN
                dbo.tb_points ON dbo.tb_bridge_up.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_bridge_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tv_budget]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_budget]
AS
SELECT  TOP (100) PERCENT bg_id AS 预算ID, ct_id AS 清单ID, bg_code AS 定额编码, bg_name AS 细目名称, bg_unit AS 单位, 
                   bg_rate AS 单位比率, bg_qty AS 数量, bg_price AS 单价, bg_money AS 合价, bg_info AS 备注
FROM      dbo.tb_budget

GO
/****** Object:  View [dbo].[tv_budget_rep]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_budget_rep]
AS
SELECT  TOP (100) PERCENT bg_id AS 预算ID, ct_id AS 清单ID, gd_code AS 指导价编码, gd_label AS 计量标识, 
                   gd_name AS 细目名称, gd_unit AS 单位, gd_rate AS 单位比率, gd_qty AS 数量, gd_price AS 单价, gd_money AS 合价, 
                   qy_budget AS 分项概算数量, qy_dwg_design AS 图纸设计数量, qy_dwg_change AS 图纸变更数量, 
                   qy_chk_design AS 复核图纸设计数量, qy_chk_change AS 复核图纸变更数量, qy_act_design AS 现场设计数量, 
                   qy_act_change AS 现场变更数量, qy_do_design AS 已完设计数量, qy_do_change AS 已完变更数量, 
                   qy_up_design AS 对上计价设计数量, qy_up_change AS 对上计价变更数量, 
                   qy_down_design AS 对下计价设计数量, qy_down_change AS 对下计价变更数量, bg_info AS 备注
FROM      dbo.tb_budget_rep

GO
/****** Object:  View [dbo].[tv_check]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_check]
AS
SELECT   TOP (100) PERCENT dbo.tb_check.c_code AS 盘点编号, dbo.tb_check.c_date AS 盘点日期, 
                dbo.tb_check.b_code AS 仓库编号, dbo.tb_check.g_code AS 物设编号, dbo.tb_check.e_code AS 职工编号, 
                dbo.tb_barn.b_name AS 仓库名称, dbo.tb_goods.g_name AS 物设名称, dbo.tb_employee.e_name AS 职工姓名, 
                dbo.tb_goods.g_price AS 物设单价, dbo.tb_check.c_qtyplain AS 仓储数量, 
                dbo.tb_check.c_qtyplain * dbo.tb_goods.g_price AS 仓储金额, dbo.tb_check.c_qtycheck AS 盘点数量, 
                dbo.tb_check.c_qtycheck * dbo.tb_goods.g_price AS 盘点金额, dbo.tb_check.c_qtyupper AS 仓储上限, 
                dbo.tb_check.c_qtylower AS 仓储下限, dbo.tb_check.c_info AS 备注信息
FROM      dbo.tb_check INNER JOIN
                dbo.tb_barn ON dbo.tb_check.b_code = dbo.tb_barn.b_code INNER JOIN
                dbo.tb_goods ON dbo.tb_check.g_code = dbo.tb_goods.g_code INNER JOIN
                dbo.tb_employee ON dbo.tb_check.e_code = dbo.tb_employee.e_code
GROUP BY dbo.tb_check.c_code, dbo.tb_check.c_date, dbo.tb_check.b_code, dbo.tb_check.g_code, dbo.tb_check.e_code, 
                dbo.tb_check.c_qtyplain, dbo.tb_check.c_qtycheck, dbo.tb_check.c_qtyupper, dbo.tb_check.c_qtylower, 
                dbo.tb_check.c_info, dbo.tb_barn.b_name, dbo.tb_goods.g_name, dbo.tb_employee.e_name, dbo.tb_goods.g_price, 
                dbo.tb_check.c_qtyplain * dbo.tb_goods.g_price, dbo.tb_check.c_qtycheck * dbo.tb_goods.g_price
ORDER BY 盘点编号


GO
/****** Object:  View [dbo].[tv_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_contract]
AS
SELECT  TOP (100) PERCENT ct_id AS 清单ID, ct_code AS 清单编码, ct_name AS 细目名称, ct_unit AS 计价单位, 
                   ct_qty AS 工程数量, ct_price AS 综合单价, ct_money AS 合价, ct_info AS 备注
FROM      dbo.tb_contract

GO
/****** Object:  View [dbo].[tv_costlist]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_costlist]
AS
SELECT   TOP (100) PERCENT cl_level AS 节点级别, cl_node AS 节点名称, cl_id AS 节点ID, cl_rootId AS 根节点ID
FROM      dbo.tb_costlist
GROUP BY cl_level, cl_node, cl_id, cl_rootId
ORDER BY 节点ID, 根节点ID

GO
/****** Object:  View [dbo].[tv_employee]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_employee]
AS
SELECT   TOP (100) PERCENT e_code AS 编号, e_name AS 姓名, e_sex AS 性别, e_place AS 地址, e_birth AS 生日, 
                e_dept AS 部门, e_duty AS 职务, e_identity AS 身份, e_education AS 学历, e_college AS 院校, e_profession AS 职称, 
                e_tel AS 电话, e_info AS 备注
FROM      dbo.tb_employee
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_funds]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_funds]
AS
SELECT   TOP (100) PERCENT f_code AS 编号, f_name AS 名称, f_category AS 类别, f_business AS 商家, f_unit AS 单位, 
                f_price AS 单价, f_info AS 备注
FROM      dbo.tb_funds
ORDER BY f_code

GO
/****** Object:  View [dbo].[tv_goods]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_goods]
AS
SELECT   TOP (100) PERCENT g_code AS 编号, g_name AS 名称, g_type AS 类型, g_brand AS 品牌, g_standard AS 规格, 
                g_unit AS 单位, g_produce AS 厂商, g_price AS 价格, g_pricebudget AS 预价, g_pricesearch AS 询价, 
                g_pricecheck AS 核价, g_method AS 折旧方法, g_rate AS 净现值率, g_info AS 备注
FROM      dbo.tb_goods
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_guidance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_guidance]
AS
SELECT  TOP (100) PERCENT gd_id AS 指导价ID, ct_code AS 清单编码, bg_code AS 定额编码, gd_code AS 指导价编码, 
                   gd_label AS 计量标识, gd_name AS 项目名称, gd_unit AS 计量单位, gd_rate AS 单位比率, gd_price AS 含税指导单价, 
                   gd_item AS 含税项目单价, gd_wark AS 工作内容, gd_cost AS 费用组成, gd_role AS 计量规则, 
                   gd_info AS 指导价备注
FROM      dbo.tb_guidance

GO
/****** Object:  View [dbo].[tv_income]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_income]
AS
SELECT   dbo.tb_income.i_code AS 编号, dbo.tb_income.i_date AS 日期, dbo.tb_income.f_code AS 款项编号, 
                dbo.tb_income.m_code AS 成员编号, dbo.tb_member.m_name AS 姓名, dbo.tb_funds.f_category AS 类别, 
                dbo.tb_funds.f_name AS 款项, dbo.tb_income.i_qty AS 数量, dbo.tb_income.i_money AS 金额, 
                dbo.tb_income.i_method AS 方式, dbo.tb_income.i_info AS 备注
FROM      dbo.tb_income INNER JOIN
                dbo.tb_funds ON dbo.tb_income.f_code = dbo.tb_funds.f_code INNER JOIN
                dbo.tb_member ON dbo.tb_income.m_code = dbo.tb_member.m_code

GO
/****** Object:  View [dbo].[tv_instock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_instock]
AS
SELECT   TOP (100) PERCENT dbo.tb_instock.i_code AS 入库编号, dbo.tb_instock.i_date AS 入库日期, 
                dbo.tb_instock.i_bill AS 入库单号, dbo.tb_instock.b_code AS 仓库编号, dbo.tb_instock.g_code AS 物设编号, 
                dbo.tb_instock.u_code AS 单位编号, dbo.tb_instock.e_code AS 职工编号, dbo.tb_instock.p_code AS 合同编号, 
                dbo.tb_barn.b_name AS 仓库名称, dbo.tb_goods.g_name AS 物设名称, dbo.tb_units.u_name AS 供应单位, 
                dbo.tb_employee.e_name AS 职工姓名, dbo.tb_pact.p_name AS 物设合同, dbo.tb_instock.i_qty AS 入库数量, 
                dbo.tb_goods.g_price AS 物设单价, dbo.tb_instock.i_qty * dbo.tb_goods.g_price AS 入库金额, 
                dbo.tb_instock.i_payable AS 应付金额, dbo.tb_instock.i_payout AS 实付金额, dbo.tb_instock.i_plant AS 折旧金额, 
                dbo.tb_barn.b_place AS 使用地点, dbo.tb_barn.b_state AS 物设状态, dbo.tb_instock.i_info AS 备注信息
FROM      dbo.tb_instock INNER JOIN
                dbo.tb_barn ON dbo.tb_instock.b_code = dbo.tb_barn.b_code INNER JOIN
                dbo.tb_goods ON dbo.tb_instock.g_code = dbo.tb_goods.g_code INNER JOIN
                dbo.tb_barn AS tb_barn_1 ON dbo.tb_instock.b_code = tb_barn_1.b_code INNER JOIN
                dbo.tb_employee ON dbo.tb_instock.e_code = dbo.tb_employee.e_code INNER JOIN
                dbo.tb_goods AS tb_goods_1 ON dbo.tb_instock.g_code = tb_goods_1.g_code INNER JOIN
                dbo.tb_pact ON dbo.tb_instock.p_code = dbo.tb_pact.p_code INNER JOIN
                dbo.tb_units ON dbo.tb_instock.u_code = dbo.tb_units.u_code
ORDER BY 入库编号


GO
/****** Object:  View [dbo].[tv_ledger]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[tv_ledger]
AS
SELECT   lr_code AS 台账编号, lr_date AS 计量日期, lr_road AS 路基工程, lr_bridge AS 桥梁工程, lr_tunnel AS 隧道工程, 
                lr_orbital AS 轨道工程, lr_yard AS 站场工程, lr_temp AS 大临工程, lr_info AS 备注
FROM      dbo.tb_ledger


GO
/****** Object:  View [dbo].[tv_member]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_member]
AS
SELECT   TOP (100) PERCENT m_code AS 编号, m_name AS 姓名, m_sex AS 性别, m_birth AS 生日, m_identity AS 身份, 
                m_relation AS 关系, m_origin AS 籍贯, m_education AS 学历, m_college AS 院校, m_tel AS 电话, m_info AS 备注
FROM      dbo.tb_member
ORDER BY m_code

GO
/****** Object:  View [dbo].[tv_mixstock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_mixstock]
AS
SELECT   TOP (100) PERCENT dbo.tb_mixstock.m_code AS 调库编号, dbo.tb_mixstock.m_date AS 调库日期, 
                dbo.tb_mixstock.m_bill AS 调库单号, dbo.tb_mixstock.b_code AS 仓库编号, dbo.tb_mixstock.g_code AS 物设编号, 
                dbo.tb_mixstock.u_code AS 单位编号, dbo.tb_mixstock.e_code AS 职工编号, dbo.tb_mixstock.p_code AS 合同编号, 
                dbo.tb_barn.b_name AS 仓库名称, dbo.tb_goods.g_name AS 物设名称, dbo.tb_units.u_name AS 供应单位, 
                dbo.tb_employee.e_name AS 职工姓名, dbo.tb_pact.p_name AS 物设合同, dbo.tb_mixstock.m_qty AS 调库数量, 
                dbo.tb_goods.g_price AS 物设单价, dbo.tb_mixstock.m_qty * dbo.tb_goods.g_price AS 调库金额, 
                dbo.tb_mixstock.m_payable AS 应付金额, dbo.tb_mixstock.m_payout AS 实付金额, 
                dbo.tb_mixstock.m_plant AS 折旧金额, dbo.tb_barn.b_state AS 物设状态, dbo.tb_barn.b_place AS 使用地点, 
                dbo.tb_mixstock.m_info AS 备注信息
FROM      dbo.tb_mixstock INNER JOIN
                dbo.tb_goods ON dbo.tb_mixstock.g_code = dbo.tb_goods.g_code INNER JOIN
                dbo.tb_barn ON dbo.tb_mixstock.b_code = dbo.tb_barn.b_code INNER JOIN
                dbo.tb_barn AS tb_barn_1 ON dbo.tb_mixstock.b_code = tb_barn_1.b_code INNER JOIN
                dbo.tb_goods AS tb_goods_1 ON dbo.tb_mixstock.g_code = tb_goods_1.g_code INNER JOIN
                dbo.tb_employee ON dbo.tb_mixstock.e_code = dbo.tb_employee.e_code INNER JOIN
                dbo.tb_pact ON dbo.tb_mixstock.p_code = dbo.tb_pact.p_code INNER JOIN
                dbo.tb_units ON dbo.tb_mixstock.u_code = dbo.tb_units.u_code
ORDER BY 调库编号


GO
/****** Object:  View [dbo].[tv_orbital_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_orbital_down]
AS
SELECT   dbo.tb_orbital_down.od_code AS 对下编号, dbo.tb_orbital_down.pt_code AS 工点编号, 
                dbo.tb_orbital_down.ol_code AS 清单编号, dbo.tb_orbital_down.lr_code AS 台账编号, 
                dbo.tb_orbital_down.u_code AS 队伍编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_orbital_lst.ol_project AS 工程项目, dbo.tb_orbital_lst.ol_unit AS 单位, dbo.tb_orbital_lst.ol_price_lbr AS 单价, 
                dbo.tb_orbital_down.od_qty_pre_design AS 上期设计数量, dbo.tb_orbital_down.od_qty_pre_change AS 上期变更数量, 
                dbo.tb_orbital_down.od_qty_cur_design AS 本期设计数量, dbo.tb_orbital_down.od_qty_cur_change AS 本期变更数量, 
                dbo.tb_orbital_down.od_qty_pre_design + dbo.tb_orbital_down.od_qty_cur_design AS 累计设计数量, 
                dbo.tb_orbital_down.od_qty_pre_change + dbo.tb_orbital_down.od_qty_cur_change AS 累计变更数量, 
                dbo.tb_orbital_down.od_info AS 备注
FROM      dbo.tb_orbital_down INNER JOIN
                dbo.tb_orbital_lst ON dbo.tb_orbital_down.ol_code = dbo.tb_orbital_lst.ol_code INNER JOIN
                dbo.tb_points ON dbo.tb_orbital_down.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_orbital_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_orbital_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tv_orbital_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_orbital_lst]
AS
SELECT   ol_code AS 清单编号, ol_number AS 清单编码, ol_section AS 清单节号, ol_project AS 工程细目名称, ol_unit AS 单位, 
                ol_qty_lst AS 清单数量, ol_price_lst AS 清单单价, ol_money_lst AS 清单合价, ol_qty_lbr AS 劳务数量, 
                ol_price_lbr_Labor AS 劳务单价, ol_price_lbr_good AS 主材单价, ol_price_lbr_device AS 机械单价, ol_price_lbr, 
                ol_money_lbr_Labor AS 劳务合价, ol_money_lbr_good AS 主材合价, ol_money_lbr_device AS 机械合价, ol_money_lbr, 
                ol_info AS 备注
FROM      dbo.tb_orbital_lst


GO
/****** Object:  View [dbo].[tv_orbital_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_orbital_qty]
AS
SELECT   dbo.tb_orbital_qty.oq_code AS 数量编号, dbo.tb_orbital_qty.pt_code AS 工点编号, 
                dbo.tb_orbital_qty.ol_code AS 清单编号, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_orbital_lst.ol_project AS 工程项目, dbo.tb_orbital_lst.ol_unit AS 单位, 
                dbo.tb_orbital_qty.oq_qty_dwg_design AS 蓝图设计数量, dbo.tb_orbital_qty.oq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_orbital_qty.oq_qty_chk_design AS 复核设计数量, dbo.tb_orbital_qty.oq_qty_chk_change AS 复核变更数量, 
                dbo.tb_orbital_qty.oq_qty_doe_design AS 已完设计数量, dbo.tb_orbital_qty.oq_qty_doe_change AS 已完变更数量, 
                dbo.tb_orbital_qty.oq_info AS 备注
FROM      dbo.tb_orbital_qty INNER JOIN
                dbo.tb_orbital_lst ON dbo.tb_orbital_qty.ol_code = dbo.tb_orbital_lst.ol_code INNER JOIN
                dbo.tb_points ON dbo.tb_orbital_qty.pt_code = dbo.tb_points.pt_code


GO
/****** Object:  View [dbo].[tv_orbital_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_orbital_up]
AS
SELECT   dbo.tb_orbital_up.ou_code AS 对上编号, dbo.tb_orbital_up.pt_code AS 工点编号, 
                dbo.tb_orbital_up.ol_code AS 清单编号, dbo.tb_orbital_up.lr_code AS 台账编号, dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_orbital_lst.ol_project AS 工程项目, dbo.tb_orbital_lst.ol_unit AS 单位, dbo.tb_orbital_lst.ol_price_lst AS 单价, 
                dbo.tb_orbital_up.ou_qty_pre_design AS 上期设计数量, dbo.tb_orbital_up.ou_qty_pre_change AS 上期变更数量, 
                dbo.tb_orbital_up.ou_qty_cur_design AS 本期设计数量, dbo.tb_orbital_up.ou_qty_cur_change AS 本期变更数量, 
                dbo.tb_orbital_up.ou_qty_pre_design + dbo.tb_orbital_up.ou_qty_cur_design AS 累计设计数量, 
                dbo.tb_orbital_up.ou_qty_pre_change + dbo.tb_orbital_up.ou_qty_cur_change AS 累计变更数量, 
                dbo.tb_orbital_up.ou_info AS 备注
FROM      dbo.tb_orbital_up INNER JOIN
                dbo.tb_orbital_lst ON dbo.tb_orbital_up.ol_code = dbo.tb_orbital_lst.ol_code INNER JOIN
                dbo.tb_points ON dbo.tb_orbital_up.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_orbital_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tv_outlay]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_outlay]
AS
SELECT   dbo.tb_outlay.o_code AS 编号, dbo.tb_outlay.o_date AS 日期, dbo.tb_outlay.f_code AS 款项编号, 
                dbo.tb_outlay.m_code AS 成员编号, dbo.tb_member.m_name AS 姓名, dbo.tb_funds.f_category AS 类别, 
                dbo.tb_funds.f_name AS 款项, dbo.tb_outlay.o_qty AS 数量, dbo.tb_outlay.o_money AS 金额, 
                dbo.tb_outlay.o_method AS 方式, dbo.tb_outlay.o_info AS 备注
FROM      dbo.tb_outlay INNER JOIN
                dbo.tb_funds ON dbo.tb_outlay.f_code = dbo.tb_funds.f_code INNER JOIN
                dbo.tb_member ON dbo.tb_outlay.m_code = dbo.tb_member.m_code

GO
/****** Object:  View [dbo].[tv_outstock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_outstock]
AS
SELECT   TOP (100) PERCENT dbo.tb_outstock.o_code AS 出库编号, dbo.tb_outstock.o_date AS 出库日期, 
                dbo.tb_outstock.o_bill AS 出库单号, dbo.tb_outstock.b_code AS 仓库编号, dbo.tb_outstock.g_code AS 物设编号, 
                dbo.tb_outstock.u_code AS 单位编号, dbo.tb_outstock.e_code AS 职工编号, dbo.tb_outstock.p_code AS 合同编号, 
                dbo.tb_barn.b_name AS 仓库名称, dbo.tb_goods.g_name AS 物设名称, dbo.tb_units.u_name AS 供应单位, 
                dbo.tb_employee.e_name AS 职工姓名, dbo.tb_pact.p_name AS 物设合同, dbo.tb_outstock.o_qty AS 出库数量, 
                dbo.tb_goods.g_price AS 物设单价, dbo.tb_outstock.o_qty * dbo.tb_goods.g_price AS 出库金额, 
                dbo.tb_outstock.o_payable AS 应付金额, dbo.tb_outstock.o_payout AS 实付金额, dbo.tb_outstock.o_plant AS 折旧金额, 
                dbo.tb_barn.b_state AS 物设状态, dbo.tb_barn.b_place AS 使用地点, dbo.tb_outstock.o_info AS 备注信息
FROM      dbo.tb_outstock INNER JOIN
                dbo.tb_barn ON dbo.tb_outstock.b_code = dbo.tb_barn.b_code INNER JOIN
                dbo.tb_goods ON dbo.tb_outstock.g_code = dbo.tb_goods.g_code INNER JOIN
                dbo.tb_barn AS tb_barn_1 ON dbo.tb_outstock.b_code = tb_barn_1.b_code INNER JOIN
                dbo.tb_employee ON dbo.tb_outstock.e_code = dbo.tb_employee.e_code INNER JOIN
                dbo.tb_goods AS tb_goods_1 ON dbo.tb_outstock.g_code = tb_goods_1.g_code INNER JOIN
                dbo.tb_pact ON dbo.tb_outstock.p_code = dbo.tb_pact.p_code INNER JOIN
                dbo.tb_units ON dbo.tb_outstock.u_code = dbo.tb_units.u_code
ORDER BY 出库编号


GO
/****** Object:  View [dbo].[tv_pact]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_pact]
AS
SELECT   TOP (100) PERCENT p_code AS 合同编号, p_date AS 订立日期, p_number AS 合同代号, p_name AS 合同名称, 
                p_owner AS 甲方代表, p_party AS 乙方代表, p_info AS 备注信息
FROM      dbo.tb_pact
ORDER BY 合同编号

GO
/****** Object:  View [dbo].[tv_partitem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_partitem]
AS
SELECT   TOP (100) PERCENT pi_level AS 节点级别, pi_node AS 节点名称, pi_id AS 节点ID, pi_rootId AS 根节点ID
FROM      dbo.tb_partitem
GROUP BY pi_level, pi_node, pi_id, pi_rootId
ORDER BY 节点ID, 根节点ID

GO
/****** Object:  View [dbo].[tv_points]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[tv_points]
AS
SELECT   pt_code AS 工点编号, pt_name AS 工点名称, pt_type AS 工点类型, pt_place AS 工点地点, pt_bstat AS 起始桩号, 
                pt_estat AS 终止桩号, pt_cstat AS 中心桩号, pt_len AS 线路长度, pt_mask AS 布板数量, pt_info AS 备注
FROM      dbo.tb_points


GO
/****** Object:  View [dbo].[tv_problem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_problem_barrier]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem_barrier]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
WHERE   (pm_number LIKE 'SP%')
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_problem_bridge]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem_bridge]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
WHERE   (pm_number LIKE 'QH%')
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_problem_groud]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem_groud]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
WHERE   (pm_number LIKE 'JD%')
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_problem_measure]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem_measure]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
WHERE   (pm_number LIKE 'JC%')
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_problem_orbital]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem_orbital]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
WHERE   (pm_number LIKE 'GD%')
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_problem_road]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem_road]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
WHERE   (pm_number LIKE 'LJ%')
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_problem_tunnel]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_problem_tunnel]
AS
SELECT   TOP (100) PERCENT pm_code AS 编号, pt_code AS 工点编号, pm_units AS 施工单元, pm_team AS 施工队, 
                pm_number AS 问题编号, pm_name AS 项目, pm_part AS 部位, pm_position AS 线别, pm_project AS 问题, 
                pm_category AS 分类, pm_details AS 细目, pm_method AS 整改方案, pm_date AS 整改期限, pm_state AS 整改状态, 
                pm_sign_confirm AS 消号, pm_sign_estab AS 确认人, pm_sign_date AS 销号日期, pm_level AS 级别, 
                pm_reason AS 原因, pm_info AS 备注
FROM      dbo.tb_problem
WHERE   (pm_number LIKE 'SD%')
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_quantity]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_quantity]
AS
SELECT  TOP (100) PERCENT dbo.tb_quantity.qy_id AS 数量ID, dbo.tb_quantity.pi_id AS 节点ID, dbo.tb_quantity.lb_id AS 劳务ID, 
                   dbo.tb_quantity.ct_id AS 清单ID, dbo.tb_quantity.bg_id AS 概算ID, dbo.tb_quantity.qy_date AS 施工日期, 
                   dbo.tb_quantity.qy_name AS 数量名称, dbo.tb_quantity.qy_unit AS 计量单位, 
                   dbo.tb_quantity.qy_do_design AS 已完设计数量, dbo.tb_quantity.qy_do_change AS 已完变更数量, 
                   dbo.tb_quantity.qy_up_design AS 对上计价设计数量, dbo.tb_quantity.qy_up_change AS 对上计价变更数量, 
                   dbo.tb_quantity.qy_down_design AS 对下计价设计数量, dbo.tb_quantity.qy_down_change AS 对下计价变更数量, 
                   dbo.tb_quantity.qy_info AS 备注, dbo.tb_contract.ct_code AS 清单编码, dbo.tb_budget.bg_code AS 定额编码
FROM      dbo.tb_quantity LEFT OUTER JOIN
                   dbo.tb_contract ON dbo.tb_quantity.ct_id = dbo.tb_contract.ct_id LEFT OUTER JOIN
                   dbo.tb_budget ON dbo.tb_quantity.bg_id = dbo.tb_budget.bg_id
ORDER BY 数量ID

GO
/****** Object:  View [dbo].[tv_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_quantity_sum]
AS
SELECT  TOP (100) PERCENT dbo.tb_quantity_sum.qy_id AS 数量ID, dbo.tb_quantity_sum.pi_id AS 节点ID, 
                   dbo.tb_quantity_sum.lb_id AS 劳务ID, dbo.tb_quantity_sum.ct_id AS 清单ID, dbo.tb_quantity_sum.bg_id AS 概算ID, 
                   dbo.tb_quantity_sum.qy_date AS 施工日期, dbo.tb_quantity_sum.qy_name AS 数量名称, 
                   dbo.tb_quantity_sum.qy_unit AS 计量单位, dbo.tb_quantity_sum.qy_budget AS 分项概算数量, 
                   dbo.tb_quantity_sum.qy_dwg_design AS 图纸设计数量, dbo.tb_quantity_sum.qy_dwg_change AS 图纸变更数量, 
                   dbo.tb_quantity_sum.qy_chk_design AS 复核图纸设计数量, 
                   dbo.tb_quantity_sum.qy_chk_change AS 复核图纸变更数量, dbo.tb_quantity_sum.qy_act_design AS 现场设计数量, 
                   dbo.tb_quantity_sum.qy_act_change AS 现场变更数量, dbo.tb_quantity_sum.qy_do_design AS 已完设计数量, 
                   dbo.tb_quantity_sum.qy_do_change AS 已完变更数量, dbo.tb_quantity_sum.qy_up_design AS 对上计价设计数量, 
                   dbo.tb_quantity_sum.qy_up_change AS 对上计价变更数量, 
                   dbo.tb_quantity_sum.qy_down_design AS 对下计价设计数量, 
                   dbo.tb_quantity_sum.qy_down_change AS 对下计价变更数量, dbo.tb_quantity_sum.qy_info AS 备注, 
                   dbo.tb_contract.ct_code AS 清单编码, dbo.tb_budget.bg_code AS 定额编码
FROM      dbo.tb_quantity_sum LEFT OUTER JOIN
                   dbo.tb_budget ON dbo.tb_quantity_sum.bg_id = dbo.tb_budget.bg_id LEFT OUTER JOIN
                   dbo.tb_contract ON dbo.tb_quantity_sum.ct_id = dbo.tb_contract.ct_id
ORDER BY 数量ID

GO
/****** Object:  View [dbo].[tv_retest_orbit]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_retest_orbit]
AS
SELECT   ro_code AS 编号, pt_code AS 工点, rp_code AS 板号, ro_left_point AS 左端点号, ro_left_mileage AS 左端里程, 
                ro_left_horizon AS 左端横向偏差, ro_left_vertical AS 左端高程偏差, ro_right_point AS 右端点号, 
                ro_right_mileage AS 右端里程, ro_right_horizon AS 右端横向偏差, ro_right_vertical AS 右端高程偏差, 
                ro_dif_horizon AS 左右端横向差, ro_dif_vertical AS 左右端高程差, ro_left_in_dl AS 左轨板内纵向平顺性, 
                ro_left_in_dq AS 左轨板内横向平顺性, ro_left_in_dh AS 左轨板内高程平顺性, ro_right_in_dl AS 右轨板内纵向平顺性, 
                ro_right_in_dq AS 右轨板内横向平顺性, ro_right_in_dh AS 右轨板内高程平顺性, ro_left_out_dq AS 左轨板间横向平顺性, 
                ro_left_out_dh AS 左轨板间高程平顺性, ro_right_out_dq AS 右轨板间横向平顺性, 
                ro_right_out_dh AS 右轨板间高程平顺性, ro_info AS 备注
FROM      dbo.tb_retest_orbit


GO
/****** Object:  View [dbo].[tv_retest_plate]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_retest_plate]
AS
SELECT   rp_code AS 编号, pt_code AS 工点, rp_mark AS 板号, rp_mileage AS 里程, rp_length AS 长度, rp_type AS 板型, 
                rp_dif_up AS 前间隙, rp_dif_down AS 后间隙, rp_tie AS 轨枕数, rp_info AS 备注
FROM      dbo.tb_retest_plate


GO
/****** Object:  View [dbo].[tv_retest_rail]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_retest_rail]
AS
SELECT   rr_code AS 编号, pt_code AS 工点, rp_code AS 板号, rr_mileage AS 里程, rr_left_point AS 左点号, 
                rr_left_horizon AS 左轨平面, rr_left_vertical AS 左轨高程, rr_right_point AS 右点号, rr_right_horizon AS 右轨平面, 
                rr_right_vertical AS 右轨高程, rr_dif_horizon AS 轨距, rr_dif_vertical AS 水平, rr_left_dq AS 左轨轨向, 
                rr_left_dh AS 左轨高低, rr_right_dq AS 右轨轨向, rr_right_dh AS 右轨高低, rr_left_wfp15u_out AS 左轨外挡板, 
                rr_left_wfp15u_in AS 左轨内挡板, rr_left_zw692 AS 左轨下垫片, rr_right_wfp15u_in AS 右轨内挡板, 
                rr_right_wfp15u_out AS 右轨外挡板, rr_right_zw692 AS 右轨下垫片, rr_info AS 备注
FROM      dbo.tb_retest_rail


GO
/****** Object:  View [dbo].[tv_retstock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_retstock]
AS
SELECT   TOP (100) PERCENT dbo.tb_retstock.r_code AS 退库编号, dbo.tb_retstock.r_date AS 退库日期, 
                dbo.tb_retstock.r_bill AS 退库单号, dbo.tb_retstock.b_code AS 仓库编号, dbo.tb_retstock.g_code AS 物设编号, 
                dbo.tb_retstock.u_code AS 单位编号, dbo.tb_retstock.e_code AS 职工编号, dbo.tb_retstock.p_code AS 合同编号, 
                dbo.tb_barn.b_name AS 仓库名称, dbo.tb_goods.g_name AS 物设名称, dbo.tb_units.u_name AS 供应单位, 
                dbo.tb_employee.e_name AS 职工姓名, dbo.tb_pact.p_name AS 物设合同, dbo.tb_retstock.r_qty AS 退库数量, 
                dbo.tb_goods.g_price AS 物设单价, dbo.tb_retstock.r_qty * dbo.tb_goods.g_price AS 退库金额, 
                dbo.tb_retstock.r_payable AS 应付金额, dbo.tb_retstock.r_payout AS 实付金额, dbo.tb_retstock.r_plant AS 折旧金额, 
                dbo.tb_barn.b_state AS 物设状态, dbo.tb_barn.b_place AS 使用地点, dbo.tb_retstock.r_info AS 备注信息
FROM      dbo.tb_retstock INNER JOIN
                dbo.tb_goods ON dbo.tb_retstock.g_code = dbo.tb_goods.g_code INNER JOIN
                dbo.tb_barn ON dbo.tb_retstock.b_code = dbo.tb_barn.b_code INNER JOIN
                dbo.tb_barn AS tb_barn_1 ON dbo.tb_retstock.b_code = tb_barn_1.b_code INNER JOIN
                dbo.tb_employee ON dbo.tb_retstock.e_code = dbo.tb_employee.e_code INNER JOIN
                dbo.tb_goods AS tb_goods_1 ON dbo.tb_retstock.g_code = tb_goods_1.g_code INNER JOIN
                dbo.tb_pact ON dbo.tb_retstock.p_code = dbo.tb_pact.p_code INNER JOIN
                dbo.tb_units ON dbo.tb_retstock.u_code = dbo.tb_units.u_code
ORDER BY 退库编号

GO
/****** Object:  View [dbo].[tv_road_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_road_down]
AS
SELECT   dbo.tb_road_down.rd_code AS 对下编号, dbo.tb_road_down.pt_code AS 工点编号, 
                dbo.tb_road_down.rl_code AS 清单编号, dbo.tb_road_down.lr_code AS 台账编号, 
                dbo.tb_road_down.u_code AS 队伍编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_road_lst.rl_project AS 工程项目, dbo.tb_road_lst.rl_unit AS 单位, dbo.tb_road_lst.rl_price_lbr AS 单价, 
                dbo.tb_road_down.rd_qty_pre_design AS 上期设计数量, dbo.tb_road_down.rd_qty_pre_change AS 上期变更数量, 
                dbo.tb_road_down.rd_qty_cur_design AS 本期设计数量, dbo.tb_road_down.rd_qty_cur_change AS 本期变更数量, 
                dbo.tb_road_down.rd_qty_pre_design + dbo.tb_road_down.rd_qty_cur_design AS 累计设计数量, 
                dbo.tb_road_down.rd_qty_pre_change + dbo.tb_road_down.rd_qty_cur_change AS 累计变更数量, 
                dbo.tb_road_down.rd_info AS 备注
FROM      dbo.tb_road_down INNER JOIN
                dbo.tb_road_lst ON dbo.tb_road_down.rl_code = dbo.tb_road_lst.rl_code INNER JOIN
                dbo.tb_points ON dbo.tb_road_down.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_road_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_road_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tv_road_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_road_lst]
AS
SELECT   rl_code AS 清单编号, rl_number AS 清单编码, rl_section AS 清单节号, rl_project AS 工程细目名称, rl_unit AS 单位, 
                rl_qty_lst AS 清单数量, rl_price_lst AS 清单单价, rl_money_lst AS 清单合价, rl_qty_lbr AS 劳务数量, 
                rl_price_lbr_Labor AS 人工单价, rl_price_lbr_good AS 主材单价, rl_price_lbr_device AS 机械单价, 
                rl_price_lbr AS 劳务单价, rl_money_lbr_Labor AS 人工合价, rl_money_lbr_good AS 主材合价, 
                rl_money_lbr_device AS 机械合价, rl_money_lbr AS 劳务合价, rl_info AS 备注
FROM      dbo.tb_road_lst


GO
/****** Object:  View [dbo].[tv_road_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_road_qty]
AS
SELECT   dbo.tb_road_qty.rq_code AS 数量编号, dbo.tb_road_qty.pt_code AS 工点编号, dbo.tb_road_qty.rl_code AS 清单编号, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_road_lst.rl_project AS 工程项目, dbo.tb_road_lst.rl_unit AS 单位, 
                dbo.tb_road_qty.rq_qty_dwg_design AS 蓝图设计数量, dbo.tb_road_qty.rq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_road_qty.rq_qty_chk_design AS 复核设计数量, dbo.tb_road_qty.rq_qty_chk_change AS 复核变更数量, 
                dbo.tb_road_qty.rq_qty_doe_design AS 已完设计数量, dbo.tb_road_qty.rq_qty_doe_change AS 已完变更数量, 
                dbo.tb_road_qty.rq_info AS 备注
FROM      dbo.tb_road_qty INNER JOIN
                dbo.tb_road_lst ON dbo.tb_road_qty.rl_code = dbo.tb_road_lst.rl_code INNER JOIN
                dbo.tb_points ON dbo.tb_road_qty.pt_code = dbo.tb_points.pt_code


GO
/****** Object:  View [dbo].[tv_road_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_road_up]
AS
SELECT   dbo.tb_road_up.ru_code AS 对上编号, dbo.tb_road_up.pt_code AS 工点编号, dbo.tb_road_up.rl_code AS 清单编号, 
                dbo.tb_road_up.lr_code AS 台账编号, dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_road_lst.rl_project AS 工程项目, dbo.tb_road_lst.rl_unit AS 单位, dbo.tb_road_lst.rl_price_lst AS 单价, 
                dbo.tb_road_up.ru_qty_pre_design AS 上期设计数量, dbo.tb_road_up.ru_qty_pre_change AS 上期变更数量, 
                dbo.tb_road_up.ru_qty_cur_design AS 本期设计数量, dbo.tb_road_up.ru_qty_cur_change AS 本期变更数量, 
                dbo.tb_road_up.ru_qty_pre_design + dbo.tb_road_up.ru_qty_cur_design AS 累计设计数量, 
                dbo.tb_road_up.ru_qty_pre_change + dbo.tb_road_up.ru_qty_cur_change AS 累计变更数量, 
                dbo.tb_road_up.ru_info AS 备注
FROM      dbo.tb_road_up INNER JOIN
                dbo.tb_road_lst ON dbo.tb_road_up.rl_code = dbo.tb_road_lst.rl_code INNER JOIN
                dbo.tb_points ON dbo.tb_road_up.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_road_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tv_stock]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_stock]
AS
SELECT   TOP (100) PERCENT dbo.tb_stock.s_code AS 库存编号, dbo.tb_stock.b_code AS 仓库编号, 
                dbo.tb_stock.g_code AS 货物编号, dbo.tb_barn.b_name AS 仓库名称, dbo.tb_goods.g_name AS 货物名称, 
                dbo.tb_goods.g_type AS 货物类型, dbo.tb_goods.g_brand AS 货物品牌, dbo.tb_goods.g_standard AS 货物规格, 
                dbo.tb_goods.g_unit AS 货物单位, dbo.tb_goods.g_produce AS 货物产地, dbo.tb_stock.s_qty AS 货物数量, 
                dbo.tb_goods.g_price AS 货物单价, dbo.tb_stock.s_qty * dbo.tb_goods.g_price AS 货物金额, 
                dbo.tb_goods.g_pricebudget AS 预算单价, dbo.tb_stock.s_qty * dbo.tb_goods.g_pricebudget AS 预算金额, 
                dbo.tb_goods.g_pricesearch AS 调查单价, dbo.tb_stock.s_qty * dbo.tb_goods.g_pricesearch AS 调查金额, 
                dbo.tb_goods.g_pricecheck AS 盘点单价, dbo.tb_stock.s_qty * dbo.tb_goods.g_pricecheck AS 盘点金额, 
                dbo.tb_stock.s_info AS 库存备注
FROM      dbo.tb_stock INNER JOIN
                dbo.tb_barn ON dbo.tb_stock.b_code = dbo.tb_barn.b_code INNER JOIN
                dbo.tb_goods ON dbo.tb_stock.g_code = dbo.tb_goods.g_code
ORDER BY 库存编号

GO
/****** Object:  View [dbo].[tv_sys_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_contract]
AS
SELECT  TOP (100) PERCENT sct_id AS 清单ID, spi_id AS 节点ID, sct_code AS 清单编码, sct_name AS 细目名称, 
                   sct_unit AS 计价单位, sct_qty AS 工程数量, sct_price AS 综合单价, sct_money AS 合价, sct_info AS 备注
FROM      dbo.tb_sys_contract

GO
/****** Object:  View [dbo].[tv_sys_guidance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_guidance]
AS
SELECT  TOP (100) PERCENT sgd_id AS 指导价ID, sct_code AS 清单编码, sbg_code AS 定额编码, sgd_code AS 指导价编码, 
                   sgd_label AS 计量标识, sgd_name AS 项目名称, sgd_unit AS 计量单位, sgd_rate AS 单位比率, 
                   sgd_price AS 含税指导单价, sgd_item AS 含税项目单价, sgd_wark AS 工作内容, sgd_cost AS 费用组成, 
                   sgd_role AS 计量规则, sgd_info AS 指导价备注
FROM      dbo.tb_sys_guidance

GO
/****** Object:  View [dbo].[tv_sys_partitem]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_partitem]
AS
SELECT  TOP (100) PERCENT spi_level AS 节点级别, spi_node AS 节点名称, spi_id AS 节点ID, spi_rootid AS 根节点ID
FROM      dbo.tb_sys_partitem
GROUP BY spi_level, spi_node, spi_id, spi_rootid
ORDER BY 节点ID, 根节点ID

GO
/****** Object:  View [dbo].[tv_sys_quantity]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_quantity]
AS
SELECT  TOP (100) PERCENT dbo.tb_sys_quantity.sqy_id AS 数量ID, dbo.tb_sys_quantity.spi_id AS 节点ID, 
                   dbo.tb_sys_quantity.lb_id AS 劳务ID, dbo.tb_labour.lb_name AS 劳务名称, dbo.tb_sys_quantity.sct_id AS 清单ID, 
                   dbo.tb_sys_contract.sct_code AS 清单编码, dbo.tb_sys_quantity.sbg_id AS 概算ID, 
                   dbo.tb_sys_quantity.sqy_date AS 施工日期, dbo.tb_sys_quantity.sqy_name AS 数量名称, 
                   dbo.tb_sys_quantity.sqy_unit AS 计量单位, dbo.tb_sys_quantity.sqy_do_design AS 已完设计数量, 
                   dbo.tb_sys_quantity.sqy_do_change AS 已完变更数量, dbo.tb_sys_quantity.sqy_up_design AS 对上计价设计数量, 
                   dbo.tb_sys_quantity.sqy_up_change AS 对上计价变更数量, 
                   dbo.tb_sys_quantity.sqy_down_design AS 对下计价设计数量, 
                   dbo.tb_sys_quantity.sqy_down_change AS 对下计价变更数量, dbo.tb_sys_quantity.sqy_info AS 备注
FROM      dbo.tb_sys_quantity LEFT OUTER JOIN
                   dbo.tb_labour ON dbo.tb_sys_quantity.lb_id = dbo.tb_labour.lb_id LEFT OUTER JOIN
                   dbo.tb_sys_contract ON dbo.tb_sys_quantity.sct_id = dbo.tb_sys_contract.sct_id
ORDER BY 数量ID

GO
/****** Object:  View [dbo].[tv_sys_quantity_sum]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_quantity_sum]
AS
SELECT  TOP (100) PERCENT dbo.tb_sys_quantity_sum.sqy_id AS 数量ID, dbo.tb_sys_quantity_sum.spi_id AS 节点ID, 
                   dbo.tb_sys_quantity_sum.lb_id AS 劳务ID, dbo.tb_labour.lb_name AS 劳务名称, 
                   dbo.tb_sys_quantity_sum.sct_id AS 清单ID, dbo.tb_sys_contract.sct_code AS 清单编码, 
                   dbo.tb_sys_quantity_sum.sbg_id AS 概算ID, dbo.tb_sys_quantity_sum.sqy_date AS 施工日期, 
                   dbo.tb_sys_quantity_sum.sqy_name AS 数量名称, dbo.tb_sys_quantity_sum.sqy_unit AS 计量单位, 
                   dbo.tb_sys_quantity_sum.sqy_budget AS 分项概算数量, dbo.tb_sys_quantity_sum.sqy_dwg_design AS 图纸设计数量, 
                   dbo.tb_sys_quantity_sum.sqy_dwg_change AS 图纸变更数量, 
                   dbo.tb_sys_quantity_sum.sqy_chk_design AS 复核图纸设计数量, 
                   dbo.tb_sys_quantity_sum.sqy_chk_change AS 复核图纸变更数量, 
                   dbo.tb_sys_quantity_sum.sqy_act_design AS 现场设计数量, dbo.tb_sys_quantity_sum.sqy_act_change AS 现场变更数量, 
                   dbo.tb_sys_quantity_sum.sqy_do_design AS 已完设计数量, dbo.tb_sys_quantity_sum.sqy_do_change AS 已完变更数量, 
                   dbo.tb_sys_quantity_sum.sqy_up_design AS 对上计价设计数量, 
                   dbo.tb_sys_quantity_sum.sqy_up_change AS 对上计价变更数量, 
                   dbo.tb_sys_quantity_sum.sqy_down_design AS 对下计价设计数量, 
                   dbo.tb_sys_quantity_sum.sqy_down_change AS 对下计价变更数量, dbo.tb_sys_quantity_sum.sqy_info AS 备注
FROM      dbo.tb_sys_quantity_sum LEFT OUTER JOIN
                   dbo.tb_labour ON dbo.tb_sys_quantity_sum.lb_id = dbo.tb_labour.lb_id LEFT OUTER JOIN
                   dbo.tb_sys_contract ON dbo.tb_sys_quantity_sum.sct_id = dbo.tb_sys_contract.sct_id
ORDER BY 数量ID

GO
/****** Object:  View [dbo].[tv_sys_steel_library]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_steel_library]
AS
SELECT  ssl_id AS 构件ID, ssl_code AS 构件编号, ssl_describe AS 构件描述, ssl_number AS 钢筋编号, ssl_type AS 钢筋类型, 
                   ssl_diameter AS [钢筋直径(mm)], ssl_len_single AS [单根长(cm)], ssl_count AS 根数, ssl_len_total AS [总长(m)], 
                   ssl_mg_single AS [单位重(Kg/m)], ssl_mg_total AS [总重(Kg)], ssl_time AS [工时(h)], ssl_diagram AS 构件简图, 
                   ssl_info AS 构件备注
FROM      dbo.tb_sys_steel_library

GO
/****** Object:  View [dbo].[tv_sys_steel_order]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_steel_order]
AS
SELECT  sso_id AS 订单ID, hpi_id AS 节点ID, sso_code AS 订单编号, ssl_code AS 构件编号, sso_dt_order AS 订单日期, 
                   sso_dt_proc AS 加工日期, sso_dt_pick AS 领料日期, sso_info AS 订单备注
FROM      dbo.tb_sys_steel_order

GO
/****** Object:  View [dbo].[tv_sys_steel_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sys_steel_qty]
AS
SELECT   ssq_id AS 数量ID, hpi_id AS 节点ID, spi_id AS 系统节点ID, ssl_code AS 构件编号, ssl_describe AS 构件描述, 
                ssq_number AS 钢筋编号, ssq_type AS 钢筋类型, ssq_diameter AS [钢筋直径(mm)], ssq_len_single AS [单根长(cm)], 
                ssq_count AS 根数, ssq_len_total AS [总长(m)], ssq_mg_single AS [单位重(Kg/m)], ssq_mg_total AS [总重(Kg)], 
                ssq_entire_m AS 承台材质, ssq_entire_v AS [承台砼(m3)], ssq_sub_m AS 垫层材质, ssq_sub_v AS [垫层砼(m3)], 
                ssq_info AS 数量备注
FROM      dbo.tb_sys_steel_qty

GO
/****** Object:  View [dbo].[tv_sysprogram_demonstrate]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_sysprogram_demonstrate]
AS
SELECT  spd_id AS 方案ID, spi_id AS 节点ID, spd_type AS 方案类别, spd_program AS 专项方案, spd_demonstrate AS 论证要求, 
                   spd_info AS 方案备注
FROM      dbo.tb_sysprogram_demonstrate

GO
/****** Object:  View [dbo].[tv_temp_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_temp_down]
AS
SELECT   dbo.tb_temp_down.pd_code AS 对下编号, dbo.tb_temp_down.pt_code AS 工点编号, 
                dbo.tb_temp_down.pl_code AS 清单编号, dbo.tb_temp_down.lr_code AS 台账编号, 
                dbo.tb_temp_down.u_code AS 队伍编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_temp_lst.pl_project AS 工程项目, dbo.tb_temp_lst.pl_unit AS 单位, dbo.tb_temp_lst.pl_price_lbr AS 单价, 
                dbo.tb_temp_down.pd_qty_pre_design AS 上期设计数量, dbo.tb_temp_down.pd_qty_pre_change AS 上期变更数量, 
                dbo.tb_temp_down.pd_qty_cur_design AS 本期设计数量, dbo.tb_temp_down.pd_qty_cur_change AS 本期变更数量, 
                dbo.tb_temp_down.pd_qty_pre_design + dbo.tb_temp_down.pd_qty_cur_design AS 累计设计数量, 
                dbo.tb_temp_down.pd_qty_pre_change + dbo.tb_temp_down.pd_qty_cur_change AS 累计变更数量, 
                dbo.tb_temp_down.pd_info AS 备注
FROM      dbo.tb_temp_down INNER JOIN
                dbo.tb_temp_lst ON dbo.tb_temp_down.pl_code = dbo.tb_temp_lst.pl_code INNER JOIN
                dbo.tb_points ON dbo.tb_temp_down.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_temp_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_temp_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tv_temp_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_temp_lst]
AS
SELECT   pl_code AS 清单编号, pl_number AS 清单编码, pl_section AS 清单节号, pl_project AS 工程细目名称, pl_unit AS 单位, 
                pl_qty_lst AS 清单数量, pl_price_lst AS 清单单价, pl_money_lst AS 清单合价, pl_qty_lbr AS 劳务数量, 
                pl_price_lbr_Labor AS 劳务单价, pl_price_lbr_good AS 主材单价, pl_price_lbr_device AS 机械单价, pl_price_lbr, 
                pl_money_lbr_Labor AS 劳务合价, pl_money_lbr_good AS 主材合价, pl_money_lbr_device AS 机械合价, pl_money_lbr, 
                pl_info AS 备注
FROM      dbo.tb_temp_lst


GO
/****** Object:  View [dbo].[tv_temp_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_temp_qty]
AS
SELECT   dbo.tb_temp_qty.pq_code AS 数量编号, dbo.tb_temp_qty.pt_code AS 工点编号, dbo.tb_temp_qty.pl_code AS 清单编号, 
                dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, dbo.tb_temp_lst.pl_project AS 工程项目, 
                dbo.tb_temp_lst.pl_unit AS 单位, dbo.tb_temp_qty.pq_qty_dwg_design AS 蓝图设计数量, 
                dbo.tb_temp_qty.pq_qty_dwg_change AS 蓝图变更数量, dbo.tb_temp_qty.pq_qty_chk_design AS 复核设计数量, 
                dbo.tb_temp_qty.pq_qty_chk_change AS 复核变更数量, dbo.tb_temp_qty.pq_qty_doe_design AS 已完设计数量, 
                dbo.tb_temp_qty.pq_qty_doe_change AS 已完变更数量, dbo.tb_temp_qty.pq_info AS 备注
FROM      dbo.tb_temp_qty INNER JOIN
                dbo.tb_temp_lst ON dbo.tb_temp_qty.pl_code = dbo.tb_temp_lst.pl_code INNER JOIN
                dbo.tb_points ON dbo.tb_temp_qty.pt_code = dbo.tb_points.pt_code


GO
/****** Object:  View [dbo].[tv_temp_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_temp_up]
AS
SELECT   dbo.tb_temp_up.pu_code AS 对上编号, dbo.tb_ledger.lr_date AS 对上日期, dbo.tb_temp_up.pt_code AS 工点编号, 
                dbo.tb_temp_up.pl_code AS 清单编号, dbo.tb_temp_up.lr_code AS 台账编号, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_temp_lst.pl_project AS 工程项目, dbo.tb_temp_lst.pl_unit AS 单位, dbo.tb_temp_lst.pl_price_lst AS 单价, 
                dbo.tb_temp_up.pu_qty_pre_design AS 上期设计数量, dbo.tb_temp_up.pu_qty_pre_change AS 上期变更数量, 
                dbo.tb_temp_up.pu_qty_cur_design AS 本期设计数量, dbo.tb_temp_up.pu_qty_cur_change AS 本期变更数量, 
                dbo.tb_temp_up.pu_qty_pre_design + dbo.tb_temp_up.pu_qty_cur_design AS 累计设计数量, 
                dbo.tb_temp_up.pu_qty_pre_change + dbo.tb_temp_up.pu_qty_cur_change AS 累计变更数量, 
                dbo.tb_temp_up.pu_info AS 备注
FROM      dbo.tb_temp_up INNER JOIN
                dbo.tb_temp_lst ON dbo.tb_temp_up.pl_code = dbo.tb_temp_lst.pl_code INNER JOIN
                dbo.tb_points ON dbo.tb_temp_up.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_temp_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tv_tunnel_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_tunnel_down]
AS
SELECT   dbo.tb_tunnel_down.td_code AS 对下编号, dbo.tb_tunnel_down.pt_code AS 工点编号, 
                dbo.tb_tunnel_down.tl_code AS 清单编号, dbo.tb_tunnel_down.lr_code AS 台账编号, 
                dbo.tb_tunnel_down.u_code AS 队伍编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_tunnel_lst.tl_project AS 工程项目, dbo.tb_tunnel_lst.tl_unit AS 单位, dbo.tb_tunnel_lst.tl_price_lbr AS 单价, 
                dbo.tb_tunnel_down.td_qty_pre_design AS 上期设计数量, dbo.tb_tunnel_down.td_qty_pre_change AS 上期变更数量, 
                dbo.tb_tunnel_down.td_qty_cur_design AS 本期设计数量, dbo.tb_tunnel_down.td_qty_cur_change AS 本期变更数量, 
                dbo.tb_tunnel_down.td_qty_pre_design + dbo.tb_tunnel_down.td_qty_cur_design AS 累计设计数量, 
                dbo.tb_tunnel_down.td_qty_pre_change + dbo.tb_tunnel_down.td_qty_cur_change AS 累计变更数量, 
                dbo.tb_tunnel_down.td_info AS 备注
FROM      dbo.tb_tunnel_down INNER JOIN
                dbo.tb_tunnel_lst ON dbo.tb_tunnel_down.tl_code = dbo.tb_tunnel_lst.tl_code INNER JOIN
                dbo.tb_points ON dbo.tb_tunnel_down.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_tunnel_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_tunnel_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tv_tunnel_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_tunnel_lst]
AS
SELECT   tl_code AS 清单编号, tl_number AS 清单编码, tl_section AS 清单节号, tl_project AS 工程细目名称, tl_unit AS 单位, 
                tl_qty_lst AS 清单数量, tl_price_lst AS 清单单价, tl_money_lst AS 清单合价, tl_qty_lbr AS 劳务数量, 
                tl_price_lbr_Labor AS 劳务单价, tl_price_lbr_good AS 主材单价, tl_price_lbr_device AS 机械单价, tl_price_lbr, 
                tl_money_lbr_Labor AS 劳务合价, tl_money_lbr_good AS 主材合价, tl_money_lbr_device AS 机械合价, tl_money_lbr, 
                tl_info AS 备注
FROM      dbo.tb_tunnel_lst


GO
/****** Object:  View [dbo].[tv_tunnel_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_tunnel_qty]
AS
SELECT   dbo.tb_tunnel_qty.tq_code AS 数量编号, dbo.tb_tunnel_qty.pt_code AS 工点编号, 
                dbo.tb_tunnel_qty.tl_code AS 清单编号, dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_tunnel_lst.tl_project AS 工程项目, dbo.tb_tunnel_lst.tl_unit AS 单位, 
                dbo.tb_tunnel_qty.tq_qty_dwg_design AS 蓝图设计数量, dbo.tb_tunnel_qty.tq_qty_dwg_change AS 蓝图变更数量, 
                dbo.tb_tunnel_qty.tq_qty_chk_design AS 复核设计数量, dbo.tb_tunnel_qty.tq_qty_chk_change AS 复核变更数量, 
                dbo.tb_tunnel_qty.tq_qty_doe_design AS 已完设计数量, dbo.tb_tunnel_qty.tq_qty_doe_change AS 已完变更数量, 
                dbo.tb_tunnel_qty.tq_info AS 备注
FROM      dbo.tb_tunnel_qty INNER JOIN
                dbo.tb_tunnel_lst ON dbo.tb_tunnel_qty.tl_code = dbo.tb_tunnel_lst.tl_code INNER JOIN
                dbo.tb_points ON dbo.tb_tunnel_qty.pt_code = dbo.tb_points.pt_code


GO
/****** Object:  View [dbo].[tv_tunnel_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_tunnel_up]
AS
SELECT   dbo.tb_tunnel_up.tu_code AS 对上编号, dbo.tb_tunnel_up.pt_code AS 工点编号, dbo.tb_tunnel_up.tl_code AS 清单编号, 
                dbo.tb_tunnel_up.lr_code AS 台账编号, dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_tunnel_lst.tl_project AS 工程项目, dbo.tb_tunnel_lst.tl_unit AS 单位, dbo.tb_tunnel_lst.tl_price_lst AS 单价, 
                dbo.tb_tunnel_up.tu_qty_pre_design AS 上期设计数量, dbo.tb_tunnel_up.tu_qty_pre_change AS 上期变更数量, 
                dbo.tb_tunnel_up.tu_qty_cur_design AS 本期设计数量, dbo.tb_tunnel_up.tu_qty_cur_change AS 本期变更数量, 
                dbo.tb_tunnel_up.tu_qty_pre_design + dbo.tb_tunnel_up.tu_qty_cur_design AS 累计设计数量, 
                dbo.tb_tunnel_up.tu_qty_pre_change + dbo.tb_tunnel_up.tu_qty_cur_change AS 累计变更数量, 
                dbo.tb_tunnel_up.tu_info AS 备注
FROM      dbo.tb_tunnel_up INNER JOIN
                dbo.tb_tunnel_lst ON dbo.tb_tunnel_up.tl_code = dbo.tb_tunnel_lst.tl_code INNER JOIN
                dbo.tb_points ON dbo.tb_tunnel_up.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_tunnel_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[tv_units]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_units]
AS
SELECT   TOP (100) PERCENT u_code AS 编号, u_name AS 名称, u_type AS 类别, u_tax AS 传真, u_tel AS 电话, 
                u_address AS 地址, u_email AS 邮箱, u_bank AS 银行, u_account AS 账户, u_legalman AS 法人, u_linkman AS 委托人, 
                u_linktel AS 手机, u_income AS 入账金额, u_payout AS 支出金额, u_info AS 备注
FROM      dbo.tb_units
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_users]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_users]
AS
SELECT   TOP (100) PERCENT id AS 编号, sysuser AS 用户, password AS 密码, cip AS 客户端IP, cport AS 客户端口, 
                sip AS 服务器IP, sport AS 服务器端口, state AS 登录状态, advanced AS 系统权限, remberpwd AS 记住密码, 
                autologin AS 自动登录
FROM      dbo.tb_users
ORDER BY 编号

GO
/****** Object:  View [dbo].[tv_yard_down]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_yard_down]
AS
SELECT   dbo.tb_yard_down.yd_code AS 对下编号, dbo.tb_yard_down.pt_code AS 工点编号, 
                dbo.tb_yard_down.yl_code AS 清单编号, dbo.tb_yard_down.lr_code AS 台账编号, 
                dbo.tb_yard_down.u_code AS 队伍编号, dbo.tb_ledger.lr_date AS 对下日期, dbo.tb_units.u_legalman AS 施工队伍, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_yard_lst.yl_project AS 工程项目, dbo.tb_yard_lst.yl_unit AS 单位, dbo.tb_yard_lst.yl_price_lbr AS 单价, 
                dbo.tb_yard_down.yd_qty_pre_design AS 上期设计数量, dbo.tb_yard_down.yd_qty_pre_change AS 上期变更数量, 
                dbo.tb_yard_down.yd_qty_cur_design AS 本期设计数量, dbo.tb_yard_down.yd_qty_cur_change AS 本期变更数量, 
                dbo.tb_yard_down.yd_qty_pre_design + dbo.tb_yard_down.yd_qty_cur_design AS 累计设计数量, 
                dbo.tb_yard_down.yd_qty_pre_change + dbo.tb_yard_down.yd_qty_cur_change AS 累计变更数量, 
                dbo.tb_yard_down.yd_info AS 备注
FROM      dbo.tb_yard_down INNER JOIN
                dbo.tb_yard_lst ON dbo.tb_yard_down.yl_code = dbo.tb_yard_lst.yl_code INNER JOIN
                dbo.tb_points ON dbo.tb_yard_down.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_yard_down.lr_code = dbo.tb_ledger.lr_code INNER JOIN
                dbo.tb_units ON dbo.tb_yard_down.u_code = dbo.tb_units.u_code


GO
/****** Object:  View [dbo].[tv_yard_lst]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_yard_lst]
AS
SELECT   yl_code AS 清单编号, yl_number AS 清单编码, yl_section AS 清单节号, yl_project AS 工程细目名称, yl_unit AS 单位, 
                yl_qty_lst AS 清单数量, yl_price_lst AS 清单单价, yl_money_lst AS 清单合价, yl_qty_lbr AS 劳务数量, 
                yl_price_lbr_Labor AS 劳务单价, yl_price_lbr_good AS 主材单价, yl_price_lbr_device AS 机械单价, yl_price_lbr, 
                yl_money_lbr_Labor AS 劳务合价, yl_money_lbr_good AS 主材合价, yl_money_lbr_device AS 机械合价, yl_money_lbr, 
                yl_info AS 备注
FROM      dbo.tb_yard_lst


GO
/****** Object:  View [dbo].[tv_yard_qty]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_yard_qty]
AS
SELECT   dbo.tb_yard_qty.yq_code AS 数量编号, dbo.tb_yard_qty.pt_code AS 工点编号, dbo.tb_yard_qty.yl_code AS 清单编号, 
                dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, dbo.tb_yard_lst.yl_project AS 工程项目, 
                dbo.tb_yard_lst.yl_unit AS 单位, dbo.tb_yard_qty.yq_qty_dwg_design AS 蓝图设计数量, 
                dbo.tb_yard_qty.yq_qty_dwg_change AS 蓝图变更数量, dbo.tb_yard_qty.yq_qty_chk_design AS 复核设计数量, 
                dbo.tb_yard_qty.yq_qty_chk_change AS 复核变更数量, dbo.tb_yard_qty.yq_qty_doe_design AS 已完设计数量, 
                dbo.tb_yard_qty.yq_qty_doe_change AS 已完变更数量, dbo.tb_yard_qty.yq_info AS 备注
FROM      dbo.tb_yard_qty INNER JOIN
                dbo.tb_yard_lst ON dbo.tb_yard_qty.yl_code = dbo.tb_yard_lst.yl_code INNER JOIN
                dbo.tb_points ON dbo.tb_yard_qty.pt_code = dbo.tb_points.pt_code


GO
/****** Object:  View [dbo].[tv_yard_up]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tv_yard_up]
AS
SELECT   dbo.tb_yard_up.yu_code AS 对上编号, dbo.tb_yard_up.pt_code AS 工点编号, dbo.tb_yard_up.yl_code AS 清单编号, 
                dbo.tb_yard_up.lr_code AS 台账编号, dbo.tb_ledger.lr_date AS 对上日期, 
                dbo.tb_points.pt_name + '  ' + dbo.tb_points.pt_bstat + '～' + dbo.tb_points.pt_estat AS 里程桩号, 
                dbo.tb_yard_lst.yl_project AS 工程项目, dbo.tb_yard_lst.yl_unit AS 单位, dbo.tb_yard_lst.yl_price_lst AS 单价, 
                dbo.tb_yard_up.yu_qty_pre_design AS 上期设计数量, dbo.tb_yard_up.yu_qty_pre_change AS 上期变更数量, 
                dbo.tb_yard_up.yu_qty_cur_design AS 本期设计数量, dbo.tb_yard_up.yu_qty_cur_change AS 本期变更数量, 
                dbo.tb_yard_up.yu_qty_pre_design + dbo.tb_yard_up.yu_qty_cur_design AS 累计设计数量, 
                dbo.tb_yard_up.yu_qty_pre_change + dbo.tb_yard_up.yu_qty_cur_change AS 累计变更数量, 
                dbo.tb_yard_up.yu_info AS 备注
FROM      dbo.tb_yard_up INNER JOIN
                dbo.tb_yard_lst ON dbo.tb_yard_up.yl_code = dbo.tb_yard_lst.yl_code INNER JOIN
                dbo.tb_points ON dbo.tb_yard_up.pt_code = dbo.tb_points.pt_code INNER JOIN
                dbo.tb_ledger ON dbo.tb_yard_up.lr_code = dbo.tb_ledger.lr_code


GO
/****** Object:  View [dbo].[vT_guidance]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vT_guidance]
AS
SELECT  TOP (100) PERCENT dbo.T.id, MIN(dbo.tb_guidance.gd_id) AS gd_id, dbo.T.code AS ct_code, MIN(dbo.tb_guidance.bg_code) 
                   AS bg_code, MIN(dbo.tb_guidance.gd_code) AS gd_code, MIN(dbo.tb_guidance.gd_label) AS gd_label, 
                   MIN(dbo.tb_guidance.gd_name) AS gd_name, MIN(dbo.tb_guidance.gd_unit) AS gd_unit, MIN(dbo.tb_guidance.gd_rate) 
                   AS gd_rate, MIN(dbo.tb_guidance.gd_price) AS gd_price, MIN(dbo.tb_guidance.gd_item) AS gd_item, 
                   MIN(dbo.tb_guidance.gd_wark) AS gd_wark, MIN(dbo.tb_guidance.gd_cost) AS gd_cost, MIN(dbo.tb_guidance.gd_role) 
                   AS gd_role, MIN(dbo.tb_guidance.gd_info) AS gd_info
FROM      dbo.T LEFT OUTER JOIN
                   dbo.tb_guidance ON dbo.T._code = dbo.tb_guidance.gd_code
GROUP BY dbo.T.id, dbo.T.code, dbo.T._code
ORDER BY dbo.T.id

GO
/****** Object:  View [dbo].[vT_sys_contract]    Script Date: 2019/12/30 14:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vT_sys_contract]
AS
SELECT  TOP (100) PERCENT dbo.T.id, MIN(dbo.T.code) AS code, MIN(dbo.tb_sys_contract.spi_id) AS spi_id, 
                   MIN(dbo.tb_sys_contract.sct_id) AS sct_id, MIN(dbo.tb_sys_contract.sct_code) AS sct_code, MIN(dbo.T._id) AS _id
FROM      dbo.T LEFT OUTER JOIN
                   dbo.tb_sys_contract ON dbo.T.code = dbo.tb_sys_contract.sct_code AND dbo.T._id = dbo.tb_sys_contract.spi_id
GROUP BY dbo.T.id
ORDER BY dbo.T.id

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_barn]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_barn] ON [dbo].[tb_barn]
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_down_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_down_ledger] ON [dbo].[tb_bridge_down]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_down_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_down_lst] ON [dbo].[tb_bridge_down]
(
	[bl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_down_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_down_points] ON [dbo].[tb_bridge_down]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_down_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_down_units] ON [dbo].[tb_bridge_down]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_lst] ON [dbo].[tb_bridge_lst]
(
	[bl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_lst_project]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_lst_project] ON [dbo].[tb_bridge_lst]
(
	[bl_project] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_qty_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_qty_lst] ON [dbo].[tb_bridge_qty]
(
	[bl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_qty_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_qty_points] ON [dbo].[tb_bridge_qty]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_up_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_up_ledger] ON [dbo].[tb_bridge_up]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_up_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_up_lst] ON [dbo].[tb_bridge_up]
(
	[bl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_up_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_up_points] ON [dbo].[tb_bridge_up]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_bridge_up_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_bridge_up_units] ON [dbo].[tb_bridge_up]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_check_barn]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_check_barn] ON [dbo].[tb_check]
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_check_employee]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_check_employee] ON [dbo].[tb_check]
(
	[e_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_check_goods]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_check_goods] ON [dbo].[tb_check]
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_employee]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_employee] ON [dbo].[tb_employee]
(
	[e_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_goods]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_goods] ON [dbo].[tb_goods]
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_instock_barn]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_instock_barn] ON [dbo].[tb_instock]
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_instock_bill]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_instock_bill] ON [dbo].[tb_instock]
(
	[i_bill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_instock_employee]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_instock_employee] ON [dbo].[tb_instock]
(
	[e_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_instock_goods]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_instock_goods] ON [dbo].[tb_instock]
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_instock_pact]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_instock_pact] ON [dbo].[tb_instock]
(
	[p_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_instock_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_instock_units] ON [dbo].[tb_instock]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_ledger] ON [dbo].[tb_ledger]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
/****** Object:  Index [IX_ledger_date]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_ledger_date] ON [dbo].[tb_ledger]
(
	[lr_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_mixstock_barn]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_mixstock_barn] ON [dbo].[tb_mixstock]
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_mixstock_bill]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_mixstock_bill] ON [dbo].[tb_mixstock]
(
	[m_bill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_mixstock_employee]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_mixstock_employee] ON [dbo].[tb_mixstock]
(
	[e_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_mixstock_goods]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_mixstock_goods] ON [dbo].[tb_mixstock]
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_mixstock_pact]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_mixstock_pact] ON [dbo].[tb_mixstock]
(
	[p_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_mixstock_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_mixstock_units] ON [dbo].[tb_mixstock]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_down_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_down_ledger] ON [dbo].[tb_orbital_down]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_down_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_down_lst] ON [dbo].[tb_orbital_down]
(
	[ol_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_down_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_down_points] ON [dbo].[tb_orbital_down]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_down_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_down_units] ON [dbo].[tb_orbital_down]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_lst] ON [dbo].[tb_orbital_lst]
(
	[ol_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_lst_project]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_lst_project] ON [dbo].[tb_orbital_lst]
(
	[ol_project] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_qty_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_qty_lst] ON [dbo].[tb_orbital_qty]
(
	[ol_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_qty_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_qty_points] ON [dbo].[tb_orbital_qty]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_up_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_up_ledger] ON [dbo].[tb_orbital_up]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_up_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_up_lst] ON [dbo].[tb_orbital_up]
(
	[ol_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_up_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_up_points] ON [dbo].[tb_orbital_up]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_orbital_up_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_orbital_up_units] ON [dbo].[tb_orbital_up]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_outstock_barn]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_outstock_barn] ON [dbo].[tb_outstock]
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_outstock_bill]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_outstock_bill] ON [dbo].[tb_outstock]
(
	[o_bill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_outstock_employee]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_outstock_employee] ON [dbo].[tb_outstock]
(
	[e_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_outstock_goods]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_outstock_goods] ON [dbo].[tb_outstock]
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_outstock_pact]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_outstock_pact] ON [dbo].[tb_outstock]
(
	[p_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_outstock_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_outstock_units] ON [dbo].[tb_outstock]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_pact]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_pact] ON [dbo].[tb_pact]
(
	[p_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_points] ON [dbo].[tb_points]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_points_name]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_points_name] ON [dbo].[tb_points]
(
	[pt_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_problem_number]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_problem_number] ON [dbo].[tb_problem]
(
	[pm_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_problem_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_problem_point] ON [dbo].[tb_problem]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_orbit]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_orbit] ON [dbo].[tb_retest_orbit]
(
	[ro_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_orbit_left_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_orbit_left_point] ON [dbo].[tb_retest_orbit]
(
	[ro_left_point] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_orbit_mark]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_orbit_mark] ON [dbo].[tb_retest_orbit]
(
	[rp_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_orbit_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_orbit_point] ON [dbo].[tb_retest_orbit]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_orbit_right_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_orbit_right_point] ON [dbo].[tb_retest_orbit]
(
	[ro_right_point] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_plate]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_plate] ON [dbo].[tb_retest_plate]
(
	[rp_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_plate_mark]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_plate_mark] ON [dbo].[tb_retest_plate]
(
	[rp_mark] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_plate_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_plate_point] ON [dbo].[tb_retest_plate]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_rail]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_rail] ON [dbo].[tb_retest_rail]
(
	[rr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_rail_left_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_rail_left_point] ON [dbo].[tb_retest_rail]
(
	[rr_left_point] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_rail_mark]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_rail_mark] ON [dbo].[tb_retest_rail]
(
	[rp_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_rail_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_rail_point] ON [dbo].[tb_retest_rail]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retest_rail_right_point]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retest_rail_right_point] ON [dbo].[tb_retest_rail]
(
	[rr_right_point] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retstock_barn]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retstock_barn] ON [dbo].[tb_retstock]
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retstock_bill]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retstock_bill] ON [dbo].[tb_retstock]
(
	[r_bill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retstock_employee]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retstock_employee] ON [dbo].[tb_retstock]
(
	[e_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retstock_goods]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retstock_goods] ON [dbo].[tb_retstock]
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retstock_pact]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retstock_pact] ON [dbo].[tb_retstock]
(
	[p_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_retstock_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_retstock_units] ON [dbo].[tb_retstock]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_down_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_down_ledger] ON [dbo].[tb_road_down]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_down_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_down_lst] ON [dbo].[tb_road_down]
(
	[rl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_down_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_down_points] ON [dbo].[tb_road_down]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_down_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_down_units] ON [dbo].[tb_road_down]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_lst] ON [dbo].[tb_road_lst]
(
	[rl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_lst_project]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_lst_project] ON [dbo].[tb_road_lst]
(
	[rl_project] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_qty_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_qty_lst] ON [dbo].[tb_road_qty]
(
	[rl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_qty_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_qty_points] ON [dbo].[tb_road_qty]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_up_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_up_ledger] ON [dbo].[tb_road_up]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_up_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_up_lst] ON [dbo].[tb_road_up]
(
	[rl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_up_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_up_points] ON [dbo].[tb_road_up]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_road_up_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_road_up_units] ON [dbo].[tb_road_up]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_stock_barn]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_stock_barn] ON [dbo].[tb_stock]
(
	[b_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_stock_goods]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_stock_goods] ON [dbo].[tb_stock]
(
	[g_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_down_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_down_ledger] ON [dbo].[tb_temp_down]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_down_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_down_lst] ON [dbo].[tb_temp_down]
(
	[pl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_down_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_down_points] ON [dbo].[tb_temp_down]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_down_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_down_units] ON [dbo].[tb_temp_down]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_lst] ON [dbo].[tb_temp_lst]
(
	[pl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_lst_project]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_lst_project] ON [dbo].[tb_temp_lst]
(
	[pl_project] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_qty_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_qty_lst] ON [dbo].[tb_temp_qty]
(
	[pl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_qty_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_qty_points] ON [dbo].[tb_temp_qty]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_up_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_up_ledger] ON [dbo].[tb_temp_up]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_up_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_up_lst] ON [dbo].[tb_temp_up]
(
	[pl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_up_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_up_points] ON [dbo].[tb_temp_up]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_temp_up_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_temp_up_units] ON [dbo].[tb_temp_up]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_down_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_down_ledger] ON [dbo].[tb_tunnel_down]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_down_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_down_lst] ON [dbo].[tb_tunnel_down]
(
	[tl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_down_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_down_points] ON [dbo].[tb_tunnel_down]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_down_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_down_units] ON [dbo].[tb_tunnel_down]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_lst] ON [dbo].[tb_tunnel_lst]
(
	[tl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_lst_project]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_lst_project] ON [dbo].[tb_tunnel_lst]
(
	[tl_project] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_qty_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_qty_lst] ON [dbo].[tb_tunnel_qty]
(
	[tl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_qty_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_qty_points] ON [dbo].[tb_tunnel_qty]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_up_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_up_ledger] ON [dbo].[tb_tunnel_up]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_up_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_up_lst] ON [dbo].[tb_tunnel_up]
(
	[tl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_up_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_up_points] ON [dbo].[tb_tunnel_up]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_tunnel_up_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_tunnel_up_units] ON [dbo].[tb_tunnel_up]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_units] ON [dbo].[tb_units]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_down_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_down_ledger] ON [dbo].[tb_yard_down]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_down_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_down_lst] ON [dbo].[tb_yard_down]
(
	[yl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_down_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_down_points] ON [dbo].[tb_yard_down]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_down_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_down_units] ON [dbo].[tb_yard_down]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_lst] ON [dbo].[tb_yard_lst]
(
	[yl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_lst_project]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_lst_project] ON [dbo].[tb_yard_lst]
(
	[yl_project] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_qty_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_qty_lst] ON [dbo].[tb_yard_qty]
(
	[yl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_qty_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_qty_points] ON [dbo].[tb_yard_qty]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_up_ledger]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_up_ledger] ON [dbo].[tb_yard_up]
(
	[lr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_up_lst]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_up_lst] ON [dbo].[tb_yard_up]
(
	[yl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_up_points]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_up_points] ON [dbo].[tb_yard_up]
(
	[pt_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_yard_up_units]    Script Date: 2019/12/30 14:11:56 ******/
CREATE NONCLUSTERED INDEX [IX_yard_up_units] ON [dbo].[tb_yard_up]
(
	[u_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_code]  DEFAULT ('OD00000000') FOR [od_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_ol_code]  DEFAULT ('OL001') FOR [ol_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_pre_design]  DEFAULT ((0)) FOR [od_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_pre_change]  DEFAULT ((0)) FOR [od_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_cur_design]  DEFAULT ((0)) FOR [od_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_cur_change]  DEFAULT ((0)) FOR [od_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_time]  DEFAULT (getdate()) FOR [od_time]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_estab]  DEFAULT (N'编制') FOR [od_estab]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_check]  DEFAULT (N'未复核') FOR [od_check]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_audit]  DEFAULT (N'未审核') FOR [od_audit]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_code]  DEFAULT ('OQ00000000') FOR [oq_code]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_ol_code]  DEFAULT ('OL001') FOR [ol_code]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_dwg_design]  DEFAULT ((0)) FOR [oq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_dwg_change]  DEFAULT ((0)) FOR [oq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_chk_design]  DEFAULT ((0)) FOR [oq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_chk_change]  DEFAULT ((0)) FOR [oq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_doe_design]  DEFAULT ((0)) FOR [oq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_doe_change]  DEFAULT ((0)) FOR [oq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_time]  DEFAULT (getdate()) FOR [oq_time]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_estab]  DEFAULT (N'编制') FOR [oq_estab]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_check]  DEFAULT (N'未复核') FOR [oq_check]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_audit]  DEFAULT (N'未审核') FOR [oq_audit]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_code]  DEFAULT ('OU00000000') FOR [ou_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ol_code]  DEFAULT ('OL001') FOR [ol_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_pre_design]  DEFAULT ((0)) FOR [ou_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_pre_change]  DEFAULT ((0)) FOR [ou_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_cur_design]  DEFAULT ((0)) FOR [ou_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_cur_change]  DEFAULT ((0)) FOR [ou_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_time]  DEFAULT (getdate()) FOR [ou_time]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_estab]  DEFAULT (N'编制') FOR [ou_estab]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_check]  DEFAULT (N'未复核') FOR [ou_check]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_audit]  DEFAULT (N'未审核') FOR [ou_audit]
GO
ALTER TABLE [dbo].[tb_railway_partitem] ADD  CONSTRAINT [DF_tb_railway_partitem_rpi_id]  DEFAULT ((1)) FOR [rpi_id]
GO
ALTER TABLE [dbo].[tb_railway_partitem] ADD  CONSTRAINT [DF_tb_railway_partitem_rpi_rootid]  DEFAULT ((0)) FOR [rpi_rootid]
GO
ALTER TABLE [dbo].[tb_railway_partitem] ADD  CONSTRAINT [DF_tb_railway_partitem_rpi_level]  DEFAULT ((1)) FOR [rpi_level]
GO
ALTER TABLE [dbo].[tb_railway_partitem] ADD  CONSTRAINT [DF_tb_railway_partitem_rpi_node]  DEFAULT (N'XXX节点') FOR [rpi_node]
GO
ALTER TABLE [dbo].[tb_railway_partitem] ADD  CONSTRAINT [DF_tb_railway_partitem_spi_id]  DEFAULT ((1)) FOR [spi_id]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_s_code]  DEFAULT ('S000000000') FOR [s_code]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_b_code]  DEFAULT ('B0001') FOR [b_code]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_g_code]  DEFAULT ('G0001') FOR [g_code]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_s_qty]  DEFAULT ((0)) FOR [s_qty]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_s_time]  DEFAULT (getdate()) FOR [s_time]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_s_estab]  DEFAULT (N'编制') FOR [s_estab]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_s_check]  DEFAULT (N'未复核') FOR [s_check]
GO
ALTER TABLE [dbo].[tb_stock] ADD  CONSTRAINT [DF_tb_stock_s_audit]  DEFAULT (N'未审核') FOR [s_audit]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_code]  DEFAULT ('PD00000000') FOR [pd_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pl_code]  DEFAULT ('PL001') FOR [pl_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_pre_design]  DEFAULT ((0)) FOR [pd_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_pre_change]  DEFAULT ((0)) FOR [pd_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_cur_design]  DEFAULT ((0)) FOR [pd_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_cur_change]  DEFAULT ((0)) FOR [pd_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_time]  DEFAULT (getdate()) FOR [pd_time]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_estab]  DEFAULT (N'编制') FOR [pd_estab]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_check]  DEFAULT (N'未复核') FOR [pd_check]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_audit]  DEFAULT (N'未审核') FOR [pd_audit]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_code]  DEFAULT ('PL000') FOR [pl_code]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_number]  DEFAULT ((1234567890)) FOR [pl_number]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_section]  DEFAULT ((1234567890)) FOR [pl_section]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_project]  DEFAULT (N'xxx项目') FOR [pl_project]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_unit]  DEFAULT (N'm3') FOR [pl_unit]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_qty_lst]  DEFAULT ((0)) FOR [pl_qty_lst]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_price_lst]  DEFAULT ((0)) FOR [pl_price_lst]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_qty_lbr]  DEFAULT ((0)) FOR [pl_qty_lbr]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_price_lbr_Labor]  DEFAULT ((0)) FOR [pl_price_lbr_Labor]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_price_lbr_good]  DEFAULT ((0)) FOR [pl_price_lbr_good]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_price_lbr_device]  DEFAULT ((0)) FOR [pl_price_lbr_device]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_date]  DEFAULT (getdate()) FOR [pl_time]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_estab]  DEFAULT (N'编制') FOR [pl_estab]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_check]  DEFAULT (N'未复核') FOR [pl_check]
GO
ALTER TABLE [dbo].[tb_temp_lst] ADD  CONSTRAINT [DF_tb_temp_lst_pl_audit]  DEFAULT (N'未审核') FOR [pl_audit]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_code]  DEFAULT ('PQ00000000') FOR [pq_code]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pl_code]  DEFAULT ('PL001') FOR [pl_code]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_dwg_design]  DEFAULT ((0)) FOR [pq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_dwg_change]  DEFAULT ((0)) FOR [pq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_chk_design]  DEFAULT ((0)) FOR [pq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_chk_change]  DEFAULT ((0)) FOR [pq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_doe_design]  DEFAULT ((0)) FOR [pq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_doe_change]  DEFAULT ((0)) FOR [pq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_time]  DEFAULT (getdate()) FOR [pq_time]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_estab]  DEFAULT (N'编制') FOR [pq_estab]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_check]  DEFAULT (N'未复核') FOR [pq_check]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_audit]  DEFAULT (N'未审核') FOR [pq_audit]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_code]  DEFAULT ('PU00000000') FOR [pu_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pl_code]  DEFAULT ('PL001') FOR [pl_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_pre_design]  DEFAULT ((0)) FOR [pu_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_pre_change]  DEFAULT ((0)) FOR [pu_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_cur_design]  DEFAULT ((0)) FOR [pu_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_cur_change]  DEFAULT ((0)) FOR [pu_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_time]  DEFAULT (getdate()) FOR [pu_time]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_estab]  DEFAULT (N'编制') FOR [pu_estab]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_check]  DEFAULT (N'未复核') FOR [pu_check]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_audit]  DEFAULT (N'未审核') FOR [pu_audit]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_code]  DEFAULT ('TD00000000') FOR [td_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_tl_code]  DEFAULT ('TL001') FOR [tl_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_pre_design]  DEFAULT ((0)) FOR [td_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_pre_change]  DEFAULT ((0)) FOR [td_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_cur_design]  DEFAULT ((0)) FOR [td_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_cur_change]  DEFAULT ((0)) FOR [td_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_time]  DEFAULT (getdate()) FOR [td_time]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_estab]  DEFAULT (N'编制') FOR [td_estab]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_check]  DEFAULT (N'未复核') FOR [td_check]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_audit]  DEFAULT (N'未审核') FOR [td_audit]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_code]  DEFAULT ('TQ00000000') FOR [tq_code]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tl_code]  DEFAULT ('TL001') FOR [tl_code]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_dwg_design]  DEFAULT ((0)) FOR [tq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_dwg_change]  DEFAULT ((0)) FOR [tq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_chk_design]  DEFAULT ((0)) FOR [tq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_chk_change]  DEFAULT ((0)) FOR [tq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_doe_design]  DEFAULT ((0)) FOR [tq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_doe_change]  DEFAULT ((0)) FOR [tq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_time]  DEFAULT (getdate()) FOR [tq_time]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_estab]  DEFAULT (N'编制') FOR [tq_estab]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_check]  DEFAULT (N'未复核') FOR [tq_check]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_audit]  DEFAULT (N'未审核') FOR [tq_audit]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_code]  DEFAULT ('TU00000000') FOR [tu_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tl_code]  DEFAULT ('TL001') FOR [tl_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_pre_design]  DEFAULT ((0)) FOR [tu_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_pre_change]  DEFAULT ((0)) FOR [tu_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_cur_design]  DEFAULT ((0)) FOR [tu_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_cur_change]  DEFAULT ((0)) FOR [tu_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_time]  DEFAULT (getdate()) FOR [tu_time]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_estab]  DEFAULT (N'编制') FOR [tu_estab]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_check]  DEFAULT (N'未复核') FOR [tu_check]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_audit]  DEFAULT (N'未审核') FOR [tu_audit]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_code]  DEFAULT ('YD00000000') FOR [yd_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yl_code]  DEFAULT ('YL001') FOR [yl_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_pre_design]  DEFAULT ((0)) FOR [yd_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_pre_change]  DEFAULT ((0)) FOR [yd_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_cur_design]  DEFAULT ((0)) FOR [yd_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_cur_change]  DEFAULT ((0)) FOR [yd_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_time]  DEFAULT (getdate()) FOR [yd_time]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_estab]  DEFAULT (N'编制') FOR [yd_estab]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_check]  DEFAULT (N'未复核') FOR [yd_check]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_audit]  DEFAULT (N'未审核') FOR [yd_audit]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_code]  DEFAULT ('YL000') FOR [yl_code]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_number]  DEFAULT ((1234567890)) FOR [yl_number]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_section]  DEFAULT ((1234567890)) FOR [yl_section]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_project]  DEFAULT (N'xxx项目') FOR [yl_project]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_unit]  DEFAULT (N'm3') FOR [yl_unit]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_qty_lst]  DEFAULT ((0)) FOR [yl_qty_lst]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_price_lst]  DEFAULT ((0)) FOR [yl_price_lst]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_qty_lbr]  DEFAULT ((0)) FOR [yl_qty_lbr]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_price_lbr_Labor]  DEFAULT ((0)) FOR [yl_price_lbr_Labor]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_price_lbr_good]  DEFAULT ((0)) FOR [yl_price_lbr_good]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_price_lbr_device]  DEFAULT ((0)) FOR [yl_price_lbr_device]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_date]  DEFAULT (getdate()) FOR [yl_time]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_estab]  DEFAULT (N'编制') FOR [yl_estab]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_check]  DEFAULT (N'未复核') FOR [yl_check]
GO
ALTER TABLE [dbo].[tb_yard_lst] ADD  CONSTRAINT [DF_tb_yard_lst_yl_audit]  DEFAULT (N'未审核') FOR [yl_audit]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_code]  DEFAULT ('YQ00000000') FOR [yq_code]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yl_code]  DEFAULT ('YL001') FOR [yl_code]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_dwg_design]  DEFAULT ((0)) FOR [yq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_dwg_change]  DEFAULT ((0)) FOR [yq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_chk_design]  DEFAULT ((0)) FOR [yq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_chk_change]  DEFAULT ((0)) FOR [yq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_doe_design]  DEFAULT ((0)) FOR [yq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_doe_change]  DEFAULT ((0)) FOR [yq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_date]  DEFAULT (getdate()) FOR [yq_time]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_estab]  DEFAULT (N'编制') FOR [yq_estab]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_check]  DEFAULT (N'未复核') FOR [yq_check]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_audit]  DEFAULT (N'未审核') FOR [yq_audit]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_code]  DEFAULT ('YU00000000') FOR [yu_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yl_code]  DEFAULT ('YL001') FOR [yl_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_pre_design]  DEFAULT ((0)) FOR [yu_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_pre_change]  DEFAULT ((0)) FOR [yu_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_cur_design]  DEFAULT ((0)) FOR [yu_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_cur_change]  DEFAULT ((0)) FOR [yu_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_time]  DEFAULT (getdate()) FOR [yu_time]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_estab]  DEFAULT (N'编制') FOR [yu_estab]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_check]  DEFAULT (N'未复核') FOR [yu_check]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_audit]  DEFAULT (N'未审核') FOR [yu_audit]
GO
ALTER TABLE [dbo].[tb_bridge_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_down_tb_bridge_lst] FOREIGN KEY([bl_code])
REFERENCES [dbo].[tb_bridge_lst] ([bl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_down] CHECK CONSTRAINT [FK_tb_bridge_down_tb_bridge_lst]
GO
ALTER TABLE [dbo].[tb_bridge_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_down] CHECK CONSTRAINT [FK_tb_bridge_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_bridge_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_down] CHECK CONSTRAINT [FK_tb_bridge_down_tb_points]
GO
ALTER TABLE [dbo].[tb_bridge_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_qty_tb_bridge_lst] FOREIGN KEY([bl_code])
REFERENCES [dbo].[tb_bridge_lst] ([bl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_qty] CHECK CONSTRAINT [FK_tb_bridge_qty_tb_bridge_lst]
GO
ALTER TABLE [dbo].[tb_bridge_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_qty] CHECK CONSTRAINT [FK_tb_bridge_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_bridge_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_up_tb_bridge_lst] FOREIGN KEY([bl_code])
REFERENCES [dbo].[tb_bridge_lst] ([bl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_up] CHECK CONSTRAINT [FK_tb_bridge_up_tb_bridge_lst]
GO
ALTER TABLE [dbo].[tb_bridge_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_up] CHECK CONSTRAINT [FK_tb_bridge_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_bridge_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_up] CHECK CONSTRAINT [FK_tb_bridge_up_tb_points]
GO
ALTER TABLE [dbo].[tb_check]  WITH CHECK ADD  CONSTRAINT [FK_tb_check_tb_barn] FOREIGN KEY([b_code])
REFERENCES [dbo].[tb_barn] ([b_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_check] CHECK CONSTRAINT [FK_tb_check_tb_barn]
GO
ALTER TABLE [dbo].[tb_check]  WITH CHECK ADD  CONSTRAINT [FK_tb_check_tb_employee] FOREIGN KEY([e_code])
REFERENCES [dbo].[tb_employee] ([e_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_check] CHECK CONSTRAINT [FK_tb_check_tb_employee]
GO
ALTER TABLE [dbo].[tb_check]  WITH CHECK ADD  CONSTRAINT [FK_tb_check_tb_goods] FOREIGN KEY([g_code])
REFERENCES [dbo].[tb_goods] ([g_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_check] CHECK CONSTRAINT [FK_tb_check_tb_goods]
GO
ALTER TABLE [dbo].[tb_finance]  WITH CHECK ADD  CONSTRAINT [FK_tb_finance_tb_funds] FOREIGN KEY([f_code])
REFERENCES [dbo].[tb_funds] ([f_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_finance] CHECK CONSTRAINT [FK_tb_finance_tb_funds]
GO
ALTER TABLE [dbo].[tb_finance]  WITH CHECK ADD  CONSTRAINT [FK_tb_finance_tb_member] FOREIGN KEY([m_code])
REFERENCES [dbo].[tb_member] ([m_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_finance] CHECK CONSTRAINT [FK_tb_finance_tb_member]
GO
ALTER TABLE [dbo].[tb_income]  WITH CHECK ADD  CONSTRAINT [FK_tb_income_tb_funds] FOREIGN KEY([f_code])
REFERENCES [dbo].[tb_funds] ([f_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_income] CHECK CONSTRAINT [FK_tb_income_tb_funds]
GO
ALTER TABLE [dbo].[tb_income]  WITH CHECK ADD  CONSTRAINT [FK_tb_income_tb_member] FOREIGN KEY([m_code])
REFERENCES [dbo].[tb_member] ([m_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_income] CHECK CONSTRAINT [FK_tb_income_tb_member]
GO
ALTER TABLE [dbo].[tb_instock]  WITH CHECK ADD  CONSTRAINT [FK_tb_instock_tb_barn] FOREIGN KEY([b_code])
REFERENCES [dbo].[tb_barn] ([b_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_instock] CHECK CONSTRAINT [FK_tb_instock_tb_barn]
GO
ALTER TABLE [dbo].[tb_instock]  WITH CHECK ADD  CONSTRAINT [FK_tb_instock_tb_employee] FOREIGN KEY([e_code])
REFERENCES [dbo].[tb_employee] ([e_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_instock] CHECK CONSTRAINT [FK_tb_instock_tb_employee]
GO
ALTER TABLE [dbo].[tb_instock]  WITH CHECK ADD  CONSTRAINT [FK_tb_instock_tb_goods] FOREIGN KEY([g_code])
REFERENCES [dbo].[tb_goods] ([g_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_instock] CHECK CONSTRAINT [FK_tb_instock_tb_goods]
GO
ALTER TABLE [dbo].[tb_instock]  WITH CHECK ADD  CONSTRAINT [FK_tb_instock_tb_pact] FOREIGN KEY([p_code])
REFERENCES [dbo].[tb_pact] ([p_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_instock] CHECK CONSTRAINT [FK_tb_instock_tb_pact]
GO
ALTER TABLE [dbo].[tb_instock]  WITH CHECK ADD  CONSTRAINT [FK_tb_instock_tb_units] FOREIGN KEY([u_code])
REFERENCES [dbo].[tb_units] ([u_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_instock] CHECK CONSTRAINT [FK_tb_instock_tb_units]
GO
ALTER TABLE [dbo].[tb_mixstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_mixstock_tb_barn] FOREIGN KEY([b_code])
REFERENCES [dbo].[tb_barn] ([b_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_mixstock] CHECK CONSTRAINT [FK_tb_mixstock_tb_barn]
GO
ALTER TABLE [dbo].[tb_mixstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_mixstock_tb_employee] FOREIGN KEY([e_code])
REFERENCES [dbo].[tb_employee] ([e_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_mixstock] CHECK CONSTRAINT [FK_tb_mixstock_tb_employee]
GO
ALTER TABLE [dbo].[tb_mixstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_mixstock_tb_goods] FOREIGN KEY([g_code])
REFERENCES [dbo].[tb_goods] ([g_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_mixstock] CHECK CONSTRAINT [FK_tb_mixstock_tb_goods]
GO
ALTER TABLE [dbo].[tb_mixstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_mixstock_tb_pact] FOREIGN KEY([p_code])
REFERENCES [dbo].[tb_pact] ([p_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_mixstock] CHECK CONSTRAINT [FK_tb_mixstock_tb_pact]
GO
ALTER TABLE [dbo].[tb_mixstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_mixstock_tb_units] FOREIGN KEY([u_code])
REFERENCES [dbo].[tb_units] ([u_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_mixstock] CHECK CONSTRAINT [FK_tb_mixstock_tb_units]
GO
ALTER TABLE [dbo].[tb_orbital_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_down] CHECK CONSTRAINT [FK_tb_orbital_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_orbital_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_down_tb_orbital_lst] FOREIGN KEY([ol_code])
REFERENCES [dbo].[tb_orbital_lst] ([ol_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_down] CHECK CONSTRAINT [FK_tb_orbital_down_tb_orbital_lst]
GO
ALTER TABLE [dbo].[tb_orbital_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_down] CHECK CONSTRAINT [FK_tb_orbital_down_tb_points]
GO
ALTER TABLE [dbo].[tb_orbital_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_qty_tb_orbital_lst] FOREIGN KEY([ol_code])
REFERENCES [dbo].[tb_orbital_lst] ([ol_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_qty] CHECK CONSTRAINT [FK_tb_orbital_qty_tb_orbital_lst]
GO
ALTER TABLE [dbo].[tb_orbital_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_qty] CHECK CONSTRAINT [FK_tb_orbital_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_orbital_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_up] CHECK CONSTRAINT [FK_tb_orbital_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_orbital_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_up_tb_orbital_lst] FOREIGN KEY([ol_code])
REFERENCES [dbo].[tb_orbital_lst] ([ol_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_up] CHECK CONSTRAINT [FK_tb_orbital_up_tb_orbital_lst]
GO
ALTER TABLE [dbo].[tb_orbital_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_up] CHECK CONSTRAINT [FK_tb_orbital_up_tb_points]
GO
ALTER TABLE [dbo].[tb_outlay]  WITH CHECK ADD  CONSTRAINT [FK_tb_outlay_tb_funds] FOREIGN KEY([f_code])
REFERENCES [dbo].[tb_funds] ([f_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_outlay] CHECK CONSTRAINT [FK_tb_outlay_tb_funds]
GO
ALTER TABLE [dbo].[tb_outlay]  WITH CHECK ADD  CONSTRAINT [FK_tb_outlay_tb_member] FOREIGN KEY([m_code])
REFERENCES [dbo].[tb_member] ([m_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_outlay] CHECK CONSTRAINT [FK_tb_outlay_tb_member]
GO
ALTER TABLE [dbo].[tb_outstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_outstock_tb_barn] FOREIGN KEY([b_code])
REFERENCES [dbo].[tb_barn] ([b_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_outstock] CHECK CONSTRAINT [FK_tb_outstock_tb_barn]
GO
ALTER TABLE [dbo].[tb_outstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_outstock_tb_employee] FOREIGN KEY([e_code])
REFERENCES [dbo].[tb_employee] ([e_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_outstock] CHECK CONSTRAINT [FK_tb_outstock_tb_employee]
GO
ALTER TABLE [dbo].[tb_outstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_outstock_tb_goods] FOREIGN KEY([g_code])
REFERENCES [dbo].[tb_goods] ([g_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_outstock] CHECK CONSTRAINT [FK_tb_outstock_tb_goods]
GO
ALTER TABLE [dbo].[tb_outstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_outstock_tb_pact] FOREIGN KEY([p_code])
REFERENCES [dbo].[tb_pact] ([p_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_outstock] CHECK CONSTRAINT [FK_tb_outstock_tb_pact]
GO
ALTER TABLE [dbo].[tb_outstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_outstock_tb_units] FOREIGN KEY([u_code])
REFERENCES [dbo].[tb_units] ([u_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_outstock] CHECK CONSTRAINT [FK_tb_outstock_tb_units]
GO
ALTER TABLE [dbo].[tb_retest_orbit]  WITH CHECK ADD  CONSTRAINT [FK_tb_retest_orbit_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retest_orbit] CHECK CONSTRAINT [FK_tb_retest_orbit_tb_points]
GO
ALTER TABLE [dbo].[tb_retest_orbit]  WITH CHECK ADD  CONSTRAINT [FK_tb_retest_orbit_tb_retest_plate] FOREIGN KEY([rp_code])
REFERENCES [dbo].[tb_retest_plate] ([rp_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retest_orbit] CHECK CONSTRAINT [FK_tb_retest_orbit_tb_retest_plate]
GO
ALTER TABLE [dbo].[tb_retest_rail]  WITH CHECK ADD  CONSTRAINT [FK_tb_retest_rail_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retest_rail] CHECK CONSTRAINT [FK_tb_retest_rail_tb_points]
GO
ALTER TABLE [dbo].[tb_retest_rail]  WITH CHECK ADD  CONSTRAINT [FK_tb_retest_rail_tb_retest_plate] FOREIGN KEY([rp_code])
REFERENCES [dbo].[tb_retest_plate] ([rp_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retest_rail] CHECK CONSTRAINT [FK_tb_retest_rail_tb_retest_plate]
GO
ALTER TABLE [dbo].[tb_retstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_retstock_tb_barn] FOREIGN KEY([b_code])
REFERENCES [dbo].[tb_barn] ([b_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retstock] CHECK CONSTRAINT [FK_tb_retstock_tb_barn]
GO
ALTER TABLE [dbo].[tb_retstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_retstock_tb_employee] FOREIGN KEY([e_code])
REFERENCES [dbo].[tb_employee] ([e_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retstock] CHECK CONSTRAINT [FK_tb_retstock_tb_employee]
GO
ALTER TABLE [dbo].[tb_retstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_retstock_tb_goods] FOREIGN KEY([g_code])
REFERENCES [dbo].[tb_goods] ([g_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retstock] CHECK CONSTRAINT [FK_tb_retstock_tb_goods]
GO
ALTER TABLE [dbo].[tb_retstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_retstock_tb_pact] FOREIGN KEY([p_code])
REFERENCES [dbo].[tb_pact] ([p_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retstock] CHECK CONSTRAINT [FK_tb_retstock_tb_pact]
GO
ALTER TABLE [dbo].[tb_retstock]  WITH CHECK ADD  CONSTRAINT [FK_tb_retstock_tb_units] FOREIGN KEY([u_code])
REFERENCES [dbo].[tb_units] ([u_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_retstock] CHECK CONSTRAINT [FK_tb_retstock_tb_units]
GO
ALTER TABLE [dbo].[tb_road_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_down] CHECK CONSTRAINT [FK_tb_road_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_road_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_down] CHECK CONSTRAINT [FK_tb_road_down_tb_points]
GO
ALTER TABLE [dbo].[tb_road_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_down_tb_road_lst] FOREIGN KEY([rl_code])
REFERENCES [dbo].[tb_road_lst] ([rl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_down] CHECK CONSTRAINT [FK_tb_road_down_tb_road_lst]
GO
ALTER TABLE [dbo].[tb_road_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_qty] CHECK CONSTRAINT [FK_tb_road_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_road_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_qty_tb_road_lst] FOREIGN KEY([rl_code])
REFERENCES [dbo].[tb_road_lst] ([rl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_qty] CHECK CONSTRAINT [FK_tb_road_qty_tb_road_lst]
GO
ALTER TABLE [dbo].[tb_road_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_up] CHECK CONSTRAINT [FK_tb_road_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_road_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_up] CHECK CONSTRAINT [FK_tb_road_up_tb_points]
GO
ALTER TABLE [dbo].[tb_road_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_up_tb_road_lst] FOREIGN KEY([rl_code])
REFERENCES [dbo].[tb_road_lst] ([rl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_up] CHECK CONSTRAINT [FK_tb_road_up_tb_road_lst]
GO
ALTER TABLE [dbo].[tb_stock]  WITH CHECK ADD  CONSTRAINT [FK_tb_stock_tb_barn] FOREIGN KEY([b_code])
REFERENCES [dbo].[tb_barn] ([b_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_stock] CHECK CONSTRAINT [FK_tb_stock_tb_barn]
GO
ALTER TABLE [dbo].[tb_stock]  WITH CHECK ADD  CONSTRAINT [FK_tb_stock_tb_goods] FOREIGN KEY([g_code])
REFERENCES [dbo].[tb_goods] ([g_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_stock] CHECK CONSTRAINT [FK_tb_stock_tb_goods]
GO
ALTER TABLE [dbo].[tb_temp_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_down] CHECK CONSTRAINT [FK_tb_temp_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_temp_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_down] CHECK CONSTRAINT [FK_tb_temp_down_tb_points]
GO
ALTER TABLE [dbo].[tb_temp_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_down_tb_temp_lst] FOREIGN KEY([pl_code])
REFERENCES [dbo].[tb_temp_lst] ([pl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_down] CHECK CONSTRAINT [FK_tb_temp_down_tb_temp_lst]
GO
ALTER TABLE [dbo].[tb_temp_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_qty] CHECK CONSTRAINT [FK_tb_temp_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_temp_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_qty_tb_temp_lst] FOREIGN KEY([pl_code])
REFERENCES [dbo].[tb_temp_lst] ([pl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_qty] CHECK CONSTRAINT [FK_tb_temp_qty_tb_temp_lst]
GO
ALTER TABLE [dbo].[tb_temp_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_up] CHECK CONSTRAINT [FK_tb_temp_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_temp_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_up] CHECK CONSTRAINT [FK_tb_temp_up_tb_points]
GO
ALTER TABLE [dbo].[tb_temp_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_up_tb_temp_lst] FOREIGN KEY([pl_code])
REFERENCES [dbo].[tb_temp_lst] ([pl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_up] CHECK CONSTRAINT [FK_tb_temp_up_tb_temp_lst]
GO
ALTER TABLE [dbo].[tb_tunnel_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_down] CHECK CONSTRAINT [FK_tb_tunnel_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_tunnel_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_down] CHECK CONSTRAINT [FK_tb_tunnel_down_tb_points]
GO
ALTER TABLE [dbo].[tb_tunnel_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_down_tb_tunnel_lst] FOREIGN KEY([tl_code])
REFERENCES [dbo].[tb_tunnel_lst] ([tl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_down] CHECK CONSTRAINT [FK_tb_tunnel_down_tb_tunnel_lst]
GO
ALTER TABLE [dbo].[tb_tunnel_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_qty] CHECK CONSTRAINT [FK_tb_tunnel_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_tunnel_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_qty_tb_tunnel_lst] FOREIGN KEY([tl_code])
REFERENCES [dbo].[tb_tunnel_lst] ([tl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_qty] CHECK CONSTRAINT [FK_tb_tunnel_qty_tb_tunnel_lst]
GO
ALTER TABLE [dbo].[tb_tunnel_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_up] CHECK CONSTRAINT [FK_tb_tunnel_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_tunnel_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_up] CHECK CONSTRAINT [FK_tb_tunnel_up_tb_points]
GO
ALTER TABLE [dbo].[tb_tunnel_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_up_tb_tunnel_lst] FOREIGN KEY([tl_code])
REFERENCES [dbo].[tb_tunnel_lst] ([tl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_up] CHECK CONSTRAINT [FK_tb_tunnel_up_tb_tunnel_lst]
GO
ALTER TABLE [dbo].[tb_yard_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_down] CHECK CONSTRAINT [FK_tb_yard_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_yard_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_down] CHECK CONSTRAINT [FK_tb_yard_down_tb_points]
GO
ALTER TABLE [dbo].[tb_yard_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_down_tb_yard_lst] FOREIGN KEY([yl_code])
REFERENCES [dbo].[tb_yard_lst] ([yl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_down] CHECK CONSTRAINT [FK_tb_yard_down_tb_yard_lst]
GO
ALTER TABLE [dbo].[tb_yard_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_qty] CHECK CONSTRAINT [FK_tb_yard_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_yard_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_qty_tb_yard_lst] FOREIGN KEY([yl_code])
REFERENCES [dbo].[tb_yard_lst] ([yl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_qty] CHECK CONSTRAINT [FK_tb_yard_qty_tb_yard_lst]
GO
ALTER TABLE [dbo].[tb_yard_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_up] CHECK CONSTRAINT [FK_tb_yard_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_yard_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_up] CHECK CONSTRAINT [FK_tb_yard_up_tb_points]
GO
ALTER TABLE [dbo].[tb_yard_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_up_tb_yard_lst] FOREIGN KEY([yl_code])
REFERENCES [dbo].[tb_yard_lst] ([yl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_up] CHECK CONSTRAINT [FK_tb_yard_up_tb_yard_lst]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[89] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_bridge_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_bridge_qty"
            Begin Extent = 
               Top = 0
               Left = 373
               Bottom = 139
               Right = 578
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 616
               Bottom = 145
               Right = 758
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_bridge_lst"
            Begin Extent = 
               Top = 6
               Left = 796
               Bottom = 145
               Right = 1003
            End
            DisplayFlags = 280
            TopColumn = 14
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 1041
               Bottom = 145
               Right = 1183
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 1221
               Bottom = 145
               Right = 1375
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column =' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' 10455
         Alias = 3060
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[5] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_bridge_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[91] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_bridge_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_bridge_qty"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 145
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_bridge_lst"
            Begin Extent = 
               Top = 6
               Left = 522
               Bottom = 145
               Right = 729
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 767
               Bottom = 145
               Right = 909
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 947
               Bottom = 145
               Right = 1089
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 10020
         Alias = 1320
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_bridge_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_bridge_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[8] 4[2] 2[60] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 15
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_budget_rep_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_budget_rep_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[17] 4[7] 2[45] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 2496
         Width = 5556
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_budget_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_budget_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[14] 4[14] 2[18] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tv_finance"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_finance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_finance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[87] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = -75
      End
      Begin Tables = 
         Begin Table = "tb_orbital_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_orbital_qty"
            Begin Extent = 
               Top = 0
               Left = 329
               Bottom = 139
               Right = 534
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_orbital_lst"
            Begin Extent = 
               Top = 6
               Left = 572
               Bottom = 145
               Right = 779
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 817
               Bottom = 145
               Right = 959
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 997
               Bottom = 145
               Right = 1139
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 1177
               Bottom = 145
               Right = 1331
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 10410
         Alias = 1320
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[6] 2[70] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_orbital_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[3] 4[88] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_orbital_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_orbital_qty"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 145
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_orbital_lst"
            Begin Extent = 
               Top = 6
               Left = 522
               Bottom = 145
               Right = 729
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 7
               Left = 767
               Bottom = 145
               Right = 912
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 950
               Bottom = 145
               Right = 1092
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 9975
         Alias = 1320
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[5] 2[70] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[5] 2[70] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_orbital_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_orbital_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[4] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1515
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[6] 2[51] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 735
         Width = 1020
         Width = 1185
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[32] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_barrier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_barrier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[39] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_bridge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_bridge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[36] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_groud'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_groud'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_measure'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_measure'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[6] 2[44] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_orbital'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_orbital'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[41] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_road'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_road'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[5] 2[37] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[6] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_tunnel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_problem_tunnel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[14] 4[13] 2[38] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -480
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_quantity"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 285
            End
            DisplayFlags = 280
            TopColumn = 10
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 15
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 1908
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[74] 2[9] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_retest_orbit"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 261
               Bottom = 145
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_retest_plate"
            Begin Extent = 
               Top = 6
               Left = 441
               Bottom = 145
               Right = 600
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1845
         Alias = 1635
         Table = 1500
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[14] 4[11] 2[60] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[14] 2[36] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 27
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1935
         Width = 2535
         Width = 2145
         Width = 2475
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1725
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit_cnt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit_cnt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 3[71] 2) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 19
         Width = 284
         Width = 1500
         Width = 1605
         Width = 1800
         Width = 1650
         Width = 1740
         Width = 1650
         Width = 1005
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3885
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_orbit_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[7] 2[34] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_retest_rail"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 145
               Right = 420
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_retest_plate"
            Begin Extent = 
               Top = 6
               Left = 458
               Bottom = 145
               Right = 617
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[55] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 16
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail_calc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail_calc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[10] 4[2] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 840
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail_wfp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail_wfp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[5] 2[32] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail_zw6'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_retest_rail_zw6'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[3] 4[90] 2[6] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_road_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "tb_road_qty"
            Begin Extent = 
               Top = 1
               Left = 340
               Bottom = 140
               Right = 542
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 580
               Bottom = 145
               Right = 722
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points_1"
            Begin Extent = 
               Top = 6
               Left = 760
               Bottom = 145
               Right = 902
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_road_lst"
            Begin Extent = 
               Top = 6
               Left = 940
               Bottom = 145
               Right = 1144
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 1182
               Bottom = 145
               Right = 1324
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 144
               Left = 277
               Bottom = 283
               Right = 431
            End
            ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 25
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 9900
         Alias = 1320
         Table = 1470
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[21] 2[29] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 25
         Width = 284
         Width = 1965
         Width = 1350
         Width = 2910
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3720
         Alias = 2505
         Table = 1905
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 3000
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[13] 4[14] 2[64] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_road_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 2445
         Table = 2910
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[88] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_road_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_road_qty"
            Begin Extent = 
               Top = 124
               Left = 416
               Bottom = 269
               Right = 618
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 9
               Left = 665
               Bottom = 148
               Right = 807
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_road_lst"
            Begin Extent = 
               Top = 208
               Left = 177
               Bottom = 347
               Right = 381
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 845
               Bottom = 145
               Right = 987
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 9390
         Alias = 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'320
         Table = 1260
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1785
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[16] 4[29] 2[38] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_road_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_road_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[23] 2[22] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_contract"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 379
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_sys_guidance"
            Begin Extent = 
               Top = 7
               Left = 269
               Bottom = 402
               Right = 468
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 14
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_quantity"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 292
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 16
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_steel_order"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 356
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_highway_partitem"
            Begin Extent = 
               Top = 7
               Left = 272
               Bottom = 329
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_sys_partitem"
            Begin Extent = 
               Top = 7
               Left = 488
               Bottom = 170
               Right = 657
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 14
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_steel_order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_steel_order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[21] 4[14] 2[34] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 21
         Width = 284
         Width = 1200
         Width = 2592
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3948
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_steel_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_steel_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[11] 2[40] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_highway_partitem"
            Begin Extent = 
               Top = 6
               Left = 248
               Bottom = 146
               Right = 396
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tv_sys_steel_qty_tmp"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 23
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_steel_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_sys_steel_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[90] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_temp_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_temp_qty"
            Begin Extent = 
               Top = 0
               Left = 460
               Bottom = 139
               Right = 665
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_temp_lst"
            Begin Extent = 
               Top = 6
               Left = 703
               Bottom = 145
               Right = 910
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 280
               Bottom = 145
               Right = 422
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 948
               Bottom = 145
               Right = 1090
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 1128
               Bottom = 145
               Right = 1282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 8160
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Alias = 1320
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[10] 4[8] 2[65] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[89] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_temp_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_temp_qty"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 145
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 522
               Bottom = 145
               Right = 664
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_temp_lst"
            Begin Extent = 
               Top = 6
               Left = 702
               Bottom = 145
               Right = 909
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 947
               Bottom = 145
               Right = 1089
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 13275
         Alias = 1320
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
      ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[5] 2[70] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_temp_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_temp_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[86] 2[4] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_tunnel_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_tunnel_qty"
            Begin Extent = 
               Top = 376
               Left = 145
               Bottom = 515
               Right = 346
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_tunnel_lst"
            Begin Extent = 
               Top = 21
               Left = 895
               Bottom = 160
               Right = 1098
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 334
               Left = 795
               Bottom = 473
               Right = 937
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 276
               Bottom = 145
               Right = 418
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 456
               Bottom = 145
               Right = 610
            End
            DisplayFlags = 280
            TopColumn = 5
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column =' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' 9570
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[9] 4[5] 2[68] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_tunnel_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[88] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_tunnel_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 237
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_tunnel_qty"
            Begin Extent = 
               Top = 6
               Left = 275
               Bottom = 145
               Right = 476
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 518
               Bottom = 145
               Right = 660
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_tunnel_lst"
            Begin Extent = 
               Top = 6
               Left = 698
               Bottom = 145
               Right = 901
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 939
               Bottom = 145
               Right = 1081
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 13335
         Alias' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[5] 2[70] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_tunnel_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_tunnel_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[89] 3[3] 2) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -206
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_yard_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_yard_qty"
            Begin Extent = 
               Top = 0
               Left = 322
               Bottom = 139
               Right = 525
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_yard_lst"
            Begin Extent = 
               Top = 116
               Left = 563
               Bottom = 255
               Right = 768
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 116
               Left = 806
               Bottom = 255
               Right = 948
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 116
               Left = 986
               Bottom = 255
               Right = 1128
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 212
               Left = 38
               Bottom = 351
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'9420
         Alias = 1320
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[8] 4[5] 2[68] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_down_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_yard_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_down_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[3] 4[85] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_yard_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_yard_qty"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 145
               Right = 480
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 518
               Bottom = 145
               Right = 660
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_yard_lst"
            Begin Extent = 
               Top = 6
               Left = 698
               Bottom = 145
               Right = 903
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 941
               Bottom = 145
               Right = 1083
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 9345
         Alias = 1320
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
       ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'  Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_up_all'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tp_yard_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tp_yard_up_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[12] 4[10] 2[60] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_barn"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_barn'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_barn'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[72] 2[9] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_bridge_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_bridge_lst"
            Begin Extent = 
               Top = 6
               Left = 280
               Bottom = 145
               Right = 487
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 525
               Bottom = 145
               Right = 667
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 705
               Bottom = 145
               Right = 847
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 885
               Bottom = 145
               Right = 1039
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
     ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'    Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_bridge_lst"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[4] 2[57] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_bridge_qty"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_bridge_lst"
            Begin Extent = 
               Top = 6
               Left = 281
               Bottom = 145
               Right = 488
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 526
               Bottom = 145
               Right = 668
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 930
         Width = 930
         Width = 3075
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[72] 2[9] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_bridge_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_bridge_lst"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 145
               Right = 486
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 524
               Bottom = 145
               Right = 666
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 704
               Bottom = 145
               Right = 846
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_bridge_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_budget"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 389
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_budget'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_budget'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[43] 4[18] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_budget_rep"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 343
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_budget_rep'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_budget_rep'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[12] 4[62] 2[8] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_check"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn"
            Begin Extent = 
               Top = 6
               Left = 248
               Bottom = 145
               Right = 406
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods"
            Begin Extent = 
               Top = 6
               Left = 444
               Bottom = 145
               Right = 617
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_employee"
            Begin Extent = 
               Top = 6
               Left = 655
               Bottom = 145
               Right = 818
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 960
         Table = 3045
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_check'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_check'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[29] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_contract"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 181
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_costlist"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_costlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_costlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[60] 2[17] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_employee"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 201
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2280
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_employee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_employee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[41] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_finance"
            Begin Extent = 
               Top = 6
               Left = 373
               Bottom = 146
               Right = 516
            End
            DisplayFlags = 280
            TopColumn = 9
         End
         Begin Table = "tb_funds"
            Begin Extent = 
               Top = 8
               Left = 125
               Bottom = 148
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "tb_member"
            Begin Extent = 
               Top = 6
               Left = 604
               Bottom = 146
               Right = 766
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3180
         Alias = 900
         Table = 1605
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_finance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_finance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[28] 4[34] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_funds"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 146
               Right = 398
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3225
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_funds'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_funds'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[11] 4[56] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_goods"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3300
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_goods'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_goods'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_guidance"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 447
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2664
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_guidance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_guidance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[40] 2[4] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_income"
            Begin Extent = 
               Top = 6
               Left = 219
               Bottom = 146
               Right = 361
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_funds"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 187
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_member"
            Begin Extent = 
               Top = 6
               Left = 399
               Bottom = 146
               Right = 561
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1560
         Table = 3060
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_income'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_income'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[78] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_instock"
            Begin Extent = 
               Top = 6
               Left = 234
               Bottom = 145
               Right = 392
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn"
            Begin Extent = 
               Top = 102
               Left = 38
               Bottom = 241
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods"
            Begin Extent = 
               Top = 102
               Left = 430
               Bottom = 241
               Right = 603
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn_1"
            Begin Extent = 
               Top = 102
               Left = 641
               Bottom = 241
               Right = 799
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_employee"
            Begin Extent = 
               Top = 102
               Left = 837
               Bottom = 241
               Right = 1000
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods_1"
            Begin Extent = 
               Top = 102
               Left = 1038
               Bottom = 241
               Right = 1211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_pact"
            Begin Extent = 
               Top = 102
               Left = 1249
               Bottom = 241
               Right = 1396
            End
         ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_instock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 150
               Left = 234
               Bottom = 289
               Right = 388
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 960
         Table = 1830
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_instock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_instock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 180
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_ledger'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_ledger'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[16] 4[46] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_member"
            Begin Extent = 
               Top = 6
               Left = 239
               Bottom = 146
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3495
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_member'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_member'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[3] 4[64] 3[9] 2) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_mixstock"
            Begin Extent = 
               Top = 6
               Left = 250
               Bottom = 145
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "tb_goods"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn"
            Begin Extent = 
               Top = 6
               Left = 448
               Bottom = 145
               Right = 606
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn_1"
            Begin Extent = 
               Top = 6
               Left = 644
               Bottom = 145
               Right = 802
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods_1"
            Begin Extent = 
               Top = 6
               Left = 840
               Bottom = 145
               Right = 1013
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_employee"
            Begin Extent = 
               Top = 6
               Left = 1051
               Bottom = 145
               Right = 1214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_pact"
            Begin Extent = 
               Top = 6
               Left = 1252
               Bottom = 145
               Right = 1399
            End
            DisplayFla' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_mixstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'gs = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 150
               Left = 38
               Bottom = 289
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1935
         Alias = 2025
         Table = 2400
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_mixstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_mixstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[58] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_orbital_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_orbital_lst"
            Begin Extent = 
               Top = 6
               Left = 280
               Bottom = 145
               Right = 487
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 525
               Bottom = 145
               Right = 667
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 705
               Bottom = 145
               Right = 847
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 885
               Bottom = 145
               Right = 1039
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_orbital_lst"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_orbital_qty"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_orbital_lst"
            Begin Extent = 
               Top = 6
               Left = 281
               Bottom = 145
               Right = 488
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 526
               Bottom = 145
               Right = 668
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[3] 4[64] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_orbital_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_orbital_lst"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 145
               Right = 486
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 524
               Bottom = 145
               Right = 666
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 704
               Bottom = 145
               Right = 846
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_orbital_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[16] 4[47] 2[10] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_outlay"
            Begin Extent = 
               Top = 6
               Left = 219
               Bottom = 146
               Right = 366
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_funds"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 187
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "tb_member"
            Begin Extent = 
               Top = 6
               Left = 404
               Bottom = 146
               Right = 566
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1680
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_outlay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_outlay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[75] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_outstock"
            Begin Extent = 
               Top = 6
               Left = 234
               Bottom = 145
               Right = 392
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods"
            Begin Extent = 
               Top = 6
               Left = 430
               Bottom = 145
               Right = 603
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn_1"
            Begin Extent = 
               Top = 6
               Left = 641
               Bottom = 145
               Right = 799
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_employee"
            Begin Extent = 
               Top = 6
               Left = 837
               Bottom = 145
               Right = 1000
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods_1"
            Begin Extent = 
               Top = 6
               Left = 1038
               Bottom = 145
               Right = 1211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_pact"
            Begin Extent = 
               Top = 6
               Left = 1249
               Bottom = 145
               Right = 1396
            End
            DisplayFla' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_outstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'gs = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 150
               Left = 38
               Bottom = 289
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 960
         Table = 1350
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_outstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_outstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[11] 4[58] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_pact"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 180
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2400
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_pact'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_pact'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[8] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_partitem"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 146
               Right = 404
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 3480
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_partitem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_partitem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[14] 4[54] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 180
            End
            DisplayFlags = 280
            TopColumn = 7
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_points'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_points'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[23] 2[13] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -192
         Left = -730
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2775
         Alias = 1590
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[5] 2[38] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_barrier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_barrier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[4] 2[30] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_bridge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_bridge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[8] 2[71] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1245
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_groud'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_groud'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[5] 2[72] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_measure'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_measure'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[72] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_orbital'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_orbital'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[5] 2[80] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_road'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_road'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[5] 2[72] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_problem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_tunnel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_problem_tunnel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[9] 4[7] 2[5] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_quantity"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 413
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_contract"
            Begin Extent = 
               Top = 7
               Left = 331
               Bottom = 170
               Right = 497
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_budget"
            Begin Extent = 
               Top = 7
               Left = 545
               Bottom = 170
               Right = 717
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3240
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_quantity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_quantity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_quantity_sum"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 428
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_budget"
            Begin Extent = 
               Top = 7
               Left = 292
               Bottom = 170
               Right = 464
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_contract"
            Begin Extent = 
               Top = 7
               Left = 512
               Bottom = 170
               Right = 678
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[11] 4[57] 2[18] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_retest_orbit"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 24
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1845
         Table = 1920
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retest_orbit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retest_orbit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[12] 4[61] 2[9] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_retest_plate"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 197
            End
            DisplayFlags = 280
            TopColumn = 10
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2085
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retest_plate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retest_plate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[14] 4[35] 2[44] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_retest_rail"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2820
         Alias = 2280
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retest_rail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retest_rail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[66] 2[25] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_retstock"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 139
               Right = 161
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods"
            Begin Extent = 
               Top = 6
               Left = 199
               Bottom = 145
               Right = 372
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn"
            Begin Extent = 
               Top = 6
               Left = 410
               Bottom = 145
               Right = 568
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn_1"
            Begin Extent = 
               Top = 6
               Left = 606
               Bottom = 145
               Right = 764
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_employee"
            Begin Extent = 
               Top = 6
               Left = 802
               Bottom = 145
               Right = 965
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods_1"
            Begin Extent = 
               Top = 6
               Left = 1003
               Bottom = 145
               Right = 1176
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_pact"
            Begin Extent = 
               Top = 6
               Left = 1214
               Bottom = 145
               Right = 1361
            End
            DisplayFlag' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N's = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 144
               Left = 38
               Bottom = 283
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2670
         Table = 2910
         Output = 3600
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_retstock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[3] 4[62] 2[21] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_road_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "tb_road_lst"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 145
               Right = 481
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 519
               Bottom = 145
               Right = 661
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 699
               Bottom = 145
               Right = 841
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 879
               Bottom = 145
               Right = 1033
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 1320
         Table = 1470
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
       ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'  Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[19] 4[55] 2[8] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_road_lst"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3045
         Alias = 2700
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[64] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_road_qty"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_road_lst"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 145
               Right = 482
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 175
               Left = 284
               Bottom = 314
               Right = 483
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 14
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 3075
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1860
         Table = 2805
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[3] 4[65] 2[10] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_road_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_road_lst"
            Begin Extent = 
               Top = 6
               Left = 276
               Bottom = 386
               Right = 480
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 518
               Bottom = 145
               Right = 660
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 698
               Bottom = 145
               Right = 840
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 17
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 4845
         Alias = 2610
         Table = 1215
         Output = 720
         Append = 1400
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_road_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[67] 2[18] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_stock"
            Begin Extent = 
               Top = 1
               Left = 345
               Bottom = 107
               Right = 507
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_barn"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_goods"
            Begin Extent = 
               Top = 4
               Left = 677
               Bottom = 143
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1620
         Alias = 2445
         Table = 2925
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_stock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_stock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_contract"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_guidance"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 16
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_guidance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_guidance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_partitem"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_partitem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_partitem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_quantity"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_sys_contract"
            Begin Extent = 
               Top = 6
               Left = 314
               Bottom = 146
               Right = 463
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_labour"
            Begin Extent = 
               Top = 7
               Left = 511
               Bottom = 170
               Right = 684
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 17
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_quantity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_quantity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[18] 4[41] 2[10] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_quantity_sum"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_sys_contract"
            Begin Extent = 
               Top = 7
               Left = 324
               Bottom = 170
               Right = 497
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_labour"
            Begin Extent = 
               Top = 7
               Left = 545
               Bottom = 170
               Right = 718
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 24
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy =' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_quantity_sum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_steel_library"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 396
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 8
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_library'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_library'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_steel_order"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 4
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[37] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_steel_qty"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 418
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3660
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[38] 4[4] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sys_steel_qty"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 398
               Right = 237
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "tb_sys_partitem"
            Begin Extent = 
               Top = 6
               Left = 248
               Bottom = 146
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tb_highway_partitem"
            Begin Extent = 
               Top = 6
               Left = 433
               Bottom = 146
               Right = 581
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 23
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2145
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         F' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_qty_tmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'ilter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_qty_tmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sys_steel_qty_tmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_sysprogram_demonstrate"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 271
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sysprogram_demonstrate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_sysprogram_demonstrate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[69] 2[11] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_temp_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_temp_lst"
            Begin Extent = 
               Top = 6
               Left = 280
               Bottom = 145
               Right = 487
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 525
               Bottom = 145
               Right = 667
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 705
               Bottom = 145
               Right = 847
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 885
               Bottom = 145
               Right = 1039
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_temp_lst"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_temp_qty"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_temp_lst"
            Begin Extent = 
               Top = 6
               Left = 281
               Bottom = 145
               Right = 488
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 526
               Bottom = 145
               Right = 668
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[9] 4[52] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_temp_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_temp_lst"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 145
               Right = 486
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 524
               Bottom = 145
               Right = 666
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 704
               Bottom = 145
               Right = 846
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_temp_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[58] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_tunnel_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_tunnel_lst"
            Begin Extent = 
               Top = 6
               Left = 276
               Bottom = 145
               Right = 479
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 517
               Bottom = 145
               Right = 659
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 697
               Bottom = 145
               Right = 839
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 877
               Bottom = 145
               Right = 1031
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
    ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'     Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_tunnel_lst"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[0] 2[21] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_tunnel_qty"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_tunnel_lst"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 145
               Right = 480
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 518
               Bottom = 145
               Right = 660
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[58] 2[21] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_tunnel_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 237
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_tunnel_lst"
            Begin Extent = 
               Top = 13
               Left = 275
               Bottom = 145
               Right = 478
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 516
               Bottom = 145
               Right = 658
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 696
               Bottom = 145
               Right = 838
            End
            DisplayFlags = 280
            TopColumn = 3
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_tunnel_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[65] 2[3] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 186
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3765
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_units'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_units'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[35] 4[32] 2[17] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_users"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 184
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2700
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_users'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_users'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[58] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_yard_down"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_yard_lst"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 145
               Right = 483
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 521
               Bottom = 145
               Right = 663
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 701
               Bottom = 145
               Right = 843
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_units"
            Begin Extent = 
               Top = 6
               Left = 881
               Bottom = 145
               Right = 1035
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_down'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_yard_lst"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_lst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_yard_qty"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_yard_lst"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 145
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 522
               Bottom = 145
               Right = 664
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[58] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_yard_up"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_yard_lst"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 145
               Right = 487
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_points"
            Begin Extent = 
               Top = 6
               Left = 525
               Bottom = 145
               Right = 667
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_ledger"
            Begin Extent = 
               Top = 6
               Left = 705
               Bottom = 145
               Right = 847
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7575
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'tv_yard_up'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "A"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 7
               Left = 278
               Bottom = 170
               Right = 466
            End
            DisplayFlags = 280
            TopColumn = 6
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 14
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1356
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_budget'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_budget'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 126
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_contract"
            Begin Extent = 
               Top = 7
               Left = 499
               Bottom = 394
               Right = 684
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[34] 2[34] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 126
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_guidance"
            Begin Extent = 
               Top = 7
               Left = 257
               Bottom = 170
               Right = 419
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 17
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 2856
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_guidance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_guidance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 126
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tb_sys_contract"
            Begin Extent = 
               Top = 7
               Left = 257
               Bottom = 170
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_sys_contract'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vT_sys_contract'
GO
USE [master]
GO
ALTER DATABASE [ProjectManage] SET  READ_WRITE 
GO
