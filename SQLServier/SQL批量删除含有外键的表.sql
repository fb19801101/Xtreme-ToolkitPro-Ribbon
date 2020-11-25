�ȿ�������Ҫ�õ��ļ���Ŀ¼��ͼ�Ľ���:
1,sys.foreign_keys--�������ͼ�з��������е����Լ��
2,sys.foreign_key_columns--�������ͼ�з��������������(ֻ�����е�id)
3,sys.columns--�������ͼ�з����˱�����ͼ��������

ʾ����
��������Ҫ��ѯ��tb1�����������Ϣ���������£�
select
a.name as Լ����,
object_name(b.parent_object_id) as �����,
d.name as �����,
object_name(b.referenced_object_id) as ������,
c.name as ������
from sys.foreign_keys a
inner join sys.foreign_key_columns b on a.object_id=b.constraint_object_id
inner join sys.columns c on b.parent_object_id=c.object_id and b.parent_column_id=c.column_id 
inner join sys.columns d on b.referenced_object_id=d.object_id and b.referenced_column_id=d.column_id 
where object_name(b.referenced_object_id)='tb1';

set xact_abort on
begin tran
declare @sql nvarchar(128)
declare cur_fk cursor local for
select 'alter table '+obj.name+' nocheck constraint '+fk.name as cmd
from sys.foreign_keys  fk  join  sys.all_objects  obj  on(fk.parent_object_id=obj.object_id)
where object_name(fk.referenced_object_id)='tb_points'
--ɾ���������
open cur_fk
fetch cur_fk into @sql
while @@fetch_status = 0
begin
  print @sql
  exec(@sql)
  fetch cur_fk into @sql
end
close cur_fk
deallocate cur_fk
commit tran



SQL Server ���� ͣ��/���� ���Լ��
����ٶ�֪������,��������һ��Ҫ��:

������һ����,�кܶ��ű�
��Ҫɾ��һ�ű�ļ�¼��ʱ��,�����������̫��,
����,û��ɾ����Ӧ�ļ�¼,
˭�ܰ�æд���洢����,������ɾ�����б����,���,
Ȼ�����ɾ�����¼,Ȼ���ٻָ�֮ǰ���е������.


һ�ۿ���ȥ����Ҫ����ɾ������������������ѡ�
����Ҫ�������������֮��
һ�д�����Ϻ󣬻�Ҫ������ؽ�������
����е㸴���ˡ�

���룬���ɾ��֮�󣬻�Ҫ�ؽ��ġ�
�ǻ�����һ��ʼ�Ͳ�ɾ����ֻ����ʱ �������á���
��һϵ�еĲ���ִ����Ϻ�
�ٰ���Щǰ����ʱ �������á� �����  ���ָ�ʹ�á�

 

�������� ͣ�� �����SQL���

select 'alter table '+obj.name+' nocheck constraint '+fk.name+';'  as  sql
from sys.foreign_keys  fk  join  sys.all_objects  obj  on(fk.parent_object_id=obj.object_id)
where object_name(fk.referenced_object_id)='tb_points';

������ж�������¼��ȡ����������ݿ����棬�ж��ٸ�����ˡ�
���ҵĲ������ݿ����棬ֻ��һ������������ҵ�ִ�н��Ϊ��

ALTER TABLE test_sub NOCHECK CONSTRAINT main_id_cons;

�����е�ִ�н������ȥִ��һ�飬 �Ϳ��Խ����е� ���Լ��ͣ�á�
������ִ�еĲ��ԣ�

1> delete  from test_main
2> go
��Ϣ 547������ 16��״̬ 1�������� GMJ-PC\SQLEXPRESS���� 1 ��
DELETE ����� REFERENCE Լ��"main_id_cons"��ͻ���ó�ͻ���������ݿ�"Test"����"dbo
.test_sub", column 'main_id'��
�������ֹ��
1>ALTER TABLE test_sub NOCHECK CONSTRAINT main_id_cons;
2> go
1> delete from test_main
2> go

(2 ����Ӱ��)
1> delete from test_sub
2> go

(2 ����Ӱ��)

����������Ϻ󣬻ָ����

select 'alter table '+obj.name+' check constraint '+fk.name+';'  as  sql
from sys.foreign_keys  fk  join  sys.all_objects  obj  on(fk.parent_object_id=obj.object_id)
where object_name(fk.referenced_object_id)='tb_points';


�ҵ�ִ�н��Ϊ��

ALTER TABLE test_sub CHECK CONSTRAINT main_id_cons;

�������Լ���Ƿ�������

 

1> ALTER TABLE test_sub CHECK CONSTRAINT main_id_cons;
2> go
1> INSERT INTO test_sub VALUES (1, 2 , 'A');
2> go
��Ϣ 547������ 16��״̬ 1�������� GMJ-PC\SQLEXPRESS���� 1 ��
INSERT ����� FOREIGN KEY Լ��"main_id_cons"��ͻ���ó�ͻ���������ݿ�"Test"����"d
bo.test_main", column 'id'��
�������ֹ��






SQL����ɾ����������ı�ķ���(1)
д��һ��

set xact_abort on
begin tran
DECLARE @SQL VARCHAR(99)
DECLARE CUR_FK CURSOR LOCAL FOR
SELECT 'alter table '+ OBJECT_NAME(FKEYID) + ' drop constraint ' + OBJECT_NAME(CONSTID) FROM SYSREFERENCES
--ɾ���������
OPEN CUR_FK
FETCH CUR_FK INTO @SQL
WHILE @@FETCH_STATUS =0
 BEGIN
  EXEC(@SQL)
  FETCH CUR_FK INTO @SQL
 END
CLOSE CUR_FK
DEALLOCATE CUR_FK
-- ɾ�����б� 
DECLARE CUR_TAB CURSOR LOCAL FOR
SELECT 'DROP TABLE '+ NAME FROM SYSOBJECTS WHERE XTYPE='U' -- AND NAME LIKE 'xx%'
OPEN CUR_TAB
FETCH CUR_TAB INTO @SQL
WHILE @@FETCH_STATUS =0
 BEGIN
  EXEC(@SQL)
  FETCH CUR_TAB INTO @SQL
 END
CLOSE CUR_TAB 
DEALLOCATE CUR_TAB
commit tran
д����

DECLARE @SQL VARCHAR(99),@TBL VARCHAR(30),@FK VARCHAR(30)
DECLARE CUR_FK CURSOR LOCAL FOR
SELECT OBJECT_NAME(CONSTID),OBJECT_NAME(FKEYID) FROM SYSREFERENCES
--ɾ���������
OPEN CUR_FK
FETCH CUR_FK INTO @FK,@TBL
WHILE @@FETCH_STATUS =0
BEGIN
SELECT @SQL='ALTER TABLE '+@TBL+' DROP CONSTRAINT '+@FK
EXEC(@SQL)
FETCH CUR_FK INTO @FK,@TBL
END
CLOSE CUR_FK
DECLARE CUR_FKS CURSOR LOCAL FOR
SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U'
OPEN CUR_FKS
FETCH CUR_FKS INTO @TBL
WHILE @@FETCH_STATUS =0
BEGIN
SELECT @SQL='DROP TABLE ['+@TBL+']'
EXEC(@SQL)
FETCH CUR_FKS INTO @TBL
END
CLOSE CUR_FKS