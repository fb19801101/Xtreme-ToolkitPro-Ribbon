sql���ڰ��·ݺ���ݷ����ѯ
ԭ�� 2016��03��11�� 13:53:08 11092
--��2013-12-10 12:56:55Ϊ��
--convert(nvarchar(10),CreateDate,120)      =>      2013-12-10
--DATEPART(month,CreateDate)      =>      12
--DATEPART(year,CreateDate)      =>      2013


--����������
--��
select datepart(YEAR,'2013-06-08')
select datepart(yyyy,'2013-06-08')
select datepart(yy,'2013-06-08')
--��
select datepart(MONTH,'2013-06-08')
select datepart(mm,'2013-06-08')
select datepart(m,'2013-06-08')
--��
select datepart(dd,'2013-06-08')
--1���еĵڶ�����
select datepart(dy,'2013-06-08')
--����
select datepart(qq,'2013-06-08')
--1���еĵڶ�����
select datepart(wk,'2013-06-08')
--����
select datepart(dw,'2013-06-08')


SELECT CONVERT(VARCHAR(10),GETDATE(),120)  --2015-07-13
SELECT CONVERT(VARCHAR(10),GETDATE(),101)  --07/13/2015


--���շ��飺2013-01-01
select convert(nvarchar(10),CreateDate,120) as Times,ISNULL(sum(Unit),0.0) as Drinking from pdt_Out
group by convert(nvarchar(10),CreateDate,120)
go


--���·��飺2012-01
select DATEPART(month,CreateDate) as Times,sum(Unit) as Totals from pdt_Out
group by DATEPART(month,CreateDate)
go


--������飺2013
select DATEPART(year,CreateDate) as Times,sum(Unit) as Totals from pdt_Out
group by DATEPART(year,CreateDate)
go