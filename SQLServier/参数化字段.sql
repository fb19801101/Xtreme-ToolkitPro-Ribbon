use ProjectManage
declare @sql varchar(8000),@fid varchar(100),@i int
set @i=1;
if @i<10
set @fid = '隧道材料消耗.'+'[0'+cast(@i as varchar(5))+'_消耗数量]'
else
set @fid = '隧道材料消耗.'+'['+cast(@i as varchar(5))+'_消耗数量]'
set @sql = 'alter view 隧道材料数据 as select top (100) percent 隧道材料数量.ID,隧道材料数量.序号,隧道材料数量.里程桩号,隧道材料数量.分部工程,隧道材料数量.分项工程,隧道材料数量.施工部位,隧道材料数量.材料规格,隧道材料数量.材料名称,隧道材料数量.单位,
隧道材料数量.Ⅱ*'+@fid+'as Ⅱ,隧道材料数量.Ⅲc*'+@fid+'as Ⅲc,隧道材料数量.[Ⅳa-2]*'+@fid+'as [Ⅳa-2],隧道材料数量.Ⅳb*'+@fid+'as Ⅳb,隧道材料数量.Ⅴb*'+@fid+'as Ⅴb,隧道材料数量.Ⅴc*'+@fid+
'as Ⅴc,隧道材料数量.明偏压*'+@fid+'as 明偏压,隧道材料数量.明覆2*'+@fid+'as 明覆2,隧道材料数量.明覆4*'+@fid+'明覆4,隧道材料数量.明覆6*'+@fid+'明覆6,隧道材料数量.帽檐*'+@fid+'as 帽檐,隧道材料数量.喇叭*'+@fid+
' as 喇叭 from 隧道材料数量,隧道材料消耗
 where 隧道材料数量.ID=隧道材料消耗.ID order by 隧道材料数量.ID'
print @sql
exec (@sql)