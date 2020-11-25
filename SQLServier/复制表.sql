USE ProjectManage
insert into 计量台账1 select * from 计量台账

USE ProjectManage
go
--如果目的表已经存在:
delete tb_retest_orbit_backup
insert into tb_retest_orbit_backup
select * from tb_retest_orbit

go
--如果目的表不存在:
select * into tb_retest_orbit_bkp2
from tb_retest_orbit