SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[totalmail_connection_fn]()
RETURNS varchar(1000)

AS 
BEGIN
	DECLARE @ServerName varchar(255)
	DECLARE @DatabaseName varchar(255)

	DECLARE @SQLDyn varchar(2500)
	DECLARE @Prefix varchar(1000)
	DECLARE @ConnectionServerName varchar(255)
	DECLARE @HoursOfServiceFormID varchar(255)

	Set @Prefix = ''

	SELECT	@ConnectionServerName = RTRIM	(	CONVERT	(varchar(60),	CASE WHEN cmptlevel = '70' THEN 
																			@@servername 
																		ELSE 
																			SERVERPROPERTY('servername') 
																		END
														)
											)
	FROM	master..sysdatabases 
	WHERE	dbid = (	SELECT	dbid 
						FROM	master..sysprocesses 
						WHERE spid = @@spid
					)

	SELECT	@ServerName = gi_string1,
			@DatabaseName = gi_string2
	FROM	generalinfo
	WHERE	gi_name = 'TOTALMAIL'

	--PTS80644 JJF 20141027
	IF LEFT(@ConnectionServerName, 1) <> '[' BEGIN
		SET @ConnectionServerName = '[' + @ConnectionServerName + ']'
	END
	IF LEFT(@ServerName, 1) <> '[' BEGIN
		SET @ServerName = '[' + @ServerName + ']'
	END
	IF LEFT(@DatabaseName, 1) <> '[' BEGIN
		SET @DatabaseName = '[' + @DatabaseName + ']'
	END
	

	IF @ServerName = '[localhost]' BEGIN
		SELECT	@ServerName = ''
		end

		-- by emolvera to solve treating local server as linked server issue
		IF @ServerName like '%172.24.16.112%' BEGIN
		SELECT	@ServerName = ''

	END

	IF LEN(@DatabaseName) > 0 BEGIN
		SET	@Prefix =	CASE WHEN LEN(@ServerName) > 0 And @ConnectionServerName <> @ServerName THEN
							@ServerName + '.' + @DatabaseName + '.' 
						ELSE
							@DatabaseName + '.' 
						END
	END



	
	RETURN @Prefix
	
END
GO
GRANT EXECUTE ON  [dbo].[totalmail_connection_fn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[totalmail_connection_fn] TO [public]
GO
