USE ProjectManage
DBCC FREEPROCCACHE; 
GO 

SELECT * FROM 路基数量 where ID=1
GO 

EXEC sp_executesql N'SELECT * FROM 路基数量 where ID=@_id',
N'@_id INT', @_id = 2
GO

SELECT stats.execution_count AS cnt, 
p.size_in_bytes AS [size], 
[sql].[text] AS [plan_text] 
FROM sys.dm_exec_cached_plans p 
OUTER APPLY sys.dm_exec_sql_text (p.plan_handle) sql 
JOIN sys.dm_exec_query_stats stats 
ON stats.plan_handle = p.plan_handle