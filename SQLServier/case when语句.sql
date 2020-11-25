SELECT   ROW_NUMBER() OVER (ORDER BY ������) AS ���, MIN(��������) AS ��������, ������, MIN(�յ����) 
AS �յ����, MIN(�������) AS �������, MIN(��·����) AS ��·����, MIN(��������) AS ��������, 
COUNT(CASE WHEN ����ƫ�� >= 4 OR ����ƫ�� <= -4 THEN ����ƫ�� END) AS [����ƫ���4;��-4],
COUNT(CASE WHEN ����ƫ�� < 4 AND ����ƫ�� > -4 THEN ����ƫ�� END) AS [����ƫ�-4_��4],
COUNT(CASE WHEN �߳�ƫ�� >= 4 THEN �߳�ƫ�� END) AS [�߳�ƫ���4],
COUNT(CASE WHEN �߳�ƫ�� < 4 AND �߳�ƫ�� > 3 THEN �߳�ƫ�� END) AS [�߳�ƫ�3_��4],
COUNT(CASE WHEN �߳�ƫ�� <= 3 THEN �߳�ƫ�� END) AS [�߳�ƫ���3],
COUNT(CASE WHEN ���ں���ƽ˳�� >= 4 OR ���ں���ƽ˳�� <= -4 THEN ���ں���ƽ˳�� END) AS [���ں���ƽ˳�ԡ�4;��-4], 
COUNT(CASE WHEN ���ں���ƽ˳�� < 4 AND ���ں���ƽ˳�� > -4 THEN ���ں���ƽ˳�� END) AS [���ں���ƽ˳�ԣ�-4_��4],
COUNT(CASE WHEN ���ڸ߳�ƽ˳�� >= 4 THEN ���ڸ߳�ƽ˳�� END) AS [���ڸ߳�ƽ˳�ԡ�4],
COUNT(CASE WHEN ���ڸ߳�ƽ˳�� < 4 AND ���ڸ߳�ƽ˳�� > 3 THEN ���ڸ߳�ƽ˳�� END) AS [���ڸ߳�ƽ˳�ԣ�3_��4],
COUNT(CASE WHEN ���ڸ߳�ƽ˳�� <= 3 THEN ���ڸ߳�ƽ˳�� END) AS [���ڸ߳�ƽ˳�ԡ�3],
COUNT(CASE WHEN ������ƽ˳�� >= 4 OR ������ƽ˳�� <= -4 THEN ������ƽ˳�� END) AS [������ƽ˳�ԡ�4;��-4], 
COUNT(CASE WHEN ������ƽ˳�� < 4 AND ������ƽ˳�� > -4 THEN ������ƽ˳�� END) AS [������ƽ˳�ԣ�-4_��4], 
COUNT(CASE WHEN ���߳�ƽ˳�� >= 4 THEN ���߳�ƽ˳�� END) AS [���߳�ƽ˳�ԡ�4],
COUNT(CASE WHEN ���߳�ƽ˳�� < 4 AND ���߳�ƽ˳�� > 3 THEN ���߳�ƽ˳�� END) AS [���߳�ƽ˳�ԣ�3_��4],
COUNT(CASE WHEN ���߳�ƽ˳�� <= 3 THEN ���߳�ƽ˳�� END) AS [���߳�ƽ˳�ԡ�3]
FROM      dbo.tp_retest_orbit_sum
GROUP BY ������





SELECT   ROW_NUMBER() OVER (ORDER BY code) AS ���, name AS ��������, bstat AS ������, estat AS �յ����, 
cstat AS �������, len AS ��·����, count AS ��������, mask AS ������, mileage AS ������, horizon AS ����ƫ��, 
vertical AS �߳�ƫ��, dif_horizon AS ���Ҷ˺����, dif_vertical AS ���Ҷ˸̲߳�, in_dl AS ��������ƽ˳��, 
in_dq AS ���ں���ƽ˳��, in_dh AS ���ڸ߳�ƽ˳��, out_dq AS ������ƽ˳��, out_dh AS ���߳�ƽ˳��
FROM      (SELECT   ROW_NUMBER() OVER (ORDER BY t1.ro_code) AS rn, t1.ro_code AS code, t1.ro_name AS name, 
                t1.ro_bstat AS bstat, t1.ro_estat AS estat, t1.ro_cstat AS cstat, t1.ro_len AS len, t1.ro_count AS count, 
                t1.ro_mask AS mask, 
                CASE WHEN t1.ro_mileage > t2.ro_mileage THEN t1.ro_mileage ELSE t2.ro_mileage END AS mileage, 
                CASE WHEN ABS(t1.ro_horizon) > ABS(t2.ro_horizon) THEN t1.ro_horizon ELSE t2.ro_horizon END AS horizon, 
                CASE WHEN t1.ro_vertical > t2.ro_vertical THEN t1.ro_vertical ELSE t2.ro_vertical END AS vertical, 
                CASE WHEN ABS(t1.ro_dif_horizon) > ABS(t2.ro_dif_horizon) THEN t1.ro_dif_horizon ELSE t2.ro_dif_horizon END AS dif_horizon, 
                CASE WHEN t1.ro_dif_vertical > t2.ro_dif_vertical THEN t1.ro_dif_vertical ELSE t2.ro_dif_vertical END AS dif_vertical, 
                CASE WHEN ABS(t1.ro_in_dl) > ABS(t2.ro_in_dl) THEN t1.ro_in_dl ELSE t2.ro_in_dl END AS in_dl, 
                CASE WHEN ABS(t1.ro_in_dq) > ABS(t2.ro_in_dq) THEN t1.ro_in_dq ELSE t2.ro_in_dq END AS in_dq, 
                CASE WHEN t1.ro_in_dh > t2.ro_in_dh THEN t1.ro_in_dh ELSE t2.ro_in_dh END AS in_dh, 
                CASE WHEN ABS(t1.ro_out_dq) > ABS(t2.ro_out_dq) THEN t1.ro_out_dq ELSE t2.ro_out_dq END AS out_dq, 
                CASE WHEN t1.ro_out_dh > t2.ro_out_dh THEN t1.ro_out_dh ELSE t2.ro_out_dh END AS out_dh
FROM      (SELECT   ROW_NUMBER() OVER (ORDER BY ro_code) AS rn1, ro_code, ro_name, ro_bstat, ro_estat, ro_cstat, ro_len, 
                ro_count, ro_mask, ro_mileage, ro_horizon, ro_vertical, ro_dif_horizon, ro_dif_vertical, ro_in_dl, ro_in_dq, ro_in_dh, 
                ro_out_dq, ro_out_dh
FROM      dbo.tp_retest_orbit) t1 INNER JOIN
    (SELECT   ROW_NUMBER() OVER (ORDER BY ro_code) AS rn2, ro_code, ro_name, ro_bstat, ro_estat, ro_cstat, ro_len, 
ro_count, ro_mask, ro_mileage, ro_horizon, ro_vertical, ro_dif_horizon, ro_dif_vertical, ro_in_dl, ro_in_dq, ro_in_dh, ro_out_dq, 
ro_out_dh
FROM      dbo.tp_retest_orbit) t2 ON t1.rn1 = t2.rn2 - 1) t
WHERE   rn % 2 = 1