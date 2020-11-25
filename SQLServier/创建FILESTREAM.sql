create database ProjectManage
on
primary (name=ProjectManage,filename='E:\ProjectManage\ProjectManage.mdf'),
filegroup FTP contains filestream(name=FTP, filename='E:\ProjectManage\FTP')
log on (name=ProjectManage_log,filename='E:\ProjectManage\ProjectManage_log.ldf')
go