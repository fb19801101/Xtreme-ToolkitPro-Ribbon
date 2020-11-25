--MS SQL���ݿⱸ�ݺͻָ��洢����
/*�������ݿ�*/
if exists(select name from sys.procedures where name = 'sp_Data_Backup')
drop procedure sp_Data_Backup

go
create procedure sp_Data_Backup
@backup_db_name nvarchar(128), --���ݿ�����
@filename nvarchar(255),       --·��+�ļ�����
@ret bit out,                  --ִ�б�־
@flag varchar(20) out          --ִ�б�־
as
declare @sql nvarchar(4000),@parm nvarchar(1000)
if not exists(select * from master..sysdatabases where name=@backup_db_name)
begin
  set @flag='db not exist'  --���ݿⲻ����
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
    set @flag='file type error'  --����@filename�����ʽ����
	set @ret = 0
    return
  end
end


go
if exists(select * from sysobjects where id = object_id('fn_GetFilePath') and xtype in ('fn'))
drop function fn_GetFilePath
go
/*��������,�õ��ļ���·��*/
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
/*�ָ����ݿ�*/
create procedure sp_Data_Restore    
@restore_db_name nvarchar(128),  --Ҫ�ָ�����������
@filename nvarchar(255),         --�����ļ���ŵ�·��+�����ļ�����
@ret bit out,                    --ִ�б�־
@flag varchar(20) out            --ִ�б�־
as
/*����ϵͳ�洢����xp_cmdshell���н��*/
declare @proc_result tinyint 
declare @loop_time smallint  --ѭ������
/*@tem���ids�������*/
declare @max_ids smallint    
declare @file_bak_path nvarchar(260)  --ԭ���ݿ���·��
declare @flag_file bit   --�ļ���ű�־
/*���ݿ�master�ļ�·��*/
declare @master_path nvarchar(260)  
declare @sql nvarchar(4000),@parm nvarchar(1000)
declare @sql_sub nvarchar(4000)
declare @sql_cmd nvarchar(100) 
declare @sql_kill nvarchar(100) 

/*�жϲ���@filename�ļ���ʽ�Ϸ��ԣ��Է�ֹ�û���������d: ���� c:a �ȷǷ��ļ���
����@filename���������''''���Ҳ���''''��β*/
if right(@filename,1)<>'\' and charindex('\',@filename)<>0
begin 
  set @sql_cmd='dir '+@filename
  exec @proc_result = master..xp_cmdshell @sql_cmd,no_output

  /*ϵͳ�洢����xp_cmdshell���ش���ֵ:0(�ɹ�����1��ʧ�ܣ�*/
  if (@proc_result<>0)  
  begin
    /*�����ļ�������*/
    set @flag='not exist'   
    /*�˳�����*/
	set @ret = 0
    return
  end

  /*������ʱ��,�����ɱ��ݼ��ڰ��������ݿ����־�ļ��б���ɵĽ����*/
  create table #temp_backup(
	LogicalName nvarchar(128) null,         --�ļ��߼�����
    PhysicalName nvarchar(260) null,        --�ļ����������ƻ����ϵͳ����
    Type char(1) null,                      --�ļ������ͣ����а�����L = MicrosoftSQL Server��־�ļ� ;D = SQL Server data file ;F = ȫ��Ŀ¼ ;S = FileStream�� FileTable�����ڴ��� OLTP����
    FileGroupName nvarchar(128) null,       --�����ļ����ļ��������
    Size bigint null ,                      --��ǰ��С�����ֽ�Ϊ��λ��
    MaxSize Bigint null,                    --���������С�����ֽ�Ϊ��λ��
    FileId bigint,						    --�ļ���ʶ���������ݿ���Ψһ
    CreateLSN numeric(25,0),			    --�����ļ�ʱ����־���к�
    DropLSN numeric(25,0) NULL,			    --���ļ���ɾ������־���кš� ����ļ���δɾ������ֵΪ NULL
    UniqueID uniqueidentifier,			    --�ļ���ȫ��Ψһ��ʶ��
    ReadOnlyLSN numeric(25,0) NULL,		    --�������ļ����ļ���Ӷ�д���Ը���Ϊֻ�����ԣ����¸��ģ�ʱ����־���к�										    
    ReadWriteLSN numeric(25,0) NULL,	    --�������ļ����ļ����ֻ�����Ը���Ϊ��д���ԣ����¸��ģ�ʱ����־���к�
    BackupSizeInBytes bigint,               --���ļ��ı��ݵĴ�С���ֽڣ�
    SourceBlockSize int,					--�����ļ��������豸�����Ǳ����豸���Ŀ��С�����ֽ�Ϊ��λ��
    FileGroupID int,						--�ļ���� ID
    LogGroupGUID uniqueidentifier NULL,		--NULL
    DifferentialBaseLSN numeric(25,0) NULL,	--���챸�ݣ�������־���кŴ��ڻ����DifferentialBaseLSN�������,���������������ͣ���ֵΪ NULLL
    DifferentialBaseGUID uniqueidentifier,	--���ڲ��챸�ݣ���ֵ�ǲ����׼��Ψһ��ʶ��,���������������ͣ���ֵΪ NULL
    IsReadOnly bit,							--1 = �ļ���ֻ����
    IsPresent BIT,							--1 = ���ļ��Ƿ���ڱ�����
	TDEThumbprint varbinary(32)				--��ʾ���ݿ������Կ��ָ�ơ� ���ܳ����ָ���Ǵ��м�����Կ��֤��� SHA-1 ��ϣ�� �й����ݿ���ܵ���Ϣ�������͸�����ݼ��� (TDE)
  )
  /*�������������ṹ����ʱ�����һ�����Ƕ�������,
  ��ids����������У�,
  ��file_path,����ļ���·��*/
  declare @temp_backup table(
     [ids] smallint identity,  --���������
     [LogicalName] nvarchar(128), 
     [PhysicalName] nvarchar(260), 
     [File_path] nvarchar(260), 
     [Type] char(1),
     [FileGroupName] nvarchar(128)
  )
  insert into #temp_backup execute('restore filelistonly from disk='''+@filename+'''')
  /*����ʱ����������,���Ҽ������Ӧ��·��*/
  insert into @temp_backup(LogicalName,PhysicalName,File_path,Type,FileGroupName)
  select LogicalName,PhysicalName,dbo.fn_GetFilePath ( PhysicalName),Type,FileGroupName from #temp_backup
  if @@rowcount>0
  begin
    drop table #temp_backup
  end
  set @loop_time=1

  /*@tem���ids�������*/
  select @max_ids=max(ids) from @temp_backup
  while @loop_time<=@max_ids
  begin
	select @file_bak_path=file_path from @temp_backup where ids=@loop_time
	set @sql_cmd='dir '+@file_bak_path
	exec @proc_result = master..xp_cmdshell @sql_cmd,no_output
	
	/*ϵͳ�洢����xp_cmdshell���ش���ֵ:0(�ɹ�����1��ʧ�ܣ�*/
    if (@proc_result<>0) 
    set @loop_time=@loop_time+1  
    else
    /*û���ҵ�����ǰ�����ļ�ԭ�д��·�����˳�ѭ��*/
    break 
  end
  set @master_path=''
  if @loop_time>@max_ids 
  /*����ǰ�����ļ�ԭ�д��·������*/
  set @flag_file=1
  else
  begin
    /*����ǰ�����ļ�ԭ�д��·��������*/
    set @flag_file=0  
    select @master_path=dbo.fn_GetFilePath(filename) from master..sysdatabases where name='master'
  end
  set @sql_sub=''
  /*type='d'�������ļ�,type='l'����־�ļ� */
  /*@flag_file=1ʱ�µ����ݿ��ļ����Ǵ����ԭ��·����������·����master���ݿ�·��һ��*/
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
  /*�ر���ؽ��̣�����Ӧ����״��������ʱ����*/
  select identity(int,1,1) ids, spid into #temp from master..sysprocesses where dbid=db_id(@restore_db_name)
  /*�ҵ���Ӧ����*/
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
  /*�����ɹ�*/
  set @flag='ok'
  set @ret = 1
