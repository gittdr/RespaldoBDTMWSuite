SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[grant_user_audit_access] @user           VARCHAR(20),
                                             @login          VARCHAR(100)
AS
DECLARE @sql         NVARCHAR(400),
        @database    VARCHAR(100)

SELECT @database = ISNULL(gi_string2, '')
  FROM generalinfo 
 WHERE gi_name = 'UserDefinedAuditing'

SET @sql = 'USE ' + @database + ' CREATE USER [' + @user + '] FOR LOGIN [' + @login + '] WITH DEFAULT_SCHEMA=[dbo]'

EXEC sp_executesql @sql

GO
GRANT EXECUTE ON  [dbo].[grant_user_audit_access] TO [public]
GO
