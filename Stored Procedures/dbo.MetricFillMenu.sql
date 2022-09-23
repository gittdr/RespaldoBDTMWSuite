SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricFillMenu]
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @ThisDBName varchar(60), @ThisServerName varchar(60)
	SELECT @ThisDBName = RTRIM(name),
		@ThisServerName = RTRIM(CONVERT(varchar(60), CASE WHEN cmptlevel = '70' THEN @@servername ELSE SERVERPROPERTY('servername') END))
	 FROM master..sysdatabases WHERE dbid = (SELECT dbid FROM master..sysprocesses WHERE spid = @@spid)

	DECLARE @object int
	DECLARE @hr int
	DECLARE @src varchar(255), @desc varchar(255)

	--***** CREATE AvtiveX DLL.
	EXEC @hr = sp_OACreate 'ResultsNow.clsInitialize', @object OUT --, 4
	IF @hr <> 0
	BEGIN
		EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT 
		IF @hr = -2147221005 SELECT @desc = 'TMW Message: DLL appears to not be registered.  SQL Server message: ' + @desc
		-- SELECT CONVERT(varbinary(4), @hr) AS hr, @src AS Source , @desc AS Description 
		SELECT -1, -1, 'TMW License Issue', @desc, -1, -1, -1, -1, -1, 'License Page', 'License Page', -1, 'MetricLicenseProblem.asp?CODE=DLLPROBLEM', 1000
		RETURN		

	END

	--***** Call Method for ActiveX DLL
	EXEC @hr = sp_OAMethod @object, 'InitMenus', NULL, 
		@ThisServerName, @ThisDBName
	IF @hr <> 0
	BEGIN
		EXEC sp_OAGetErrorInfo @object
		RETURN
	END

	EXEC @hr = sp_OADestroy @object
	IF @hr <> 0
	BEGIN
	   EXEC sp_OAGetErrorInfo @object
	END
GO
GRANT EXECUTE ON  [dbo].[MetricFillMenu] TO [public]
GO
