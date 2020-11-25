/*利用SQL语言,实现数据库的备份/恢复的功能
 
体现了SQL Server中的四个知识点：
1． 获取SQL Server服务器上的默认目录
2． 备份SQL语句的使用
3． 恢复SQL语句的使用，同时考虑了强制恢复时关闭其他用户进程的处理
4． 作业创建SQL语句的使用
*/
 

/*1.--得到数据库的文件目录

@dbname 指定要取得目录的数据库名
如果指定的数据不存在,返回安装SQL时设置的默认数据目录
如果指定NULL,则返回默认的SQL备份目录名
----*/

/*--调用示例
select 数据库文件目录=dbo.f_getdbpath('tempdb')
,[默认SQL SERVER数据目录]=dbo.f_getdbpath('')
,[默认SQL SERVER备份目录]=dbo.f_getdbpath(null)
--*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_getdbpath]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[f_getdbpath]
GO

create function f_getdbpath(@dbname sysname)
returns nvarchar(260)
as 
begin
declare @re nvarchar(260)
if @dbname is null or db_id(@dbname) is null
select @re=rtrim(reverse(filename)) from master..sysdatabases where name='master'
else
select @re=rtrim(reverse(filename)) from master..sysdatabases where name=@dbname

if @dbname is null
set @re=reverse(substring(@re,charindex('/',@re)+5,260))+'BACKUP'
else
set @re=reverse(substring(@re,charindex('/',@re),260))
return(@re)
end
go

 

/*2.--备份数据库--*/

/*--调用示例

--备份当前数据库
exec p_backupdb @bkpath='c:/',@bkfname='db_/DATE/_db.bak'

--差异备份当前数据库
exec p_backupdb @bkpath='c:/',@bkfname='db_/DATE/_df.bak',@bktype='DF'

--备份当前数据库日志
exec p_backupdb @bkpath='c:/',@bkfname='db_/DATE/_log.bak',@bktype='LOG'

--*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_backupdb]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_backupdb]
GO

create proc p_backupdb
@dbname sysname='', --要备份的数据库名称,不指定则备份当前数据库
@bkpath nvarchar(260)='', --备份文件的存放目录,不指定则使用SQL默认的备份目录
@bkfname nvarchar(260)='', --备份文件名,文件名中可以用/DBNAME/代表数据库名,/DATE/代表日期,/TIME/代表时间
@bktype nvarchar(10)='DB', --备份类型:'DB'备份数据库,'DF' 差异备份,'LOG' 日志备份
@appendfile bit=1 --追加/覆盖备份文件
as
declare @sql varchar(8000)
if isnull(@dbname,'')='' set @dbname=db_name()
if isnull(@bkpath,'')='' set @bkpath=dbo.f_getdbpath(null)
if isnull(@bkfname,'')='' set @bkfname='/DBNAME/_/DATE/_/TIME/.BAK'
set @bkfname=replace(replace(replace(@bkfname,'/DBNAME/',@dbname)
,'/DATE/',convert(varchar,getdate(),112))
,'/TIME/',replace(convert(varchar,getdate(),108),':',''))
set @sql='backup '+case @bktype when 'LOG' then 'log ' else 'database ' end +@dbname
+' to disk='''+@bkpath+@bkfname
+''' with '+case @bktype when 'DF' then 'DIFFERENTIAL,' else '' end
+case @appendfile when 1 then 'NOINIT' else 'INIT' end
print @sql
exec(@sql)
go

 

/*3.--恢复数据库--*/

