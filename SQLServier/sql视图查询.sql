路基数据
SELECT   TOP (100) PERCENT dbo.路基数量.ID, dbo.路基数量.工程项目, dbo.路基数量.单位, dbo.路基数量.蓝图设计数量, 
                dbo.路基数量.蓝图变更数量, dbo.路基数量.复核设计数量, dbo.路基数量.复核变更数量, dbo.路基数量.已完设计数量, 
                dbo.路基数量.已完变更数量, dbo.路基对上.[01_设计数量] AS 对上设计数量, 
                dbo.路基对上.[01_变更数量] AS 对上变更数量, dbo.路基对下.[01_设计数量] AS 对下设计数量, 
                dbo.路基对下.[01_变更数量] AS 对下变更数量, dbo.路基数量.蓝图设计数量 + dbo.路基数量.蓝图变更数量 AS 蓝图数量, 
                dbo.路基数量.复核设计数量 + dbo.路基数量.复核变更数量 AS 复核数量, 
                dbo.路基数量.已完设计数量 + dbo.路基数量.已完变更数量 AS 已完数量, 
                dbo.路基对上.[01_设计数量] + dbo.路基对上.[01_变更数量] AS 对上计价数量, 
                dbo.路基对下.[01_设计数量] + dbo.路基对下.[01_变更数量] AS 对下计价数量, dbo.路基对上.单价 AS 清单单价, 
                dbo.路基对下.单价 AS 劳务单价, dbo.路基数量.序号, dbo.路基数量.里程桩号
FROM      dbo.路基数量 INNER JOIN
                dbo.路基对上 ON dbo.路基数量.ID = dbo.路基对上.ID INNER JOIN
                dbo.路基对下 ON dbo.路基数量.ID = dbo.路基对下.ID
ORDER BY dbo.路基数量.ID

路基分析
SELECT   TOP (100) PERCENT ID, 工程项目, 单位, 蓝图数量, 复核数量, 已完数量, 对上计价数量, 清单单价, 
                FLOOR(对上计价数量 * 清单单价) AS 对上合价, 对下计价数量, 劳务单价, FLOOR(对下计价数量 * 劳务单价) 
                AS 对下合价, 蓝图数量 - 对下计价数量 AS 对下比照蓝图数量, FLOOR((蓝图数量 - 对下计价数量) * 劳务单价) 
                AS 对下比照蓝图合价, 复核数量 - 对下计价数量 AS 对下比照复核数量, FLOOR((复核数量 - 对下计价数量) * 劳务单价) 
                AS 对下比照复核合价, 已完数量 - 对下计价数量 AS 对下比照已完数量, FLOOR((已完数量 - 对下计价数量) * 劳务单价) 
                AS 对下比照已完合价, 蓝图数量 - 对上计价数量 AS 对上比照蓝图数量, FLOOR((蓝图数量 - 对上计价数量) * 清单单价) 
                AS 对上比照蓝图合价, 复核数量 - 对上计价数量 AS 对上比照复核数量, FLOOR((复核数量 - 对上计价数量) * 清单单价) 
                AS 对上比照复核合价, 已完数量 - 对上计价数量 AS 对上比照已完数量, FLOOR((已完数量 - 对上计价数量) * 清单单价) 
                AS 对上比照已完合价, 序号, 里程桩号
FROM      dbo.路基数据
ORDER BY ID

路基汇总
SELECT   TOP (100) PERCENT MIN(序号) AS ID, MIN(工程项目) AS 工程项目, MIN(单位) AS 单位, SUM(蓝图数量) AS 蓝图数量, 
                SUM(复核数量) AS 复核数量, SUM(已完数量) AS 已完数量, SUM(对上计价数量) AS 对上计价数量, MIN(清单单价) 
                AS 清单单价, FLOOR(SUM(对上合价)) AS 对上合价, SUM(对下计价数量) AS 对下计价数量, MIN(劳务单价) AS 劳务单价, 
                FLOOR(SUM(对下合价)) AS 对下合价, SUM(对下比照蓝图数量) AS 对下比照蓝图数量, FLOOR(SUM(对下比照蓝图合价)) 
                AS 对下比照蓝图合价, SUM(对下比照复核数量) AS 对下比照复核数量, FLOOR(SUM(对下比照复核合价)) 
                AS 对下比照复核合价, SUM(对下比照已完数量) AS 对下比照已完数量, FLOOR(SUM(对下比照已完合价)) 
                AS 对下比照已完合价, SUM(对上比照蓝图数量) AS 对上比照蓝图数量, FLOOR(SUM(对上比照蓝图合价)) 
                AS 对上比照蓝图合价, SUM(对上比照复核数量) AS 对上比照复核数量, FLOOR(SUM(对上比照复核合价)) 
                AS 对上比照复核合价, SUM(对上比照已完数量) AS 对上比照已完数量, FLOOR(SUM(对上比照已完合价)) 
                AS 对上比照已完合价
FROM      dbo.路基分析
GROUP BY 序号
ORDER BY ID

