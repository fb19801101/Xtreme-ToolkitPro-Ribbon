use ProjectManage
go

create table dbo.tb_hierarchy
(
id  int not null primary key, --��������id
id_parent int not null,  --���������ϼ�id
name nvarchar(20) not null  --������������
)

go
insert into dbo.tb_hierarchy
values(1,0,'����ʡ')
,(2,1,'������'),(3,2,'������'),(4,3,'«����'),(12,3,'������'),(13,3,'̨ͷ��'),(14,3,'�ȶ���')
,(8,2,'��ʼ��'),(9,8,'�����')
,(10,2,'Ϣ��'),(11,10,'�ص���')
,(5,1,'������'),(6,5,'����'),(7,6,'������')
,(15,1,'������'),(16,15,'������')
,(17,1,'פ�����'),(18,17,'������')

select * 
from dbo.tb_hierarchy
order by id_parent


--ʵ���ɸ������Ӽ��Ĳ�ѯ
--����ʵ�ʵ����ݿ����кܶ࣬���ԣ�Ҫ���ȡ����ʡ�µ������У��أ��磬�����Ϣ������ʹ�õݹ��ѯ
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

--���Ҫ�鿴���ڵݹ鵽����level������ʹ�������У�level=0��ʡlevel��level=1����level���������ơ�

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


--���Ӽ��򸸼��ĵݹ��ѯ

;with cte as
(
select id,id_parent,name
from dbo.tb_hierarchy
where id=4 --«�����ID

union all
select h.id,h.id_parent,h.name
from dbo.tb_hierarchy h
inner join cte c on h.id=c.id_parent
)
select id,id_parent,name
from cte
order by id_parent
