declare @sql varchar(8000),@sql2 varchar(8000),@i int
set @sql = 'create view �ź����ºϼ� as select ID, ���, ����, '
set @i = 1
while @i <= 50
begin
if @i <= 9
set @sql=@sql+'[0'+cast(@i as varchar(5))+'_�������]+'
else
set @sql=@sql+'['+cast(@i as varchar(5))+'_�������]+'
set @i = @i + 1
end
set @sql = left(@sql,len(@sql) - 1)
set @sql = @sql + 'as �����������,'
set @i = 1
while @i <= 50
begin
if @i <= 9
set @sql=@sql+'[0'+cast(@i as varchar(5))+'_�������]+'
else
set @sql=@sql+'['+cast(@i as varchar(5))+'_�������]+'
set @i = @i + 1
end
set @sql = left(@sql,len(@sql) - 1)
set @sql = @sql + 'as ���±������ from �ź�����'
print @sql
exec (@sql)