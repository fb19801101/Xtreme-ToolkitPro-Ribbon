use ProjectManage
go
insert into tb_stock (s_code) values ('S0001')
go
update tb_stock set 
tb_stock.s_date = tv_instock.入库日期, 
tb_stock.s_storage = tv_instock.仓库名称, 
tb_stock.s_goods = tv_instock.物设名称, 
tb_stock.s_units = tv_instock.供应商, 
tb_stock.s_employee = tv_instock.负责人, 
tb_stock.s_pact = tv_instock.物设合同, 
tb_stock.s_state = tv_instock.物设状态, 
tb_stock.s_place = tv_instock.使用地点, 
tb_stock.s_qty = tv_instock.计量数量, 
tb_stock.s_price = tv_instock.计量单价, 
tb_stock.s_money = tv_instock.计量金额, 
tb_stock.s_plant = tv_instock.折旧金额
from tb_stock,tv_instock
where tb_stock.s_bill = tv_instock.入库单号