USE [ProjectManage]
GO
drop table 路基数量
drop table 路基对上
drop table 路基对下
drop table 桥涵数量
drop table 桥涵对上
drop table 桥涵对下
drop table 隧道数量
drop table 隧道对上
drop table 隧道对下
drop table 轨道数量
drop table 轨道对上
drop table 轨道对下
drop table 站场数量
drop table 站场对上
drop table 站场对下
drop table 大临数量
drop table 大临对上
drop table 大临对下
GO
EXEC sp_rename '路基数量', 'tb_roaddat'
EXEC sp_rename '桥涵数量', 'tb_briddat'
EXEC sp_rename '隧道数量', 'tb_tunneldat'
EXEC sp_rename '轨道数量', 'tb_raildat'
EXEC sp_rename '站场数量', 'tb_yarddat'
EXEC sp_rename '大临数量', 'tb_tempdat'
EXEC sp_rename '路基对上', 'tb_roadup'
EXEC sp_rename '桥涵对上', 'tb_bridgeup'
EXEC sp_rename '隧道对上', 'tb_tunnelup'
EXEC sp_rename '轨道对上', 'tb_railup'
EXEC sp_rename '站场对上', 'tb_yardup'
EXEC sp_rename '大临对上', 'tb_tempup'
EXEC sp_rename '路基对下', 'tb_roaddown'
EXEC sp_rename '桥涵对下', 'tb_bridgedown'
EXEC sp_rename '隧道对下', 'tb_tunneldown'
EXEC sp_rename '轨道对下', 'tb_raildown'
EXEC sp_rename '站场对下', 'tb_yarddown'
EXEC sp_rename '大临对下', 'tb_tempdown'