end
else
begin
  /*����@filename�����ʽ����*/
  set @flag='file type error'
  set @ret = 0
end


go
/*����*/
/*�������ݿ�test*/
declare @fl varchar(20)
declare @rl bit
--execute sp_Data_Backup 'ProjectManage','D:\ProjectManage.bak',@rl out,@fl out
print @fl

/*�ָ����ݿ�,����Ĳ�������*/
declare @f2 varchar(10)
declare @r2 bit
exec sp_Data_Restore 'ProjectManage','d:\ProjectManage.bak',@r2 out, @f2 out
print @f2

/*�ָ����ݿ�,���������ݿ�test�ĸ���test_db*/
declare @f3 varchar(20)
declare @r3 bit
--exec sp_Data_Restore 'ProjectManage_db','d:\ProjectManage.bak',@r3 out,@f3 out
--print @f3




--������ݿ�
if( object_id('sp_Data_Clear') is not null )      
drop procedure sp_Data_Clear
go

create procedure sp_Data_Clear
as
begin transaction --��ʼһ������
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
      dbcc checkident(@tbl, reseed, 0)  --����������������������ֵ
    end
    fetch next from cur_clear into @tbl
  end
  close cur_clear
  deallocate cur_clear
commit transaction --����һ������


go 
--ִ��
exec sp_Data_Clear

go
backup log ProjectManage to disk='d:\log.bak' with norecovery,no_truncate -- �ض���־
alter database ProjectManage set recovery simple ----�޸����ݿ�ָ�ģʽ ��ģʽ
dbcc shrinkdatabase('ProjectManage')  --����ָ�����ݿ��е������ļ���С
dbcc updateusage('ProjectManage')  --����͸��� sysindexes ��Ĳ���ȷ����
alter database ProjectManage set recovery full ----�޸����ݿ�ָ�ģʽ ��ȫģʽ

--�鿴��ռ�
select 
object_name(id) as ����, 
(rtrim(8*reserved/1024) + 'MB') as ����, 
(rtrim(8*dpages/1024) + 'MB') as ��ʹ��, 
(rtrim(8*(reserved-dpages)/1024) + 'MB') as δʹ��, 
(rtrim(8*dpages/1024-rows/1024*minlen/1024) + 'MB' ) as ��϶
from sysindexes
where indid=1
order by reserved desc