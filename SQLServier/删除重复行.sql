USE ProjectManage
select distinct * into #Tmp from ����̨��
drop table ����̨��
select * into ����̨�� from #Tmp
drop table #Tmp


���ǿ��ܻ�������������ĳ����ԭ����Ʋ���ȫ�����±���������������ظ�����ô����ζ��ظ������ݽ���ɾ���أ� 
�ظ������ݿ��������������������һ��ʱ����ֻ��ĳЩ�ֶ�һ�����ڶ��������м�¼��ȫһ���� 
һ�����ڲ����ֶ��ظ����ݵ�ɾ�� 
����̸̸��β�ѯ�ظ������ݰɡ� 
���������Բ�ѯ����Щ�������ظ��ģ�

select �ֶ�1,�ֶ�2,count(*) from ���� group by �ֶ�1,�ֶ�2 having count(*) > 1

�������>�Ÿ�Ϊ=�žͿ��Բ�ѯ��û���ظ��������ˡ� 
��Ҫɾ����Щ�ظ������ݣ�����ʹ������������ɾ��

delete from ���� a where �ֶ�1,�ֶ�2 in  
(select �ֶ�1,�ֶ�2,count(*) from ���� group by �ֶ�1,�ֶ�2 having count(*) > 1)

��������ǳ��򵥣����ǽ���ѯ��������ɾ��������������ɾ��ִ�е�Ч�ʷǳ��ͣ����ڴ���������˵�����ܻὫ���ݿ�����������ҽ����Ƚ���ѯ�����ظ������ݲ��뵽һ����ʱ���У�Ȼ��Խ���ɾ����������ִ��ɾ����ʱ��Ͳ����ٽ���һ�β�ѯ�ˡ����£�

CREATE TABLE ��ʱ�� AS  
(select �ֶ�1,�ֶ�2,count(*) from ���� group by �ֶ�1,�ֶ�2 having count(*) > 1)

������仰���ǽ�������ʱ��������ѯ�������ݲ������С� 
����Ϳ��Խ���������ɾ��������

delete from ���� a where �ֶ�1,�ֶ�2 in (select �ֶ�1���ֶ�2 from ��ʱ��);

�����Ƚ���ʱ���ٽ���ɾ���Ĳ���Ҫ��ֱ����һ��������ɾ��Ҫ��Ч�öࡣ 

���ʱ�򣬴�ҿ��ܻ�������˵��ʲô���������ִ��������䣬�ǲ��ǰ������ظ���ȫ��ɾ���𣿶������뱣���ظ����������µ�һ����¼������Ҳ�Ҫ���������Ҿͽ�һ����ν������ֲ����� 
��oracle�У��и��������Զ�rowid�������ÿ����¼һ��Ψһ��rowid����������뱣�����µ�һ����¼�� 
���ǾͿ�����������ֶΣ������ظ�������rowid����һ����¼�Ϳ����ˣ�

�����ǲ�ѯ�ظ����ݵ�һ�����ӣ�

select a.rowid,a.* from ���� a   
where a.rowid !=   
(  
select max(b.rowid) from ���� b   
where a.�ֶ�1 = b.�ֶ�1 and   
a.�ֶ�2 = b.�ֶ�2   
)

�����Ҿ�������һ�£����������е�����ǲ�ѯ���ظ�������rowid����һ����¼�� 
��������ǲ�ѯ������rowid���֮��������ظ��������ˡ� 
�ɴˣ�����Ҫɾ���ظ����ݣ�ֻ�������µ�һ�����ݣ��Ϳ�������д�ˣ�

delete from ���� a   
where a.rowid !=   
(  
select max(b.rowid) from ���� b   
where a.�ֶ�1 = b.�ֶ�1 and   
a.�ֶ�2 = b.�ֶ�2   
)

���˵һ�£���������ִ��Ч���Ǻܵ͵ģ����Կ��ǽ�����ʱ������Ҫ�ж��ظ����ֶΡ�rowid������ʱ���У�Ȼ��ɾ����ʱ���ڽ��бȽϡ�

create table ��ʱ�� as   
select a.�ֶ�1,a.�ֶ�2,MAX(a.ROWID) dataid from ��ʽ�� a GROUP BY a.�ֶ�1,a.�ֶ�2
 

delete from ���� a   
where a.rowid !=   
(  
select b.dataid from ��ʱ�� b   
where a.�ֶ�1 = b.�ֶ�1 and   
a.�ֶ�2 = b.�ֶ�2   
);  
commit;