路基总计
SELECT   TOP (100) PERCENT FLOOR(MIN(ID) / 262 + 1) AS ID, MIN(里程桩号) AS 里程桩号, FLOOR(SUM(蓝图数量 * 清单单价)) 
                AS 蓝图设计总价, FLOOR(SUM(复核数量 * 清单单价)) AS 蓝图复核总价, FLOOR(SUM(已完数量 * 清单单价)) 
                AS 蓝图已完总价, FLOOR(SUM(对上合价)) AS 对上总价, FLOOR(SUM(对下合价)) AS 对下总价, 
                FLOOR(SUM(对下比照蓝图合价)) AS 对下比照蓝图总价, FLOOR(SUM(对下比照复核合价)) AS 对下比照复核总价, 
                FLOOR(SUM(对下比照已完合价)) AS 对下比照已完总价, FLOOR(SUM(对上比照蓝图合价)) AS 对上比照蓝图总价, 
                FLOOR(SUM(对上比照复核合价)) AS 对上比照复核总价, FLOOR(SUM(对上比照已完合价)) AS 对上比照已完总价
FROM      dbo.路基分析
GROUP BY 里程桩号
ORDER BY ID

tv_inbill
SELECT   dbo.tb_inbill.i_code, dbo.tb_inbill.n_bill AS i_bill, dbo.tb_storage.r_name AS i_storage, 
                dbo.tb_goods.g_shortname AS i_name, dbo.tb_goods.g_type AS i_type, dbo.tb_goods.g_standard AS i_standard, 
                dbo.tb_goods.g_produce AS i_produce, dbo.tb_goods.g_unit AS i_unit, dbo.tb_inbill.i_qty, dbo.tb_inbill.i_price, 
                dbo.tb_inbill.i_money, dbo.tb_inbill.i_info
FROM      dbo.tb_goods INNER JOIN
                dbo.tb_inbill ON dbo.tb_goods.g_code = dbo.tb_inbill.g_code INNER JOIN
                dbo.tb_storage ON dbo.tb_inbill.r_code = dbo.tb_storage.r_code

tv_instock                
SELECT   dbo.tb_instock.n_code, dbo.tb_instock.n_date, dbo.tb_instock.n_bill, dbo.tb_employee.e_name AS n_employee, 
                dbo.tb_units.u_name AS n_units, dbo.tb_instock.n_sumpay, dbo.tb_instock.n_realpay, dbo.tb_instock.n_info
FROM      dbo.tb_employee INNER JOIN
                dbo.tb_instock ON dbo.tb_employee.e_code = dbo.tb_instock.e_code INNER JOIN
                dbo.tb_units ON dbo.tb_instock.u_code = dbo.tb_units.u_code
GROUP BY dbo.tb_instock.n_code, dbo.tb_instock.n_date, dbo.tb_instock.n_bill, dbo.tb_employee.e_name, dbo.tb_units.u_name, 
                dbo.tb_instock.n_realpay, dbo.tb_instock.n_info, dbo.tb_instock.n_sumpay           
                
tv_outbill
SELECT   dbo.tb_outbill.o_code, dbo.tb_outbill.t_bill AS o_bill, dbo.tb_storage.r_name AS o_storage, 
                dbo.tb_goods.g_shortname AS o_name, dbo.tb_goods.g_type AS o_type, dbo.tb_goods.g_standard AS o_standard, 
                dbo.tb_goods.g_produce AS o_produce, dbo.tb_goods.g_unit AS o_unit, dbo.tb_outbill.o_qty, dbo.tb_outbill.o_price, 
                dbo.tb_outbill.o_money, dbo.tb_outbill.o_info
FROM      dbo.tb_goods INNER JOIN
                dbo.tb_outbill ON dbo.tb_goods.g_code = dbo.tb_outbill.g_code INNER JOIN
                dbo.tb_storage ON dbo.tb_outbill.r_code = dbo.tb_storage.r_code    
 
tv_outstock
SELECT   dbo.tb_outstock.t_code, dbo.tb_outstock.t_date, dbo.tb_outstock.t_bill, dbo.tb_units.u_name AS t_units, 
                dbo.tb_employee.e_name AS t_employee, dbo.tb_outstock.t_sumpay, dbo.tb_outstock.t_realpay, 
                dbo.tb_outstock.t_info
FROM      dbo.tb_employee INNER JOIN
                dbo.tb_outstock ON dbo.tb_employee.e_code = dbo.tb_outstock.e_code INNER JOIN
                dbo.tb_units ON dbo.tb_outstock.u_code = dbo.tb_units.u_code
                
tv_stock
SELECT   dbo.tb_stock.s_code, dbo.tb_storage.r_name AS s_storage, dbo.tb_goods.g_shortname AS s_name, 
                dbo.tb_goods.g_type AS s_type, dbo.tb_goods.g_standard AS s_standard, dbo.tb_goods.g_produce AS s_produce, 
                dbo.tb_goods.g_unit AS s_unit, dbo.tb_stock.s_qty, dbo.tb_stock.s_buyprice, dbo.tb_stock.s_aveprice, 
                dbo.tb_stock.s_saleprice, dbo.tb_stock.s_money, dbo.tb_stock.s_checkqty, dbo.tb_stock.s_upperlimit, 
                dbo.tb_stock.s_lowerlimit, dbo.tb_stock.s_info
FROM      dbo.tb_goods INNER JOIN
                dbo.tb_stock ON dbo.tb_goods.g_code = dbo.tb_stock.g_code INNER JOIN
                dbo.tb_storage ON dbo.tb_stock.r_code = dbo.tb_storage.r_code                                 