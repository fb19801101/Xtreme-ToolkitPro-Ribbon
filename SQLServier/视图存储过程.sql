/*功能：自动生成自增字段值的存储过程*/
if exists(select name from sys.procedures where name = 'sp_tv_barn')
drop procedure sp_tv_barn
go
create procedure sp_tv_barn
as
begin
select b_code as 仓库编号, b_name as 仓库名称, b_dateopen as 建库日期, b_dateclose as 销库日期, 
       b_place as 仓库地点, b_linkman as 负责人, b_tel as 联系电话, b_state as 仓库状态, b_info as 备注信息
from tb_barn
order by 仓库编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_check')
drop procedure sp_tv_check
go
create procedure sp_tv_check
as
begin
select c_code as 盘点编号, c_date as 盘点日期, b_code as 仓库编号, g_code as 物设编号, 
       e_code as 职工编号, c_qtyplain as 仓储数量, c_qtycheck as 盘点数量, c_qtyupper as 仓储上限, 
       c_qtylower as 仓储下限, c_info as 备注信息
from tb_check
order by 盘点编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_employee')
drop procedure sp_tv_employee
go
create procedure sp_tv_employee
as
begin
select e_code as 职工编号, e_name as 职工姓名, e_sex as 职工性别, e_place as 工作地址, 
       e_birth as 出生年月, e_dept as 所属部门, e_duty as 部门职务, e_identity as 政治面貌, e_education as 学历, 
       e_college as 毕业院校, e_profession as 职称, e_tel as 联系电话, e_info as 职工备注
from tb_employee
order by 职工编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_goods')
drop procedure sp_tv_goods
go
create procedure sp_tv_goods
as
begin
select g_code as 物设编号, g_name as 物设名称, g_type as 物设类型, g_brand as 物设品牌, 
       g_standard as 规格型号, g_unit as 计量单位, g_produce as 产地厂商, g_price as 物设价格, g_pricebudget as 预算价格, 
       g_pricesearch as 调查价格, g_pricecheck as 核定价格, g_method as 折旧方法, g_rate as 净现值率, 
       g_info as 备注信息
from tb_goods
order by 物设编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_instock')
drop procedure sp_tv_instock
go
create procedure sp_tv_instock
as
begin
select i_code as 入库编号, i_date as 入库日期, i_bill as 入库单号, b_code as 仓库编号, 
       g_code as 物设编号, u_code as 单位编号, e_code as 职工编号, p_code as 合同编号, i_qty as 入库数量, 
       i_money as 入库金额, i_payable as 应付金额, i_payout as 实付金额, i_plant as 折旧金额, i_state as 物设状态, 
       i_place as 使用地点, i_info as 备注信息
from tb_instock
order by 入库编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_mixstock')
drop procedure sp_tv_mixstock
go
create procedure sp_tv_mixstock
as
begin
select m_code as 调库编号, m_date as 调库日期, m_bill as 调库单号, m_barn as 调库名称, 
       b_code as 仓库编号, g_code as 物设编号, u_code as 单位编号, e_code as 职工编号, p_code as 合同编号, 
       m_qty as 调库数量, m_money as 调库金额, m_state as 物设状态, m_place as 使用地点, m_info as 备注信息
from tb_mixstock
order by 调库编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_outstock')
drop procedure sp_tv_outstock
go
create procedure sp_tv_outstock
as
begin
select o_code as 出库编号, o_date as 出库日期, o_bill as 出库单号, b_code as 仓库编号, 
       g_code as 物设编号, u_code as 单位编号, e_code as 职工编号, p_code as 合同编号, o_qty as 出库数量, 
       o_money as 出库金额, o_payable as 应付金额, o_payout as 实付金额, o_plant as 折旧金额, o_state as 物设状态, 
       o_place as 使用地点, o_info as 备注信息
from tb_outstock
order by 出库编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_pact')
drop procedure sp_tv_pact
go
create procedure sp_tv_pact
as
begin
select p_code as 合同编号, p_date as 订立日期, p_number as 合同代号, p_name as 合同名称, 
       p_owner as 甲方代表, p_party as 乙方代表, p_info as 备注信息
from tb_pact
order by 合同编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_retstock')
drop procedure sp_tv_retstock
go
create procedure sp_tv_retstock
as
begin
select r_code as 退库编号, r_date as 退库日期, r_bill as 退库单号, b_code as 仓库编号, 
       g_code as 物设编号, u_code as 单位编号, e_code as 职工编号, p_code as 合同编号, r_qty as 退库数量, 
       r_money as 退库金额, r_payable as 应付金额, r_payout as 实付金额, r_plant as 折旧金额, r_state as 物设状态, 
       r_place as 使用地点, r_info as 备注信息
from tb_retstock
order by 退库编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_stock')
drop procedure sp_tv_stock
go
create procedure sp_tv_stock
as
begin
select s_code as 库存编号, b_code as 仓库编号, g_code as 物设编号, s_barn as 仓库名称, 
       s_good as 物设名称, s_type as 物设类型, s_brand as 物设品牌, s_standard as 物设规格, s_unit as 物设单位, 
       s_produce as 物设产地, s_qty as 仓储数量, s_price as 物设单价, s_money as 仓储金额, s_pricebudget as 预算单价, 
       s_moneybudget as 预算金额, s_pricesearch as 调查单价, s_moneysearch as 调查金额, s_pricecheck as 盘点单价, 
       s_moneycheck as 盘点金额, s_info as 备注信息
from tb_stock
order by 库存编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_units')
drop procedure sp_tv_units
go
create procedure sp_tv_units
as
begin
select u_code as 厂商编号, u_name as 厂商名称, u_type as 经营类别, u_tax as 公司传真, 
       u_tel as 公司电话, u_address as 厂商地址, u_email as 邮箱地址, u_bank as 开户银行, u_account as 银行账户, 
       u_legalman as 公司法人, u_linkman as 联系人, u_linktel as 联系电话, u_income as 入账金额, u_payout as 支出金额, 
       u_info as 备注信息
from tb_units
order by 厂商编号
end

go
if exists(select name from sys.procedures where name = 'sp_tv_users')
drop procedure sp_tv_users
go
create procedure sp_tv_users
as
begin
select id as 用户编号, sysuser as 用户名称, password as 用户密码, cip as 客户端IP, cport as 客户端口, 
       sip as 服务器IP, sport as 服务器端口, state as 用户状态, advanced as 用户权限, remberpwd as 记住密码, 
       autologin as 自动登录
from tb_users
order by 用户编号
end