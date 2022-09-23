IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TDR\Administrator')
CREATE LOGIN [TDR\Administrator] FROM WINDOWS
GO
CREATE USER [TDR\Administrator] FOR LOGIN [TDR\Administrator]
GO
