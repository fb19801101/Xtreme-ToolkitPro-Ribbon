use ProjectManage
go
insert into tb_stock (s_code) values ('S0001')
go
update tb_stock set 
tb_stock.s_date = tv_instock.�������, 
tb_stock.s_storage = tv_instock.�ֿ�����, 
tb_stock.s_goods = tv_instock.��������, 
tb_stock.s_units = tv_instock.��Ӧ��, 
tb_stock.s_employee = tv_instock.������, 
tb_stock.s_pact = tv_instock.�����ͬ, 
tb_stock.s_state = tv_instock.����״̬, 
tb_stock.s_place = tv_instock.ʹ�õص�, 
tb_stock.s_qty = tv_instock.��������, 
tb_stock.s_price = tv_instock.��������, 
tb_stock.s_money = tv_instock.�������, 
tb_stock.s_plant = tv_instock.�۾ɽ��
from tb_stock,tv_instock
where tb_stock.s_bill = tv_instock.��ⵥ��