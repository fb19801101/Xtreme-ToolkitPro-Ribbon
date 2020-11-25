USE [ProjectManage]
GO

drop index tb_road_qty.IX_road_qty_stat
alter table tb_road_qty drop constraint DF_tb_road_qty_rq_stat
alter table tb_road_qty drop column rq_stat

drop index tb_road_qty.IX_road_qty_project
alter table tb_road_qty drop constraint DF_tb_road_qty_rq_project
alter table tb_road_qty drop column rq_project

alter table tb_road_qty drop constraint DF_tb_road_qty_rq_unit
alter table tb_road_qty drop column rq_unit

drop index tb_road_up.IX_road_up_stat
alter table tb_road_up drop constraint DF_tb_road_up_ru_stat
alter table tb_road_up drop column ru_stat

drop index tb_road_up.IX_road_up_project
alter table tb_road_up drop constraint DF_tb_road_up_ru_project
alter table tb_road_up drop column ru_project

alter table tb_road_up drop constraint DF_tb_road_up_ru_unit
alter table tb_road_up drop column ru_unit

alter table tb_road_up drop constraint DF_tb_road_up_ru_price
alter table tb_road_up drop column ru_price

drop index tb_road_down.IX_road_down_stat
alter table tb_road_down drop constraint DF_tb_road_down_rd_stat
alter table tb_road_down drop column rd_stat

drop index tb_road_down.IX_road_down_project
alter table tb_road_down drop constraint DF_tb_road_down_rd_project
alter table tb_road_down drop column rd_project

alter table tb_road_down drop constraint DF_tb_road_down_rd_unit
alter table tb_road_down drop column rd_unit

alter table tb_road_down drop constraint DF_tb_road_down_rd_price
alter table tb_road_down drop column rd_price