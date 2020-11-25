declare @sql varchar(8000),@sql2 varchar(8000),@i int
set @sql = 'create view 桥涵对下合计 as select ID, 序号, 单价, '
set @i = 1
while @i <= 50
begin
if @i <= 9
set @sql=@sql+'[0'+cast(@i as varchar(5))+'_设计数量]+'
else
set @sql=@sql+'['+cast(@i as varchar(5))+'_设计数量]+'
set @i = @i + 1
end
set @sql = left(@sql,len(@sql) - 1)
set @sql = @sql + 'as 对下设计数量,'
set @i = 1
while @i <= 50
begin
if @i <= 9
set @sql=@sql+'[0'+cast(@i as varchar(5))+'_变更数量]+'
else
set @sql=@sql+'['+cast(@i as varchar(5))+'_变更数量]+'
set @i = @i + 1
end
set @sql = left(@sql,len(@sql) - 1)
set @sql = @sql + 'as 对下变更数量 from 桥涵对下'
print @sql
exec (@sql)