/*--调用示例
--完整恢复数据库
exec p_RestoreDb @bkfile='c:/db_20031015_db.bak',@dbname='db'

--差异备份恢复
exec p_RestoreDb @bkfile='c:/db_20031015_db.bak',@dbname='db',@retype='DBNOR'
exec p_backupdb @bkfile='c:/db_20031015_df.bak',@dbname='db',@retype='DF'

--日志备份恢复
exec p_RestoreDb @bkfile='c:/db_20031015_db.bak',@dbname='db',@retype='DBNOR'
exec p_backupdb @bkfile='c:/db_20031015_log.bak',@dbname='db',@retype='LOG'

--*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_RestoreDb]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_RestoreDb]
GO

create proc p_RestoreDb
@bkfile nvarchar(1000), --定义要恢复的备份文件名
@dbname sysname='', --定义恢复后的数据库名,默认为备份的文件名
@dbpath nvarchar(260)='', --恢复后的数据库存放目录,不指定则为SQL的默认数据目录
@retype nvarchar(10)='DB', --恢复类型:'DB'完事恢复数据库,'DBNOR' 为差异恢复,日志恢复进行完整恢复,'DF' 差异备份的恢复,'LOG' 日志恢复
@filenumber int=1, --恢复的文件号
@overexist bit=1, --是否覆盖已经存在的数据库,仅@retype为
@killuser bit=1 --是否关闭用户使用进程,仅@overexist=1时有效
as
declare @sql varchar(8000)

--得到恢复后的数据库名
if isnull(@dbname,'')=''
select @sql=reverse(@bkfile)
,@sql=case when charindex('.',@sql)=0 then @sql
else substring(@sql,charindex('.',@sql)+1,1000) end
,@sql=case when charindex('/',@sql)=0 then @sql
else left(@sql,charindex('/',@sql)-1) end
,@dbname=reverse(@sql)

--得到恢复后的数据库存放目录
if isnull(@dbpath,'')='' set @dbpath=dbo.f_getdbpath('')

--生成数据库恢复语句
set @sql='restore '+case @retype when 'LOG' then 'log ' else 'database ' end+@dbname
+' from disk='''+@bkfile+''''
+' with file='+cast(@filenumber as varchar)
+case when @overexist=1 and @retype in('DB','DBNOR') then ',replace' else '' end
+case @retype when 'DBNOR' then ',NORECOVERY' else ',RECOVERY' end
print @sql
--添加移动逻辑文件的处理
if @retype='DB' or @retype='DBNOR'
begin
--从备份文件中获取逻辑文件名
declare @lfn nvarchar(128),@tp char(1),@i int

--创建临时表,保存获取的信息
create table #tb(ln nvarchar(128),pn nvarchar(260),tp char(1),fgn nvarchar(128),sz numeric(20,0),Msz numeric(20,0),
FileId bigint,CreateLSN numeric(25,0),DropLSN numeric(25,0),UniqueID uniqueidentifier,
ReadOnlyLSN numeric(25,0),ReadWriteLSN numeric(25,0),BackupSizeInBytes bigint,
SourceBlockSize int,FileGroupID int,LogGroupGUID uniqueidentifier,DifferentialBaseLSN numeric(25,0),
DifferentialBaseGUID uniqueidentifier,IsReadOnly bit,IsPresent bit)

--从备份文件中获取信息
insert into #tb exec('restore filelistonly from disk='''+@bkfile+'''')
declare #f cursor for select ln,tp from #tb
open #f
fetch next from #f into @lfn,@tp
set @i=0
while @@fetch_status=0
begin
select @sql=@sql+',move '''+@lfn+''' to '''+@dbpath+@dbname+cast(@i as varchar)
+case @tp when 'D' then '.mdf''' else '.ldf''' end
,@i=@i+1
fetch next from #f into @lfn,@tp
end
close #f
deallocate #f
end

--关闭用户进程处理
if @overexist=1 and @killuser=1
begin
declare @spid varchar(20)
declare #spid cursor for
select spid=cast(spid as varchar(20)) from master..sysprocesses where dbid=db_id(@dbname)
open #spid
fetch next from #spid into @spid
while @@fetch_status=0
begin 
exec('kill '+@spid)
fetch next from #spid into @spid
end 
close #spid
deallocate #spid
end

--恢复数据库
exec(@sql)

go

/*4.--创建作业--*/

/*--调用示例

--每月执行的作业
exec p_createjob @jobname='mm',@sql='select * from syscolumns',@freqtype='month'

--每周执行的作业
exec p_createjob @jobname='ww',@sql='select * from syscolumns',@freqtype='week'

--每日执行的作业
exec p_createjob @jobname='a',@sql='select * from syscolumns'

--每日执行的作业,每天隔4小时重复的作业
exec p_createjob @jobname='b',@sql='select * from syscolumns',@fsinterval=4

--*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_createjob]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_createjob]
GO

create proc p_createjob
@jobname varchar(100), --作业名称
@sql varchar(8000), --要执行的命令
@dbname sysname='', --默认为当前的数据库名
@freqtype varchar(6)='day', --时间周期,month 月,week 周,day 日
@fsinterval int=1, --相对于每日的重复次数
@time int=170000 --开始执行时间,对于重复执行的作业,将从0点到23:59分
as
if isnull(@dbname,'')='' set @dbname=db_name()

--创建作业
exec msdb..sp_add_job @job_name=@jobname

--创建作业步骤
exec msdb..sp_add_jobstep @job_name=@jobname,
@step_name = '数据处理',
@subsystem = 'TSQL',
@database_name=@dbname,
@command = @sql,
@retry_attempts = 5, --重试次数
@retry_interval = 5 --重试间隔

--创建调度
declare @ftype int,@fstype int,@ffactor int
select @ftype=case @freqtype when 'day' then 4
when 'week' then 8
when 'month' then 16 end
,@fstype=case @fsinterval when 1 then 0 else 8 end
if @fsinterval<>1 set @time=0
set @ffactor=case @freqtype when 'day' then 0 else 1 end

EXEC msdb..sp_add_jobschedule @job_name=@jobname, 
@name = '时间安排',
@freq_type=@ftype , --每天,8 每周,16 每月
@freq_interval=1, --重复执行次数
@freq_subday_type=@fstype, --是否重复执行
@freq_subday_interval=@fsinterval, --重复周期
@freq_recurrence_factor=@ffactor,
@active_start_time=@time --下午17:00:00分执行

go


/*--应用案例--备份方案:
完整备份（每个星期天一次）+差异备份（每天备份一次）+日志备份（每2小时备份一次）

调用上面的存储过程来实现
--*/

