use [ProjectManage]
go
create trigger [dbo].[tr_road_insert] on [dbo].[tb_road_qty] for insert
as
begin
	insert into tb_road_up(ru_code,pt_code,rl_code,lr_code,u_code,
	ru_qty_cur_design,ru_qty_cur_change)
	select inserted.rq_code,inserted.pt_code,inserted.rl_code,'LR001','U0001',
	inserted.rq_qty_doe_design,inserted.rq_qty_doe_change from inserted

	insert into tb_road_down(rd_code,pt_code,rl_code,lr_code,u_code,
	rd_qty_cur_design,rd_qty_cur_change)
	select inserted.rq_code,inserted.pt_code,inserted.rl_code,'LR001','U0001',
	inserted.rq_qty_doe_design,inserted.rq_qty_doe_change from inserted
end

go
create trigger [dbo].[tr_road_delete] on [dbo].[tb_road_qty] for delete
as
begin
	delete from tb_road_up where tb_road_up.ru_code=(select deleted.rq_code from deleted)
	delete from tb_road_down where tb_road_down.rd_code=(select deleted.rq_code from deleted)
end

go
create trigger [dbo].[tr_road_update] on [dbo].[tb_road_qty] for update
as
begin
	declare @code varchar(10),@point varchar(5),@ledger varchar(5),
	@doe_design float,@doe_change float
	select @code=rq_code,@point=pt_code,@ledger=rl_code,
	@doe_design=rq_qty_doe_design,@doe_change=rq_qty_doe_change from inserted

	update tb_road_up set pt_code=@point,rl_code=@ledger,
	ru_qty_cur_design=@doe_design,ru_qty_cur_change=@doe_change
	where ru_code=@code

	update tb_road_down set pt_code=@point,rl_code=@ledger,
	rd_qty_cur_design=@doe_design,rd_qty_cur_change=@doe_change
	where rd_code=@code
end

go
create trigger [dbo].[tr_bridge_insert] on [dbo].[tb_bridge_qty] for insert
as
begin
	insert into tb_bridge_up(bu_code,pt_code,bl_code,lr_code,u_code,
	bu_qty_cur_design,bu_qty_cur_change)
	select inserted.bq_code,inserted.pt_code,inserted.bl_code,'LR001','U0001',
	inserted.bq_qty_doe_design,inserted.bq_qty_doe_change from inserted

	insert into tb_bridge_down(bd_code,pt_code,bl_code,lr_code,u_code,
	bd_qty_cur_design,bd_qty_cur_change)
	select inserted.bq_code,inserted.pt_code,inserted.bl_code,'LR001','U0001',
	inserted.bq_qty_doe_design,inserted.bq_qty_doe_change from inserted
end

go
create trigger [dbo].[tr_bridge_delete] on [dbo].[tb_bridge_qty] for delete
as
begin
	delete from tb_bridge_up where tb_bridge_up.bu_code=(select deleted.bq_code from deleted)
	delete from tb_bridge_down where tb_bridge_down.bd_code=(select deleted.bq_code from deleted)
end

go
create trigger [dbo].[tr_bridge_update] on [dbo].[tb_bridge_qty] for update
as
begin
	declare @code varchar(10),@point varchar(5),@ledger varchar(5),
	@doe_design float,@doe_change float
	select @code=bq_code,@point=pt_code,@ledger=bl_code,
	@doe_design=bq_qty_doe_design,@doe_change=bq_qty_doe_change from inserted

	update tb_bridge_up set pt_code=@point,bl_code=@ledger,
	bu_qty_cur_design=@doe_design,bu_qty_cur_change=@doe_change
	where bu_code=@code

	update tb_bridge_down set pt_code=@point,bl_code=@ledger,
	bd_qty_cur_design=@doe_design,bd_qty_cur_change=@doe_change
	where bd_code=@code
end

