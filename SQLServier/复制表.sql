USE ProjectManage
insert into ����̨��1 select * from ����̨��

USE ProjectManage
go
--���Ŀ�ı��Ѿ�����:
delete tb_retest_orbit_backup
insert into tb_retest_orbit_backup
select * from tb_retest_orbit

go
--���Ŀ�ı�����:
select * into tb_retest_orbit_bkp2
from tb_retest_orbit