/*���ܣ��Զ����������ֶ�ֵ�Ĵ洢����*/
if exists(select name from sys.procedures where name = 'sp_tv_barn')
drop procedure sp_tv_barn
go
create procedure sp_tv_barn
as
begin
select b_code as �ֿ���, b_name as �ֿ�����, b_dateopen as ��������, b_dateclose as ��������, 
       b_place as �ֿ�ص�, b_linkman as ������, b_tel as ��ϵ�绰, b_state as �ֿ�״̬, b_info as ��ע��Ϣ
from tb_barn
order by �ֿ���
end

go
if exists(select name from sys.procedures where name = 'sp_tv_check')
drop procedure sp_tv_check
go
create procedure sp_tv_check
as
begin
select c_code as �̵���, c_date as �̵�����, b_code as �ֿ���, g_code as ������, 
       e_code as ְ�����, c_qtyplain as �ִ�����, c_qtycheck as �̵�����, c_qtyupper as �ִ�����, 
       c_qtylower as �ִ�����, c_info as ��ע��Ϣ
from tb_check
order by �̵���
end

go
if exists(select name from sys.procedures where name = 'sp_tv_employee')
drop procedure sp_tv_employee
go
create procedure sp_tv_employee
as
begin
select e_code as ְ�����, e_name as ְ������, e_sex as ְ���Ա�, e_place as ������ַ, 
       e_birth as ��������, e_dept as ��������, e_duty as ����ְ��, e_identity as ������ò, e_education as ѧ��, 
       e_college as ��ҵԺУ, e_profession as ְ��, e_tel as ��ϵ�绰, e_info as ְ����ע
from tb_employee
order by ְ�����
end

go
if exists(select name from sys.procedures where name = 'sp_tv_goods')
drop procedure sp_tv_goods
go
create procedure sp_tv_goods
as
begin
select g_code as ������, g_name as ��������, g_type as ��������, g_brand as ����Ʒ��, 
       g_standard as ����ͺ�, g_unit as ������λ, g_produce as ���س���, g_price as ����۸�, g_pricebudget as Ԥ��۸�, 
       g_pricesearch as ����۸�, g_pricecheck as �˶��۸�, g_method as �۾ɷ���, g_rate as ����ֵ��, 
       g_info as ��ע��Ϣ
from tb_goods
order by ������
end

go
if exists(select name from sys.procedures where name = 'sp_tv_instock')
drop procedure sp_tv_instock
go
create procedure sp_tv_instock
as
begin
select i_code as �����, i_date as �������, i_bill as ��ⵥ��, b_code as �ֿ���, 
       g_code as ������, u_code as ��λ���, e_code as ְ�����, p_code as ��ͬ���, i_qty as �������, 
       i_money as �����, i_payable as Ӧ�����, i_payout as ʵ�����, i_plant as �۾ɽ��, i_state as ����״̬, 
       i_place as ʹ�õص�, i_info as ��ע��Ϣ
from tb_instock
order by �����
end

go
if exists(select name from sys.procedures where name = 'sp_tv_mixstock')
drop procedure sp_tv_mixstock
go
create procedure sp_tv_mixstock
as
begin
select m_code as ������, m_date as ��������, m_bill as ���ⵥ��, m_barn as ��������, 
       b_code as �ֿ���, g_code as ������, u_code as ��λ���, e_code as ְ�����, p_code as ��ͬ���, 
       m_qty as ��������, m_money as ������, m_state as ����״̬, m_place as ʹ�õص�, m_info as ��ע��Ϣ
from tb_mixstock
order by ������
end

go
if exists(select name from sys.procedures where name = 'sp_tv_outstock')
drop procedure sp_tv_outstock
go
create procedure sp_tv_outstock
as
begin
select o_code as ������, o_date as ��������, o_bill as ���ⵥ��, b_code as �ֿ���, 
       g_code as ������, u_code as ��λ���, e_code as ְ�����, p_code as ��ͬ���, o_qty as ��������, 
       o_money as ������, o_payable as Ӧ�����, o_payout as ʵ�����, o_plant as �۾ɽ��, o_state as ����״̬, 
       o_place as ʹ�õص�, o_info as ��ע��Ϣ
from tb_outstock
order by ������
end

go
if exists(select name from sys.procedures where name = 'sp_tv_pact')
drop procedure sp_tv_pact
go
create procedure sp_tv_pact
as
begin
select p_code as ��ͬ���, p_date as ��������, p_number as ��ͬ����, p_name as ��ͬ����, 
       p_owner as �׷�����, p_party as �ҷ�����, p_info as ��ע��Ϣ
from tb_pact
order by ��ͬ���
end

go
if exists(select name from sys.procedures where name = 'sp_tv_retstock')
drop procedure sp_tv_retstock
go
create procedure sp_tv_retstock
as
begin
select r_code as �˿���, r_date as �˿�����, r_bill as �˿ⵥ��, b_code as �ֿ���, 
       g_code as ������, u_code as ��λ���, e_code as ְ�����, p_code as ��ͬ���, r_qty as �˿�����, 
       r_money as �˿���, r_payable as Ӧ�����, r_payout as ʵ�����, r_plant as �۾ɽ��, r_state as ����״̬, 
       r_place as ʹ�õص�, r_info as ��ע��Ϣ
from tb_retstock
order by �˿���
end

go
if exists(select name from sys.procedures where name = 'sp_tv_stock')
drop procedure sp_tv_stock
go
create procedure sp_tv_stock
as
begin
select s_code as �����, b_code as �ֿ���, g_code as ������, s_barn as �ֿ�����, 
       s_good as ��������, s_type as ��������, s_brand as ����Ʒ��, s_standard as ������, s_unit as ���赥λ, 
       s_produce as �������, s_qty as �ִ�����, s_price as ���赥��, s_money as �ִ����, s_pricebudget as Ԥ�㵥��, 
       s_moneybudget as Ԥ����, s_pricesearch as ���鵥��, s_moneysearch as ������, s_pricecheck as �̵㵥��, 
       s_moneycheck as �̵���, s_info as ��ע��Ϣ
from tb_stock
order by �����
end

go
if exists(select name from sys.procedures where name = 'sp_tv_units')
drop procedure sp_tv_units
go
create procedure sp_tv_units
as
begin
select u_code as ���̱��, u_name as ��������, u_type as ��Ӫ���, u_tax as ��˾����, 
       u_tel as ��˾�绰, u_address as ���̵�ַ, u_email as �����ַ, u_bank as ��������, u_account as �����˻�, 
       u_legalman as ��˾����, u_linkman as ��ϵ��, u_linktel as ��ϵ�绰, u_income as ���˽��, u_payout as ֧�����, 
       u_info as ��ע��Ϣ
from tb_units
order by ���̱��
end

go
if exists(select name from sys.procedures where name = 'sp_tv_users')
drop procedure sp_tv_users
go
create procedure sp_tv_users
as
begin
select id as �û����, sysuser as �û�����, password as �û�����, cip as �ͻ���IP, cport as �ͻ��˿�, 
       sip as ������IP, sport as �������˿�, state as �û�״̬, advanced as �û�Ȩ��, remberpwd as ��ס����, 
       autologin as �Զ���¼
from tb_users
order by �û����
end