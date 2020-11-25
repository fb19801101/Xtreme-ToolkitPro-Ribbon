use ProjectManage
go
--示例数据
create table tb_tree(ID int,Name varchar(10),ParentID int)
insert tb_tree select 1,'AAAA'    ,0
union all select 2,'BBBB'    ,0
union all select 3,'CCCC'    ,0
union all select 4,'AAAA-1'  ,1
union all select 5,'AAAA-2'  ,1
union all select 6,'BBBB-1'  ,2
union all select 7,'BBBB-2'  ,2
union all select 8,'CCCC-1'  ,3
union all select 9,'CCCC-2'  ,3
union all select 10,'AAAA-1-1',4
union all select 11,'AAAA-1-2',4
go

--创建处理的函数
create function f_tree_id()
returns @re table(id int,level int,sid varchar(8000))
as
begin
    declare @l int
    set @l=0
    insert @re select id,@l,right(10000+id,4)
    from tb_tree where ParentID=0
    while @@rowcount>0
    begin
        set @l=@l+1
        insert @re select a.id,@l,b.sid+','+right(10000+a.id,4)
        from tb_tree a,@re b
        where a.ParentID=b.id and b.level=@l-1
    end
    return
end
go

--调用函数实现查询
select a.*,MenuName=space(b.level*4)+a.Name
from tb_tree a,f_tree_id() b
where a.id=b.id
order by b.sid
go

--删除测试
--drop table tb_tree
--drop function f_tree_id