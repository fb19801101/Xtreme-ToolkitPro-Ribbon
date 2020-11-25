sql日期按月份和年份分组查询
原创 2016年03月11日 13:53:08 11092
--以2013-12-10 12:56:55为例
--convert(nvarchar(10),CreateDate,120)      =>      2013-12-10
--DATEPART(month,CreateDate)      =>      12
--DATEPART(year,CreateDate)      =>      2013


--还可以这样
--年
select datepart(YEAR,'2013-06-08')
select datepart(yyyy,'2013-06-08')
select datepart(yy,'2013-06-08')
--月
select datepart(MONTH,'2013-06-08')
select datepart(mm,'2013-06-08')
select datepart(m,'2013-06-08')
--日
select datepart(dd,'2013-06-08')
--1年中的第多少天
select datepart(dy,'2013-06-08')
--季度
select datepart(qq,'2013-06-08')
--1年中的第多少周
select datepart(wk,'2013-06-08')
--星期
select datepart(dw,'2013-06-08')


SELECT CONVERT(VARCHAR(10),GETDATE(),120)  --2015-07-13
SELECT CONVERT(VARCHAR(10),GETDATE(),101)  --07/13/2015


--按日分组：2013-01-01
select convert(nvarchar(10),CreateDate,120) as Times,ISNULL(sum(Unit),0.0) as Drinking from pdt_Out
group by convert(nvarchar(10),CreateDate,120)
go


--按月分组：2012-01
select DATEPART(month,CreateDate) as Times,sum(Unit) as Totals from pdt_Out
group by DATEPART(month,CreateDate)
go


--按年分组：2013
select DATEPART(year,CreateDate) as Times,sum(Unit) as Totals from pdt_Out
group by DATEPART(year,CreateDate)
go