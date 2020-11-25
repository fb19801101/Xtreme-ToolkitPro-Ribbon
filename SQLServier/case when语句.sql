SELECT   ROW_NUMBER() OVER (ORDER BY 起点里程) AS 序号, MIN(工点名称) AS 工点名称, 起点里程, MIN(终点里程) 
AS 终点里程, MIN(中心里程) AS 中心里程, MIN(线路长度) AS 线路长度, MIN(布板数量) AS 布板数量, 
COUNT(CASE WHEN 横向偏差 >= 4 OR 横向偏差 <= -4 THEN 横向偏差 END) AS [横向偏差≥4;≤-4],
COUNT(CASE WHEN 横向偏差 < 4 AND 横向偏差 > -4 THEN 横向偏差 END) AS [横向偏差＞-4_＜4],
COUNT(CASE WHEN 高程偏差 >= 4 THEN 高程偏差 END) AS [高程偏差≥4],
COUNT(CASE WHEN 高程偏差 < 4 AND 高程偏差 > 3 THEN 高程偏差 END) AS [高程偏差＞3_＜4],
COUNT(CASE WHEN 高程偏差 <= 3 THEN 高程偏差 END) AS [高程偏差≤3],
COUNT(CASE WHEN 板内横向平顺性 >= 4 OR 板内横向平顺性 <= -4 THEN 板内横向平顺性 END) AS [板内横向平顺性≥4;≤-4], 
COUNT(CASE WHEN 板内横向平顺性 < 4 AND 板内横向平顺性 > -4 THEN 板内横向平顺性 END) AS [板内横向平顺性＞-4_＜4],
COUNT(CASE WHEN 板内高程平顺性 >= 4 THEN 板内高程平顺性 END) AS [板内高程平顺性≥4],
COUNT(CASE WHEN 板内高程平顺性 < 4 AND 板内高程平顺性 > 3 THEN 板内高程平顺性 END) AS [板内高程平顺性＞3_＜4],
COUNT(CASE WHEN 板内高程平顺性 <= 3 THEN 板内高程平顺性 END) AS [板内高程平顺性≤3],
COUNT(CASE WHEN 板间横向平顺性 >= 4 OR 板间横向平顺性 <= -4 THEN 板间横向平顺性 END) AS [板间横向平顺性≥4;≤-4], 
COUNT(CASE WHEN 板间横向平顺性 < 4 AND 板间横向平顺性 > -4 THEN 板间横向平顺性 END) AS [板间横向平顺性＞-4_＜4], 
COUNT(CASE WHEN 板间高程平顺性 >= 4 THEN 板间高程平顺性 END) AS [板间高程平顺性≥4],
COUNT(CASE WHEN 板间高程平顺性 < 4 AND 板间高程平顺性 > 3 THEN 板间高程平顺性 END) AS [板间高程平顺性＞3_＜4],
COUNT(CASE WHEN 板间高程平顺性 <= 3 THEN 板间高程平顺性 END) AS [板间高程平顺性≤3]
FROM      dbo.tp_retest_orbit_sum
GROUP BY 起点里程





SELECT   ROW_NUMBER() OVER (ORDER BY code) AS 序号, name AS 工点名称, bstat AS 起点里程, estat AS 终点里程, 
cstat AS 中心里程, len AS 线路长度, count AS 布板数量, mask AS 布板板号, mileage AS 测点里程, horizon AS 横向偏差, 
vertical AS 高程偏差, dif_horizon AS 左右端横向差, dif_vertical AS 左右端高程差, in_dl AS 板内纵向平顺性, 
in_dq AS 板内横向平顺性, in_dh AS 板内高程平顺性, out_dq AS 板间横向平顺性, out_dh AS 板间高程平顺性
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