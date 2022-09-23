SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_sys_adduser_sp]
                 @usr_userid varchar(100),
                 @usr_windows_userid varchar(100),
                 @defaultdb varchar(100)

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_sys_adduser_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Stub procedure for future security integration
    
EXECUTION and INPUTS:


EXEC  tmw_sys_adduser_sp 'USERA','USERA',''

 * 01/21/2010     - MDH - Changed to check for SQL Server 2000 instead of 2005.

----------------------------------------------------------------------------------*/

declare @error int,
        @sql nvarchar(4000),
        @resolved_id varchar(100)
        
--Determine rdbms version
If charindex('SQL SERVER  2000',UPPER(@@version) ) = 0 
BEGIN
    if isnull(@usr_windows_userid,'')<>'' 
        set @resolved_id = @usr_windows_userid
    else
        set @resolved_id = @usr_userid
        

    --If the windows user id is set (windows authentication) then
    --the user is associated with the windows user id, not the standard user id
    set @sql = 'CREATE USER ['+@usr_userid+'] FOR LOGIN ['+@resolved_id+']'
    exec (@sql)
    set @error = @@error
END	
Else
BEGIN
    exec @error = sp_adduser @usr_userid
END

return @error
GO
GRANT EXECUTE ON  [dbo].[tmw_sys_adduser_sp] TO [public]
GO
