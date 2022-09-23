SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_sys_addlogin_sp]
                 @usr_userid varchar(100),
                 @usr_windows_userid varchar(100),
                 @pword varchar(100),
                 @defaultdb varchar(100)

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_sys_addlogin_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Stub procedure for future security integration
    
EXECUTION and INPUTS:


EXEC  tmw_sys_addlogin_sp 'USERA','USERA','PWORDA','TMWPB'

 * 01/21/2010     - MDH - Changed to check for SQL Server 2000 instead of 2005.

----------------------------------------------------------------------------------*/

declare @error int,
        @sql nvarchar(4000)
        
--Determine rdbms version
If charindex('SQL SERVER  2000',UPPER(@@version)) = 0 
BEGIN
    if isnull(@usr_windows_userid,'')<>'' 
    BEGIN
        --The syntax for windows authenticated logins is different from the standard user login        
        set @sql = 'CREATE LOGIN ['+@usr_windows_userid+'] FROM WINDOWS WITH DEFAULT_DATABASE = '+@defaultdb
        exec (@sql)
        set @error = @@error
    END
    ELSE
    BEGIN        
        set @sql = 'CREATE LOGIN ['+@usr_userid+'] WITH PASSWORD = '''+@pword+''' , DEFAULT_DATABASE ='+ @defaultdb+', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF '

        exec (@sql)
        set @error = @@error
    END        
END	
Else
BEGIN
    --Legacy support
    exec @error = sp_addlogin @usr_userid,@pword,@defaultdb
    
END

return @error
GO
GRANT EXECUTE ON  [dbo].[tmw_sys_addlogin_sp] TO [public]
GO
