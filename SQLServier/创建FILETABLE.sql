-- =========================================
-- Create FileTable template
-- =========================================
USE ProjectManage
GO

IF OBJECT_ID('�����ļ�', 'U') IS NOT NULL
  DROP TABLE �����ļ�
GO
CREATE TABLE �����ļ� AS FILETABLE
WITH
(
  FILETABLE_DIRECTORY = '�����ļ�',
  FILETABLE_COLLATE_FILENAME = database_default
)
GO

IF OBJECT_ID('�����ļ�', 'U') IS NOT NULL
  DROP TABLE �����ļ�
GO
CREATE TABLE �����ļ� AS FILETABLE
WITH
(
  FILETABLE_DIRECTORY = '�����ļ�',
  FILETABLE_COLLATE_FILENAME = database_default
)
GO

IF OBJECT_ID('��˾�ļ�', 'U') IS NOT NULL
  DROP TABLE ��˾�ļ�
GO
CREATE TABLE ��˾�ļ� AS FILETABLE
WITH
(
  FILETABLE_DIRECTORY = '��˾�ļ�',
  FILETABLE_COLLATE_FILENAME = database_default
)
GO

IF OBJECT_ID('��ʱ�ļ�', 'U') IS NOT NULL
  DROP TABLE ��ʱ�ļ�
GO
CREATE TABLE ��ʱ�ļ� AS FILETABLE
WITH
(
  FILETABLE_DIRECTORY = '��ʱ�ļ�',
  FILETABLE_COLLATE_FILENAME = database_default
)
GO

IF OBJECT_ID('����ļ�', 'U') IS NOT NULL
  DROP TABLE ����ļ�
GO
CREATE TABLE ����ļ� AS FILETABLE
WITH
(
  FILETABLE_DIRECTORY = '����ļ�',
  FILETABLE_COLLATE_FILENAME = database_default
)
GO

IF OBJECT_ID('ʩ��ͼֽ', 'U') IS NOT NULL
  DROP TABLE ʩ��ͼֽ
GO
CREATE TABLE ʩ��ͼֽ AS FILETABLE
WITH
(
  FILETABLE_DIRECTORY = 'ʩ��ͼֽ',
  FILETABLE_COLLATE_FILENAME = database_default
)
GO

IF OBJECT_ID('ʩ���ļ�', 'U') IS NOT NULL
  DROP TABLE ʩ���ļ�
GO
CREATE TABLE ʩ���ļ� AS FILETABLE
WITH
(
  FILETABLE_DIRECTORY = 'ʩ���ļ�',
  FILETABLE_COLLATE_FILENAME = database_default
)
GO