declare @sql varchar(8000)
--完整备份（每个星期天一次）
set @sql='exec p_backupdb @dbname=''要备份的数据库名'''
exec p_createjob @jobname='每周备份',@sql,@freqtype='week'

--差异备份（每天备份一次）
set @sql='exec p_backupdb @dbname=''要备份的数据库名'',@bktype='DF''
exec p_createjob @jobname='每天差异备份',@sql,@freqtype='day'

--日志备份（每2小时备份一次）
set @sql='exec p_backupdb @dbname=''要备份的数据库名'',@bktype='LOG''
exec p_createjob @jobname='每2小时日志备份',@sql,@freqtype='day',@fsinterval=2

*--应用案例2

生产数据核心库：PRODUCE

备份方案如下：
1.设置三个作业,分别对PRODUCE库进行每日备份,每周备份,每月备份
2.新建三个新库,分别命名为:每日备份,每周备份,每月备份
3.建立三个作业，分别把三个备份库还原到以上的三个新库。

目的:当用户在produce库中有任何的数据丢失时,均可以从上面的三个备份库中导入相应的TABLE数据。
--*/

declare @sql varchar(8000)

--1.建立每月备份和生成月备份数据库的作业,每月每1天下午16:40分进行:
set @sql='
declare @path nvarchar(260),@fname nvarchar(100)
set @fname=''PRODUCE_''+convert(varchar(10),getdate(),112)+''_m.bak''
set @path=dbo.f_getdbpath(null)+@fname

--备份
exec p_backupdb @dbname=''PRODUCE'',@bkfname=@fname

--根据备份生成每月新库
exec p_RestoreDb @bkfile=@path,@dbname=''PRODUCE_月''

--为周数据库恢复准备基础数据库
exec p_RestoreDb @bkfile=@path,@dbname=''PRODUCE_周'',@retype=''DBNOR''

--为日数据库恢复准备基础数据库
exec p_RestoreDb @bkfile=@path,@dbname=''PRODUCE_日'',@retype=''DBNOR''
'
exec p_createjob @jobname='每月备份',@sql,@freqtype='month',@time=164000

--2.建立每周差异备份和生成周备份数据库的作业,每周日下午17:00分进行:
set @sql='
declare @path nvarchar(260),@fname nvarchar(100)
set @fname=''PRODUCE_''+convert(varchar(10),getdate(),112)+''_w.bak''
set @path=dbo.f_getdbpath(null)+@fname

--差异备份
exec p_backupdb @dbname=''PRODUCE'',@bkfname=@fname,@bktype=''DF''

--差异恢复周数据库
exec p_backupdb @bkfile=@path,@dbname=''PRODUCE_周'',@retype=''DF''
'
exec p_createjob @jobname='每周差异备份',@sql,@freqtype='week',@time=170000

--3.建立每日日志备份和生成日备份数据库的作业,每周日下午17:15分进行:
set @sql='
declare @path nvarchar(260),@fname nvarchar(100)
set @fname=''PRODUCE_''+convert(varchar(10),getdate(),112)+''_l.bak''
set @path=dbo.f_getdbpath(null)+@fname

--日志备份
exec p_backupdb @dbname=''PRODUCE'',@bkfname=@fname,@bktype=''LOG''

--日志恢复日数据库
exec p_backupdb @bkfile=@path,@dbname=''PRODUCE_日'',@retype=''LOG''
'
exec p_createjob @jobname='每周差异备份',@sql,@freqtype='day',@time=171500