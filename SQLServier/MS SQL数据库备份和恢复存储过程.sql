--MS SQL数据库备份和恢复存储过程
/*备份数据库*/
if exists(select name from sys.procedures where name = 'sp_Data_Backup')
drop procedure sp_Data_Backup

go
create procedure sp_Data_Backup
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


go
if exists(select * from sysobjects where id = object_id('fn_GetFilePath') and xtype in ('fn'))
drop function fn_GetFilePath
go
/*创建函数,得到文件得路径*/
create function fn_GetFilePath(@filename nvarchar(255))
returns nvarchar(255)
as
begin
  declare @file_path nvarchar(255)
  declare @filename_reverse nvarchar(255)
  set @filename_reverse=reverse(@filename)
  set @file_path=substring(@filename,1,len(@filename)+1-charindex('\',@filename_reverse))
  return @file_path
end

go
if exists(select name from sys.procedures where name = 'sp_Data_Restore')
drop procedure sp_Data_Restore
go
/*恢复数据库*/
create procedure sp_Data_Restore    
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
  /*@flag_file=1时新的数据库文件还是存放在原来路径，否则存放路径和master数据库路径一样*/
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


go
/*运行*/
/*备份数据库test*/
declare @fl varchar(20)
declare @rl bit
--execute sp_Data_Backup 'ProjectManage','D:\ProjectManage.bak',@rl out,@fl out
print @fl

/*恢复数据库,输入的参数错误*/
declare @f2 varchar(10)
declare @r2 bit
exec sp_Data_Restore 'ProjectManage','d:\ProjectManage.bak',@r2 out, @f2 out
print @f2

/*恢复数据库,即创建数据库test的复本test_db*/
declare @f3 varchar(20)
declare @r3 bit
--exec sp_Data_Restore 'ProjectManage_db','d:\ProjectManage.bak',@r3 out,@f3 out
--print @f3




--清空数据库
if( object_id('sp_Data_Clear') is not null )      
drop procedure sp_Data_Clear
go

create procedure sp_Data_Clear
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


go 
--执行
exec sp_Data_Clear

go
backup log ProjectManage to disk='d:\log.bak' with norecovery,no_truncate -- 截断日志
alter database ProjectManage set recovery simple ----修改数据库恢复模式 简单模式
dbcc shrinkdatabase('ProjectManage')  --收缩指定数据库中的数据文件大小
dbcc updateusage('ProjectManage')  --报告和更正 sysindexes 表的不正确内容
alter database ProjectManage set recovery full ----修改数据库恢复模式 完全模式

--查看表空间
select 
object_name(id) as 表名, 
(rtrim(8*reserved/1024) + 'MB') as 总量, 
(rtrim(8*dpages/1024) + 'MB') as 已使用, 
(rtrim(8*(reserved-dpages)/1024) + 'MB') as 未使用, 
(rtrim(8*dpages/1024-rows/1024*minlen/1024) + 'MB' ) as 空隙
from sysindexes
where indid=1
order by reserved desc