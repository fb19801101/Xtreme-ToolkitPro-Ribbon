USE [master]
GO
CREATE DATABASE [ProjectManage] ON 
( FILENAME = N'F:\ProjectManage\ProjectManage.mdf' ),
( FILENAME = N'F:\ProjectManage\ProjectManage_log.ldf' )
 FOR ATTACH WITH FILESTREAM ( DIRECTORY_NAME = N'FTP' );
GO
