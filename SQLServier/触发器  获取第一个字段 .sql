use ProjectManage
go

--select * from sysobjects where xtype='TR'
if exists(select * from dbo.sysobjects where id = object_id(N'tr_income_insert') and type = 'TR')
drop trigger tr_income_insert
go
create trigger tr_income_insert on tv_income Instead of insert
as
begin
	update tb_finance set f_type='收入'
	from tb_finance,inserted
	where
	tb_finance.f_code=inserted.编号
end

go

if exists(select * from dbo.sysobjects where id = object_id(N'tr_outlay_insert') and type = 'TR')
drop trigger tr_outlay_insert
go
create trigger tr_outlay_insert on tv_outlay Instead of insert
as
begin
	update tb_finance set f_type='支出'
	from tb_finance,inserted
	where
	tb_finance.f_code=inserted.编号
end
go

if exists(select * from dbo.sysobjects where id = object_id(N'tr_outlay_insert') and type = 'TR')
drop trigger tr_outlay_insert
go
create trigger tr_outlay_insert on tb_outlay for insert
as
begin
	insert into tb_finance(p_code,p_date,f_code,m_code,p_qty,p_money,p_type,p_method)
	select inserted.o_code,inserted.o_date,inserted.f_code,inserted.m_code,inserted.o_qty,inserted.o_money
	,'支出',inserted.o_method from inserted
end
go

if exists(select * from dbo.sysobjects where id = object_id(N'tr_income_delete') and type = 'TR')
drop trigger tr_income_delete
go
create trigger tr_income_delete on tb_income for delete
as
begin
	delete from tb_finance where tb_finance.p_code in (select deleted.i_code from deleted)
end
go

if exists(select * from dbo.sysobjects where id = object_id(N'tr_outlay_update') and type = 'TR')
drop trigger tr_outlay_update
go
create trigger tr_outlay_update on tb_outlay for update
as
begin
	declare	@code varchar(10),@date date,@fcode varchar(5),
	@mcode varchar(5),@qty float,@money float,@method nvarchar(10)
	select @code=o_code,@date=o_date,@fcode=f_code,@mcode=m_code,
	@qty=o_qty,@money=o_money,@method=o_method from inserted

	update tb_finance set p_date=@date,f_code=@fcode,
	m_code=@mcode,p_qty=@qty,p_money=@money,p_method=@method
	where p_code=@code
end
go

if exists(select * from dbo.sysobjects where id = object_id(N'updateInStock') and type = 'TR')
drop trigger updateInStock
go
create trigger updateInStock on tb_instock for update
as
begin
declare @icode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @icode=i_code,@bcode=b_code,@gcode=g_code,@qty=i_qty from inserted
update [tb_stock] set b_code=@bcode,g_code=@gcode,s_qty=@qty where s_code=@icode
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'updateOutStock') and type = 'TR')
drop trigger updateOutStock
go
create trigger updateOutStock on tb_outstock for update
as
begin
declare @ocode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @ocode=o_code,@bcode=b_code,@gcode=g_code,@qty=o_qty from inserted
update [tb_stock] set b_code=@bcode,g_code=@gcode,s_qty=@qty where s_code=@ocode
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'updateMixStock') and type = 'TR')
drop trigger updateMixStock
go
create trigger updateMixStock on tb_mixstock for update
as
begin
declare @mcode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @mcode=m_code,@bcode=b_code,@gcode=g_code,@qty=m_qty from inserted
update [tb_stock] set b_code=@bcode,g_code=@gcode,s_qty=@qty where s_code=@mcode
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'updateRetStock') and type = 'TR')
drop trigger updateRetStock
go
create trigger updateRetStock on tb_retstock for update
as
begin
declare @rcode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @rcode=r_code,@bcode=b_code,@gcode=g_code,@qty=r_qty from inserted
update [tb_stock] set b_code=@bcode,g_code=@gcode,s_qty=@qty where s_code=@rcode
end

/*
go
if exists(select * from dbo.sysobjects where id = object_id(N'updateStock') and type = 'TR')
drop trigger updateStock
go
create trigger updateStock on tb_stock for update
as
begin
declare @code varchar(10)
declare @date date 
declare @rcode varchar(10)
declare @gcode varchar(10)
declare @ecode varchar(10)
declare @qtyin real
declare @qtyout real
declare @moneyin real
declare @moneyout real
select @code=s_code,@date=s_date,@rcode=r_code,@gcode=g_code,@ecode=e_code,@qtyin=s_qtyin,@qtyout=s_qtyout,@moneyin=s_moneyin,@moneyout=s_moneyout from inserted
update [tb_instock] set i_date=@date,r_code=@rcode,g_code=@gcode,e_code=@ecode,i_qty=@qtyin,i_price=@moneyin/@qtyin where i_code=@code
update [tb_outstock] set o_date=@date,r_code=@rcode,g_code=@gcode,e_code=@ecode,o_qty=@qtyout,o_price=@moneyout/@qtyout where o_code=@code
end
*/

