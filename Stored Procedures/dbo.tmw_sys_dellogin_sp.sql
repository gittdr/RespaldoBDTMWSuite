SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_sys_dellogin_sp]
                 @usr_userid varchar(100),
                 @usr_windows_userid varchar(100)

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_sys_dellogin_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Stub procedure for future security integration
    
EXECUTION and INPUTS:


EXEC  tmw_sys_dellogin_sp 'KDECELLE2','TRIORG\kdecelle'

 * 01/21/2010     - MDH - Changed to check for SQL Server 2000 instead of 2005.

----------------------------------------------------------------------------------*/

declare @error int,
        @sql nvarchar(4000),
        @resolveduser varchar(255)

--Default the resolved user id to the standard TMW user id (usr_userid from ttsusers)
set @resolveduser = @usr_userid
        
--Determine rdbms version
If charindex('SQL SERVER  2000',UPPER(@@version)) = 0 
BEGIN

    --If the user is configured for windows authentication, the login will be the
    --value of usr_windows_userid from ttsusers
    if isnull(@usr_windows_userid,'')<>'' 
    BEGIN    
        set @resolveduser = @usr_windows_userid
    END
    set @sql = 'drop login ['+@resolveduser+']'
    exec (@sql)
    set @error = @@error
END	
ELSE
BEGIN
    exec  @error = sp_droplogin @resolveduser
END

return @error
GO
GRANT EXECUTE ON  [dbo].[tmw_sys_dellogin_sp] TO [public]
GO
