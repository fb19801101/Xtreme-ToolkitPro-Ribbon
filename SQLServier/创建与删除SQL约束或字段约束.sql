USE [ProjectManage]
GO
--创建与删除SQL约束或字段约束
--1)禁止所有表约束的SQL
select 'alter table '+name+' nocheck constraint all' from sysobjects where Name = 'tb_tunnel_up' And type='U'

--2)删除所有表数据的SQL
select 'TRUNCATE TABLE '+name from sysobjects where type='U'

--3)恢复所有表约束的SQL
select 'alter table '+name+' check constraint all' from sysobjects where type='U'

--4)删除某字段的约束
declare @name varchar(100)
--DF为约束名称前缀
select @name=b.name from syscolumns a,sysobjects b where a.id=object_id('表名') and b.id=a.cdefault and a.name='字段名' and b.name like 'DF%'
--删除约束
alter table 表名 drop constraint @name
--为字段添加新默认值和约束
ALTER TABLE 表名 ADD CONSTRAINT @name  DEFAULT (0) FOR [字段名]

 

--删除约束
ALTER TABLE tablename
Drop CONSTRAINT 约束名
--修改表中已经存在的列的属性（不包括约束，但可以为主键或递增或唯一）
ALTER TABLE tablename 
alter column 列名 int not null
--添加列的约束
ALTER TABLE tablename
ADD CONSTRAINT DF_tablename_列名 DEFAULT(0) FOR 列名
--添加范围约束
alter table  tablename  add  check(性别 in ('M','F'))