go
if exists(select * from dbo.sysobjects where id = object_id(N'deleteInStock') and type = 'TR')
drop trigger deleteInStock
go
create trigger deleteInStock on tb_instock for delete
as
begin
declare @sql Nvarchar(100), @field Nvarchar(10),@val Nvarchar(10)
select @val=i_code from deleted
select @field=column_name from information_schema.columns where table_name='tb_stock' and ordinal_position=1
set @sql = N'delete from [tb_stock] where ['+@field+'] = ('''+@val+''')'
exec(@sql)
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'deleteOutStock') and type = 'TR')
drop trigger deleteOutStock
go
create trigger deleteOutStock on tb_outstock for delete
as
begin
declare @sql Nvarchar(100), @field Nvarchar(10),@val Nvarchar(10)
select @val=o_code from deleted
select @field=column_name from information_schema.columns where table_name='tb_stock' and ordinal_position=1
set @sql = N'delete from [tb_stock] where ['+@field+'] = ('''+@val+''')'
exec(@sql)
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'deleteMixStock') and type = 'TR')
drop trigger deleteMixStock
go
create trigger deleteMixStock on tb_mixstock for delete
as
begin
declare @sql Nvarchar(100), @field Nvarchar(10),@val Nvarchar(10)
select @val=m_code from deleted
select @field=column_name from information_schema.columns where table_name='tb_stock' and ordinal_position=1
set @sql = N'delete from [tb_stock] where ['+@field+'] = ('''+@val+''')'
exec(@sql)
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'deleteRetStock') and type = 'TR')
drop trigger deleteRetStock
go
create trigger deleteRetStock on tb_retstock for delete
as
begin
declare @sql Nvarchar(100), @field Nvarchar(10),@val Nvarchar(10)
select @val=r_code from deleted
select @field=column_name from information_schema.columns where table_name='tb_stock' and ordinal_position=1
set @sql = N'delete from [tb_stock] where ['+@field+'] = ('''+@val+''')'
exec(@sql)
end

/*
go
if exists(select * from dbo.sysobjects where id = object_id(N'deleteStock') and type = 'TR')
drop trigger deleteStock
go
create trigger deleteStock on tb_stock for delete
as
begin
declare @sql Nvarchar(100), @fieldin Nvarchar(10),@fieldout Nvarchar(10),@val Nvarchar(10)
select @val=s_code from deleted
select @fieldin=column_name from information_schema.columns where table_name='tb_instock' and ordinal_position=1
select @fieldout=column_name from information_schema.columns where table_name='tb_outstock' and ordinal_position=1
set @sql = N'delete from [tb_instock] where ['+@fieldin+'] = ('''+@val+''')'
exec(@sql)
set @sql = N'delete from [tb_outstock] where ['+@fieldout+'] = ('''+@val+''')'
exec(@sql)
end
*/

go
if exists(select * from dbo.sysobjects where id = object_id(N'InsertInStock') and type = 'TR')
drop trigger InsertInStock
go
create trigger InsertInStock on tb_instock for insert
as
begin
declare @icode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @icode=i_code,@bcode=b_code,@gcode=g_code,@qty=i_qty from inserted
insert into [tb_stock] (s_code,b_code,g_code,s_qty) values (@icode,@bcode,@gcode,@qty)
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'InsertOutStock') and type = 'TR')
drop trigger InsertOutStock
go
create trigger InsertOutStock on tb_outstock for insert
as
begin
declare @ocode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @ocode=o_code,@bcode=b_code,@gcode=g_code,@qty=o_qty from inserted
insert into [tb_stock] (s_code,b_code,g_code,s_qty) values (@ocode,@bcode,@gcode,@qty)
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'InsertMixStock') and type = 'TR')
drop trigger InsertMixStock
go
create trigger InsertMixStock on tb_mixstock for insert
as
begin
declare @mcode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @mcode=m_code,@bcode=b_code,@gcode=g_code,@qty=m_qty from inserted
insert into [tb_stock] (s_code,b_code,g_code,s_qty) values (@mcode,@bcode,@gcode,@qty)
end

go
if exists(select * from dbo.sysobjects where id = object_id(N'InsertRetStock') and type = 'TR')
drop trigger InsertRetStock
go
create trigger InsertRetStock on tb_retstock for insert
as
begin
declare @rcode varchar(10)
declare @bcode varchar(10)
declare @gcode varchar(10)
declare @qty float
select @rcode=r_code,@bcode=b_code,@gcode=g_code,@qty=r_qty from inserted
insert into [tb_stock] (s_code,b_code,g_code,s_qty) values (@rcode,@bcode,@gcode,@qty)
end

/*
go
if exists(select * from dbo.sysobjects where id = object_id(N'InsertStock') and type = 'TR')
drop trigger InsertStock
go
create trigger InsertStock on tb_stock for insert
as
begin
declare @code varchar(10)
declare @date date 
declare @rcode varchar(10)
declare @gcode varchar(10)
declare @ecode varchar(10)
declare @qtyin real
declare @qtyout real
declare @moneyin real
declare @moneyout real
select @code=s_code,@date=s_date,@rcode=r_code,@gcode=g_code,@ecode=e_code,@qtyin=s_qtyin,@qtyout=s_qtyout,@moneyin=s_moneyin,@moneyout=s_moneyout from inserted
insert into [tb_instock] (i_code,i_date,r_code,g_code,e_code,i_qty,i_price) values (@code,@date,@rcode,@gcode,@ecode,@qtyin,@moneyin/@qtyin)
insert into [tb_outstock] (o_code,o_date,r_code,g_code,e_code,o_qty,o_price) values (@code,@date,@rcode,@gcode,@ecode,@qtyout,@moneyout/@qtyout)
end
*/