go
create trigger [dbo].[tr_orbital_insert] on [dbo].[tb_orbital_qty] for insert
as
begin
	insert into tb_orbital_up(ou_code,pt_code,ol_code,lr_code,u_code,
	ou_qty_cur_design,ou_qty_cur_change)
	select inserted.oq_code,inserted.pt_code,inserted.ol_code,'LR001','U0001',
	inserted.oq_qty_doe_design,inserted.oq_qty_doe_change from inserted

	insert into tb_orbital_down(od_code,pt_code,ol_code,lr_code,u_code,
	od_qty_cur_design,od_qty_cur_change)
	select inserted.oq_code,inserted.pt_code,inserted.ol_code,'LR001','U0001',
	inserted.oq_qty_doe_design,inserted.oq_qty_doe_change from inserted
end

go
create trigger [dbo].[tr_orbital_delete] on [dbo].[tb_orbital_qty] for delete
as
begin
	delete from tb_orbital_up where tb_orbital_up.ou_code=(select deleted.oq_code from deleted)
	delete from tb_orbital_down where tb_orbital_down.od_code=(select deleted.oq_code from deleted)
end

go
create trigger [dbo].[tr_orbital_update] on [dbo].[tb_orbital_qty] for update
as
begin
	declare @code varchar(10),@point varchar(5),@ledger varchar(5),
	@doe_design float,@doe_change float
	select @code=oq_code,@point=pt_code,@ledger=ol_code,
	@doe_design=oq_qty_doe_design,@doe_change=oq_qty_doe_change from inserted

	update tb_orbital_up set pt_code=@point,ol_code=@ledger,
	ou_qty_cur_design=@doe_design,ou_qty_cur_change=@doe_change
	where ou_code=@code

	update tb_orbital_down set pt_code=@point,ol_code=@ledger,
	od_qty_cur_design=@doe_design,od_qty_cur_change=@doe_change
	where od_code=@code
end

go
create trigger [dbo].[tr_tunnel_insert] on [dbo].[tb_tunnel_qty] for insert
as
begin
	insert into tb_tunnel_up(tu_code,pt_code,tl_code,lr_code,u_code,
	tu_qty_cur_design,tu_qty_cur_change)
	select inserted.tq_code,inserted.pt_code,inserted.tl_code,'LR001','U0001',
	inserted.tq_qty_doe_design,inserted.tq_qty_doe_change from inserted

	insert into tb_tunnel_down(td_code,pt_code,tl_code,lr_code,u_code,
	td_qty_cur_design,td_qty_cur_change)
	select inserted.tq_code,inserted.pt_code,inserted.tl_code,'LR001','U0001',
	inserted.tq_qty_doe_design,inserted.tq_qty_doe_change from inserted
end

go
create trigger [dbo].[tr_tunnel_delete] on [dbo].[tb_tunnel_qty] for delete
as
begin
	delete from tb_tunnel_up where tb_tunnel_up.tu_code=(select deleted.tq_code from deleted)
	delete from tb_tunnel_down where tb_tunnel_down.td_code=(select deleted.tq_code from deleted)
end

go
create trigger [dbo].[tr_tunnel_update] on [dbo].[tb_tunnel_qty] for update
as
begin
	declare @code varchar(10),@point varchar(5),@ledger varchar(5),
	@doe_design float,@doe_change float
	select @code=tq_code,@point=pt_code,@ledger=tl_code,
	@doe_design=tq_qty_doe_design,@doe_change=tq_qty_doe_change from inserted

	update tb_tunnel_up set pt_code=@point,tl_code=@ledger,
	tu_qty_cur_design=@doe_design,tu_qty_cur_change=@doe_change
	where tu_code=@code

	update tb_tunnel_down set pt_code=@point,tl_code=@ledger,
	td_qty_cur_design=@doe_design,td_qty_cur_change=@doe_change
	where td_code=@code
end

go
create trigger [dbo].[tr_yard_insert] on [dbo].[tb_yard_qty] for insert
as
begin
	insert into tb_yard_up(yu_code,pt_code,yl_code,lr_code,u_code,
	yu_qty_cur_design,yu_qty_cur_change)
	select inserted.yq_code,inserted.pt_code,inserted.yl_code,'LR001','U0001',
	inserted.yq_qty_doe_design,inserted.yq_qty_doe_change from inserted

	insert into tb_yard_down(yd_code,pt_code,yl_code,lr_code,u_code,
	yd_qty_cur_design,yd_qty_cur_change)
	select inserted.yq_code,inserted.pt_code,inserted.yl_code,'LR001','U0001',
	inserted.yq_qty_doe_design,inserted.yq_qty_doe_change from inserted
