·������
SELECT   TOP (100) PERCENT dbo.·������.ID, dbo.·������.������Ŀ, dbo.·������.��λ, dbo.·������.��ͼ�������, 
                dbo.·������.��ͼ�������, dbo.·������.�����������, dbo.·������.���˱������, dbo.·������.�����������, 
                dbo.·������.����������, dbo.·������.[01_�������] AS �����������, 
                dbo.·������.[01_�������] AS ���ϱ������, dbo.·������.[01_�������] AS �����������, 
                dbo.·������.[01_�������] AS ���±������, dbo.·������.��ͼ������� + dbo.·������.��ͼ������� AS ��ͼ����, 
                dbo.·������.����������� + dbo.·������.���˱������ AS ��������, 
                dbo.·������.����������� + dbo.·������.���������� AS ��������, 
                dbo.·������.[01_�������] + dbo.·������.[01_�������] AS ���ϼƼ�����, 
                dbo.·������.[01_�������] + dbo.·������.[01_�������] AS ���¼Ƽ�����, dbo.·������.���� AS �嵥����, 
                dbo.·������.���� AS ���񵥼�, dbo.·������.���, dbo.·������.���׮��
FROM      dbo.·������ INNER JOIN
                dbo.·������ ON dbo.·������.ID = dbo.·������.ID INNER JOIN
                dbo.·������ ON dbo.·������.ID = dbo.·������.ID
ORDER BY dbo.·������.ID

·������
SELECT   TOP (100) PERCENT ID, ������Ŀ, ��λ, ��ͼ����, ��������, ��������, ���ϼƼ�����, �嵥����, 
                FLOOR(���ϼƼ����� * �嵥����) AS ���Ϻϼ�, ���¼Ƽ�����, ���񵥼�, FLOOR(���¼Ƽ����� * ���񵥼�) 
                AS ���ºϼ�, ��ͼ���� - ���¼Ƽ����� AS ���±�����ͼ����, FLOOR((��ͼ���� - ���¼Ƽ�����) * ���񵥼�) 
                AS ���±�����ͼ�ϼ�, �������� - ���¼Ƽ����� AS ���±��ո�������, FLOOR((�������� - ���¼Ƽ�����) * ���񵥼�) 
                AS ���±��ո��˺ϼ�, �������� - ���¼Ƽ����� AS ���±�����������, FLOOR((�������� - ���¼Ƽ�����) * ���񵥼�) 
                AS ���±�������ϼ�, ��ͼ���� - ���ϼƼ����� AS ���ϱ�����ͼ����, FLOOR((��ͼ���� - ���ϼƼ�����) * �嵥����) 
                AS ���ϱ�����ͼ�ϼ�, �������� - ���ϼƼ����� AS ���ϱ��ո�������, FLOOR((�������� - ���ϼƼ�����) * �嵥����) 
                AS ���ϱ��ո��˺ϼ�, �������� - ���ϼƼ����� AS ���ϱ�����������, FLOOR((�������� - ���ϼƼ�����) * �嵥����) 
                AS ���ϱ�������ϼ�, ���, ���׮��
FROM      dbo.·������
ORDER BY ID

·������
SELECT   TOP (100) PERCENT MIN(���) AS ID, MIN(������Ŀ) AS ������Ŀ, MIN(��λ) AS ��λ, SUM(��ͼ����) AS ��ͼ����, 
                SUM(��������) AS ��������, SUM(��������) AS ��������, SUM(���ϼƼ�����) AS ���ϼƼ�����, MIN(�嵥����) 
                AS �嵥����, FLOOR(SUM(���Ϻϼ�)) AS ���Ϻϼ�, SUM(���¼Ƽ�����) AS ���¼Ƽ�����, MIN(���񵥼�) AS ���񵥼�, 
                FLOOR(SUM(���ºϼ�)) AS ���ºϼ�, SUM(���±�����ͼ����) AS ���±�����ͼ����, FLOOR(SUM(���±�����ͼ�ϼ�)) 
                AS ���±�����ͼ�ϼ�, SUM(���±��ո�������) AS ���±��ո�������, FLOOR(SUM(���±��ո��˺ϼ�)) 
                AS ���±��ո��˺ϼ�, SUM(���±�����������) AS ���±�����������, FLOOR(SUM(���±�������ϼ�)) 
                AS ���±�������ϼ�, SUM(���ϱ�����ͼ����) AS ���ϱ�����ͼ����, FLOOR(SUM(���ϱ�����ͼ�ϼ�)) 
                AS ���ϱ�����ͼ�ϼ�, SUM(���ϱ��ո�������) AS ���ϱ��ո�������, FLOOR(SUM(���ϱ��ո��˺ϼ�)) 
                AS ���ϱ��ո��˺ϼ�, SUM(���ϱ�����������) AS ���ϱ�����������, FLOOR(SUM(���ϱ�������ϼ�)) 
                AS ���ϱ�������ϼ�
FROM      dbo.·������
GROUP BY ���
ORDER BY ID

·���ܼ�
SELECT   TOP (100) PERCENT FLOOR(MIN(ID) / 262 + 1) AS ID, MIN(���׮��) AS ���׮��, FLOOR(SUM(��ͼ���� * �嵥����)) 
                AS ��ͼ����ܼ�, FLOOR(SUM(�������� * �嵥����)) AS ��ͼ�����ܼ�, FLOOR(SUM(�������� * �嵥����)) 
                AS ��ͼ�����ܼ�, FLOOR(SUM(���Ϻϼ�)) AS �����ܼ�, FLOOR(SUM(���ºϼ�)) AS �����ܼ�, 
                FLOOR(SUM(���±�����ͼ�ϼ�)) AS ���±�����ͼ�ܼ�, FLOOR(SUM(���±��ո��˺ϼ�)) AS ���±��ո����ܼ�, 
                FLOOR(SUM(���±�������ϼ�)) AS ���±��������ܼ�, FLOOR(SUM(���ϱ�����ͼ�ϼ�)) AS ���ϱ�����ͼ�ܼ�, 
                FLOOR(SUM(���ϱ��ո��˺ϼ�)) AS ���ϱ��ո����ܼ�, FLOOR(SUM(���ϱ�������ϼ�)) AS ���ϱ��������ܼ�
FROM      dbo.·������
GROUP BY ���׮��
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