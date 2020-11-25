-- ʹ��sql��䴴���޸�SQL Server��ʶ��(���Զ�������)

-- һ����ʶ�еĶ����Լ��ص�
-- SQL Server�еı�ʶ���ֳƱ�ʶ����,ϰ�����ֽ������С�
-- �����о������������ص㣺
-- 1���е���������Ϊ����С������ֵ����
-- 2���ڽ��в���(Insert)����ʱ�����е�ֵ����ϵͳ��һ����������,�������ֵ
-- 3����ֵ���ظ������б�ʶ����ÿһ�е�����,ÿ����ֻ����һ����ʶ�С�
-- ���������ص㣬ʹ�ñ�ʶ�������ݿ������еõ��㷺��ʹ�á�

-- ������ʶ�е����
-- ����һ����ʶ�У�ͨ��Ҫָ����������:
-- 1�����ͣ�type��
-- ��SQL Server 2000�У���ʶ�����ͱ�������ֵ���ͣ����£�
-- decimal��int��numeric��smallint��bigint ��tinyint 
-- ����Ҫע����ǣ���ѡ��decimal��numericʱ��С��λ������Ϊ��
-- ���⻹Ҫע��ÿ�������������б�ʾ����ֵ��Χ
-- 2������(seed)
-- ��ָ�ɸ����е�һ�е�ֵ,Ĭ��Ϊ1
-- 3��������(increment)
-- ����������ʶֵ֮���������Ĭ��Ϊ1��

-- ������ʶ�еĴ������޸�
-- ��ʶ�еĴ������޸ģ�ͨ������ҵ����������Transact-SQL��䶼��ʵ�֣�ʹ����ҵ����������Ƚϼ򵥣���ο�SQL Server��������������
-- ��ֻ����ʹ��Transact-SQL�ķ���
-- 1��������ʱָ����ʶ��
-- ��ʶ�п��� IDENTITY ���Խ����������SQL Server�У��ֳƱ�ʶ��Ϊ����IDENTITY���Ե��л�IDENTITY�С�
-- ��������Ӵ���һ��������ΪID,����Ϊint,����Ϊ1��������Ϊ1�ı�ʶ��
   CREATE TABLE T_test
   (ID int IDENTITY(1,1),
   Name varchar(50)
   )
-- 2�������б�����ӱ�ʶ��
-- ������������T_test�����һ����ΪID,����Ϊint,����Ϊ1��������Ϊ1�ı�ʶ��
   --������
   CREATE TABLE T_test
   (Name varchar(50)
   )
   --��������
   INSERT T_test(Name) VALUES('����')
   --���ӱ�ʶ��
   ALTER TABLE T_test
   ADD ID int IDENTITY(1,1)
-- 3���ж�һ�����Ƿ���б�ʶ��
-- ����ʹ�� OBJECTPROPERTY ����ȷ��һ�����Ƿ���� IDENTITY����ʶ����,�÷�:
   Select OBJECTPROPERTY(OBJECT_ID('����'),'TableHasIdentity')
-- ����У��򷵻�1,���򷵻�0
-- 4���ж�ĳ���Ƿ��Ǳ�ʶ��
-- ��ʹ�� COLUMNPROPERTY ����ȷ�� ĳ���Ƿ����IDENTITY ����,�÷�
   SELECT COLUMNPROPERTY( OBJECT_ID('����'),'����','IsIdentity')
-- �������Ϊ��ʶ�У��򷵻�1,���򷵻�0
-- 4����ѯĳ���ʶ�е�����
   SQL Server��û���ֳɵĺ���ʵ�ִ˹��ܣ�ʵ�ֵ�SQL�������
   SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.columns
   WHERE TABLE_NAME='����' AND COLUMNPROPERTY( 
   OBJECT_ID('����'),COLUMN_NAME,'IsIdentity')=1
-- 5����ʶ�е�����
-- �����SQL��������ñ�ʶ�У����ùؼ���IDENTITYCOL����
-- ���磬��Ҫ��ѯ������ID����1���У�
-- ����������ѯ����ǵȼ۵�
   SELECT * FROM T_test WHERE IDENTITYCOL=1
   SELECT * FROM T_test WHERE ID=1
-- 6����ȡ��ʶ�е�����ֵ
-- ��ʹ�ú���IDENT_SEED,�÷���
   SELECT IDENT_SEED ('����')
-- 7����ȡ��ʶ�еĵ�����
-- ��ʹ�ú���IDENT_INCR ,�÷���
   SELECT IDENT_INCR('����')