end

go
create trigger [dbo].[tr_yard_delete] on [dbo].[tb_yard_qty] for delete
as
begin
	delete from tb_yard_up where tb_yard_up.yu_code=(select deleted.yq_code from deleted)
	delete from tb_yard_down where tb_yard_down.yd_code=(select deleted.yq_code from deleted)
end
GO
create trigger [dbo].[tr_yard_update] on [dbo].[tb_yard_qty] for update
as
begin
	declare @code varchar(10),@point varchar(5),@ledger varchar(5),
	@doe_design float,@doe_change float
	select @code=yq_code,@point=pt_code,@ledger=yl_code,
	@doe_design=yq_qty_doe_design,@doe_change=yq_qty_doe_change from inserted

	update tb_yard_up set pt_code=@point,yl_code=@ledger,
	yu_qty_cur_design=@doe_design,yu_qty_cur_change=@doe_change
	where yu_code=@code

	update tb_yard_down set pt_code=@point,yl_code=@ledger,
	yd_qty_cur_design=@doe_design,yd_qty_cur_change=@doe_change
	where yd_code=@code
end

USE [ProjectManage]
go
create trigger [dbo].[tr_temp_insert] on [dbo].[tb_temp_qty] for insert
as
begin
	insert into tb_temp_up(pu_code,pt_code,pl_code,lr_code,u_code,
	pu_qty_cur_design,pu_qty_cur_change)
	select inserted.pq_code,inserted.pt_code,inserted.pl_code,'LR001','U0001',
	inserted.pq_qty_doe_design,inserted.pq_qty_doe_change from inserted

	insert into tb_temp_down(pd_code,pt_code,pl_code,lr_code,u_code,
	pd_qty_cur_design,pd_qty_cur_change)
	select inserted.pq_code,inserted.pt_code,inserted.pl_code,'LR001','U0001',
	inserted.pq_qty_doe_design,inserted.pq_qty_doe_change from inserted
end

go
create trigger [dbo].[tr_temp_delete] on [dbo].[tb_temp_qty] for delete
as
begin
	delete from tb_temp_up where tb_temp_up.pu_code in (select deleted.pq_code from deleted)
	delete from tb_temp_down where tb_temp_down.pd_code in (select deleted.pq_code from deleted)
end

go
create trigger [dbo].[tr_temp_update] on [dbo].[tb_temp_qty] for update
as
begin
	declare @code varchar(10),@point varchar(5),@ledger varchar(5),
	@doe_design float,@doe_change float
	select @code=pq_code,@point=pt_code,@ledger=pl_code,
	@doe_design=pq_qty_doe_design,@doe_change=pq_qty_doe_change from inserted

	update tb_temp_up set pt_code=@point,pl_code=@ledger,
	pu_qty_cur_design=@doe_design,pu_qty_cur_change=@doe_change
	where pu_code=@code

	update tb_temp_down set pt_code=@point,pl_code=@ledger,
	pd_qty_cur_design=@doe_design,pd_qty_cur_change=@doe_change
	where pd_code=@code
end

go
create trigger [dbo].[tr_outlay_insert] on [dbo].[tb_outlay] for insert
as
begin
	insert into tb_finance(p_code,p_date,f_code,m_code,p_qty,p_money,p_type,p_method)
	select inserted.o_code,inserted.o_date,inserted.f_code,inserted.m_code,inserted.o_qty,inserted.o_money
	,'支出',inserted.o_method from inserted
end

go
create trigger [dbo].[tr_outlay_delete] on [dbo].[tb_outlay] for delete
as
begin
	delete from tb_finance where tb_finance.p_code in (select deleted.o_code from deleted)
end

