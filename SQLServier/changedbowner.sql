USE [master]  
GO
EXEC dbo.sp_dbcmptlevel @dbname='ProjectManage', @new_cmptlevel=90
GO

USE [ProjectManage]
GO
EXEC sp_changedbowner 'sa'