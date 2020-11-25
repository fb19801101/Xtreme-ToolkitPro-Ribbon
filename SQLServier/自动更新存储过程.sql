/*功能：返回某一表的所有字段、存储过程、函数的参数信息*/
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

go
if exists(select name from sys.procedures where name = 'sp_CreateProcdure')
drop procedure sp_CreateProcdure

go
create procedure sp_CreateProcdure(@TableName nvarchar(50))
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