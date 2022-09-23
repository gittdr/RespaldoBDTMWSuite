SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[drop_user_audit_access] @user           VARCHAR(20)
AS
DECLARE @sql         NVARCHAR(400),
        @database    VARCHAR(100)

SELECT @database = ISNULL(gi_string2, '')
  FROM generalinfo 
 WHERE gi_name = 'UserDefinedAuditing'

SET @sql = 'USE ' + @database + ' DROP USER [' + @user + ']'

EXEC sp_executesql @sql

GO
GRANT EXECUTE ON  [dbo].[drop_user_audit_access] TO [public]
GO
