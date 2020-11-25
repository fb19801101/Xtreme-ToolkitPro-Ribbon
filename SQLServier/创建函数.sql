use ProjectManage
go
/*使用 Ole Automation Procedures 选项可指定是否可以在 Transact-SQL 批处理中实例化 OLE Automation 对象。也可以使用外围应用配置器工具来配置此选项。有关详细信息，请参阅外围应用配置器。
可以将 Ole Automation Procedures 选项设置为以下值。
0  禁用 OLE Automation Procedures。SQL Server 2005 新实例的默认值。
1  启用 OLE Automation Procedures。
当启用 OLE Automation Procedures 时，对 sp_OACreate 的调用将会启动 OLE 共享执行环境。
可以使用 sp_configure 系统存储过程来查看和更改 Ole Automation Procedures 选项的当前值。
以下示例显示了如何查看 OLE Automation Procedures 的当前设置。
以下示例显示了如何启用 OLE Automation Procedures。*/
--开启导入功能
exec sp_configure 'show advanced options', 1;
reconfigure;
exec sp_configure 'Ole Automation Procedures', 1;
reconfigure;
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
--允许在进程中使用ACE.OLEDB.12
exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
--允许动态参数
exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

--导入临时表 
exec ('insert into jihua(id,[批次号],Right('''+ @filepath +''',charindex(''\'',REVERSE('''+ @filepath +'''))-1),getdate() FROM OPENDATASOURCE (''Microsoft.ACE.OLEDB.12.0'', ''Data Source='+@filepath+';User ID=Admin;Password='' )...计划汇总表')

-- Get table (worksheet) or column (field) listings from an excel spreadsheet
-- 设置变量
declare @linkedServerName sysname = 'TempExcelSpreadsheet'
declare @excelFileUrl nvarchar(1000) = 'c:\1.xlsx'
-- 删除链接服务（如果它已经存在）
if exists(select null from sys.servers where name = @linkedServerName) begin
    exec sp_dropserver @server = @linkedServerName, @droplogins = 'droplogins'
end

-- 添加服务对象
-- ACE 12.0 可以很好地工作为*.xls 和 *.xlsx, 你也可以用 Jet ,但是只能访问*.xls文件
exec sp_addlinkedserver
    @server = @linkedServerName,
    @srvproduct = 'ACE 12.0',
    @provider = 'Microsoft.ACE.OLEDB.12.0',
    @datasrc = @excelFileUrl,
    @provstr = 'Excel 12.0;HDR=Yes'
 
-- 获取当前用户
declare @suser_sname nvarchar(256) = suser_sname()
 
-- 添加当前用户作为登陆这个链接服务
exec sp_addlinkedsrvlogin
    @rmtsrvname = @linkedServerName,
    @useself = 'false',
    @locallogin = @suser_sname,
    @rmtuser = null,
    @rmtpassword = null
 
-- 返回 sheet 和 各个 sheet中的列
exec sp_tables_ex @linkedServerName
exec sp_columns_ex @linkedServerName
 
--删除链接服务对象
if exists(select null from sys.servers where name = @linkedServerName) begin
    exec sp_dropserver @server = @linkedServerName, @droplogins = 'droplogins'
end

--关闭导入功能,注意这里，要先关闭外围的设置，然后再关闭高级选项
exec sp_configure'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure'Ole Automation Procedures',0
reconfigure
exec sp_configure'show advanced options',0
reconfigure
--关闭ACE.OLEDB.12的选项
exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 0
exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 0


--功能：在SQL Server中获取Excel文件中所有Sheet工作表的名称
--if exists(select name from sys.procedures where name = 'fn_GetSheetName')
if exists(select * from dbo.sysobjects where id = object_id(N'fn_GetSheetName') and xtype in (N'FN', N'IF', N'TF'))
drop function fn_GetSheetName
go
create function fn_GetSheetName(@xls nvarchar(255))
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
select * from fn_GetSheetName('c:/1.xls')


go
--创建函数,得到文件得路径
if exists(select * from dbo.sysobjects where id = object_id(N'fn_GetFilePath') and xtype in (N'FN', N'IF', N'TF'))
drop function fn_GetFilePath
go
create function fn_GetFilePath(@file nvarchar(255))
returns nvarchar(255)
as
begin
  declare @path nvarchar(255)
  declare @reverse nvarchar(255)
  set @reverse=reverse(@file)
  set @path=substring(@file,1,len(@file)+1-charindex('\',@reverse))
  return @path
end

go
--功能：返回某一表的所有字段、存储过程、函数的参数信息
if exists(select * from dbo.sysobjects where id = object_id(N'fn_GetObjColInfo') and xtype in (N'FN', N'IF', N'TF'))
drop function fn_GetObjColInfo
go
create function fn_GetObjColInfo(@ObjName varchar(50))
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