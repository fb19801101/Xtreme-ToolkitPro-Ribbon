/*���ܣ�����ĳһ��������ֶΡ��洢���̡������Ĳ�����Ϣ*/
create function fn_GetObjColInfo(@ObjName varchar(50))
returns @tb_ret table(TName nvarchar(50), TypeName nvarchar(50), TypeLength nvarchar(50), Colstat Bit)
as
begin
	insert @tb_ret
	select b.name as �ֶ���,c.name as �ֶ�����,b.length
	as �ֶγ���,b.colstat as �Ƿ��Զ�����
	from sysobjects a
	inner join syscolumns b on a.id=b.id
	inner join systypes c on c.xusertype=b.xtype
	where a.name =@ObjName
	order by B.ColID
	return
end

/*���ܣ� �Զ����ɱ�ĸ������ݵĴ洢����
�磺��������MyTable��ִ��SP_CreateProcdure �����ɱ�MyTable�����ݸ�
�µĴ洢����UP_MyTable
��ƣ� OK_008
ʱ�䣺 2006-05
��ע��
1�����ڲ�ѯ��������ִ�У�EXEC SP_CreateProcdure TableName
2���������ɵ��ַ������Ⱥϼƺܶ�ʱ�����>4000���ϣ�����ֻʹ��Print�����
��Copy���ɡ�
3���÷���������һ���ĸ������ݵĴ洢���̣����и��¸�ʽ���Ը���ʵ��
����޸ġ�
��Ʒ�����
1����ȡ��ĸ����ֶ���Ϣ
2�� �����ԩ� ����������ݹ���
���� ����洢���̲�������
���� �����������ݲ���
���� ����������ݲ���
���� ����ɾ�����ݲ���
3���ֶ�PRINT
4����������Ľ�����Ƶ��½����洢���̽����м���ʹ�á�*/

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
	               +' /* -1 ɾ�� 0 �޸� 1���� */'
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
		--����洢���̲�������
		set @strParameter=@strParameter +char(13)+'@'+ @TName + ' ' +@TypeName+','

		--�����������ݲ���
		if @Colstat=0 set @strInsert=@strInsert + '@'+ @TName +','

		--����������ݲ���
		if (@strWhere='')
			begin
				set @strNewID='set @'+@TName+'=(select isnull(max('+@TName+'),0) from '+@TableName+')+1'

				--ȡ�µ�ID
				set @strWhere=' where '+@TName+'='+'@'+@TName
			end
		else
			set @strUpdate=@strUpdate+@TName+'='+'@'+@TName +','
			--����ɾ�����ݲ���
			fetch next from Obj_Cursor into @TName,@TypeName,@TypeLength,@Colstat
	end

	close Obj_Cursor
	
	deallocate Obj_Cursor
	set @strParameter=left(@strParameter,len(@strParameter)-1) --ȥ�����ұߵĶ���
	set @strUpdate=left(@strUpdate,len(@strUpdate)-1)
	set @strInsert=left(@strInsert,len(@strInsert)-1)

	--�洢������������
	print @strSqlProc+@strParameter+char(13)+'as'

	--�޸�
	print 'if (@intUpdateId=0)'
	print' begin'+char(13)
	print char(9)+'update '+@TableName+' set '+@strUpdate+char(13)+char(9)+@strWhere
	print ' end'

	--����
	print 'if (@intUpdateId=1)'
	print ' begin'
	print char(9)+@strNewID
	print char(9)+'insert into '+@TableName+' select '+@strInsert
	print ' end'

	--ɾ��
	print 'else'
	print ' begin'
	print char(9)+'delete from '+@TableName +@strWhere
	print ' end'
	print 'go'
end