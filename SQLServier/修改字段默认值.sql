USE [ProjectManage]
GO

alter table tb_ledger alter column lr_date date NOT NULL

alter table tb_retest_orbit drop constraint DF_tb_retest_orbit_rp_code  

alter table tb_retest_orbit add constraint DF_tb_retest_orbit_rp_code default 'RP00000001' for	rp_code