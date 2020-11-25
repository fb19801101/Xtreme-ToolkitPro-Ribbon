use ProjectManage
go

create table dbo.tb_hierarchy
(
id  int not null primary key, --行政区域id
id_parent int not null,  --行政区域上级id
name nvarchar(20) not null  --行政区域名称
)

go
insert into dbo.tb_hierarchy
values(1,0,'河南省')
,(2,1,'信阳市'),(3,2,'淮滨县'),(4,3,'芦集乡'),(12,3,'邓湾乡'),(13,3,'台头乡'),(14,3,'谷堆乡')
,(8,2,'固始县'),(9,8,'李店乡')
,(10,2,'息县'),(11,10,'关店乡')
,(5,1,'安阳市'),(6,5,'滑县'),(7,6,'老庙乡')
,(15,1,'南阳市'),(16,15,'方城县')
,(17,1,'驻马店市'),(18,17,'正阳县')

select * 
from dbo.tb_hierarchy
order by id_parent


--实现由父级向子级的查询
--由于实际的数据可能有很多，所以，要想获取河南省下的所有市，县，乡，村等信息，必须使用递归查询
;with cte(id,id_parent,Name) as
(
select * 
from dbo.tb_hierarchy 
where id=1

union all
select h.* 
from dbo.tb_hierarchy h
inner join cte c on h.id_parent=c.id 
--where c.id!=h.ID
)
select *
from cte
order by id_parent

--如果要查看向内递归到多少level，可以使用派生列，level=0是省level，level=1是市level，依次类推。

;with cte(id,id_parent,name,Level) as
(
select id,id_parent,name,0 as Level
from dbo.tb_hierarchy 
where id=1

union all
select h.id,h.id_parent,h.name,c.Level+1 as Level
from dbo.tb_hierarchy h
inner join cte c on h.id_parent=c.id 
--where c.id!=h.ID
)
select *
from cte
order by id_parent


--由子级向父级的递归查询

;with cte as
(
select id,id_parent,name
from dbo.tb_hierarchy
where id=4 --芦集乡的ID

union all
select h.id,h.id_parent,h.name
from dbo.tb_hierarchy h
inner join cte c on h.id=c.id_parent
)
select id,id_parent,name
from cte
order by id_parent
