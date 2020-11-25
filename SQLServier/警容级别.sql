/*

�﷨
ALTER DATABASE database_name 
SET COMPATIBILITY_LEVEL = { 80 | 90 | 100 }
 
����
database_name 
Ҫ�޸ĵ����ݿ�����ơ�

COMPATIBILITY_LEVEL { 80 | 90 | 100 }
Ҫʹ���ݿ���֮���ݵ� SQL Server �汾����ֵ����Ϊ����ֵ֮һ��
= SQL Server 2000 
= SQL Server 2005 
= SQL Server 2008 

��ע
�������� SQL Server 2008 ��װ��Ĭ�ϵļ��ݼ���Ϊ 100������ model ���ݿ��и��͵ļ��ݼ��𣬷��� SQL Server 2008 �д��������ݿ������Ϊ�ü��𡣽����ݿ�� SQL Server ���κ����ڰ汾������ SQL Server 2008 ʱ��������ݿ�ļ��ݼ����� 80 ���£�������ݿ⽫���������еļ��ݼ����������ݼ������ 80 �����ݿ�Ὣ���ݿ�ļ��ݼ�������Ϊ 80�����������ϵͳ���ݿ⣬Ҳ�������û����ݿ⡣ʹ�� ALTER DATABASE �ɸ������ݿ�ļ��ݼ�����Ҫ�鿴���ݿ�ĵ�ǰ���ݼ������ѯ sys.databases Ŀ¼��ͼ�е� compatibility_level �С�

���ü��ݼ�����������
���ݼ���ֻӰ��ָ�����ݿ����Ϊ������Ӱ����������������Ϊ�����ݼ���ֻʵ���� SQL Server �����ڰ汾���ֲ��������ݡ�ͨ�������ݼ���������ʱ�Ե�Ǩ�Ƹ������ߣ��ɽ����ؼ��ݼ������ÿ��Ƶ���Ϊ֮����ڵİ汾�������⡣������� SQL Server Ӧ�ó����ܵ� SQL Server 2008 ����Ϊ�����Ӱ�죬��Ը�Ӧ�ó������ת����ʹ֮���������С�Ȼ��ʹ�� ALTER DATABASE �����ݼ������Ϊ 100�����ݿ���¼��������ý��ڸ����ݿ��´γ�Ϊ��ǰ���ݿ⣨�������ڵ�¼ʱ��ΪĬ�����ݿ⻹���� USE �����ָ����ʱ��Ч��

���ʵ��
������û����ӵ����ݿ�ʱ���ļ��ݼ��𣬿��ܻ�ʹ���ѯ��������ȷ�Ľ���������磬����ڱ�д��ѯ�ƻ�ʱ���ݼ��������ģ����д��ļƻ�����ͬʱ���ھɵĺ��µļ��ݼ��𣬴Ӷ���ɼƻ�����ȷ�������ܵ��½����׼ȷ�����⣬������ƻ����ڼƻ������й������Ĳ�ѯ���ã���������ܸ��Ӹ��ӡ�Ϊ�˱����ѯ�����׼ȷ��������ʹ�����¹������������ݿ�ļ��ݼ���

1. ͨ��ʹ�� ALTER DATABASE SET SINGLE_USER�������ݿ�����Ϊ���û�����ģʽ��
2. �������ݿ�ļ��ݼ���
3. ͨ��ʹ�� ALTER DATABASE SET MULTI_USER�������ݿ���Ϊ���û�����ģʽ��
   �й��������ݿ����ģʽ����ϸ��Ϣ������� ALTER DATABASE (Transact-SQL)��
*/


--��ȡ���ݿ���ݼ���
SELECT name ,compatibility_level ,recovery_model_desc FROM sys.databases WITH(NOLOCK)

--���û�����Ϊ���û�����ģʽ
ALTER DATABASE test SET SINGLE_USER

--�޸����ݿ�ļ��ݼ���
ALTER DATABASE TEST
SET COMPATIBILITY_LEVEL = 90
--or
EXEC sp_dbcmptlevel TEST, 90;
GO



--���û�����Ϊ���û�����ģʽ
ALTER DATABASE test SET MULTI_USER

/*
�﷨
sp_dbcmptlevel [ [ @dbname = ] name ] 
    [ , [ @new_cmptlevel = ] version ]
 

����
[ @dbname = ] name
ҪΪ����ļ��ݼ�������ݿ�����ơ����ݿ����Ʊ�����ϱ�ʶ���Ĺ���name ����������Ϊ sysname��Ĭ��ֵΪ NULL��

[ @new_cmptlevel = ] version
���ݿ�Ҫ��֮���ݵ� SQL Server �İ汾��version ����������Ϊ tinyint��Ĭ��ֵΪ NULL����ֵ����Ϊ����ֵ֮һ��
= SQL Server 2000 
= SQL Server 2005 
= SQL Server 2008 

���ش���ֵ
0���ɹ����� 1��ʧ�ܣ�

�����
���δָ���κβ�����δָ�� name �������� sp_dbcmptlevel �����ش���

���ָ�� name ��δָ�� version���� ���ݿ����潫����һ����Ϣ����ʾָ�����ݿ�ĵ�ǰ���ݼ���

��ע
�йؼ��ݼ����˵��������� ALTER DATABASE ���ݼ��� (Transact-SQL)��

Ȩ��
ֻ�����ݿ������ߡ�sysadmin �̶���������ɫ�� db_owner �̶����ݿ��ɫ�ĳ�Ա��ǰ������Ҫ���ĵ�ǰ���ݿ⣩����ִ�д˹��̡�

*/