����������ȫ�ظ���¼��ɾ�� 
���ڱ������м�¼��ȫһ�����������������������ȡ��ȥ���ظ����ݺ�ļ�¼�� 
select distinct * from ���� 
���Խ���ѯ�ļ�¼�ŵ���ʱ���У�Ȼ���ٽ�ԭ���ı��¼ɾ���������ʱ������ݵ���ԭ���ı��С����£�

CREATE TABLE ��ʱ�� AS (select distinct * from ����);  
drop table ��ʽ��;  
insert into ��ʽ�� (select * from ��ʱ��);  
drop table ��ʱ��;

�����ɾ��һ������ظ����ݣ������Ƚ�һ����ʱ����ȥ���ظ����ݺ�����ݵ��뵽��ʱ��Ȼ���ڴ� 
��ʱ�����ݵ�����ʽ���У����£�

INSERT INTO t_table_bak  
select distinct * from t_table;


--> --> (Roy)���ɜyԇ����
 
if not object_id('Tempdb..#T') is null
    drop table #T
Go
Create table #T([ID] int,[Name] nvarchar(1),[Memo] nvarchar(2))
Insert #T
select 1,N'A',N'A1' union all
select 2,N'A',N'A2' union all
select 3,N'A',N'A3' union all
select 4,N'B',N'B1' union all
select 5,N'B',N'B2'
Go
 
--I��Name��ͬID��С�ļ�¼(�Ƽ���1,2,3),������Сһ��
����1:
delete a from #T a where  exists(select 1 from #T where Name=a.Name and ID<a.ID)
 
����2:
delete a  from #T a left join (select min(ID)ID,Name from #T group by Name) b on a.Name=b.Name and a.ID=b.ID where b.Id is null
 
����3:
delete a from #T a where ID not in (select min(ID) from #T where Name=a.Name)
 
����4(ע:IDΪΨһʱ����):
delete a from #T a where ID not in(select min(ID)from #T group by Name)
 
����5:
delete a from #T a where (select count(1) from #T where Name=a.Name and ID<a.ID)>0
 
����6:
delete a from #T a where ID<>(select top 1 ID from #T where Name=a.name order by ID)
 
����7:
delete a from #T a where ID>any(select ID from #T where Name=a.Name)
 
 
 
select * from #T
 
���ɽ��:
/*
ID          Name Memo
----------- ---- ----
1           A    A1
4           B    B1
 
(2 ����Ӱ��)
*/
 
 
--II��Name��ͬID��������һ����¼:
 
����1:
delete a from #T a where  exists(select 1 from #T where Name=a.Name and ID>a.ID)
 
����2:
delete a  from #T a left join (select max(ID)ID,Name from #T group by Name) b on a.Name=b.Name and a.ID=b.ID where b.Id is null
 
����3:
delete a from #T a where ID not in (select max(ID) from #T where Name=a.Name)
 
����4(ע:IDΪΨһʱ����):
delete a from #T a where ID not in(select max(ID)from #T group by Name)
 
����5:
delete a from #T a where (select count(1) from #T where Name=a.Name and ID>a.ID)>0
 
����6:
delete a from #T a where ID<>(select top 1 ID from #T where Name=a.name order by ID desc)
 
����7:
delete a from #T a where ID<any(select ID from #T where Name=a.Name)
 
 
select * from #T
/*
ID          Name Memo
----------- ---- ----
3           A    A3
5           B    B2
 
(2 ����Ӱ��)
*/





��һ������ѯ�ظ���¼
[sql] view plain copy
SELECT * FROM TableName  
WHERE RepeatFiled IN (  
    SELECT RepeatFiled  
    FROM TableName  
    GROUP BY RepeatFiled  
    HAVING COUNT(RepeatFiled) > 1  
)  

��һ���߼��ܼ򵥣����ǰ��ظ���������1��ȫ��������������ˡ�
�ڶ�����ɾ���ظ���¼��ֻ����һ��
[sql] view plain copy
SELECT * FROM TableName  
WHERE RepeatFiled IN (  
    SELECT RepeatFiled  
    FROM TableName  
    GROUP BY RepeatFiled  
    HAVING COUNT(RepeatFiled) > 1  
    AND  
    ID NOT IN (  
        SELECT MIN(ID)  
        FROM TableName  
        GROUP BY RepeatFiled  
        HAVING COUNT(RepeatFiled) > 1      
    )  
)  


ȥ���ظ���UserName
delete Student2 where Id in
(
��select id from (
��select Id, UserName,ROW_NUMBER() over (partition by UserName order by id) orderid from Student2
��)t1
��where t1.orderid>1
)