-- 8����ȡָ������������ɵı�ʶֵ
-- ��ʹ�ú���IDENT_CURRENT���÷�:
   SELECT IDENT_CURRENT('����') 
-- ע�������������ʶ�еı�ոմ���,Ϊ�����κβ������ʱ��ʹ��IDENT_CURRENT�����õ���ֵΪ��ʶ�е�����ֵ����һ���ڿ������ݿ�Ӧ�ó����ʱ������Ӧ��ע�⡣


----------------

--���� SQL ����޸ĳ�һ����ʶ��ʹ��sql��䴴���޸�SQL <wbr>Server��ʶ��(���Զ�������)
--�����ݸ��Ƶ���ʱ��
select * into #aclist from aclist

--ɾ�����ݱ�
drop table aclist

--�������ݱ������ñ�ʶ�У�
create table aclist(id int identity(1,1),[date] datetime,version nvarchar(6),[class] nvarchar(10),actitle nvarchar(50),acdetail nvarchar(max),author nvarchar(50))

--���ñ�ʶ���������
set identity_insert aclist on

--�����ݴ���ʱ��ת�ƹ���
insert into aclist(id,[date],version,[class],actitle,acdetail,author)
select id,[date],version,[class],actitle,acdetail,author from #aclist

--�رձ�ʶ�в���
set identity_insert aclist off

--ǿ�����ñ�ʶ�е���ʼֵ:
DBCC CHECKIDENT (����, RESEED, 1) --ǿ��ʹ��ʶֵ��1��ʼ.


----------------

--�޸�ԭ���ֶ��У���ɾ����ֱ���޸ı����ֶΣ�ɾ�����ݺ󣬴���

--����û���Զ����������ݱ�
CREATE TABLE [tbMessage](
[id] [decimal](18, 0),
[msg_content] [varchar](max) NULL
) ON [PRIMARY]

GO
--�����������
insert into [tbMessage]([id],[msg_content])
values(20,'��֪����')

insert into [tbMessage]([id],[msg_content])
values(21,'��֪����201')
go
--�鿴����
--select * from tbMessage

--������ʱ��
select * into #tbMessage from [tbMessage]
go
--ɾ��������
delete [tbMessage]
go

--ɾ���ֶ�ID
alter table [tbMessage] drop column [ID]
--����ID�Զ������ֶ�
alter table [tbMessage] add [id] int identity(1,1)
set identity_insert [tbMessage] on

--�����ݴ���ʱ��ת�ƹ���

insert into [tbMessage]([msg_content],[id])
select [msg_content],[id] from #tbMessage

--�رձ�ʶ�в���
set identity_insert [tbMessage] off

---ɾ����ʱ��
drop table #tbMessage

--------------------------------------------------
/*
drop table tbMessage
---------------����Զ������ֶ��Ƿ�����----------
----��ȡ��������
SELECT IDENT_SEED ('[tbMessage]')

---drop table tbMessage
---�����������

insert into [tbMessage]([msg_content])
values('��֪����20111')

insert into [tbMessage]([msg_content])
values('��֪����20112')

---�鿴���ID�Ƿ�,��������
select * from tbMessage
*/

--��ѯ��ǰ�ı�ʶ��ֵ��
SELECT IDENT_CURRENT('dbo.StayPushShipping') 
SELECT IDENT_INCR('dbo.StayPushShipping')
SELECT IDENT_SEED ('dbo.StayPushShipping')

--������ͨ�ı���TRUNCATE TABLE
TRUNCATE TABLE name  --����ɾ����������ֵ�����ñ�ʶֵ �����Ǳ��ڵ����ݽ���ʧ��

--���������˸��Ƶı�����DELETEɾ�����ݺ���DBCC CHECKIDENT
DBCC CHECKIDENT ('dbo.StayPushShipping', RESEED,1)

-- ����Ҫ���ñ�ʶֵ����ɾ�����ݣ��������淽�����ɣ����Ǵ������⣺
-- 1)DBCC CHECKIDENT ('����', RESEED,new_value)(�����µı�ʶֵ��new_valueΪ��ֵ)
-- 2)���⣺��dbcc checkident ('����',reseed,1)���ɣ���������������ݣ��������ֵ���С�ڵ�ǰ��
--   �ı�ʶ���ֵ���ٲ�������ʱδָ������ı�ʶֵ�������ᵼ�±�ʶ��ͻ���⣬�����ı�ʶ���ó���
--   ���ġ����⣬��Ҳ������ dbcc checkident('����',reseed)�������Զ�����ֵ���������ֵ��