go
create trigger [dbo].[tr_outlay_update] on [dbo].[tb_outlay] for update
as
begin
	declare	@code varchar(10),@date date,@fcode varchar(5),@price float,
	@mcode varchar(5),@qty float,@money float,@method nvarchar(10),@info nvarchar(40)

	select @code=o_code,@date=o_date,@fcode=f_code,@mcode=m_code,
	       @qty=o_qty,@method=o_method,@info=o_info from inserted
	select @price=f_price from tb_funds where f_code = @fcode

	update tb_outlay set @money=o_money=@price*@qty where o_code = @code and f_code = @fcode
	update tb_finance set p_date=@date,f_code=@fcode,
	m_code=@mcode,p_qty=@qty,p_money=@money,p_method=@method,p_info=@info
	where p_code=@code
end

go
create trigger [dbo].[tr_income_insert] on [dbo].[tb_income] for insert
as
begin
	insert into tb_finance(p_code,p_date,f_code,m_code,p_qty,p_money,p_type,p_method)
	select inserted.i_code,inserted.i_date,inserted.f_code,inserted.m_code,inserted.i_qty,inserted.i_money
	,'收入',inserted.i_method from inserted
end

go
create trigger [dbo].[tr_income_delete] on [dbo].[tb_income] for delete
as
begin
	delete from tb_finance where tb_finance.p_code in (select deleted.i_code from deleted)
end

go
create trigger [dbo].[tr_income_update] on [dbo].[tb_income] for update
as
begin
	declare	@code varchar(10),@date date,@fcode varchar(5),@price float,
	@mcode varchar(5),@qty float,@money float,@method nvarchar(10),@info nvarchar(40)

	select @code=i_code,@date=i_date,@fcode=f_code,@mcode=m_code,
	       @qty=i_qty,@method=i_method,@info=i_info from inserted
	select @price=f_price from tb_funds where f_code = @fcode

	update tb_income set @money=i_money=@price*@qty where i_code = @code and f_code = @fcode
	update tb_finance set p_date=@date,f_code=@fcode,
	m_code=@mcode,p_qty=@qty,p_money=@money,p_method=@method,p_info=@info
	where p_code = @code
end

go
create trigger [dbo].[tr_funds_update] on [dbo].[tb_funds] for update
as
begin
	declare	@code varchar(5),@price float
	select @code=f_code,@price=f_price from inserted

	update tb_income set i_money=@price*i_qty where f_code = @code
	update tb_outlay set o_money=@price*o_qty where f_code = @code
end

go
create trigger [dbo].[tr_funds_delete] on [dbo].[tb_funds] for delete
as
begin
	delete from tb_income where tb_income.f_code in (select deleted.f_code from deleted)
	delete from tb_outlay where tb_outlay.f_code in (select deleted.f_code from deleted)
end

go
create trigger [dbo].[tr_budget_insert] on [dbo].[tb_budget] for insert
as
begin
	insert into tb_budget_bak(bg_id,ct_code,bg_code,gd_name,gd_unit,bg_rate,bg_qty,gd_price,bg_money,bg_sort,bg_info)
	select * from inserted

	declare @id varchar(20),@_code varchar(20),
	@qty float
	select @id=inserted.bg_id,@_code=inserted.bg_code,@qty = inserted.bg_qty from inserted

	if @_code is not null
	begin
		declare @code varchar(20),@name nvarchar(100),@unit nvarchar(10),
		@label char(3),
		@price float,@rate float
		select @code=tb_guidance.gd_code,
		@label=tb_guidance.gd_label,
		@name=tb_guidance.gd_name,
		@unit=tb_guidance.gd_unit,
		@rate=tb_guidance.gd_rate,
		@price=tb_guidance.gd_price
		from tb_guidance where tb_guidance.bg_code = @_code

		set @qty = @qty * case when @qty = 0 then 1 else @rate end
	
		update tb_budget_bak set gd_code=@code,gd_label=@label,gd_name=@name,gd_unit=@unit,bg_qty=@qty,gd_price=@price,bg_money=@qty*@price
		where tb_budget_bak.bg_id=@id
	end
end

