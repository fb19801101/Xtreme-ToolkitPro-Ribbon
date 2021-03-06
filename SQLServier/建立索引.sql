USE [ProjectManage]

GO --笔试列创建非聚集索引：填充因子为70％

IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_check_barn')
DROP INDEX tb_check.IX_check_barn
CREATE NONCLUSTERED INDEX IX_check_barn
ON tb_check(b_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_check_goods')
DROP INDEX tb_check.IX_check_goods
CREATE NONCLUSTERED INDEX IX_check_goods
ON tb_check(g_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_check_employee')
DROP INDEX tb_check.IX_check_employee
CREATE NONCLUSTERED INDEX IX_check_employee
ON tb_check(e_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_instock_bill')
DROP INDEX tb_instock.IX_instock_bill
CREATE NONCLUSTERED INDEX IX_instock_bill
ON tb_instock(i_bill)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_instock_barn')
DROP INDEX tb_instock.IX_instock_barn
CREATE NONCLUSTERED INDEX IX_instock_barn
ON tb_instock(b_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_instock_goods')
DROP INDEX tb_instock.IX_instock_goods
CREATE NONCLUSTERED INDEX IX_instock_goods
ON tb_instock(g_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_instock_units')
DROP INDEX tb_instock.IX_instock_units
CREATE NONCLUSTERED INDEX IX_instock_units
ON tb_instock(u_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_instock_employee')
DROP INDEX tb_instock.IX_instock_employee
CREATE NONCLUSTERED INDEX IX_instock_employee
ON tb_instock(e_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_instock_pact')
DROP INDEX tb_instock.IX_instock_pact
CREATE NONCLUSTERED INDEX IX_instock_pact
ON tb_instock(p_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_outstock_bill')
DROP INDEX tb_outstock.IX_outstock_bill
CREATE NONCLUSTERED INDEX IX_outstock_bill
ON tb_outstock(o_bill)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_outstock_barn')
DROP INDEX tb_outstock.IX_outstock_barn
CREATE NONCLUSTERED INDEX IX_outstock_barn
ON tb_outstock(b_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_outstock_goods')
DROP INDEX tb_outstock.IX_outstock_goods
CREATE NONCLUSTERED INDEX IX_outstock_goods
ON tb_outstock(g_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_outstock_units')
DROP INDEX tb_outstock.IX_outstock_units
CREATE NONCLUSTERED INDEX IX_outstock_units
ON tb_outstock(u_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_outstock_employee')
DROP INDEX tb_outstock.IX_outstock_employee
CREATE NONCLUSTERED INDEX IX_outstock_employee
ON tb_outstock(e_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_outstock_pact')
DROP INDEX tb_outstock.IX_outstock_pact
CREATE NONCLUSTERED INDEX IX_outstock_pact
ON tb_outstock(p_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_mixstock_bill')
DROP INDEX tb_mixstock.IX_mixstock_bill
CREATE NONCLUSTERED INDEX IX_mixstock_bill
ON tb_mixstock(m_bill)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_mixstock_barn')
DROP INDEX tb_mixstock.IX_mixstock_barn
CREATE NONCLUSTERED INDEX IX_mixstock_barn
ON tb_mixstock(b_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_mixstock_goods')
DROP INDEX tb_mixstock.IX_mixstock_goods
CREATE NONCLUSTERED INDEX IX_mixstock_goods
ON tb_mixstock(g_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_mixstock_units')
DROP INDEX tb_mixstock.IX_mixstock_units
CREATE NONCLUSTERED INDEX IX_mixstock_units
ON tb_mixstock(u_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_mixstock_employee')
DROP INDEX tb_mixstock.IX_mixstock_employee
CREATE NONCLUSTERED INDEX IX_mixstock_employee
ON tb_mixstock(e_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_mixstock_pact')
DROP INDEX tb_mixstock.IX_mixstock_pact
CREATE NONCLUSTERED INDEX IX_mixstock_pact
ON tb_mixstock(p_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retstock_bill')
DROP INDEX tb_retstock.IX_retstock_bill
CREATE NONCLUSTERED INDEX IX_retstock_bill
ON tb_retstock(r_bill)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retstock_barn')
DROP INDEX tb_retstock.IX_retstock_barn
CREATE NONCLUSTERED INDEX IX_retstock_barn
ON tb_retstock(b_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retstock_goods')
DROP INDEX tb_retstock.IX_retstock_goods
CREATE NONCLUSTERED INDEX IX_retstock_goods
ON tb_retstock(g_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retstock_units')
DROP INDEX tb_retstock.IX_retstock_units
CREATE NONCLUSTERED INDEX IX_retstock_units
ON tb_retstock(u_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retstock_employee')
DROP INDEX tb_retstock.IX_retstock_employee
CREATE NONCLUSTERED INDEX IX_retstock_employee
ON tb_retstock(e_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retstock_pact')
DROP INDEX tb_retstock.IX_retstock_pact
CREATE NONCLUSTERED INDEX IX_retstock_pact
ON tb_retstock(p_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_stock_barn')
DROP INDEX tb_stock.IX_stock_barn
CREATE NONCLUSTERED INDEX IX_stock_barn
ON tb_stock(b_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_stock_goods')
DROP INDEX tb_stock.IX_stock_goods
CREATE NONCLUSTERED INDEX IX_stock_goods
ON tb_stock(g_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_points_name')
DROP INDEX tb_points.IX_points_name
CREATE NONCLUSTERED INDEX IX_points_name
ON tb_points(pt_name)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_ledger_date')
DROP INDEX tb_ledger.IX_ledger_date
CREATE NONCLUSTERED INDEX IX_ledger_date
ON tb_ledger(lr_date)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_up_points')
DROP INDEX tb_road_up.IX_road_up_points
CREATE NONCLUSTERED INDEX IX_road_up_points
ON tb_road_up(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_up_lst')
DROP INDEX tb_road_up.IX_road_up_lst
CREATE NONCLUSTERED INDEX IX_road_up_lst
ON tb_road_up(rl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_up_ledger')
DROP INDEX tb_road_up.IX_road_up_ledger
CREATE NONCLUSTERED INDEX IX_road_up_ledger
ON tb_road_up(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_up_units')
DROP INDEX tb_road_up.IX_road_up_units
CREATE NONCLUSTERED INDEX IX_road_up_units
ON tb_road_up(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_down_points')
DROP INDEX tb_road_down.IX_road_down_points
CREATE NONCLUSTERED INDEX IX_road_down_points
ON tb_road_down(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_down_lst')
DROP INDEX tb_road_down.IX_road_down_lst
CREATE NONCLUSTERED INDEX IX_road_down_lst
ON tb_road_down(rl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_down_ledger')
DROP INDEX tb_road_down.IX_road_down_ledger
CREATE NONCLUSTERED INDEX IX_road_down_ledger
ON tb_road_down(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_down_units')
DROP INDEX tb_road_down.IX_road_down_units
CREATE NONCLUSTERED INDEX IX_road_down_units
ON tb_road_down(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_qty_points')
DROP INDEX tb_road_qty.IX_road_qty_points
CREATE NONCLUSTERED INDEX IX_road_qty_points
ON tb_road_qty(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_qty_lst')
DROP INDEX tb_road_qty.IX_road_qty_lst
CREATE NONCLUSTERED INDEX IX_road_qty_lst
ON tb_road_qty(rl_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_road_lst_project')
DROP INDEX tb_road_lst.IX_road_lst_project
CREATE NONCLUSTERED INDEX IX_road_lst_project
ON tb_road_lst(rl_project)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_up_points')
DROP INDEX tb_tunnel_up.IX_tunnel_up_points
CREATE NONCLUSTERED INDEX IX_tunnel_up_points
ON tb_tunnel_up(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_up_lst')
DROP INDEX tb_tunnel_up.IX_tunnel_up_lst
CREATE NONCLUSTERED INDEX IX_tunnel_up_lst
ON tb_tunnel_up(tl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_up_ledger')
DROP INDEX tb_tunnel_up.IX_tunnel_up_ledger
CREATE NONCLUSTERED INDEX IX_tunnel_up_ledger
ON tb_tunnel_up(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_up_units')
DROP INDEX tb_tunnel_up.IX_tunnel_up_units
CREATE NONCLUSTERED INDEX IX_tunnel_up_units
ON tb_tunnel_up(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_down_points')
DROP INDEX tb_tunnel_down.IX_tunnel_down_points
CREATE NONCLUSTERED INDEX IX_tunnel_down_points
ON tb_tunnel_down(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_down_lst')
DROP INDEX tb_tunnel_down.IX_tunnel_down_lst
CREATE NONCLUSTERED INDEX IX_tunnel_down_lst
ON tb_tunnel_down(tl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_down_ledger')
DROP INDEX tb_tunnel_down.IX_tunnel_down_ledger
CREATE NONCLUSTERED INDEX IX_tunnel_down_ledger
ON tb_tunnel_down(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_down_units')
DROP INDEX tb_tunnel_down.IX_tunnel_down_units
CREATE NONCLUSTERED INDEX IX_tunnel_down_units
ON tb_tunnel_down(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_qty_points')
DROP INDEX tb_tunnel_qty.IX_tunnel_qty_points
CREATE NONCLUSTERED INDEX IX_tunnel_qty_points
ON tb_tunnel_qty(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_qty_lst')
DROP INDEX tb_tunnel_qty.IX_tunnel_qty_lst
CREATE NONCLUSTERED INDEX IX_tunnel_qty_lst
ON tb_tunnel_qty(tl_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_tunnel_lst_project')
DROP INDEX tb_tunnel_lst.IX_tunnel_lst_project
CREATE NONCLUSTERED INDEX IX_tunnel_lst_project
ON tb_tunnel_lst(tl_project)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_up_points')
DROP INDEX tb_bridge_up.IX_bridge_up_points
CREATE NONCLUSTERED INDEX IX_bridge_up_points
ON tb_bridge_up(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_up_lst')
DROP INDEX tb_bridge_up.IX_bridge_up_lst
CREATE NONCLUSTERED INDEX IX_bridge_up_lst
ON tb_bridge_up(bl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_up_ledger')
DROP INDEX tb_bridge_up.IX_bridge_up_ledger
CREATE NONCLUSTERED INDEX IX_bridge_up_ledger
ON tb_bridge_up(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_up_units')
DROP INDEX tb_bridge_up.IX_bridge_up_units
CREATE NONCLUSTERED INDEX IX_bridge_up_units
ON tb_bridge_up(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_down_points')
DROP INDEX tb_bridge_down.IX_bridge_down_points
CREATE NONCLUSTERED INDEX IX_bridge_down_points
ON tb_bridge_down(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_down_lst')
DROP INDEX tb_bridge_down.IX_bridge_down_lst
CREATE NONCLUSTERED INDEX IX_bridge_down_lst
ON tb_bridge_down(bl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_down_ledger')
DROP INDEX tb_bridge_down.IX_bridge_down_ledger
CREATE NONCLUSTERED INDEX IX_bridge_down_ledger
ON tb_bridge_down(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_down_units')
DROP INDEX tb_bridge_down.IX_bridge_down_units
CREATE NONCLUSTERED INDEX IX_bridge_down_units
ON tb_bridge_down(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_qty_points')
DROP INDEX tb_bridge_qty.IX_bridge_qty_points
CREATE NONCLUSTERED INDEX IX_bridge_qty_points
ON tb_bridge_qty(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_qty_lst')
DROP INDEX tb_bridge_qty.IX_bridge_qty_lst
CREATE NONCLUSTERED INDEX IX_bridge_qty_lst
ON tb_bridge_qty(bl_code)
WITH FILLFACTOR = 70


GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_bridge_lst_project')
DROP INDEX tb_bridge_lst.IX_bridge_lst_project
CREATE NONCLUSTERED INDEX IX_bridge_lst_project
ON tb_bridge_lst(bl_project)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_up_points')
DROP INDEX tb_orbital_up.IX_orbital_up_points
CREATE NONCLUSTERED INDEX IX_orbital_up_points
ON tb_orbital_up(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_up_lst')
DROP INDEX tb_orbital_up.IX_orbital_up_lst
CREATE NONCLUSTERED INDEX IX_orbital_up_lst
ON tb_orbital_up(ol_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_up_ledger')
DROP INDEX tb_orbital_up.IX_orbital_up_ledger
CREATE NONCLUSTERED INDEX IX_orbital_up_ledger
ON tb_orbital_up(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_up_units')
DROP INDEX tb_orbital_up.IX_orbital_up_units
CREATE NONCLUSTERED INDEX IX_orbital_up_units
ON tb_orbital_up(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_down_points')
DROP INDEX tb_orbital_down.IX_orbital_down_points
CREATE NONCLUSTERED INDEX IX_orbital_down_points
ON tb_orbital_down(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_down_lst')
DROP INDEX tb_orbital_down.IX_orbital_down_lst
CREATE NONCLUSTERED INDEX IX_orbital_down_lst
ON tb_orbital_down(ol_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_down_ledger')
DROP INDEX tb_orbital_down.IX_orbital_down_ledger
CREATE NONCLUSTERED INDEX IX_orbital_down_ledger
ON tb_orbital_down(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_down_units')
DROP INDEX tb_orbital_down.IX_orbital_down_units
CREATE NONCLUSTERED INDEX IX_orbital_down_units
ON tb_orbital_down(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_qty_points')
DROP INDEX tb_orbital_qty.IX_orbital_qty_points
CREATE NONCLUSTERED INDEX IX_orbital_qty_points
ON tb_orbital_qty(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_qty_lst')
DROP INDEX tb_orbital_qty.IX_orbital_qty_lst
CREATE NONCLUSTERED INDEX IX_orbital_qty_lst
ON tb_orbital_qty(ol_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_orbital_lst_project')
DROP INDEX tb_orbital_lst.IX_orbital_lst_project
CREATE NONCLUSTERED INDEX IX_orbital_lst_project
ON tb_orbital_lst(ol_project)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_up_points')
DROP INDEX tb_yard_up.IX_yard_up_points
CREATE NONCLUSTERED INDEX IX_yard_up_points
ON tb_yard_up(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_up_lst')
DROP INDEX tb_yard_up.IX_yard_up_lst
CREATE NONCLUSTERED INDEX IX_yard_up_lst
ON tb_yard_up(yl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_up_ledger')
DROP INDEX tb_yard_up.IX_yard_up_ledger
CREATE NONCLUSTERED INDEX IX_yard_up_ledger
ON tb_yard_up(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_up_units')
DROP INDEX tb_yard_up.IX_yard_up_units
CREATE NONCLUSTERED INDEX IX_yard_up_units
ON tb_yard_up(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_down_points')
DROP INDEX tb_yard_down.IX_yard_down_points
CREATE NONCLUSTERED INDEX IX_yard_down_points
ON tb_yard_down(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_down_lst')
DROP INDEX tb_yard_down.IX_yard_down_lst
CREATE NONCLUSTERED INDEX IX_yard_down_lst
ON tb_yard_down(yl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_down_ledger')
DROP INDEX tb_yard_down.IX_yard_down_ledger
CREATE NONCLUSTERED INDEX IX_yard_down_ledger
ON tb_yard_down(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_down_units')
DROP INDEX tb_yard_down.IX_yard_down_units
CREATE NONCLUSTERED INDEX IX_yard_down_units
ON tb_yard_down(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_qty_points')
DROP INDEX tb_yard_qty.IX_yard_qty_points
CREATE NONCLUSTERED INDEX IX_yard_qty_points
ON tb_yard_qty(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_qty_lst')
DROP INDEX tb_yard_qty.IX_yard_qty_lst
CREATE NONCLUSTERED INDEX IX_yard_qty_lst
ON tb_yard_qty(yl_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_yard_lst_project')
DROP INDEX tb_yard_lst.IX_yard_lst_project
CREATE NONCLUSTERED INDEX IX_yard_lst_project
ON tb_yard_lst(yl_project)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_up_points')
DROP INDEX tb_temp_up.IX_temp_up_points
CREATE NONCLUSTERED INDEX IX_temp_up_points
ON tb_temp_up(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_up_lst')
DROP INDEX tb_temp_up.IX_temp_up_lst
CREATE NONCLUSTERED INDEX IX_temp_up_lst
ON tb_temp_up(pl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_up_ledger')
DROP INDEX tb_temp_up.IX_temp_up_ledger
CREATE NONCLUSTERED INDEX IX_temp_up_ledger
ON tb_temp_up(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_up_units')
DROP INDEX tb_temp_up.IX_temp_up_units
CREATE NONCLUSTERED INDEX IX_temp_up_units
ON tb_temp_up(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_down_points')
DROP INDEX tb_temp_down.IX_temp_down_points
CREATE NONCLUSTERED INDEX IX_temp_down_points
ON tb_temp_down(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_down_lst')
DROP INDEX tb_temp_down.IX_temp_down_lst
CREATE NONCLUSTERED INDEX IX_temp_down_lst
ON tb_temp_down(pl_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_down_ledger')
DROP INDEX tb_temp_down.IX_temp_down_ledger
CREATE NONCLUSTERED INDEX IX_temp_down_ledger
ON tb_temp_down(lr_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_down_units')
DROP INDEX tb_temp_down.IX_temp_down_units
CREATE NONCLUSTERED INDEX IX_temp_down_units
ON tb_temp_down(u_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_qty_points')
DROP INDEX tb_temp_qty.IX_temp_qty_points
CREATE NONCLUSTERED INDEX IX_temp_qty_points
ON tb_temp_qty(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_qty_lst')
DROP INDEX tb_temp_qty.IX_temp_qty_lst
CREATE NONCLUSTERED INDEX IX_temp_qty_lst
ON tb_temp_qty(pl_code)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_temp_lst_project')
DROP INDEX tb_temp_lst.IX_temp_lst_project
CREATE NONCLUSTERED INDEX IX_temp_lst_project
ON tb_temp_lst(pl_project)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_orbit_point')
DROP INDEX tb_retest_orbit.IX_retest_orbit_point
CREATE NONCLUSTERED INDEX IX_retest_orbit_point
ON tb_retest_orbit(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_orbit_mark')
DROP INDEX tb_retest_orbit.IX_retest_orbit_mark
CREATE NONCLUSTERED INDEX IX_retest_orbit_mark
ON tb_retest_orbit(rp_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_orbit_left_point')
DROP INDEX tb_retest_orbit.IX_retest_orbit_left_point
CREATE NONCLUSTERED INDEX IX_retest_orbit_left_point
ON tb_retest_orbit(ro_left_point)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_orbit_right_point')
DROP INDEX tb_retest_orbit.IX_retest_orbit_right_point
CREATE NONCLUSTERED INDEX IX_retest_orbit_right_point
ON tb_retest_orbit(ro_right_point)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_rail_point')
DROP INDEX tb_retest_rail.IX_retest_rail_point
CREATE NONCLUSTERED INDEX IX_retest_rail_point
ON tb_retest_rail(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_rail_mark')
DROP INDEX tb_retest_rail.IX_retest_rail_mark
CREATE NONCLUSTERED INDEX IX_retest_rail_mark
ON tb_retest_rail(rp_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_rail_left_point')
DROP INDEX tb_retest_rail.IX_retest_rail_left_point
CREATE NONCLUSTERED INDEX IX_retest_rail_left_point
ON tb_retest_rail(rr_left_point)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_rail_right_point')
DROP INDEX tb_retest_rail.IX_retest_rail_right_point
CREATE NONCLUSTERED INDEX IX_retest_rail_right_point
ON tb_retest_rail(rr_right_point)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_plate_point')
DROP INDEX tb_retest_plate.IX_retest_plate_point
CREATE NONCLUSTERED INDEX IX_retest_plate_point
ON tb_retest_plate(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_retest_plate_mark')
DROP INDEX tb_retest_plate.IX_retest_plate_mark
CREATE NONCLUSTERED INDEX IX_retest_plate_mark
ON tb_retest_plate(rp_mark)
WITH FILLFACTOR = 70

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_problem_point')
DROP INDEX tb_problem.IX_problem_point
CREATE NONCLUSTERED INDEX IX_problem_point
ON tb_problem(pt_code)
WITH FILLFACTOR = 70
GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_problem_number')
DROP INDEX tb_problem.IX_problem_number
CREATE NONCLUSTERED INDEX IX_problem_number
ON tb_problem(pm_number)
WITH FILLFACTOR = 70