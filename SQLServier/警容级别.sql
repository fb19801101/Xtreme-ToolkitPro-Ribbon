/*

语法
ALTER DATABASE database_name 
SET COMPATIBILITY_LEVEL = { 80 | 90 | 100 }
 
参数
database_name 
要修改的数据库的名称。

COMPATIBILITY_LEVEL { 80 | 90 | 100 }
要使数据库与之兼容的 SQL Server 版本。该值必须为下列值之一：
= SQL Server 2000 
= SQL Server 2005 
= SQL Server 2008 

备注
对于所有 SQL Server 2008 安装，默认的兼容级别都为 100。除非 model 数据库有更低的兼容级别，否则 SQL Server 2008 中创建的数据库会设置为该级别。将数据库从 SQL Server 的任何早期版本升级到 SQL Server 2008 时，如果数据库的兼容级别不在 80 以下，则该数据库将保留其现有的兼容级别。升级兼容级别低于 80 的数据库会将数据库的兼容级别设置为 80。这既适用于系统数据库，也适用于用户数据库。使用 ALTER DATABASE 可更改数据库的兼容级别。若要查看数据库的当前兼容级别，请查询 sys.databases 目录视图中的 compatibility_level 列。

利用兼容级别获得向后兼容
兼容级别只影响指定数据库的行为，而不影响整个服务器的行为。兼容级别只实现与 SQL Server 的早期版本保持部分向后兼容。通过将兼容级别用作临时性的迁移辅助工具，可解决相关兼容级别设置控制的行为之间存在的版本差异问题。如果现有 SQL Server 应用程序受到 SQL Server 2008 中行为差异的影响，请对该应用程序进行转换，使之能正常运行。然后使用 ALTER DATABASE 将兼容级别更改为 100。数据库的新兼容性设置将在该数据库下次成为当前数据库（无论是在登录时作为默认数据库还是在 USE 语句中指定）时生效。

最佳实践
如果在用户连接到数据库时更改兼容级别，可能会使活动查询产生不正确的结果集。例如，如果在编写查询计划时兼容级别发生更改，则编写后的计划可能同时基于旧的和新的兼容级别，从而造成计划不正确，并可能导致结果不准确。此外，如果将计划放在计划缓存中供后续的查询重用，则问题可能更加复杂。为了避免查询结果不准确，建议您使用以下过程来更改数据库的兼容级别：

1. 通过使用 ALTER DATABASE SET SINGLE_USER，将数据库设置为单用户访问模式。
2. 更改数据库的兼容级别。
3. 通过使用 ALTER DATABASE SET MULTI_USER，将数据库设为多用户访问模式。
   有关设置数据库访问模式的详细信息，请参阅 ALTER DATABASE (Transact-SQL)。
*/


--获取数据库兼容级别
SELECT name ,compatibility_level ,recovery_model_desc FROM sys.databases WITH(NOLOCK)

--将用户设置为单用户访问模式
ALTER DATABASE test SET SINGLE_USER

--修改数据库的兼容级别
ALTER DATABASE TEST
SET COMPATIBILITY_LEVEL = 90
--or
EXEC sp_dbcmptlevel TEST, 90;
GO



--将用户设置为多用户访问模式
ALTER DATABASE test SET MULTI_USER

/*
语法
sp_dbcmptlevel [ [ @dbname = ] name ] 
    [ , [ @new_cmptlevel = ] version ]
 

参数
[ @dbname = ] name
要为其更改兼容级别的数据库的名称。数据库名称必须符合标识符的规则。name 的数据类型为 sysname，默认值为 NULL。

[ @new_cmptlevel = ] version
数据库要与之兼容的 SQL Server 的版本。version 的数据类型为 tinyint，默认值为 NULL。该值必须为下列值之一：
= SQL Server 2000 
= SQL Server 2005 
= SQL Server 2008 

返回代码值
0（成功）或 1（失败）

结果集
如果未指定任何参数或未指定 name 参数，则 sp_dbcmptlevel 将返回错误。

如果指定 name 但未指定 version，则 数据库引擎将返回一条消息，显示指定数据库的当前兼容级别。

备注
有关兼容级别的说明，请参阅 ALTER DATABASE 兼容级别 (Transact-SQL)。

权限
只有数据库所有者、sysadmin 固定服务器角色和 db_owner 固定数据库角色的成员（前提是您要更改当前数据库）才能执行此过程。

*/