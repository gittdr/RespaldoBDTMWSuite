SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_sys_deluser_sp]
                 @usr_userid varchar(100),
                 @usr_windows_userid varchar(100)

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_sys_deluser_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Stub procedure for future security integration
    
EXECUTION and INPUTS:


EXEC  tmw_sys_deluser_sp 'USERA','USERA'

 * 01/21/2010     - MDH - Changed to check for SQL Server 2000 instead of 2005.

----------------------------------------------------------------------------------*/

declare @error int,
        @sql nvarchar(4000)

If charindex('SQL SERVER  2000',UPPER(@@version)) = 0 
BEGIN
    set @sql = 'DROP USER [' + @usr_userid + ']'
    exec (@sql)
    set @error = @@error
END
ELSE
BEGIN
	exec @error = sp_dropuser @usr_userid
END

return @error
GO
GRANT EXECUTE ON  [dbo].[tmw_sys_deluser_sp] TO [public]
GO