go
create trigger [dbo].[tr_budget_delete] on [dbo].[tb_budget] for delete
as
begin
	delete from tb_budget_bak where tb_budget_bak.bg_id in (select deleted.bg_id from deleted)
	delete from tb_budget_rep where tb_budget_rep.bg_id in (select deleted.bg_id from deleted)
end

go
create trigger [dbo].[tr_budget_bak_insert] on [dbo].[tb_budget_bak] for insert
as
begin
	declare @bgid varchar(20),@budget float,
	@dwg_design float,@dwg_change float,@chk_design float,@chk_change float,@act_design float,@act_change float,
	@do_design float,@do_change float,@up_design float,@up_change float,@down_design float,@down_change float
	
	select @bgid=inserted.bg_id from inserted
	
	select @budget=qy_budget,
	@dwg_design=qy_dwg_design,@dwg_change=qy_dwg_change,
	@chk_design=qy_chk_design,@chk_change=qy_chk_change,
	@act_design=qy_act_design,@act_change=qy_act_change,
	@do_design=qy_do_design,@do_change=qy_do_change,
	@up_design=qy_up_design,@up_change=qy_up_change,
	@down_design=qy_down_design,@down_change=qy_down_change
  from tb_quantity_sum where bg_id=@bgid

	if @bgid is not null
	begin
		update tb_budget_bak set qy_budget=@budget,
		qy_dwg_design=@dwg_design,qy_dwg_change=@dwg_change,
		qy_chk_design=@chk_design,qy_chk_change=@chk_change,
		qy_act_design=@act_design,qy_act_change=@act_change,
		qy_do_design=@do_design,qy_do_change=@do_change,
		qy_up_design=@up_design,qy_up_change=@up_change,
		qy_down_design=@down_design,qy_down_change=@down_change
		where bg_id=@bgid
	end
end

go
Create trigger [dbo].[tr_quantity_delete] on [dbo].[tb_quantity] for delete
as
begin
	delete from tb_quantity_sum where tb_quantity_sum.bg_id in (select deleted.bg_id from deleted)
end

go
create trigger [dbo].[tr_quantity_sum_insert] on [dbo].[tb_quantity_sum] for insert
as
begin
	/*
	declare @bgid varchar(20),
	@do_design float,@do_change float,@up_design float,@up_change float,@down_design float,@down_change float
	
	select @bgid=inserted.bg_id from inserted
	
	select @do_design=qy_do_design,@do_change=qy_do_change,
	@up_design=qy_up_design,@up_change=qy_up_change,
	@down_design=qy_down_design,@down_change=qy_down_change
  from tp_quantity_sum where bg_id=@bgid

	if @bgid is not null
	begin
		update tb_quantity_sum set qy_do_design=@do_design,qy_do_change=@do_change,
		qy_up_design=@up_design,qy_up_change=@up_change,
		qy_down_design=@down_design,qy_down_change=@down_change
		where bg_id=@bgid
	end
	*/
	
	update A set
	A.qy_do_design=B.qy_do_design,A.qy_do_change=B.qy_do_change,
	A.qy_up_design=B.qy_up_design,A.qy_up_change=B.qy_up_change,
	A.qy_down_design=B.qy_down_design,A.qy_down_change=B.qy_down_change from tb_quantity_sum A
	left join tp_quantity_sum B on A.bg_id=B.bg_id
end

go
create trigger [dbo].[tr_sys_steel_qty_insert] on [dbo].[tb_sys_steel_qty] for insert
as
begin
	insert into tb_sys_steel_library(ssl_id,ssl_code,ssl_describe,ssl_number,ssl_type,ssl_diameter,ssl_len_single,ssl_count,ssl_len_total,ssl_mg_single,ssl_mg_total,ssl_info)
	select ssq_id,ssl_code,ssl_describe,ssq_number,ssq_type,ssq_diameter,ssq_len_single,ssq_count,ssq_len_total,ssq_mg_single,ssq_mg_total,ssq_info from inserted
end

go
Create trigger [dbo].[tr_sys_steel_qty_delete] on [dbo].[tb_sys_steel_qty] for delete
as
begin
	delete from tb_sys_steel_library where tb_sys_steel_library.ssl_code in (select deleted.ssl_code from deleted)
end
