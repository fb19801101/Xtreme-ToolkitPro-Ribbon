USE [ProjectManage]
GO
alter table tb_tunnel_up alter column tu_qty_sum_design float
alter table tb_tunnel_up drop column tu_qty_sum_design
alter table tb_tunnel_up add tu_qty_sum_design as tu_qty_pre_design+tu_qty_cur_design


USE [ProjectManage]
GO
alter table tb_retest_orbit drop column [ro_estab]
alter table tb_retest_orbit drop column [ro_check]
alter table tb_retest_orbit drop column [ro_audit]
alter table tb_retest_orbit drop column [ro_info]
alter table tb_retest_orbit add [ro_estab] [nvarchar](5) DEFAULT(N'编制') NOT NULL
alter table tb_retest_orbit add [ro_check] [nvarchar](5) DEFAULT(N'未复核') NOT NULL
alter table tb_retest_orbit add [ro_audit] [nvarchar](5) DEFAULT(N'未审核') NOT NULL
alter table tb_retest_orbit add [ro_info] [nvarchar](40) NULL
alter table tb_retest_orbit add [ro_info] [int] IDENTITY(1,1) NOT NULL