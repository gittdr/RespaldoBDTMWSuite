IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TDR\emolvera')
CREATE LOGIN [TDR\emolvera] FROM WINDOWS
GO
CREATE USER [TDR\emolvera] FOR LOGIN [TDR\emolvera]
GO
